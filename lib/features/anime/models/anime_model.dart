// lib/features/anime/models/anime_model.dart

class AnimeModel {
  final String id;
  final String name;
  final String? description;
  
  // Necessary for offline-first and cloud sync architectures
  final int createdAt;
  final bool isShared;
  final String? bangumiId;

  AnimeModel({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.isShared = false,
    this.bangumiId,
  });
}