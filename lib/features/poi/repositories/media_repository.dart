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

class DualTrackMediaRepository implements MediaRepository {
  final AppDatabase localDb;
  DualTrackMediaRepository(this.localDb);

  @override
  Future<void> addMediaAsset(MediaAssetModel asset) async {
    if (asset.isShared) { 
      // TODO: Firestore logic
    } else {
      await localDb.insertMediaAsset(
        MediaAssetsCompanion.insert(
          id: asset.id,
          poiId: asset.poiId,
          localUri: asset.localUri,
          type: asset.type ?? 'unknown', 
          referenceImageId: Value(asset.referenceImageId),
        )
      );
    }
  }

  @override
  Future<void> deleteMediaAsset(String id) async {
    await localDb.deleteMediaAsset(id);
  }

  @override
  Future<void> addReferenceImage(ReferenceImageModel image) async {
    if (image.isShared) { 
      // TODO: Firestore logic
    } else {
      await localDb.insertReferenceImage(
        ReferenceImagesCompanion.insert(
          id: image.id,
          poiId: image.poiId,
          localUri: image.localUri, 
        )
      );
    }
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
        referenceImageId: asset.referenceImageId,
        createdAt: DateTime.now().millisecondsSinceEpoch,
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
        createdAt: DateTime.now().millisecondsSinceEpoch,
        isShared: false,
      )).toList();
    });
  }

  @override
  Future<void> updateMediaAssetLocalUri(String id, String newUri) async {
    // TODO: Firestore logic (if shared)
    await localDb.updateMediaAssetLocalUri(id, newUri);
  }

  @override
  Future<void> updateReferenceImageLocalUri(String id, String newUri) async {
    // TODO: Firestore logic (if shared)
    await localDb.updateReferenceImageLocalUri(id, newUri);
  }

  @override
  Stream<List<MediaAssetModel>> watchMediaAssetsByType(String type) {
    return (localDb.select(localDb.mediaAssets)..where((tbl) => tbl.type.equals(type)))
        .watch()
        .map((rows) {
          // 將底層的 Drift Entity 轉換成純潔的 Model
          return rows.map((row) => MediaAssetModel(
            id: row.id,
            poiId: row.poiId,
            type: row.type,
            localUri: row.localUri,
            remoteUrl: row.remoteUrl,
            referenceImageId: row.referenceImageId,
            metadata: row.metadata,
            createdAt: DateTime.now().millisecondsSinceEpoch, 
          )).toList();
        });
  }
}

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return DualTrackMediaRepository(ref.read(databaseProvider));
});