// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MapState {

 List<PoiModel> get pois; PoiModel? get selectedPoi; String? get selectedRoiId; String? get selectedDate; bool get isLoading;
/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MapStateCopyWith<MapState> get copyWith => _$MapStateCopyWithImpl<MapState>(this as MapState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MapState&&const DeepCollectionEquality().equals(other.pois, pois)&&(identical(other.selectedPoi, selectedPoi) || other.selectedPoi == selectedPoi)&&(identical(other.selectedRoiId, selectedRoiId) || other.selectedRoiId == selectedRoiId)&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(pois),selectedPoi,selectedRoiId,selectedDate,isLoading);

@override
String toString() {
  return 'MapState(pois: $pois, selectedPoi: $selectedPoi, selectedRoiId: $selectedRoiId, selectedDate: $selectedDate, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class $MapStateCopyWith<$Res>  {
  factory $MapStateCopyWith(MapState value, $Res Function(MapState) _then) = _$MapStateCopyWithImpl;
@useResult
$Res call({
 List<PoiModel> pois, PoiModel? selectedPoi, String? selectedRoiId, String? selectedDate, bool isLoading
});




}
/// @nodoc
class _$MapStateCopyWithImpl<$Res>
    implements $MapStateCopyWith<$Res> {
  _$MapStateCopyWithImpl(this._self, this._then);

  final MapState _self;
  final $Res Function(MapState) _then;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pois = null,Object? selectedPoi = freezed,Object? selectedRoiId = freezed,Object? selectedDate = freezed,Object? isLoading = null,}) {
  return _then(_self.copyWith(
pois: null == pois ? _self.pois : pois // ignore: cast_nullable_to_non_nullable
as List<PoiModel>,selectedPoi: freezed == selectedPoi ? _self.selectedPoi : selectedPoi // ignore: cast_nullable_to_non_nullable
as PoiModel?,selectedRoiId: freezed == selectedRoiId ? _self.selectedRoiId : selectedRoiId // ignore: cast_nullable_to_non_nullable
as String?,selectedDate: freezed == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MapState].
extension MapStatePatterns on MapState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MapState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MapState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MapState value)  $default,){
final _that = this;
switch (_that) {
case _MapState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MapState value)?  $default,){
final _that = this;
switch (_that) {
case _MapState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PoiModel> pois,  PoiModel? selectedPoi,  String? selectedRoiId,  String? selectedDate,  bool isLoading)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MapState() when $default != null:
return $default(_that.pois,_that.selectedPoi,_that.selectedRoiId,_that.selectedDate,_that.isLoading);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PoiModel> pois,  PoiModel? selectedPoi,  String? selectedRoiId,  String? selectedDate,  bool isLoading)  $default,) {final _that = this;
switch (_that) {
case _MapState():
return $default(_that.pois,_that.selectedPoi,_that.selectedRoiId,_that.selectedDate,_that.isLoading);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PoiModel> pois,  PoiModel? selectedPoi,  String? selectedRoiId,  String? selectedDate,  bool isLoading)?  $default,) {final _that = this;
switch (_that) {
case _MapState() when $default != null:
return $default(_that.pois,_that.selectedPoi,_that.selectedRoiId,_that.selectedDate,_that.isLoading);case _:
  return null;

}
}

}

/// @nodoc


class _MapState implements MapState {
  const _MapState({final  List<PoiModel> pois = const [], this.selectedPoi, this.selectedRoiId, this.selectedDate, this.isLoading = false}): _pois = pois;
  

 final  List<PoiModel> _pois;
@override@JsonKey() List<PoiModel> get pois {
  if (_pois is EqualUnmodifiableListView) return _pois;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pois);
}

@override final  PoiModel? selectedPoi;
@override final  String? selectedRoiId;
@override final  String? selectedDate;
@override@JsonKey() final  bool isLoading;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MapStateCopyWith<_MapState> get copyWith => __$MapStateCopyWithImpl<_MapState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MapState&&const DeepCollectionEquality().equals(other._pois, _pois)&&(identical(other.selectedPoi, selectedPoi) || other.selectedPoi == selectedPoi)&&(identical(other.selectedRoiId, selectedRoiId) || other.selectedRoiId == selectedRoiId)&&(identical(other.selectedDate, selectedDate) || other.selectedDate == selectedDate)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_pois),selectedPoi,selectedRoiId,selectedDate,isLoading);

@override
String toString() {
  return 'MapState(pois: $pois, selectedPoi: $selectedPoi, selectedRoiId: $selectedRoiId, selectedDate: $selectedDate, isLoading: $isLoading)';
}


}

/// @nodoc
abstract mixin class _$MapStateCopyWith<$Res> implements $MapStateCopyWith<$Res> {
  factory _$MapStateCopyWith(_MapState value, $Res Function(_MapState) _then) = __$MapStateCopyWithImpl;
@override @useResult
$Res call({
 List<PoiModel> pois, PoiModel? selectedPoi, String? selectedRoiId, String? selectedDate, bool isLoading
});




}
/// @nodoc
class __$MapStateCopyWithImpl<$Res>
    implements _$MapStateCopyWith<$Res> {
  __$MapStateCopyWithImpl(this._self, this._then);

  final _MapState _self;
  final $Res Function(_MapState) _then;

/// Create a copy of MapState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pois = null,Object? selectedPoi = freezed,Object? selectedRoiId = freezed,Object? selectedDate = freezed,Object? isLoading = null,}) {
  return _then(_MapState(
pois: null == pois ? _self._pois : pois // ignore: cast_nullable_to_non_nullable
as List<PoiModel>,selectedPoi: freezed == selectedPoi ? _self.selectedPoi : selectedPoi // ignore: cast_nullable_to_non_nullable
as PoiModel?,selectedRoiId: freezed == selectedRoiId ? _self.selectedRoiId : selectedRoiId // ignore: cast_nullable_to_non_nullable
as String?,selectedDate: freezed == selectedDate ? _self.selectedDate : selectedDate // ignore: cast_nullable_to_non_nullable
as String?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
