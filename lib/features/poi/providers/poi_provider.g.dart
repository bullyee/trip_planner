// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'poi_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$poisByRoiHash() => r'87a64769ff6377c058ed6ac5731832d9772a3e47';

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

/// See also [poisByRoi].
@ProviderFor(poisByRoi)
const poisByRoiProvider = PoisByRoiFamily();

/// See also [poisByRoi].
class PoisByRoiFamily extends Family<AsyncValue<List<PoiModel>>> {
  /// See also [poisByRoi].
  const PoisByRoiFamily();

  /// See also [poisByRoi].
  PoisByRoiProvider call(String roiId) {
    return PoisByRoiProvider(roiId);
  }

  @override
  PoisByRoiProvider getProviderOverride(covariant PoisByRoiProvider provider) {
    return call(provider.roiId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'poisByRoiProvider';
}

/// See also [poisByRoi].
class PoisByRoiProvider extends AutoDisposeStreamProvider<List<PoiModel>> {
  /// See also [poisByRoi].
  PoisByRoiProvider(String roiId)
    : this._internal(
        (ref) => poisByRoi(ref as PoisByRoiRef, roiId),
        from: poisByRoiProvider,
        name: r'poisByRoiProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$poisByRoiHash,
        dependencies: PoisByRoiFamily._dependencies,
        allTransitiveDependencies: PoisByRoiFamily._allTransitiveDependencies,
        roiId: roiId,
      );

  PoisByRoiProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roiId,
  }) : super.internal();

  final String roiId;

  @override
  Override overrideWith(
    Stream<List<PoiModel>> Function(PoisByRoiRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PoisByRoiProvider._internal(
        (ref) => create(ref as PoisByRoiRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roiId: roiId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<PoiModel>> createElement() {
    return _PoisByRoiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PoisByRoiProvider && other.roiId == roiId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roiId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PoisByRoiRef on AutoDisposeStreamProviderRef<List<PoiModel>> {
  /// The parameter `roiId` of this provider.
  String get roiId;
}

class _PoisByRoiProviderElement
    extends AutoDisposeStreamProviderElement<List<PoiModel>>
    with PoisByRoiRef {
  _PoisByRoiProviderElement(super.provider);

  @override
  String get roiId => (origin as PoisByRoiProvider).roiId;
}

String _$poisWithoutRoiHash() => r'e041ddefd6d952aa900b47aac0717ca758427d26';

/// See also [poisWithoutRoi].
@ProviderFor(poisWithoutRoi)
final poisWithoutRoiProvider =
    AutoDisposeStreamProvider<List<PoiModel>>.internal(
      poisWithoutRoi,
      name: r'poisWithoutRoiProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$poisWithoutRoiHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PoisWithoutRoiRef = AutoDisposeStreamProviderRef<List<PoiModel>>;
String _$poiByIdHash() => r'd04a2f2651ffbf1a16a4a549c183f63c8f05cb40';

/// See also [poiById].
@ProviderFor(poiById)
const poiByIdProvider = PoiByIdFamily();

/// See also [poiById].
class PoiByIdFamily extends Family<AsyncValue<PoiModel>> {
  /// See also [poiById].
  const PoiByIdFamily();

  /// See also [poiById].
  PoiByIdProvider call(String id) {
    return PoiByIdProvider(id);
  }

  @override
  PoiByIdProvider getProviderOverride(covariant PoiByIdProvider provider) {
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
  String? get name => r'poiByIdProvider';
}

/// See also [poiById].
class PoiByIdProvider extends AutoDisposeStreamProvider<PoiModel> {
  /// See also [poiById].
  PoiByIdProvider(String id)
    : this._internal(
        (ref) => poiById(ref as PoiByIdRef, id),
        from: poiByIdProvider,
        name: r'poiByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$poiByIdHash,
        dependencies: PoiByIdFamily._dependencies,
        allTransitiveDependencies: PoiByIdFamily._allTransitiveDependencies,
        id: id,
      );

  PoiByIdProvider._internal(
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
  Override overrideWith(Stream<PoiModel> Function(PoiByIdRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: PoiByIdProvider._internal(
        (ref) => create(ref as PoiByIdRef),
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
  AutoDisposeStreamProviderElement<PoiModel> createElement() {
    return _PoiByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PoiByIdProvider && other.id == id;
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
mixin PoiByIdRef on AutoDisposeStreamProviderRef<PoiModel> {
  /// The parameter `id` of this provider.
  String get id;
}

class _PoiByIdProviderElement extends AutoDisposeStreamProviderElement<PoiModel>
    with PoiByIdRef {
  _PoiByIdProviderElement(super.provider);

  @override
  String get id => (origin as PoiByIdProvider).id;
}

String _$allPoisHash() => r'22dc7be3e0b9bb81315999a531b0283b18860fd0';

/// See also [allPois].
@ProviderFor(allPois)
final allPoisProvider =
    AutoDisposeStreamProvider<Map<String, PoiModel>>.internal(
      allPois,
      name: r'allPoisProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allPoisHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllPoisRef = AutoDisposeStreamProviderRef<Map<String, PoiModel>>;
String _$poisByAnimeHash() => r'de84d780da480aa2afebc12a3b2a6dc2a9ca8944';

/// See also [poisByAnime].
@ProviderFor(poisByAnime)
const poisByAnimeProvider = PoisByAnimeFamily();

/// See also [poisByAnime].
class PoisByAnimeFamily extends Family<AsyncValue<List<PoiModel>>> {
  /// See also [poisByAnime].
  const PoisByAnimeFamily();

  /// See also [poisByAnime].
  PoisByAnimeProvider call(String animeId) {
    return PoisByAnimeProvider(animeId);
  }

  @override
  PoisByAnimeProvider getProviderOverride(
    covariant PoisByAnimeProvider provider,
  ) {
    return call(provider.animeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'poisByAnimeProvider';
}

/// See also [poisByAnime].
class PoisByAnimeProvider extends AutoDisposeStreamProvider<List<PoiModel>> {
  /// See also [poisByAnime].
  PoisByAnimeProvider(String animeId)
    : this._internal(
        (ref) => poisByAnime(ref as PoisByAnimeRef, animeId),
        from: poisByAnimeProvider,
        name: r'poisByAnimeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$poisByAnimeHash,
        dependencies: PoisByAnimeFamily._dependencies,
        allTransitiveDependencies: PoisByAnimeFamily._allTransitiveDependencies,
        animeId: animeId,
      );

  PoisByAnimeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.animeId,
  }) : super.internal();

  final String animeId;

  @override
  Override overrideWith(
    Stream<List<PoiModel>> Function(PoisByAnimeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PoisByAnimeProvider._internal(
        (ref) => create(ref as PoisByAnimeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        animeId: animeId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<PoiModel>> createElement() {
    return _PoisByAnimeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PoisByAnimeProvider && other.animeId == animeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, animeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PoisByAnimeRef on AutoDisposeStreamProviderRef<List<PoiModel>> {
  /// The parameter `animeId` of this provider.
  String get animeId;
}

class _PoisByAnimeProviderElement
    extends AutoDisposeStreamProviderElement<List<PoiModel>>
    with PoisByAnimeRef {
  _PoisByAnimeProviderElement(super.provider);

  @override
  String get animeId => (origin as PoisByAnimeProvider).animeId;
}

String _$poiCountForAnimeHash() => r'4a82f31b204ec70c90e2bc8133f9d52d06154093';

/// See also [poiCountForAnime].
@ProviderFor(poiCountForAnime)
const poiCountForAnimeProvider = PoiCountForAnimeFamily();

/// See also [poiCountForAnime].
class PoiCountForAnimeFamily extends Family<AsyncValue<int>> {
  /// See also [poiCountForAnime].
  const PoiCountForAnimeFamily();

  /// See also [poiCountForAnime].
  PoiCountForAnimeProvider call(String animeId) {
    return PoiCountForAnimeProvider(animeId);
  }

  @override
  PoiCountForAnimeProvider getProviderOverride(
    covariant PoiCountForAnimeProvider provider,
  ) {
    return call(provider.animeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'poiCountForAnimeProvider';
}

/// See also [poiCountForAnime].
class PoiCountForAnimeProvider extends AutoDisposeStreamProvider<int> {
  /// See also [poiCountForAnime].
  PoiCountForAnimeProvider(String animeId)
    : this._internal(
        (ref) => poiCountForAnime(ref as PoiCountForAnimeRef, animeId),
        from: poiCountForAnimeProvider,
        name: r'poiCountForAnimeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$poiCountForAnimeHash,
        dependencies: PoiCountForAnimeFamily._dependencies,
        allTransitiveDependencies:
            PoiCountForAnimeFamily._allTransitiveDependencies,
        animeId: animeId,
      );

  PoiCountForAnimeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.animeId,
  }) : super.internal();

  final String animeId;

  @override
  Override overrideWith(
    Stream<int> Function(PoiCountForAnimeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PoiCountForAnimeProvider._internal(
        (ref) => create(ref as PoiCountForAnimeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        animeId: animeId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<int> createElement() {
    return _PoiCountForAnimeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PoiCountForAnimeProvider && other.animeId == animeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, animeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PoiCountForAnimeRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `animeId` of this provider.
  String get animeId;
}

class _PoiCountForAnimeProviderElement
    extends AutoDisposeStreamProviderElement<int>
    with PoiCountForAnimeRef {
  _PoiCountForAnimeProviderElement(super.provider);

  @override
  String get animeId => (origin as PoiCountForAnimeProvider).animeId;
}

String _$poisByTagHash() => r'fde803b06465df14ab389eb38745157375ed782a';

/// See also [poisByTag].
@ProviderFor(poisByTag)
const poisByTagProvider = PoisByTagFamily();

/// See also [poisByTag].
class PoisByTagFamily extends Family<AsyncValue<List<PoiModel>>> {
  /// See also [poisByTag].
  const PoisByTagFamily();

  /// See also [poisByTag].
  PoisByTagProvider call(String tagId) {
    return PoisByTagProvider(tagId);
  }

  @override
  PoisByTagProvider getProviderOverride(covariant PoisByTagProvider provider) {
    return call(provider.tagId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'poisByTagProvider';
}

/// See also [poisByTag].
class PoisByTagProvider extends AutoDisposeStreamProvider<List<PoiModel>> {
  /// See also [poisByTag].
  PoisByTagProvider(String tagId)
    : this._internal(
        (ref) => poisByTag(ref as PoisByTagRef, tagId),
        from: poisByTagProvider,
        name: r'poisByTagProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$poisByTagHash,
        dependencies: PoisByTagFamily._dependencies,
        allTransitiveDependencies: PoisByTagFamily._allTransitiveDependencies,
        tagId: tagId,
      );

  PoisByTagProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tagId,
  }) : super.internal();

  final String tagId;

  @override
  Override overrideWith(
    Stream<List<PoiModel>> Function(PoisByTagRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PoisByTagProvider._internal(
        (ref) => create(ref as PoisByTagRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tagId: tagId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<PoiModel>> createElement() {
    return _PoisByTagProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PoisByTagProvider && other.tagId == tagId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tagId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PoisByTagRef on AutoDisposeStreamProviderRef<List<PoiModel>> {
  /// The parameter `tagId` of this provider.
  String get tagId;
}

class _PoisByTagProviderElement
    extends AutoDisposeStreamProviderElement<List<PoiModel>>
    with PoisByTagRef {
  _PoisByTagProviderElement(super.provider);

  @override
  String get tagId => (origin as PoisByTagProvider).tagId;
}

String _$poiCountForTagHash() => r'56530b62745a8ecc4837727c135a8673b6a4d6b3';

/// See also [poiCountForTag].
@ProviderFor(poiCountForTag)
const poiCountForTagProvider = PoiCountForTagFamily();

/// See also [poiCountForTag].
class PoiCountForTagFamily extends Family<AsyncValue<int>> {
  /// See also [poiCountForTag].
  const PoiCountForTagFamily();

  /// See also [poiCountForTag].
  PoiCountForTagProvider call(String tagId) {
    return PoiCountForTagProvider(tagId);
  }

  @override
  PoiCountForTagProvider getProviderOverride(
    covariant PoiCountForTagProvider provider,
  ) {
    return call(provider.tagId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'poiCountForTagProvider';
}

/// See also [poiCountForTag].
class PoiCountForTagProvider extends AutoDisposeStreamProvider<int> {
  /// See also [poiCountForTag].
  PoiCountForTagProvider(String tagId)
    : this._internal(
        (ref) => poiCountForTag(ref as PoiCountForTagRef, tagId),
        from: poiCountForTagProvider,
        name: r'poiCountForTagProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$poiCountForTagHash,
        dependencies: PoiCountForTagFamily._dependencies,
        allTransitiveDependencies:
            PoiCountForTagFamily._allTransitiveDependencies,
        tagId: tagId,
      );

  PoiCountForTagProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tagId,
  }) : super.internal();

  final String tagId;

  @override
  Override overrideWith(
    Stream<int> Function(PoiCountForTagRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PoiCountForTagProvider._internal(
        (ref) => create(ref as PoiCountForTagRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tagId: tagId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<int> createElement() {
    return _PoiCountForTagProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PoiCountForTagProvider && other.tagId == tagId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tagId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PoiCountForTagRef on AutoDisposeStreamProviderRef<int> {
  /// The parameter `tagId` of this provider.
  String get tagId;
}

class _PoiCountForTagProviderElement
    extends AutoDisposeStreamProviderElement<int>
    with PoiCountForTagRef {
  _PoiCountForTagProviderElement(super.provider);

  @override
  String get tagId => (origin as PoiCountForTagProvider).tagId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
