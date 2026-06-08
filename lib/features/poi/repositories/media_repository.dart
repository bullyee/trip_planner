import 'package:drift/drift.dart';
import '../models/media_asset_model.dart';
import '../models/reference_image_model.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_repository.g.dart';

abstract class MediaRepository {
  // Media Assets
  Future<void> addMediaAsset(MediaAssetModel asset);
  Future<void> deleteMediaAsset(String id);
  
  // Reference Images
  Future<void> addReferenceImage(ReferenceImageModel image);
  Future<void> deleteReferenceImage(String id);
  
  // Renamed to reflect localPath and allow nullable values
  Future<void> updateMediaAssetLocalPath(String id, String? newPath);
  Future<void> updateReferenceImageLocalPath(String id, String? newPath);
  
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
        authorId: asset.authorId, // Must be added to Drift table
        localPath: Value(asset.localPath), // Changed from localUri, wrapped in Value for nullable
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
        authorId: image.authorId, // Assumed addition to ReferenceImageModel
        localPath: Value(image.localPath), // Changed from localUri
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
        authorId: asset.authorId, // Mapped from Drift
        localPath: asset.localPath, // Mapped from Drift
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
        authorId: img.authorId, // Assumed mapped from Drift
        localPath: img.localPath, // Mapped from Drift
        remoteUrl: img.remoteUrl, 
        metadata: img.metadata,   
        createdAt: img.createdAt,
        isShared: false,
      )).toList();
    });
  }

  @override
  Future<void> updateMediaAssetLocalPath(String id, String? newPath) async {
    // Requires implementation update in localDb
    await localDb.updateMediaAssetLocalPath(id, newPath);
  }

  @override
  Future<void> updateReferenceImageLocalPath(String id, String? newPath) async {
    // Requires implementation update in localDb
    await localDb.updateReferenceImageLocalPath(id, newPath);
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
            authorId: row.authorId, // Mapped from Drift
            type: row.type,
            localPath: row.localPath, // Mapped from Drift
            remoteUrl: row.remoteUrl,
            referenceImageId: row.referenceImageId,
            metadata: row.metadata,
            createdAt: row.createdAt,
          )).toList();
        });
  }
}

@riverpod
MediaRepository mediaRepository(MediaRepositoryRef ref) {
  return LocalMediaRepository(ref.watch(databaseProvider));
}