import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart'; 
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';
import 'firestore_sync_service.dart';

class SyncEngineService {
  final AppDatabase localDb;
  final FirestoreSyncService firestoreSync;
  final String currentUserId;

  StreamSubscription? _globalSyncSub;
  Timer? _debounceTimer;

  SyncEngineService({
    required this.localDb,
    required this.firestoreSync,
    required this.currentUserId,
  });

  void startSync() {
    debugPrint('[SyncEngine] Starting global background sync orchestrator...');
    
    final query = localDb.select(localDb.timeChunks).join([
      innerJoin(localDb.pois, localDb.pois.id.equalsExp(localDb.timeChunks.poiId)),
      innerJoin(localDb.rois, localDb.rois.id.equalsExp(localDb.pois.roiId)),
    ])
      ..where(localDb.timeChunks.syncStatus.equals(SyncStatus.dirty.index) & 
              localDb.rois.isShared.equals(true));

    _globalSyncSub = query.watch().listen((rows) {
      if (rows.isEmpty) return;

      if (currentUserId.isEmpty || currentUserId == 'guest_local_user') {
        return;
      }

      final dirtyChunks = rows.map((row) => row.readTable(localDb.timeChunks)).toList();

      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(seconds: 2), () async {
        await _processGlobalDirtyChunks(dirtyChunks);
      });
    });
  }

  void stopSync() {
    debugPrint('[SyncEngine] Stopping global sync orchestrator...');
    _globalSyncSub?.cancel();
    _debounceTimer?.cancel();
  }

  Future<void> _processGlobalDirtyChunks(List<TimeChunk> dirtyChunks) async {
    try {
      final poiIds = dirtyChunks.map((c) => c.poiId).toSet().toList();
      if (poiIds.isEmpty) return;

      final affectedPois = await (localDb.select(localDb.pois)
        ..where((p) => p.id.isIn(poiIds))).get();
      
      final affectedRoiIds = affectedPois
          .map((p) => p.roiId)
          .whereType<String>()
          .toSet();

      for (final roiId in affectedRoiIds) {
        final roi = await localDb.getRoiById(roiId);
        if (roi.isShared) {
          debugPrint('[SyncEngine] Auto-triggering push for SHARED Trip: $roiId');
          await executePush(roiId);
        }
      }
    } catch (e) {
      debugPrint('[SyncEngine] Auto-push failed: $e');
    }
  }

  Future<void> executePush(String roiId) async {
    final lockAcquired = await firestoreSync.acquireLock(roiId, currentUserId);
    if (!lockAcquired) throw Exception('Resource locked.');

    try {
      final cloudVersion = await firestoreSync.fetchTripVersion(roiId);
      final roiRecord = await localDb.getRoiById(roiId);
      final localVersion = roiRecord.cloudVersion;
      
      if (cloudVersion > localVersion) throw Exception('Local version obsolete.');

      final dirtyData = await _fetchDirtyRecords(roiId);
      if (dirtyData.isEmpty) {
        await firestoreSync.releaseLock(roiId);
        return;
      }

      final chunks = _splitIntoBatches(dirtyData, 490);
      for (int i = 0; i < chunks.length; i++) {
        final batch = firestoreSync.createBatch();
        for (final item in chunks[i]) {
          firestoreSync.buildBatchOperations(batch, item, roiId);
        }
        if (i == chunks.length - 1) {
          firestoreSync.appendVersionBumpAndLockRelease(batch, roiId, cloudVersion + 1);
        }
        await firestoreSync.commitBatch(batch);
      }

      await _postPushLocalCleanup(roiId, dirtyData, cloudVersion + 1);
    } catch (e) {
      debugPrint('[SyncEngine] Push failed: $e');
      rethrow;
    }
  }

  Future<void> executePull(String roiId) async {
    try {
      final cloudVersion = await firestoreSync.fetchTripVersion(roiId);
      final roiRecord = await localDb.getRoiById(roiId);
      
      if (roiRecord.cloudVersion == cloudVersion) return;

      final cloudData = await firestoreSync.fetchTripData(roiId);
      
      await localDb.transaction(() async {
        for (final remoteChunk in cloudData) {
          final chunkId = remoteChunk['id'] as String;
          final isRemoteDeleted = remoteChunk['isDeleted'] as bool? ?? false;
          
          final localChunk = await (localDb.select(localDb.timeChunks)
            ..where((t) => t.id.equals(chunkId))).getSingleOrNull();

          if (localChunk == null) {
            if (!isRemoteDeleted) await _insertCloudData(remoteChunk);
            continue;
          }

          final isLocalDirty = localChunk.syncStatus == SyncStatus.dirty.index;

          if (isRemoteDeleted) {
            if (isLocalDirty) {
              await _stashLocalEffort(localChunk);
            } else {
              await (localDb.delete(localDb.timeChunks)..where((t) => t.id.equals(chunkId))).go();
            }
          } else {
            if (isLocalDirty) {
              await _stashLocalEffort(localChunk);
              await _insertCloudData(remoteChunk);
            } else {
              await _updateCloudData(remoteChunk);
            }
          }
        }
        await (localDb.update(localDb.rois)..where((r) => r.id.equals(roiId))).write(
          RoisCompanion(cloudVersion: Value(cloudVersion)),
        );
      });
    } catch (e) {
      debugPrint('[SyncEngine] Pull failed: $e');
      rethrow;
    }
  }

  List<List<T>> _splitIntoBatches<T>(List<T> list, int batchSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += batchSize) {
      int end = (i + batchSize < list.length) ? i + batchSize : list.length;
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }

  Future<List<TimeChunk>> _fetchDirtyRecords(String roiId) async {
    return await (localDb.select(localDb.timeChunks).join([
      innerJoin(localDb.pois, localDb.pois.id.equalsExp(localDb.timeChunks.poiId))
    ])
      ..where(localDb.pois.roiId.equals(roiId) & 
              localDb.timeChunks.syncStatus.equals(SyncStatus.dirty.index)))
        .map((row) => row.readTable(localDb.timeChunks))
        .get();
  }

  Future<void> _postPushLocalCleanup(String roiId, List<TimeChunk> pushedData, int newVersion) async {
    await localDb.transaction(() async {
      for (final chunk in pushedData) {
        if (chunk.isDeleted) {
          await (localDb.delete(localDb.timeChunks)..where((t) => t.id.equals(chunk.id))).go();
        } else {
          await (localDb.update(localDb.timeChunks)..where((t) => t.id.equals(chunk.id))).write(
            TimeChunksCompanion(
              syncStatus: Value(SyncStatus.synced.index),
              hasEverSynced: const Value(true),
            ),
          );
        }
      }
      await (localDb.update(localDb.rois)..where((r) => r.id.equals(roiId))).write(
        RoisCompanion(cloudVersion: Value(newVersion)),
      );
    });
  }

  Future<void> _stashLocalEffort(TimeChunk localData) async {
    final stashedId = const Uuid().v4();
    final companion = TimeChunksCompanion(
      id: Value(stashedId),
      poiId: Value(localData.poiId),
      date: Value(localData.date),
      originalStartTime: Value(localData.startTime),
      originalEndTime: Value(localData.endTime),
      startTime: const Value(null),
      endTime: const Value(null),
      status: const Value('backlog'),
      syncStatus: Value(SyncStatus.stashed.index),
      isDeleted: const Value(false),
      hasEverSynced: const Value(false),
      authorId: Value(localData.authorId),
    );

    await localDb.into(localDb.timeChunks).insert(companion);
    await (localDb.delete(localDb.timeChunks)..where((t) => t.id.equals(localData.id))).go();
  }

  Future<void> _insertCloudData(Map<String, dynamic> data) async {
    final companion = TimeChunksCompanion(
      id: Value(data['id']),
      poiId: Value(data['poiId']),
      date: Value(data['date']),
      startTime: Value(data['startTime']),
      endTime: Value(data['endTime']),
      status: Value(data['status']),
      sortOrder: Value(data['sortOrder'] ?? 0),
      duration: Value(data['duration'] ?? 60),
      transitDuration: Value(data['transitDuration'] ?? 0),
      isFixedTime: Value(data['isFixedTime'] ?? false),
      syncStatus: Value(SyncStatus.synced.index),
      isDeleted: const Value(false),
      hasEverSynced: const Value(true),
      authorId: Value(data['authorId'] ?? currentUserId),
    );
    await localDb.into(localDb.timeChunks).insert(companion);
  }

  Future<void> _updateCloudData(Map<String, dynamic> data) async {
    final companion = TimeChunksCompanion(
      syncStatus: Value(SyncStatus.synced.index),
      date: Value(data['date']),
      startTime: Value(data['startTime']),
      endTime: Value(data['endTime']),
      status: Value(data['status']),
      sortOrder: Value(data['sortOrder'] ?? 0),
      duration: Value(data['duration'] ?? 60),
      transitDuration: Value(data['transitDuration'] ?? 0),
      isFixedTime: Value(data['isFixedTime'] ?? false),
    );
    await (localDb.update(localDb.timeChunks)..where((t) => t.id.equals(data['id']))).write(companion);
  }
}

final syncEngineProvider = Provider<SyncEngineService>((ref) {
  return SyncEngineService(
    localDb: ref.watch(databaseProvider),
    firestoreSync: ref.watch(firestoreSyncServiceProvider),
    currentUserId: ref.watch(currentUserIdProvider),
  );
});