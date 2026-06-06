import 'package:riverpod_annotation/riverpod_annotation.dart';

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