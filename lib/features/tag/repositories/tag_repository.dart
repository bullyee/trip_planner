import 'package:drift/drift.dart';
import '../../auth/providers/auth_provider.dart';
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
}

class LocalTagRepository implements TagRepository {
  final AppDatabase localDb;
  final String currentUserId;

  LocalTagRepository(this.localDb, this.currentUserId);

  @override
  Future<void> addTag(TagModel tag) async {
    await localDb.insertTag(
      TagsCompanion.insert(
        id: tag.id,
        name: tag.name,
        description: Value(tag.description),
        createdAt: Value(tag.createdAt),
        authorId: currentUserId,
      ),
    );
  }

  @override
  Future<void> updateTag(TagModel tag) async {
    await localDb.updateTag(
      TagsCompanion(
        id: Value(tag.id),
        name: Value(tag.name),
        description: tag.description != null ? Value(tag.description) : const Value.absent(),
        createdAt: Value(tag.createdAt), 
      ),
    );
  }

  @override
  Stream<List<TagModel>> watchTagsForPoi(String poiId) {
    return localDb.watchTagsForPoi(poiId).map((rows) {
      return rows.map((row) => TagModel(
        id: row.id,
        name: row.name,
        description: row.description, 
        createdAt: row.createdAt,
      )).toList();
    });
  }

  @override
  Stream<List<TagModel>> watchAllTags() {
    return localDb.watchAllTags().map((rows) {
      return rows.map((row) => TagModel(
        id: row.id,
        name: row.name,
        description: row.description, 
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
        description: row.description, 
        createdAt: row.createdAt,
      );
    });
  }

  @override
  Future<TagModel?> getTagById(String id) async {
    final row = await localDb.getTagById(id);
    if (row == null) return null;
    return TagModel(
      id: row.id,
      name: row.name,
      description: row.description, 
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
  final currentUserId = ref.watch(currentUserIdProvider);
  return LocalTagRepository(db, currentUserId);
}