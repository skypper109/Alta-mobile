// ─── DetAI — Feature: Session — Entities ────────────────────────────────────
// Entités immuables : message de session et état de l'IA.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_entity.freezed.dart';
part 'session_entity.g.dart';

// ══════════════════════════════════════════════════════════════════════════════
// AI STATE — État de l'IA en temps réel
// ══════════════════════════════════════════════════════════════════════════════

/// État actuel du moteur IA du boîtier DetAI.
enum AiState {
  /// En attente — aucune activité.
  idle,

  /// Le boîtier écoute la voix de l'élève.
  listening,

  /// L'IA analyse la réponse (traitement socratique).
  thinking,

  /// L'IA émet une réponse vocale.
  speaking;

  /// Libellé lisible en français.
  String get label => switch (this) {
    AiState.idle      => 'Inactif',
    AiState.listening => 'Écoute',
    AiState.thinking  => 'Analyse Socratique',
    AiState.speaking  => 'Émission Vocale',
  };

  /// Icône représentant l'état.
  String get iconDescription => switch (this) {
    AiState.idle      => 'pause',
    AiState.listening => 'mic',
    AiState.thinking  => 'psychology',
    AiState.speaking  => 'volume_up',
  };
}

// ══════════════════════════════════════════════════════════════════════════════
// SESSION MESSAGE — Message de transcription
// ══════════════════════════════════════════════════════════════════════════════

/// Locuteur d'un message dans la session.
enum Speaker {
  /// L'élève (utilisateur).
  student,

  /// L'IA (boîtier DetAI).
  ai;
}

/// Un message de transcription échangé pendant une session.
@freezed
abstract class SessionMessage with _$SessionMessage {
  const factory SessionMessage({
    /// Identifiant unique du message.
    required String id,

    /// Contenu textuel du message.
    required String content,

    /// Locuteur du message (élève ou IA).
    required Speaker speaker,

    /// Horodatage du message.
    required DateTime timestamp,

    /// Indique si le message est en cours de transcription (partiel).
    @Default(false) bool isPartial,
  }) = _SessionMessage;

  factory SessionMessage.fromJson(Map<String, dynamic> json) =>
      _$SessionMessageFromJson(json);
}

// ══════════════════════════════════════════════════════════════════════════════
// SESSION EVENT — Événement WebSocket brut
// ══════════════════════════════════════════════════════════════════════════════

/// Types d'événements émis par le boîtier via WebSocket.
enum WsEventType {
  /// Nouveau fragment de transcription.
  transcript,

  /// Changement d'état de l'IA.
  aiState,

  /// Niveau d'amplitude sonore (pour le waveform).
  amplitude,

  /// Autre type non géré.
  unknown,
}

/// Événement WebSocket parsé depuis le JSON du boîtier.
@freezed
abstract class WsEvent with _$WsEvent {
  const factory WsEvent({
    required WsEventType type,
    required Map<String, dynamic> payload,
    required DateTime receivedAt,
  }) = _WsEvent;

  factory WsEvent.fromJson(Map<String, dynamic> json) =>
      _$WsEventFromJson(json);
}
