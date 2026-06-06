// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anime_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allAnimesHash() => r'05fecf3e84f601cbaac8df37d8a30e9c3548dffe';

/// See also [allAnimes].
@ProviderFor(allAnimes)
final allAnimesProvider = AutoDisposeStreamProvider<List<AnimeModel>>.internal(
  allAnimes,
  name: r'allAnimesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allAnimesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllAnimesRef = AutoDisposeStreamProviderRef<List<AnimeModel>>;
String _$animeByIdHash() => r'125dbf38e5925db6ca8c7c9eb18d08ea23331d3a';

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

/// See also [animeById].
@ProviderFor(animeById)
const animeByIdProvider = AnimeByIdFamily();

/// See also [animeById].
class AnimeByIdFamily extends Family<AsyncValue<AnimeModel?>> {
  /// See also [animeById].
  const AnimeByIdFamily();

  /// See also [animeById].
  AnimeByIdProvider call(String id) {
    return AnimeByIdProvider(id);
  }

  @override
  AnimeByIdProvider getProviderOverride(covariant AnimeByIdProvider provider) {
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
  String? get name => r'animeByIdProvider';
}

/// See also [animeById].
class AnimeByIdProvider extends AutoDisposeStreamProvider<AnimeModel?> {
  /// See also [animeById].
  AnimeByIdProvider(String id)
    : this._internal(
        (ref) => animeById(ref as AnimeByIdRef, id),
        from: animeByIdProvider,
        name: r'animeByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$animeByIdHash,
        dependencies: AnimeByIdFamily._dependencies,
        allTransitiveDependencies: AnimeByIdFamily._allTransitiveDependencies,
        id: id,
      );

  AnimeByIdProvider._internal(
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
    Stream<AnimeModel?> Function(AnimeByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AnimeByIdProvider._internal(
        (ref) => create(ref as AnimeByIdRef),
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
  AutoDisposeStreamProviderElement<AnimeModel?> createElement() {
    return _AnimeByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnimeByIdProvider && other.id == id;
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
mixin AnimeByIdRef on AutoDisposeStreamProviderRef<AnimeModel?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _AnimeByIdProviderElement
    extends AutoDisposeStreamProviderElement<AnimeModel?>
    with AnimeByIdRef {
  _AnimeByIdProviderElement(super.provider);

  @override
  String get id => (origin as AnimeByIdProvider).id;
}

String _$animesForPoiHash() => r'd18235b0428653ac8726287933f9b246bdba8b2c';

/// See also [animesForPoi].
@ProviderFor(animesForPoi)
const animesForPoiProvider = AnimesForPoiFamily();

/// See also [animesForPoi].
class AnimesForPoiFamily extends Family<AsyncValue<List<AnimeModel>>> {
  /// See also [animesForPoi].
  const AnimesForPoiFamily();

  /// See also [animesForPoi].
  AnimesForPoiProvider call(String poiId) {
    return AnimesForPoiProvider(poiId);
  }

  @override
  AnimesForPoiProvider getProviderOverride(
    covariant AnimesForPoiProvider provider,
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
  String? get name => r'animesForPoiProvider';
}

/// See also [animesForPoi].
class AnimesForPoiProvider extends AutoDisposeStreamProvider<List<AnimeModel>> {
  /// See also [animesForPoi].
  AnimesForPoiProvider(String poiId)
    : this._internal(
        (ref) => animesForPoi(ref as AnimesForPoiRef, poiId),
        from: animesForPoiProvider,
        name: r'animesForPoiProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$animesForPoiHash,
        dependencies: AnimesForPoiFamily._dependencies,
        allTransitiveDependencies:
            AnimesForPoiFamily._allTransitiveDependencies,
        poiId: poiId,
      );

  AnimesForPoiProvider._internal(
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
    Stream<List<AnimeModel>> Function(AnimesForPoiRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AnimesForPoiProvider._internal(
        (ref) => create(ref as AnimesForPoiRef),
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
  AutoDisposeStreamProviderElement<List<AnimeModel>> createElement() {
    return _AnimesForPoiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnimesForPoiProvider && other.poiId == poiId;
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
mixin AnimesForPoiRef on AutoDisposeStreamProviderRef<List<AnimeModel>> {
  /// The parameter `poiId` of this provider.
  String get poiId;
}

class _AnimesForPoiProviderElement
    extends AutoDisposeStreamProviderElement<List<AnimeModel>>
    with AnimesForPoiRef {
  _AnimesForPoiProviderElement(super.provider);

  @override
  String get poiId => (origin as AnimesForPoiProvider).poiId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
