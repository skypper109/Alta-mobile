import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dio/dio.dart';
import '../../../../core/constants.dart';
import '../../../profile/user_prefs_notifier.dart';
import '../datasources/culture_api_client.dart';
import '../models/culture_passport_models.dart';
import '../theme/culture_theme.dart';

/// Notifier du Passeport Culturel & Parcours gérant la mémoire de l'odyssée
/// Entièrement connecté : profil utilisateur dynamique, persistance locale SharedPreferences,
/// synchronisation bi-directionnelle avec l'API backend CultureLens et calcul d'XP réel.
class CulturePassportNotifier extends StateNotifier<PassportState> {
  final Ref _ref;
  final CultureApiClient _apiClient;

  static const String _prefEntriesKey = 'culture_passport_entries_v4';
  static const String _prefIssuedAtKey = 'culture_passport_issued_at_v4';

  CulturePassportNotifier(this._ref, {CultureApiClient? apiClient})
      : _apiClient = apiClient ?? CultureApiClient(),
        super(_createInitialState(_ref)) {
    _initAndSync();
    _listenToUserChanges();
  }

  String get _currentTravelerName {
    final prefs = _ref.read(userPrefsProvider);
    return prefs.name.trim().isNotEmpty ? prefs.name.trim() : 'Explorateur Alternia';
  }

  String get _currentPassportNumber {
    final prefs = _ref.read(userPrefsProvider);
    return _generatePassportNumber(prefs);
  }

  static String _generatePassportNumber(UserProfileState prefs) {
    final raw = prefs.name.isNotEmpty ? prefs.name : prefs.studentClassId;
    if (raw.trim().isEmpty) return 'ML-ALT-2026-08';
    final hash = raw.codeUnits.fold<int>(0, (acc, c) => (acc * 31 + c) & 0xFFFFFF);
    final numStr = hash.toString().padLeft(6, '0');
    return 'ML-ALT-2026-${numStr.substring(numStr.length - 6)}';
  }

  static List<String> _computeExploredRegions(List<PassportEntry> entries) {
    final regions = <String>{};
    for (final e in entries) {
      if (e.regionId != null && e.regionId!.trim().isNotEmpty) {
        regions.add(e.regionId!.trim());
      }
    }
    return regions.toList();
  }

  static PassportState _createInitialState(Ref ref) {
    final prefs = ref.read(userPrefsProvider);
    final travelerName = prefs.name.trim().isNotEmpty ? prefs.name.trim() : 'Explorateur Alternia';
    final passportNum = _generatePassportNumber(prefs);

    return PassportState(
      travelerName: travelerName,
      passportNumber: passportNum,
      issuedAt: DateTime.now(),
      entries: const [],
      exploredRegionIds: const [],
      featuredDiscoveryOfTheDay: _defaultFeaturedDiscovery,
    );
  }

  void _listenToUserChanges() {
    _ref.listen<UserProfileState>(userPrefsProvider, (prev, next) {
      final newName = next.name.trim().isNotEmpty ? next.name.trim() : 'Explorateur Alternia';
      final newPassportNum = _generatePassportNumber(next);
      if (state.travelerName != newName || state.passportNumber != newPassportNum) {
        state = PassportState(
          travelerName: newName,
          passportNumber: newPassportNum,
          issuedAt: state.issuedAt,
          entries: state.entries,
          exploredRegionIds: state.exploredRegionIds,
          featuredDiscoveryOfTheDay: state.featuredDiscoveryOfTheDay,
          bonusCultureXp: state.bonusCultureXp,
          bonusCultureCoins: state.bonusCultureCoins,
        );
      }
    });
  }

  Future<void> _initAndSync() async {
    await _loadFromLocal();
    await syncWithBackend();
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_prefEntriesKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        final decoded = jsonDecode(savedJson) as List<dynamic>;
        final loaded = decoded
            .whereType<Map<String, dynamic>>()
            .map((item) => PassportEntry.fromJson(item))
            .toList();

        if (loaded.isNotEmpty) {
          final issuedAtStr = prefs.getString(_prefIssuedAtKey);
          final issuedAt = issuedAtStr != null
              ? DateTime.tryParse(issuedAtStr) ?? state.issuedAt
              : state.issuedAt;

          state = PassportState(
            travelerName: _currentTravelerName,
            passportNumber: _currentPassportNumber,
            issuedAt: issuedAt,
            entries: loaded,
            exploredRegionIds: _computeExploredRegions(loaded),
            featuredDiscoveryOfTheDay: loaded.firstWhere(
              (e) =>
                  e.type == PassportItemType.personnage ||
                  e.type == PassportItemType.monument,
              orElse: () => _defaultFeaturedDiscovery,
            ),
            bonusCultureXp: state.bonusCultureXp,
            bonusCultureCoins: state.bonusCultureCoins,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _saveToLocal(List<PassportEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized = entries.map((e) => e.toJson()).toList();
      await prefs.setString(_prefEntriesKey, jsonEncode(serialized));
      await prefs.setString(_prefIssuedAtKey, state.issuedAt.toIso8601String());
    } catch (_) {}
  }

  /// Synchronise les récompenses culturelles validées sur le backend (contributions citoyennes)
  Future<void> syncWithBackend() async {
    try {
      final userPrefs = _ref.read(userPrefsProvider);
      if (userPrefs.name.trim().isEmpty) return;

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
          if (res.statusCode == 200 && res.data is Map) {
            final data = Map<String, dynamic>.from(res.data as Map);
            if (data['culture'] is Map) {
              final cultureMap = Map<String, dynamic>.from(data['culture'] as Map);
              final remoteCultureXp = (cultureMap['xp'] as num?)?.toInt() ?? 0;
              final remoteCultureCoins = (cultureMap['coins'] as num?)?.toInt() ?? 0;
              if (mounted) {
                state = PassportState(
                  travelerName: _currentTravelerName,
                  passportNumber: _currentPassportNumber,
                  issuedAt: state.issuedAt,
                  entries: state.entries,
                  exploredRegionIds: state.exploredRegionIds,
                  featuredDiscoveryOfTheDay: state.featuredDiscoveryOfTheDay,
                  bonusCultureXp: remoteCultureXp,
                  bonusCultureCoins: remoteCultureCoins,
                );
              }
            }
            break;
          }
        } catch (_) {}
      }
    } catch (_) {}
  }

  static final PassportEntry _defaultFeaturedDiscovery = PassportEntry(
    id: 'perso_soundiata',
    type: PassportItemType.personnage,
    title: 'Soundiata Keïta',
    subtitle: 'Le Lion du Manden & Proclamateur de la Charte de 1236',
    regionId: 'koulikoro',
    regionName: 'Koulikoro',
    photoUrl: 'assets/images/culture/personnages/soundiata.jpg',
    tag: 'Mansa Bâtisseur',
    discoveredAt: DateTime.now().subtract(const Duration(hours: 18)),
    culturalQuote:
        '« Toute vie humaine est une vie. Un tort causé à une vie exige réparation. »',
    isMilestone: true,
    milestoneLabel: 'Première figure historique découverte',
    targetRoute: '/culture/personnage/perso_soundiata',
    xpEarned: 50,
  );

  /// Enregistre une découverte de manière idempotente dans le Passeport,
  /// la persiste localement et la soumet au serveur central
  bool recordDiscovery({
    required String id,
    required PassportItemType type,
    required String title,
    required String subtitle,
    String? regionId,
    required String regionName,
    required String photoUrl,
    required String tag,
    String? culturalQuote,
    required String targetRoute,
    bool isMilestone = false,
    String? milestoneLabel,
    int xpEarned = 50,
    int coinsEarned = 15,
  }) {
    final existingIndex =
        state.entries.indexWhere((e) => e.type == type && e.id == id);
    if (existingIndex != -1) {
      return false;
    }

    final bool firstOfType = !state.entries.any((e) => e.type == type);
    final String? resolvedMilestone = milestoneLabel ??
        (firstOfType
            ? 'Premier(ère) ${type.label.toLowerCase()} maîtrisé(e)'
            : null);

    final newEntry = PassportEntry(
      id: id,
      type: type,
      title: title,
      subtitle: subtitle,
      regionId: regionId,
      regionName: regionName,
      photoUrl: photoUrl,
      tag: tag,
      discoveredAt: DateTime.now(),
      culturalQuote: culturalQuote,
      isMilestone: isMilestone || firstOfType,
      milestoneLabel: resolvedMilestone,
      targetRoute: targetRoute,
      xpEarned: xpEarned,
      coinsEarned: coinsEarned,
    );

    final updatedEntries = [newEntry, ...state.entries];
    final updatedRegions = _computeExploredRegions(updatedEntries);

    state = PassportState(
      travelerName: _currentTravelerName,
      passportNumber: _currentPassportNumber,
      issuedAt: state.issuedAt,
      entries: updatedEntries,
      exploredRegionIds: updatedRegions,
      featuredDiscoveryOfTheDay: (newEntry.targetRoute.isNotEmpty &&
              !newEntry.targetRoute.contains('passport') &&
              newEntry.type != PassportItemType.defi)
          ? newEntry
          : (state.featuredDiscoveryOfTheDay ?? _defaultFeaturedDiscovery),
      bonusCultureXp: state.bonusCultureXp,
      bonusCultureCoins: state.bonusCultureCoins,
    );

    // 1. Sauvegarde locale persistante (strictement dans l'espace Culture)
    unawaited(_saveToLocal(updatedEntries));

    // 2. Synchronisation backend CultureLens
    if (type == PassportItemType.monument || type == PassportItemType.ville) {
      final userPrefs = _ref.read(userPrefsProvider);
      unawaited(_apiClient.recordDiscovery(
        monumentId: id,
        studentId: userPrefs.name.isNotEmpty ? userPrefs.name : null,
        confidence: 0.98,
        notes: 'Maîtrisé par Défi Quiz et inscrit au Passeport Culturel ($title)',
      ));
    }

    return true;
  }

  /// Réinitialise le passeport culturel à zéro (efface les tampons locaux)
  Future<void> resetPassport() async {
    state = _createInitialState(_ref);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefEntriesKey);
      await prefs.remove(_prefIssuedAtKey);
      await prefs.remove('culture_passport_entries_v2');
      await prefs.remove('culture_passport_issued_at_v2');
    } catch (_) {}
  }

  /// Liste des distinctions culturelles calculées dynamiquement
  List<CulturalDistinction> get distinctions {
    final monumentCount = state.monuments.length;
    final conteCount = state.contes.length;
    final figureCount = state.figures.length;
    final regionCount = state.exploredRegionIds.length;
    final defiCount = state.defis.length;

    return [
      CulturalDistinction(
        id: 'explorateur_monuments',
        title: 'Gardien des Pierres & du Banco',
        subtitle: 'Explorateur des édifices sacrés du Mali',
        description:
            'A foulé et contemplé au moins 2 monuments historiques séculaires.',
        icon: Icons.account_balance_rounded,
        sealColor: CultureTheme.primaryBlue,
        isUnlocked: monumentCount >= 2,
        requirementText: '$monumentCount/2 monuments explorés',
        unlockedAt: monumentCount >= 2
            ? state.issuedAt.add(const Duration(days: 4))
            : null,
      ),
      CulturalDistinction(
        id: 'conteur_veillees',
        title: 'Mémoire des Veillées',
        subtitle: 'Gardien de la tradition orale',
        description: 'A écouté et intégré les sagesses et fables de la savane.',
        icon: Icons.auto_stories_rounded,
        sealColor: CultureTheme.accentOrange,
        isUnlocked: conteCount >= 1,
        requirementText: '$conteCount/1 conte achevé',
        unlockedAt: conteCount >= 1
            ? state.issuedAt.add(const Duration(days: 7))
            : null,
      ),
      CulturalDistinction(
        id: 'historien_manden',
        title: 'Chroniqueur des Mansa',
        subtitle: 'Connaisseur des grandes dynasties',
        description:
            'A exploré les récits des bâtisseurs et héros de la nation malienne.',
        icon: Icons.history_edu_rounded,
        sealColor: CultureTheme.primaryBlue,
        isUnlocked: figureCount >= 3,
        requirementText: '$figureCount/3 grandes figures inscrites',
        unlockedAt: figureCount >= 3
            ? state.issuedAt.add(const Duration(days: 8))
            : null,
      ),
      CulturalDistinction(
        id: 'sage_enigmes',
        title: 'Initié aux Devinettes',
        subtitle: 'Maître des énigmes de la sagesse populaire',
        description:
            'A résolu avec sagacité les énigmes ancestrales du Djoliba.',
        icon: Icons.psychology_rounded,
        sealColor: CultureTheme.accentOrange,
        isUnlocked: defiCount >= 1,
        requirementText: '$defiCount/1 défi relevé',
        unlockedAt: defiCount >= 1
            ? state.issuedAt.add(const Duration(days: 11))
            : null,
      ),
      CulturalDistinction(
        id: 'decouvreur_mali',
        title: 'Grand Voyageur du Sahel',
        subtitle: 'Explorateur des terres et cités du Mali',
        description:
            'A parcouru au moins 4 grandes régions culturelles du pays.',
        icon: Icons.explore_rounded,
        sealColor: CultureTheme.cyanTurquoise,
        isUnlocked: regionCount >= 4,
        requirementText: '$regionCount/4 régions explorées',
        unlockedAt: regionCount >= 4
            ? state.issuedAt.add(const Duration(days: 12))
            : null,
      ),
    ];
  }
}

/// Provider Riverpod global du Passeport Culturel (dynamique)
final culturePassportProvider =
    StateNotifierProvider<CulturePassportNotifier, PassportState>((ref) {
  return CulturePassportNotifier(ref);
});
