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
          streak: '1j',
          xp: '0',
          coins: '0',
          seances: '0',
          subjectsProgress: {},
        )) {
    _initStats();
  }

  final Ref _ref;
  int _requestToken = 0;

  static const _prefsKey = 'alternia_gamification_stats_v5';

  static String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  Future<void> _initStats() async {
    await _loadFromLocalCache();
    await fetchStatsFromBackend();
  }

  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Nettoyage de l'ancien cache v3 potentiellement pollué par les données de démo
      if (prefs.containsKey('alternia_gamification_stats_v3')) {
        await prefs.remove('alternia_gamification_stats_v3');
      }
      final cachedJson = prefs.getString(_prefsKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final data = jsonDecode(cachedJson) as Map<String, dynamic>;
        _applyJsonData(data);
      }
    } catch (_) {}
  }

  Future<void> fetchStatsFromBackend() async {
    final userPrefs = _ref.read(userPrefsProvider);
    if (userPrefs.name.trim().isEmpty || !userPrefs.hasSelectedClass) {
      return;
    }

    final currentToken = ++_requestToken;
    state = state.copyWith(isLoading: true);
    final dio = Dio();

    for (final url in AltaApiConfig.candidateBaseUrls) {
      try {
        final res = await dio.get(
          '$url/api/apprenants/gamification/stats',
          queryParameters: {
            'eleve_nom': userPrefs.name.trim(),
            'classe': userPrefs.studentClassId.trim(),
          },
          options: Options(connectTimeout: const Duration(seconds: 3)),
        );

        // Si resetStats() ou une autre requête a été lancée entre-temps, on ignore cette réponse
        if (!mounted || currentToken != _requestToken) return;

        if (res.statusCode == 200 && res.data is Map) {
          final data = Map<String, dynamic>.from(res.data as Map);

          // Protection contre l'ancienne API distante (api.alterniamali.com) non mise à jour
          // qui renvoie les stats de démo (12j, 21 900 XP, 240 pièces, 24 séances) pour tout nouvel inscrit.
          final remoteXp = int.tryParse(data['xp']?.toString() ?? '0') ?? 0;
          final remoteStreak = int.tryParse(data['streak']?.toString() ?? '1') ?? 1;
          final remoteSeances = int.tryParse(data['seances']?.toString() ?? '0') ?? 0;
          final remoteCoins = int.tryParse(data['coins']?.toString() ?? '0') ?? 0;

          final isLegacyDemoFallback = !data.containsKey('valeur_fcfa') ||
              (state.xpInt == 0 &&
                  state.seances == '0' &&
                  (remoteXp >= 3450 || remoteStreak >= 12 || remoteSeances >= 24));

          if (isLegacyDemoFallback) {
            break;
          }

          // Si le compte est neuf (0 XP, 0 séance) mais que le serveur renvoie l'ancien bonus de 240 pièces par défaut
          if (remoteXp == 0 && remoteSeances == 0 && remoteCoins == 240 && state.coinsInt == 0) {
            data['coins'] = 0;
            data['coins_label'] = '0';
          }

          _applyJsonData(data);

          // Sauvegarder dans le cache local
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_prefsKey, jsonEncode(data));
          break;
        }
      } catch (_) {}
    }

    if (mounted && currentToken == _requestToken) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _applyJsonData(Map<String, dynamic> data) {
    // Séparation stricte : l'état GamificationNotifier ne lit que les métriques Éducation
    final eduSource = data['education'] is Map
        ? Map<String, dynamic>.from(data['education'] as Map)
        : data;

    final streak = eduSource['streak_label'] as String? ??
        (eduSource['streak'] != null ? '${eduSource['streak']}j' : state.streak);

    final xp = eduSource['xp_label'] as String? ??
        (eduSource['xp'] != null ? _formatNumber(int.tryParse(eduSource['xp'].toString()) ?? 0) : state.xp);

    final coins = eduSource['coins_label'] as String? ??
        (eduSource['coins'] != null ? eduSource['coins'].toString() : state.coins);

    final seances = eduSource['seances_label'] as String? ??
        (eduSource['seances'] != null ? '${eduSource['seances']}' : state.seances);

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
    _requestToken++;
    state = const GamificationState(
      streak: '1j',
      xp: '0',
      coins: '0',
      seances: '0',
      subjectsProgress: {},
      isLoading: false,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      await prefs.remove('alternia_gamification_stats_v3');
    } catch (_) {}
  }
}

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  return GamificationNotifier(ref);
});

