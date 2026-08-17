// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sessionRepositoryHash() => r'1da696c52961e74585ae52672c69a7a302209017';

/// See also [sessionRepository].
@ProviderFor(sessionRepository)
final sessionRepositoryProvider = Provider<SessionRepository>.internal(
  sessionRepository,
  name: r'sessionRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SessionRepositoryRef = ProviderRef<SessionRepository>;
String _$geminiServiceHash() => r'e5feb19f16ed3b98580dffdb3a321139b26a7d6d';

/// See also [geminiService].
@ProviderFor(geminiService)
final geminiServiceProvider = Provider<GeminiService>.internal(
  geminiService,
  name: r'geminiServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$geminiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GeminiServiceRef = ProviderRef<GeminiService>;
String _$demoAmplitudesHash() => r'98ef6b12f2db066f48f2ec000173ce2bfe5a41f2';

/// See also [demoAmplitudes].
@ProviderFor(demoAmplitudes)
final demoAmplitudesProvider = AutoDisposeProvider<List<double>>.internal(
  demoAmplitudes,
  name: r'demoAmplitudesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$demoAmplitudesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DemoAmplitudesRef = AutoDisposeProviderRef<List<double>>;
String _$sessionNotifierHash() => r'480a3a23bd170ed7729f8347425f8d30e19b8cd4';

/// See also [SessionNotifier].
@ProviderFor(SessionNotifier)
final sessionNotifierProvider =
    AutoDisposeNotifierProvider<SessionNotifier, SessionState>.internal(
  SessionNotifier.new,
  name: r'sessionNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sessionNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SessionNotifier = AutoDisposeNotifier<SessionState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
