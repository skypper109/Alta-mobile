import 'package:flutter/material.dart';
import '../models/monument_scan_models.dart';

/// Répertoire de connaissances des monuments et sites remarquables du Mali
/// calibré pour la vision par ordinateur, la géolocalisation et le récit historique oral.
abstract final class MonumentScanKnowledge {
  static const List<MonumentScanTarget> targets = [
    // ── 1. GRANDE MOSQUÉE DE DJENNÉ ──────────────────────────────────────────
    MonumentScanTarget(
      id: 'monument_mosquee_djenne',
      name: 'Grande Mosquée de Djenné',
      subtitle: 'Le plus grand édifice en terre crue au monde',
      regionId: 'mopti',
      regionName: 'Mopti',
      era: 'Érigée en 1907 (fondations du XIIIe siècle)',
      architectureStyle:
          'Style soudano-sahélien en banco, poutres de rônier (torons), minarets crénelés',
      locationDetails: 'Bord du fleuve Bani, Cité millénaire de Djenné',
      photoUrl: 'assets/images/culture/monuments/mosquee_djenne.jpg',
      tag: 'Patrimoine Mondial UNESCO',
      latitude: 13.9056,
      longitude: -4.5558,
      unlockedBadge: 'Gardien du Banco Millénaire',
      xpEarned: 50,
      keywords: [
        'djenne',
        'mosquee',
        'banco',
        'terre',
        'mopti',
        'toron',
        'unesco',
        'bani',
        'crepissage',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Texture Banco & Argile alluviale crue',
          confidence: 0.992,
          category: 'Matériau',
          icon: Icons.grain_rounded,
        ),
        ScanDetectionFeature(
          label: 'Poutres de rônier apparentes (Torons)',
          confidence: 0.985,
          category: 'Structure',
          icon: Icons.architecture_rounded,
        ),
        ScanDetectionFeature(
          label: 'Minarets crénelés avec œufs d\'autruche sacrés',
          confidence: 0.978,
          category: 'Symbole',
          icon: Icons.brightness_high_rounded,
        ),
        ScanDetectionFeature(
          label: 'Contreforts coniques soudanais',
          confidence: 0.969,
          category: 'Géométrie',
          icon: Icons.view_in_ar_rounded,
        ),
      ],
      secretsAndMysteries:
          'Chaque année, lors de la fête du Crépissage (Béré-Goun), plus de 4 000 habitants restaurent l\'intégralité des façades en une seule journée. Les récits oraux transmettent le mythe fondateur de la jeune fille Tapama Djenepo, dont l\'offrande spirituelle assura la prospérité et la paix éternelle de la cité.',
      historicalStory:
          'Édifiée pour la première fois au XIIIe siècle par le roi Koy Koumboro converti à l\'islam, la Grande Mosquée de Djenné est le couronnement absolu du génie architectural sahélien. Bâtie entièrement en briques de terre séchée au soleil, d\'argile et de paille, elle s\'élève comme une montagne vivante respirant avec les saisons.',
      audioNarrationText:
          'Vous observez la majestueuse Grande Mosquée de Djenné, classée au patrimoine mondial de l\'UNESCO. Cet édifice est le plus grand monument en terre crue de notre planète. Remarquez les poutres de bois qui dépassent des murs : ce sont les torons, servant à la fois d\'échafaudage permanent et de signatures sacrées. Chaque année, la ville entière se réunit pour la grande fête du crépissage, renouvelant l\'argile sacrée dans une communion populaire unique au monde.',
      whyItMatters:
          'Elle incarne la maîtrise ancestrale des matériaux écologiques locaux et le triomphe de la solidarité communautaire malienne.',
      routePath: '/culture/monument/monument_mosquee_djenne',
    ),

    // ── 2. LE TATA DE SIKASSO ────────────────────────────────────────────────
    MonumentScanTarget(
      id: 'monument_tata_sikasso',
      name: 'Le Tata de Sikasso',
      subtitle: 'La Muraille de Résistance du Kénédougou',
      regionId: 'sikasso',
      regionName: 'Sikasso',
      era: 'Édifié entre 1877 et 1890 par le roi Tiéba Traoré',
      architectureStyle:
          'Fortification militaire massive en banco durci et blocs de latérite',
      locationDetails: 'Colline du Mamelon, Centre de Sikasso',
      photoUrl: 'assets/images/culture/monuments/tata_sikasso.jpg',
      tag: 'Monument National de Résistance',
      latitude: 11.3176,
      longitude: -5.6665,
      unlockedBadge: 'Bravoure du Kénédougou',
      xpEarned: 50,
      keywords: [
        'sikasso',
        'tata',
        'rempart',
        'muraille',
        'tieba',
        'babemba',
        'traore',
        'kenedougou',
        'mamelon',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Blocs de latérite taillée & terre rouge cuite',
          confidence: 0.988,
          category: 'Matériau',
          icon: Icons.layers_rounded,
        ),
        ScanDetectionFeature(
          label: 'Épaisseur défensive (3 à 6 mètres)',
          confidence: 0.974,
          category: 'Structure',
          icon: Icons.shield_rounded,
        ),
        ScanDetectionFeature(
          label: 'Meurtrières de tir & créneaux de garde',
          confidence: 0.965,
          category: 'Tactique',
          icon: Icons.security_rounded,
        ),
      ],
      secretsAndMysteries:
          'Le Tata mesurait à son apogée plus de 9 kilomètres de circonférence et comprenait trois enceintes concentriques. Il a repoussé pendant 15 mois le siège impitoyable de l\'Almamy Samory Touré en 1887. En 1898, encerclé par les troupes coloniales, le roi Babemba Traoré refusa toute reddition et s\'exclama la devise sacrée : « Plutôt la mort que la honte » (Sayi té Maloya Sa).',
      historicalStory:
          'Chef-d\'œuvre de génie militaire précolonial ouest-africain, le Tata de Sikasso est l\'ultime forteresse de la dignité souveraine. Les murs étaient renforcés avec du beurre de karité et des décoctions de plantes pour les rendre imperméables aux canons et intempéries.',
      audioNarrationText:
          'Voici les vestiges héroïques du Tata de Sikasso, l\'enceinte fortifiée du royaume du Kénédougou. Érigée par Tiéba Traoré et défendue jusqu\'au dernier souffle par son frère Babemba en 1898, cette muraille gigantesque de neuf kilomètres a tenu tête aux armées les plus puissantes de son époque. Ce lieu est le symbole indomptable de l\'honneur malien.',
      whyItMatters:
          'Témoignage suprême du refus de la servitude et du sens aigu de l\'indépendance nationale.',
      routePath: '/culture/monument/monument_tata_sikasso',
    ),

    // ── 3. TOMBEAU PYRAMIDAL DES ASKIA ──────────────────────────────────────
    MonumentScanTarget(
      id: 'monument_tombeau_askia',
      name: 'Tombeau pyramidal des Askia',
      subtitle: 'Symbole de la gloire impériale Songhoï',
      regionId: 'gao',
      regionName: 'Gao',
      era: 'Construit en 1495 par l\'empereur Askia Mohammed',
      architectureStyle:
          'Structure pyramidale à degrés sahélienne avec deux minarets et nécropole sacrée',
      locationDetails: 'Bord du fleuve Niger, Gao',
      photoUrl: 'assets/images/culture/monuments/tombeau_askia.jpg',
      tag: 'Patrimoine Mondial UNESCO',
      latitude: 16.2974,
      longitude: -0.0447,
      unlockedBadge: 'Héritier de l\'Empire Songhoï',
      xpEarned: 50,
      keywords: [
        'gao',
        'askia',
        'tombeau',
        'pyramide',
        'songhoi',
        'unesco',
        'mohammed',
        'sahel',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Forme pyramidale tronquée à degrés (17m)',
          confidence: 0.991,
          category: 'Géométrie',
          icon: Icons.change_history_rounded,
        ),
        ScanDetectionFeature(
          label: 'Échafaudages permanents en troncs d\'acacia',
          confidence: 0.982,
          category: 'Structure',
          icon: Icons.architecture_rounded,
        ),
        ScanDetectionFeature(
          label: 'Enduit d\'argile fine du lit du Niger',
          confidence: 0.970,
          category: 'Matériau',
          icon: Icons.brush_rounded,
        ),
      ],
      secretsAndMysteries:
          'Selon la tradition historique orale de Gao, l\'empereur Askia Mohammed ramena lui-même de la terre et de l\'eau bénite de la Mecque lors de son célèbre pèlerinage de 1496 pour sceller les fondations spirituelles de ce tombeau impérial.',
      historicalStory:
          'Témoin de la puissance commerciale, intellectuelle et militaire de l\'Empire Songhoï aux XVe et XVIe siècles, le tombeau est le seul complexe pyramidal en banco préservé dans tout le Sahara.',
      audioNarrationText:
          'Vous contemplez le Tombeau des Askia à Gao, joyau de l\'Empire Songhoï bâti en 1495 par l\'empereur Askia Mohammed. Sa forme pyramidale singulière s\'élève à 17 mètres de haut au-dessus du fleuve Niger. Il représente la synthèse grandiose entre les traditions funéraires sahéliennes et le rayonnement universel de Tombouctou et Gao.',
      whyItMatters:
          'L\'un des plus prestigieux complexes monumentaux de l\'Afrique subsaharienne précoloniale.',
      routePath: '/culture/monument/monument_tombeau_askia',
    ),

    // ── 4. MOSQUÉE DJINGAREYBER ──────────────────────────────────────────────
    MonumentScanTarget(
      id: 'monument_djingareyber',
      name: 'Mosquée Djingareyber',
      subtitle: 'Sanctuaire d\'or et de manuscrits de Tombouctou',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      era: 'Commandée en 1327 par l\'empereur Mansa Moussa',
      architectureStyle:
          'Style soudano-andalou en banco, piliers intérieurs monumentaux, toiture en troncs de rônier',
      locationDetails: 'Quartier historique, Cité des 333 Saints, Tombouctou',
      photoUrl: 'assets/images/culture/monuments/mosquee_djingareyber.jpg',
      tag: 'Patrimoine Mondial UNESCO',
      latitude: 16.7725,
      longitude: -3.0076,
      unlockedBadge: 'Érudit des Sables de Tombouctou',
      xpEarned: 50,
      keywords: [
        'tombouctou',
        'djingareyber',
        'mansa',
        'moussa',
        'saheli',
        'mosquee',
        'manuscrit',
        'unesco',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Minaret conique en terre à escalier extérieur',
          confidence: 0.987,
          category: 'Structure',
          icon: Icons.stairs_rounded,
        ),
        ScanDetectionFeature(
          label: 'Arcs andalous & piliers de banco massifs',
          confidence: 0.979,
          category: 'Architecture',
          icon: Icons.domain_rounded,
        ),
        ScanDetectionFeature(
          label: 'Calcaire de banco et terre crue séchée',
          confidence: 0.971,
          category: 'Matériau',
          icon: Icons.grain_rounded,
        ),
      ],
      secretsAndMysteries:
          'Au retour de son pèlerinage fastueux de 1324 où il distribua des tonnes d\'or, Mansa Moussa offrit 200 kilogrammes d\'or pur (environ 40 000 mithqals) au poète et architecte andalou Abou Ishaq es-Sahéli pour concevoir cette merveille qui n\'a jamais cessé d\'accueillir des fidèles depuis sept siècles.',
      historicalStory:
          'Djingareyber est la plus ancienne mosquée préservée de Tombouctou. Elle formait avec Sankoré et Sidi Yahya le triptyque de la prestigieuse Université médiévale de Tombouctou où étudiaient plus de 25 000 savants de tout le monde connu.',
      audioNarrationText:
          'Voici Djingareyber, la plus ancienne mosquée de Tombouctou, érigée en 1327 sur ordre du légendaire empereur Mansa Moussa. Conçue par l\'architecte andalou Abou Ishaq es-Sahéli, elle est le berceau où des dizaines de milliers de manuscrits traitant de médecine, d\'astronomie et de droit ont été calligraphiés et protégés à travers les siècles.',
      whyItMatters:
          'Le phare historique de l\'âge d\'or intellectuel et de la tolérance humaniste africaine.',
      routePath: '/culture/monument/monument_djingareyber',
    ),

    // ── 5. MOSQUÉE ET UNIVERSITÉ DE SANKORÉ ──────────────────────────────────
    MonumentScanTarget(
      id: 'monument_sankore',
      name: 'Mosquée et Université de Sankoré',
      subtitle: 'Le Berceau du Savoir Universel et des Manuscrits',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      era: 'Fondée vers 1300, réaménagée sous Askia Mohammed en 1578',
      architectureStyle:
          'Architecture en banco soudanais avec cour sacrée respectant les dimensions de la Kaaba',
      locationDetails: 'Nord de Tombouctou, Quartier Sankoré',
      photoUrl: 'assets/images/culture/monuments/mosquee_sankore.jpg',
      tag: 'Patrimoine Mondial UNESCO',
      latitude: 16.7778,
      longitude: -3.0033,
      unlockedBadge: 'Maître des Sciences de Sankoré',
      xpEarned: 50,
      keywords: [
        'sankore',
        'universite',
        'tombouctou',
        'ahmed',
        'baba',
        'manuscrits',
        'savoir',
        'unesco',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Minaret pyramidale à renforts en bois de rônier',
          confidence: 0.985,
          category: 'Structure',
          icon: Icons.castle_rounded,
        ),
        ScanDetectionFeature(
          label: 'Cour intérieure aux proportions sacrées de la Kaaba',
          confidence: 0.976,
          category: 'Géométrie',
          icon: Icons.square_foot_rounded,
        ),
        ScanDetectionFeature(
          label: 'Bibliothèque des manuscrits anciens en ajami',
          confidence: 0.989,
          category: 'Patrimoine',
          icon: Icons.auto_stories_rounded,
        ),
      ],
      secretsAndMysteries:
          'L\'illustre savant Ahmed Baba (1556-1627) y enseignait et possédait une bibliothèque personnelle de plus de 1 600 ouvrages rares. Sankoré délivrait des turbans de diplôme après plusieurs années de thèses soutenues publiquement.',
      historicalStory:
          'L\'Université de Sankoré a fait de Tombouctou la capitale intellectuelle de l\'Afrique. On y enseignait la géométrie euclidienne, la chirurgie ophtalmologique, la théologie et la poésie à une époque où de nombreuses universités d\'Europe n\'existaient pas encore.',
      audioNarrationText:
          'Vous regardez l\'Université et Mosquée de Sankoré. Au XVIe siècle, plus de 25 000 étudiants venus de tout le monde musulman et africain fréquentaient ses bancs. C\'est ici que le célèbre érudit Ahmed Baba a démontré la grandeur de la pensée philosophique et scientifique africaine.',
      whyItMatters:
          'Prouve la place centrale du Mali dans l\'histoire de la science mondiale et de la culture écrite.',
      routePath: '/culture/monument/monument_sankore',
    ),

    // ── 6. FORT DE MÉDINE ────────────────────────────────────────────────────
    MonumentScanTarget(
      id: 'monument_fort_medine',
      name: 'Fort de Médine',
      subtitle: 'Sentinelle historique de pierre sur le Haut-Sénégal',
      regionId: 'kayes',
      regionName: 'Kayes',
      era: 'Construit en 1855 sous le règne du roi du Khasso Hawa Demba Diallo',
      architectureStyle:
          'Fortification militaire en pierres taillées de grès rouge et mortier de chaux',
      locationDetails: 'Bord du fleuve Sénégal, à 12 km de Kayes',
      photoUrl: 'assets/images/culture/monuments/fort_medine.jpg',
      tag: 'Monument Historique National',
      latitude: 14.3756,
      longitude: -11.3653,
      unlockedBadge: 'Vigie du Khasso',
      xpEarned: 50,
      keywords: [
        'kayes',
        'medine',
        'fort',
        'khasso',
        'senegal',
        'elhadj',
        'tall',
        'pierre',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Appareillage en pierres rouges de latérite taillée',
          confidence: 0.984,
          category: 'Matériau',
          icon: Icons.handyman_rounded,
        ),
        ScanDetectionFeature(
          label: 'Tour de guet cylindrique & bastions d\'artillerie',
          confidence: 0.978,
          category: 'Structure',
          icon: Icons.visibility_rounded,
        ),
        ScanDetectionFeature(
          label: 'Remparts surplombant le cours du fleuve Sénégal',
          confidence: 0.968,
          category: 'Topographie',
          icon: Icons.water_rounded,
        ),
      ],
      secretsAndMysteries:
          'Le fort a été le théâtre du célèbre siège de 1857 opposant les troupes d\'El Hadj Oumar Tall, fondateur de l\'Empire toucouleur, aux forces coalisées de Faidherbe et du roi local Sambala Diallo. Le siège dura 97 jours héroïques avant d\'être levé.',
      historicalStory:
          'Bâti pour contrôler la navigation commerciale et fluviale sur le Haut-Sénégal, Médine est un carrefour stratégique unique entre le Soudan occidental et la côte atlantique.',
      audioNarrationText:
          'Voici le Fort de Médine, dressé au bord du fleuve Sénégal près de Kayes. Construit en 1855 en solides pierres taillées de grès, il a été le théâtre du mémorable siège de 97 jours mené par l\'Almamy El Hadj Oumar Tall. Médine est un témoin capital des bouleversements géopolitiques du XIXe siècle en Afrique de l\'Ouest.',
      whyItMatters:
          'Témoin clé de l\'épopée toucouleure et de l\'histoire fluviale du Mali maritime et continental.',
      routePath: '/culture/monument/monument_fort_medine',
    ),
  ];

  /// Trouver un monument par son ID
  static MonumentScanTarget? findById(String id) {
    try {
      return targets.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Recherche par mots-clés ou proximité textuelle
  static MonumentScanTarget? matchByKeywords(String query) {
    final clean = query.toLowerCase().trim();
    if (clean.isEmpty) return null;

    for (final target in targets) {
      if (target.id.toLowerCase() == clean ||
          target.name.toLowerCase().contains(clean) ||
          target.subtitle.toLowerCase().contains(clean)) {
        return target;
      }
      for (final kw in target.keywords) {
        if (clean.contains(kw) || kw.contains(clean)) {
          return target;
        }
      }
    }
    return null;
  }
}
