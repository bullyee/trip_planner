// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mediaAssetsByPoiHash() => r'4952817eb1f6697cee475f1cd8d1687037fce852';

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

/// See also [mediaAssetsByPoi].
@ProviderFor(mediaAssetsByPoi)
const mediaAssetsByPoiProvider = MediaAssetsByPoiFamily();

/// See also [mediaAssetsByPoi].
class MediaAssetsByPoiFamily extends Family<AsyncValue<List<MediaAssetModel>>> {
  /// See also [mediaAssetsByPoi].
  const MediaAssetsByPoiFamily();

  /// See also [mediaAssetsByPoi].
  MediaAssetsByPoiProvider call(String poiId) {
    return MediaAssetsByPoiProvider(poiId);
  }

  @override
  MediaAssetsByPoiProvider getProviderOverride(
    covariant MediaAssetsByPoiProvider provider,
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
  String? get name => r'mediaAssetsByPoiProvider';
}

/// See also [mediaAssetsByPoi].
class MediaAssetsByPoiProvider
    extends AutoDisposeStreamProvider<List<MediaAssetModel>> {
  /// See also [mediaAssetsByPoi].
  MediaAssetsByPoiProvider(String poiId)
    : this._internal(
        (ref) => mediaAssetsByPoi(ref as MediaAssetsByPoiRef, poiId),
        from: mediaAssetsByPoiProvider,
        name: r'mediaAssetsByPoiProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$mediaAssetsByPoiHash,
        dependencies: MediaAssetsByPoiFamily._dependencies,
        allTransitiveDependencies:
            MediaAssetsByPoiFamily._allTransitiveDependencies,
        poiId: poiId,
      );

  MediaAssetsByPoiProvider._internal(
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
    Stream<List<MediaAssetModel>> Function(MediaAssetsByPoiRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MediaAssetsByPoiProvider._internal(
        (ref) => create(ref as MediaAssetsByPoiRef),
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
  AutoDisposeStreamProviderElement<List<MediaAssetModel>> createElement() {
    return _MediaAssetsByPoiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MediaAssetsByPoiProvider && other.poiId == poiId;
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
mixin MediaAssetsByPoiRef
    on AutoDisposeStreamProviderRef<List<MediaAssetModel>> {
  /// The parameter `poiId` of this provider.
  String get poiId;
}

class _MediaAssetsByPoiProviderElement
    extends AutoDisposeStreamProviderElement<List<MediaAssetModel>>
    with MediaAssetsByPoiRef {
  _MediaAssetsByPoiProviderElement(super.provider);

  @override
  String get poiId => (origin as MediaAssetsByPoiProvider).poiId;
}

String _$referenceImagesByPoiHash() =>
    r'123187f0905a8e0c21eee828e7840ea9427e4315';

/// See also [referenceImagesByPoi].
@ProviderFor(referenceImagesByPoi)
const referenceImagesByPoiProvider = ReferenceImagesByPoiFamily();

/// See also [referenceImagesByPoi].
class ReferenceImagesByPoiFamily
    extends Family<AsyncValue<List<ReferenceImageModel>>> {
  /// See also [referenceImagesByPoi].
  const ReferenceImagesByPoiFamily();

  /// See also [referenceImagesByPoi].
  ReferenceImagesByPoiProvider call(String poiId) {
    return ReferenceImagesByPoiProvider(poiId);
  }

  @override
  ReferenceImagesByPoiProvider getProviderOverride(
    covariant ReferenceImagesByPoiProvider provider,
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
  String? get name => r'referenceImagesByPoiProvider';
}

/// See also [referenceImagesByPoi].
class ReferenceImagesByPoiProvider
    extends AutoDisposeStreamProvider<List<ReferenceImageModel>> {
  /// See also [referenceImagesByPoi].
  ReferenceImagesByPoiProvider(String poiId)
    : this._internal(
        (ref) => referenceImagesByPoi(ref as ReferenceImagesByPoiRef, poiId),
        from: referenceImagesByPoiProvider,
        name: r'referenceImagesByPoiProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$referenceImagesByPoiHash,
        dependencies: ReferenceImagesByPoiFamily._dependencies,
        allTransitiveDependencies:
            ReferenceImagesByPoiFamily._allTransitiveDependencies,
        poiId: poiId,
      );

  ReferenceImagesByPoiProvider._internal(
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
    Stream<List<ReferenceImageModel>> Function(ReferenceImagesByPoiRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReferenceImagesByPoiProvider._internal(
        (ref) => create(ref as ReferenceImagesByPoiRef),
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
  AutoDisposeStreamProviderElement<List<ReferenceImageModel>> createElement() {
    return _ReferenceImagesByPoiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReferenceImagesByPoiProvider && other.poiId == poiId;
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
mixin ReferenceImagesByPoiRef
    on AutoDisposeStreamProviderRef<List<ReferenceImageModel>> {
  /// The parameter `poiId` of this provider.
  String get poiId;
}

class _ReferenceImagesByPoiProviderElement
    extends AutoDisposeStreamProviderElement<List<ReferenceImageModel>>
    with ReferenceImagesByPoiRef {
  _ReferenceImagesByPoiProviderElement(super.provider);

  @override
  String get poiId => (origin as ReferenceImagesByPoiProvider).poiId;
}

String _$ticketAssetsHash() => r'994830a8538fa4e70f2e661df291595821578ef6';

/// See also [ticketAssets].
@ProviderFor(ticketAssets)
final ticketAssetsProvider =
    AutoDisposeStreamProvider<List<MediaAssetModel>>.internal(
      ticketAssets,
      name: r'ticketAssetsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ticketAssetsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TicketAssetsRef = AutoDisposeStreamProviderRef<List<MediaAssetModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
