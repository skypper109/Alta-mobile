// ─── DetAI — Feature: Device — Entity ───────────────────────────────────────
// Entité immuable représentant un boîtier DetAI découvert sur le réseau.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_entity.freezed.dart';
part 'device_entity.g.dart';

// ══════════════════════════════════════════════════════════════════════════════
// DEVICE ENTITY
// ══════════════════════════════════════════════════════════════════════════════

/// Entité immuable représentant un boîtier DetAI sur le réseau local.
@freezed
abstract class DeviceEntity with _$DeviceEntity {
  const factory DeviceEntity({
    /// Identifiant unique (dérivé de l'adresse MAC ou de l'IP).
    required String id,

    /// Nom d'affichage du boîtier (ex: "DetAI-Classroom-01").
    required String name,

    /// Adresse IP locale du boîtier.
    required String ipAddress,

    /// Port WebSocket du boîtier (default: 8080).
    @Default(8080) int port,

    /// Force du signal Wi-Fi (RSSI, entre -100 dBm et 0 dBm).
    /// -1 si non disponible.
    @Default(-1) int signalStrength,

    /// Indique si la connexion WebSocket est active.
    @Default(false) bool isConnected,

    /// Horodatage de la dernière détection.
    DateTime? lastSeen,

    /// Version du firmware du boîtier (si disponible).
    String? firmwareVersion,
  }) = _DeviceEntity;

  /// Désérialisation JSON (pour le cache local).
  factory DeviceEntity.fromJson(Map<String, dynamic> json) =>
      _$DeviceEntityFromJson(json);
}

// ══════════════════════════════════════════════════════════════════════════════
// EXTENSIONS
// ══════════════════════════════════════════════════════════════════════════════

// ── Extensions — disponibles après génération de code (build_runner) ──────────
// Ces extensions utilisent les champs générés par freezed.
// Elles seront disponibles une fois que `flutter pub run build_runner build` a été lancé.
extension DeviceEntityX on DeviceEntity {
  /// URL WebSocket complète.
  String get wsUrl => 'ws://$ipAddress:$port/ws';

  /// URL de base HTTP pour l\'API REST du boîtier.
  String get httpUrl => 'http://$ipAddress:$port';

  /// Qualité du signal sous forme de libellé lisible.
  String get signalLabel {
    final s = signalStrength;
    if (s == -1) return 'N/A';
    if (s >= -50) return 'Excellent';
    if (s >= -65) return 'Bon';
    if (s >= -80) return 'Faible';
    return 'Très faible';
  }

  /// Qualité du signal normalisée entre 0.0 et 1.0.
  double get signalQuality {
    final s = signalStrength;
    if (s == -1) return 0.0;
    return ((s + 100) / 50).clamp(0.0, 1.0);
  }
}
