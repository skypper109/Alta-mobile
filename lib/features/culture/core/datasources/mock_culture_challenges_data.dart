import 'package:flutter/material.dart';
import '../models/culture_challenge_models.dart';

/// Banques de données authentiques des Devinettes « N'Da ! », Quiz et Missions
abstract final class MockCultureChallengesData {
  // ── 1. DEVINETTES TRADITIONNELLES (« N'DA ! ») ─────────────────────────────
  static const List<TraditionalRiddle> riddles = [
    // Devinette 1 : Le Vent (Fonyo)
    TraditionalRiddle(
      id: 'riddle_vent',
      formulaIntro: "« N'Da ! » — « N'Da n'sira ! »",
      riddleText:
          'Je voyage sans jambes et je parle sans bouche.\nJe caresse la tête du roi comme celle du mendiant.\nNul ne peut me voir, mais chacun entend mon passage.\n\nQui suis-je ?',
      hints: [
        '💡 Indice 1 : Je suis invisible mais capable de faire danser les branches des baobabs.',
        '💡 Indice 2 : Les piroguiers du Djoliba et les caravanes du désert scrutent ma direction.',
        '💡 Indice 3 : En saison sèche, je porte le nom d\'Harmattan.',
      ],
      options: [
        'Le Vent (Fonyo)',
        'L\'Ombre (Dounou)',
        'L\'Écho (Kuma)',
        'La Fumée (Sisi)',
      ],
      correctAnswer: 'Le Vent (Fonyo)',
      culturalExplanation:
          'Dans les veillées mandingues et sahéliennes, le vent (Fonyo) est perçu comme le messager invisible des esprits et le souffle de vie. Il rappelle que ce qui est invisible peut être plus puissant que ce qui se voit.',
      proverb: '« Le vent ne brise jamais l\'herbe qui sait se courber avec humilité. »',
      regionId: null,
      regionName: 'Tout le Mali',
      category: 'Éléments de la Nature',
      difficulty: 'Initié',
      xpReward: 50,
      photoUrl: 'assets/images/culture/villes/bandiagara_falaise.jpg',
    ),

    // Devinette 2 : L'Ombre
    TraditionalRiddle(
      id: 'riddle_ombre',
      formulaIntro: "« N'Da ! » — « N'Da n'sira ! »",
      riddleText:
          'Si tu marches, il marche avec toi.\nSi tu cours à perdre haleine, il court à tes côtés.\nMais dès que la nuit noire tombe, il s\'évanouit sans bruit.\n\nQui suis-je ?',
      hints: [
        '💡 Indice 1 : Il est toujours noir, quel que soit le tissu de ton boubou.',
        '💡 Indice 2 : Il grandit quand le soleil se couche et rétrécit à midi pile.',
        '💡 Indice 3 : Il te quitte dès que la flamme de la lampe s\'éteint.',
      ],
      options: [
        'L\'Ombre (Dounou)',
        'Le Reflet dans le fleuve',
        'Le Vêtement (Fani)',
        'La Trace de pas',
      ],
      correctAnswer: 'L\'Ombre (Dounou)',
      culturalExplanation:
          'L\'ombre symbolise le double spirituel (Ni ou Dya) dans la cosmogonie bambara et mandingue. Elle est le compagnon inséparable de l\'homme sur terre, témoin silencieux de ses actes.',
      proverb: '« L\'homme peut fuir son village, mais il ne peut fuir son ombre. »',
      regionId: 'segou',
      regionName: 'Ségou',
      category: 'Sagesse & Esprit',
      difficulty: 'Apprenti',
      xpReward: 45,
      photoUrl: 'assets/images/culture/villes/segou_koro.jpg',
    ),

    // Devinette 3 : Le Tam-tam / Djembé
    TraditionalRiddle(
      id: 'riddle_tamtam',
      formulaIntro: "« N'Da ! » — « N'Da n'sira ! »",
      riddleText:
          'Un tronc d\'arbre mort, coiffé de la peau d\'une chèvre.\nOn le frappe avec les mains, et pourtant tout le village se met à danser de joie.\n\nQui suis-je ?',
      hints: [
        '💡 Indice 1 : Les griots et forgerons taillent son bois dans le Lenké sacré.',
        '💡 Indice 2 : Il rythme les fêtes de moisson, les mariages et les intronisations.',
        '💡 Indice 3 : Ses frappes sont le Ton, le Slap et la Basse.',
      ],
      options: [
        'Le Djembé / Tam-tam',
        'Le Mortier à mil (Kourou)',
        'La Kora',
        'Le Balafon',
      ],
      correctAnswer: 'Le Djembé / Tam-tam',
      culturalExplanation:
          'Le djembé, né sous l\'Empire du Mali au XIIIe siècle, est l\'instrument de rassemblement par excellence. « Djembe » vient du proverbe « Anke djé, anke bé » qui signifie « Rassemblons-nous tous ensemble dans la paix ».',
      proverb: '« Le son du tambour ne dépasse pas le village qui sait l\'écouter. »',
      regionId: 'koulikoro',
      regionName: 'Koulikoro',
      category: 'Objets Sacrés & Musique',
      difficulty: 'Initié',
      xpReward: 60,
      photoUrl: 'assets/images/culture/personnages/soundiata.jpg',
    ),

    // Devinette 4 : La Pirogue sur le Djoliba
    TraditionalRiddle(
      id: 'riddle_pirogue',
      formulaIntro: "« N'Da ! » — « N'Da n'sira ! »",
      riddleText:
          'Un grand arbre couché qui glisse sur l\'eau sans jamais boire.\nIl porte cent sacs de mil et cinquante hommes sans couler,\nmais une simple goutte d\'eau au fond peut le faire pleurer.\n\nQui suis-je ?',
      hints: [
        '💡 Indice 1 : Les pêcheurs Bozos sont ses maîtres absolus.',
        '💡 Indice 2 : On la propulse avec une perche ou une pagaie en bois poli.',
        '💡 Indice 3 : Elle relie Koulikoro, Mopti et Tombouctou au gré du courant.',
      ],
      options: [
        'La Pirogue (Kounkoro)',
        'Le Crocodile du fleuve',
        'Le Pont des martyrs',
        'Le Filet de pêche (Djo)',
      ],
      correctAnswer: 'La Pirogue (Kounkoro)',
      culturalExplanation:
          'La pirogue est le symbole de la civilisation du fleuve Niger. Les Bozos, « maîtres des eaux », transmettent l\'art de sculpter ces embarcations et de négocier avec Faro, le génie du fleuve.',
      proverb: '« Si tu voyages dans la pirogue d\'autrui, ne critique pas la direction de la pagaie. »',
      regionId: 'mopti',
      regionName: 'Mopti',
      category: 'Objets & Métiers',
      difficulty: 'Apprenti',
      xpReward: 50,
      photoUrl: 'assets/images/culture/villes/djenne_ville.jpg',
    ),

    // Devinette 5 : Le Feu et la Cendre
    TraditionalRiddle(
      id: 'riddle_feu',
      formulaIntro: "« N'Da ! » — « N'Da n'sira ! »",
      riddleText:
          'La mère donne naissance à son fils dans la rougeur.\nMais quand le fils grandit et devient tout blanc,\nil étouffe et enterre sa propre mère.\n\nQui sommes-nous ?',
      hints: [
        '💡 Indice 1 : L\'un réchauffe les veillées et cuit le tô de mil.',
        '💡 Indice 2 : L\'autre reste au foyer au petit matin, grise et froide.',
        '💡 Indice 3 : L\'un est rouge et brûlant, l\'autre est cendre.',
      ],
      options: [
        'Le Feu et la Cendre (Tasuma & Bugun)',
        'Le Soleil et la Lune',
        'Le Mil et la Farine',
        'La Pluie et la Terre',
      ],
      correctAnswer: 'Le Feu et la Cendre (Tasuma & Bugun)',
      culturalExplanation:
          'Cette énigme philosophique enseigne la métamorphose et le cycle de la vie. Elle rappelle aux jeunes initiés que tout ce qui brille avec éclat finit par s\'apaiser dans le silence de la sagesse.',
      proverb: '« Même la plus grande flamme finit par dormir dans un lit de cendre. »',
      regionId: 'kayes',
      regionName: 'Kayes',
      category: 'Sagesse des Aînés',
      difficulty: 'Maître Dozo',
      xpReward: 70,
      photoUrl: 'assets/images/culture/monuments/fort_medine.jpg',
    ),

    // Devinette 6 : L'Aiguille et le Fil
    TraditionalRiddle(
      id: 'riddle_aiguille',
      formulaIntro: "« N'Da ! » — « N'Da n'sira ! »",
      riddleText:
          'J\'ai un seul œil percé dans la tête.\nJe traverse sans crainte les étoffes les plus denses,\nen traînant derrière moi une longue queue qui ne me quitte jamais.\n\nQui suis-je ?',
      hints: [
        '💡 Indice 1 : Les maîtres tisserands et tailleurs de boubous ne peuvent se passer de moi.',
        '💡 Indice 2 : Je réunis ce qui est déchiré.',
        '💡 Indice 3 : Mon corps est d\'acier fin et ma queue de coton filé.',
      ],
      options: [
        'L\'Aiguille et le Fil (Miseli)',
        'Le Serpent de brousse',
        'La Pirogue et sa corde',
        'La Flèche de chasse Dozo',
      ],
      correctAnswer: 'L\'Aiguille et le Fil (Miseli)',
      culturalExplanation:
          'L\'aiguille symbolise le lien social et la médiation dans la société malienne. Celui qui sait réconcilier deux clans rivaux est surnommé « l\'aiguille qui recoud le tissu de la paix ».',
      proverb: '« L\'aiguille perce le tissu, mais c\'est le fil qui le maintient uni. »',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      category: 'Objets Sacrés & Métiers',
      difficulty: 'Initié',
      xpReward: 55,
      photoUrl: 'assets/images/culture/villes/tombouctou_ville.jpg',
    ),
  ];

  // ── 2. QUIZ CULTURELS ──────────────────────────────────────────────────────
  static const List<CultureQuizQuestion> quizQuestions = [
    CultureQuizQuestion(
      id: 'q_soundiata_charte',
      question: 'Quel texte fondamental a été proclamé par Soundiata Keïta en 1236 ?',
      options: [
        'La Charte de Kouroukan Fouga',
        'Le Traité de Tombouctou',
        'Le Pacte de Koumbi Saleh',
        'La Déclaration du Djoliba',
      ],
      correctIndex: 0,
      explanation:
          'Proclamée en 1236 lors de l\'intronisation de Soundiata Keïta, la Charte de Kouroukan Fouga est l\'une des plus anciennes déclarations des droits de l\'Homme au monde.',
      category: 'Histoire des Empires',
      regionId: 'koulikoro',
      regionName: 'Koulikoro',
      xp: 35,
    ),
    CultureQuizQuestion(
      id: 'q_djenne_architecture',
      question: 'En quel matériau traditionnel la Grande Mosquée de Djenné est-elle entièrement construite ?',
      options: [
        'En banco (terre crue mêlée de paille)',
        'En pierre de taille calcaire',
        'En briques cuites rouges',
        'En marbre du Sahara',
      ],
      correctIndex: 0,
      explanation:
          'La Grande Mosquée de Djenné est le plus vaste édifice en terre crue (banco) au monde, restauré annuellement lors de la fête du Crépissage (Le Béré).',
      category: 'Monuments & Architecture',
      regionId: 'mopti',
      regionName: 'Mopti',
      xp: 30,
    ),
    CultureQuizQuestion(
      id: 'q_mansa_moussa_pelerinage',
      question: 'En quelle année Mansa Moussa a-t-il effectué son célèbre pèlerinage fastueux à La Mecque ?',
      options: [
        '1324',
        '1235',
        '1492',
        '1591',
      ],
      correctIndex: 0,
      explanation:
          'En 1324, la caravane de Mansa Moussa distribua tellement d\'or au Caire qu\'elle fit chuter le cours mondial du métal précieux pendant plus de dix ans.',
      category: 'Histoire des Empires',
      regionId: null,
      regionName: 'Tout le Mali',
      xp: 40,
    ),
    CultureQuizQuestion(
      id: 'q_segou_arbres',
      question: 'Quel arbre emblématique a donné à Ségou son surnom poétique de « Cité des 4 444... » ?',
      options: [
        'Les Balanzans (acacias sacrés)',
        'Les Baobabs millénaires',
        'Les Palmiers rôniers',
        'Les Céréaliers de karité',
      ],
      correctIndex: 0,
      explanation:
          'Ségou est renommée comme la « Cité des 4 444 Balanzans », arbres sacrés qui perdent leurs feuilles pendant l\'hivernage et verdissent en saison sèche.',
      category: 'Villes & Terroirs',
      regionId: 'segou',
      regionName: 'Ségou',
      xp: 30,
    ),
    CultureQuizQuestion(
      id: 'q_tombouctou_saints',
      question: 'Combien de saints patrons veillent traditionnellement sur la cité de Tombouctou ?',
      options: [
        '333 Saints',
        '99 Saints',
        '120 Saints',
        '777 Saints',
      ],
      correctIndex: 0,
      explanation:
          'Tombouctou est universellement célébrée comme « La Cité des 333 Saints », sanctuaire historique de la spiritualité et des manuscrits savants.',
      category: 'Spiritualité & Savoirs',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      xp: 35,
    ),
  ];

  // ── 3. MISSIONS DÉCOUVERTE DU PATRIMOINE ──────────────────────────────────
  static const List<DiscoveryMission> discoveryMissions = [
    DiscoveryMission(
      id: 'm_mosquee_djenne',
      title: 'Explorer la Mosquée de Djenné',
      description: 'Découvrez les secrets d\'architecture du plus grand monument en terre crue au monde.',
      actionRoute: '/culture/monument/monument_mosquee_djenne',
      category: 'Monument',
      xp: 50,
      icon: Icons.account_balance_rounded,
      isCompleted: true,
    ),
    DiscoveryMission(
      id: 'm_conte_lievre',
      title: 'Vivre le conte de Zoumana et Namori',
      description: 'Faites des choix interactifs pour déjouer les plans de l\'hyène gourmande.',
      actionRoute: '/culture/conte/conte_lievre_hyene',
      category: 'Conte Interactif',
      xp: 60,
      icon: Icons.auto_stories_rounded,
      isCompleted: false,
    ),
    DiscoveryMission(
      id: 'm_perso_soundiata',
      title: 'Consulter la fiche de Soundiata Keïta',
      description: 'Apprenez les 44 articles de la Charte du Manden et la fondation de l\'empire.',
      actionRoute: '/culture/personnage/perso_soundiata',
      category: 'Personnage Illustre',
      xp: 40,
      icon: Icons.person_search_rounded,
      isCompleted: false,
    ),
    DiscoveryMission(
      id: 'm_ville_tombouctou',
      title: 'Visiter Tombouctou la Mystérieuse',
      description: 'Parcourez la cité des 333 saints et l\'Université historique de Sankoré.',
      actionRoute: '/culture/ville/ville_tombouctou',
      category: 'Cité Historique',
      xp: 45,
      icon: Icons.location_city_rounded,
      isCompleted: false,
    ),
  ];

  // ── 4. DÉFI DU JOUR ────────────────────────────────────────────────────────
  static const TraditionalRiddle dailyChallenge = TraditionalRiddle(
    id: 'riddle_daily',
    formulaIntro: "« N'Da ! » — Défi du Jour des Anciens",
    riddleText:
        'Je suis petite comme une perle, mais je traverse les siècles.\nLes reines du Manden m\'arboraient dans leurs tresses, et j\'achetais des chevaux au temps de Kankan Moussa.\n\nQui suis-je ?',
    hints: [
      '💡 Indice 1 : Je viens des profondeurs de l\'océan Indien et de l\'Atlantique.',
      '💡 Indice 2 : J\'ai servi de monnaie d\'échange sacrée dans tout l\'Empire du Mali.',
      '💡 Indice 3 : On me brode sur le boubou des chasseurs Dozo et les masques Dogon.',
    ],
    options: [
      'Le Cauri (Koni)',
      'La Pépite d\'or',
      'Le Grain de mil',
      'La Noix de cola',
    ],
    correctAnswer: 'Le Cauri (Koni)',
    culturalExplanation:
        'Le cauri est le symbole millénaire de la prospérité, de la divination et du commerce au Mali. Il servait à la fois de monnaie et de parure protectrice chez les Dozos et les souverains.',
    proverb: '« Celui qui possède le cauri du savoir est plus riche que celui qui possède le coffre d\'or. »',
    regionId: null,
    regionName: 'Tout le Mali',
    category: 'Symbole Sacré du Jour',
    difficulty: 'Initié',
    xpReward: 100,
    photoUrl: 'assets/images/culture/personnages/soundiata.jpg',
  );

  /// Récupère une devinette par son ID
  static TraditionalRiddle getRiddleById(String id) {
    return riddles.firstWhere(
      (r) => r.id == id,
      orElse: () => riddles.first,
    );
  }

  /// Filtre les devinettes par région
  static List<TraditionalRiddle> getFilteredRiddles({String? regionId}) {
    return riddles.where((r) => r.matchesRegion(regionId)).toList();
  }

  /// Filtre les questions de quiz par région
  static List<CultureQuizQuestion> getFilteredQuiz({String? regionId}) {
    return quizQuestions.where((q) => q.matchesRegion(regionId)).toList();
  }
}
