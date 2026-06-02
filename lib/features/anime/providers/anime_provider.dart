import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/anime_model.dart';
import '../repositories/anime_repository.dart';

part 'anime_provider.g.dart';

@riverpod
Stream<List<AnimeModel>> allAnimes(AllAnimesRef ref) {
  return ref.watch(animeRepositoryProvider).watchAllAnimes();
}

@riverpod
Stream<AnimeModel?> animeById(AnimeByIdRef ref, String id) {
  return ref.watch(animeRepositoryProvider).watchAnimeById(id);
}

@riverpod
Stream<List<AnimeModel>> animesForPoi(AnimesForPoiRef ref, String poiId) {
  return ref.watch(animeRepositoryProvider).watchAnimesForPoi(poiId);
}