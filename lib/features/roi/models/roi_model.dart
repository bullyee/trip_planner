// lib/features/roi/models/roi_model.dart

class RoiModel {
  final String id;
  final String name;
  final String? description;
  final bool isShared;
  final int createdAt; // Added for precise client-side timestamping
  final bool isOfflineCached;
  final String authorId;

  RoiModel({
    required this.id,
    required this.name,
    required this.authorId,
    required this.createdAt, 
    this.description,
    this.isShared = false,
    this.isOfflineCached = true,
  });
}