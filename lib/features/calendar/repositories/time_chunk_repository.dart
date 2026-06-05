// lib/features/calendar/repositories/time_chunk_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../models/time_chunk_model.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';

abstract class TimeChunkRepository {
  Future<void> addTimeChunk(TimeChunkModel chunk);
  Future<void> updateTimeChunk(TimeChunkModel chunk);
  Future<void> deleteTimeChunk(String id);
  Stream<List<TimeChunkModel>> watchTimeChunksByPoi(String poiId);
  Stream<List<TimeChunkModel>> watchTimeChunksByDate(String date);
  Stream<List<TimeChunkModel>> watchBacklogChunks();
}

class DualTrackTimeChunkRepository implements TimeChunkRepository {
  final AppDatabase localDb;

  DualTrackTimeChunkRepository(this.localDb);

  @override
  Future<void> addTimeChunk(TimeChunkModel chunk) async {
    if (chunk.isShared) {
      // TODO: Route to Firestore SDK
    } else {
      await localDb.insertTimeChunk(
        TimeChunksCompanion.insert(
          id: chunk.id,
          poiId: chunk.poiId,
          date: Value(chunk.date),
          startTime: Value(chunk.startTime),
          endTime: Value(chunk.endTime),
        ),
      );
    }
  }

  @override
  Stream<List<TimeChunkModel>> watchTimeChunksByPoi(String poiId) {
    final query = localDb.select(localDb.timeChunks)..where((t) => t.poiId.equals(poiId));
    return query.watch().map((list) {
      return list.map((chunk) => TimeChunkModel(
        id: chunk.id,
        poiId: chunk.poiId,
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
    // TODO: Firestore logic
    await localDb.updateTimeChunk(TimeChunksCompanion(
      id: Value(chunk.id),
      poiId: Value(chunk.poiId),
      date: Value(chunk.date),
      startTime: Value(chunk.startTime),
      endTime: Value(chunk.endTime),
      status: Value(chunk.status ?? 'backlog'),
    ));
  }

  @override
  Future<void> deleteTimeChunk(String id) async {
    // TODO: Firestore logic
    await localDb.deleteTimeChunk(id);
  }

  @override
  Stream<List<TimeChunkModel>> watchTimeChunksByDate(String date) {
    return localDb.watchTimeChunksByDate(date).map((list) {
      return list.map((chunk) => TimeChunkModel(
        id: chunk.id,
        poiId: chunk.poiId,
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

final timeChunkRepositoryProvider = Provider<TimeChunkRepository>((ref) {
  final db = ref.read(databaseProvider);
  return DualTrackTimeChunkRepository(db);
});