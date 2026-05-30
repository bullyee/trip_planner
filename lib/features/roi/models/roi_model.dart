// lib/features/roi/models/roi_model.dart

class RoiModel {
  final String id;
  final String name;
  final String? description;
  final bool isShared; // Determines if this belongs to Firebase or local Drift

  RoiModel({
    required this.id,
    required this.name,
    this.description,
    this.isShared = false,
  });

  // Optional: Add copyWith, ==, or factory constructors for JSON if needed
}