import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import 'user_prefs_notifier.dart';

class GamificationState {
  const GamificationState({
    required this.streak,
    required this.xp,
    required this.coins,
    required this.seances,
    required this.subjectsProgress,
    this.isLoading = false,
  });

  final String streak;
  final String xp;
  final String coins;
  final String seances;
  final Map<String, double> subjectsProgress; // 0.0 to 1.0
  final bool isLoading;

  int get xpInt {
    final cleaned = xp.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  int get streakInt {
    final cleaned = streak.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  int get coinsInt {
    final cleaned = coins.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  double getProgressForSubject(String subject) {
    // 1. Recherche exacte
    if (subjectsProgress.containsKey(subject)) {
      return subjectsProgress[subject]!;
    }
    // 2. Recherche insensible à la casse ou partielle
    final lower = subject.toLowerCase().trim();
    for (final entry in subjectsProgress.entries) {
      final keyLower = entry.key.toLowerCase().trim();
      if (keyLower.contains(lower) || lower.contains(keyLower)) {
        return entry.value;
      }
    }
    return 0.0; // Progression par défaut à zéro au premier lancement
  }

  GamificationState copyWith({
    String? streak,
    String? xp,
    String? coins,
    String? seances,
    Map<String, double>? subjectsProgress,
    bool? isLoading,
  }) {
    return GamificationState(
      streak: streak ?? this.streak,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      seances: seances ?? this.seances,
      subjectsProgress: subjectsProgress ?? this.subjectsProgress,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier(this._ref)
      : super(const GamificationState(
          streak: '0j',
          xp: '0',
          coins: '0',
          seances: '0',
          subjectsProgress: {},
        )) {
    _loadFromLocalCache();
    fetchStatsFromBackend();
  }

  final Ref _ref;

  static const _prefsKey = 'alternia_gamification_stats_v3';

  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_prefsKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final data = jsonDecode(cachedJson) as Map<String, dynamic>;
        _applyJsonData(data);
      }
    } catch (_) {}
  }

  Future<void> fetchStatsFromBackend() async {
    state = state.copyWith(isLoading: true);
    final userPrefs = _ref.read(userPrefsProvider);
    final dio = Dio();

    for (final url in AltaApiConfig.candidateBaseUrls) {
      try {
        final res = await dio.get(
          '$url/api/apprenants/gamification/stats',
          queryParameters: {
            'eleve_nom': userPrefs.name,
            'classe': userPrefs.studentClassId,
          },
          options: Options(connectTimeout: const Duration(seconds: 3)),
        );

        if (res.statusCode == 200 && res.data is Map) {
          final data = res.data as Map<String, dynamic>;
          _applyJsonData(data);

          // Sauvegarder dans le cache local
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_prefsKey, jsonEncode(data));
          break;
        }
      } catch (_) {}
    }

    if (mounted) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _applyJsonData(Map<String, dynamic> data) {
    final streak = data['streak_label'] as String? ??
        (data['streak'] != null ? '${data['streak']}j' : state.streak);

    final xp = data['xp_label'] as String? ??
        (data['xp'] != null ? _formatNumber(int.tryParse(data['xp'].toString()) ?? 0) : state.xp);

    final coins = data['coins_label'] as String? ??
        (data['coins'] != null ? data['coins'].toString() : state.coins);

    final seances = data['seances_label'] as String? ??
        (data['seances'] != null ? '${data['seances']}' : state.seances);

    final rawSubProgress = data['subjects_progress'] as Map<String, dynamic>?;
    final Map<String, double> progressMap = Map.from(state.subjectsProgress);

    if (rawSubProgress != null) {
      for (final entry in rawSubProgress.entries) {
        final val = entry.value;
        if (val is num) {
          final normalized = val > 1.0 ? (val / 100.0).clamp(0.0, 1.0) : val.toDouble();
          progressMap[entry.key] = normalized;
        }
      }
    }

    state = state.copyWith(
      streak: streak,
      xp: xp,
      coins: coins,
      seances: seances,
      subjectsProgress: progressMap,
    );
  }

  /// Crédite instantanément les récompenses de duel (XP + Pièces AlterniA)
  Future<void> addDuelReward({
    required int xpGained,
    required int coinsGained,
    required String subject,
    required bool won,
  }) async {
    final newXpVal = state.xpInt + xpGained;
    final newCoinsVal = state.coinsInt + coinsGained;

    final progressMap = Map<String, double>.from(state.subjectsProgress);
    final curProg = state.getProgressForSubject(subject);
    progressMap[subject] = (curProg + (won ? 0.05 : 0.02)).clamp(0.0, 1.0);

    state = state.copyWith(
      xp: _formatNumber(newXpVal),
      coins: newCoinsVal.toString(),
      subjectsProgress: progressMap,
    );

    // Persister immédiatement en local
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'streak': state.streak,
        'streak_label': state.streak,
        'xp': newXpVal,
        'xp_label': state.xp,
        'coins': newCoinsVal,
        'coins_label': state.coins,
        'seances': state.seances,
        'seances_label': state.seances,
        'subjects_progress': progressMap,
      };
      await prefs.setString(_prefsKey, jsonEncode(cacheData));
    } catch (_) {}

    // Synchronisation en tâche de fond avec le backend si connecté
    final userPrefs = _ref.read(userPrefsProvider);
    final dio = Dio();
    for (final url in AltaApiConfig.candidateBaseUrls) {
      try {
        await dio.post(
          '$url/api/duel/claim-reward',
          data: {
            'player_name': userPrefs.name.isNotEmpty ? userPrefs.name : 'Élève',
            'subject': subject,
            'player_won': won,
            'score': xpGained,
            'xp_earned': xpGained,
            'coins_earned': coinsGained,
          },
          options: Options(connectTimeout: const Duration(seconds: 2)),
        );
        break;
      } catch (_) {}
    }
  }

  /// Crédite instantanément les récompenses de révision flashcards (XP)
  Future<void> addFlashcardReward({
    required int xpGained,
    required String subject,
  }) async {
    final newXpVal = state.xpInt + xpGained;

    final progressMap = Map<String, double>.from(state.subjectsProgress);
    final curProg = state.getProgressForSubject(subject);
    progressMap[subject] = (curProg + 0.01).clamp(0.0, 1.0);

    state = state.copyWith(
      xp: _formatNumber(newXpVal),
      subjectsProgress: progressMap,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'streak': state.streak,
        'streak_label': state.streak,
        'xp': newXpVal,
        'xp_label': state.xp,
        'coins': state.coins,
        'coins_label': state.coins,
        'seances': state.seances,
        'seances_label': state.seances,
        'subjects_progress': progressMap,
      };
      await prefs.setString(_prefsKey, jsonEncode(cacheData));
    } catch (_) {}
  }

  /// Sauvegarde l'état courant dans le cache SharedPreferences local
  Future<void> _saveLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'streak': state.streak,
        'streak_label': state.streak,
        'xp': state.xpInt,
        'xp_label': state.xp,
        'coins': state.coins,
        'coins_label': state.coins,
        'seances': state.seances,
        'seances_label': state.seances,
        'subjects_progress': state.subjectsProgress,
      };
      await prefs.setString(_prefsKey, jsonEncode(cacheData));
    } catch (_) {}
  }

  /// Crédite instantanément de l'XP au profil global et persiste le cache local
  Future<void> addXp(int xpGained) async {
    final newXpVal = state.xpInt + xpGained;
    state = state.copyWith(
      xp: _formatNumber(newXpVal),
    );
    await _saveLocalCache();
  }

  /// Incrémente le streak de jours consécutifs
  Future<void> incrementStreak([int amount = 1]) async {
    final newStreakVal = state.streakInt + amount;
    state = state.copyWith(
      streak: '${newStreakVal}j',
    );
    await _saveLocalCache();
  }

  /// Réinitialise l'ensemble des métriques de jeu à zéro (utilisé lors de la réinitialisation du profil)
  Future<void> resetStats() async {
    state = const GamificationState(
      streak: '0j',
      xp: '0',
      coins: '0',
      seances: '0',
      subjectsProgress: {},
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (_) {}
  }
}

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  return GamificationNotifier(ref);
});

