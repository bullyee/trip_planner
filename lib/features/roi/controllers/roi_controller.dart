import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../models/roi_model.dart';
import '../repositories/roi_repository.dart';

part 'roi_controller.g.dart';

@riverpod
class RoiController extends _$RoiController {
  @override
  FutureOr<void> build() {}

  Future<bool> updateRoi({
    required String id,
    required String name,
    required String description,
    required int createdAt, // 1. Require the original timestamp from UI
    required bool isShared, // 2. Require the original sync state from UI
    int? existingIsOfflineCached,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Helper function to handle empty strings
      String? nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

      // 1. Construct the pure domain model using the passed parameters
      final updatedRoi = RoiModel(
        id: id,
        name: name.trim(),
        createdAt: createdAt, // Preserve the timestamp
        description: nullIfEmpty(description),
        isShared: isShared,   // Preserve the sync state
      );

      // 2. Delegate the operation to the Repository layer.
      await ref.read(roiRepositoryProvider).updateRoi(
        updatedRoi,
        existingIsOfflineCached: existingIsOfflineCached
      );

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
  Future<bool> addRoi({
    required String name,
    required String description,
  }) async {
    state = const AsyncValue.loading();
    try {
      String? nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

      // 1. Construct the domain model and assign a new UUID here
      final newRoi = RoiModel(
        id: const Uuid().v4(), // Generate ID in the controller
        name: name.trim(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        description: nullIfEmpty(description),
        isShared: false,
      );

      // 2. Pass it to the repository
      await ref.read(roiRepositoryProvider).addRoi(newRoi);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}