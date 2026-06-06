// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allTagsHash() => r'010e3ac80a00fb7f5767b68ccbfa2c074b3223cc';

/// See also [allTags].
@ProviderFor(allTags)
final allTagsProvider = AutoDisposeStreamProvider<List<TagModel>>.internal(
  allTags,
  name: r'allTagsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$allTagsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllTagsRef = AutoDisposeStreamProviderRef<List<TagModel>>;
String _$tagByIdHash() => r'b69195a7e3fcb085ffb5c5ba97b16d4fd426ef97';

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

/// See also [tagById].
@ProviderFor(tagById)
const tagByIdProvider = TagByIdFamily();

/// See also [tagById].
class TagByIdFamily extends Family<AsyncValue<TagModel?>> {
  /// See also [tagById].
  const TagByIdFamily();

  /// See also [tagById].
  TagByIdProvider call(String id) {
    return TagByIdProvider(id);
  }

  @override
  TagByIdProvider getProviderOverride(covariant TagByIdProvider provider) {
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
  String? get name => r'tagByIdProvider';
}

/// See also [tagById].
class TagByIdProvider extends AutoDisposeStreamProvider<TagModel?> {
  /// See also [tagById].
  TagByIdProvider(String id)
    : this._internal(
        (ref) => tagById(ref as TagByIdRef, id),
        from: tagByIdProvider,
        name: r'tagByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tagByIdHash,
        dependencies: TagByIdFamily._dependencies,
        allTransitiveDependencies: TagByIdFamily._allTransitiveDependencies,
        id: id,
      );

  TagByIdProvider._internal(
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
    Stream<TagModel?> Function(TagByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TagByIdProvider._internal(
        (ref) => create(ref as TagByIdRef),
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
  AutoDisposeStreamProviderElement<TagModel?> createElement() {
    return _TagByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TagByIdProvider && other.id == id;
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
mixin TagByIdRef on AutoDisposeStreamProviderRef<TagModel?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _TagByIdProviderElement
    extends AutoDisposeStreamProviderElement<TagModel?>
    with TagByIdRef {
  _TagByIdProviderElement(super.provider);

  @override
  String get id => (origin as TagByIdProvider).id;
}

String _$tagsForPoiHash() => r'ced46d18b430c4eb6b589d90a563b11099bece2e';

/// See also [tagsForPoi].
@ProviderFor(tagsForPoi)
const tagsForPoiProvider = TagsForPoiFamily();

/// See also [tagsForPoi].
class TagsForPoiFamily extends Family<AsyncValue<List<TagModel>>> {
  /// See also [tagsForPoi].
  const TagsForPoiFamily();

  /// See also [tagsForPoi].
  TagsForPoiProvider call(String poiId) {
    return TagsForPoiProvider(poiId);
  }

  @override
  TagsForPoiProvider getProviderOverride(
    covariant TagsForPoiProvider provider,
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
  String? get name => r'tagsForPoiProvider';
}

/// See also [tagsForPoi].
class TagsForPoiProvider extends AutoDisposeStreamProvider<List<TagModel>> {
  /// See also [tagsForPoi].
  TagsForPoiProvider(String poiId)
    : this._internal(
        (ref) => tagsForPoi(ref as TagsForPoiRef, poiId),
        from: tagsForPoiProvider,
        name: r'tagsForPoiProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tagsForPoiHash,
        dependencies: TagsForPoiFamily._dependencies,
        allTransitiveDependencies: TagsForPoiFamily._allTransitiveDependencies,
        poiId: poiId,
      );

  TagsForPoiProvider._internal(
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
    Stream<List<TagModel>> Function(TagsForPoiRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TagsForPoiProvider._internal(
        (ref) => create(ref as TagsForPoiRef),
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
  AutoDisposeStreamProviderElement<List<TagModel>> createElement() {
    return _TagsForPoiProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TagsForPoiProvider && other.poiId == poiId;
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
mixin TagsForPoiRef on AutoDisposeStreamProviderRef<List<TagModel>> {
  /// The parameter `poiId` of this provider.
  String get poiId;
}

class _TagsForPoiProviderElement
    extends AutoDisposeStreamProviderElement<List<TagModel>>
    with TagsForPoiRef {
  _TagsForPoiProviderElement(super.provider);

  @override
  String get poiId => (origin as TagsForPoiProvider).poiId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
