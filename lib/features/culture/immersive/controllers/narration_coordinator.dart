import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// États de la narration vocale
enum NarrationState {
  idle,
  speaking,
  paused,
  completed,
  error,
}

/// État réactif du coordinateur de narration
class NarrationSnapshot {
  final NarrationState state;
  final String currentText;
  final String? activeContentId;
  final double progress; // De 0.0 à 1.0 (approximatif ou selon étapes)
  final double speechRate;
  final String? errorMessage;

  const NarrationSnapshot({
    this.state = NarrationState.idle,
    this.currentText = '',
    this.activeContentId,
    this.progress = 0.0,
    this.speechRate = 0.48,
    this.errorMessage,
  });

  bool get isSpeaking => state == NarrationState.speaking;
  bool get isIdle => state == NarrationState.idle;
  bool get isCompleted => state == NarrationState.completed;

  NarrationSnapshot copyWith({
    NarrationState? state,
    String? currentText,
    String? activeContentId,
    bool clearActiveContentId = false,
    double? progress,
    double? speechRate,
    String? errorMessage,
  }) {
    return NarrationSnapshot(
      state: state ?? this.state,
      currentText: currentText ?? this.currentText,
      activeContentId: clearActiveContentId
          ? null
          : (activeContentId ?? this.activeContentId),
      progress: progress ?? this.progress,
      speechRate: speechRate ?? this.speechRate,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Coordinateur centralisé pour la synthèse vocale (Griot & Narrateur culturel)
class NarrationCoordinator extends StateNotifier<NarrationSnapshot> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  VoidCallback? _currentCompletionCallback;

  NarrationCoordinator() : super(const NarrationSnapshot()) {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('fr-FR');
      await _flutterTts.setSpeechRate(state.speechRate);
      await _flutterTts.setPitch(0.95);

      _flutterTts.setStartHandler(() {
        state = state.copyWith(state: NarrationState.speaking);
      });

      _flutterTts.setCompletionHandler(() {
        state = state.copyWith(
          state: NarrationState.completed,
          progress: 1.0,
        );
        _currentCompletionCallback?.call();
        _currentCompletionCallback = null;
      });

      _flutterTts.setErrorHandler((msg) {
        state = state.copyWith(
          state: NarrationState.error,
          errorMessage: msg.toString(),
        );
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('[NarrationCoordinator] Erreur d\'initialisation TTS : $e');
    }
  }

  /// Modifier le débit de lecture du Griot (ex: 0.40 posé, 0.48 normal, 0.58 rapide)
  Future<void> setSpeechRate(double rate) async {
    final clamped = rate.clamp(0.35, 0.70);
    try {
      await _flutterTts.setSpeechRate(clamped);
      state = state.copyWith(speechRate: clamped);
    } catch (_) {}
  }

  /// Démarre ou relance la lecture du texte avec identifiant de contenu optionnel
  Future<void> speak(
    String text, {
    String? contentId,
    VoidCallback? onComplete,
  }) async {
    if (text.trim().isEmpty) return;

    if (!_isInitialized) {
      await _initTts();
    }

    try {
      _currentCompletionCallback = onComplete;
      state = state.copyWith(
        state: NarrationState.speaking,
        currentText: text,
        activeContentId: contentId,
        progress: 0.0,
        errorMessage: null,
      );
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (e) {
      state = state.copyWith(
        state: NarrationState.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Arrête immédiatement la narration
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _currentCompletionCallback = null;
      state = state.copyWith(
        state: NarrationState.idle,
        clearActiveContentId: true,
        progress: 0.0,
      );
    } catch (_) {}
  }

  /// Bascule entre lecture et arrêt pour un texte donné
  Future<void> toggle(
    String text, {
    String? contentId,
    VoidCallback? onComplete,
  }) async {
    if (state.isSpeaking && (contentId == null || state.activeContentId == contentId)) {
      await stop();
    } else {
      await speak(text, contentId: contentId, onComplete: onComplete);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}

/// Provider Riverpod global du coordinateur de narration
final narrationCoordinatorProvider =
    StateNotifierProvider<NarrationCoordinator, NarrationSnapshot>(
  (ref) => NarrationCoordinator(),
);
