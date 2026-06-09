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

  /// The core Auto-Cascading Engine for a specific day.
  Future<void> recalculateDaySchedule(List<TimeChunkModel> dayChunks) async {
    if (dayChunks.isEmpty) return;

    // 1. Ensure chunks are sorted by visual order
    final sortedChunks = List<TimeChunkModel>.from(dayChunks)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    // FIX 1: Dynamically determine the anchor time instead of hardcoding '09:00'.
    // We find the earliest startTime in the current day's chunks before cascading.
    final String? earliestTime = dayChunks
        .map((c) => c.startTime)
        .reduce((a, b) => a!.compareTo(b!) < 0 ? a : b);

    String? currentTimeCursor = earliestTime; 
    final List<TimeChunkModel> chunksToUpdate = [];

    // FIX 2: Re-normalize sortOrder to prevent integer division collisions during UI drag.
    int currentNormalizedOrder = 1024;

    // 2. Cascade down the list
    for (final chunk in sortedChunks) {
      final String? calculatedStartTime = currentTimeCursor;
      final String calculatedEndTime = _addMinutes(calculatedStartTime!, chunk.duration);
      
      currentTimeCursor = _addMinutes(calculatedEndTime, chunk.transitDuration);

      // CRITICAL FIX: Update both time and sortOrder simultaneously to maintain DB health.
      chunksToUpdate.add(
        chunk.copyWith(
          startTime: calculatedStartTime,
          endTime: calculatedEndTime,
          sortOrder: currentNormalizedOrder, 
        ),
      );
      
      currentNormalizedOrder += 1024;
    }

    // 3. Force batch update all chunks to keep DB perfectly synced with UI memory
    if (chunksToUpdate.isNotEmpty) {
      await _repository.batchUpdateTimeChunks(chunksToUpdate);
    }
  }
}