import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/schedule_engine.dart';
import '../models/time_chunk_model.dart';
import '../repositories/time_chunk_repository.dart';

part 'calendar_provider.g.dart';

@riverpod
Stream<List<TimeChunkModel>> timeChunksByDate(TimeChunksByDateRef ref, String date) {
  return ref.watch(timeChunkRepositoryProvider).watchTimeChunksByDate(date);
}

@riverpod
Stream<List<TimeChunkModel>> backlogChunks(BacklogChunksRef ref) {
  return ref.watch(timeChunkRepositoryProvider).watchBacklogChunks();
}

// StateProvider is replaced by a Notifier class in code-gen
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();

  // Expose a method to update the state from the UI
  void updateDate(DateTime newDate) {
    state = newDate;
  }
}

// The successfully repatriated provider
@riverpod
Stream<List<TimeChunkModel>> timeChunksByPoi(TimeChunksByPoiRef ref, String poiId) {
  return ref.watch(timeChunkRepositoryProvider).watchTimeChunksByPoi(poiId);
}

@riverpod
ScheduleEngine scheduleEngine(ScheduleEngineRef ref) {
  final repository = ref.watch(timeChunkRepositoryProvider);
  return ScheduleEngine(repository);
}