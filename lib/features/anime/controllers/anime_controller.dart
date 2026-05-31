import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

// IMPORTANT: Removed drift and direct database imports.
// Added the pure domain model and repository imports.
import '../models/anime_model.dart';
import '../repositories/anime_repository.dart';

part 'anime_controller.g.dart';

@riverpod
class AnimeController extends _$AnimeController {
  @override
  FutureOr<void> build() {}

  /// Handles business logic for saving an Anime.
  /// Delegates all database operations to the Repository.
  Future<bool> saveAnime({
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
      final animeId = isNew ? const Uuid().v4() : id!;
      
      final animeModel = AnimeModel(
        id: animeId,
        name: name.trim(),
        description: nullIfEmpty(description),
        // Preserve timestamp on edit, generate new one on creation
        createdAt: existingCreatedAt ?? DateTime.now().millisecondsSinceEpoch,
        isShared: isShared,
      );

      // 2. Delegate to the Repository Layer
      final repository = ref.read(animeRepositoryProvider);
      if (isNew) {
        await repository.addAnime(animeModel);
      } else {
        await repository.updateAnime(animeModel);
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}