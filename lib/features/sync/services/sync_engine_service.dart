import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show WriteBatch;
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../../core/providers/database_provider.dart';
import '../providers/firestore_sync_provider.dart';
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
    // Self-heal: if the cloud trip is missing (never initialized, or deleted
    // out-of-band), re-create it and re-arm this trip's local data for a full
    // re-push. Without this, a deleted trip can never be re-uploaded because
    // the chunks are already marked 'synced' and acquireLock fails on a doc
    // that no longer exists.
    if (!await firestoreSync.tripExists(roiId)) {
      final roi = await localDb.getRoiById(roiId);
      await firestoreSync.initializeCloudTrip(roiId, currentUserId, roi.name);
      await _resetRoiForFullResync(roiId);
    }

    final lockAcquired = await firestoreSync.acquireLock(roiId, currentUserId);
    if (!lockAcquired) throw Exception('Resource locked.');

    try {
      final cloudVersion = await firestoreSync.fetchTripVersion(roiId);
      final roiRecord = await localDb.getRoiById(roiId);
      final localVersion = roiRecord.cloudVersion;

      if (cloudVersion > localVersion) throw Exception('Local version obsolete.');

      final dirtyData = await _fetchDirtyRecords(roiId);
      final pois = await localDb.getPoisByRoi(roiId);

      // Combined op list: full POI snapshot + dirty time-chunk ops, split into
      // Firestore-batch-sized groups. Only the final batch bumps the version
      // and releases the lock so the whole push commits atomically per batch.
      final ops = <void Function(WriteBatch)>[
        for (final poi in pois)
          (b) => firestoreSync.buildPoiBatchOperations(b, poi, roiId),
        for (final chunk in dirtyData)
          (b) => firestoreSync.buildBatchOperations(b, chunk, roiId),
      ];

      if (ops.isEmpty) {
        await firestoreSync.releaseLock(roiId);
        return;
      }

      final batches = _splitIntoBatches(ops, 490);
      for (int i = 0; i < batches.length; i++) {
        final batch = firestoreSync.createBatch();
        for (final op in batches[i]) {
          op(batch);
        }
        if (i == batches.length - 1) {
          firestoreSync.appendVersionBumpAndLockRelease(batch, roiId, cloudVersion + 1);
        }
        await firestoreSync.commitBatch(batch);
      }

      await _postPushLocalCleanup(roiId, dirtyData, cloudVersion + 1);
    } catch (e) {
      // We bailed before the final batch released the lock server-side, so the
      // lock would otherwise linger until its TTL expires. Best-effort release
      // (don't let a release failure mask the original error).
      try {
        await firestoreSync.releaseLock(roiId);
      } catch (_) {}
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
      final cloudPois = await firestoreSync.fetchTripPois(roiId);

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
        for (final remotePoi in cloudPois) {
          await _upsertCloudPoi(roiId, remotePoi);
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

  /// Upserts a POI pulled from the cloud. `localCoverImagePath`/`createdAt` are
  /// left absent so a local-only cover path and original timestamp survive.
  Future<void> _upsertCloudPoi(String roiId, Map<String, dynamic> data) async {
    await localDb.into(localDb.pois).insertOnConflictUpdate(PoisCompanion(
          id: Value(data['id'] as String),
          roiId: Value(roiId),
          authorId: Value(data['authorId'] as String? ?? currentUserId),
          name: Value(data['name'] as String? ?? 'Unnamed'),
          description: Value(data['description'] as String?),
          address: Value(data['address'] as String?),
          lat: Value((data['lat'] as num?)?.toDouble() ?? 0),
          lng: Value((data['lng'] as num?)?.toDouble() ?? 0),
          businessHours: Value(data['businessHours'] as String?),
          contactInfo: Value(data['contactInfo'] as String?),
          remoteCoverImageUrl: Value(data['remoteCoverImageUrl'] as String?),
          sortOrder: Value((data['sortOrder'] as num?)?.toInt() ?? 0),
          isShared: const Value(true),
        ));
  }

  /// Re-arms a trip for a full re-upload after its cloud doc was recreated:
  /// reset the local version to 0 and mark every live chunk dirty so the next
  /// push re-sends them (POIs are always snapshot-pushed, so they need no flag).
  Future<void> _resetRoiForFullResync(String roiId) async {
    await localDb.transaction(() async {
      await (localDb.update(localDb.rois)..where((r) => r.id.equals(roiId)))
          .write(const RoisCompanion(cloudVersion: Value(0)));

      final poiIds = (await localDb.getPoisByRoi(roiId)).map((p) => p.id).toList();
      if (poiIds.isEmpty) return;
      await (localDb.update(localDb.timeChunks)
            ..where((t) => t.poiId.isIn(poiIds) & t.isDeleted.equals(false)))
          .write(TimeChunksCompanion(syncStatus: Value(SyncStatus.dirty.index)));
    });
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