// ─── DetAI — Feature: Session — Repository ───────────────────────────────────
// Écoute le WebSocket du boîtier et parse les événements en entities.
library;

import 'dart:async';
import 'dart:convert';

import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../core/failures.dart';
import '../../core/ws_manager.dart';
import 'session_entity.dart';

// ══════════════════════════════════════════════════════════════════════════════
// INTERFACE (DOMAIN)
// ══════════════════════════════════════════════════════════════════════════════

/// Interface du repository Session.
abstract interface class ISessionRepository {
  /// Stream continu des messages de transcription.
  Stream<DetResult<SessionMessage>> watchMessages();

  /// Stream de l'état courant de l'IA.
  Stream<DetResult<AiState>> watchAiState();

  /// Stream des niveaux d'amplitude sonore normalisés [0.0, 1.0].
  Stream<double> watchAmplitude();

  /// Libère les ressources (subscriptions).
  void dispose();
}

// ══════════════════════════════════════════════════════════════════════════════
// IMPLÉMENTATION (DATA)
// ══════════════════════════════════════════════════════════════════════════════

/// Repository Session : parse les événements WebSocket bruts en entities.
///
/// Protocole JSON attendu du boîtier :
/// ```json
/// // Transcription
/// { "type": "transcript", "speaker": "student"|"ai", "text": "...", "partial": false }
///
/// // État IA
/// { "type": "ai_state", "state": "listening"|"thinking"|"speaking"|"idle" }
///
/// // Amplitude
/// { "type": "amplitude", "value": 0.72 }
/// ```
class SessionRepository implements ISessionRepository {
  SessionRepository({required DetWebSocketManager wsManager})
      : _wsManager = wsManager;

  final DetWebSocketManager _wsManager;
  final _logger = Logger();
  final _uuid   = const Uuid();

  // Contrôleurs broadcast internes
  final _messagesCtrl  = StreamController<DetResult<SessionMessage>>.broadcast();
  final _aiStateCtrl   = StreamController<DetResult<AiState>>.broadcast();
  final _amplitudeCtrl = StreamController<double>.broadcast();

  StreamSubscription<String>? _wsSub;
  bool _initialized = false;

  // ── Initialisation (paresseuse) ───────────────────────────────────────────

  /// Démarre l'écoute du WebSocket si ce n'est pas encore fait.
  void _ensureListening() {
    if (_initialized) return;
    _initialized = true;

    _wsSub = _wsManager.messageStream.listen(
      _parseEvent,
      onError: (Object e) {
        _logger.e('[Session] Erreur WS : $e');
        _messagesCtrl.add(left(WebSocketFailure()));
        _aiStateCtrl.add(left(WebSocketFailure()));
      },
    );
  }

  // ── Streams publics ───────────────────────────────────────────────────────

  @override
  Stream<DetResult<SessionMessage>> watchMessages() {
    _ensureListening();
    return _messagesCtrl.stream;
  }

  @override
  Stream<DetResult<AiState>> watchAiState() {
    _ensureListening();
    return _aiStateCtrl.stream;
  }

  @override
  Stream<double> watchAmplitude() {
    _ensureListening();
    return _amplitudeCtrl.stream;
  }

  // ── Parsing événements ────────────────────────────────────────────────────

  /// Parse un message JSON brut du WebSocket et le distribue au bon stream.
  void _parseEvent(String rawJson) {
    try {
      final data = jsonDecode(rawJson) as Map<String, dynamic>;
      final type = data['type'] as String? ?? '';

      switch (type) {
        case 'transcript':
          _handleTranscript(data);
        case 'ai_state':
          _handleAiState(data);
        case 'amplitude':
          _handleAmplitude(data);
        default:
          _logger.t('[Session] Événement ignoré : $type');
      }
    } catch (e) {
      _logger.w('[Session] Erreur parsing JSON : $e | raw: $rawJson');
    }
  }

  void _handleTranscript(Map<String, dynamic> data) {
    final speakerStr = data['speaker'] as String? ?? 'ai';
    final speaker    = speakerStr == 'student' ? Speaker.student : Speaker.ai;
    final text       = data['text'] as String? ?? '';
    final isPartial  = data['partial'] as bool? ?? false;

    if (text.isEmpty) return;

    final message = SessionMessage(
      id:        _uuid.v4(),
      content:   text,
      speaker:   speaker,
      timestamp: DateTime.now(),
      isPartial: isPartial,
    );

    _messagesCtrl.add(right(message));
  }

  void _handleAiState(Map<String, dynamic> data) {
    final stateStr = data['state'] as String? ?? 'idle';
    final aiState  = switch (stateStr) {
      'listening' => AiState.listening,
      'thinking'  => AiState.thinking,
      'speaking'  => AiState.speaking,
      _           => AiState.idle,
    };
    _aiStateCtrl.add(right(aiState));
  }

  void _handleAmplitude(Map<String, dynamic> data) {
    final value = (data['value'] as num?)?.toDouble() ?? 0.0;
    _amplitudeCtrl.add(value.clamp(0.0, 1.0));
  }

  // ── Nettoyage ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _wsSub?.cancel();
    _messagesCtrl.close();
    _aiStateCtrl.close();
    _amplitudeCtrl.close();
    _initialized = false;
  }
}
