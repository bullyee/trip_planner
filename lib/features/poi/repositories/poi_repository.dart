import 'dart:async';
import 'package:drift/drift.dart';

import 'package:flutter/foundation.dart';
import '../models/poi_model.dart';
import '../models/anitabi_poi_data.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/providers/auth_provider.dart';
import '../../sync/providers/firestore_sync_provider.dart';
import '../../sync/services/firestore_sync_service.dart';

part 'poi_repository.g.dart';

abstract class PoiRepository {
  Future<void> savePoiWithRelations({
    required PoiModel poi,
    required List<String> animeIds,
    required List<String> tagIds,
    required bool isUpdate,
  });
  Future<void> deletePoi(String id);
  Future<void> updatePoi(PoiModel poi);

  Future<PoiModel> getPoiById(String id);
  Future<List<PoiModel>> getAllPois();
  Future<List<PoiModel>> getPoisByRoi(String roiId);
  Future<List<PoiModel>> getPoisByDate(String date);

  Stream<List<PoiModel>> watchPoisByRoi(String roiId);
  Stream<List<PoiModel>> watchPoisWithoutRoi();
  Stream<PoiModel?> watchPoiById(String id);
  Stream<Map<String, PoiModel>> watchAllPois();
  Stream<List<PoiModel>> watchPoisByAnime(String animeId);
  Stream<int> watchPoiCountForAnime(String animeId);
  Stream<List<PoiModel>> watchPoisByTag(String tagId);
  Stream<int> watchPoiCountForTag(String tagId);

  Future<AnitabiImportBatchResult> importAnitabiPois({
    required String bangumiId,
    required String animeName,
    required List<AnitabiPoiData> spots,
  });
}

class LocalPoiRepository implements PoiRepository {
  final AppDatabase localDb;
  final String currentUserId;
  final FirestoreSyncService? firestoreSync;

  LocalPoiRepository(this.localDb, this.currentUserId, [this.firestoreSync]);

  @override
  Future<void> updatePoi(PoiModel poi) async {
    final companion = PoisCompanion(
      id: Value(poi.id),
      name: Value(poi.name),
      roiId: Value(poi.roiId),
      authorId: Value(poi.authorId),
      description: Value(poi.description),
      address: Value(poi.address),
      lat: Value(poi.lat),
      lng: Value(poi.lng),
      businessHours: Value(poi.businessHours),
      contactInfo: Value(poi.contactInfo),
      localCoverImagePath: Value(poi.localCoverImagePath),
      remoteCoverImageUrl: Value(poi.remoteCoverImageUrl),
      sortOrder: Value(poi.sortOrder),
      createdAt: Value(poi.createdAt),
      isShared: Value(poi.isShared),
      syncStatus: const Value(1), // SyncStatus.dirty
      isDeleted: Value(poi.isDeleted),
      hasEverSynced: Value(poi.hasEverSynced),
      lastModifiedAt: Value(DateTime.now()),
    );
    
    await localDb.updatePoi(companion); 
  }

  @override
  Future<void> savePoiWithRelations({
    required PoiModel poi,
    required List<String> animeIds,
    required List<String> tagIds,
    required bool isUpdate,
  }) async {
    String? movedFromRoiId;
    await localDb.transaction(() async {
      if (isUpdate) {
        // --- [UPDATE FLOW] ---
        // Fetch the existing POI to preserve its sync state and original author
        final currentPoi = await localDb.getPoiById(poi.id);
        if (currentPoi.hasEverSynced && currentPoi.roiId != null && currentPoi.roiId != poi.roiId) {
          movedFromRoiId = currentPoi.roiId;
        }
        DateTime modifiedAt = DateTime.now();
        if (currentPoi.lastModifiedAt != null &&
            modifiedAt.difference(currentPoi.lastModifiedAt!).inSeconds < 1) {
          modifiedAt = currentPoi.lastModifiedAt!.add(const Duration(seconds: 1));
        }
        final updateCompanion = PoisCompanion(
          id: Value(poi.id),
          roiId: Value(poi.roiId),
          name: Value(poi.name),
          description: Value(poi.description),
          address: Value(poi.address),
          lat: Value(poi.lat),
          lng: Value(poi.lng),
          businessHours: Value(poi.businessHours),
          contactInfo: Value(poi.contactInfo),
          localCoverImagePath: Value(poi.localCoverImagePath),
          remoteCoverImageUrl: Value(poi.remoteCoverImageUrl),
          sortOrder: Value(currentPoi.sortOrder),
          createdAt: Value(poi.createdAt),
          
          // CRITICAL: Preserve original ownership and sync status during an update
          authorId: Value(currentPoi.authorId),
          isShared: Value(currentPoi.isShared),
          syncStatus: const Value(1), // SyncStatus.dirty
          hasEverSynced: Value(currentPoi.hasEverSynced),
          isDeleted: Value(currentPoi.isDeleted),
          lastModifiedAt: Value(modifiedAt),
        );
        
        await localDb.updatePoi(updateCompanion);
        
      } else {
        // --- [INSERT FLOW] ---
        // Use .insert() for strict schema enforcement on new records
        final insertCompanion = PoisCompanion.insert(
          id: poi.id,
          roiId: Value(poi.roiId),
          name: poi.name,
          description: Value(poi.description),
          address: Value(poi.address),
          lat: poi.lat,
          lng: poi.lng,
          businessHours: Value(poi.businessHours),
          contactInfo: Value(poi.contactInfo),
          localCoverImagePath: Value(poi.localCoverImagePath),
          remoteCoverImageUrl: Value(poi.remoteCoverImageUrl),
          createdAt: Value(poi.createdAt),
          
          // CRITICAL: Force the injected user ID as the owner of this new POI
          authorId: currentUserId, 
          // Default to false since it's a local draft until synced
          isShared: const Value(false), 
          syncStatus: const Value(1), // SyncStatus.dirty
          isDeleted: const Value(false),
          hasEverSynced: const Value(false),
          lastModifiedAt: Value(DateTime.now()),
        );
        
        await localDb.insertPoi(insertCompanion);
      }

      // Update relationships regardless of insert or update
      await localDb.setAnimesForPoi(poi.id, animeIds);
      await localDb.setTagsForPoi(poi.id, tagIds);
    });

    final sync = firestoreSync;
    final from = movedFromRoiId;
    if (sync != null && from != null) {
      unawaited(sync.deletePoiFromTrip(from, poi.id).catchError((Object e) {
        debugPrint('[LocalPoiRepository] Error deleting POI from old cloud trip: $e');
      }));
    }
  }

  @override
  Future<void> deletePoi(String id) async {
    await localDb.deletePoi(id);
  }

  @override
  Future<PoiModel> getPoiById(String id) async {
    final driftPoi = await localDb.getPoiById(id);
    return _mapPoi(driftPoi);
  }

  PoiModel _mapPoi(Poi driftPoi) {
    return PoiModel(
      id: driftPoi.id,
      roiId: driftPoi.roiId,
      authorId: driftPoi.authorId,
      name: driftPoi.name,
      description: driftPoi.description,
      address: driftPoi.address,
      lat: driftPoi.lat,
      lng: driftPoi.lng,
      businessHours: driftPoi.businessHours,
      contactInfo: driftPoi.contactInfo,
      localCoverImagePath: driftPoi.localCoverImagePath,
      remoteCoverImageUrl: driftPoi.remoteCoverImageUrl,
      sortOrder: driftPoi.sortOrder,
      createdAt: driftPoi.createdAt,
      isShared: driftPoi.isShared,
      syncStatus: driftPoi.syncStatus,
      isDeleted: driftPoi.isDeleted,
      hasEverSynced: driftPoi.hasEverSynced,
      lastModifiedAt: driftPoi.lastModifiedAt,
    );
  }

  @override
  Stream<List<PoiModel>> watchPoisByRoi(String roiId) {
    return localDb.watchPoisByRoi(roiId).map((list) => list.map(_mapPoi).toList());
  }

  @override
  Stream<List<PoiModel>> watchPoisWithoutRoi() {
    return localDb.watchPoisWithoutRoi().map((list) => list.map(_mapPoi).toList());
  }

  @override
  Stream<PoiModel?> watchPoiById(String id) {
    return localDb.watchPoiById(id).map((p) => p == null ? null : _mapPoi(p));
  }

  @override
  Stream<Map<String, PoiModel>> watchAllPois() {
    return localDb.watchAllPois().map((pois) {
      return {for (final poi in pois) poi.id: _mapPoi(poi)};
    });
  }

  @override
  Future<List<PoiModel>> getAllPois() async {
    final rows = await localDb.getAllPois();
    return rows.map(_mapPoi).toList();
  }

  @override
  Future<List<PoiModel>> getPoisByRoi(String roiId) async {
    final rows = await localDb.getPoisByRoi(roiId);
    return rows.map(_mapPoi).toList();
  }

  @override
  Future<List<PoiModel>> getPoisByDate(String date) async {
    final rows = await localDb.getPoisByDate(date);
    return rows.map(_mapPoi).toList();
  }

  @override
  Stream<List<PoiModel>> watchPoisByAnime(String animeId) {
    return localDb.watchPoisByAnime(animeId).map((rows) => rows.map(_mapPoi).toList());
  }

  @override
  Stream<int> watchPoiCountForAnime(String animeId) {
    return localDb.watchPoiCountForAnime(animeId);
  }

  @override
  Stream<List<PoiModel>> watchPoisByTag(String tagId) {
    return localDb.watchPoisByTag(tagId).map((rows) => rows.map(_mapPoi).toList());
  }

  @override
  Stream<int> watchPoiCountForTag(String tagId) {
    return localDb.watchPoiCountForTag(tagId);
  }

  @override
  Future<AnitabiImportBatchResult> importAnitabiPois({
    required String bangumiId,
    required String animeName,
    required List<AnitabiPoiData> spots,
  }) async {
    final animeId = await localDb.upsertAnimeByBangumiId(
      bangumiId: bangumiId,
      name: animeName,
      authorId: currentUserId,
    );

    int imported = 0;
    int skipped = 0;
    final pendingDownloads = <PendingCoverDownload>[];

    await localDb.transaction(() async {
      for (final spot in spots) {
        try {
          final poiId = spot.id;
          final alreadyImported = await (localDb.select(localDb.pois)
                ..where((t) => t.id.equals(poiId)))
              .getSingleOrNull();

          final companion = PoisCompanion(
            id: Value(poiId),
            name: Value(spot.name),
            lat: Value(spot.lat),
            lng: Value(spot.lng),
            localCoverImagePath: const Value(null),
            description: Value(spot.description),
            address: const Value(null),
            businessHours: const Value(null),
            contactInfo: const Value(null),
            roiId: const Value(null),
            authorId: Value(currentUserId),
            createdAt: Value(DateTime.now().millisecondsSinceEpoch),
            isShared: const Value(false),
          );

          await localDb.into(localDb.pois).insert(
                companion,
                mode: InsertMode.insertOrIgnore,
              );

          await localDb.addAnimeToPoi(poiId, animeId);

          if (alreadyImported != null) {
            skipped++;
            continue;
          }
          imported++;

          if (spot.imageUrl != null && spot.imageUrl!.isNotEmpty) {
            pendingDownloads.add(PendingCoverDownload(
              poiId: poiId,
              url: spot.imageUrl!,
              metadata: spot.imageMetadata ?? '',
            ));
          }
        } catch (e, st) {
          debugPrint('[LocalPoiRepository] Database Insert Error for POI ${spot.id}: $e\n$st');
          skipped++;
        }
      }
    });

    return AnitabiImportBatchResult(
      animeId: animeId,
      imported: imported,
      skipped: skipped,
      pendingDownloads: pendingDownloads,
    );
  }
}

@riverpod
PoiRepository poiRepository(PoiRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  final currentUserId = ref.watch(currentUserIdProvider);
  final firestoreSync = ref.watch(firestoreSyncServiceProvider);
  return LocalPoiRepository(db, currentUserId, firestoreSync);
}