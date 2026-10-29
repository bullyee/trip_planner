import '../../features/calendar/models/time_chunk_model.dart';
import '../../features/calendar/repositories/time_chunk_repository.dart';

class ScheduleEngine {
  final TimeChunkRepository _repository;

  ScheduleEngine(this._repository);

  String _addMinutes(String timeString, int minutesToAdd) {
    final parts = timeString.split(':');
    if (parts.length != 2) return timeString;
    
    final int hours = int.tryParse(parts[0]) ?? 0;
    final int minutes = int.tryParse(parts[1]) ?? 0;
    
    final int totalMinutes = (hours * 60) + minutes + minutesToAdd;
    final int newHours = (totalMinutes ~/ 60) % 24;
    final int newMinutes = totalMinutes % 60;
    
    return '${newHours.toString().padLeft(2, '0')}:${newMinutes.toString().padLeft(2, '0')}';
  }

  int _timeToMinutes(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) return 0;
    return (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
  }

  /// The core Auto-Cascading Engine for a specific day.
  Future<void> recalculateDaySchedule(List<TimeChunkModel> dayChunks) async {
    if (dayChunks.isEmpty) return;

    final sortedChunks = List<TimeChunkModel>.from(dayChunks)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    String currentTimeCursor = '09:00';
    if (sortedChunks.first.isFixedTime &&
        sortedChunks.first.startTime != null &&
        sortedChunks.first.startTime != '--:--') {
      currentTimeCursor = sortedChunks.first.startTime!;
    } else {
      final flexibleTimes = sortedChunks
          .where((c) => !c.isFixedTime && c.startTime != null && c.startTime != '--:--')
          .map((c) => c.startTime!)
          .toList();
      if (flexibleTimes.isNotEmpty) {
        currentTimeCursor = flexibleTimes.reduce((a, b) => a.compareTo(b) < 0 ? a : b);
      } else {
        final anyValidTimes = sortedChunks
            .map((c) => c.startTime)
            .where((t) => t != null && t != '--:--')
            .cast<String>()
            .toList();
        if (anyValidTimes.isNotEmpty) {
          currentTimeCursor = anyValidTimes.first;
        }
      }
    }

    final List<TimeChunkModel> chunksToUpdate = [];
    int currentNormalizedOrder = 1024;

    // Cascade down the list
    for (final chunk in sortedChunks) {
      String calculatedStartTime;
      int cursorMins = _timeToMinutes(currentTimeCursor);

      // Fixed time collision detection
      if (chunk.isFixedTime && chunk.startTime != null && chunk.startTime != '--:--') {
        calculatedStartTime = chunk.startTime!; // Force lock time
        
        int fixedMins = _timeToMinutes(calculatedStartTime);
        
        // If the calculated cursor is earlier than the fixed time, align to the fixed time.
        if (fixedMins > cursorMins) {
          currentTimeCursor = calculatedStartTime;
          cursorMins = fixedMins;
        }
      } else {
        // Normal cascading
        calculatedStartTime = currentTimeCursor;
      }

      final String calculatedEndTime = _addMinutes(calculatedStartTime, chunk.duration);
      int endMins = _timeToMinutes(calculatedEndTime);
      if (endMins < _timeToMinutes(calculatedStartTime)) {
        endMins += 1440;
      }
      final int endWithTransitMins = endMins + chunk.transitDuration;

      // Only advance cursor forward; never jump backwards into the past.
      if (endWithTransitMins > cursorMins) {
        currentTimeCursor = _addMinutes(calculatedEndTime, chunk.transitDuration);
      }

      // Update both time and sortOrder simultaneously
      chunksToUpdate.add(
        chunk.copyWith(
          startTime: calculatedStartTime,
          endTime: calculatedEndTime,
          sortOrder: currentNormalizedOrder, 
        ),
      );
      
      currentNormalizedOrder += 1024;
    }

    if (chunksToUpdate.isNotEmpty) {
      await _repository.batchUpdateTimeChunks(chunksToUpdate);
    }
  }
}
