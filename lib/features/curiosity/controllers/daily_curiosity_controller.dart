import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/vivienne_tts_service.dart';
import '../../profile/gamification_notifier.dart';
import '../data/datasources/daily_curiosity_catalog.dart';
import '../data/models/daily_curiosity_item.dart';

class DailyCuriosityState {
  final DailyCuriosityItem todayItem;
  final bool isCompletedToday;
  final int? selectedOptionIndex;
  final bool? isCorrect;
  final bool isSpeakingAudio;
  final int streakCount;
  final List<String> unlockedCardIds;
  final int xpEarnedToday;

  const DailyCuriosityState({
    required this.todayItem,
    this.isCompletedToday = false,
    this.selectedOptionIndex,
    this.isCorrect,
    this.isSpeakingAudio = false,
    this.streakCount = 1,
    this.unlockedCardIds = const [],
    this.xpEarnedToday = 0,
  });

  DailyCuriosityState copyWith({
    DailyCuriosityItem? todayItem,
    bool? isCompletedToday,
    int? selectedOptionIndex,
    bool? isCorrect,
    bool? isSpeakingAudio,
    int? streakCount,
    List<String>? unlockedCardIds,
    int? xpEarnedToday,
  }) {
    return DailyCuriosityState(
      todayItem: todayItem ?? this.todayItem,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
      isCorrect: isCorrect ?? this.isCorrect,
      isSpeakingAudio: isSpeakingAudio ?? this.isSpeakingAudio,
      streakCount: streakCount ?? this.streakCount,
      unlockedCardIds: unlockedCardIds ?? this.unlockedCardIds,
      xpEarnedToday: xpEarnedToday ?? this.xpEarnedToday,
    );
  }
}

class DailyCuriosityController extends StateNotifier<DailyCuriosityState> {
  final Ref _ref;

  static const String _prefLastDateKey = 'daily_curiosity_last_date';
  static const String _prefStreakKey = 'daily_curiosity_streak';
  static const String _prefCardsKey = 'daily_curiosity_cards';

  DailyCuriosityController(this._ref)
      : super(DailyCuriosityState(
          todayItem: DailyCuriosityCatalog.getTodayItem(),
        )) {
    _loadState();
  }

  String _formatTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = _formatTodayDate();
      final lastCompletedDate = prefs.getString(_prefLastDateKey);
      final storedStreak = prefs.getInt(_prefStreakKey) ?? 1;
      final storedCards = prefs.getStringList(_prefCardsKey) ?? [];

      final isCompleted = lastCompletedDate == todayStr;

      state = state.copyWith(
        isCompletedToday: isCompleted,
        streakCount: storedStreak,
        unlockedCardIds: storedCards,
        isCorrect: isCompleted ? true : null,
        selectedOptionIndex:
            isCompleted ? state.todayItem.challenge.correctOptionIndex : null,
      );
    } catch (_) {}
  }

  /// Soumet une réponse au micro-défi de 20 secondes
  Future<bool> answerChallenge(int optionIndex) async {
    if (state.isCompletedToday) return true;

    final isRight = optionIndex == state.todayItem.challenge.correctOptionIndex;

    if (isRight) {
      HapticFeedback.heavyImpact();

      final todayStr = _formatTodayDate();
      final prefs = await SharedPreferences.getInstance();
      final currentStreak = (prefs.getInt(_prefStreakKey) ?? 1) + 1;
      final currentCards = (prefs.getStringList(_prefCardsKey) ?? []).toList();

      if (!currentCards.contains(state.todayItem.id)) {
        currentCards.add(state.todayItem.id);
      }

      await prefs.setString(_prefLastDateKey, todayStr);
      await prefs.setInt(_prefStreakKey, currentStreak);
      await prefs.setStringList(_prefCardsKey, currentCards);

      // Créditer l'XP et le streak dans le profil global
      try {
        _ref.read(gamificationProvider.notifier).addXp(state.todayItem.challenge.xpReward);
        _ref.read(gamificationProvider.notifier).incrementStreak();
      } catch (_) {}

      state = state.copyWith(
        selectedOptionIndex: optionIndex,
        isCorrect: true,
        isCompletedToday: true,
        streakCount: currentStreak,
        unlockedCardIds: currentCards,
        xpEarnedToday: state.todayItem.challenge.xpReward,
      );
      return true;
    } else {
      HapticFeedback.vibrate();
      state = state.copyWith(
        selectedOptionIndex: optionIndex,
        isCorrect: false,
      );
      return false;
    }
  }

  /// Lance ou stoppe la lecture audio naturelle par Vivienne
  Future<void> toggleAudioNarration() async {
    if (state.isSpeakingAudio) {
      await stopAudio();
    } else {
      state = state.copyWith(isSpeakingAudio: true);
      HapticFeedback.lightImpact();

      await VivienneTtsService.instance.speak(
        state.todayItem.audioNarrationText,
        onStart: () {
          if (mounted) state = state.copyWith(isSpeakingAudio: true);
        },
        onComplete: () {
          if (mounted) state = state.copyWith(isSpeakingAudio: false);
        },
        onError: (_) {
          if (mounted) state = state.copyWith(isSpeakingAudio: false);
        },
      );
    }
  }

  Future<void> stopAudio() async {
    try {
      VivienneTtsService.instance.stop();
    } catch (_) {}
    if (mounted) {
      state = state.copyWith(isSpeakingAudio: false);
    }
  }

  @override
  void dispose() {
    stopAudio();
    super.dispose();
  }
}

final dailyCuriosityProvider =
    StateNotifierProvider<DailyCuriosityController, DailyCuriosityState>((ref) {
  return DailyCuriosityController(ref);
});
