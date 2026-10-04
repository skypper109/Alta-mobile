import 'package:flutter/material.dart';
import '../models/monument_scan_models.dart';

/// Répertoire de connaissances des monuments et sites remarquables du Mali
/// calibré pour la vision par ordinateur CultureLens AI, la géolocalisation et le récit historique oral.
/// Se base strictement sur les monuments disposant de dossiers et photos réelles du dataset.
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
    // ── MONUMENTS DE BAMAKO (AVEC PHOTOS RÉELLES DU DATASET) ──────────────────
    // ══════════════════════════════════════════════════════════════════════════

    // 1. MONUMENT DE L'INDÉPENDANCE
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
          'assets/images/culture/monuments/monument_independance_bamako/ind11.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_independance_bamako/ind11.jpg',
        'assets/images/culture/monuments/monument_independance_bamako/ind12.jpg',
        'assets/images/culture/monuments/monument_independance_bamako/ind13.jpg',
        'assets/images/culture/monuments/monument_independance_bamako/ind2.jpg',
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

    // 2. LA TOUR DE L'AFRIQUE
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
          'assets/images/culture/monuments/monument_tour_afrique_bamako/tour.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_tour_afrique_bamako/tour.jpg',
        'assets/images/culture/monuments/monument_tour_afrique_bamako/tour1.jpg',
        'assets/images/culture/monuments/monument_tour_afrique_bamako/tour10.jpg',
        'assets/images/culture/monuments/monument_tour_afrique_bamako/tour11.jpg',
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

    // 3. LE MONUMENT DE LA PAIX
    MonumentScanTarget(
      id: 'monument_paix_bamako',
      name: 'Le Monument de la Paix',
      subtitle: 'La Colombe de la Concorde et de la Réconciliation',
      regionId: 'bamako',
      regionName: 'District de Bamako',
      ville: 'Bamako',
      era: 'Érigé en 1996 • Dans la ferveur de la Flamme de la Paix',
      architectureStyle:
          'Colombe blanche monumentale aux ailes déployées au-dessus du globe terrestre',
      locationDetails:
          'Rond-point de la Paix, Hamdallaye ACI 2000, Commune IV',
      photoUrl:
          'assets/images/culture/monuments/monument_paix_bamako/Ref_P5.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_paix_bamako/Ref_P5.jpg',
        'assets/images/culture/monuments/monument_paix_bamako/paix1.jpg',
        'assets/images/culture/monuments/monument_paix_bamako/ref_P1.jpg',
        'assets/images/culture/monuments/monument_paix_bamako/ref_P10.jpg',
      ],
      tag: 'Monument National de Concorde',
      latitude: 12.6322,
      longitude: -8.0261,
      unlockedBadge: 'Artisan de la Paix',
      xpEarned: 50,
      keywords: [
        'paix',
        'colombe',
        'aci 2000',
        'hamdallaye',
        'reconciliation',
        'concorde',
        'bamako',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Colombe sculpturale blanche en plein envol',
          confidence: 0.990,
          category: 'Symbole',
          icon: Icons.flutter_dash_rounded,
        ),
        ScanDetectionFeature(
          label: 'Sphère terrestre en acier ajouré',
          confidence: 0.982,
          category: 'Structure',
          icon: Icons.public_rounded,
        ),
        ScanDetectionFeature(
          label: 'Bassin d\'eau circulaire réfléchissant',
          confidence: 0.970,
          category: 'Environnement',
          icon: Icons.water_rounded,
        ),
      ],
      secretsAndMysteries:
          'Le monument a été érigé suite à l\'accord historique de Tombouctou en 1996 où plus de 3 000 fusils de guerre furent brûlés dans un brasier d\'espoir.',
      historicalStory:
          'Situé dans le quartier d\'affaires d\'ACI 2000, le monument rappelle que la paix n\'est pas un vain mot, mais un comportement quotidien inscrit dans la parenté à plaisanterie (Sinankunya).',
      audioNarrationText:
          'Vous admirez le Monument de la Paix d\'Hamdallaye ACI 2000. La colombe immaculée prenant son essor symbolise le triomphe du dialogue sur la discorde.',
      whyItMatters:
          'Rappel solennel de la réconciliation et du vivre-ensemble entre toutes les communautés maliennes.',
      routePath: '/culture/monuments',
      arAvailable: false,
      validationStatus: 'Validé',
    ),

    // 4. MONUMENT DES HÉROS DE L'ARMÉE NOIRE
    MonumentScanTarget(
      id: 'monument_armee_noire_bamako',
      name: 'Monument des Héros de l\'Armée Noire',
      subtitle: 'Hommage universel aux Tirailleurs et Combattants Africains',
      regionId: 'bamako',
      regionName: 'District de Bamako',
      ville: 'Bamako',
      era: 'Conçu en 1924 • Réhabilité solennellement en 2004',
      architectureStyle:
          'Statuaire monumentale en bronze représentant des soldats africains solidaires',
      locationDetails: 'Place de la Liberté, Centre-ville, Commune III',
      photoUrl:
          'assets/images/culture/monuments/monument_armee_noire_bamako/ref_N1.webp',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_armee_noire_bamako/ref_N1.webp',
      ],
      tag: 'Mémoire Militaire & Universelle',
      latitude: 12.6514,
      longitude: -7.9982,
      unlockedBadge: 'Mémoire des Tirailleurs',
      xpEarned: 55,
      keywords: [
        'tirailleurs',
        'armee noire',
        'liberte',
        'guerre',
        'heros',
        'bamako',
        'bronze',
        'place',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Groupe sculpté de soldats africains en uniforme d\'époque',
          confidence: 0.991,
          category: 'Sculpture',
          icon: Icons.groups_rounded,
        ),
        ScanDetectionFeature(
          label: 'Piédestal en pierre de taille rouge',
          confidence: 0.980,
          category: 'Matériau',
          icon: Icons.foundation_rounded,
        ),
        ScanDetectionFeature(
          label: 'Emplacement central sur la Place de la Liberté',
          confidence: 0.974,
          category: 'Topographie',
          icon: Icons.location_city_rounded,
        ),
      ],
      secretsAndMysteries:
          'Ce monument est la réplique exacte de celui érigé à Reims en France en 1924, détruit durant l\'occupation de 1940, puis reconstruit grâce aux archives conservées à Bamako.',
      historicalStory:
          'Ce mémorial consacre le sacrifice suprême consenti par les fils du Mali et d\'Afrique de l\'Ouest pour la liberté mondiale lors des deux guerres mondiales.',
      audioNarrationText:
          'Ici s\'élève le Monument des Héros de l\'Armée Noire, sur la Place de la Liberté. Il honore la mémoire impérissable des tirailleurs qui ont combattu sur les champs de bataille avec un héroïsme légendaire.',
      whyItMatters:
          'Plaque tournante de la mémoire combattante africaine et de la reconnaissance internationale.',
      routePath: '/culture/monuments',
      arAvailable: false,
      validationStatus: 'Validé Archives Militaires',
    ),

    // 5. MONUMENT DE SAMORY TOURÉ
    MonumentScanTarget(
      id: 'monument_samory_toure_bamako',
      name: 'Monument de l\'Almamy Samory Touré',
      subtitle: 'Le Bâtisseur de l\'Empire Ouassoulou et Grand Stratège',
      regionId: 'bamako',
      regionName: 'District de Bamako',
      ville: 'Bamako',
      era: 'Érigé sous la IIIe République',
      architectureStyle:
          'Statue équestre impériale en bronze sur socle monolithique',
      locationDetails:
          'Boulevard du 22 Octobre, Hamdallaye ACI 2000, Bamako',
      photoUrl:
          'assets/images/culture/monuments/monument_samory_toure_bamako/sam1.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_samory_toure_bamako/sam1.jpg',
        'assets/images/culture/monuments/monument_samory_toure_bamako/sam10.jpg',
        'assets/images/culture/monuments/monument_samory_toure_bamako/sam2.jpg',
        'assets/images/culture/monuments/monument_samory_toure_bamako/sam3.jpg',
      ],
      tag: 'Monument Historique de Résistance',
      latitude: 12.6348,
      longitude: -8.0315,
      unlockedBadge: 'Cavalier du Ouassoulou',
      xpEarned: 55,
      keywords: [
        'samory',
        'toure',
        'almamy',
        'cavalier',
        'cheval',
        'ouassoulou',
        'resistance',
        'aci 2000',
        'bamako',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Statue équestre en bronze (cheval cabré)',
          confidence: 0.993,
          category: 'Sculpture',
          icon: Icons.sports_score_rounded,
        ),
        ScanDetectionFeature(
          label: 'Almamy en tenue guerrière et sabre au côté',
          confidence: 0.986,
          category: 'Détail',
          icon: Icons.shield_rounded,
        ),
        ScanDetectionFeature(
          label: 'Implantation sur le rond-point d\'ACI 2000',
          confidence: 0.975,
          category: 'Topographie',
          icon: Icons.place_rounded,
        ),
      ],
      secretsAndMysteries:
          'Samory Touré avait organisé une armée moderne de 30 000 sofa et développé des forges artisanales capables de fabriquer des répliques fidèles des fusils à tir rapide Chassepot et Kropatschek.',
      historicalStory:
          'L\'Almamy Samory Touré (1830-1900) résista pendant près de vingt ans aux armées coloniales avec une intelligence tactique qui suscita le respect des généraux de son siècle.',
      audioNarrationText:
          'Vous voici devant la statue équestre de l\'Almamy Samory Touré. Fondateur de l\'Empire du Ouassoulou, il est l\'une des figures militaires les plus remarquables de l\'histoire africaine.',
      whyItMatters:
          'Symbole de la résistance acharnée et de la capacité industrielle précoloniale.',
      routePath: '/culture/monuments',
      arAvailable: false,
      validationStatus: 'Validé',
    ),

    // 6. MONUMENT DES MARTYRS
    MonumentScanTarget(
      id: 'monument_martyrs_bamako',
      name: 'Monument des Martyrs',
      subtitle: 'Hommage au soulèvement démocratique du 26 Mars 1991',
      regionId: 'bamako',
      regionName: 'District de Bamako',
      ville: 'Bamako',
      era: 'Érigé en 1993 • IIIe République',
      architectureStyle:
          'Mémorial géométrique moderne en marbre blanc et structures ajourées sur les rives du fleuve Niger',
      locationDetails: 'Tête du Pont des Martyrs, Badalabougou, Bamako',
      photoUrl:
          'assets/images/culture/monuments/monument_martyrs_bamako/mart1.webp',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_martyrs_bamako/mart1.webp',
        'assets/images/culture/monuments/monument_martyrs_bamako/mart10.jpg',
        'assets/images/culture/monuments/monument_martyrs_bamako/mart2.jpg',
        'assets/images/culture/monuments/monument_martyrs_bamako/mart3.jpg',
      ],
      tag: 'Sanctuaire Démocratique',
      latitude: 12.6358,
      longitude: -7.9942,
      unlockedBadge: 'Flambeau Démocratique',
      xpEarned: 55,
      keywords: [
        'martyrs',
        'democratie',
        'pont',
        'mars',
        '1991',
        'fleuve',
        'liberte',
        'bamako',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Stèle commémorative stylisée et flamme du souvenir',
          confidence: 0.990,
          category: 'Structure',
          icon: Icons.local_fire_department_rounded,
        ),
        ScanDetectionFeature(
          label: 'Arcs et bas-reliefs gravés des martyrs de la liberté',
          confidence: 0.982,
          category: 'Sculpture',
          icon: Icons.history_edu_rounded,
        ),
        ScanDetectionFeature(
          label: 'Emplacement emblématique à la tête du Pont des Martyrs',
          confidence: 0.975,
          category: 'Topographie',
          icon: Icons.alt_route_rounded,
        ),
      ],
      secretsAndMysteries:
          'Chaque 26 mars, le Président de la République et les associations de la société civile viennent y déposer une gerbe de fleurs en mémoire des pionniers qui ont offert leur vie pour la démocratie pluraliste.',
      historicalStory:
          'Le 26 mars 1991 marque la chute de la dictature militaire et la naissance du renouveau démocratique au Mali. Ce monument perpétue la bravoure de la jeunesse et des femmes maliennes.',
      audioNarrationText:
          'Vous êtes au Monument des Martyrs, érigé au bord du majestueux fleuve Niger. Il honore les femmes et les hommes tombés en mars 1991 pour la démocratie et la dignité du Mali.',
      whyItMatters:
          'Cœur de la mémoire citoyenne et de l\'avènement de la IIIe République.',
      routePath: '/culture/monuments',
      arAvailable: false,
      validationStatus: 'Validé Archives Nationales',
    ),

    // 7. MONUMENT KWAMÉ NKRUMAH
    MonumentScanTarget(
      id: 'monument_kwame_nkrumah_bamako',
      name: 'Monument Kwamé Nkrumah',
      subtitle: 'Hommage à l\'Apôtre des États-Unis d\'Afrique',
      regionId: 'bamako',
      regionName: 'District de Bamako',
      ville: 'Bamako',
      era: 'Érigé dans les années 1990',
      architectureStyle:
          'Buste commémoratif en bronze monté sur stèle trapézoïdale de marbre sombre',
      locationDetails: 'Avenue Kwamé Nkrumah, Hamdallaye, Bamako',
      photoUrl:
          'assets/images/culture/monuments/monument_kwame_nkrumah_bamako/kk1.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_kwame_nkrumah_bamako/kk1.jpg',
        'assets/images/culture/monuments/monument_kwame_nkrumah_bamako/kk10.jpg',
        'assets/images/culture/monuments/monument_kwame_nkrumah_bamako/kk2.jpg',
        'assets/images/culture/monuments/monument_kwame_nkrumah_bamako/kk3.jpg',
      ],
      tag: 'Panafricanisme & Fraternité',
      latitude: 12.6380,
      longitude: -8.0120,
      unlockedBadge: 'Visionnaire de l\'Unité Africaine',
      xpEarned: 50,
      keywords: [
        'nkrumah',
        'kwame',
        'panafricanisme',
        'ghana',
        'modibo',
        'bamako',
        'afrique',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Buste sculpté en bronze de Kwamé Nkrumah',
          confidence: 0.991,
          category: 'Sculpture',
          icon: Icons.person_rounded,
        ),
        ScanDetectionFeature(
          label: 'Stèle sombre gravée de maximes panafricaines',
          confidence: 0.980,
          category: 'Matériau',
          icon: Icons.auto_stories_rounded,
        ),
        ScanDetectionFeature(
          label: 'Rond-point arboré sur l\'avenue éponyme',
          confidence: 0.970,
          category: 'Environnement',
          icon: Icons.park_rounded,
        ),
      ],
      secretsAndMysteries:
          'Kwamé Nkrumah et Modibo Keïta conclurent l\'Union Guinée-Ghana-Mali en 1961, première tentative concrète de fusion politique panafricaine du XXe siècle.',
      historicalStory:
          'Ce monument célèbre la fraternité indissoluble entre le peuple malien et les pères de la libération africaine. Nkrumah voyait en Bamako le foyer ardent de la Renaissance africaine.',
      audioNarrationText:
          'Voici le Monument dédié au docteur Kwamé Nkrumah, héros de l\'indépendance du Ghana et champion infatigable de l\'Unité Africaine, honoré par la capitale malienne.',
      whyItMatters:
          'Symbole de la vision panafricaine partagée entre le Mali et les bâtisseurs du continent.',
      routePath: '/culture/monuments',
      arAvailable: false,
      validationStatus: 'Validé',
    ),

    // 8. CATHÉDRALE DU SACRÉ-CŒUR DE BAMAKO
    MonumentScanTarget(
      id: 'monument_cathedrale_bamako',
      name: 'Cathédrale du Sacré-Cœur',
      subtitle: 'Chef-d\'œuvre de pierre et de coexistence pacifique',
      regionId: 'bamako',
      regionName: 'District de Bamako',
      ville: 'Bamako',
      era: 'Construite entre 1925 et 1936',
      architectureStyle:
          'Style néo-roman byzantin en grès rouge de Kati et pierres taillées',
      locationDetails: 'Avenue Modibo Keïta, Centre-ville, Bamako',
      photoUrl:
          'assets/images/culture/monuments/monument_cathedrale_bamako/cat1.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_cathedrale_bamako/cat1.jpg',
        'assets/images/culture/monuments/monument_cathedrale_bamako/cat10.jpg',
        'assets/images/culture/monuments/monument_cathedrale_bamako/cat2.jpg',
        'assets/images/culture/monuments/monument_cathedrale_bamako/cat3.jpg',
      ],
      tag: 'Patrimoine Spirituel & Architectural',
      latitude: 12.6450,
      longitude: -7.9970,
      unlockedBadge: 'Harmonie Interreligieuse',
      xpEarned: 55,
      keywords: [
        'cathedrale',
        'sacre coeur',
        'eglise',
        'kati',
        'gres',
        'bamako',
        'centre-ville',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Façade massive en pierres de taille de grès rouge',
          confidence: 0.993,
          category: 'Matériau',
          icon: Icons.foundation_rounded,
        ),
        ScanDetectionFeature(
          label: 'Campanile roman élancé et clocher central',
          confidence: 0.985,
          category: 'Structure',
          icon: Icons.church_rounded,
        ),
        ScanDetectionFeature(
          label: 'Vitraux polychromes et portail cintré',
          confidence: 0.978,
          category: 'Détail',
          icon: Icons.auto_awesome_rounded,
        ),
      ],
      secretsAndMysteries:
          'Les pierres ayant servi à sa construction furent extraites manuellement des carrières de Kati et transportées par les ouvriers maliens, illustrant une rare maîtrise de la taille de pierre.',
      historicalStory:
          'Siège de l\'archevêché de Bamako, la cathédrale est un témoignage vivant de la laïcité harmonieuse et de la fraternité séculaire entre chrétiens et musulmans au Mali.',
      audioNarrationText:
          'Vous contemplez la Cathédrale du Sacré-Cœur de Bamako, bâtie en solide grès de Kati dès 1925. Elle reflète la tolérance et la paix religieuse qui caractérisent le Mali.',
      whyItMatters:
          'Joyau patrimonial urbain et symbole de concorde confessionnelle.',
      routePath: '/culture/monuments',
      arAvailable: false,
      validationStatus: 'Validé',
    ),

    // 9. STATUE DE SOGOLON KOLONKAN
    MonumentScanTarget(
      id: 'monument_sogolon_bamako',
      name: 'Statue de Sogolon Kolonkan',
      subtitle: 'L\'Héroïne Mystique du Mandé et Mère de Soundiata',
      regionId: 'bamako',
      regionName: 'District de Bamako',
      ville: 'Bamako',
      era: 'Érigée pour la valorisation du Matrimoine',
      architectureStyle:
          'Sculpture monumentale figurative représentant la femme matrice du Mandé',
      locationDetails: 'Boulevard de l\'OUA / ACI 2000, Bamako',
      photoUrl:
          'assets/images/culture/monuments/monument_sogolon_bamako/sog1.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_sogolon_bamako/sog1.jpg',
        'assets/images/culture/monuments/monument_sogolon_bamako/sog10.jpg',
        'assets/images/culture/monuments/monument_sogolon_bamako/sog2.jpg',
        'assets/images/culture/monuments/monument_sogolon_bamako/sog3.jpg',
      ],
      tag: 'Matrimoine & Épopée Mandingue',
      latitude: 12.6340,
      longitude: -8.0200,
      unlockedBadge: 'Héritier de Sogolon',
      xpEarned: 55,
      keywords: [
        'sogolon',
        'kolonkan',
        'mande',
        'soundiata',
        'femme',
        'matrimoine',
        'bamako',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Silhouette sculptée de la mère protectrice mandingue',
          confidence: 0.992,
          category: 'Sculpture',
          icon: Icons.female_rounded,
        ),
        ScanDetectionFeature(
          label: 'Attributs traditionnels et parures féminines soudanaises',
          confidence: 0.984,
          category: 'Détail',
          icon: Icons.flare_rounded,
        ),
        ScanDetectionFeature(
          label: 'Socle gravé des versets de la Charte de Kurukan Fuga',
          confidence: 0.976,
          category: 'Texte',
          icon: Icons.history_edu_rounded,
        ),
      ],
      secretsAndMysteries:
          'Sogolon Kèdjou possédait selon l\'épopée le pouvoir du double totem du buffle sacré de Do. C\'est sa clairvoyance et son abnégation qui ont rendu possible le destin grandiose de Soundiata Keïta.',
      historicalStory:
          'Ce monument rend hommage aux femmes du Mali, gardiennes de la paix, des secrets botaniques et de la cohésion sociale depuis la fondation de l\'Empire en 1236.',
      audioNarrationText:
          'Voici la statue dédiée à Sogolon Kolonkan et Sogolon Kèdjou. Dans l\'Épopée du Mandé, ces femmes d\'exception ont forgé le destin du grand conquérant Soundiata.',
      whyItMatters:
          'Consécration du rôle fondamental de la femme dans l\'histoire et la culture maliennes.',
      routePath: '/culture/monuments',
      arAvailable: false,
      validationStatus: 'Validé',
    ),

    // 10. MONUMENT AL-QOODS (AL-QODS)
    MonumentScanTarget(
      id: 'monument_al_quouds',
      name: 'Monument Al-Qoods (Al-Qods)',
      subtitle: 'Symbole de Fraternité Internationale et de Paix Sacrée',
      regionId: 'bamako',
      regionName: 'District de Bamako',
      ville: 'Bamako',
      era: 'Inauguré dans les années 2000',
      architectureStyle:
          'Dôme doré oriental surmonté du croissant et arcades mauresques élancées',
      locationDetails: 'Carrefour d\'Hamdallaye ACI 2000, Bamako',
      photoUrl:
          'assets/images/culture/monuments/monument_al_quouds/qu1.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_al_quouds/qu1.jpg',
        'assets/images/culture/monuments/monument_al_quouds/qu10.jpg',
        'assets/images/culture/monuments/monument_al_quouds/qu2.jpg',
        'assets/images/culture/monuments/monument_al_quouds/qu3.jpg',
      ],
      tag: 'Solidarité & Architecture Mauresque',
      latitude: 12.6360,
      longitude: -8.0250,
      unlockedBadge: 'Porteur de Solidarité',
      xpEarned: 50,
      keywords: [
        'al-qods',
        'quouds',
        'dome',
        'croissant',
        'arcades',
        'solidarite',
        'bamako',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Coupole dorée scintillante et flèche au croissant',
          confidence: 0.994,
          category: 'Structure',
          icon: Icons.brightness_7_rounded,
        ),
        ScanDetectionFeature(
          label: 'Arcades en fer à cheval mauresques ajourées',
          confidence: 0.986,
          category: 'Architecture',
          icon: Icons.account_balance_rounded,
        ),
        ScanDetectionFeature(
          label: 'Jardin circulaire paysager et carrefour ACI',
          confidence: 0.978,
          category: 'Topographie',
          icon: Icons.place_rounded,
        ),
      ],
      secretsAndMysteries:
          'Le monument a été conçu en hommage à la ville sainte d\'Al-Qods et incarne la position constante du Mali en faveur du droit des peuples et de la justice internationale.',
      historicalStory:
          'Érigé au cœur de l\'expansion moderne d\'ACI 2000, le Monument Al-Qoods rappelle les liens historiques et culturels profonds unissant le Mali aux civilisations du monde arabo-musulman.',
      audioNarrationText:
          'Vous admirez le Monument Al-Qods, reconnaissable à son dôme éclatant et ses fines arcades orientales. Il reflète la fraternité spirituelle et la quête de paix universelle.',
      whyItMatters:
          'Repère visuel majeur du quartier d\'affaires de la capitale malienne.',
      routePath: '/culture/monuments',
      arAvailable: false,
      validationStatus: 'Validé',
    ),

    // 11. MONUMENT MALIBA (LE GRAND MALI)
    MonumentScanTarget(
      id: 'monument_maliba_bamako',
      name: 'Monument MaliBa (Grand Mali)',
      subtitle: 'L\'Emblème de l\'Unité Patriotique et de la Fierté Nationale',
      regionId: 'bamako',
      regionName: 'District de Bamako',
      ville: 'Bamako',
      era: 'Création contemporaine',
      architectureStyle:
          'Lettres sculpturales monumentales polychromes aux couleurs nationales Vert-Jaune-Rouge',
      locationDetails: 'Grand Axe Urbain, Commune II / Centre-ville, Bamako',
      photoUrl:
          'assets/images/culture/monuments/monument_maliba_bamako/mb1.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_maliba_bamako/mb1.jpg',
        'assets/images/culture/monuments/monument_maliba_bamako/mb2.jpg',
        'assets/images/culture/monuments/monument_maliba_bamako/mb3.jpg',
        'assets/images/culture/monuments/monument_maliba_bamako/mb4.jpg',
      ],
      tag: 'Fierté Civique & Jeunesse',
      latitude: 12.6480,
      longitude: -8.0010,
      unlockedBadge: 'Cœur Battant MaliBa',
      xpEarned: 50,
      keywords: [
        'maliba',
        'patriotisme',
        'vert jaune rouge',
        'lettres',
        'fierte',
        'unite',
        'bamako',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Typographie sculpturale 3D « MALIBA »',
          confidence: 0.995,
          category: 'Typographie',
          icon: Icons.text_fields_rounded,
        ),
        ScanDetectionFeature(
          label: 'Triptyque chromatique Vert, Jaune d\'or et Rouge',
          confidence: 0.988,
          category: 'Couleur',
          icon: Icons.palette_rounded,
        ),
        ScanDetectionFeature(
          label: 'Plateforme piétonne festive pour la citoyenneté',
          confidence: 0.978,
          category: 'Espace',
          icon: Icons.photo_camera_rounded,
        ),
      ],
      secretsAndMysteries:
          '« MaliBa » signifie littéralement le « Grand Mali » en bambara, faisant écho à l\'immensité de son passé impérial et à l\'espérance invincible de sa jeunesse contemporaine.',
      historicalStory:
          'Lieu de rassemblement civique très prisé par les jeunes générations et les visiteurs, cette œuvre matérialise l\'attachement indéfectible à la patrie et aux valeurs du drapeau national.',
      audioNarrationText:
          'Voici le Monument MaliBa ! Ses lettres géantes aux trois couleurs nationales célèbrent le Grand Mali uni, fort de son histoire millénaire et résolument tourné vers l\'avenir.',
      whyItMatters:
          'Le spot photo citoyen le plus populaire et vibrant de Bamako.',
      routePath: '/culture/monuments',
      arAvailable: false,
      validationStatus: 'Validé',
    ),

    // 12. PLACE DE LA LIBERTÉ & OBÉLISQUE
    MonumentScanTarget(
      id: 'monument_obelisque_bamako',
      name: 'Place de la Liberté & Obélisque',
      subtitle: 'Le Cœur Civique et Historique de Bamako',
      regionId: 'bamako',
      regionName: 'District de Bamako',
      ville: 'Bamako',
      era: 'Aménagée dès le début du XXe siècle',
      architectureStyle:
          'Esplanade circulaire pavée centrée sur une stèle obélisque commémorative',
      locationDetails: 'Place de la Liberté, Centre-ville, Commune III, Bamako',
      photoUrl:
          'assets/images/culture/monuments/monument_obelisque_bamako/ob10.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_obelisque_bamako/ob10.jpg',
        'assets/images/culture/monuments/monument_obelisque_bamako/ob11.jpg',
        'assets/images/culture/monuments/monument_obelisque_bamako/ob2.jpg',
        'assets/images/culture/monuments/monument_obelisque_bamako/ob3.jpg',
      ],
      tag: 'Cœur Historique de Bamako',
      latitude: 12.6510,
      longitude: -7.9985,
      unlockedBadge: 'Citoyen de la Liberté',
      xpEarned: 50,
      keywords: [
        'liberte',
        'obelisque',
        'place',
        'centre-ville',
        'commune 3',
        'bamako',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Obélisque central en pierre et bas-reliefs',
          confidence: 0.990,
          category: 'Structure',
          icon: Icons.account_balance_rounded,
        ),
        ScanDetectionFeature(
          label: 'Vaste rond-point pavé bordé d\'arbres centenaires',
          confidence: 0.982,
          category: 'Urbanisme',
          icon: Icons.traffic_rounded,
        ),
        ScanDetectionFeature(
          label: 'Perspective vers les bâtiments coloniaux et le marché',
          confidence: 0.974,
          category: 'Vue',
          icon: Icons.visibility_rounded,
        ),
      ],
      secretsAndMysteries:
          'La Place de la Liberté est le point zéro historique à partir duquel s\'est développée l\'urbanisation moderne de Bamako au pied de la colline de Koulouba.',
      historicalStory:
          'Carrefour incontournable entre la ville administrative et le grand marché grouillant, la Place de la Liberté est le témoin quotidien des grands événements politiques et populaires maliens.',
      audioNarrationText:
          'Vous êtes sur la Place de la Liberté, véritable centre névralgique de Bamako. Son obélisque et son esplanade incarnent le pouls vivant de la cité depuis plus d\'un siècle.',
      whyItMatters:
          'Le carrefour historique et civique le plus célèbre de la capitale.',
      routePath: '/culture/monuments',
      arAvailable: false,
      validationStatus: 'Validé',
    ),

    // ══════════════════════════════════════════════════════════════════════════
    // ── MONUMENTS NATIONAUX DES RÉGIONS (AVEC PHOTOS RÉELLES DU DATASET) ─────
    // ══════════════════════════════════════════════════════════════════════════

    // 13. GRANDE MOSQUÉE DE DJENNÉ
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

    // 14. MOSQUÉE DJINGAREYBER DE TOMBOUCTOU
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
          'assets/images/culture/monuments/monument_djingareyber/djin1.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_djingareyber/djin1.jpg',
        'assets/images/culture/monuments/monument_djingareyber/djin10.jpg',
        'assets/images/culture/monuments/monument_djingareyber/djin2.jpg',
        'assets/images/culture/monuments/monument_djingareyber/djin3.jpg',
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

    // 15. FORT DE MÉDINE
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
          'assets/images/culture/monuments/monument_fort_medine/med1.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/monument_fort_medine/med1.jpg',
        'assets/images/culture/monuments/monument_fort_medine/med10.jpg',
        'assets/images/culture/monuments/monument_fort_medine/med2.jpg',
        'assets/images/culture/monuments/monument_fort_medine/med3.jpg',
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

    // 16. SÉGOU-KORO & CITÉ DES BALANZANS
    MonumentScanTarget(
      id: 'segou',
      name: 'Ségou-Koro & Cité des Balanzans',
      subtitle: 'La Cité Royale Fondatrice du Royaume Bambara',
      regionId: 'segou',
      regionName: 'Ségou',
      ville: 'Ségou',
      era: 'Fondée au XVIIe siècle • Apogée sous Biton Coulibaly (1712-1755)',
      architectureStyle:
          'Architecture traditionnelle soudanaise en banco, vestibules royaux et sanctuaires ancestraux',
      locationDetails: 'Bord du fleuve Niger, Ségou-Koro (à 10 km de Ségou)',
      photoUrl:
          'assets/images/culture/monuments/segou/segou_!.jpg',
      galleryPhotos: [
        'assets/images/culture/monuments/segou/segou_!.jpg',
      ],
      tag: 'Capitale Royale Historique',
      latitude: 13.4333,
      longitude: -6.2667,
      unlockedBadge: 'Noble du Royaume Bambara',
      xpEarned: 60,
      keywords: [
        'segou',
        'segou-koro',
        'biton',
        'coulibaly',
        'balanzans',
        'bambara',
        'djoliba',
        'banco',
      ],
      detectionFeatures: [
        ScanDetectionFeature(
          label: 'Vestibule royal en banco ancestral de Biton Coulibaly',
          confidence: 0.992,
          category: 'Structure',
          icon: Icons.castle_rounded,
        ),
        ScanDetectionFeature(
          label: 'Mosquée historique de Ba Sounou Sako',
          confidence: 0.985,
          category: 'Architecture',
          icon: Icons.mosque_rounded,
        ),
        ScanDetectionFeature(
          label: 'Arbres Balanzans sacrés en bordure du Djoliba',
          confidence: 0.976,
          category: 'Nature',
          icon: Icons.nature_rounded,
        ),
      ],
      secretsAndMysteries:
          'La légende raconte que Ségou est protégée par ses 4 444 balanzans sacrés (Acacia albida), plus un arbre mystérieux introuvable qui veille sur la paix du royaume.',
      historicalStory:
          'Ancienne capitale de l\'Empire Bambara de Ségou, la cité conserve la tombe du fondateur Mamary Biton Coulibaly et les premières mosquées bâties au cœur des traditions ancestrales.',
      audioNarrationText:
          'Bienvenue à Ségou-Koro, le berceau du puissant Royaume Bambara. C\'est ici que Biton Coulibaly organisa ses célèbres guerriers Tònjon et fit rayonner la culture des balanzans.',
      whyItMatters:
          'L\'un des sanctuaires dynastiques les plus vénérés de la mémoire bamanan.',
      routePath: '/culture/monuments',
      arAvailable: false,
      validationStatus: 'Validé Patrimoine National',
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

  /// Trouver tous les monuments situés à Bamako
  static List<MonumentScanTarget> get bamakoTargets {
    return targets
        .where(
          (t) =>
              t.ville.toLowerCase() == 'bamako' || t.regionId == 'bamako',
        )
        .toList();
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
