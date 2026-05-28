import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/database/database.dart';

part 'map_state.freezed.dart';

@freezed
abstract class MapState with _$MapState {
  const factory MapState({
    @Default([]) List<Poi> pois,
    Poi? selectedPoi,
    String? selectedRoiId,
    String? selectedDate,
    @Default(false) bool isLoading,
  }) = _MapState;
}
