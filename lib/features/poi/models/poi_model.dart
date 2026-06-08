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
  
  // ADDED: The sorting weight for the UI sequence
  final int sortOrder;

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
    this.sortOrder = 0, // Default value to prevent mapping errors from older data
    required this.createdAt,
    this.isShared = false,
  });

  // ADDED: Essential for Optimistic UI updates and state management in Riverpod
  PoiModel copyWith({
    String? id,
    String? roiId,
    String? authorId,
    String? name,
    String? description,
    String? address,
    double? lat,
    double? lng,
    String? businessHours,
    String? contactInfo,
    String? localCoverImagePath,
    String? remoteCoverImageUrl,
    int? sortOrder,
    int? createdAt,
    bool? isShared,
  }) {
    return PoiModel(
      id: id ?? this.id,
      roiId: roiId ?? this.roiId,
      authorId: authorId ?? this.authorId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      businessHours: businessHours ?? this.businessHours,
      contactInfo: contactInfo ?? this.contactInfo,
      localCoverImagePath: localCoverImagePath ?? this.localCoverImagePath,
      remoteCoverImageUrl: remoteCoverImageUrl ?? this.remoteCoverImageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      isShared: isShared ?? this.isShared,
    );
  }
}