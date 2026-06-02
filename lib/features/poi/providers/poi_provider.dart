import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/poi_model.dart';

import '../repositories/poi_repository.dart';

// Required for code generation
part 'poi_provider.g.dart';

@riverpod
Stream<List<PoiModel>> poisByRoi(PoisByRoiRef ref, String roiId) {
  return ref.watch(poiRepositoryProvider).watchPoisByRoi(roiId);
}

@riverpod
Stream<List<PoiModel>> poisWithoutRoi(PoisWithoutRoiRef ref) {
  return ref.watch(poiRepositoryProvider).watchPoisWithoutRoi();
}

@riverpod
Stream<PoiModel> poiById(PoiByIdRef ref, String id) {
  return ref.watch(poiRepositoryProvider).watchPoiById(id);
}

@riverpod
Stream<Map<String, PoiModel>> allPois(AllPoisRef ref) {
  return ref.watch(poiRepositoryProvider).watchAllPois();
}

@riverpod
Stream<List<PoiModel>> poisByAnime(PoisByAnimeRef ref, String animeId) {
  return ref.watch(poiRepositoryProvider).watchPoisByAnime(animeId);
}

@riverpod
Stream<int> poiCountForAnime(PoiCountForAnimeRef ref, String animeId) {
  return ref.watch(poiRepositoryProvider).watchPoiCountForAnime(animeId);
}