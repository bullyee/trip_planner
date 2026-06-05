// lib/features/poi/models/poi_model.dart

class PoiModel {
  final String id;
  final String? roiId;
  final String name;
  final String? description;
  final String? address;
  final double lat;
  final double lng;
  final String? businessHours;
  final String? contactInfo;
  final String? coverImageUri;
  
  // Necessary for offline-first and cloud sync architectures
  final int createdAt;
  final bool isShared;

  PoiModel({
    required this.id,
    this.roiId,
    required this.name,
    this.description,
    this.address,
    required this.lat,
    required this.lng,
    this.businessHours,
    this.contactInfo,
    this.coverImageUri,
    required this.createdAt,
    this.isShared = false,
  });
}