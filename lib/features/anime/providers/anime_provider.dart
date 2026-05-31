import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/anime_repository.dart';
import '../models/anime_model.dart';
import '../../poi/models/poi_model.dart'; 

// --------------------------------------------------

final allAnimesProvider = StreamProvider<List<AnimeModel>>((ref) {
  return ref.watch(animeRepositoryProvider).watchAllAnimes();
});

final animeByIdProvider = StreamProvider.family<AnimeModel?, String>((ref, id) {
  return ref.watch(animeRepositoryProvider).watchAnimeById(id);
});

final animesForPoiProvider =
    StreamProvider.family<List<AnimeModel>, String>((ref, poiId) {
  return ref.watch(animeRepositoryProvider).watchAnimesForPoi(poiId);
});

final poisByAnimeProvider =
    StreamProvider.family<List<PoiModel>, String>((ref, animeId) {
  return ref.watch(animeRepositoryProvider).watchPoisByAnime(animeId);
});

final poiCountForAnimeProvider =
    StreamProvider.family<int, String>((ref, animeId) {
  return ref.watch(animeRepositoryProvider).watchPoiCountForAnime(animeId);
});