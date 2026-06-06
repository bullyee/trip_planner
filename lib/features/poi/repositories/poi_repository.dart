import 'package:drift/drift.dart';

import '../models/poi_model.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'poi_repository.g.dart';

abstract class PoiRepository {
  Future<void> savePoiWithRelations({
    required PoiModel poi,
    required List<String> animeIds,
    required List<String> tagIds,
    required bool isUpdate,
  });
  Future<void> deletePoi(String id);

  Future<PoiModel> getPoiById(String id);
  Future<List<PoiModel>> getAllPois();
  Future<List<PoiModel>> getPoisByRoi(String roiId);
  Future<List<PoiModel>> getPoisByDate(String date);

  Stream<List<PoiModel>> watchPoisByRoi(String roiId);
  Stream<List<PoiModel>> watchPoisWithoutRoi();
  Stream<PoiModel> watchPoiById(String id);
  Stream<Map<String, PoiModel>> watchAllPois();
  Stream<List<PoiModel>> watchPoisByAnime(String animeId);
  Stream<int> watchPoiCountForAnime(String animeId);
  Stream<List<PoiModel>> watchPoisByTag(String tagId);
  Stream<int> watchPoiCountForTag(String tagId);
}

class LocalPoiRepository implements PoiRepository {
  final AppDatabase localDb;

  LocalPoiRepository(this.localDb);

  @override
  Future<void> savePoiWithRelations({
    required PoiModel poi,
    required List<String> animeIds,
    required List<String> tagIds,
    required bool isUpdate,
  }) async {
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
        createdAt: Value(poi.createdAt),
      );

      if (isUpdate) {
        await localDb.updatePoi(companion);
      } else {
        await localDb.insertPoi(companion);
      }
        
      await localDb.setAnimesForPoi(poi.id, animeIds);
      await localDb.setTagsForPoi(poi.id, tagIds);
    });
  }

  @override
  Future<void> deletePoi(String id) async {
    await localDb.deletePoi(id);
  }

  @override
  Future<PoiModel> getPoiById(String id) async {
    final driftPoi = await localDb.getPoiById(id);
    
    return PoiModel(
      id: driftPoi.id,
      roiId: driftPoi.roiId,
      name: driftPoi.name,
      description: driftPoi.description,
      address: driftPoi.address,
      lat: driftPoi.lat,
      lng: driftPoi.lng,
      businessHours: driftPoi.businessHours,
      contactInfo: driftPoi.contactInfo,
      coverImageUri: driftPoi.coverImageUri,
      createdAt: driftPoi.createdAt, // FIXED: driftRow -> driftPoi
      isShared: false, 
    );
  }

  PoiModel _mapPoi(dynamic driftPoi) {
    return PoiModel(
      id: driftPoi.id,
      roiId: driftPoi.roiId,
      name: driftPoi.name,
      description: driftPoi.description,
      address: driftPoi.address,
      lat: driftPoi.lat,
      lng: driftPoi.lng,
      businessHours: driftPoi.businessHours,
      contactInfo: driftPoi.contactInfo,
      coverImageUri: driftPoi.coverImageUri,
      createdAt: driftPoi.createdAt,
      isShared: false,
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
  Stream<PoiModel> watchPoiById(String id) {
    return localDb.watchPoiById(id).map(_mapPoi);
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
    return localDb.watchPoisByAnime(animeId).map((rows) {
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
  Stream<int> watchPoiCountForAnime(String animeId) {
    return localDb.watchPoiCountForAnime(animeId);
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
  Stream<int> watchPoiCountForTag(String tagId) {
    return localDb.watchPoiCountForTag(tagId);
  }
}

@riverpod
PoiRepository poiRepository(PoiRepositoryRef ref) {
  final db = ref.watch(databaseProvider);
  return LocalPoiRepository(db);
}