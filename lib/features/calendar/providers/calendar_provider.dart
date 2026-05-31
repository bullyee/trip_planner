import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/time_chunk_model.dart';
import '../repositories/time_chunk_repository.dart';

final timeChunksByDateProvider =
    StreamProvider.family<List<TimeChunkModel>, String>((ref, date) {
  return ref.watch(timeChunkRepositoryProvider).watchTimeChunksByDate(date);
});

// 淨化這裡：改為回傳 List<TimeChunkModel> 並呼叫 Repository
final backlogChunksProvider = StreamProvider<List<TimeChunkModel>>((ref) {
  return ref.watch(timeChunkRepositoryProvider).watchBacklogChunks();
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});