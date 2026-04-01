import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';

final timeChunksByDateProvider =
    StreamProvider.family<List<TimeChunk>, String>((ref, date) {
  final db = ref.watch(databaseProvider);
  return db.watchTimeChunksByDate(date);
});

final backlogChunksProvider = StreamProvider<List<TimeChunk>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchBacklogChunks();
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
