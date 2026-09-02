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
  final double progress; // De 0.0 à 1.0 (approximatif ou selon étapes)
  final String? errorMessage;

  const NarrationSnapshot({
    this.state = NarrationState.idle,
    this.currentText = '',
    this.progress = 0.0,
    this.errorMessage,
  });

  bool get isSpeaking => state == NarrationState.speaking;
  bool get isIdle => state == NarrationState.idle;
  bool get isCompleted => state == NarrationState.completed;

  NarrationSnapshot copyWith({
    NarrationState? state,
    String? currentText,
    double? progress,
    String? errorMessage,
  }) {
    return NarrationSnapshot(
      state: state ?? this.state,
      currentText: currentText ?? this.currentText,
      progress: progress ?? this.progress,
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
      await _flutterTts.setSpeechRate(0.48);
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

  /// Démarre ou relance la lecture du texte
  Future<void> speak(String text, {VoidCallback? onComplete}) async {
    if (text.trim().isEmpty) return;

    if (!_isInitialized) {
      await _initTts();
    }

    try {
      _currentCompletionCallback = onComplete;
      state = state.copyWith(
        state: NarrationState.speaking,
        currentText: text,
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
        progress: 0.0,
      );
    } catch (_) {}
  }

  /// Bascule entre lecture et arrêt
  Future<void> toggle(String text, {VoidCallback? onComplete}) async {
    if (state.isSpeaking) {
      await stop();
    } else {
      await speak(text, onComplete: onComplete);
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
    StateNotifierProvider.autoDispose<NarrationCoordinator, NarrationSnapshot>(
  (ref) => NarrationCoordinator(),
);
