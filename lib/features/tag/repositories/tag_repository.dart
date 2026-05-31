// lib/features/tag/repositories/tag_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../models/tag_model.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';

abstract class TagRepository {
  Future<void> addTag(TagModel tag);
  Future<void> updateTag(TagModel tag);
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
}

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final db = ref.read(databaseProvider);
  return DualTrackTagRepository(db);
});