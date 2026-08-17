// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$exerciseRepositoryHash() =>
    r'6980b28e9b242428478cf6b5e0780aa97cb578fb';

/// See also [exerciseRepository].
@ProviderFor(exerciseRepository)
final exerciseRepositoryProvider = Provider<ExerciseRepository>.internal(
  exerciseRepository,
  name: r'exerciseRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$exerciseRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExerciseRepositoryRef = ProviderRef<ExerciseRepository>;
String _$exerciseNotifierHash() => r'24f7e296de16b1f19ef762656230b6274c463038';

/// See also [ExerciseNotifier].
@ProviderFor(ExerciseNotifier)
final exerciseNotifierProvider =
    AutoDisposeNotifierProvider<ExerciseNotifier, ExerciseEntity>.internal(
  ExerciseNotifier.new,
  name: r'exerciseNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$exerciseNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ExerciseNotifier = AutoDisposeNotifier<ExerciseEntity>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
