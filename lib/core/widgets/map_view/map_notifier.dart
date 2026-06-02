import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import the Repository and Model instead of the raw database
import '../../../features/poi/models/poi_model.dart';
import '../../../features/poi/repositories/poi_repository.dart';
import 'map_state.dart';

final mapNotifierProvider =
    StateNotifierProvider<MapNotifier, MapState>((ref) {
  final poiRepo = ref.watch(poiRepositoryProvider);
  return MapNotifier(poiRepo);
});

class MapNotifier extends StateNotifier<MapState> {
  final PoiRepository _poiRepo;

  MapNotifier(this._poiRepo) : super(const MapState()) {
    loadPois();
  }

  Future<void> loadPois({String? roiId}) async {
    state = state.copyWith(isLoading: true);
    final pois = roiId != null
        ? await _poiRepo.getPoisByRoi(roiId)
        : await _poiRepo.getAllPois();
    state = state.copyWith(
      pois: pois,
      isLoading: false,
      selectedRoiId: roiId,
      selectedDate: null,
    );
  }

  Future<void> loadPoisByDate(String? date) async {
    state = state.copyWith(isLoading: true);
    final pois = date != null
        ? await _poiRepo.getPoisByDate(date)
        : await _poiRepo.getAllPois();
    state = state.copyWith(
      pois: pois,
      isLoading: false,
      selectedDate: date,
      selectedRoiId: null,
    );
  }

  // Use PoiModel instead of Drift's Poi class
  void selectPoi(PoiModel? poi) => state = state.copyWith(selectedPoi: poi);

  void clearSelection() => state = state.copyWith(selectedPoi: null);
}