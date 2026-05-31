// lib/features/roi/repositories/roi_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart'; 
import '../models/roi_model.dart';
import '../../../core/database/database.dart'; 
import '../../../core/providers/database_provider.dart';

abstract class RoiRepository {
  Future<void> updateRoi(
    RoiModel roi, {
    int? existingIsOfflineCached,
  });
  Future<void> addRoi(RoiModel roi);
  Future<void> deleteRoi(String id);

  Future<RoiModel> getRoiById(String id);
}

class DualTrackRoiRepository implements RoiRepository {
  final AppDatabase localDb;
  
  DualTrackRoiRepository(this.localDb);

  @override
  Future<void> updateRoi(
    RoiModel roi, {
    int? existingIsOfflineCached,
  }) async {
    if (roi.isShared) {
      // TODO: Route to Firestore SDK when implemented
    } else {
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
  }
  @override
  Future<void> addRoi(RoiModel roi) async {
    if (roi.isShared) {
      // TODO: Firestore logic
    } else {
      await localDb.insertRoi(
        RoisCompanion.insert(
          id: roi.id,
          name: roi.name,
          description: Value(roi.description),
          createdAt: roi.createdAt, // Extract directly from model
        ),
      );
    }
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
      isShared: false, // Set default or map from Drift if you have a column for it
    );
  }
  @override
  Future<void> deleteRoi(String id) async {
    // TODO: Firestore logic (if shared)
    await localDb.deleteRoi(id);
  }
}

final roiRepositoryProvider = Provider<RoiRepository>((ref) {
  // Inject the actual Drift database instance
  final db = ref.read(databaseProvider);
  return DualTrackRoiRepository(db);
});