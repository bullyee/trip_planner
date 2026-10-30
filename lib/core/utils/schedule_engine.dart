import 'dart:math' as math;
import '../../features/calendar/models/time_chunk_model.dart';
import '../../features/calendar/repositories/time_chunk_repository.dart';

/// Converts "HH:mm" to minutes from start of day (0..1439).
int timeStringToMinutes(String timeString) {
  final parts = timeString.split(':');
  if (parts.length != 2) return 0;
  return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
}

/// Converts continuous minutes to a formatted "HH:mm" time string (wrapping at 24:00).
String minutesToTimeString(int totalMinutes) {
  final int normalized = totalMinutes % 1440;
  final int positiveMinutes = normalized < 0 ? normalized + 1440 : normalized;
  final int hours = positiveMinutes ~/ 60;
  final int minutes = positiveMinutes % 60;
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
}

/// Converts a "HH:mm" time string into continuous timeline minutes within a day's schedule.
/// If the day starts during daytime/evening (>= 06:00 / 360 min), any time in early morning
/// (< 06:00 / 360 min) belongs to the next morning across midnight (+1440 min).
int toTimelineMinutes(String timeString, int dayStartMinutes) {
  final int mins = timeStringToMinutes(timeString);
  if (mins < 360 && dayStartMinutes >= 360) {
    return mins + 1440;
  }
  return mins;
}

/// Converts a "HH:mm" time string into continuous timeline minutes relative to a reference
/// point (or day start), properly handling crossings past midnight.
int toContinuousMinutes(String timeString, int referenceMinutes) {
  final int mins = timeStringToMinutes(timeString);
  final int dayOffset = (referenceMinutes ~/ 1440) * 1440;
  int candidate = mins + dayOffset;
  if (candidate < referenceMinutes) {
    final int hour = mins ~/ 60;
    final int refHour = (referenceMinutes % 1440) ~/ 60;
    // Crosses midnight if the time represents late-night/early-morning hours (00:00 - 05:59)
    // and reference point is already in the evening/night (>= 18:00),
    // or if the timeline reference itself is already past midnight (>= 1440).
    if ((hour < 6 && refHour >= 18) || (referenceMinutes >= 1440)) {
      candidate += 1440;
    }
  }
  return candidate;
}

/// Represents the gap or conflict between two scheduled chunks.
class ScheduleGapInfo {
  final int gapMinutes;
  final bool isConflict;
  final int conflictMinutes;
  final int freeTimeMinutes;

  const ScheduleGapInfo({
    required this.gapMinutes,
    required this.isConflict,
    required this.conflictMinutes,
    required this.freeTimeMinutes,
  });
}

/// Calculates the gap or conflict before [currChunk], optionally taking all [priorChunks]
/// into account to accurately reflect nested overlaps and multi-card timelines.
ScheduleGapInfo? calculateScheduleGap(
  TimeChunkModel prevChunk,
  TimeChunkModel currChunk, {
  List<TimeChunkModel>? priorChunks,
}) {
  final currStart = currChunk.startTime;
  if (currStart == null || currStart == '--:--') {
    return null;
  }

  // Determine timeline reference start point
  final baseList = (priorChunks != null && priorChunks.isNotEmpty)
      ? priorChunks
      : [prevChunk];

  final String dayRefStr = baseList.first.startTime ?? '00:00';
  final int dayRefMins = timeStringToMinutes(dayRefStr);

  int maxPriorArrival = -1;
  for (final p in baseList) {
    final pEnd = p.endTime;
    if (pEnd == null || pEnd == '--:--') continue;
    final int pStartMins = toTimelineMinutes(p.startTime ?? '00:00', dayRefMins);
    int pEndMins = toTimelineMinutes(pEnd, dayRefMins);
    if (pEndMins < pStartMins) {
      pEndMins += 1440;
    }
    final int pArrival = pEndMins + p.transitDuration;
    if (pArrival > maxPriorArrival) {
      maxPriorArrival = pArrival;
    }
  }

  if (maxPriorArrival < 0) return null;

  final int currStartMinutes = toTimelineMinutes(currStart, dayRefMins);
  final int currDuration = currChunk.duration;
  final int currEndMinutes = currStartMinutes + currDuration;
  final int currArrivalMinutes = currEndMinutes + currChunk.transitDuration;

  final int diff = currStartMinutes - maxPriorArrival;

  if (diff > 0) {
    return ScheduleGapInfo(
      gapMinutes: diff,
      isConflict: false,
      conflictMinutes: 0,
      freeTimeMinutes: diff,
    );
  } else if (diff < 0) {
    // Conflict overlap is the overlapping time between curr and the preceding occupied timeline
    final int overlap = math.max(0, math.min(currArrivalMinutes, maxPriorArrival) - currStartMinutes);
    return ScheduleGapInfo(
      gapMinutes: diff,
      isConflict: true,
      conflictMinutes: overlap,
      freeTimeMinutes: 0,
    );
  } else {
    return const ScheduleGapInfo(
      gapMinutes: 0,
      isConflict: false,
      conflictMinutes: 0,
      freeTimeMinutes: 0,
    );
  }
}

class ScheduleEngine {
  final TimeChunkRepository _repository;

  ScheduleEngine(this._repository);

  /// The core Auto-Cascading Engine for a specific day.
  Future<void> recalculateDaySchedule(List<TimeChunkModel> dayChunks) async {
    if (dayChunks.isEmpty) return;

    final sortedChunks = List<TimeChunkModel>.from(dayChunks)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    // Find the first chunk with a valid start time to establish the day's baseline timeline reference
    final String? firstValidTime = sortedChunks
        .map((c) => c.startTime)
        .firstWhere((t) => t != null && t != '--:--', orElse: () => null);
    final int dayRefMins = firstValidTime != null ? timeStringToMinutes(firstValidTime) : 540;

    // 1. Determine day's base timeline start
    String currentTimeCursor = '09:00';
    final firstChunk = sortedChunks.first;

    TimeChunkModel? firstLocked;
    for (final c in sortedChunks) {
      if (c.isFixedTime && c.startTime != null && c.startTime != '--:--') {
        firstLocked = c;
        break;
      }
    }

    if (firstChunk.isFixedTime &&
        firstChunk.startTime != null &&
        firstChunk.startTime != '--:--') {
      currentTimeCursor = firstChunk.startTime!;
    } else {
      // Find all valid flexible chunk start times
      final flexibleChunks = sortedChunks
          .where((c) => !c.isFixedTime && c.startTime != null && c.startTime != '--:--')
          .toList();

      String? earliestFlex;
      if (flexibleChunks.isNotEmpty) {
        final earliest = flexibleChunks.reduce((a, b) {
          final aMins = toTimelineMinutes(a.startTime!, dayRefMins);
          final bMins = toTimelineMinutes(b.startTime!, dayRefMins);
          return aMins <= bMins ? a : b;
        });
        earliestFlex = earliest.startTime;
      }

      if (firstLocked != null) {
        final lockedMinutes = toTimelineMinutes(firstLocked.startTime!, dayRefMins);
        final neededDuration = firstChunk.duration + firstChunk.transitDuration;

        if (earliestFlex != null) {
          final earliestFlexMins = toTimelineMinutes(earliestFlex, dayRefMins);
          // If earliest flex chunk was after downstream locked chunk
          // (e.g. dragged from below afternoon locked chunk to top),
          // reset it to 09:00 only if there is room before the locked chunk.
          if (earliestFlexMins >= lockedMinutes && (lockedMinutes - neededDuration >= 540)) {
            currentTimeCursor = '09:00';
          } else {
            currentTimeCursor = earliestFlex;
          }
        } else {
          if (lockedMinutes - neededDuration >= 540) {
            currentTimeCursor = '09:00';
          } else {
            currentTimeCursor = firstLocked.startTime!;
          }
        }
      } else {
        if (earliestFlex != null) {
          currentTimeCursor = earliestFlex;
        } else {
          final validTimes = sortedChunks
              .map((c) => c.startTime)
              .where((t) => t != null && t != '--:--')
              .cast<String>()
              .toList();
          if (validTimes.isNotEmpty) {
            final earliest = validTimes.reduce((a, b) {
              final aMins = toTimelineMinutes(a, dayRefMins);
              final bMins = toTimelineMinutes(b, dayRefMins);
              return aMins <= bMins ? a : b;
            });
            currentTimeCursor = earliest;
          }
        }
      }
    }

    int cursorMinutes = toTimelineMinutes(currentTimeCursor, dayRefMins);

    final List<TimeChunkModel> calculatedChunks = [];

    // 2. Cascade down the list
    for (final chunk in sortedChunks) {
      String calculatedStartTime;
      int chunkStartMinutes;

      if (chunk.isFixedTime && chunk.startTime != null && chunk.startTime != '--:--') {
        calculatedStartTime = chunk.startTime!;
        chunkStartMinutes = toTimelineMinutes(calculatedStartTime, dayRefMins);

        // If the chunk is locked later than cursor, advance cursor to lock time.
        // If cursor was already past lock time (overlap/conflict), lock time is respected,
        // and cursor stays at cursorMinutes (does not regress backwards).
        if (chunkStartMinutes > cursorMinutes) {
          cursorMinutes = chunkStartMinutes;
        }
      } else {
        // Flexible chunk cascades from cursor
        chunkStartMinutes = cursorMinutes;
        calculatedStartTime = minutesToTimeString(chunkStartMinutes);
      }

      final int chunkEndMinutes = chunkStartMinutes + chunk.duration;
      final String calculatedEndTime = minutesToTimeString(chunkEndMinutes);
      final int endWithTransitMinutes = chunkEndMinutes + chunk.transitDuration;

      // Only advance cursor forward; never regress backwards.
      if (endWithTransitMinutes > cursorMinutes) {
        cursorMinutes = endWithTransitMinutes;
      }

      calculatedChunks.add(
        chunk.copyWith(
          startTime: calculatedStartTime,
          endTime: calculatedEndTime,
        ),
      );
    }

    // 3. Chronological normalization:
    // Sort chunks strictly by continuous start minutes relative to day's start time
    // so that both time and sortOrder are in chronological order.
    // Chunks that crossed midnight belong at the end of the day, not before day start.
    final initialCursorMins = toTimelineMinutes(currentTimeCursor, dayRefMins);
    calculatedChunks.sort((a, b) {
      int aStart = toTimelineMinutes(a.startTime ?? '00:00', initialCursorMins);
      int bStart = toTimelineMinutes(b.startTime ?? '00:00', initialCursorMins);
      if (aStart != bStart) {
        return aStart.compareTo(bStart);
      }
      return a.sortOrder.compareTo(b.sortOrder);
    });

    // 4. Assign normalized sortOrder
    int currentNormalizedOrder = 1024;
    final List<TimeChunkModel> chunksToUpdate = [];
    for (final chunk in calculatedChunks) {
      chunksToUpdate.add(
        chunk.copyWith(sortOrder: currentNormalizedOrder),
      );
      currentNormalizedOrder += 1024;
    }

    if (chunksToUpdate.isNotEmpty) {
      await _repository.batchUpdateTimeChunks(chunksToUpdate);
    }
  }
}
