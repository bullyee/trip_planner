import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../poi/services/anitabi_api_service.dart';
import '../models/anime_model.dart';
import '../../poi/models/poi_model.dart'; 
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
  Stream<List<PoiModel>> watchPoisByAnime(String animeId);
  Stream<int> watchPoiCountForAnime(String animeId);
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
        ),
      );
    }
  }

  @override
  Stream<List<AnimeModel>> watchAllAnimes() {
    return localDb.watchAllAnimes().map((rows) {
      return rows.map((row) => AnimeModel(
        id: row.id,
        name: row.name,
        description: row.description,
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
        description: row.description, // 如果有這欄位記得補上
        createdAt: row.createdAt,
      )).toList();
    });
  }

  @override
  Stream<List<PoiModel>> watchPoisByAnime(String animeId) {
    return localDb.watchPoisByAnime(animeId).map((rows) {
      return rows.map((row) => PoiModel(
        id: row.id,
        roiId: row.roiId,
        name: row.name,
        description: row.description,
        address: row.address,
        lat: row.lat,
        lng: row.lng,
        businessHours: row.businessHours,
        contactInfo: row.contactInfo,
        coverImageUri: row.coverImageUri,
        // Ensure your Drift row contains a createdAt field, 
        // otherwise this will throw an error.
        createdAt: row.createdAt, 
        // Use default false if isShared is not persisted in the local DB yet, 
        // or map it directly if it exists: isShared: row.isShared ?? false,
      )).toList();
    });
  }

  @override
  Stream<int> watchPoiCountForAnime(String animeId) {
    // 假設底層 Drift 的 watchPoiCountForAnime 已經回傳 Stream<int>
    return localDb.watchPoiCountForAnime(animeId);
  }

  @override
  Future<AnimeModel?> getAnimeById(String id) async {
    final row = await localDb.getAnimeById(id);
    if (row == null) return null;
    return AnimeModel(
      id: row.id,
      name: row.name,
      description: row.description,
      createdAt: row.createdAt,
    );
  }

  @override
  Future<void> deleteAnime(String id) async {
    await localDb.deleteAnime(id);
  }

  @override
Future<AnitabiImportResult?> importFromAnitabi(String subjectId, String fallbackName) async {
  // Pass the String subjectId directly to the underlying service
  return await AnitabiApiService.importBangumiSubject(
    localDb,
    subjectId,
    fallbackName: fallbackName,
  );
}
}

final animeRepositoryProvider = Provider<AnimeRepository>((ref) {
  final db = ref.read(databaseProvider);
  return DualTrackAnimeRepository(db);
});