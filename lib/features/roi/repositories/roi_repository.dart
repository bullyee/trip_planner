// lib/features/roi/repositories/roi_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/roi_model.dart';
// import 'package:trip_planner/core/database/database.dart'; // Import your actual Drift DB here

abstract class RoiRepository {
  // MUST declare the method signature here so the Controller can see it
  Future<void> updateRoi(
    RoiModel roi, {
    int? existingIsOfflineCached,
    int? existingCreatedAt,
  });
  Future<void> addRoi(RoiModel roi);
  
  // Future<List<RoiModel>> getRois();
  // Future<void> addRoi(RoiModel roi);
}

class DualTrackRoiRepository implements RoiRepository {
  // final AppDatabase localDb;
  // DualTrackRoiRepository(this.localDb);

  @override
  Future<void> updateRoi(
    RoiModel roi, {
    int? existingIsOfflineCached,
    int? existingCreatedAt,
  }) async {
    if (roi.isShared) {
      // TODO: Route to Firestore SDK when implemented
      // await cloudDb.collection('trips').doc(roi.id).update({...});
    } else {
      // Route to local Drift SQLite.
      // Notice how the Drift-specific 'Value' wrapper is strictly confined to this layer.
      /*
      await localDb.updateRoi(
        RoisCompanion(
          id: Value(roi.id),
          name: Value(roi.name),
          description: Value(roi.description),
          isOfflineCached: Value(existingIsOfflineCached ?? 0),
          createdAt: Value(existingCreatedAt ?? DateTime.now().millisecondsSinceEpoch),
        ),
      );
      */
    }
  }

  @override
  Future<void> addRoi(RoiModel roi) async {
    if (roi.isShared) {
      // TODO: Firestore logic
      // await cloudDb.collection('trips').doc(roi.id).set({...});
    } else {
      // Local Drift logic handling the 'Value' wrappers
      /*
      await localDb.insertRoi(
        RoisCompanion.insert(
          id: roi.id,
          name: roi.name,
          description: Value(roi.description),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      */
    }
  }
}

final roiRepositoryProvider = Provider<RoiRepository>((ref) {
  // return DualTrackRoiRepository(ref.read(databaseProvider));
  throw UnimplementedError('Initialize with your actual Drift database instance');
});