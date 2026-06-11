import 'package:drift/drift.dart'; 
import '../../auth/providers/auth_provider.dart';
import '../models/roi_model.dart';
import '../../../core/database/database.dart'; 
import '../../../core/providers/database_provider.dart';
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
  
  LocalRoiRepository(this.localDb, this.currentUserId);

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
        isOfflineCached: Value(existingIsOfflineCached ?? 0),
        createdAt: Value(roi.createdAt),
        authorId: Value(roi.authorId), 
        isShared: Value(roi.isShared),
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
    return RoiModel(
      id: driftRoi.id,
      name: driftRoi.name,
      description: driftRoi.description,
      createdAt: driftRoi.createdAt, 
      isOfflineCached: driftRoi.isOfflineCached == 1,
      isShared: driftRoi.isShared,
      authorId: driftRoi.authorId,
    );
  }
  
  @override
  Future<void> deleteRoi(String id) async {
    await localDb.deleteRoi(id);
  }

  @override
  Stream<List<RoiModel>> watchAllRois() {
    return localDb.watchAllRois().map((rows) {
      return rows.map((row) => RoiModel(
        id: row.id,
        name: row.name,
        description: row.description,
        createdAt: row.createdAt, 
        isOfflineCached: row.isOfflineCached == 1,
        authorId: row.authorId,
        isShared: row.isShared,
      )).toList();
    });
  }

  @override
  Stream<RoiModel?> watchRoiById(String id) {
    return localDb.watchRoiById(id).map((row) {
      if (row == null) return null;
      return RoiModel(
        id: row.id,
        name: row.name,
        description: row.description,
        createdAt: row.createdAt,
        isOfflineCached: row.isOfflineCached == 1,
        authorId: row.authorId,
        isShared: row.isShared,
      );
    });
  }

  @override
  Future<void> enableCloudSyncForRoi(String roiId) async {
    await (localDb.update(localDb.rois)..where((r) => r.id.equals(roiId))).write(
      const RoisCompanion(
        isShared: Value(true),
      ),
    );
  }
}

@riverpod
RoiRepository roiRepository(RoiRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  final currentUserId = ref.watch(currentUserIdProvider);
  return LocalRoiRepository(db, currentUserId);
}