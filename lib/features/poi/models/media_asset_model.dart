class MediaAssetModel {
  final String id;
  final String poiId;
  final String localUri;
  final String? cloudUri;
  final String? type;
  final String? referenceImageId;
  final int createdAt;
  final bool isShared;
  final String? metadata;
  final String? remoteUrl;

  MediaAssetModel({
    required this.id,
    required this.poiId,
    required this.localUri,
    this.cloudUri,
    this.type,
    this.referenceImageId,
    required this.createdAt,
    this.isShared = false,
    this.metadata,
    this.remoteUrl,
  });
}