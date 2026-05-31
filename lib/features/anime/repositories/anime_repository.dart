// lib/features/anime/repositories/anime_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../models/anime_model.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';

abstract class AnimeRepository {
  Future<void> addAnime(AnimeModel anime);
  Future<void> updateAnime(AnimeModel anime);
}

class DualTrackAnimeRepository implements AnimeRepository {
  final AppDatabase localDb;

  DualTrackAnimeRepository(this.localDb);

  @override
  Future<void> addAnime(AnimeModel anime) async {
    if (anime.isShared) {
      // TODO: Route to Firestore SDK when implemented
    } else {
      await localDb.insertAnime(
        AnimesCompanion.insert(
          id: anime.id,
          name: anime.name,
          description: Value(anime.description),
          createdAt: anime.createdAt, 
        ),
      );
    }
  }

  @override
  Future<void> updateAnime(AnimeModel anime) async {
    if (anime.isShared) {
      // TODO: Route to Firestore SDK when implemented
    } else {
      await localDb.updateAnime(
        AnimesCompanion(
          id: Value(anime.id),
          name: Value(anime.name),
          description: Value(anime.description),
          // createdAt is intentionally omitted here if your local DB 
          // doesn't update the creation time on edit.
        ),
      );
    }
  }
}

final animeRepositoryProvider = Provider<AnimeRepository>((ref) {
  final db = ref.read(databaseProvider);
  return DualTrackAnimeRepository(db);
});