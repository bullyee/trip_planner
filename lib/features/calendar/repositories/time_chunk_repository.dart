// lib/features/calendar/repositories/time_chunk_repository.dart
import 'package:drift/drift.dart';

import '../models/time_chunk_model.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'time_chunk_repository.g.dart';

abstract class TimeChunkRepository {
  Future<void> addTimeChunk(TimeChunkModel chunk);
  Future<void> updateTimeChunk(TimeChunkModel chunk);
  Future<void> deleteTimeChunk(String id);
  Stream<List<TimeChunkModel>> watchTimeChunksByPoi(String poiId);
  Stream<List<TimeChunkModel>> watchTimeChunksByDate(String date);
  Stream<List<TimeChunkModel>> watchBacklogChunks();
}

class LocalTimeChunkRepository implements TimeChunkRepository {
  final AppDatabase localDb;

  LocalTimeChunkRepository(this.localDb);

  @override
  Future<void> addTimeChunk(TimeChunkModel chunk) async {
    // CRITICAL FIX: Map ALL fields from the model to prevent data loss.
    // Use the default Companion constructor and wrap everything in Value()
    // to maintain perfect consistency with updateTimeChunk.
    final companion = TimeChunksCompanion(
      id: Value(chunk.id),
      poiId: Value(chunk.poiId),
      // Use the explicitly injected authorId from the model, not the repository's context
      authorId: Value(chunk.authorId), 
      date: Value(chunk.date),
      startTime: Value(chunk.startTime),
      endTime: Value(chunk.endTime),
      status: Value(chunk.status ?? 'backlog'),       // Was missing!
      createdAt: Value(chunk.createdAt), // Was missing!
      isShared: Value(chunk.isShared),   // Was missing!
    );

    await localDb.insertTimeChunk(companion);
  }

  @override
  Stream<List<TimeChunkModel>> watchTimeChunksByPoi(String poiId) {
    final query = localDb.select(localDb.timeChunks)..where((t) => t.poiId.equals(poiId));
    return query.watch().map((list) {
      return list.map((chunk) => TimeChunkModel(
        id: chunk.id,
        poiId: chunk.poiId,
        authorId: chunk.authorId,
        date: chunk.date,
        startTime: chunk.startTime,
        endTime: chunk.endTime,
        status: chunk.status,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        isShared: false,
      )).toList();
    });
  }

  @override
  Future<void> updateTimeChunk(TimeChunkModel chunk) async {
    await localDb.updateTimeChunk(TimeChunksCompanion(
      id: Value(chunk.id),
      poiId: Value(chunk.poiId),
      authorId: Value(chunk.authorId),
      date: Value(chunk.date),
      startTime: Value(chunk.startTime),
      endTime: Value(chunk.endTime),
      status: Value(chunk.status ?? 'backlog'),
      createdAt: Value(chunk.createdAt),
      isShared: Value(chunk.isShared),
    ));
  }

  @override
  Future<void> deleteTimeChunk(String id) async {
    await localDb.deleteTimeChunk(id);
  }

  @override
  Stream<List<TimeChunkModel>> watchTimeChunksByDate(String date) {
    return localDb.watchTimeChunksByDate(date).map((list) {
      return list.map((chunk) => TimeChunkModel(
        id: chunk.id,
        poiId: chunk.poiId,
        authorId: chunk.authorId,
        date: chunk.date,
        startTime: chunk.startTime,
        endTime: chunk.endTime,
        status: chunk.status,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        isShared: false,
      )).toList();
    });
  }

  @override
  Stream<List<TimeChunkModel>> watchBacklogChunks() {
    return localDb.watchBacklogChunks().map((list) {
      return list.map((chunk) => TimeChunkModel(
        id: chunk.id,
        poiId: chunk.poiId,
        authorId: chunk.authorId,
        date: chunk.date,
        startTime: chunk.startTime,
        endTime: chunk.endTime,
        status: chunk.status,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        isShared: false,
      )).toList();
    });
  }
}

@riverpod
TimeChunkRepository timeChunkRepository(TimeChunkRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  return LocalTimeChunkRepository(db);
}