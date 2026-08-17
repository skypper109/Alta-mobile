// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'ad13470fe866595ad0f58a3e26f11048d94ef22e';

/// See also [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = FutureProvider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = FutureProviderRef<SharedPreferences>;
String _$progressRepositoryHash() =>
    r'f25872eeed04c21389e5c2eb8fedecf2ae1f071b';

/// See also [progressRepository].
@ProviderFor(progressRepository)
final progressRepositoryProvider = FutureProvider<ProgressRepository>.internal(
  progressRepository,
  name: r'progressRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$progressRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProgressRepositoryRef = FutureProviderRef<ProgressRepository>;
String _$progressNotifierHash() => r'94c208371433830c2d53779a3b1c87b3ccbbdb84';

/// See also [ProgressNotifier].
@ProviderFor(ProgressNotifier)
final progressNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ProgressNotifier, ProgressState>.internal(
  ProgressNotifier.new,
  name: r'progressNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$progressNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProgressNotifier = AutoDisposeAsyncNotifier<ProgressState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
