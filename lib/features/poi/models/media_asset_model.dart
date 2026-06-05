class MediaAssetModel {
  final String id;
  final String poiId;
  final String authorId;
  
  final String? localPath; 
  final String? remoteUrl;
  
  final String? type;
  final String? referenceImageId;
  final int createdAt;
  final bool isShared;
  final String? metadata;

  MediaAssetModel({
    required this.id,
    required this.poiId,
    required this.authorId,
    this.localPath,
    this.remoteUrl,
    this.type,
    this.referenceImageId,
    required this.createdAt,
    this.isShared = false,
    this.metadata,
  });
}