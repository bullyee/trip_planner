// lib/features/poi/models/poi_model.dart

class PoiModel {
  final String id;
  final String? roiId;
  final String authorId;
  final String name;
  final String? description;
  final String? address;
  final double lat;
  final double lng;
  final String? businessHours;
  final String? contactInfo;
  final String? localCoverImagePath;
  final String? remoteCoverImageUrl;
  
  // Necessary for offline-first and cloud sync architectures
  final int createdAt;
  final bool isShared;

  PoiModel({
    required this.id,
    this.roiId,
    required this.authorId,
    required this.name,
    this.description,
    this.address,
    required this.lat,
    required this.lng,
    this.businessHours,
    this.contactInfo,
    this.localCoverImagePath,
    this.remoteCoverImageUrl,
    required this.createdAt,
    this.isShared = false,
  });
}