// lib/features/calendar/repositories/time_chunk_repository.dart
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../models/time_chunk_model.dart';
import '../../../core/database/database.dart';
import '../../../core/database/tables.dart'; 
import '../../../core/providers/database_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'time_chunk_repository.g.dart';

abstract class TimeChunkRepository {
  Future<void> addTimeChunk(TimeChunkModel chunk);
  Future<void> updateTimeChunk(TimeChunkModel chunk);
  Future<void> deleteTimeChunk(String id);
  Future<void> batchUpdateTimeChunks(List<TimeChunkModel> chunks);
  Future<void> executeRebirth(TimeChunkModel stashedChunk, {required String newDate, String? newStartTime, String? newEndTime});
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
      sortOrder: dbChunk.sortOrder, 
      duration: dbChunk.duration,   
      transitDuration: dbChunk.transitDuration,
      isFixedTime: dbChunk.isFixedTime,
      syncStatus: dbChunk.syncStatus is int ? dbChunk.syncStatus : dbChunk.syncStatus.index,
      isDeleted: dbChunk.isDeleted,
      hasEverSynced: dbChunk.hasEverSynced,
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
      sortOrder: Value(model.sortOrder),
      duration: Value(model.duration),
      transitDuration: Value(model.transitDuration),
      isFixedTime: Value(model.isFixedTime),
      syncStatus: Value(SyncStatus.dirty.index),
      lastModifiedAt: Value(DateTime.now()),
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
      sortOrder: Value(chunk.sortOrder),
      duration: Value(chunk.duration), 
      transitDuration: Value(chunk.transitDuration),
      isFixedTime: Value(chunk.isFixedTime),
      syncStatus: Value(SyncStatus.dirty.index),
      hasEverSynced: const Value(false),
      lastModifiedAt: Value(DateTime.now()),
    );

    await localDb.insertTimeChunk(companion);
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
      sortOrder: Value(chunk.sortOrder),
      duration: Value(chunk.duration),
      isFixedTime: Value(chunk.isFixedTime),
      syncStatus: Value(SyncStatus.dirty.index),
      lastModifiedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> deleteTimeChunk(String id) async {
    await localDb.executeLocalDelete(id);
  }

  @override
  Future<void> executeRebirth(TimeChunkModel stashedChunk, {required String newDate, String? newStartTime, String? newEndTime}) async {
    final newChunkId = const Uuid().v4();

    await localDb.transaction(() async {
      final rebornCompanion = TimeChunksCompanion(
        id: Value(newChunkId),
        poiId: Value(stashedChunk.poiId),
        authorId: Value(stashedChunk.authorId),
        date: Value(newDate),
        startTime: Value(newStartTime),
        endTime: Value(newEndTime),
        status: const Value('scheduled'),
        sortOrder: Value(stashedChunk.sortOrder),
        duration: Value(stashedChunk.duration),
        transitDuration: Value(stashedChunk.transitDuration),
        isFixedTime: Value(stashedChunk.isFixedTime),
        syncStatus: Value(SyncStatus.dirty.index),
        isDeleted: const Value(false),
        hasEverSynced: const Value(false),
        lastModifiedAt: Value(DateTime.now()),
      );
      
      await localDb.into(localDb.timeChunks).insert(rebornCompanion);
      await (localDb.delete(localDb.timeChunks)..where((t) => t.id.equals(stashedChunk.id))).go();
    });
  }

  @override
  Stream<List<TimeChunkModel>> watchTimeChunksByPoi(String poiId) {
    final query = localDb.select(localDb.timeChunks)
      ..where((t) => t.poiId.equals(poiId) & t.isDeleted.equals(false));
    return query.watch().map((list) => list.map(_mapToDomain).toList());
  }

  @override
  Stream<List<TimeChunkModel>> watchTimeChunksByDate(String date) {
    final query = localDb.select(localDb.timeChunks)
      ..where((t) => t.date.equals(date) & t.isDeleted.equals(false));
    return query.watch().map((list) => list.map(_mapToDomain).toList());
  }

  @override
  Stream<List<TimeChunkModel>> watchBacklogChunks() {
    final query = localDb.select(localDb.timeChunks)
      ..where((t) => t.status.equals('backlog') & t.isDeleted.equals(false));
    return query.watch().map((list) => list.map(_mapToDomain).toList());
  }
}

@riverpod
TimeChunkRepository timeChunkRepository(TimeChunkRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  return LocalTimeChunkRepository(db);
}