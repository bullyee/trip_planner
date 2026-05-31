class ReferenceImageModel {
  final String id;
  final String poiId;
  final String localUri;
  final String? description;
  final int createdAt;
  final bool isShared;

  ReferenceImageModel({
    required this.id,
    required this.poiId,
    required this.localUri,
    this.description,
    required this.createdAt,
    this.isShared = false,
  });
}