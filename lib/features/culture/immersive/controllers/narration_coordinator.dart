import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/vivienne_tts_service.dart';

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
    this.speechRate = VivienneTtsService.vivienneSpeechRate,
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

/// Coordinateur centralisé pour la voix Neurale Vivienne (AlternIA)
class NarrationCoordinator extends StateNotifier<NarrationSnapshot> {
  final VivienneTtsService _vivienneTts = VivienneTtsService.instance;
  VoidCallback? _currentCompletionCallback;

  NarrationCoordinator() : super(const NarrationSnapshot());

  /// Modifier le débit de lecture
  Future<void> setSpeechRate(double rate) async {
    final clamped = rate.clamp(0.35, 0.70);
    state = state.copyWith(speechRate: clamped);
  }

  /// Démarre ou relance la lecture du texte avec la voix Neurale Vivienne
  Future<void> speak(
    String text, {
    String? contentId,
    VoidCallback? onComplete,
  }) async {
    if (text.trim().isEmpty) return;

    try {
      _currentCompletionCallback = onComplete;
      state = state.copyWith(
        state: NarrationState.speaking,
        currentText: text,
        activeContentId: contentId,
        progress: 0.0,
        errorMessage: null,
      );

      await _vivienneTts.speak(
        text,
        onStart: () {
          state = state.copyWith(state: NarrationState.speaking);
        },
        onComplete: () {
          state = state.copyWith(
            state: NarrationState.completed,
            progress: 1.0,
          );
          _currentCompletionCallback?.call();
          _currentCompletionCallback = null;
        },
        onError: (err) {
          state = state.copyWith(
            state: NarrationState.error,
            errorMessage: err.toString(),
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        state: NarrationState.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Arrête immédiatement la narration Vivienne
  Future<void> stop() async {
    try {
      await _vivienneTts.stop();
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
    _vivienneTts.stop();
    super.dispose();
  }
}

/// Provider Riverpod global du coordinateur de narration
final narrationCoordinatorProvider =
    StateNotifierProvider<NarrationCoordinator, NarrationSnapshot>(
  (ref) => NarrationCoordinator(),
);
