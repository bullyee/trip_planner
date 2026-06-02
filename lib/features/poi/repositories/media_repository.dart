import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/media_asset_model.dart';
import '../models/reference_image_model.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';

abstract class MediaRepository {
  // Media Assets
  Future<void> addMediaAsset(MediaAssetModel asset);
  Future<void> deleteMediaAsset(String id);
  
  // Reference Images
  Future<void> addReferenceImage(ReferenceImageModel image);
  Future<void> deleteReferenceImage(String id);
  
  Future<void> updateMediaAssetLocalUri(String id, String newUri);
  Future<void> updateReferenceImageLocalUri(String id, String newUri);
  
  Stream<List<MediaAssetModel>> watchMediaAssetsByPoi(String poiId);
  Stream<List<ReferenceImageModel>> watchReferenceImagesByPoi(String poiId);
  Stream<List<MediaAssetModel>> watchMediaAssetsByType(String type);
}

class LocalMediaRepository implements MediaRepository {
  final AppDatabase localDb;
  LocalMediaRepository(this.localDb);

  @override
  Future<void> addMediaAsset(MediaAssetModel asset) async {
    await localDb.insertMediaAsset(
      MediaAssetsCompanion.insert(
        id: asset.id,
        poiId: asset.poiId,
        localUri: asset.localUri,
        type: asset.type ?? 'unknown', 
        remoteUrl: Value(asset.remoteUrl), 
        metadata: Value(asset.metadata),   
        referenceImageId: Value(asset.referenceImageId),
        createdAt: Value(asset.createdAt),
      )
    );
  }

  @override
  Future<void> deleteMediaAsset(String id) async {
    await localDb.deleteMediaAsset(id);
  }

  @override
  Future<void> addReferenceImage(ReferenceImageModel image) async {
    await localDb.insertReferenceImage(
      ReferenceImagesCompanion.insert(
        id: image.id,
        poiId: image.poiId,
        localUri: image.localUri, 
        remoteUrl: Value(image.remoteUrl), 
        metadata: Value(image.metadata),   
        createdAt: Value(image.createdAt),
      )
    );
  }

  @override
  Future<void> deleteReferenceImage(String id) async {
    await localDb.deleteReferenceImage(id);
  }

  @override
  Stream<List<MediaAssetModel>> watchMediaAssetsByPoi(String poiId) {
    return localDb.watchMediaAssetsByPoi(poiId).map((list) {
      return list.map((asset) => MediaAssetModel(
        id: asset.id,
        poiId: asset.poiId,
        localUri: asset.localUri,
        type: asset.type, 
        remoteUrl: asset.remoteUrl, 
        metadata: asset.metadata,   
        referenceImageId: asset.referenceImageId,
        createdAt: asset.createdAt,
        isShared: false,
      )).toList();
    });
  }

  @override
  Stream<List<ReferenceImageModel>> watchReferenceImagesByPoi(String poiId) {
    return localDb.watchReferenceImagesByPoi(poiId).map((list) {
      return list.map((img) => ReferenceImageModel(
        id: img.id,
        poiId: img.poiId,
        localUri: img.localUri,
        remoteUrl: img.remoteUrl, 
        metadata: img.metadata,   
        createdAt: img.createdAt,
        isShared: false,
      )).toList();
    });
  }

  @override
  Future<void> updateMediaAssetLocalUri(String id, String newUri) async {
    await localDb.updateMediaAssetLocalUri(id, newUri);
  }

  @override
  Future<void> updateReferenceImageLocalUri(String id, String newUri) async {
    await localDb.updateReferenceImageLocalUri(id, newUri);
  }

  @override
  Stream<List<MediaAssetModel>> watchMediaAssetsByType(String type) {
    return (localDb.select(localDb.mediaAssets)
          ..where((tbl) => tbl.type.equals(type))
          ..orderBy([(m) => OrderingTerm.desc(m.id)]))
        .watch()
        .map((rows) {
          return rows.map((row) => MediaAssetModel(
            id: row.id,
            poiId: row.poiId,
            type: row.type,
            localUri: row.localUri,
            remoteUrl: row.remoteUrl,
            referenceImageId: row.referenceImageId,
            metadata: row.metadata,
            createdAt: row.createdAt,
          )).toList();
        });
  }
}

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return LocalMediaRepository(ref.read(databaseProvider));
});