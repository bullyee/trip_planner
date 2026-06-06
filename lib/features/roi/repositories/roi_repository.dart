import 'package:drift/drift.dart'; 
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
}

class LocalRoiRepository implements RoiRepository {
  final AppDatabase localDb;
  
  LocalRoiRepository(this.localDb);

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
        createdAt: Value(roi.createdAt), // Extract directly from model
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
        createdAt: Value(roi.createdAt), // Extract directly from model
      ),
    );
  }

  @override
  Future<RoiModel> getRoiById(String id) async {
    // 1. Fetch the raw Drift entity
    final driftRoi = await localDb.getRoiById(id);
    
    // 2. Map it to the pure Domain Model
    return RoiModel(
      id: driftRoi.id,
      name: driftRoi.name,
      description: driftRoi.description,
      createdAt: driftRoi.createdAt, // Assumes Drift has this column
      isOfflineCached: driftRoi.isOfflineCached == 1,
      isShared: false, // Set default or map from Drift if you have a column for it
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
      );
    });
  }
}

@riverpod
RoiRepository roiRepository(RoiRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  return LocalRoiRepository(db);
}