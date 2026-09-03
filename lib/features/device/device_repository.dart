// ─── DetAI — Feature: Device — Repository (Interface + Impl) ─────────────────
// Interface domain + implémentation data : scan Wi-Fi, connexion WebSocket.
library;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';

import '../../core/constants.dart';
import '../../core/failures.dart';
import '../../core/ws_manager.dart';
import 'device_entity.dart';

// ══════════════════════════════════════════════════════════════════════════════
// INTERFACE (DOMAIN)
// ══════════════════════════════════════════════════════════════════════════════

abstract interface class IDeviceRepository {
  Future<DetResult<List<DeviceEntity>>> scanDevices();
  Future<DetResult<DeviceEntity>> connectToDevice(DeviceEntity device);
  Future<DetVoidResult> disconnectDevice();
  Stream<WsConnectionState> watchConnectionState();
}

// ══════════════════════════════════════════════════════════════════════════════
// IMPLÉMENTATION (DATA)
// ══════════════════════════════════════════════════════════════════════════════

class DeviceRepository implements IDeviceRepository {
  DeviceRepository({
    required DetWebSocketManager wsManager,
    Dio? dio,
    this.detectorPort = 8000,
    this.scanTimeout  = const Duration(seconds: 3),
  })  : _wsManager = wsManager,
        _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 2)));

  final DetWebSocketManager _wsManager;
  final Dio                 _dio;
  final int                 detectorPort;
  final Duration            scanTimeout;
  final _logger = Logger();

  static final geminiVirtualDevice = DeviceEntity(
    id: 'alternia-server',
    name: 'Serveur AlternIA (IA & RAG Mali)',
    ipAddress: AltaApiConfig.serverBaseUrl,
    port: 443,
    signalStrength: -20,
    firmwareVersion: 'v2.0-Cloudflare',
    lastSeen: DateTime.now(),
  );

  // ── Scan réseau ──────────────────────────────────────────────────────────

  @override
  Future<DetResult<List<DeviceEntity>>> scanDevices() async {
    try {
      final candidates = _buildCandidateList();
      _logger.i('[Device] Scan de ${candidates.length} adresses…');

      final futures = candidates.map((ip) => _probeDevice(ip));
      final results = await Future.wait(futures, eagerError: false);

      final found = results.whereType<DeviceEntity>().toList();
      _logger.i('[Device] ${found.length} boîtier(s) physique(s) détecté(s)');

      return right(found);
    } catch (e, st) {
      _logger.e('[Device] Erreur scan boîtiers', error: e, stackTrace: st);
      return right([]);
    }
  }

  List<String> _buildCandidateList() {
    return [
      '172.20.10.14',
      '127.0.0.1',
      'localhost',
      '10.0.2.2',
      '192.168.4.1',
      '192.168.1.1',
      '192.168.1.100',
      '10.42.0.1',
      '172.16.0.1',
    ];
  }

  Future<DeviceEntity?> _probeDevice(String ip) async {
    for (final port in [8000, 8080]) {
      try {
        final url = ip.startsWith('http') ? '$ip/api/info' : 'http://$ip:$port/api/info';
        final response = await _dio.get(
          url,
          options: Options(
            receiveTimeout: const Duration(seconds: 2),
            sendTimeout:    const Duration(seconds: 2),
          ),
        );

        if (response.statusCode == 200 && response.data is Map) {
          return _parseDeviceInfo(ip, port, response.data as Map<String, dynamic>);
        }
      } catch (_) {}
    }
    return null;
  }

  DeviceEntity _parseDeviceInfo(String ip, int port, Map<String, dynamic> data) {
    return DeviceEntity(
      id:              data['device_id'] as String? ?? data['id'] as String? ?? ip,
      name:            data['device_name'] as String? ?? data['name'] as String? ?? 'Boîtier AlternIA',
      ipAddress:       ip,
      port:            port,
      firmwareVersion: data['firmware'] as String? ?? data['firmware_version'] as String? ?? 'v2.0',
      lastSeen:        DateTime.now(),
    );
  }

  // ── Connexion WebSocket ───────────────────────────────────────────────────

  @override
  Future<DetResult<DeviceEntity>> connectToDevice(DeviceEntity device) async {
    try {
      final wsTarget = 'ws://${device.ipAddress}:${device.port}/ws/session';
      await _wsManager.connect(wsTarget);
      _logger.i('[Device] Connexion WS à $wsTarget');
      return right(device.copyWith(isConnected: true));
    } catch (e) {
      _logger.e('[Device] Échec connexion : $e');
      return left(DeviceConnectionFailure());
    }
  }

  @override
  Future<DetVoidResult> disconnectDevice() async {
    try {
      await _wsManager.disconnect();
      return right(unit);
    } catch (e) {
      return left(DeviceConnectionFailure(
        message: 'Erreur lors de la déconnexion : $e',
      ));
    }
  }

  @override
  Stream<WsConnectionState> watchConnectionState() =>
      _wsManager.stateStream;
}
