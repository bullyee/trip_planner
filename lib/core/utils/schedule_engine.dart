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
    final validTimes = dayChunks
        .map((c) => c.startTime)
        .where((t) => t != null && t != '--:--')
        .cast<String>()
        .toList();

    if (validTimes.isNotEmpty) {
      currentTimeCursor = validTimes.reduce((a, b) => a.compareTo(b) < 0 ? a : b);
    }

    final List<TimeChunkModel> chunksToUpdate = [];
    int currentNormalizedOrder = 1024;

    // 2. Cascade down the list
    for (final chunk in sortedChunks) {
      String calculatedStartTime;

      // Feature C: Fixed time collision detection
      if (chunk.isFixedTime && chunk.startTime != null && chunk.startTime != '--:--') {
        calculatedStartTime = chunk.startTime!; // Force lock time
        
        int cursorMins = _timeToMinutes(currentTimeCursor);
        int fixedMins = _timeToMinutes(calculatedStartTime);
        
        // If the calculated cursor is earlier than the fixed time, align to the fixed time.
        if (fixedMins > cursorMins) {
           currentTimeCursor = calculatedStartTime;
        }
      } else {
        // Normal cascading
        calculatedStartTime = currentTimeCursor;
      }

      final String calculatedEndTime = _addMinutes(calculatedStartTime, chunk.duration);
      currentTimeCursor = _addMinutes(calculatedEndTime, chunk.transitDuration);

      // CRITICAL FIX: Update both time and sortOrder simultaneously
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