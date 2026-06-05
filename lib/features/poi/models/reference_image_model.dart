class ReferenceImageModel {
  final String id;
  final String poiId;
  final String localUri;
  final String? remoteUrl;  // FIXED: Added missing field
  final String? metadata;   // FIXED: Added missing field
  final String? description;
  final int createdAt;
  final bool isShared;

  ReferenceImageModel({
    required this.id,
    required this.poiId,
    required this.localUri,
    this.remoteUrl,         // FIXED: Added to constructor
    this.metadata,          // FIXED: Added to constructor
    this.description,
    required this.createdAt,
    this.isShared = false,
  });
}