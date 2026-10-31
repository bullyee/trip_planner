import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../sync/services/firestore_sync_service.dart';
import '../../sync/providers/firestore_sync_provider.dart';
import 'package:drift/drift.dart'; 
import '../../auth/providers/auth_provider.dart';
import '../models/roi_model.dart';
import '../../../core/database/database.dart'; 
import '../../../core/providers/database_provider.dart';
import '../../../core/providers/sync_provider.dart';
import '../../sync/services/sync_engine_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'roi_repository.g.dart';

abstract class RoiRepository {
  Future<void> updateRoi(
    RoiModel roi, {
    int? existingIsOfflineCached,
  });
  Future<void> addRoi(RoiModel roi);
  Future<void> deleteRoi(String id);

  Future<RoiModel> getRoiById(String id);
  Stream<List<RoiModel>> watchAllRois();
  Stream<RoiModel?> watchRoiById(String id);
  
  // ADDED: 開啟特定行程的雲端同步狀態
  Future<void> enableCloudSyncForRoi(String roiId);
}

class LocalRoiRepository implements RoiRepository {
  final AppDatabase localDb;
  final String currentUserId;
  final FirestoreSyncService? firestoreSync;
  final SyncEngineService? syncEngine;
  
  LocalRoiRepository(this.localDb, this.currentUserId, {this.firestoreSync, this.syncEngine});

  RoiModel _mapRoi(Roi row) {
    return RoiModel(
      id: row.id,
      name: row.name,
      description: row.description,
      createdAt: row.createdAt,
      isOfflineCached: row.isOfflineCached == 1,
      authorId: row.authorId,
      isShared: row.isShared,
      cloudVersion: row.cloudVersion,
      syncLockExpiresAt: row.syncLockExpiresAt,
    );
  }

  @override
  Future<void> updateRoi(
    RoiModel roi, {
    int? existingIsOfflineCached,
  }) async {
    await localDb.updateRoi(
      RoisCompanion(
        id: Value(roi.id),
        name: Value(roi.name),
        description: Value(roi.description),
        isOfflineCached: Value(existingIsOfflineCached ?? (roi.isOfflineCached ? 1 : 0)),
        createdAt: Value(roi.createdAt),
        authorId: Value(roi.authorId), 
        isShared: Value(roi.isShared),
        cloudVersion: Value(roi.cloudVersion),
        syncLockExpiresAt: Value(roi.syncLockExpiresAt),
      ),
    );
  }

  @override
  Future<void> addRoi(RoiModel roi) async {
    await localDb.insertRoi(
      RoisCompanion.insert(
        id: roi.id,
        name: roi.name,
        description: Value(roi.description),
        createdAt: Value(roi.createdAt), 
        authorId: currentUserId,
        isShared: const Value(false),
      ),
    );
  }

  @override
  Future<RoiModel> getRoiById(String id) async {
    final driftRoi = await localDb.getRoiById(id);
    return _mapRoi(driftRoi);
  }
  
  @override
  Future<void> deleteRoi(String id) async {
    syncEngine?.notifyRoiDeleted(id);
    final roi = await (localDb.select(localDb.rois)..where((r) => r.id.equals(id))).getSingleOrNull();
    final shouldLeaveCloud = roi != null && roi.isShared && firestoreSync != null && currentUserId.isNotEmpty && currentUserId != 'guest_local_user';
    await localDb.deleteRoi(id);
    if (shouldLeaveCloud) {
      unawaited(firestoreSync!.leaveOrDeleteCloudTrip(id, currentUserId).catchError((Object e) {
        debugPrint('[LocalRoiRepository] Error leaving cloud trip: $e');
      }));
    }
  }

  @override
  Stream<List<RoiModel>> watchAllRois() {
    return localDb.watchAllRois().map((rows) => rows.map(_mapRoi).toList());
  }

  @override
  Stream<RoiModel?> watchRoiById(String id) {
    return localDb.watchRoiById(id).map((row) => row == null ? null : _mapRoi(row));
  }

  @override
  Future<void> enableCloudSyncForRoi(String roiId) async {
    await localDb.transaction(() async {
      await (localDb.update(localDb.rois)..where((r) => r.id.equals(roiId))).write(
        const RoisCompanion(
          isShared: Value(true),
        ),
      );
      await (localDb.update(localDb.pois)..where((p) => p.roiId.equals(roiId) & p.isDeleted.equals(false))).write(
        const PoisCompanion(
          syncStatus: Value(1), // SyncStatus.dirty
        ),
      );
      final poiIds = (await localDb.getPoisByRoi(roiId)).map((p) => p.id).toList();
      if (poiIds.isNotEmpty) {
        await (localDb.update(localDb.timeChunks)..where((t) => t.poiId.isIn(poiIds) & t.isDeleted.equals(false))).write(
          const TimeChunksCompanion(
            syncStatus: Value(1), // SyncStatus.dirty
          ),
        );
      }
    });
  }
}

@riverpod
RoiRepository roiRepository(RoiRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  final currentUserId = ref.watch(currentUserIdProvider);
  final firestoreSync = ref.watch(firestoreSyncServiceProvider);
  final syncEngine = ref.watch(syncEngineProvider);
  return LocalRoiRepository(db, currentUserId, firestoreSync: firestoreSync, syncEngine: syncEngine);
}
