import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../models/anime_model.dart';
import '../repositories/anime_repository.dart';
import '../../../core/utils/app_result.dart'; // Added AppResult import

part 'anime_controller.g.dart';

@Riverpod(keepAlive: true)
class AnimeController extends _$AnimeController {
  @override
  FutureOr<void> build() {}

  Future<AppResult<void>> saveAnime({
    required bool isNew,
    String? id,
    required String name,
    required String description,
    int? existingCreatedAt,
  }) async {
    state = const AsyncValue.loading();
    try {
      String? nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

      final animeId = isNew ? const Uuid().v4() : id!;
      
      final animeModel = AnimeModel(
        id: animeId,
        name: name.trim(),
        description: nullIfEmpty(description),
        createdAt: existingCreatedAt ?? DateTime.now().millisecondsSinceEpoch,
        isShared: false, // Explicitly set to false since we removed dual-track
      );

      // Delegate to the pure local repository
      final repository = ref.read(animeRepositoryProvider);
      if (isNew) {
        await repository.addAnime(animeModel);
      } else {
        await repository.updateAnime(animeModel);
      }

      state = const AsyncValue.data(null);
      return const Success(null); // Explicit success
      
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // Return explicit failure so UI can show a Snackbar with the exact error
      return Failure(e.toString(), st); 
    }
  }
}