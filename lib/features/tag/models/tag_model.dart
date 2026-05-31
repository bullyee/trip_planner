// lib/features/tag/models/tag_model.dart

class TagModel {
  final String id;
  final String name;
  final String? description;
  
  // Necessary for offline-first and cloud sync architectures
  final int createdAt;
  final bool isShared;

  TagModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.isShared = false,
  });
}