import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/culture_passport_models.dart';
import '../theme/culture_theme.dart';

/// Notifier du Passeport Culturel gérant la mémoire de l'odyssée
class CulturePassportNotifier extends StateNotifier<PassportState> {
  CulturePassportNotifier()
      : super(
          PassportState(
            travelerName: 'Explorateur Alternia',
            passportNumber: 'ML-ALT-2026-08',
            issuedAt: DateTime.now().subtract(const Duration(days: 14)),
            entries: _initialDiscoveries,
            exploredRegionIds: const ['koulikoro', 'tombouctou', 'sikasso', 'mopti'],
            featuredDiscoveryOfTheDay: _defaultFeaturedDiscovery,
          ),
        );

  static final PassportEntry _defaultFeaturedDiscovery = PassportEntry(
    id: 'monument_djingareyber',
    type: PassportItemType.monument,
    title: 'Mosquée Djingareyber',
    subtitle: 'Chef-d\'œuvre architectural de Tombouctou érigé par Mansa Moussa',
    regionId: 'tombouctou',
    regionName: 'Tombouctou',
    photoUrl: 'assets/images/culture/monuments/mosquee_djingareyber.jpg',
    tag: 'Patrimoine Mondial',
    discoveredAt: DateTime.now().subtract(const Duration(hours: 18)),
    culturalQuote: '« Bâtie en 1327 par Abou Ishaq es-Sahéli avec les offrandes d\'or de Mansa Moussa. »',
    isMilestone: true,
    milestoneLabel: 'Premier monument du Nord exploré',
    targetRoute: '/culture/monument/monument_djingareyber',
  );

  static final List<PassportEntry> _initialDiscoveries = [
    // 1. Figures
    PassportEntry(
      id: 'perso_soundiata',
      type: PassportItemType.personnage,
      title: 'Soundiata Keïta',
      subtitle: 'Le Lion du Manden & Proclamateur de la Charte de 1236',
      regionId: 'koulikoro',
      regionName: 'Koulikoro',
      photoUrl: 'assets/images/culture/personnages/soundiata.jpg',
      tag: 'Mansa Bâtisseur',
      discoveredAt: DateTime.now().subtract(const Duration(days: 12)),
      culturalQuote: '« Toute vie humaine est une vie. Un tort causé à une vie exige réparation. »',
      isMilestone: true,
      milestoneLabel: 'Première figure historique découverte',
      targetRoute: '/culture/personnage/perso_soundiata',
    ),
    PassportEntry(
      id: 'perso_mansa_moussa',
      type: PassportItemType.personnage,
      title: 'Mansa Moussa',
      subtitle: 'L\'Empereur d\'Or & Mécène du Savoir Universel',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      photoUrl: 'assets/images/culture/personnages/mansa_moussa.jpg',
      tag: 'Âge d\'Or',
      discoveredAt: DateTime.now().subtract(const Duration(days: 9)),
      culturalQuote: '« Il fit rayonner les universités du Mali jusqu\'aux confins du monde méditerranéen. »',
      targetRoute: '/culture/personnage/perso_mansa_moussa',
    ),
    PassportEntry(
      id: 'perso_babemba',
      type: PassportItemType.personnage,
      title: 'Babemba Traoré',
      subtitle: 'Roi du Kénédougou & Héros du Tata',
      regionId: 'sikasso',
      regionName: 'Sikasso',
      photoUrl: 'assets/images/culture/personnages/babemba_traore.jpg',
      tag: 'Résistance',
      discoveredAt: DateTime.now().subtract(const Duration(days: 6)),
      culturalQuote: '« Sayi té Maloya Sa (Plutôt la mort que la honte). »',
      targetRoute: '/culture/personnage/perso_babemba',
    ),

    // 2. Monuments
    PassportEntry(
      id: 'monument_djingareyber',
      type: PassportItemType.monument,
      title: 'Mosquée Djingareyber',
      subtitle: 'Sanctuaire d\'argile et de savoir de Tombouctou',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      photoUrl: 'assets/images/culture/monuments/mosquee_djingareyber.jpg',
      tag: 'Joyau UNESCO',
      discoveredAt: DateTime.now().subtract(const Duration(days: 10)),
      culturalQuote: '« Un lieu où la prière et la science se rencontrent depuis sept siècles. »',
      isMilestone: true,
      milestoneLabel: 'Premier monument historique exploré',
      targetRoute: '/culture/monument/monument_djingareyber',
    ),
    PassportEntry(
      id: 'monument_djenne',
      type: PassportItemType.monument,
      title: 'Grande Mosquée de Djenné',
      subtitle: 'Plus grand édifice en terre crue (banco) au monde',
      regionId: 'mopti',
      regionName: 'Mopti',
      photoUrl: 'assets/images/culture/monuments/mosquee_djenne.jpg',
      tag: 'Architecture Banco',
      discoveredAt: DateTime.now().subtract(const Duration(days: 4)),
      culturalQuote: '« Chaque année, la fête du Crépissage rassemble toute la communauté du Djoliba. »',
      targetRoute: '/culture/monument/monument_djenne',
    ),

    // 3. Villes
    PassportEntry(
      id: 'ville_djenne',
      type: PassportItemType.ville,
      title: 'Djenné',
      subtitle: 'La Cité Millénaire du Banco & de la Fraternité',
      regionId: 'mopti',
      regionName: 'Mopti',
      photoUrl: 'assets/images/culture/villes/djenne_ville.jpg',
      tag: 'Cité d\'Art',
      discoveredAt: DateTime.now().subtract(const Duration(days: 8)),
      culturalQuote: '« Berceau des bâtisseurs maçons Barey et du carrefour fluvial du Bani. »',
      targetRoute: '/culture/ville/ville_djenne',
    ),
    PassportEntry(
      id: 'ville_sikasso',
      type: PassportItemType.ville,
      title: 'Sikasso',
      subtitle: 'La Cité du Kénédougou & Verger du Mali',
      regionId: 'sikasso',
      regionName: 'Sikasso',
      photoUrl: 'assets/images/culture/villes/sikasso_ville.jpg',
      tag: 'Capitale du Sud',
      discoveredAt: DateTime.now().subtract(const Duration(days: 5)),
      culturalQuote: '« Terre fertile, remparts de mémoire et carrefour des rythmes Balafon. »',
      targetRoute: '/culture/ville/ville_sikasso',
    ),

    // 4. Contes
    PassportEntry(
      id: 'conte_lievre_hyene',
      type: PassportItemType.conte,
      title: 'Zoumana le Lièvre et Namori l\'Hyène',
      subtitle: 'La ruse de l\'esprit face à la cupidité de la force',
      regionId: null,
      regionName: 'Tout le Mali',
      photoUrl: 'assets/images/culture/villes/djenne_ville.jpg',
      tag: 'Fable Mandingue',
      discoveredAt: DateTime.now().subtract(const Duration(days: 7)),
      culturalQuote: '« La sagesse et la mesure triomphent toujours de la force aveugle. »',
      isMilestone: true,
      milestoneLabel: 'Premier conte et sagesse achevés',
      targetRoute: '/culture/conte/conte_lievre_hyene',
    ),

    // 5. Défis
    PassportEntry(
      id: 'riddle_vent',
      type: PassportItemType.defi,
      title: 'Devinette N\'Da : Le Vent (Fonyo)',
      subtitle: 'Je voyage sans jambes et parle sans bouche...',
      regionId: null,
      regionName: 'Tout le Mali',
      photoUrl: 'assets/images/culture/villes/bandiagara_falaise.jpg',
      tag: 'Devinette N\'Da',
      discoveredAt: DateTime.now().subtract(const Duration(days: 3)),
      culturalQuote: '« Le vent ne brise jamais l\'herbe qui sait se courber avec humilité. »',
      isMilestone: true,
      milestoneLabel: 'Première énigme traditionnelle résolue',
      targetRoute: '/culture/defis/devinettes',
    ),
  ];

  /// Enregistre une découverte de manière idempotente dans le Passeport
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
  }) {
    final existingIndex = state.entries.indexWhere((e) => e.type == type && e.id == id);
    if (existingIndex != -1) {
      // Déjà découvert
      return false;
    }

    // Détection automatique de milestone si premier élément du genre
    final bool firstOfType = !state.entries.any((e) => e.type == type);
    final String? resolvedMilestone = milestoneLabel ??
        (firstOfType ? 'Premier(ère) ${type.label.toLowerCase()} découvert(e)' : null);

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
    );

    final updatedRegions = List<String>.from(state.exploredRegionIds);
    if (regionId != null && !updatedRegions.contains(regionId)) {
      updatedRegions.add(regionId);
    }

    state = PassportState(
      travelerName: state.travelerName,
      passportNumber: state.passportNumber,
      issuedAt: state.issuedAt,
      entries: [newEntry, ...state.entries],
      exploredRegionIds: updatedRegions,
      featuredDiscoveryOfTheDay: newEntry,
    );

    return true;
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
        description: 'A foulé et contemplé au moins 2 monuments historiques séculaires.',
        icon: Icons.account_balance_rounded,
        sealColor: CultureTheme.primaryBlue,
        isUnlocked: monumentCount >= 2,
        requirementText: '$monumentCount/2 monuments explorés',
        unlockedAt: monumentCount >= 2 ? state.issuedAt.add(const Duration(days: 4)) : null,
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
        unlockedAt: conteCount >= 1 ? state.issuedAt.add(const Duration(days: 7)) : null,
      ),
      CulturalDistinction(
        id: 'historien_manden',
        title: 'Chroniqueur des Mansa',
        subtitle: 'Connaisseur des grandes dynasties',
        description: 'A exploré les récits des bâtisseurs et héros de la nation malienne.',
        icon: Icons.history_edu_rounded,
        sealColor: const Color(0xFF8B5CF6),
        isUnlocked: figureCount >= 3,
        requirementText: '$figureCount/3 grandes figures inscrites',
        unlockedAt: figureCount >= 3 ? state.issuedAt.add(const Duration(days: 8)) : null,
      ),
      CulturalDistinction(
        id: 'sage_enigmes',
        title: 'Initié aux Devinettes N\'Da',
        subtitle: 'Maître des énigmes de la sagesse populaire',
        description: 'A résolu avec sagacité les énigmes ancestrales du Djoliba.',
        icon: Icons.psychology_rounded,
        sealColor: CultureTheme.vertNaturel,
        isUnlocked: defiCount >= 1,
        requirementText: '$defiCount/1 défi relevé',
        unlockedAt: defiCount >= 1 ? state.issuedAt.add(const Duration(days: 11)) : null,
      ),
      CulturalDistinction(
        id: 'decouvreur_mali',
        title: 'Grand Voyageur du Sahel',
        subtitle: 'Explorateur des terres et cités du Mali',
        description: 'A parcouru au moins 4 grandes régions culturelles du pays.',
        icon: Icons.explore_rounded,
        sealColor: CultureTheme.cyanTurquoise,
        isUnlocked: regionCount >= 4,
        requirementText: '$regionCount/4 régions explorées',
        unlockedAt: regionCount >= 4 ? state.issuedAt.add(const Duration(days: 12)) : null,
      ),
    ];
  }
}

/// Provider Riverpod global du Passeport Culturel
final culturePassportProvider =
    StateNotifierProvider<CulturePassportNotifier, PassportState>((ref) {
  return CulturePassportNotifier();
});
