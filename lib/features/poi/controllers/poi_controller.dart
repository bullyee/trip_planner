import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

// IMPORTANT: Removed drift and direct database imports.
// Added the pure domain model and repository imports.
import '../models/poi_model.dart';
import '../repositories/poi_repository.dart';

part 'poi_controller.g.dart';

@riverpod
class PoiController extends _$PoiController {
  @override
  FutureOr<void> build() {}

  /// Handles business logic for saving a POI.
  /// Delegates all database transactions and relational mappings to the Repository.
  Future<String?> savePoi({
    required String? id,
    required String? roiId,
    required String name,
    required String description,
    required String address,
    required String latStr,
    required String lngStr,
    required String businessHours,
    required String contactInfo,
    required List<String> animeIds,
    required List<String> tagIds,
    String? coverImageUri,
    // Added for Dual-Track Sync architecture
    int? existingCreatedAt, 
    bool isShared = false,  
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final poiId = id ?? const Uuid().v4();
      
      // Business logic: clean up empty strings
      String? nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

      // 1. Construct the pure Domain Model
      final poiModel = PoiModel(
        id: poiId,
        roiId: roiId,
        name: name.trim(),
        description: nullIfEmpty(description),
        address: nullIfEmpty(address),
        lat: double.parse(latStr.trim()),
        lng: double.parse(lngStr.trim()),
        businessHours: nullIfEmpty(businessHours),
        contactInfo: nullIfEmpty(contactInfo),
        coverImageUri: coverImageUri,
        // Preserve timestamp on edit, generate new one on creation
        createdAt: existingCreatedAt ?? DateTime.now().millisecondsSinceEpoch,
        isShared: isShared,
      );

      // 2. Delegate to the Repository Layer
      // The repository will handle the transaction, updating the POI, 
      // and setting the relational anime/tag connections.
      await ref.read(poiRepositoryProvider).savePoiWithRelations(
        poi: poiModel,
        animeIds: animeIds,
        tagIds: tagIds,
        isUpdate: id != null,
      );

      state = const AsyncValue.data(null);
      return poiId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}