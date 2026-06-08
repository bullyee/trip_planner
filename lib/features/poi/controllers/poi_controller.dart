import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

// IMPORTANT: Removed drift and direct database imports.
// Added the pure domain model and repository imports.
import '../../auth/providers/auth_provider.dart';
import '../../../core/utils/app_result.dart';
import '../models/poi_model.dart';
import '../repositories/poi_repository.dart';

part 'poi_controller.g.dart';

@Riverpod(keepAlive: true)
class PoiController extends _$PoiController {
  @override
  FutureOr<void> build() {}

  /// Handles business logic for saving a POI.
  /// Delegates all database transactions and relational mappings to the Repository.
  Future<AppResult<String>> savePoi({
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
    String? localCoverImagePath,
    String? remoteCoverImageUrl,
    int? existingCreatedAt, 
    bool isShared = false,  
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final poiId = id ?? const Uuid().v4();
      
      // Business logic: clean up empty strings
      String? nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

      final currentUserId = ref.read(currentUserIdProvider);

      // 1. Construct the pure Domain Model
      final poiModel = PoiModel(
        id: poiId,
        roiId: roiId,
        authorId: currentUserId,
        name: name.trim(),
        description: nullIfEmpty(description),
        address: nullIfEmpty(address),
        lat: double.parse(latStr.trim()),
        lng: double.parse(lngStr.trim()),
        businessHours: nullIfEmpty(businessHours),
        contactInfo: nullIfEmpty(contactInfo),
        localCoverImagePath: localCoverImagePath,
        remoteCoverImageUrl: remoteCoverImageUrl,
        // Preserve timestamp on edit, generate new one on creation
        createdAt: existingCreatedAt ?? DateTime.now().millisecondsSinceEpoch,
        isShared: isShared,
      );

      // 2. Delegate to the Repository Layer (Clean Architecture)
      await ref.read(poiRepositoryProvider).savePoiWithRelations(
        poi: poiModel,
        animeIds: animeIds,
        tagIds: tagIds,
        isUpdate: id != null,
      );

      state = const AsyncValue.data(null);
      return Success(poiId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return Failure(e.toString(), st);
    }
  }
}