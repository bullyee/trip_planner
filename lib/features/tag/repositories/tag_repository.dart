import 'package:drift/drift.dart';

import '../../poi/models/poi_model.dart';
import '../models/tag_model.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tag_repository.g.dart';

abstract class TagRepository {
  Future<void> addTag(TagModel tag);
  Future<void> updateTag(TagModel tag);
  Future<TagModel?> getTagById(String id);
  Future<void> deleteTag(String id);

  Stream<List<TagModel>> watchTagsForPoi(String poiId);
  Stream<List<TagModel>> watchAllTags();
  Stream<TagModel?> watchTagById(String id);
  Stream<List<PoiModel>> watchPoisByTag(String tagId);
  Stream<int> watchPoiCountForTag(String tagId);
}

class LocalTagRepository implements TagRepository {
  final AppDatabase localDb;

  LocalTagRepository(this.localDb);

  @override
  Future<void> addTag(TagModel tag) async {
    await localDb.insertTag(
      TagsCompanion.insert(
        id: tag.id,
        name: tag.name,
        description: Value(tag.description),
        createdAt: Value(tag.createdAt),
      ),
    );
  }

  @override
  Future<void> updateTag(TagModel tag) async {
    await localDb.updateTag(
      TagsCompanion(
        id: Value(tag.id),
        name: Value(tag.name),
        // FIXED: Do not blindly overwrite with null. Use Value.absent() to ignore the column 
        // during update if the tag model doesn't have a description set.
        description: tag.description != null ? Value(tag.description) : const Value.absent(),
        createdAt: Value(tag.createdAt), // FIXED: Preserve original timestamp
      ),
    );
  }

  @override
  Stream<List<TagModel>> watchTagsForPoi(String poiId) {
    return localDb.watchTagsForPoi(poiId).map((rows) {
      return rows.map((row) => TagModel(
        id: row.id,
        name: row.name,
        description: row.description, // FIXED: Prevent silent data loss
        createdAt: row.createdAt,
      )).toList();
    });
  }

  @override
  Stream<int> watchPoiCountForTag(String tagId) {
    return localDb.watchPoiCountForTag(tagId);
  }
  
  @override
  Stream<List<TagModel>> watchAllTags() {
    return localDb.watchAllTags().map((rows) {
      return rows.map((row) => TagModel(
        id: row.id,
        name: row.name,
        description: row.description, // FIXED: Prevent silent data loss
        createdAt: row.createdAt,
      )).toList();
    });
  }

  @override
  Stream<TagModel?> watchTagById(String id) {
    return localDb.watchTagById(id).map((row) {
      if (row == null) return null;
      return TagModel(
        id: row.id,
        name: row.name,
        description: row.description, // FIXED: Prevent silent data loss
        createdAt: row.createdAt,
      );
    });
  }

  @override
  Stream<List<PoiModel>> watchPoisByTag(String tagId) {
    return localDb.watchPoisByTag(tagId).map((rows) {
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
        createdAt: row.createdAt,
        isShared: false,
      )).toList();
    });
  }

  @override
  Future<TagModel?> getTagById(String id) async {
    final row = await localDb.getTagById(id);
    if (row == null) return null;
    return TagModel(
      id: row.id,
      name: row.name,
      description: row.description, // FIXED: Prevent silent data loss
      createdAt: row.createdAt,
    );
  }

  @override
  Future<void> deleteTag(String id) async {
    await localDb.deleteTag(id);
  }
}

@riverpod
TagRepository tagRepository(TagRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  return LocalTagRepository(db);
}