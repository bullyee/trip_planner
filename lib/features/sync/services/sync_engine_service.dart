import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show WriteBatch;
import 'package:uuid/uuid.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/tables.dart';
import 'firestore_sync_service.dart';

class SyncEngineService {
  final AppDatabase localDb;
  final FirestoreSyncService firestoreSync;
  final String currentUserId;

  StreamSubscription? _globalChunkSyncSub;
  StreamSubscription? _globalPoiSyncSub;
  StreamSubscription? _downstreamSub;
  Timer? _debounceTimer;
  final Set<String> _pendingRoiIdsToPush = <String>{};
  final Set<String> _inFlightSyncRois = <String>{};
  final Set<String> _locallyDeletedRoiIds = <String>{};

  void notifyRoiDeleted(String roiId) {
    _locallyDeletedRoiIds.add(roiId);
  }

  SyncEngineService({
    required this.localDb,
    required this.firestoreSync,
    required this.currentUserId,
  });

  void startSync() {
    debugPrint('[SyncEngine] Starting global bidirectional sync orchestrator...');

    // 1. Upstream Chunk Watcher: watches dirty TimeChunks in shared trips
    final chunkQuery = localDb.select(localDb.timeChunks).join([
      innerJoin(localDb.pois, localDb.pois.id.equalsExp(localDb.timeChunks.poiId)),
      innerJoin(localDb.rois, localDb.rois.id.equalsExp(localDb.pois.roiId)),
    ])
      ..where(localDb.timeChunks.syncStatus.equals(SyncStatus.dirty.index) &
              localDb.rois.isShared.equals(true));

    _globalChunkSyncSub = chunkQuery.watch().listen((rows) {
      if (rows.isEmpty) return;
      if (currentUserId.isEmpty || currentUserId == 'guest_local_user') return;

      final dirtyChunks = rows.map((row) => row.readTable(localDb.timeChunks)).toList();
      _scheduleDebouncedPush(dirtyChunks: dirtyChunks);
    });

    // 2. Upstream POI Watcher: watches dirty POIs in shared trips (#45)
    final poiQuery = localDb.select(localDb.pois).join([
      innerJoin(localDb.rois, localDb.rois.id.equalsExp(localDb.pois.roiId)),
    ])
      ..where(localDb.pois.syncStatus.equals(SyncStatus.dirty.index) &
              localDb.rois.isShared.equals(true));

    _globalPoiSyncSub = poiQuery.watch().listen((rows) {
      if (rows.isEmpty) return;
      if (currentUserId.isEmpty || currentUserId == 'guest_local_user') return;

      final dirtyPois = rows.map((row) => row.readTable(localDb.pois)).toList();
      _scheduleDebouncedPush(dirtyPois: dirtyPois);
    });

    // 3. Downstream Pull Listener: watches Firestore shared trips (#45)
    if (currentUserId.isNotEmpty && currentUserId != 'guest_local_user') {
      _downstreamSub = firestoreSync.watchUserTrips(currentUserId).listen((trips) async {
        for (final remoteTrip in trips) {
          final roiId = remoteTrip['id'] as String?;
          if (roiId == null || roiId.isEmpty) continue;
          if (_locallyDeletedRoiIds.contains(roiId)) continue;

          final remoteVersion = (remoteTrip['cloudVersion'] as num?)?.toInt() ?? 0;
          try {
            final localRoi = await (localDb.select(localDb.rois)
                  ..where((r) => r.id.equals(roiId)))
                .getSingleOrNull();

            if (localRoi == null) {
              // Remote trip newly shared with user — create local ROI and pull down
              await localDb.into(localDb.rois).insert(RoisCompanion(
                    id: Value(roiId),
                    name: Value(remoteTrip['name'] as String? ?? 'Shared Trip'),
                    authorId: Value(remoteTrip['authorId'] as String? ?? currentUserId),
                    isShared: const Value(true),
                    cloudVersion: const Value(0),
                  ));
              await executePull(roiId);
            } else if (localRoi.isShared && remoteVersion > localRoi.cloudVersion) {
              // Remote version bumped by collaborator — trigger downstream pull
              debugPrint('[SyncEngine] Remote version bump detected ($remoteVersion > ${localRoi.cloudVersion}) for trip $roiId. Pulling...');
              await executePull(roiId);
            }
          } catch (e) {
            debugPrint('[SyncEngine] Downstream sync error for trip $roiId: $e');
          }
        }
      });
    }
  }

  void stopSync() {
    debugPrint('[SyncEngine] Stopping global sync orchestrator...');
    _globalChunkSyncSub?.cancel();
    _globalPoiSyncSub?.cancel();
    _downstreamSub?.cancel();
    _debounceTimer?.cancel();
  }

  void _scheduleDebouncedPush({
    List<TimeChunk>? dirtyChunks,
    List<Poi>? dirtyPois,
  }) async {
    if (dirtyChunks != null && dirtyChunks.isNotEmpty) {
      final poiIds = dirtyChunks.map((c) => c.poiId).toSet().toList();
      final pois = await (localDb.select(localDb.pois)
            ..where((p) => p.id.isIn(poiIds)))
          .get();
      _pendingRoiIdsToPush.addAll(pois.map((p) => p.roiId).whereType<String>());
    }

    if (dirtyPois != null && dirtyPois.isNotEmpty) {
      _pendingRoiIdsToPush.addAll(dirtyPois.map((p) => p.roiId).whereType<String>());
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () async {
      final roisToPush = Set<String>.from(_pendingRoiIdsToPush);
      _pendingRoiIdsToPush.clear();

      for (final roiId in roisToPush) {
        try {
          final roi = await localDb.getRoiById(roiId);
          if (roi.isShared) {
            debugPrint('[SyncEngine] Auto-triggering push for SHARED Trip: $roiId');
            await executePush(roiId);
          }
        } catch (e) {
          debugPrint('[SyncEngine] Auto-push failed for trip $roiId: $e');
        }
      }
    });
  }

  Future<void> executePush(String roiId) async {
    if (_locallyDeletedRoiIds.contains(roiId)) return;
    if (_inFlightSyncRois.contains(roiId)) {
      debugPrint('[SyncEngine] Sync already in-flight for trip $roiId. Skipping push.');
      return;
    }
    _inFlightSyncRois.add(roiId);

    try {
      // Self-heal: if the cloud trip is missing (never initialized, or deleted
      // out-of-band), re-create it and re-arm this trip's local data for a full
      // re-push.
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

        // Bidirectional convergence: if remote is ahead, pull remote updates first
        // so local edits merge on top rather than clobbering remote changes (#45)
        if (cloudVersion > localVersion) {
          debugPrint('[SyncEngine] Local version ($localVersion) behind cloud ($cloudVersion). Merging downstream first...');
          await _internalPull(roiId);
        }

      final dirtyChunks = await _fetchDirtyRecords(roiId);
      final dirtyPois = await _fetchDirtyPois(roiId);

      final ops = <void Function(WriteBatch)>[
        for (final poi in dirtyPois)
          (b) => firestoreSync.buildPoiBatchOperations(b, poi, roiId),
        for (final chunk in dirtyChunks)
          (b) => firestoreSync.buildBatchOperations(b, chunk, roiId),
      ];

      if (ops.isEmpty) {
        await firestoreSync.releaseLock(roiId);
        return;
      }

      final currentVersion = await firestoreSync.fetchTripVersion(roiId);
      final nextVersion = currentVersion + 1;

      final batches = _splitIntoBatches(ops, 490);
      for (int i = 0; i < batches.length; i++) {
        final batch = firestoreSync.createBatch();
        for (final op in batches[i]) {
          op(batch);
        }
        if (i == batches.length - 1) {
          firestoreSync.appendVersionBumpAndLockRelease(batch, roiId, nextVersion);
        }
        await firestoreSync.commitBatch(batch);
      }

        await _postPushLocalCleanup(roiId, dirtyChunks, dirtyPois, nextVersion);
      } catch (e) {
        try {
          await firestoreSync.releaseLock(roiId);
        } catch (_) {}
        debugPrint('[SyncEngine] Push failed: $e');
        rethrow;
      }
    } finally {
      _inFlightSyncRois.remove(roiId);
    }
  }

  Future<void> executePull(String roiId) async {
    if (_locallyDeletedRoiIds.contains(roiId)) return;
    if (_inFlightSyncRois.contains(roiId)) {
      debugPrint('[SyncEngine] Sync already in-flight for trip $roiId. Skipping pull.');
      return;
    }
    _inFlightSyncRois.add(roiId);
    try {
      await _internalPull(roiId);
    } finally {
      _inFlightSyncRois.remove(roiId);
    }
  }

  Future<void> _internalPull(String roiId) async {
    try {
      final cloudVersion = await firestoreSync.fetchTripVersion(roiId);
      final roiRecord = await localDb.getRoiById(roiId);

      if (roiRecord.cloudVersion >= cloudVersion) return;

      final cloudData = await firestoreSync.fetchTripData(roiId);
      final cloudPois = await firestoreSync.fetchTripPois(roiId);

      await localDb.transaction(() async {
        // --- 1. Downstream POI Synchronization ---
        final remotePoiIds = cloudPois.map((p) => p['id'] as String).toSet();
        final localPois = await (localDb.select(localDb.pois)
              ..where((p) => p.roiId.equals(roiId)))
            .get();

        // Detect remote POI deletions (#45)
        for (final localPoi in localPois) {
          if (!remotePoiIds.contains(localPoi.id) && localPoi.hasEverSynced) {
            if (localPoi.syncStatus == SyncStatus.dirty.index) {
              // Local has unsynced edits: unassign from shared trip to preserve user effort
              await (localDb.update(localDb.pois)..where((p) => p.id.equals(localPoi.id))).write(
                const PoisCompanion(roiId: Value(null)),
              );
            } else {
              // Remote deletion of clean POI: hard-delete locally so it is completely removed without becoming dirty
              await localDb.hardDeletePoi(localPoi.id);
            }
          }
        }

        // Upsert remote POIs
        for (final remotePoi in cloudPois) {
          await _upsertCloudPoi(roiId, remotePoi);
        }

        // --- 2. Downstream TimeChunk Synchronization ---
        final remoteChunkIds = cloudData.map((c) => c['id'] as String).toSet();
        final currentPois = await (localDb.select(localDb.pois)
              ..where((p) => p.roiId.equals(roiId) & p.isDeleted.equals(false)))
            .get();
        final currentPoiIds = currentPois.map((p) => p.id).toSet();

        final localChunks = currentPoiIds.isEmpty
            ? <TimeChunk>[]
            : await (localDb.select(localDb.timeChunks)
                  ..where((t) => t.poiId.isIn(currentPoiIds)))
                .get();

        // Detect remote TimeChunk deletions (#45)
        for (final localChunk in localChunks) {
          if (!remoteChunkIds.contains(localChunk.id) && localChunk.hasEverSynced) {
            if (localChunk.syncStatus == SyncStatus.dirty.index) {
              await _stashLocalEffort(localChunk);
            } else {
              await (localDb.delete(localDb.timeChunks)..where((t) => t.id.equals(localChunk.id))).go();
            }
          }
        }

        // Upsert / update remote TimeChunks
        for (final remoteChunk in cloudData) {
          final chunkId = remoteChunk['id'] as String;
          final localChunk = await (localDb.select(localDb.timeChunks)
                ..where((t) => t.id.equals(chunkId)))
              .getSingleOrNull();

          if (localChunk == null) {
            await _insertCloudData(remoteChunk);
            continue;
          }

          final isLocalDirty = localChunk.syncStatus == SyncStatus.dirty.index;
          if (isLocalDirty) {
            await _stashLocalEffort(localChunk);
            await _insertCloudData(remoteChunk);
          } else {
            await _updateCloudData(remoteChunk);
          }
        }

        // --- 3. Update Local ROI Cloud Version ---
        await (localDb.update(localDb.rois)..where((r) => r.id.equals(roiId))).write(
          RoisCompanion(cloudVersion: Value(cloudVersion)),
        );
      });
    } catch (e) {
      debugPrint('[SyncEngine] Pull failed: $e');
      rethrow;
    }
  }

  /// Upserts a POI pulled from the cloud.
  /// Preserves device-local cover image path and does not overwrite local dirty edits.
  Future<void> _upsertCloudPoi(String roiId, Map<String, dynamic> data) async {
    final poiId = data['id'] as String;
    final existing = await (localDb.select(localDb.pois)
          ..where((p) => p.id.equals(poiId)))
        .getSingleOrNull();

    // If the local POI belongs to another trip, it was moved!
    // Clean up the obsolete cloud doc in this old trip and skip upserting locally.
    if (existing != null && existing.roiId != null && existing.roiId != roiId) {
      try {
        await firestoreSync.deletePoiFromTrip(roiId, poiId);
      } catch (e) {
        debugPrint('[SyncEngine] Error deleting moved POI from old trip: $e');
      }
      return;
    }

    // If local POI has unpushed edits, let local edits take precedence until pushed
    if (existing != null && existing.syncStatus == SyncStatus.dirty.index) {
      return;
    }

    await localDb.into(localDb.pois).insertOnConflictUpdate(PoisCompanion(
          id: Value(poiId),
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
          localCoverImagePath: existing != null ? Value(existing.localCoverImagePath) : const Value(null),
          sortOrder: Value((data['sortOrder'] as num?)?.toInt() ?? 0),
          isShared: const Value(true),
          hasEverSynced: const Value(true),
          syncStatus: Value(SyncStatus.synced.index),
          isDeleted: const Value(false),
        ));
  }

  /// Re-arms a trip for a full re-upload after its cloud doc was recreated.
  Future<void> _resetRoiForFullResync(String roiId) async {
    await localDb.transaction(() async {
      await (localDb.update(localDb.rois)..where((r) => r.id.equals(roiId)))
          .write(const RoisCompanion(cloudVersion: Value(0)));

      await (localDb.update(localDb.pois)
            ..where((p) => p.roiId.equals(roiId) & p.isDeleted.equals(false)))
          .write(PoisCompanion(syncStatus: Value(SyncStatus.dirty.index)));

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

  Future<List<Poi>> _fetchDirtyPois(String roiId) async {
    return await (localDb.select(localDb.pois)
          ..where((p) => p.roiId.equals(roiId) & p.syncStatus.equals(SyncStatus.dirty.index)))
        .get();
  }

  Future<void> _postPushLocalCleanup(
    String roiId,
    List<TimeChunk> pushedChunks,
    List<Poi> pushedPois,
    int newVersion,
  ) async {
    await localDb.transaction(() async {
      // 1. Process pushed time chunks first to avoid FK constraint violations
      for (final chunk in pushedChunks) {
        if (chunk.isDeleted) {
          await (localDb.delete(localDb.timeChunks)..where((t) => t.id.equals(chunk.id))).go();
        } else {
          final query = localDb.update(localDb.timeChunks)
            ..where((t) {
              final idMatch = t.id.equals(chunk.id);
              final timeMatch = chunk.lastModifiedAt == null
                  ? t.lastModifiedAt.isNull()
                  : t.lastModifiedAt.equals(chunk.lastModifiedAt!);
              return idMatch & timeMatch;
            });
          await query.write(
            TimeChunksCompanion(
              syncStatus: Value(SyncStatus.synced.index),
              hasEverSynced: const Value(true),
            ),
          );
        }
      }

      // 2. Process pushed POIs second (cascades remaining child records if deleted)
      for (final poi in pushedPois) {
        if (poi.isDeleted) {
          await localDb.hardDeletePoi(poi.id);
        } else {
          final query = localDb.update(localDb.pois)
            ..where((p) {
              final idMatch = p.id.equals(poi.id);
              final timeMatch = poi.lastModifiedAt == null
                  ? p.lastModifiedAt.isNull()
                  : p.lastModifiedAt.equals(poi.lastModifiedAt!);
              return idMatch & timeMatch;
            });
          await query.write(
            PoisCompanion(
              syncStatus: Value(SyncStatus.synced.index),
              hasEverSynced: const Value(true),
              isShared: const Value(true),
            ),
          );
        }
      }

      // 3. Update local ROI cloudVersion
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
