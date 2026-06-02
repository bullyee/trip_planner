import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../poi/services/anitabi_api_service.dart';
import '../models/anime_model.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';

abstract class AnimeRepository {
  Future<void> addAnime(AnimeModel anime);
  Future<void> updateAnime(AnimeModel anime);
  Future<AnimeModel?> getAnimeById(String id);
  Future<void> deleteAnime(String id);
  Future<AnitabiImportResult?> importFromAnitabi(String subjectId, String fallbackName);
  
  Stream<List<AnimeModel>> watchAllAnimes();
  Stream<AnimeModel?> watchAnimeById(String id);
  Stream<List<AnimeModel>> watchAnimesForPoi(String poiId); 
}

class LocalAnimeRepository implements AnimeRepository {
  final AppDatabase localDb;

  LocalAnimeRepository(this.localDb);

  @override
  Future<void> addAnime(AnimeModel anime) async {
    await localDb.insertAnime(
      AnimesCompanion.insert(
        id: anime.id,
        name: anime.name,
        description: Value(anime.description),
        bangumiId: Value(anime.bangumiId), // FIXED: Added missing bangumiId
        createdAt: Value(anime.createdAt), // FIXED: Wrapped in Value()
      ),
    );
    
  }

  @override
  Future<void> updateAnime(AnimeModel anime) async {
    await localDb.updateAnime(
      AnimesCompanion(
        id: Value(anime.id),
        name: Value(anime.name),
        description: Value(anime.description),
        bangumiId: Value(anime.bangumiId), // FIXED: Prevent silent data loss
        createdAt: Value(anime.createdAt), // FIXED: Preserve original timestamp
      ),
    );
    
  }

  @override
  Stream<List<AnimeModel>> watchAllAnimes() {
    return localDb.watchAllAnimes().map((rows) {
      return rows.map((row) => AnimeModel(
        id: row.id,
        name: row.name,
        description: row.description,
        bangumiId: row.bangumiId, // FIXED: Map bangumiId from DB
        createdAt: row.createdAt,
      )).toList();
    });
  }

  @override
  Stream<AnimeModel?> watchAnimeById(String id) {
    return localDb.watchAnimeById(id).map((row) {
      if (row == null) return null;
      return AnimeModel(
        id: row.id,
        name: row.name,
        description: row.description,
        bangumiId: row.bangumiId, // FIXED: Map bangumiId from DB
        createdAt: row.createdAt,
      );
    });
  }

  @override
  Stream<List<AnimeModel>> watchAnimesForPoi(String poiId) {
    return localDb.watchAnimesForPoi(poiId).map((rows) {
      return rows.map((row) => AnimeModel(
        id: row.id,
        name: row.name,
        description: row.description,
        bangumiId: row.bangumiId, // FIXED: Map bangumiId from DB
        createdAt: row.createdAt,
      )).toList();
    });
  }

  @override
  Future<AnimeModel?> getAnimeById(String id) async {
    final row = await localDb.getAnimeById(id);
    if (row == null) return null;
    return AnimeModel(
      id: row.id,
      name: row.name,
      description: row.description,
      bangumiId: row.bangumiId, // FIXED: Map bangumiId from DB
      createdAt: row.createdAt,
    );
  }

  @override
  Future<void> deleteAnime(String id) async {
    await localDb.deleteAnime(id);
  }

  @override
  Future<AnitabiImportResult?> importFromAnitabi(String subjectId, String fallbackName) async {
    return await AnitabiApiService.importBangumiSubject(
      localDb,
      subjectId,
      fallbackName: fallbackName,
    );
  }
}

final animeRepositoryProvider = Provider<AnimeRepository>((ref) {
  final db = ref.read(databaseProvider);
  return LocalAnimeRepository(db);
});