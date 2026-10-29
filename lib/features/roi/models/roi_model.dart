// lib/features/roi/models/roi_model.dart

class RoiModel {
  final String id;
  final String name;
  final String? description;
  final bool isShared;
  final int createdAt;
  final bool isOfflineCached;
  final String authorId;
  final int cloudVersion;
  final int? syncLockExpiresAt;

  const RoiModel({
    required this.id,
    required this.name,
    required this.authorId,
    required this.createdAt,
    this.description,
    this.isShared = false,
    this.isOfflineCached = true,
    this.cloudVersion = 0,
    this.syncLockExpiresAt,
  });

  RoiModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? isShared,
    int? createdAt,
    bool? isOfflineCached,
    String? authorId,
    int? cloudVersion,
    int? syncLockExpiresAt,
  }) {
    return RoiModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isShared: isShared ?? this.isShared,
      createdAt: createdAt ?? this.createdAt,
      isOfflineCached: isOfflineCached ?? this.isOfflineCached,
      authorId: authorId ?? this.authorId,
      cloudVersion: cloudVersion ?? this.cloudVersion,
      syncLockExpiresAt: syncLockExpiresAt ?? this.syncLockExpiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isShared': isShared,
      'createdAt': createdAt,
      'isOfflineCached': isOfflineCached,
      'authorId': authorId,
      'cloudVersion': cloudVersion,
      'syncLockExpiresAt': syncLockExpiresAt,
    };
  }

  factory RoiModel.fromJson(Map<String, dynamic> json) {
    return RoiModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isShared: json['isShared'] as bool? ?? false,
      createdAt: json['createdAt'] as int,
      isOfflineCached: json['isOfflineCached'] as bool? ?? true,
      authorId: json['authorId'] as String,
      cloudVersion: json['cloudVersion'] as int? ?? 0,
      syncLockExpiresAt: json['syncLockExpiresAt'] as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoiModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          isShared == other.isShared &&
          createdAt == other.createdAt &&
          isOfflineCached == other.isOfflineCached &&
          authorId == other.authorId &&
          cloudVersion == other.cloudVersion &&
          syncLockExpiresAt == other.syncLockExpiresAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      isShared.hashCode ^
      createdAt.hashCode ^
      isOfflineCached.hashCode ^
      authorId.hashCode ^
      cloudVersion.hashCode ^
      syncLockExpiresAt.hashCode;
}
