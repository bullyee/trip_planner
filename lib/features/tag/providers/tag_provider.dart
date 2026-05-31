import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../poi/models/poi_model.dart';
import '../models/tag_model.dart';
import '../repositories/tag_repository.dart';

final allTagsProvider = StreamProvider<List<TagModel>>((ref) {
  return ref.watch(tagRepositoryProvider).watchAllTags();
});

final tagByIdProvider = StreamProvider.family<TagModel?, String>((ref, id) {
  return ref.watch(tagRepositoryProvider).watchTagById(id);
});

final tagsForPoiProvider =
    StreamProvider.family<List<TagModel>, String>((ref, poiId) {
  return ref.watch(tagRepositoryProvider).watchTagsForPoi(poiId);
});

final poisByTagProvider =
    StreamProvider.family<List<PoiModel>, String>((ref, tagId) {
  return ref.watch(tagRepositoryProvider).watchPoisByTag(tagId);
});

final poiCountForTagProvider =
    StreamProvider.family<int, String>((ref, tagId) {
  return ref.watch(tagRepositoryProvider).watchPoiCountForTag(tagId);
});
