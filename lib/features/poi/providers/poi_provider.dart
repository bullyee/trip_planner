import 'package:flutter_riverpod/flutter_riverpod.dart';

// 引入乾淨的領域模型
import '../models/poi_model.dart';
import '../models/media_asset_model.dart';
import '../models/reference_image_model.dart';
import '../../calendar/models/time_chunk_model.dart';

// 引入防腐層
import '../repositories/poi_repository.dart';
import '../repositories/media_repository.dart';
import '../../calendar/repositories/time_chunk_repository.dart';

final poisByRoiProvider = StreamProvider.family<List<PoiModel>, String>((ref, roiId) {
  return ref.watch(poiRepositoryProvider).watchPoisByRoi(roiId);
});

final poisWithoutRoiProvider = StreamProvider<List<PoiModel>>((ref) {
  return ref.watch(poiRepositoryProvider).watchPoisWithoutRoi();
});

final poiByIdProvider = StreamProvider.family<PoiModel, String>((ref, id) {
  return ref.watch(poiRepositoryProvider).watchPoiById(id);
});

final mediaAssetsByPoiProvider = StreamProvider.family<List<MediaAssetModel>, String>((ref, poiId) {
  return ref.watch(mediaRepositoryProvider).watchMediaAssetsByPoi(poiId);
});

final referenceImagesByPoiProvider = StreamProvider.family<List<ReferenceImageModel>, String>((ref, poiId) {
  return ref.watch(mediaRepositoryProvider).watchReferenceImagesByPoi(poiId);
});

final timeChunksByPoiProvider = StreamProvider.family<List<TimeChunkModel>, String>((ref, poiId) {
  return ref.watch(timeChunkRepositoryProvider).watchTimeChunksByPoi(poiId);
});

final allPoisProvider = StreamProvider<Map<String, PoiModel>>((ref) {
  return ref.watch(poiRepositoryProvider).watchAllPois();
});

final poisByAnimeProvider =
    StreamProvider.family<List<PoiModel>, String>((ref, animeId) {
  return ref.watch(poiRepositoryProvider).watchPoisByAnime(animeId);
});

final poiCountForAnimeProvider =
    StreamProvider.family<int, String>((ref, animeId) {
  return ref.watch(poiRepositoryProvider).watchPoiCountForAnime(animeId);
});