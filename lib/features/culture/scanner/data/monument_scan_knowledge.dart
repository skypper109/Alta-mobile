import 'package:flutter/material.dart';
import '../models/monument_scan_models.dart';

/// Répertoire de connaissances des monuments et sites remarquables du Mali
/// calibré pour la vision par ordinateur CultureLens AI, la géolocalisation et le récit historique oral.
/// Se base strictement sur les 8 monuments historiques réels du dataset et du patrimoine malien.
abstract final class MonumentScanKnowledge {
  static final List<MonumentScanTarget> _dynamicTargets = [];

  static List<MonumentScanTarget> get targets => [
    ..._dynamicTargets,
    ...defaultTargets,
  ];

  /// Permet d'alimenter dynamiquement le catalogue depuis la base de données distante ou locale
  static void registerDynamicTargets(List<MonumentScanTarget> newTargets) {
    for (final t in newTargets) {
      _dynamicTargets.removeWhere((existing) => existing.id == t.id);
      _dynamicTargets.add(t);
    }
  }

  static const List<MonumentScanTarget> defaultTargets = [
    // ══════════════════════════════════════════════════════════════════════════
    // ── LES 8 GRANDS MONUMENTS HISTORIQUES AUTHENTIQUES DU MALI ───────────────
    // ══════════════════════════════════════════════════════════════════════════

    // 1. GRANDE MOSQUÉE DE DJENNÉ (MOPTI)
    MonumentScanTarget(
      id: 'monument_mosquee_djenne',
      name: 'Grande Mosquée de Djenné',
      subtitle: 'Le plus grand édifice en terre crue au monde',
      regionId: 'mopti',
      regionName: 'Mopti',
      ville: 'Djenné',
      era: 'Érigée en 1907 (fondations du XIIIe siècle)',
      architectureStyle:
          'Style soudano-sahélien en banco, poutres de rônier (torons), minarets crénelés',
      locationDetails: 'Bord du fleuve Bani, Cité millénaire de Djenné',
      photoUrl:
          'assets/images/culture/monuments/monument_mosquee_djenne/dje_1.webp',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_mosquee_djenne/dje_1.webp',
        'assets/images/culture/monuments/monument_mosquee_djenne/dje_2.webp',
        'assets/images/culture/monuments/monument_mosquee_djenne/dje_3.webp',
        'assets/images/culture/monuments/monument_mosquee_djenne/dje_4.webp',
        'assets/images/culture/monuments/monument_mosquee_djenne/dje_5.webp',
        'assets/images/culture/monuments/monument_mosquee_djenne/dje_6.jpg',
        'assets/images/culture/monuments/monument_mosquee_djenne/dje_7.webp',
        'assets/images/culture/monuments/monument_mosquee_djenne/dje_8.webp',
        'assets/images/culture/monuments/monument_mosquee_djenne/dje_9.webp',
        'assets/images/culture/monuments/monument_mosquee_djenne/dje_10.webp',
      ],
      tag: 'Patrimoine Mondial UNESCO',
      latitude: 13.9056,
      longitude: -4.5558,
      unlockedBadge: 'Gardien du Banco Millénaire',
      xpEarned: 70,
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
          'Chaque année, lors de la fête du Crépissage (Béré-Goun), plus de 4 000 habitants restaurent l\'intégralité des façades en une seule journée. Les récits oraux transmettent le mythe fondateur de Tapama Djenepo.',
      historicalStory:
          'Édifiée pour la première fois au XIIIe siècle par le roi Koy Koumboro, la Grande Mosquée de Djenné est le couronnement absolu du génie architectural sahélien.',
      audioNarrationText:
          'Vous observez la majestueuse Grande Mosquée de Djenné, classée au patrimoine mondial de l\'UNESCO. Cet édifice est le plus grand monument en terre crue de notre planète.',
      whyItMatters:
          'Elle incarne la maîtrise ancestrale des matériaux écologiques locaux et le triomphe de la solidarité communautaire malienne.',
      routePath: '/culture/monuments',
      arAvailable: true,
      validationStatus: 'Patrimoine Mondial UNESCO',
    ),

    // 2. MOSQUÉE DJINGAREYBER (TOMBOUCTOU)
    MonumentScanTarget(
      id: 'monument_djingareyber',
      name: 'Mosquée Djingareyber',
      subtitle: 'Sanctuaire d\'or et de manuscrits de Tombouctou',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      ville: 'Tombouctou',
      era: 'Commandée en 1327 par l\'empereur Mansa Moussa',
      architectureStyle:
          'Style soudano-andalou en banco, piliers intérieurs monumentaux, toiture en troncs de rônier',
      locationDetails: 'Quartier historique, Cité des 333 Saints, Tombouctou',
      photoUrl:
          'assets/images/culture/monuments/monument_djingareyber/wm_djin_1.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_djingareyber/wm_djin_1.jpg',
        'assets/images/culture/monuments/monument_djingareyber/wm_djin_2.jpg',
        'assets/images/culture/monuments/monument_djingareyber/wm_djin_3.jpg',
        'assets/images/culture/monuments/monument_djingareyber/wm_djin_4.jpg',
        'assets/images/culture/monuments/monument_djingareyber/wm_djin_5.jpg',
      ],
      tag: 'Patrimoine Mondial UNESCO',
      latitude: 16.7725,
      longitude: -3.0076,
      unlockedBadge: 'Érudit des Sables de Tombouctou',
      xpEarned: 70,
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
          'Au retour de son pèlerinage fastueux de 1324, Mansa Moussa offrit 200 kilogrammes d\'or pur à l\'architecte andalou Abou Ishaq es-Sahéli pour concevoir cette merveille.',
      historicalStory:
          'Djingareyber est la plus ancienne mosquée préservée de Tombouctou. Elle accueillait des milliers de disciples du monde entier.',
      audioNarrationText:
          'Voici Djingareyber, la plus ancienne mosquée de Tombouctou, érigée en 1327 sur ordre du légendaire empereur Mansa Moussa.',
      whyItMatters:
          'Le phare historique de l\'âge d\'or intellectuel et de la tolérance humaniste africaine.',
      routePath: '/culture/monuments',
      arAvailable: false,
      validationStatus: 'Patrimoine Mondial UNESCO',
    ),

    // 3. MOSQUÉE ET UNIVERSITÉ DE SANKORÉ (TOMBOUCTOU)
    MonumentScanTarget(
      id: 'monument_sankore',
      name: 'Mosquée et Université de Sankoré',
      subtitle: 'Le Berceau du Savoir Universel et des Manuscrits de Tombouctou',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      ville: 'Tombouctou',
      era: 'Fondée vers 1300, réaménagée sous Askia Mohammed en 1578',
      architectureStyle:
          'Architecture en banco soudanais avec cour sacrée respectant les dimensions de la Kaaba',
      locationDetails: 'Nord de Tombouctou, Quartier Sankoré',
      photoUrl:
          'assets/images/culture/monuments/monument_sankore/wm_san_1.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_sankore/wm_san_1.jpg',
        'assets/images/culture/monuments/monument_sankore/wm_san_2.jpg',
        'assets/images/culture/monuments/monument_sankore/wm_san_3.jpg',
        'assets/images/culture/monuments/monument_sankore/wm_san_4.jpg',
        'assets/images/culture/monuments/monument_sankore/wm_san_5.JPG',
      ],
      tag: 'Patrimoine Mondial UNESCO',
      latitude: 16.7778,
      longitude: -3.0033,
      unlockedBadge: 'Maître des Sciences de Sankoré',
      xpEarned: 70,
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
          'L\'illustre savant Ahmed Baba (1556-1627) y enseignait et possédait une bibliothèque personnelle de plus de 1 600 ouvrages rares.',
      historicalStory:
          'L\'Université de Sankoré a fait de Tombouctou la capitale intellectuelle de l\'Afrique subsaharienne avec 25 000 étudiants au XVIe siècle.',
      audioNarrationText:
          'Vous regardez l\'Université et Mosquée de Sankoré. Au XVIe siècle, plus de 25 000 étudiants fréquentaient ses cours.',
      whyItMatters:
          'Prouve la place centrale du Mali dans l\'histoire de la science mondiale et de la culture écrite.',
      routePath: '/culture/monuments',
      arAvailable: false,
      validationStatus: 'Patrimoine Mondial UNESCO',
    ),

    // 4. TOMBEAU PYRAMIDAL DES ASKIA (GAO)
    MonumentScanTarget(
      id: 'monument_tombeau_askia',
      name: 'Tombeau pyramidal des Askia',
      subtitle: 'Symbole de la Gloire Impériale Songhoï',
      regionId: 'gao',
      regionName: 'Gao',
      ville: 'Gao',
      era: 'Construit en 1495 par l\'empereur Askia Mohammed',
      architectureStyle:
          'Structure pyramidale à degrés sahélienne avec deux minarets et nécropole sacrée',
      locationDetails: 'Bord du fleuve Niger, Gao',
      photoUrl:
          'assets/images/culture/monuments/monument_tombeau_askia/wm_tomb_1.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_tombeau_askia/wm_tomb_1.jpg',
        'assets/images/culture/monuments/monument_tombeau_askia/wm_tomb_2.jpg',
        'assets/images/culture/monuments/monument_tombeau_askia/wm_tomb_3.jpg',
        'assets/images/culture/monuments/monument_tombeau_askia/wm_tomb_4.jpg',
        'assets/images/culture/monuments/monument_tombeau_askia/wm_tomb_5.jpg',
      ],
      tag: 'Patrimoine Mondial UNESCO',
      latitude: 16.2974,
      longitude: -0.0447,
      unlockedBadge: 'Héritier de l\'Empire Songhoï',
      xpEarned: 65,
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
          'Askia Mohammed ramena de la terre et de l\'eau bénite de La Mecque en 1496 pour sceller les fondations spirituelles de ce tombeau impérial.',
      historicalStory:
          'Témoin de la puissance commerciale, intellectuelle et militaire de l\'Empire Songhoï aux XVe et XVIe siècles, le tombeau est le seul complexe pyramidal en banco préservé dans tout le Sahara.',
      audioNarrationText:
          'Vous contemplez le Tombeau des Askia à Gao, joyau de l\'Empire Songhoï bâti en 1495 par l\'empereur Askia Mohammed.',
      whyItMatters:
          'L\'un des plus prestigieux complexes monumentaux de l\'Afrique subsaharienne précoloniale.',
      routePath: '/culture/monuments',
      arAvailable: false,
      validationStatus: 'Patrimoine Mondial UNESCO',
    ),

    // 5. MONUMENT DE L'INDÉPENDANCE (BAMAKO)
    MonumentScanTarget(
      id: 'monument_independance_bamako',
      name: 'Monument de l\'Indépendance',
      subtitle: 'Symbole éternel de la souveraineté et du 22 Septembre 1960',
      regionId: 'bamako',
      regionName: 'District de Bamako',
      ville: 'Bamako',
      era: 'Érigé en hommage au 22 septembre 1960 • Modibo Keïta',
      architectureStyle:
          'Obélisque monumentaliste moderne orné de bas-reliefs patriotiques',
      locationDetails:
          'Boulevard de l\'Indépendance, Hamdallaye / Centre administratif',
      photoUrl:
          'assets/images/culture/monuments/monument_independance_bamako/ind_24.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_independance_bamako/ind_24.jpg',
        'assets/images/culture/monuments/monument_independance_bamako/ind11.jpg',
        'assets/images/culture/monuments/monument_independance_bamako/ind12.jpg',
        'assets/images/culture/monuments/monument_independance_bamako/ind13.jpg',
      ],
      tag: 'Monument National Emblématique',
      latitude: 12.6392,
      longitude: -8.0029,
      unlockedBadge: 'Pionnier de la Souveraineté',
      xpEarned: 60,
      keywords: [
        'independance',
        'obelisque',
        'bamako',
        'modibo',
        'keita',
        '1960',
        'souverainete',
        'patrie',
        'boulevard',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Obélisque vertical élancé (25 mètres)',
          confidence: 0.992,
          category: 'Structure',
          icon: Icons.trending_up_rounded,
        ),
        ScanDetectionFeature(
          label: 'Bas-reliefs en bronze figurant les pères de la nation',
          confidence: 0.985,
          category: 'Détail',
          icon: Icons.military_tech_rounded,
        ),
        ScanDetectionFeature(
          label: 'Socle pyramidal en marbre et granit',
          confidence: 0.978,
          category: 'Matériau',
          icon: Icons.layers_rounded,
        ),
      ],
      secretsAndMysteries:
          'Le monument abrite une crypte commémorative scellée et le socle de la flamme sacrée du souvenir. Chaque 22 septembre, les délégations de toute l\'Afrique s\'y réunissent pour célébrer l\'accession à la souveraineté nationale.',
      historicalStory:
          'Érigé pour immortaliser l\'accession de la République du Mali à l\'indépendance le 22 septembre 1960, le monument célèbre le courage de Modibo Keïta et des artisans de la liberté. Il incarne le non catégorique à la sujétion et le ralliement à l\'idéal panafricain.',
      audioNarrationText:
          'Vous contemplez le Monument de l\'Indépendance du Mali, qui s\'élève fièrement sur le grand boulevard de Bamako. Cet obélisque géant rappelle à chaque génération le courage des pères fondateurs de 1960 et le serment inaltérable de la liberté nationale.',
      whyItMatters:
          'C\'est le repère patriotique central de la nation malienne et le lieu cérémoniel d\'affirmation de la souveraineté.',
      routePath: '/culture/monuments',
      arAvailable: true,
      validationStatus: 'Validé Archives Nationales',
    ),

    // 6. LA TOUR DE L'AFRIQUE (BAMAKO)
    MonumentScanTarget(
      id: 'monument_tour_afrique_bamako',
      name: 'La Tour de l\'Afrique',
      subtitle: 'Le Phare du Panafricanisme et de la Fraternité Sahélienne',
      regionId: 'bamako',
      regionName: 'District de Bamako',
      ville: 'Bamako',
      era: 'Inaugurée en 2001 lors du Sommet France-Afrique',
      architectureStyle:
          'Tour néo-sahélienne de 46 mètres évoquant un baobab sacré surmonté d\'une corbeille de l\'union',
      locationDetails:
          'Rond-point de Faladié, Carrefour de la Paix, Commune VI',
      photoUrl:
          'assets/images/culture/monuments/monument_tour_afrique_bamako/wm_tour_1.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_tour_afrique_bamako/wm_tour_1.jpg',
        'assets/images/culture/monuments/monument_tour_afrique_bamako/wm_tour_2.jpg',
        'assets/images/culture/monuments/monument_tour_afrique_bamako/wm_tour_3.jpg',
        'assets/images/culture/monuments/monument_tour_afrique_bamako/wm_tour_4.jpg',
      ],
      tag: 'Symbole de l\'Unité Africaine',
      latitude: 12.5935,
      longitude: -7.9463,
      unlockedBadge: 'Bâtisseur de l\'Unité Africaine',
      xpEarned: 60,
      keywords: [
        'tour',
        'afrique',
        'faladie',
        'baobab',
        'corbeille',
        'panafricanisme',
        'bamako',
        'aeroport',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Silhouette évasée en forme de baobab (46m)',
          confidence: 0.994,
          category: 'Structure',
          icon: Icons.nature_rounded,
        ),
        ScanDetectionFeature(
          label: 'Corbeille supérieure de la concorde',
          confidence: 0.988,
          category: 'Symbole',
          icon: Icons.all_inclusive_rounded,
        ),
        ScanDetectionFeature(
          label: 'Enduit ocre et fresques céramiques des 54 pays',
          confidence: 0.976,
          category: 'Détail',
          icon: Icons.public_rounded,
        ),
      ],
      secretsAndMysteries:
          'La corbeille au sommet symbolise le mythe de la jarre percée : nul ne peut étancher la soif d\'un continent seul, mais unis, les doigts des peuples retiennent l\'eau de la paix et de la prospérité.',
      historicalStory:
          'Construite au carrefour stratégique menant à l\'aéroport et aux régions du sud, la Tour de l\'Afrique est un vibrant hommage à l\'idéal des États-Unis d\'Afrique et à la solidarité interétatique.',
      audioNarrationText:
          'Dressée à 46 mètres au-dessus du rond-point de Faladié, la Tour de l\'Afrique accueille les visiteurs entrant à Bamako. Ses lignes sinueuses rendent hommage à l\'arbre à palabres et rappellent la vocation du Mali à être le carrefour éternel de l\'unité africaine.',
      whyItMatters:
          'C\'est l\'un des monuments les plus hauts et les plus photographiés d\'Afrique de l\'Ouest.',
      routePath: '/culture/monuments',
      arAvailable: true,
      validationStatus: 'Validé Ministère de la Culture',
    ),

    // 7. FORT DE MÉDINE (KAYES)
    MonumentScanTarget(
      id: 'monument_fort_medine',
      name: 'Fort de Médine',
      subtitle: 'Sentinelle historique de pierre sur le Haut-Sénégal',
      regionId: 'kayes',
      regionName: 'Kayes',
      ville: 'Kayes',
      era: 'Construit en 1855 sous le règne du roi du Khasso Hawa Demba Diallo',
      architectureStyle:
          'Fortification militaire en pierres taillées de grès rouge et mortier de chaux',
      locationDetails: 'Bord du fleuve Sénégal, à 12 km de Kayes',
      photoUrl:
          'assets/images/culture/monuments/monument_fort_medine/wm_med_1.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_fort_medine/wm_med_1.jpg',
        'assets/images/culture/monuments/monument_fort_medine/wm_med_2.jpg',
        'assets/images/culture/monuments/monument_fort_medine/wm_med_3.jpg',
      ],
      tag: 'Monument Historique National',
      latitude: 14.3756,
      longitude: -11.3653,
      unlockedBadge: 'Vigie du Khasso',
      xpEarned: 55,
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
          'Le fort a été le théâtre du célèbre siège de 1857 opposant les troupes d\'El Hadj Oumar Tall aux forces coalisées de Faidherbe et du roi Sambala Diallo.',
      historicalStory:
          'Bâti pour contrôler la navigation fluviale sur le Haut-Sénégal, Médine est un carrefour stratégique unique.',
      audioNarrationText:
          'Voici le Fort de Médine, dressé au bord du fleuve Sénégal près de Kayes. Construit en 1855 en solides pierres taillées de grès.',
      whyItMatters:
          'Témoin clé de l\'épopée toucouleure et de l\'histoire fluviale du Mali.',
      routePath: '/culture/monuments',
      arAvailable: false,
      validationStatus: 'Monument National',
    ),

    // 8. LE TATA DE SIKASSO (SIKASSO)
    MonumentScanTarget(
      id: 'monument_tata_sikasso',
      name: 'Le Tata de Sikasso',
      subtitle: 'La Muraille de Résistance Héroïque du Kénédougou',
      regionId: 'sikasso',
      regionName: 'Sikasso',
      ville: 'Sikasso',
      era: 'Édifié entre 1877 et 1890 par le roi Tiéba Traoré',
      architectureStyle:
          'Fortification militaire massive en banco durci et blocs de latérite taillée',
      locationDetails: 'Colline du Mamelon, Centre de Sikasso',
      photoUrl:
          'assets/images/culture/monuments/monument_tata_sikasso/wm_tata_1.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_tata_sikasso/wm_tata_1.jpg',
      ],
      tag: 'Monument National de Résistance',
      latitude: 11.3176,
      longitude: -5.6665,
      unlockedBadge: 'Bravoure du Kénédougou',
      xpEarned: 65,
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
          'Le Tata mesurait à son apogée plus de 9 kilomètres de circonférence. En 1898, encerclé par les troupes coloniales, le roi Babemba Traoré s\'exclama : « Plutôt la mort que la honte » (Sayi té Maloya Sa).',
      historicalStory:
          'Chef-d\'œuvre de génie militaire précolonial ouest-africain, le Tata de Sikasso est l\'ultime forteresse de la souveraineté.',
      audioNarrationText:
          'Voici les vestiges héroïques du Tata de Sikasso, l\'enceinte fortifiée du royaume du Kénédougou. Érigée par Tiéba Traoré et défendue jusqu\'au dernier souffle par son frère Babemba en 1898.',
      whyItMatters:
          'Témoignage suprême du refus de la servitude et du sens aigu de l\'indépendance nationale.',
      routePath: '/culture/monuments',
      arAvailable: false,
      validationStatus: 'Monument National',
    ),
  ];

  /// Trouver un monument par son ID (robuste et tolérant aux variations d'identifiant)
  static MonumentScanTarget? findById(String id) {
    if (id.isEmpty) return null;
    final normalized = id.toLowerCase().trim();
    if (normalized == 'monument_djenne' ||
        normalized == 'djenne' ||
        normalized == 'mosquee_djenne') {
      try {
        return targets.firstWhere((t) => t.id == 'monument_mosquee_djenne');
      } catch (_) {}
    }
    try {
      return targets.firstWhere((t) {
        final tId = t.id.toLowerCase();
        if (tId == normalized) return true;
        if (tId == 'monument_$normalized' || normalized == 'monument_$tId') {
          return true;
        }
        if (tId.replaceAll('monument_', '') ==
            normalized.replaceAll('monument_', '')) {
          return true;
        }
        if (tId.replaceAll('_bamako', '') ==
            normalized.replaceAll('_bamako', '')) {
          return true;
        }
        return false;
      });
    } catch (_) {
      return matchByKeywords(id);
    }
  }

  /// Trouver tous les monuments situés à Bamako
  static List<MonumentScanTarget> get bamakoTargets {
    return targets
        .where(
          (t) =>
              t.ville.toLowerCase() == 'bamako' || t.regionId == 'bamako',
        )
        .toList();
  }

  /// Recherche par mots-clés ou proximité textuelle (stricte)
  static MonumentScanTarget? matchByKeywords(String query) {
    final clean = query.toLowerCase().trim();
    if (clean.isEmpty || clean.length < 4) return null;

    // Ignorer impérativement les préfixes techniques de fichiers caméra / galerie
    if (clean.startsWith('image_picker') ||
        clean.startsWith('scaled_') ||
        clean.startsWith('img_') ||
        clean.startsWith('camera') ||
        clean.startsWith('photo') ||
        clean.startsWith('capture') ||
        clean.startsWith('screenshot') ||
        clean.startsWith('frame_')) {
      return null;
    }

    for (final target in targets) {
      if (target.id.toLowerCase() == clean ||
          target.name.toLowerCase() == clean) {
        return target;
      }
      for (final kw in target.keywords) {
        final cleanKw = kw.toLowerCase().trim();
        if (cleanKw.length >= 4 && clean == cleanKw) {
          return target;
        }
      }
    }
    return null;
  }
}
