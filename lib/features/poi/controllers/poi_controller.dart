import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

// Ensure this path matches your project's actual database location
import '../../../core/database/database.dart'; 
import '../../../core/providers/database_provider.dart';

// Required for Riverpod Generator. 
// It will show an error until you run build_runner.
part 'poi_controller.g.dart';

@riverpod
class PoiController extends _$PoiController {
  @override
  FutureOr<void> build() {}

  /// Handles business logic and database operations for saving a POI.
  Future<bool> savePoi({
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
  }) async {
    // Set state to loading to prevent multiple submissions
    state = const AsyncValue.loading();
    
    try {
      final db = ref.read(databaseProvider);
      final poiId = id ?? const Uuid().v4();

      // Business logic: clean up empty strings to store null in DB
      String? nullIfEmpty(String s) => s.trim().isEmpty ? null : s.trim();

      final companion = PoisCompanion(
        id: Value(poiId),
        roiId: Value(roiId),
        name: Value(name.trim()),
        description: Value(nullIfEmpty(description)),
        address: Value(nullIfEmpty(address)),
        lat: Value(double.parse(latStr.trim())),
        lng: Value(double.parse(lngStr.trim())),
        businessHours: Value(nullIfEmpty(businessHours)),
        contactInfo: Value(nullIfEmpty(contactInfo)),
        coverImageUri: const Value(null),
      );

      // Execute database operations 
      // (TODO: Consider wrapping these in a db.transaction() for safety)
      if (id != null) {
        await db.updatePoi(companion);
      } else {
        await db.insertPoi(companion);
      }

      await db.setAnimesForPoi(poiId, animeIds);
      await db.setTagsForPoi(poiId, tagIds);

      // Success: return to normal data state
      state = const AsyncValue.data(null);
      return true; 
    } catch (e, st) {
      // Error occurred: propagate the error state
      state = AsyncValue.error(e, st);
      return false; 
    }
  }
}