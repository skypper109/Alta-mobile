// ─── DetAI — Feature: Device — Notifier (Riverpod) ───────────────────────────
// État de la découverte et connexion au boîtier DetAI.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/ws_manager.dart';
import 'device_entity.dart';
import 'device_repository.dart';

part 'device_notifier.g.dart';

// ══════════════════════════════════════════════════════════════════════════════
// PROVIDERS INFRASTRUCTURE
// ══════════════════════════════════════════════════════════════════════════════

/// Provider du WebSocket Manager (singleton).
@Riverpod(keepAlive: true)
DetWebSocketManager wsManager(Ref ref) {
  final manager = DetWebSocketManager();
  ref.onDispose(manager.dispose);
  return manager;
}

/// Provider du repository Device.
@Riverpod(keepAlive: true)
DeviceRepository deviceRepository(Ref ref) {
  return DeviceRepository(
    wsManager: ref.watch(wsManagerProvider),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// ÉTAT DU DEVICE
// ══════════════════════════════════════════════════════════════════════════════

/// État immutable de la feature Device.
class DeviceState {
  const DeviceState({
    this.devices       = const [],
    this.connectedDevice,
    this.isScanning    = false,
    this.error,
    this.connectionState = WsConnectionState.disconnected,
  });

  final List<DeviceEntity>  devices;
  final DeviceEntity?       connectedDevice;
  final bool                isScanning;
  final String?             error;
  final WsConnectionState   connectionState;

  bool get isConnected => connectionState == WsConnectionState.connected;
  bool get hasError    => error != null;

  DeviceState copyWith({
    List<DeviceEntity>? devices,
    DeviceEntity?       connectedDevice,
    bool?               isScanning,
    String?             error,
    WsConnectionState?  connectionState,
    bool                clearError = false,
    bool                clearConnected = false,
  }) {
    return DeviceState(
      devices:         devices ?? this.devices,
      connectedDevice: clearConnected ? null : connectedDevice ?? this.connectedDevice,
      isScanning:      isScanning ?? this.isScanning,
      error:           clearError ? null : error ?? this.error,
      connectionState: connectionState ?? this.connectionState,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// NOTIFIER
// ══════════════════════════════════════════════════════════════════════════════

/// Notifier gérant la découverte et la connexion au boîtier DetAI.
@riverpod
class DeviceNotifier extends _$DeviceNotifier {
  StreamSubscription<WsConnectionState>? _connSub;

  @override
  DeviceState build() {
    // Écoute les changements d'état WS en temps réel
    _connSub = ref
        .read(deviceRepositoryProvider)
        .watchConnectionState()
        .listen((wsState) {
      state = state.copyWith(connectionState: wsState);
    });

    ref.onDispose(() => _connSub?.cancel());

    return const DeviceState();
  }

  // ── Scan des boîtiers ────────────────────────────────────────────────────

  /// Lance un scan du réseau local pour détecter les boîtiers DetAI.
  /// Si aucun boîtier physique n'est trouvé, se connecte automatiquement au serveur AlternIA.
  Future<void> scanDevices() async {
    state = state.copyWith(isScanning: true, clearError: true);

    final result = await ref.read(deviceRepositoryProvider).scanDevices();

    await result.fold(
      (failure) async {
        final serverDevice = DeviceRepository.geminiVirtualDevice;
        state = state.copyWith(
          isScanning: false,
          devices: [serverDevice],
          clearError: true,
        );
        await connectToDevice(serverDevice);
      },
      (devices) async {
        if (devices.isNotEmpty) {
          state = state.copyWith(
            isScanning: false,
            devices: devices,
            clearError: true,
          );
        } else {
          // Aucun boîtier physique trouvé : connexion automatique au serveur AlternIA !
          final serverDevice = DeviceRepository.geminiVirtualDevice;
          state = state.copyWith(
            isScanning: false,
            devices: [serverDevice],
            clearError: true,
          );
          await connectToDevice(serverDevice);
        }
      },
    );
  }

  // ── Connexion ────────────────────────────────────────────────────────────

  /// Se connecte au boîtier sélectionné.
  Future<void> connectToDevice(DeviceEntity device) async {
    state = state.copyWith(
      connectionState: WsConnectionState.connecting,
      clearError: true,
    );

    final result = await ref
        .read(deviceRepositoryProvider)
        .connectToDevice(device);

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (connected) => state = state.copyWith(connectedDevice: connected),
    );
  }

  // ── Déconnexion ───────────────────────────────────────────────────────────

  /// Déconnecte du boîtier actuel.
  Future<void> disconnect() async {
    await ref.read(deviceRepositoryProvider).disconnectDevice();
    state = state.copyWith(
      clearConnected: true,
      connectionState: WsConnectionState.disconnected,
    );
  }
}
