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
    required this.seances,
    required this.subjectsProgress,
    this.isLoading = false,
  });

  final String streak;
  final String xp;
  final String seances;
  final Map<String, double> subjectsProgress; // 0.0 to 1.0
  final bool isLoading;

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
    return 0.50; // Progression par défaut réaliste
  }

  GamificationState copyWith({
    String? streak,
    String? xp,
    String? seances,
    Map<String, double>? subjectsProgress,
    bool? isLoading,
  }) {
    return GamificationState(
      streak: streak ?? this.streak,
      xp: xp ?? this.xp,
      seances: seances ?? this.seances,
      subjectsProgress: subjectsProgress ?? this.subjectsProgress,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier(this._ref)
      : super(const GamificationState(
          streak: '12j',
          xp: '3 450',
          seances: '28',
          subjectsProgress: {
            'Sociologie Générale': 0.68,
            'Droit & Institutions': 0.74,
            'Science Politique': 0.52,
            'Histoire-Géographie': 0.80,
            'Économie': 0.62,
            'Philosophie': 0.45,
            'Mathématiques': 0.78,
            'Physique-Chimie': 0.65,
            'Biologie': 0.70,
            'Français': 0.85,
            'Anglais': 0.60,
          },
        )) {
    _loadFromLocalCache();
    fetchStatsFromBackend();
  }

  final Ref _ref;

  static const _prefsKey = 'alternia_gamification_stats_cache';

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
        (data['xp'] != null ? '${data['xp']}' : state.xp);

    final seances = data['seances_label'] as String? ??
        (data['seances'] != null ? '${data['seances']}' : state.seances);

    final rawSubProgress = data['subjects_progress'] as Map<String, dynamic>?;
    final Map<String, double> progressMap = Map.from(state.subjectsProgress);

    if (rawSubProgress != null) {
      for (final entry in rawSubProgress.entries) {
        final val = entry.value;
        if (val is num) {
          // Si le backend renvoie un pourcentage (ex: 75), normaliser entre 0.0 et 1.0
          final normalized = val > 1.0 ? (val / 100.0).clamp(0.0, 1.0) : val.toDouble();
          progressMap[entry.key] = normalized;
        }
      }
    }

    state = state.copyWith(
      streak: streak,
      xp: xp,
      seances: seances,
      subjectsProgress: progressMap,
    );
  }
}

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  return GamificationNotifier(ref);
});
