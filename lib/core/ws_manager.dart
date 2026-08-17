// ─── DetAI — WebSocket Manager ──────────────────────────────────────────────
// Gestion de la connexion WebSocket avec reconnexion automatique (backoff exp.)
library;

import 'dart:async';
import 'dart:math' show min;

import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// ══════════════════════════════════════════════════════════════════════════════
// ÉTAT DE CONNEXION
// ══════════════════════════════════════════════════════════════════════════════

/// État de la connexion WebSocket.
enum WsConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
}

// ══════════════════════════════════════════════════════════════════════════════
// WEBSOCKET MANAGER
// ══════════════════════════════════════════════════════════════════════════════

/// Manager WebSocket singleton-ready avec reconnexion automatique.
///
/// Exemple d'utilisation :
/// ```dart
/// final ws = DetWebSocketManager();
/// await ws.connect('ws://192.168.4.1:8080/ws');
/// ws.messageStream.listen((msg) => print(msg));
/// ```
class DetWebSocketManager {
  DetWebSocketManager({
    this.maxReconnectAttempts = 10,
    this.baseReconnectDelay   = const Duration(seconds: 1),
    this.maxReconnectDelay    = const Duration(seconds: 30),
  });

  // ── Configuration ────────────────────────────────────────────────────────
  final int      maxReconnectAttempts;
  final Duration baseReconnectDelay;
  final Duration maxReconnectDelay;

  // ── Internals ─────────────────────────────────────────────────────────────
  final _logger       = Logger();
  WebSocketChannel?   _channel;
  String?             _lastUrl;
  int                 _reconnectAttempts = 0;
  bool                _shouldReconnect   = true;
  Timer?              _reconnectTimer;

  // ── Contrôleurs de streams ────────────────────────────────────────────────
  final _messageController = StreamController<String>.broadcast();
  final _stateController   = StreamController<WsConnectionState>.broadcast();

  // ── Streams publics ───────────────────────────────────────────────────────

  /// Stream de messages texte reçus du boîtier.
  Stream<String> get messageStream => _messageController.stream;

  /// Stream des changements d'état de la connexion.
  Stream<WsConnectionState> get stateStream => _stateController.stream;

  /// État courant (best-effort, non garanti thread-safe).
  WsConnectionState _currentState = WsConnectionState.disconnected;
  WsConnectionState get currentState => _currentState;

  // ══════════════════════════════════════════════════════════════════════════
  // CONNEXION
  // ══════════════════════════════════════════════════════════════════════════

  /// Se connecte à l'URL WebSocket donnée.
  /// Lance automatiquement la reconnexion si la connexion est perdue.
  Future<void> connect(String url) async {
    _lastUrl         = url;
    _shouldReconnect = true;
    _reconnectAttempts = 0;
    await _doConnect(url);
  }

  Future<void> _doConnect(String url) async {
    _emitState(WsConnectionState.connecting);
    _logger.i('[WS] Connexion à $url…');

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      // Attendre la handshake
      await _channel!.ready;

      _emitState(WsConnectionState.connected);
      _reconnectAttempts = 0;
      _logger.i('[WS] Connecté à $url');

      // Écoute des messages
      _channel!.stream.listen(
        (dynamic data) {
          if (data is String) {
            _messageController.add(data);
          }
        },
        onError: (Object error) {
          _logger.w('[WS] Erreur stream : $error');
          _scheduleReconnect();
        },
        onDone: () {
          _logger.w('[WS] Connexion fermée (code: ${_channel?.closeCode})');
          if (_shouldReconnect) _scheduleReconnect();
        },
        cancelOnError: false,
      );
    } catch (e) {
      _logger.e('[WS] Échec connexion : $e');
      _scheduleReconnect();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // RECONNEXION AUTOMATIQUE (BACKOFF EXPONENTIEL)
  // ══════════════════════════════════════════════════════════════════════════

  void _scheduleReconnect() {
    if (!_shouldReconnect) return;
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _emitState(WsConnectionState.failed);
      _logger.e('[WS] Nombre maximum de tentatives atteint.');
      return;
    }

    _emitState(WsConnectionState.reconnecting);

    // Délai exponentiel : 1s, 2s, 4s, 8s… plafonné à maxReconnectDelay
    final delayMs = min(
      baseReconnectDelay.inMilliseconds * (1 << _reconnectAttempts),
      maxReconnectDelay.inMilliseconds,
    );
    _reconnectAttempts++;

    _logger.i('[WS] Reconnexion dans ${delayMs}ms (tentative $_reconnectAttempts)');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(milliseconds: delayMs), () {
      if (_lastUrl != null) _doConnect(_lastUrl!);
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ENVOI DE MESSAGES
  // ══════════════════════════════════════════════════════════════════════════

  /// Envoie un message texte au boîtier.
  /// Retourne false si la connexion n'est pas active.
  bool send(String message) {
    if (_currentState != WsConnectionState.connected || _channel == null) {
      _logger.w('[WS] Tentative d\'envoi sans connexion active.');
      return false;
    }
    _channel!.sink.add(message);
    return true;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DÉCONNEXION
  // ══════════════════════════════════════════════════════════════════════════

  /// Déconnecte proprement et empêche toute reconnexion automatique.
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _emitState(WsConnectionState.disconnected);
    _logger.i('[WS] Déconnecté proprement.');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // NETTOYAGE
  // ══════════════════════════════════════════════════════════════════════════

  /// Libère toutes les ressources. Appeler depuis le dispose() du widget.
  Future<void> dispose() async {
    await disconnect();
    await _messageController.close();
    await _stateController.close();
  }

  // ── Helpers privés ────────────────────────────────────────────────────────

  void _emitState(WsConnectionState state) {
    _currentState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }
}
