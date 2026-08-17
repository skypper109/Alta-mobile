// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wsManagerHash() => r'8ce34392c4a94d8fca2f0dfd377dca043cea0ee8';

/// Provider du WebSocket Manager (singleton).
///
/// Copied from [wsManager].
@ProviderFor(wsManager)
final wsManagerProvider = Provider<DetWebSocketManager>.internal(
  wsManager,
  name: r'wsManagerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$wsManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WsManagerRef = ProviderRef<DetWebSocketManager>;
String _$deviceRepositoryHash() => r'6ed934959f0ed8a9510a69a1f1acc762d6f5e11b';

/// Provider du repository Device.
///
/// Copied from [deviceRepository].
@ProviderFor(deviceRepository)
final deviceRepositoryProvider = Provider<DeviceRepository>.internal(
  deviceRepository,
  name: r'deviceRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DeviceRepositoryRef = ProviderRef<DeviceRepository>;
String _$deviceNotifierHash() => r'7952eb95e9869d0b7b4cef9eefafd279ff583864';

/// Notifier gérant la découverte et la connexion au boîtier DetAI.
///
/// Copied from [DeviceNotifier].
@ProviderFor(DeviceNotifier)
final deviceNotifierProvider =
    AutoDisposeNotifierProvider<DeviceNotifier, DeviceState>.internal(
  DeviceNotifier.new,
  name: r'deviceNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeviceNotifier = AutoDisposeNotifier<DeviceState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
