import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

// IMPORTANT: Removed drift and direct database imports.
// Added the pure domain model and repository imports.
import '../models/tag_model.dart';
import '../repositories/tag_repository.dart';

part 'tag_controller.g.dart';

@riverpod
class TagController extends _$TagController {
  @override
  FutureOr<void> build() {}

  /// Handles business logic for saving a Tag.
  /// Delegates all database operations to the Repository layer.
  Future<bool> saveTag({
    required bool isNew,
    String? id,
    required String name,
    required String description,
    // Added for Dual-Track Sync architecture
    int? existingCreatedAt,
    bool isShared = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      String? nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

      // 1. Resolve ID and construct the pure Domain Model
      final tagId = isNew ? const Uuid().v4() : id!;

      final tagModel = TagModel(
        id: tagId,
        name: name.trim(),
        description: nullIfEmpty(description),
        // Preserve timestamp on edit, generate new one on creation
        createdAt: existingCreatedAt ?? DateTime.now().millisecondsSinceEpoch,
        isShared: isShared,
      );

      // 2. Delegate to the Repository Layer
      final repository = ref.read(tagRepositoryProvider);
      if (isNew) {
        await repository.addTag(tagModel);
      } else {
        await repository.updateTag(tagModel);
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}