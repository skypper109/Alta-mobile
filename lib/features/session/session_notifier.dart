// ─── DetAI — Feature: Session — Notifier (Riverpod + Gemini AI Real) ────────
// Gestion de l'état de la session temps réel avec connexion RÉELLE à Gemini AI.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/gemini_service.dart';
import '../device/device_notifier.dart';
import 'session_entity.dart';
import 'session_repository.dart';

part 'session_notifier.g.dart';

// ══════════════════════════════════════════════════════════════════════════════
// PROVIDERS INFRASTRUCTURE
// ══════════════════════════════════════════════════════════════════════════════

@Riverpod(keepAlive: true)
SessionRepository sessionRepository(Ref ref) {
  final ws   = ref.watch(wsManagerProvider);
  final repo = SessionRepository(wsManager: ws);
  ref.onDispose(repo.dispose);
  return repo;
}

@Riverpod(keepAlive: true)
GeminiService geminiService(Ref ref) {
  return GeminiService();
}

// ══════════════════════════════════════════════════════════════════════════════
// ÉTAT DE LA SESSION
// ══════════════════════════════════════════════════════════════════════════════

class SessionState {
  const SessionState({
    this.messages    = const [],
    this.aiState     = AiState.idle,
    this.amplitudes  = const [],
    this.isConnected = false,
    this.error,
  });

  final List<SessionMessage> messages;
  final AiState              aiState;
  final List<double>         amplitudes;
  final bool                 isConnected;
  final String?              error;

  static const int maxAmplitudes = 80;
  static const int maxMessages   = 100;

  SessionState copyWith({
    List<SessionMessage>? messages,
    AiState?              aiState,
    List<double>?         amplitudes,
    bool?                 isConnected,
    String?               error,
    bool                  clearError = false,
  }) {
    return SessionState(
      messages:    messages    ?? this.messages,
      aiState:     aiState     ?? this.aiState,
      amplitudes:  amplitudes  ?? this.amplitudes,
      isConnected: isConnected ?? this.isConnected,
      error:       clearError  ? null : error ?? this.error,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// NOTIFIER PRINCIPAL
// ══════════════════════════════════════════════════════════════════════════════

@riverpod
class SessionNotifier extends _$SessionNotifier {
  StreamSubscription<Object?>? _messageSub;
  StreamSubscription<Object?>? _aiStateSub;
  StreamSubscription<double>?  _amplitudeSub;
  Timer?                        _animTimer;

  static final List<SessionMessage> _initialMockMessages = [
    SessionMessage(
      id: 'msg-01',
      content: 'Bonjour ! Je suis DetAI, votre tuteur socratique intelligent connecté au moteur AlternIA.',
      speaker: Speaker.ai,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    SessionMessage(
      id: 'msg-02',
      content: 'Comment puis-je isoler l\'inconnue dans une équation du second degré ?',
      speaker: Speaker.student,
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    ),
    SessionMessage(
      id: 'msg-03',
      content: 'Rappelle-toi la forme canonique a(x - α)² + β = 0. Quelle est la première étape pour isoler le terme au carré ?',
      speaker: Speaker.ai,
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
  ];

  @override
  SessionState build() {
    final repo = ref.watch(sessionRepositoryProvider);

    _messageSub = repo.watchMessages().listen((result) {
      result.fold(
        (failure) => state = state.copyWith(error: failure.message),
        (message) {
          final updated = [...state.messages, message];
          final trimmed = updated.length > SessionState.maxMessages
              ? updated.sublist(updated.length - SessionState.maxMessages)
              : updated;
          state = state.copyWith(messages: trimmed, clearError: true);
        },
      );
    });

    _aiStateSub = repo.watchAiState().listen((result) {
      result.fold(
        (failure) => state = state.copyWith(error: failure.message),
        (aiState) => state = state.copyWith(aiState: aiState),
      );
    });

    _amplitudeSub = repo.watchAmplitude().listen((amplitude) {
      final updated = [...state.amplitudes, amplitude];
      final trimmed = updated.length > SessionState.maxAmplitudes
          ? updated.sublist(updated.length - SessionState.maxAmplitudes)
          : updated;
      state = state.copyWith(amplitudes: trimmed);
    });

    ref.onDispose(_cancelSubscriptions);

    return SessionState(
      messages: _initialMockMessages,
      aiState: AiState.listening,
      isConnected: true,
    );
  }

  void _cancelSubscriptions() {
    _animTimer?.cancel();
    _messageSub?.cancel();
    _aiStateSub?.cancel();
    _amplitudeSub?.cancel();
  }

  void clearMessages() {
    state = state.copyWith(messages: []);
  }

  /// Envoie un message élève et interroge RÉELLEMENT Google Gemini AI API.
  Future<void> sendStudentMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final studentMsg = SessionMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: trimmedText,
      speaker: Speaker.student,
      timestamp: DateTime.now(),
    );

    // 1. Ajouter le message de l'élève & passer en analyse socratique
    state = state.copyWith(
      messages: [...state.messages, studentMsg],
      aiState: AiState.thinking,
    );

    _startAmplitudeSimulation();

    // 2. Appel au Backend AlternIA Local
    final gemini = ref.read(geminiServiceProvider);
    final responseText = await gemini.generateSocraticResponse(trimmedText);

    final aiMsg = SessionMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      content: responseText,
      speaker: Speaker.ai,
      timestamp: DateTime.now(),
    );

    // 3. Basculer en émission vocale avec les réponses socratiques réelles
    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      aiState: AiState.speaking,
    );

    // 4. Parler pendant 3s avec animation d'ondes puis repasser en écoute
    await Future.delayed(const Duration(milliseconds: 3000));
    _stopAmplitudeSimulation();
    state = state.copyWith(aiState: AiState.listening);
  }

  void _startAmplitudeSimulation() {
    _animTimer?.cancel();
    final rand = math.Random();
    _animTimer = Timer.periodic(const Duration(milliseconds: 70), (_) {
      final amp = rand.nextDouble() * 0.85 + 0.15;
      final updated = [...state.amplitudes, amp];
      final trimmed = updated.length > SessionState.maxAmplitudes
          ? updated.sublist(updated.length - SessionState.maxAmplitudes)
          : updated;
      state = state.copyWith(amplitudes: trimmed);
    });
  }

  void _stopAmplitudeSimulation() {
    _animTimer?.cancel();
  }
}

@riverpod
List<double> demoAmplitudes(Ref ref) {
  final rand = math.Random();
  return List.generate(
    SessionState.maxAmplitudes,
    (_) => rand.nextDouble() * 0.3,
  );
}
