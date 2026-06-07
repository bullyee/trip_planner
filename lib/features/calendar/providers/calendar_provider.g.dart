// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timeChunksByDateHash() => r'21d1d0b3760096a1e54ecb13dde6c5b9488a2ae9';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [timeChunksByDate].
@ProviderFor(timeChunksByDate)
const timeChunksByDateProvider = TimeChunksByDateFamily();

/// See also [timeChunksByDate].
class TimeChunksByDateFamily extends Family<AsyncValue<List<TimeChunkModel>>> {
  /// See also [timeChunksByDate].
  const TimeChunksByDateFamily();

  /// See also [timeChunksByDate].
  TimeChunksByDateProvider call(String date) {
    return TimeChunksByDateProvider(date);
  }

  @override
  TimeChunksByDateProvider getProviderOverride(
    covariant TimeChunksByDateProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'timeChunksByDateProvider';
}

/// See also [timeChunksByDate].
class TimeChunksByDateProvider
    extends AutoDisposeStreamProvider<List<TimeChunkModel>> {
  /// See also [timeChunksByDate].
  TimeChunksByDateProvider(String date)
    : this._internal(
        (ref) => timeChunksByDate(ref as TimeChunksByDateRef, date),
        from: timeChunksByDateProvider,
        name: r'timeChunksByDateProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$timeChunksByDateHash,
        dependencies: TimeChunksByDateFamily._dependencies,
        allTransitiveDependencies:
            TimeChunksByDateFamily._allTransitiveDependencies,
        date: date,
      );

  TimeChunksByDateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final String date;

  @override
  Override overrideWith(
    Stream<List<TimeChunkModel>> Function(TimeChunksByDateRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TimeChunksByDateProvider._internal(
        (ref) => create(ref as TimeChunksByDateRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<TimeChunkModel>> createElement() {
    return _TimeChunksByDateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimeChunksByDateProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimeChunksByDateRef
    on AutoDisposeStreamProviderRef<List<TimeChunkModel>> {
  /// The parameter `date` of this provider.
  String get date;
}

class _TimeChunksByDateProviderElement
    extends AutoDisposeStreamProviderElement<List<TimeChunkModel>>
    with TimeChunksByDateRef {
  _TimeChunksByDateProviderElement(super.provider);

  @override
  String get date => (origin as TimeChunksByDateProvider).date;
}

String _$backlogChunksHash() => r'80db87b67b4184a820cd177a122072cea1194ba2';

/// See also [backlogChunks].
@ProviderFor(backlogChunks)
final backlogChunksProvider =
    AutoDisposeStreamProvider<List<TimeChunkModel>>.internal(
      backlogChunks,
      name: r'backlogChunksProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$backlogChunksHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BacklogChunksRef = AutoDisposeStreamProviderRef<List<TimeChunkModel>>;
String _$timeChunksByPoiHash() => r'c2c6cf5322f2543335b88e93afe8035de207e831';

/// See also [timeChunksByPoi].
@ProviderFor(timeChunksByPoi)
const timeChunksByPoiProvider = TimeChunksByPoiFamily();

/// See also [timeChunksByPoi].
class TimeChunksByPoiFamily extends Family<AsyncValue<List<TimeChunkModel>>> {
  /// See also [timeChunksByPoi].
  const TimeChunksByPoiFamily();

  /// See also [timeChunksByPoi].
  TimeChunksByPoiProvider call(String poiId) {
    return TimeChunksByPoiProvider(poiId);
  }

  @override
  TimeChunksByPoiProvider getProviderOverride(
    covariant TimeChunksByPoiProvider provider,
  ) {
    return call(provider.poiId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'timeChunksByPoiProvider';
}

/// See also [timeChunksByPoi].
class TimeChunksByPoiProvider
    extends AutoDisposeStreamProvider<List<TimeChunkModel>> {
  /// See also [timeChunksByPoi].
  TimeChunksByPoiProvider(String poiId)
    : this._internal(
        (ref) => timeChunksByPoi(ref as TimeChunksByPoiRef, poiId),
        from: timeChunksByPoiProvider,
        name: r'timeChunksByPoiProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$timeChunksByPoiHash,
        dependencies: TimeChunksByPoiFamily._dependencies,
        allTransitiveDependencies:
            TimeChunksByPoiFamily._allTransitiveDependencies,
        poiId: poiId,
      );

  TimeChunksByPoiProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.poiId,
  }) : super.internal();

  final String poiId;

  @override
  Override overrideWith(
    Stream<List<TimeChunkModel>> Function(TimeChunksByPoiRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TimeChunksByPoiProvider._internal(
        (ref) => create(ref as TimeChunksByPoiRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        poiId: poiId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<TimeChunkModel>> createElement() {
    return _TimeChunksByPoiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimeChunksByPoiProvider && other.poiId == poiId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, poiId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimeChunksByPoiRef on AutoDisposeStreamProviderRef<List<TimeChunkModel>> {
  /// The parameter `poiId` of this provider.
  String get poiId;
}

class _TimeChunksByPoiProviderElement
    extends AutoDisposeStreamProviderElement<List<TimeChunkModel>>
    with TimeChunksByPoiRef {
  _TimeChunksByPoiProviderElement(super.provider);

  @override
  String get poiId => (origin as TimeChunksByPoiProvider).poiId;
}

String _$selectedDateHash() => r'6806d5610d7069f5c67cb504e4c71468009bd446';

/// See also [SelectedDate].
@ProviderFor(SelectedDate)
final selectedDateProvider =
    AutoDisposeNotifierProvider<SelectedDate, DateTime>.internal(
      SelectedDate.new,
      name: r'selectedDateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$selectedDateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedDate = AutoDisposeNotifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
