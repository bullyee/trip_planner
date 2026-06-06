// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncHash() => r'5d7144ebf4922c97f155b2e6fbbba24242b00461';

/// Provides a fully configured JsonSync instance so the UI layer
/// doesn't need to know about the underlying AppDatabase.
///
/// Copied from [sync].
@ProviderFor(sync)
final syncProvider = Provider<JsonSync>.internal(
  sync,
  name: r'syncProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SyncRef = ProviderRef<JsonSync>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
