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

/// Converts a "HH:mm" time string into continuous timeline minutes relative to a reference
/// point, properly handling crossings past midnight.
int toContinuousMinutes(String timeString, int referenceMinutes) {
  int mins = timeStringToMinutes(timeString);
  final int dayOffset = (referenceMinutes ~/ 1440) * 1440;
  mins += dayOffset;
  if (mins < referenceMinutes && (referenceMinutes - mins) > 720) {
    mins += 1440;
  }
  return mins;
}

/// Represents the gap or conflict between two consecutive scheduled chunks.
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

/// Calculates the gap or conflict between two scheduled chunks, taking transit and
/// midnight wrap-around into account.
ScheduleGapInfo? calculateScheduleGap(TimeChunkModel prevChunk, TimeChunkModel currChunk) {
  final prevEnd = prevChunk.endTime;
  final currStart = currChunk.startTime;
  if (prevEnd == null || prevEnd == '--:--' || currStart == null || currStart == '--:--') {
    return null;
  }

  final int prevStartMinutes = timeStringToMinutes(prevChunk.startTime ?? '00:00');
  int prevEndMinutes = timeStringToMinutes(prevEnd);
  if (prevEndMinutes < prevStartMinutes) {
    prevEndMinutes += 1440;
  }
  final int arrivalMinutes = prevEndMinutes + prevChunk.transitDuration;

  final int currStartMinutes = toContinuousMinutes(currStart, prevStartMinutes);
  final int diff = currStartMinutes - arrivalMinutes;

  if (diff > 0) {
    return ScheduleGapInfo(
      gapMinutes: diff,
      isConflict: false,
      conflictMinutes: 0,
      freeTimeMinutes: diff,
    );
  } else if (diff < 0) {
    return ScheduleGapInfo(
      gapMinutes: diff,
      isConflict: true,
      conflictMinutes: -diff,
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
      final firstStart = firstChunk.startTime;
      if (firstLocked != null) {
        final lockedMinutes = timeStringToMinutes(firstLocked.startTime!);
        final neededDuration = firstChunk.duration + firstChunk.transitDuration;
        if (firstStart != null && firstStart != '--:--') {
          final firstMins = timeStringToMinutes(firstStart);
          // If first flexible chunk's stored time was after downstream locked chunk
          // (e.g. dragged from below afternoon locked chunk to top), reset it to start
          // in the morning (09:00) only if there is adequate room before the locked chunk.
          if (firstMins >= lockedMinutes && (lockedMinutes - neededDuration >= 540)) {
            currentTimeCursor = '09:00';
          } else {
            currentTimeCursor = firstStart;
          }
        } else {
          if (lockedMinutes - neededDuration >= 540) {
            currentTimeCursor = '09:00';
          } else {
            currentTimeCursor = firstLocked.startTime!;
          }
        }
      } else {
        final validTimes = sortedChunks
            .map((c) => c.startTime)
            .where((t) => t != null && t != '--:--')
            .cast<String>()
            .toList();
        if (validTimes.isNotEmpty) {
          currentTimeCursor = validTimes.reduce((a, b) => a.compareTo(b) < 0 ? a : b);
        }
      }
    }

    int cursorMinutes = timeStringToMinutes(currentTimeCursor);
    int referenceMinutes = cursorMinutes;

    final List<TimeChunkModel> calculatedChunks = [];

    // 2. Cascade down the list
    for (final chunk in sortedChunks) {
      String calculatedStartTime;
      int chunkStartMinutes;

      if (chunk.isFixedTime && chunk.startTime != null && chunk.startTime != '--:--') {
        calculatedStartTime = chunk.startTime!;
        chunkStartMinutes = toContinuousMinutes(calculatedStartTime, referenceMinutes);

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
      referenceMinutes = cursorMinutes;

      calculatedChunks.add(
        chunk.copyWith(
          startTime: calculatedStartTime,
          endTime: calculatedEndTime,
        ),
      );
    }

    // 3. Chronological normalization:
    // Sort chunks strictly by continuous start minutes so that both time and sortOrder
    // are in chronological order. Stable sort preserves relative order for chunks starting at identical time.
    final initialCursorMins = timeStringToMinutes(currentTimeCursor);
    calculatedChunks.sort((a, b) {
      final aStart = toContinuousMinutes(a.startTime ?? '00:00', initialCursorMins);
      final bStart = toContinuousMinutes(b.startTime ?? '00:00', initialCursorMins);
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
