// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roi_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allRoisHash() => r'b5af0b083ab139c2d044f331a0b820fa379e608d';

/// See also [allRois].
@ProviderFor(allRois)
final allRoisProvider = AutoDisposeStreamProvider<List<RoiModel>>.internal(
  allRois,
  name: r'allRoisProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allRoisHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllRoisRef = AutoDisposeStreamProviderRef<List<RoiModel>>;
String _$roiByIdHash() => r'10bb655b01b17920592ff56bd949e4f22351c135';

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

/// See also [roiById].
@ProviderFor(roiById)
const roiByIdProvider = RoiByIdFamily();

/// See also [roiById].
class RoiByIdFamily extends Family<AsyncValue<RoiModel?>> {
  /// See also [roiById].
  const RoiByIdFamily();

  /// See also [roiById].
  RoiByIdProvider call(String id) {
    return RoiByIdProvider(id);
  }

  @override
  RoiByIdProvider getProviderOverride(covariant RoiByIdProvider provider) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'roiByIdProvider';
}

/// See also [roiById].
class RoiByIdProvider extends AutoDisposeStreamProvider<RoiModel?> {
  /// See also [roiById].
  RoiByIdProvider(String id)
    : this._internal(
        (ref) => roiById(ref as RoiByIdRef, id),
        from: roiByIdProvider,
        name: r'roiByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$roiByIdHash,
        dependencies: RoiByIdFamily._dependencies,
        allTransitiveDependencies: RoiByIdFamily._allTransitiveDependencies,
        id: id,
      );

  RoiByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    Stream<RoiModel?> Function(RoiByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoiByIdProvider._internal(
        (ref) => create(ref as RoiByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<RoiModel?> createElement() {
    return _RoiByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoiByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RoiByIdRef on AutoDisposeStreamProviderRef<RoiModel?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _RoiByIdProviderElement
    extends AutoDisposeStreamProviderElement<RoiModel?>
    with RoiByIdRef {
  _RoiByIdProviderElement(super.provider);

  @override
  String get id => (origin as RoiByIdProvider).id;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
