import 'package:flutter/material.dart';
import 'culture_detail_models.dart';

/// Une étape de la visite guidée d'un monument historique
class MonumentTourStep {
  final int stepNumber;
  final String title;
  final String subtitle;
  final String photoUrl;
  final String locationBadge;
  final String guideSpeech;
  final String observationClue;
  final String? architecturalDetail;
  final IconData stepIcon;

  const MonumentTourStep({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.photoUrl,
    required this.locationBadge,
    required this.guideSpeech,
    required this.observationClue,
    this.architecturalDetail,
    this.stepIcon = Icons.tour_rounded,
  });
}

/// Ensemble du parcours de visite guidée d'un monument
class MonumentGuidedTour {
  final String monumentId;
  final String monumentName;
  final String guideName;
  final String guideRole;
  final String totalDurationEstimated;
  final List<MonumentTourStep> steps;

  const MonumentGuidedTour({
    required this.monumentId,
    required this.monumentName,
    required this.guideName,
    required this.guideRole,
    required this.totalDurationEstimated,
    required this.steps,
  });
}

/// Registre des visites guidées immersives pas-à-pas pour les monuments du Mali
abstract final class MonumentGuidedTourRegistry {
  /// Récupère le parcours de visite guidée pas-à-pas d'un monument
  static MonumentGuidedTour getTourForMonument(MonumentDetail monument) {
    final id = monument.id.toLowerCase();

    // ── 1. VISITE GUIDÉE DE LA GRANDE MOSQUÉE DE DJENNÉ ─────────────────────
    if (id.contains('djenne')) {
      return MonumentGuidedTour(
        monumentId: monument.id,
        monumentName: 'Grande Mosquée de Djenné',
        guideName: 'Maître Ousmane Barey',
        guideRole: 'Doyen des Barey Ton (Corporation des Maçons)',
        totalDurationEstimated: '6 min de visite guidée',
        steps: const [
          MonumentTourStep(
            stepNumber: 1,
            title: 'Le Parvis & L\'Écrin du Grand Marché',
            subtitle: 'Point de départ de l\'expédition',
            photoUrl:
                'assets/images/culture/monuments/monument_mosquee_djenne/dje_1.webp',
            locationBadge: 'Station 1 • Place du Grand Marché de Djenné',
            guideSpeech:
                'Arrêtez-vous un instant sur cette immense place de terre battue. Vous contemplez le plus grand édifice en terre crue au monde. Érigée au XIIIe siècle par le roi Koy Komboro après sa conversion, puis reconstruite à l\'identique en 1907 par notre guilde, cette mosquée est l\'âme vivante de notre cité millénaire.',
            observationClue:
                'Observez la couleur ocre-dorée : c\'est le banco originel, mélange sacré d\'argile fine du Bani, de balle de riz et de beurre de karité séché au soleil.',
            architecturalDetail:
                'Matériau 100% bio-climatique issu du fleuve Bani, sans aucun apport de ciment.',
            stepIcon: Icons.explore_rounded,
          ),
          MonumentTourStep(
            stepNumber: 2,
            title: 'Au Pied des Murs & Les Torons de Rônier',
            subtitle: 'Le génie de l\'échafaudage permanent',
            photoUrl:
                'assets/images/culture/monuments/monument_mosquee_djenne/dje_6.jpg',
            locationBadge: 'Station 2 • Façade Orientale & Contreforts',
            guideSpeech:
                'Approchons-nous des façades. Levez les yeux vers ces madriers qui hérissent la muraille : ce sont les torons, taillés dans le bois de palmier rônier. Ce bois a la particularité unique de ne jamais pourrir et d\'être totalement insensible aux termites.',
            observationClue:
                'Ces poutres saillantes servent d\'échafaudages naturels permanents. Lors de la fête annuelle du crépissage, des milliers de jeunes hommes les escaladent pour réenduire les murs à mains nues.',
            architecturalDetail:
                'Les torons amortissent également les secousses sismiques et les dilatations thermiques du Sahel.',
            stepIcon: Icons.carpenter_rounded,
          ),
          MonumentTourStep(
            stepNumber: 3,
            title: 'Les Trois Minarets & Les Œufs Sacrés',
            subtitle: 'Le regard levé vers le ciel sahélien',
            photoUrl:
                'assets/images/culture/monuments/monument_mosquee_djenne/dje_2.webp',
            locationBadge: 'Station 3 • Faîte des Trois Minarets',
            guideSpeech:
                'Regardez à 16 mètres de haut. La façade est couronnée par trois grands minarets coniques crénelés. Au sommet de chacun d\'eux brille un véritable œuf d\'autruche blanc poli.',
            observationClue:
                'Dans notre tradition sahélienne, l\'œuf d\'autruche symbolise la pureté sacrée, la fertilité de la terre et la protection divine contre la foudre.',
            architecturalDetail:
                'Les gargouilles tubulaires en poterie évacuent les pluies diluviennes d\'hivernage loin des parois d\'argile.',
            stepIcon: Icons.egg_rounded,
          ),
          MonumentTourStep(
            stepNumber: 4,
            title: 'La Nef Silencieuse aux 90 Piliers',
            subtitle: 'Pénétration dans le sanctuaire de fraîcheur',
            photoUrl:
                'assets/images/culture/monuments/monument_mosquee_djenne/dje_8.webp',
            locationBadge: 'Station 4 • Intérieur • Salle Hypostyle de Prière',
            guideSpeech:
                'Franchissons l\'une des portes en bois sculpté. Sentez-vous ce miracle ? Dehors, le soleil brûle à 44°C, mais ici, la température tombe instantanément à 22°C. Vous marchez au milieu d\'une forêt de 90 piliers massifs en banco qui soutiennent les voûtes.',
            observationClue:
                'L\'épaisseur des murs de terre crue (40 à 60 cm) emmagasine l\'air frais de la nuit pour le restituer durant les heures les plus chaudes de la journée.',
            architecturalDetail:
                'Les lucarnes circulaires zénithales tamisent la lumière et assurent une ventilation continue.',
            stepIcon: Icons.temple_buddhist_rounded,
          ),
          MonumentTourStep(
            stepNumber: 5,
            title: 'La Terrasse du Bani & La Mémoire des Bâtisseurs',
            subtitle: 'Apothéose de la visite',
            photoUrl:
                'assets/images/culture/monuments/monument_mosquee_djenne/dje_10.webp',
            locationBadge: 'Station 5 • Toit-Terrasse & Panorama sur le Fleuve',
            guideSpeech:
                'Nous terminons notre visite sur la terrasse supérieure. Face à vous, les méandres du fleuve Bani et les toits ocre de Djenné. Cette mosquée n\'est pas un monument du passé : c\'est un pacte vivant entre une communauté, son fleuve et sa mémoire.',
            observationClue:
                'Chaque année, la fête sacrée du Crépissage rassemble toute la cité en une seule matinée de liesse fraternelle pour offrir une nouvelle robe protectrice d\'argile à l\'édifice.',
            architecturalDetail:
                'Classée au Patrimoine Mondial de l\'UNESCO en 1988 au titre des biens culturels universels exceptionnels.',
            stepIcon: Icons.verified_rounded,
          ),
        ],
      );
    }

    // ── 2. VISITE GUIDÉE DU TOMBEAU PYRAMIDAL DES ASKIA (GAO) ───────────────
    if (id.contains('askia')) {
      return MonumentGuidedTour(
        monumentId: monument.id,
        monumentName: 'Tombeau des Askia',
        guideName: 'Maître Almamy Touré',
        guideRole: 'Gardien de la Nécropole Impériale Songhoï',
        totalDurationEstimated: '5 min de visite guidée',
        steps: [
          MonumentTourStep(
            stepNumber: 1,
            title: 'La Porte de la Cité Impériale',
            subtitle: 'L\'arrivée devant la pyramide de Gao',
            photoUrl: monument.photoUrl,
            locationBadge: 'Station 1 • Entrée du Complexe des Askia',
            guideSpeech:
                'Bienvenue à Gao, ancienne capitale du prestigieux Empire Songhoï. Devant vous se dresse l\'impressionnante pyramide funéraire érigée en 1495 par Askia Mohammed après son pèlerinage triomphal à La Mecque.',
            observationClue:
                'Remarquez la forme pyramidale à degrés : Askia Mohammed s\'est inspiré des pyramides d\'Égypte tout en imposant le génie constructif des bâtisseurs songhoï en terre crue.',
            stepIcon: Icons.change_history_rounded,
          ),
          MonumentTourStep(
            stepNumber: 2,
            title: 'Les Madriers en Acacia Blanc',
            subtitle: 'L\'architecture d\'entretien saharienne',
            photoUrl: monument.photoUrl,
            locationBadge: 'Station 2 • Façades Nord et Ouest',
            guideSpeech:
                'Comme à Djenné, les quatre faces de la pyramide sont hérissées de poutres de bois saillant. Mais ici, les artisans ont utilisé des branches d\'acacia blanc épineux résistant au vent de sable.',
            observationClue:
                'Ces madriers permettent aux familles de Gao d\'escalader la structure de 17 mètres pour renouveler l\'enduit après les tempêtes de sable sahariennes.',
            stepIcon: Icons.forest_rounded,
          ),
          MonumentTourStep(
            stepNumber: 3,
            title: 'Le Sanctuaire Funéraire & Les Deux Mosquées',
            subtitle: 'La nécropole des empereurs',
            photoUrl: monument.photoUrl,
            locationBadge: 'Station 3 • Cour intérieure & Sépulture',
            guideSpeech:
                'Entrez dans la cour ceinte de murs. Askia Mohammed repose ici, entouré de deux mosquées historiques à toit plat et d\'un cimetière séculaire où sont enterrés les dignitaires songhoï.',
            observationClue:
                'Le calme solennel du lieu témoigne de l\'apogée de l\'Afrique de l\'Ouest au XVe siècle, lorsque Gao était la capitale du plus vaste empire du continent.',
            stepIcon: Icons.verified_rounded,
          ),
        ],
      );
    }

    // ── 3. VISITE GUIDÉE DYNAMIQUE POUR LES AUTRES MONUMENTS ────────────────
    final dynamicSteps = <MonumentTourStep>[];

    // Étape 1 : Présentation d'ensemble
    dynamicSteps.add(
      MonumentTourStep(
        stepNumber: 1,
        title: 'Découverte de l\'Édifice',
        subtitle: monument.subtitle,
        photoUrl: monument.photoUrl,
        locationBadge: 'Station 1 • ${monument.locationDetails}',
        guideSpeech: monument.presentation,
        observationClue:
            'Prenez le temps d\'observer la majesté de l\'édifice : ${monument.era}.',
        architecturalDetail: monument.architectureAndMaterials,
        stepIcon: Icons.explore_rounded,
      ),
    );

    // Étapes intermédiaires tirées des chapitres
    for (int i = 0; i < monument.chapters.length && i < 3; i++) {
      final chap = monument.chapters[i];
      dynamicSteps.add(
        MonumentTourStep(
          stepNumber: i + 2,
          title: chap.title,
          subtitle: 'Station d\'observation approfondie',
          photoUrl: monument.photoUrl,
          locationBadge: 'Station ${i + 2} • Découverte historique',
          guideSpeech: chap.content,
          observationClue: chap.quote != null
              ? '« ${chap.quote} »'
              : 'Ce monument est le témoin privilégié de la mémoire malienne.',
          stepIcon: Icons.auto_stories_rounded,
        ),
      );
    }

    // Dernière étape : Pourquoi ce monument compte
    dynamicSteps.add(
      MonumentTourStep(
        stepNumber: dynamicSteps.length + 1,
        title: 'L\'Héritage & La Portée Universelle',
        subtitle: monument.tag,
        photoUrl: monument.photoUrl,
        locationBadge: 'Station finale • Bilan de la visite',
        guideSpeech: monument.whyItMatters,
        observationClue:
            'Ce site est conservé et transmis comme un joyau irremplaçable du patrimoine du Mali.',
        architecturalDetail:
            'Repère clé : ${monument.keyFacts.isNotEmpty ? monument.keyFacts.first.value : monument.era}',
        stepIcon: Icons.verified_rounded,
      ),
    );

    return MonumentGuidedTour(
      monumentId: monument.id,
      monumentName: monument.name,
      guideName: 'Guide Officiel du Patrimoine',
      guideRole: 'Direction Nationale des Monuments Historiques',
      totalDurationEstimated: '${dynamicSteps.length} étapes commentées',
      steps: dynamicSteps,
    );
  }
}
