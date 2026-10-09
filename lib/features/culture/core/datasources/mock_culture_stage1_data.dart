import 'package:flutter/material.dart';
import '../models/culture_item.dart';

/// Données mock obsolètes - REMPLACÉES PAR LA BASE DE DONNÉES
@Deprecated('Obsolète : Utiliser exclusivement la base de données centrale via culture_data_providers et CultureRepository.')
abstract final class MockCultureStage1Data {
  // ── 1. ÉLÉMENT À LA UNE (ACCUEIL) ──────────────────────────────────────────
  static const CultureItem featuredItem = CultureItem(
    id: 'featured_soundiata',
    title: 'Soundiata Keïta & la Charte du Manden',
    subtitle: 'Le fondateur de l\'Empire du Mali et la proclamation de 1236',
    category: 'accueil',
    subCategory: 'personnages',
    description:
        'Découvrez l\'épopée du Lion du Manden, sa victoire décisive à Kirina en 1235 et la proclamation de l\'une des premières déclarations des droits humains à Kouroukan Fouga.',
    regionId: 'koulikoro',
    regionName: 'Koulikoro',
    tag: 'Épopée Majeure',
    icon: Icons.shield_rounded,
    imageUrl: 'assets/images/culture/personnages/soundiata.jpg',
    isFeatured: true,
    info: 'Lecture : 4 min',
  );

  // ── 2. GRANDS PERSONNAGES HISTORIQUES (DÉCOUVRIR) ──────────────────────────
  static const List<CultureItem> personnages = [
    CultureItem(
      id: 'perso_soundiata',
      title: 'Soundiata Keïta',
      subtitle: 'Le Lion du Manden & Fondateur de l\'Empire',
      category: 'decouvrir',
      subCategory: 'personnages',
      description:
          'Bâtisseur de l\'Empire du Mali et instigateur de la Charte de Kouroukan Fouga en 1236.',
      regionId: 'koulikoro',
      regionName: 'Koulikoro',
      tag: 'Mansa',
      icon: Icons.person_rounded,
      imageUrl: 'assets/images/culture/personnages/soundiata.jpg',
      info: '1190 – 1255',
    ),
    CultureItem(
      id: 'perso_mansa_moussa',
      title: 'Mansa Moussa',
      subtitle: 'L\'Empereur d\'Or & Mécène du Savoir',
      category: 'decouvrir',
      subCategory: 'personnages',
      description:
          'Souverain célèbre pour son pèlerinage de 1324 et l\'essor universel de Tombouctou et Gao.',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      tag: 'Âge d\'Or',
      icon: Icons.account_balance_rounded,
      imageUrl: 'assets/images/culture/personnages/mansa_moussa.jpg',
      info: '1312 – 1337',
    ),
    CultureItem(
      id: 'perso_babemba',
      title: 'Babemba Traoré',
      subtitle: 'Roi du Kénédougou & Héros de Sikasso',
      category: 'decouvrir',
      subCategory: 'personnages',
      description:
          'Défenseur héroïque du Tata de Sikasso, symbole absolu de dignité patriotique.',
      regionId: 'sikasso',
      regionName: 'Sikasso',
      tag: 'Résistance',
      icon: Icons.security_rounded,
      imageUrl: 'assets/images/culture/personnages/babemba_traore.jpg',
      info: '1893 – 1898',
    ),
    CultureItem(
      id: 'perso_askia_mohammed',
      title: 'Askia Mohammed',
      subtitle: 'Grand Réformateur de l\'Empire Songhoï',
      category: 'decouvrir',
      subCategory: 'personnages',
      description:
          'Bâtisseur d\'une administration brillante et mécène de l\'Université de Sankoré.',
      regionId: 'gao',
      regionName: 'Gao',
      tag: 'Empire Songhoï',
      icon: Icons.history_edu_rounded,
      imageUrl: 'assets/images/culture/personnages/askia_mohammed.jpg',
      info: '1493 – 1528',
    ),
    CultureItem(
      id: 'perso_biton_coulibaly',
      title: 'Biton Coulibaly',
      subtitle: 'Fondateur du Royaume Bambara de Ségou',
      category: 'decouvrir',
      subCategory: 'personnages',
      description:
          'Créateur de l\'organisation militaire des Tônjons et de la puissance de Ségou.',
      regionId: 'segou',
      regionName: 'Ségou',
      tag: 'Royaume de Ségou',
      icon: Icons.military_tech_rounded,
      imageUrl: 'assets/images/culture/personnages/biton_coulibaly.jpg',
      info: '1712 – 1755',
    ),
  ];

  // ── 3. VILLES & VILLAGES (DÉCOUVRIR) ───────────────────────────────────────
  static const List<CultureItem> villes = [
    CultureItem(
      id: 'ville_djenne',
      title: 'Djenné',
      subtitle: 'La Cité Millénaire en Banco',
      category: 'decouvrir',
      subCategory: 'villes',
      description:
          'Joyau de la vallée du Bani, réputé pour sa prestigieuse architecture soudano-sahélienne.',
      regionId: 'mopti',
      regionName: 'Mopti',
      tag: 'UNESCO',
      icon: Icons.location_city_rounded,
      imageUrl: 'assets/images/culture/villes/djenne_ville.jpg',
      info: 'Fondée au IXe s.',
    ),
    CultureItem(
      id: 'ville_segou_koro',
      title: 'Ségou-Koro',
      subtitle: 'Le Berceau des 4 444 Balanzans',
      category: 'decouvrir',
      subCategory: 'villes',
      description:
          'L\'ancienne capitale royale où repose le roi Biton Coulibaly au bord du Djoliba.',
      regionId: 'segou',
      regionName: 'Ségou',
      tag: 'Cité Royale',
      icon: Icons.nature_people_rounded,
      imageUrl: 'assets/images/culture/villes/segou_koro.jpg',
      info: 'Bord du Niger',
    ),
    CultureItem(
      id: 'ville_bandiagara',
      title: 'Bandiagara & Falaise',
      subtitle: 'Les Villages Suspendus du Pays Dogon',
      category: 'decouvrir',
      subCategory: 'villes',
      description:
          'Villages séculaires accrochés au grès rouge, avec leurs Togunas et greniers ancestraux.',
      regionId: 'mopti',
      regionName: 'Mopti',
      tag: 'Pays Dogon',
      icon: Icons.terrain_rounded,
      imageUrl: 'assets/images/culture/villes/bandiagara_falaise.jpg',
      info: 'Falaise de 150 km',
    ),
    CultureItem(
      id: 'ville_tombouctou',
      title: 'Tombouctou',
      subtitle: 'La Cité des 333 Saints & des Manuscrits',
      category: 'decouvrir',
      subCategory: 'villes',
      description:
          'Carrefour transsaharien mythique ayant abrité les plus grands savants d\'Afrique.',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      tag: 'Savoirs Sahéliens',
      icon: Icons.menu_book_rounded,
      imageUrl: 'assets/images/culture/villes/tombouctou_ville.jpg',
      info: 'Carrefour des caravanes',
    ),
    CultureItem(
      id: 'ville_sikasso',
      title: 'Sikasso',
      subtitle: 'Le Verger du Mali & la Cité du Kénédougou',
      category: 'decouvrir',
      subCategory: 'villes',
      description:
          'Capitale verdoyante et généreuse, gardienne des mémoires du roi Tiéba et Babemba.',
      regionId: 'sikasso',
      regionName: 'Sikasso',
      tag: 'Kénédougou',
      icon: Icons.park_rounded,
      imageUrl: 'assets/images/culture/villes/sikasso_ville.jpg',
      info: 'Terroir agricole',
    ),
  ];

  // ── 4. MONUMENTS HISTORIQUES (DÉCOUVRIR) ───────────────────────────────────
  static const List<CultureItem> monuments = [
    // 1. Grande Mosquée de Djenné (Mopti)
    CultureItem(
      id: 'monument_mosquee_djenne',
      title: 'Grande Mosquée de Djenné',
      subtitle: 'Chef-d\'œuvre de l\'architecture en terre crue',
      category: 'decouvrir',
      subCategory: 'monuments',
      description:
          'Le plus grand édifice en terre crue (banco) au monde, chef-d\'œuvre du style soudano-sahélien inscrit au Patrimoine mondial UNESCO.',
      regionId: 'mopti',
      regionName: 'Mopti',
      tag: 'Patrimoine UNESCO',
      icon: Icons.museum_rounded,
      imageUrl:
          'assets/images/culture/monuments/monument_mosquee_djenne/dje_1.webp',
      info: 'Mopti · Djenné',
    ),

    // 2. Mosquée Djingareyber (Tombouctou)
    CultureItem(
      id: 'monument_djingareyber',
      title: 'Mosquée Djingareyber',
      subtitle: 'Le Grand Sanctuaire de Mansa Moussa (1327)',
      category: 'decouvrir',
      subCategory: 'monuments',
      description:
          'Sanctuaire séculaire dessiné par Abou Ishaq es-Sahéli sur commande de Mansa Moussa, cœur spirituel de Tombouctou.',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      tag: 'Patrimoine UNESCO',
      icon: Icons.domain_rounded,
      imageUrl:
          'assets/images/culture/monuments/monument_djingareyber/wm_djin_1.jpg',
      info: 'Tombouctou · 1327',
    ),

    // 3. Université & Mosquée de Sankoré (Tombouctou)
    CultureItem(
      id: 'monument_sankore',
      title: 'Université & Mosquée de Sankoré',
      subtitle: 'Le Phare Universitaire de l\'Afrique Médiévale',
      category: 'decouvrir',
      subCategory: 'monuments',
      description:
          'Haut lieu du savoir médiéval ayant accueilli plus de 25 000 étudiants et conservé des centaines de milliers de manuscrits précieux.',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      tag: 'Patrimoine UNESCO',
      icon: Icons.school_rounded,
      imageUrl:
          'assets/images/culture/monuments/monument_sankore/wm_san_1.jpg',
      info: 'Tombouctou · XIVe siècle',
    ),

    // 4. Tombeau des Askia (Gao)
    CultureItem(
      id: 'monument_tombeau_askia',
      title: 'Tombeau pyramidal des Askia',
      subtitle: 'La Pyramide Sahélienne de l\'Empire Songhoï',
      category: 'decouvrir',
      subCategory: 'monuments',
      description:
          'Structure pyramidale majestueuse en banco de 17 mètres édifiée à Gao en 1495 par l\'empereur Askia Mohammed.',
      regionId: 'gao',
      regionName: 'Gao',
      tag: 'Patrimoine UNESCO',
      icon: Icons.architecture_rounded,
      imageUrl:
          'assets/images/culture/monuments/monument_tombeau_askia/wm_tomb_1.jpg',
      info: 'Gao · 1495',
    ),

    // 5. Monument de l'Indépendance (Bamako)
    CultureItem(
      id: 'monument_independance_bamako',
      title: 'Monument de l\'Indépendance',
      subtitle: 'Symbole de la Souveraineté du Mali (1960)',
      category: 'decouvrir',
      subCategory: 'monuments',
      description:
          'Érigé au cœur de Bamako, ce monument célèbre l\'accession du Mali à l\'indépendance le 22 septembre 1960 sous Modibo Keïta.',
      regionId: 'bamako',
      regionName: 'Bamako',
      tag: 'Symbole National',
      icon: Icons.flag_rounded,
      imageUrl:
          'assets/images/culture/monuments/monument_independance_bamako/ind_24.jpg',
      info: 'Bamako · 1960',
    ),

    // 6. Tour de l'Afrique (Bamako)
    CultureItem(
      id: 'monument_tour_afrique_bamako',
      title: 'Tour de l\'Afrique',
      subtitle: 'Phare du Panafricanisme & de la Mémoire Continentale',
      category: 'decouvrir',
      subCategory: 'monuments',
      description:
          'Monument cylindrique colossal de 46 mètres évoquant un baobab et un minaret, dédié aux pères de l\'unité africaine.',
      regionId: 'bamako',
      regionName: 'Bamako',
      tag: 'Panafricanisme',
      icon: Icons.apartment_rounded,
      imageUrl:
          'assets/images/culture/monuments/monument_tour_afrique_bamako/wm_tour_1.jpg',
      info: 'Bamako · Faladié',
    ),

    // 7. Fort de Médine (Kayes)
    CultureItem(
      id: 'monument_fort_medine',
      title: 'Fort de Médine',
      subtitle: 'Sentinelle historique du Haut-Sénégal',
      category: 'decouvrir',
      subCategory: 'monuments',
      description:
          'Forteresse en pierres taillées de grès rouge dominant le fleuve Sénégal, témoin du siège historique de 1857.',
      regionId: 'kayes',
      regionName: 'Kayes',
      tag: 'Site Historique National',
      icon: Icons.fort_rounded,
      imageUrl:
          'assets/images/culture/monuments/monument_fort_medine/wm_med_1.jpg',
      info: 'Kayes · Médine',
    ),

    // 8. Le Tata de Sikasso (Sikasso)
    CultureItem(
      id: 'monument_tata_sikasso',
      title: 'Le Tata de Sikasso',
      subtitle: 'La Muraille Héroïque de Résistance du Kénédougou',
      category: 'decouvrir',
      subCategory: 'monuments',
      description:
          'Imposante muraille fortifiée en banco et pierres latéritiques longue de 9 km ayant défendu le royaume du Kénédougou.',
      regionId: 'sikasso',
      regionName: 'Sikasso',
      tag: 'Monument National Historique',
      icon: Icons.castle_rounded,
      imageUrl:
          'assets/images/culture/monuments/monument_tata_sikasso/wm_tata_1.jpg',
      info: 'Sikasso · Kénédougou',
    ),
  ];

  // ── 5. CONTES INTERACTIFS & TRADITIONS (CONTES) ───────────────────────────
  static const List<CultureItem> contes = [
    CultureItem(
      id: 'conte_lievre_hyene',
      title: 'Zoumana le Lièvre et Namori l\'Hyène',
      subtitle: 'La ruse de l\'esprit face à la force brute',
      category: 'contes',
      subCategory: 'contes_interactifs',
      description:
          'Une grande fable des veillées mandingues où la réflexion triomphe de la gourmandise.',
      regionId: null,
      regionName: 'Tout le Mali',
      tag: 'Conte Interactif',
      icon: Icons.auto_stories_rounded,
      info: 'Durée : 5 min',
    ),
    CultureItem(
      id: 'conte_wagadou_bida',
      title: 'La Légende du Serpent Wagadou Bida',
      subtitle: 'Le mythe fondateur de l\'Empire du Ghana',
      category: 'contes',
      subCategory: 'contes_interactifs',
      description:
          'L\'histoire du pacte sacré de Koumbi Saleh et de la pluie d\'or sur l\'ancien empire.',
      regionId: 'kayes',
      regionName: 'Kayes',
      tag: 'Récit Mythique',
      icon: Icons.psychology_alt_rounded,
      info: 'Récit des Griots',
    ),
    CultureItem(
      id: 'conte_forgeron_oiseau',
      title: 'Le Forgeron et l\'Oiseau du Djoliba',
      subtitle: 'Secret de la forge et respect des éléments',
      category: 'contes',
      subCategory: 'contes_interactifs',
      description:
          'Conte initiatique sur l\'alliance sacrée entre les maîtres du feu et la nature.',
      regionId: 'segou',
      regionName: 'Ségou',
      tag: 'Conte Initiatique',
      icon: Icons.local_fire_department_rounded,
      info: 'Tradition orale',
    ),
  ];

  // ── 6. DÉFIS & DEVINETTES (DÉFIS) ──────────────────────────────────────────
  static const List<CultureItem> defis = [
    CultureItem(
      id: 'defi_nda_baobab',
      title: '«   ! » — Les Énigmes du Baobab',
      subtitle: 'Devinettes traditionnelles Bambara',
      category: 'defis',
      subCategory: 'devinettes',
      description:
          'Répondez par «    sira » et élucidez les énigmes poétiques posées par nos aïeux.',
      regionId: null,
      regionName: 'Tout le Mali',
      tag: 'Jeu de Devinettes',
      icon: Icons.quiz_rounded,
      info: '10 Énigmes',
    ),
    CultureItem(
      id: 'defi_rois_empires',
      title: 'Le Grand Quiz des 3 Empires',
      subtitle: 'Ghana, Mali et Songhoï',
      category: 'defis',
      subCategory: 'devinettes',
      description:
          'Mesurez vos connaissances sur les dates clés, les dynasties et les grands héros du Mali.',
      regionId: null,
      regionName: 'Tout le Mali',
      tag: 'Quiz Culturel',
      icon: Icons.military_tech_rounded,
      info: 'Défi 10 questions',
    ),
    CultureItem(
      id: 'defi_chasseurs_manden',
      title: 'Les Maximes des Maîtres Chasseurs',
      subtitle: 'La sagesse de la confrérie des Dozo',
      category: 'defis',
      subCategory: 'devinettes',
      description:
          'Devinez le sens caché des proverbes et enseignements de la forêt sacrée.',
      regionId: 'koulikoro',
      regionName: 'Koulikoro',
      tag: 'Sagesse Dozo',
      icon: Icons.lightbulb_rounded,
      info: '5 Maximes',
    ),
  ];

  // ── FILTRE HELPERS ─────────────────────────────────────────────────────────
  static List<CultureItem> getFiltered({
    required List<CultureItem> source,
    String? regionId,
    String? query,
  }) {
    return source.where((item) {
      final matchesReg = item.matchesRegion(regionId);
      if (!matchesReg) return false;

      if (query == null || query.trim().isEmpty) return true;
      final q = query.trim().toLowerCase();
      return item.title.toLowerCase().contains(q) ||
          item.subtitle.toLowerCase().contains(q) ||
          item.description.toLowerCase().contains(q) ||
          item.regionName.toLowerCase().contains(q) ||
          item.tag.toLowerCase().contains(q);
    }).toList();
  }
}
