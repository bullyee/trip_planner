// lib/features/tag/repositories/tag_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../../poi/models/poi_model.dart';
import '../models/tag_model.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';

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

class DualTrackTagRepository implements TagRepository {
  final AppDatabase localDb;

  DualTrackTagRepository(this.localDb);

  @override
  Future<void> addTag(TagModel tag) async {
    if (tag.isShared) {
      // TODO: Route to Firestore SDK when implemented
    } else {
      await localDb.insertTag(
        TagsCompanion.insert(
          id: tag.id,
          name: tag.name,
          description: Value(tag.description),
          createdAt: tag.createdAt,
        ),
      );
    }
  }

  @override
  Future<void> updateTag(TagModel tag) async {
    if (tag.isShared) {
      // TODO: Route to Firestore SDK when implemented
    } else {
      await localDb.updateTag(
        TagsCompanion(
          id: Value(tag.id),
          name: Value(tag.name),
          description: Value(tag.description),
          // createdAt is intentionally omitted here if your local DB 
          // doesn't update the creation time on edit.
        ),
      );
    }
  }

  @override
  Stream<List<TagModel>> watchTagsForPoi(String poiId) {
    return localDb.watchTagsForPoi(poiId).map((rows) {
      return rows.map((row) => TagModel(
        id: row.id,
        name: row.name,
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
      createdAt: row.createdAt,
    );
  }

  @override
  Future<void> deleteTag(String id) async {
    await localDb.deleteTag(id);
  }
}

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final db = ref.read(databaseProvider);
  return DualTrackTagRepository(db);
});