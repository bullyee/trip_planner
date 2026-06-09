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
  Future<void> batchUpdateTimeChunks(List<TimeChunkModel> chunks);
  Stream<List<TimeChunkModel>> watchTimeChunksByPoi(String poiId);
  Stream<List<TimeChunkModel>> watchTimeChunksByDate(String date);
  Stream<List<TimeChunkModel>> watchBacklogChunks();
}

class LocalTimeChunkRepository implements TimeChunkRepository {
  final AppDatabase localDb;

  LocalTimeChunkRepository(this.localDb);

  TimeChunkModel _mapToDomain(dynamic dbChunk) {
    return TimeChunkModel(
      id: dbChunk.id,
      poiId: dbChunk.poiId,
      authorId: dbChunk.authorId,
      date: dbChunk.date,
      startTime: dbChunk.startTime,
      endTime: dbChunk.endTime,
      status: dbChunk.status,
      createdAt: dbChunk.createdAt, 
      isShared: dbChunk.isShared,
      sortOrder: dbChunk.sortOrder, 
      duration: dbChunk.duration,   
      transitDuration: dbChunk.transitDuration,
    );
  }

  @override
  Future<void> batchUpdateTimeChunks(List<TimeChunkModel> chunks) async {
    final companions = chunks.map((model) => TimeChunksCompanion(
      id: Value(model.id),
      poiId: Value(model.poiId),
      authorId: Value(model.authorId),
      date: Value(model.date),
      startTime: Value(model.startTime),
      endTime: Value(model.endTime),
      status: Value(model.status ?? 'backlog'),
      createdAt: Value(model.createdAt),
      isShared: Value(model.isShared),
      sortOrder: Value(model.sortOrder),
      duration: Value(model.duration),
      transitDuration: Value(model.transitDuration)
    )).toList();

    await localDb.batchUpdateTimeChunks(companions);
  }

  @override
  Future<void> addTimeChunk(TimeChunkModel chunk) async {
    final companion = TimeChunksCompanion(
      id: Value(chunk.id),
      poiId: Value(chunk.poiId),
      authorId: Value(chunk.authorId), 
      date: Value(chunk.date),
      startTime: Value(chunk.startTime),
      endTime: Value(chunk.endTime),
      status: Value(chunk.status ?? 'backlog'),       
      createdAt: Value(chunk.createdAt), 
      isShared: Value(chunk.isShared),
      sortOrder: Value(chunk.sortOrder),
      duration: Value(chunk.duration), 
      transitDuration: Value(chunk.transitDuration)
    );

    await localDb.insertTimeChunk(companion);
  }

  @override
  Stream<List<TimeChunkModel>> watchTimeChunksByPoi(String poiId) {
    final query = localDb.select(localDb.timeChunks)..where((t) => t.poiId.equals(poiId));
    return query.watch().map((list) => list.map(_mapToDomain).toList());
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
      sortOrder: Value(chunk.sortOrder),
      duration: Value(chunk.duration),
    ));
  }

  @override
  Future<void> deleteTimeChunk(String id) async {
    await localDb.deleteTimeChunk(id);
  }

  @override
  Stream<List<TimeChunkModel>> watchTimeChunksByDate(String date) {
    return localDb.watchTimeChunksByDate(date)
        .map((list) => list.map(_mapToDomain).toList());
  }

  @override
  Stream<List<TimeChunkModel>> watchBacklogChunks() {
    return localDb.watchBacklogChunks()
        .map((list) => list.map(_mapToDomain).toList());
  }
}

@riverpod
TimeChunkRepository timeChunkRepository(TimeChunkRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  return LocalTimeChunkRepository(db);
}