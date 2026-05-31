// lib/features/poi/repositories/poi_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import '../models/poi_model.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';

abstract class PoiRepository {
  /// Saves the POI and its associated many-to-many relations in a single transaction.
  Future<void> savePoiWithRelations({
    required PoiModel poi,
    required List<String> animeIds,
    required List<String> tagIds,
    required bool isUpdate,
  });
}

class DualTrackPoiRepository implements PoiRepository {
  final AppDatabase localDb;

  DualTrackPoiRepository(this.localDb);

  @override
  Future<void> savePoiWithRelations({
    required PoiModel poi,
    required List<String> animeIds,
    required List<String> tagIds,
    required bool isUpdate,
  }) async {
    if (poi.isShared) {
      // TODO: Route to Firestore SDK when implemented
    } else {
      // Execute local SQLite operations within a transaction.
      // Drift-specific 'Value' wrappers are strictly isolated here.
      await localDb.transaction(() async {
        final companion = PoisCompanion(
          id: Value(poi.id),
          roiId: Value(poi.roiId),
          name: Value(poi.name),
          description: Value(poi.description),
          address: Value(poi.address),
          lat: Value(poi.lat),
          lng: Value(poi.lng),
          businessHours: Value(poi.businessHours),
          contactInfo: Value(poi.contactInfo),
          coverImageUri: Value(poi.coverImageUri),
          // Assuming your local Drift DB has a createdAt column. 
          // If not, you may need to add it to your Drift table definition later.
        );

        if (isUpdate) {
          await localDb.updatePoi(companion);
        } else {
          await localDb.insertPoi(companion);
        }
        
        // Update many-to-many relationships
        await localDb.setAnimesForPoi(poi.id, animeIds);
        await localDb.setTagsForPoi(poi.id, tagIds);
      });
    }
  }
}

final poiRepositoryProvider = Provider<PoiRepository>((ref) {
  final db = ref.read(databaseProvider);
  return DualTrackPoiRepository(db);
});