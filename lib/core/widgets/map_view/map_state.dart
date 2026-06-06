import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../features/poi/models/poi_model.dart';

part 'map_state.freezed.dart';

@freezed
abstract class MapState with _$MapState {
  const factory MapState({
    @Default([]) List<PoiModel> pois,
    PoiModel? selectedPoi,
    String? selectedRoiId,
    String? selectedDate,
    @Default(false) bool isLoading,
  }) = _MapState;
}
