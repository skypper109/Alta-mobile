import 'package:flutter/material.dart';
import '../models/culture_challenge_models.dart';
import '../theme/culture_theme.dart';

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
        'Indice 1 : Je suis invisible mais capable de faire danser les branches des baobabs.',
        'Indice 2 : Les piroguiers du Djoliba et les caravanes du désert scrutent ma direction.',
        'Indice 3 : En saison sèche, je porte le nom d\'Harmattan.',
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
        'Indice 1 : Il est toujours noir, quel que soit le tissu de ton boubou.',
        'Indice 2 : Il grandit quand le soleil se couche et rétrécit à midi pile.',
        'Indice 3 : Il te quitte dès que la flamme de la lampe s\'éteint.',
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
        'Indice 1 : Les griots et forgerons taillent son bois dans le Lenké sacré.',
        'Indice 2 : Il rythme les fêtes de moisson, les mariages et les intronisations.',
        'Indice 3 : Ses frappes sont le Ton, le Slap et la Basse.',
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
        'Indice 1 : Les pêcheurs Bozos sont ses maîtres absolus.',
        'Indice 2 : On la propulse avec une perche ou une pagaie en bois poli.',
        'Indice 3 : Elle relie Koulikoro, Mopti et Tombouctou au gré du courant.',
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
        'Indice 1 : L\'un réchauffe les veillées et cuit le tô de mil.',
        'Indice 2 : L\'autre reste au foyer au petit matin, grise et froide.',
        'Indice 3 : L\'un est rouge et brûlant, l\'autre est cendre.',
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
        'Indice 1 : Les maîtres tisserands et tailleurs de boubous ne peuvent se passer de moi.',
        'Indice 2 : Je réunis ce qui est déchiré.',
        'Indice 3 : Mon corps est d\'acier fin et ma queue de coton filé.',
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

  // ── 2. PACKS THÉMATIQUES DE QUIZ DU SAVOIR ─────────────────────────────────
  static const List<CultureQuizPack> quizPacks = [
    // PACK 1 : LES GRANDS EMPIRES DU MALI
    CultureQuizPack(
      id: 'quiz_empires',
      title: 'Les Grands Empires du Mali',
      subtitle: 'Sundiata, Kouroukan Fouga & Mansa Moussa',
      description:
          'Explorez l\'épopée fondatrice du Manden, la grande charte de 1236 et le rayonnement économique et intellectuel des souverains maliens.',
      category: 'Histoire des Rois',
      regionId: 'koulikoro',
      regionName: 'Koulikoro & Manden',
      xpReward: 120,
      timeMinutes: 6,
      icon: Icons.account_balance_rounded,
      themeColor: CultureTheme.accentOrange,
      photoUrl: 'assets/images/culture/personnages/soundiata.jpg',
      stampBadgeTitle: 'Sceau des Grands Rois du Manden',
      questions: [
        CultureQuizQuestion(
          id: 'q_soundiata_charte',
          question: 'Quel texte fondamental a été solennellement proclamé par Soundiata Keïta en 1236 ?',
          options: [
            'La Charte de Kouroukan Fouga',
            'Le Traité de Tombouctou',
            'Le Pacte de Koumbi Saleh',
            'La Déclaration du Djoliba',
          ],
          correctIndex: 0,
          explanation:
              'Proclamée en 1236 à Kouroukan Fouga, cette charte universelle est considérée comme l\'une des premières déclarations des droits de l\'Homme au monde.',
          category: 'Histoire des Rois',
          regionId: 'koulikoro',
          regionName: 'Koulikoro',
          xp: 20,
        ),
        CultureQuizQuestion(
          id: 'q_mansa_moussa_pelerinage',
          question: 'En quelle année Mansa Moussa a-t-il réalisé son pèlerinage historique vers La Mecque ?',
          options: [
            '1324',
            '1235',
            '1492',
            '1591',
          ],
          correctIndex: 0,
          explanation:
              'En 1324, la caravane fastueuse de Mansa Moussa distribua tellement d\'or au Caire que le cours mondial du métal précieux fut déstabilisé pendant plus d\'une décennie.',
          category: 'Histoire des Rois',
          regionId: null,
          regionName: 'Tout le Mali',
          xp: 20,
        ),
        CultureQuizQuestion(
          id: 'q_kirina_bataille',
          question: 'Quelle bataille décisive de 1235 permit à Soundiata de vaincre le roi sorcier Soumaoro Kanté ?',
          options: [
            'La Bataille de Kirina',
            'La Bataille de Tondibi',
            'La Prise de Koumbi Saleh',
            'Le Siège de Djenné',
          ],
          correctIndex: 0,
          explanation:
              'La bataille de Kirina en 1235 scella la libération des peuples du Manden et marqua l\'avènement du grand Empire du Mali.',
          category: 'Histoire des Rois',
          regionId: 'koulikoro',
          regionName: 'Koulikoro',
          xp: 20,
        ),
        CultureQuizQuestion(
          id: 'q_titre_mansa',
          question: 'Que signifie exactement le titre impérial « Mansa » porté par les empereurs du Mali ?',
          options: [
            'Roi des Rois / Souverain Suprême',
            'Maître de l\'Or pur',
            'Gardien des Eaux du Niger',
            'Général des Cavaleries',
          ],
          correctIndex: 0,
          explanation:
              '« Mansa » en langue mandingue désigne le roi des rois, garant de l\'unité spirituelle, militaire et judiciaire de toutes les provinces.',
          category: 'Histoire des Rois',
          regionId: null,
          regionName: 'Tout le Mali',
          xp: 20,
        ),
        CultureQuizQuestion(
          id: 'q_ghana_capitale',
          question: 'Quelle cité antique était la prestigieuse capitale de l\'Empire du Ghana (Wagadou) ?',
          options: [
            'Koumbi Saleh',
            'Gao',
            'Tombouctou',
            'Oualata',
          ],
          correctIndex: 0,
          explanation:
              'Koumbi Saleh, située aux confins nord du Mali actuel, était le centre névralgique du commerce transsaharien de l\'or et du sel dès le VIIIe siècle.',
          category: 'Histoire des Rois',
          regionId: 'kayes',
          regionName: 'Kayes',
          xp: 20,
        ),
        CultureQuizQuestion(
          id: 'q_songhai_askia',
          question: 'Quel grand réformateur de l\'Empire Songhaï a fondé la dynastie des Askia en 1493 ?',
          options: [
            'Askia Mohammed',
            'Sonni Ali Ber',
            'Kankou Moussa',
            'Mamadou Keïta',
          ],
          correctIndex: 0,
          explanation:
              'Askia Mohammed instaura une administration centralisée exemplaire, favorisa l\'Université de Sankoré et fit de Gao l\'une des capitales les plus prospères d\'Afrique.',
          category: 'Histoire des Rois',
          regionId: 'gao',
          regionName: 'Gao',
          xp: 20,
        ),
      ],
    ),

    // PACK 2 : MONUMENTS & ARCHITECTURE BANCO
    CultureQuizPack(
      id: 'quiz_monuments',
      title: 'Monuments & Architecture Banco',
      subtitle: 'Djenné, Tombouctou & Askia',
      description:
          'Plongez dans le génie des maîtres maçons soudanais : terre crue crêpie, minarets coniques et chefs-d\'œuvre classés à l\'UNESCO.',
      category: 'Architecture & Sacré',
      regionId: 'mopti',
      regionName: 'Mopti & Tombouctou',
      xpReward: 100,
      timeMinutes: 5,
      icon: Icons.museum_rounded,
      themeColor: CultureTheme.primaryBlue,
      photoUrl: 'assets/images/culture/monuments/mosquee_djenne.jpg',
      stampBadgeTitle: 'Sceau d\'Or des Bâtisseurs Soudanais',
      questions: [
        CultureQuizQuestion(
          id: 'q_djenne_architecture',
          question: 'En quel matériau traditionnel la Grande Mosquée de Djenné est-elle entièrement bâtie ?',
          options: [
            'En banco (argile crue mêlée de son et paille)',
            'En pierre calcaire taillée',
            'En briques rouges cuites au four',
            'En marbre blanc importé',
          ],
          correctIndex: 0,
          explanation:
              'La Grande Mosquée de Djenné est le plus vaste édifice en banco au monde. Ses murs respirent et maintiennent une fraîcheur naturelle sous la chaleur sahélienne.',
          category: 'Architecture & Sacré',
          regionId: 'mopti',
          regionName: 'Mopti',
          xp: 20,
        ),
        CultureQuizQuestion(
          id: 'q_djenne_bere',
          question: 'Comment s\'appelle la grande fête annuelle collective de restauration de la mosquée de Djenné ?',
          options: [
            'Le Crépissage (Le Béré)',
            'La Fête du Sanké Mon',
            'Le Gna',
            'La Tabaski de l\'Eau',
          ],
          correctIndex: 0,
          explanation:
              'Le Béré réunit toute la population en une journée : jeunes et anciens grimpent sur les échafaudages de palmiers pour enduire à nouveau la terre protectrice.',
          category: 'Architecture & Sacré',
          regionId: 'mopti',
          regionName: 'Mopti',
          xp: 20,
        ),
        CultureQuizQuestion(
          id: 'q_tombeau_askia',
          question: 'Quelle forme architecturale unique caractérise le célèbre Tombeau des Askia à Gao ?',
          options: [
            'Une pyramide sahélienne à degrés en terre crue',
            'Un dôme circulaire en pierre',
            'Une tour octogonale en marbre',
            'Une forteresse carrée souterraine',
          ],
          correctIndex: 0,
          explanation:
              'Édifié en 1495 par l\'empereur Askia Mohammed, ce tombeau pyramidal haut de 17 mètres témoigne du rayonnement impérial Songhaï au bord du fleuve Niger.',
          category: 'Architecture & Sacré',
          regionId: 'gao',
          regionName: 'Gao',
          xp: 20,
        ),
        CultureQuizQuestion(
          id: 'q_sankore_mosquee',
          question: 'À quelle célèbre université médiévale de Tombouctou la mosquée de Sankoré est-elle associée ?',
          options: [
            'L\'Université de Sankoré',
            'L\'Académie de Djenné',
            'La Médersa d\'Al-Azhar',
            'L\'Institut de Ségou',
          ],
          correctIndex: 0,
          explanation:
              'Au XVIe siècle, l\'Université de Sankoré comptait plus de 25 000 étudiants venus de toute l\'Afrique et du Moyen-Orient pour étudier le droit, l\'astronomie et la médecine.',
          category: 'Architecture & Sacré',
          regionId: 'tombouctou',
          regionName: 'Tombouctou',
          xp: 20,
        ),
        CultureQuizQuestion(
          id: 'q_fort_medine',
          question: 'Près de quelle grande ville fluviale se dresse le Fort historique de Médine ?',
          options: [
            'Kayes',
            'Koulikoro',
            'Sikasso',
            'Kidal',
          ],
          correctIndex: 0,
          explanation:
              'Bâti en 1855 au bord des chutes de Félou à Kayes, le Fort de Médine fut le théâtre du siège héroïque soutenu contre les troupes d\'El Hadj Oumar Tall.',
          category: 'Architecture & Sacré',
          regionId: 'kayes',
          regionName: 'Kayes',
          xp: 20,
        ),
      ],
    ),

    // PACK 3 : CITÉS MILLÉNAIRES & TERROIRS
    CultureQuizPack(
      id: 'quiz_villes',
      title: 'Cités Millénaires & Terroirs',
      subtitle: 'Tombouctou, Ségou, Mopti & Sikasso',
      description:
          'Parcourez les routes mythiques des caravanes, les 333 saints protecteurs du désert et les remparts imprenables du Kénédougou.',
      category: 'Cités & Géographie',
      regionId: 'tombouctou',
      regionName: 'Tout le Mali',
      xpReward: 110,
      timeMinutes: 5,
      icon: Icons.location_city_rounded,
      themeColor: CultureTheme.cyanTurquoise,
      photoUrl: 'assets/images/culture/villes/tombouctou_ville.jpg',
      stampBadgeTitle: 'Sceau des Cités et Caravanes du Sahel',
      questions: [
        CultureQuizQuestion(
          id: 'q_tombouctou_saints',
          question: 'Combien de saints patrons veillent traditionnellement sur la cité mystique de Tombouctou ?',
          options: [
            '333 Saints',
            '99 Saints',
            '120 Saints',
            '777 Saints',
          ],
          correctIndex: 0,
          explanation:
              'Tombouctou est appelée « La Cité des 333 Saints », sanctuaire historique de sagesse, de manuscrits précieux et de haute spiritualité soufie.',
          category: 'Cités & Géographie',
          regionId: 'tombouctou',
          regionName: 'Tombouctou',
          xp: 25,
        ),
        CultureQuizQuestion(
          id: 'q_segou_arbres',
          question: 'Quel arbre sacré a donné à Ségou son surnom de « Cité des 4 444... » ?',
          options: [
            'Les Balanzans (acacias sacrés)',
            'Les Baobabs millénaires',
            'Les Palmiers rôniers',
            'Les Céréaliers de karité',
          ],
          correctIndex: 0,
          explanation:
              'Ségou est la « Cité des 4 444 Balanzans », arbres mystiques qui ont la particularité de reverdir en saison sèche et de perdre leurs feuilles pendant les pluies.',
          category: 'Cités & Géographie',
          regionId: 'segou',
          regionName: 'Ségou',
          xp: 25,
        ),
        CultureQuizQuestion(
          id: 'q_mopti_surnom',
          question: 'En raison de ses canaux et de sa flotte de pirogues, quel surnom donne-t-on souvent à Mopti ?',
          options: [
            'La Venise du Mali',
            'Le Phare du Sahel',
            'La Reine des Sables',
            'L\'Oasis d\'Or',
          ],
          correctIndex: 0,
          explanation:
              'Mopti est surnommée la « Venise du Mali » en raison de sa situation au confluent du fleuve Niger et de la rivière Bani, créant un port fluvial effervescent.',
          category: 'Cités & Géographie',
          regionId: 'mopti',
          regionName: 'Mopti',
          xp: 20,
        ),
        CultureQuizQuestion(
          id: 'q_sikasso_tata',
          question: 'Quelle formidable muraille défensive en terre crue protégeait autrefois la ville de Sikasso ?',
          options: [
            'Le Tata de Sikasso',
            'Les Remparts de Bandiagara',
            'La Muraille du Manden',
            'Le Fort de Médine',
          ],
          correctIndex: 0,
          explanation:
              'Érigé par le roi Tiéba Traoré à la fin du XIXe siècle, le Tata de Sikasso mesurait plus de 9 kilomètres de long et résista à de multiples sièges.',
          category: 'Cités & Géographie',
          regionId: 'sikasso',
          regionName: 'Sikasso',
          xp: 20,
        ),
        CultureQuizQuestion(
          id: 'q_bamako_caimans',
          question: 'Quel fleuve majestueux traverse la capitale Bamako et irrigue tout le Mali ?',
          options: [
            'Le Djoliba (Fleuve Niger)',
            'Le Fleuve Sénégal',
            'Le Bani',
            'Le Fleuve Gambie',
          ],
          correctIndex: 0,
          explanation:
              'Le Djoliba (fleuve Niger) est le cœur battant du Mali, nourricier des civilisations Bozo, Bambara, Songhaï et Peule depuis des millénaires.',
          category: 'Cités & Géographie',
          regionId: 'bamako',
          regionName: 'Bamako',
          xp: 20,
        ),
      ],
    ),

    // PACK 4 : ARTS, MUSIQUE & SAGESSES DOZO
    CultureQuizPack(
      id: 'quiz_arts_traditions',
      title: 'Arts, Musique & Sagesses Dozo',
      subtitle: 'Kora, Balafon, Bogolan & Masques',
      description:
          'Célébrez la voix des maîtres de la parole, les secrets de teinture de terre et les symboles sacrés gravés par les anciens.',
      category: 'Arts & Traditions',
      regionId: null,
      regionName: 'Tout le Mali',
      xpReward: 130,
      timeMinutes: 6,
      icon: Icons.auto_awesome_rounded,
      themeColor: CultureTheme.accentOrange,
      photoUrl: 'assets/images/culture/villes/bandiagara_falaise.jpg',
      stampBadgeTitle: 'Sceau des Maîtres de la Parole & des Dozos',
      questions: [
        CultureQuizQuestion(
          id: 'q_kora_cordes',
          question: 'Combien de cordes comporte traditionnellement la Kora mandingue classique ?',
          options: [
            '21 cordes',
            '12 cordes',
            '7 cordes',
            '33 cordes',
          ],
          correctIndex: 0,
          explanation:
              'La Kora classique possède 21 cordes tendues sur une demi-calebasse recouverte d\'une peau de vache. Elle est l\'instrument royal par excellence des griots généalogistes.',
          category: 'Arts & Traditions',
          regionId: 'koulikoro',
          regionName: 'Koulikoro',
          xp: 25,
        ),
        CultureQuizQuestion(
          id: 'q_bogolan_teinture',
          question: 'Quels ingrédients naturels sont indispensables pour teindre le tissu traditionnel Bogolan ?',
          options: [
            'De la boue fermentée et des décoctions de feuilles',
            'De la cire d\'abeille et de l\'encre de Chine',
            'De la poudre d\'or et du sel de Taoudénit',
            'De la cendre de bois et du sang de karité',
          ],
          correctIndex: 0,
          explanation:
              '« Bogolan » signifie « fait avec la terre » en bambara. L\'argile du fleuve réagit avec les tanins des plantes végétales pour donner ces motifs protecteurs bruns et noirs.',
          category: 'Arts & Traditions',
          regionId: 'segou',
          regionName: 'Ségou',
          xp: 25,
        ),
        CultureQuizQuestion(
          id: 'q_balafon_sosso',
          question: 'Quel instrument sacré légendaire, conservé depuis le XIIIe siècle, est inscrit au patrimoine immatériel de l\'UNESCO ?',
          options: [
            'Le Sosso-Bala',
            'La Kora de Soundiata',
            'Le Djembé d\'Askia',
            'Le Tam-tam de Koumbi',
          ],
          correctIndex: 0,
          explanation:
              'Le Sosso-Bala, balafon sacré ayant appartenu à Soumaoro Kanté puis confié au griot Balla Fasséké en 1235, est précieusement gardé par la lignée des Kouyaté.',
          category: 'Arts & Traditions',
          regionId: 'koulikoro',
          regionName: 'Koulikoro',
          xp: 25,
        ),
        CultureQuizQuestion(
          id: 'q_masque_kanaga',
          question: 'Quel masque dogon célèbre représente la liaison entre la Terre et le Ciel dans la cosmogonie ?',
          options: [
            'Le Masque Kanaga (croix à double traverse)',
            'Le Masque Sirige (très haute échelle)',
            'Le Masque Satimbe',
            'Le Masque Walu (antilope)',
          ],
          correctIndex: 0,
          explanation:
              'Le Kanaga, avec sa structure en double croix, symbolise le geste divin d\'Amma créant l\'univers et organisant l\'harmonie cosmique.',
          category: 'Arts & Traditions',
          regionId: 'mopti',
          regionName: 'Mopti & Pays Dogon',
          xp: 30,
        ),
        CultureQuizQuestion(
          id: 'q_confrerie_dozo',
          question: 'Quelle est la valeur centrale transmise par les confréries initiatiques de chasseurs Dozos ?',
          options: [
            'L\'humilité, la protection de la nature et la justice',
            'La conquête de nouveaux territoires',
            'L\'accumulation de richesses matérielles',
            'Le secret exclusif sans transmission',
          ],
          correctIndex: 0,
          explanation:
              'Les Dozos sont les gardiens de l\'écologie traditionnelle et du code d\'honneur. Leur devise est de ne jamais prélever dans la nature plus que ce qui est nécessaire.',
          category: 'Arts & Traditions',
          regionId: null,
          regionName: 'Tout le Mali',
          xp: 25,
        ),
      ],
    ),
  ];

  /// Liste globale des questions de quiz (rétrocompatibilité)
  static List<CultureQuizQuestion> get quizQuestions =>
      quizPacks.expand((pack) => pack.questions).toList();

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
      'Indice 1 : Je viens des profondeurs de l\'océan Indien et de l\'Atlantique.',
      'Indice 2 : J\'ai servi de monnaie d\'échange sacrée dans tout l\'Empire du Mali.',
      'Indice 3 : On me brode sur le boubou des chasseurs Dozo et les masques Dogon.',
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

  /// Récupère un pack de quiz par son ID
  static CultureQuizPack getQuizPackById(String? id) {
    if (id == null || id.isEmpty) return quizPacks.first;
    return quizPacks.firstWhere(
      (pack) => pack.id == id,
      orElse: () => quizPacks.first,
    );
  }

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
