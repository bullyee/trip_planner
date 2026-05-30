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
    int? existingIsOfflineCached,
    int? existingCreatedAt,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Helper function to handle empty strings
      String? nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

      // 1. Construct the pure domain model.
      // Notice there are no Drift-specific 'Value' or 'RoisCompanion' classes here.
      final updatedRoi = RoiModel(
        id: id,
        name: name.trim(),
        description: nullIfEmpty(description),
        isShared: false, // Set to true later when handling cloud synchronization
      );

      // 2. Delegate the operation to the Repository layer.
      // The controller no longer reads 'databaseProvider' directly.
      await ref.read(roiRepositoryProvider).updateRoi(
        updatedRoi,
        existingIsOfflineCached: existingIsOfflineCached,
        existingCreatedAt: existingCreatedAt,
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