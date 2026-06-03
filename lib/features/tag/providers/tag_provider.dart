import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../poi/models/poi_model.dart';
import '../models/tag_model.dart';
import '../repositories/tag_repository.dart';

part 'tag_provider.g.dart';

@riverpod
Stream<List<TagModel>> allTags(AllTagsRef ref) {
  return ref.watch(tagRepositoryProvider).watchAllTags();
}

@riverpod
Stream<TagModel?> tagById(TagByIdRef ref, String id) {
  return ref.watch(tagRepositoryProvider).watchTagById(id);
}

@riverpod
Stream<List<TagModel>> tagsForPoi(TagsForPoiRef ref, String poiId) {
  return ref.watch(tagRepositoryProvider).watchTagsForPoi(poiId);
}

// TODO (Tech Debt): These two providers return POI data and should ideally 
// be refactored into the POI domain (poi_provider.dart) in the future.
@riverpod
Stream<List<PoiModel>> poisByTag(PoisByTagRef ref, String tagId) {
  return ref.watch(tagRepositoryProvider).watchPoisByTag(tagId);
}

@riverpod
Stream<int> poiCountForTag(PoiCountForTagRef ref, String tagId) {
  return ref.watch(tagRepositoryProvider).watchPoiCountForTag(tagId);
}