import 'package:flutter/material.dart';
import '../models/culture_detail_models.dart';

/// Données éditoriales authentiques et immersives pour les fiches de consultation
abstract final class MockCultureDetailsData {
  // ══════════════════════════════════════════════════════════════════════════
  // 1. GRANDS PERSONNAGES HISTORIQUES
  // ══════════════════════════════════════════════════════════════════════════

  static const List<HistoricalFigureDetail> figures = [
    // Soundiata Keïta
    HistoricalFigureDetail(
      id: 'perso_soundiata',
      name: 'Soundiata Keïta',
      titleHonorifique: 'Le Lion du Manden & Fondateur de l\'Empire du Mali',
      period: '1190 – 1255',
      regionId: 'koulikoro',
      regionName: 'Koulikoro',
      tag: 'Mansa Bâtisseur',
      photoUrl: 'assets/images/culture/personnages/soundiata.jpg',
      photoCredits: 'Mémorial Historique du Manden, Kangaba • Archives Patrimoniales',
      resume: 'Bâtisseur de l\'Empire du Mali après sa victoire décisive à la bataille de Kirina en 1235, il proclame en 1236 la Charte de Kouroukan Fouga, l\'une des toutes premières déclarations des droits humains et du vivre-ensemble.',
      citationHistorique: '« Toute vie humaine est une vie. Le tort fait à autrui demande réparation. Respectez l\'étranger, l\'aîné et la femme. »\n— Charte du Manden, 1236',
      keyFacts: [
        HistoricalKeyFact(label: 'Règne', value: '1235 – 1255', icon: Icons.workspace_premium_rounded),
        HistoricalKeyFact(label: 'Victoire majeure', value: 'Bataille de Kirina (1235)', icon: Icons.shield_rounded),
        HistoricalKeyFact(label: 'Héritage universel', value: 'Charte du Manden (UNESCO)', icon: Icons.auto_stories_rounded),
        HistoricalKeyFact(label: 'Capitale originelle', value: 'Niani', icon: Icons.location_city_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'L\'Enfance et la Prophétie du Manden',
          content: 'Fils de Naré Maghann Konaté et de Sogolon Kondé, Soundiata naît paralysé des jambes. Écarté du pouvoir après la mort de son père et contraint à l\'exil avec sa mère, il fait preuve d\'une volonté inébranlable. Guidé par la foi en son destin et la parole des aînés, il réussit à se redresser à l\'aide d\'une barre de fer forgée par les maîtres du feu, devenant un chasseur émérite et un meneur d\'hommes admiré de tout le Manden.',
        ),
        EditorialStoryChapter(
          title: 'L\'Unification et la Victoire de Kirina (1235)',
          content: 'Face à la tyrannie du roi-sorcier Soumaoro Kanté du Sosso, les clans mandingues opprimés appellent Soundiata au secours. Il rassemble les tribus alliées, forgeant une coalition puissante fondée sur la loyauté et la bravoure. La confrontation finale se déroule à Kirina (dans l\'actuelle région de Koulikoro). Soundiata triomphe grâce à sa clairvoyance stratégique et brise l\'hégémonie du Sosso, unifiant pour la première fois les peuples du fleuve Niger.',
        ),
        EditorialStoryChapter(
          title: 'La Charte de Kouroukan Fouga (1236)',
          content: 'Réunis dans la clairière de Kouroukan Fouga à Kangaba, Soundiata et les chefs de tribus proclament en 1236 une constitution orale de 44 articles. Cette charte sacralise la dignité de la personne, abolit la servitude cruelle, institue la paix sociale par la parenté à plaisanterie (Sinankunya), accorde une place centrale aux femmes et protège la nature. Reconnue par l\'UNESCO comme patrimoine immatériel universel, elle demeure le socle moral du Mali.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'monument_mosquee_djenne',
          title: 'Grande Mosquée de Djenné',
          subtitle: 'Joyau de l\'époque impériale',
          type: ConnectedItemType.monument,
          tag: 'UNESCO',
          regionName: 'Mopti',
          icon: Icons.museum_rounded,
        ),
        ConnectedItemRef(
          id: 'perso_mansa_moussa',
          title: 'Mansa Moussa',
          subtitle: 'Descendant & Apogée du Mali',
          type: ConnectedItemType.personnage,
          tag: 'Mansa',
          regionName: 'Tombouctou',
          icon: Icons.person_rounded,
        ),
        ConnectedItemRef(
          id: 'ville_segou_koro',
          title: 'Ségou-Koro',
          subtitle: 'Berceau des dynasties du fleuve',
          type: ConnectedItemType.ville,
          tag: 'Cité Royale',
          regionName: 'Ségou',
          icon: Icons.location_city_rounded,
        ),
      ],
    ),

    // Mansa Moussa
    HistoricalFigureDetail(
      id: 'perso_mansa_moussa',
      name: 'Mansa Moussa',
      titleHonorifique: 'Le Souverain d\'Or & Bâtisseur du Savoir Universel',
      period: '1312 – 1337',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      tag: 'Âge d\'Or Impérial',
      photoUrl: 'assets/images/culture/personnages/mansa_moussa.jpg',
      photoCredits: 'Atlas Catalan de 1375, Abraham Cresques • Bibliothèque Nationale de France',
      resume: 'Mansa Kankou Moussa porte l\'Empire du Mali à son apogée économique, culturel et territorial. Son pèlerinage mémorable à La Mecque en 1324 révèle au monde la richesse colossale du Mali et fait de Tombouctou et Gao les capitales intellectuelles de l\'Afrique.',
      citationHistorique: '« Le savoir est la lumière de l\'empire ; les savants sont les gardiens de notre avenir. »\n— Mansa Moussa, 1327',
      keyFacts: [
        HistoricalKeyFact(label: 'Règne', value: '1312 – 1337', icon: Icons.workspace_premium_rounded),
        HistoricalKeyFact(label: 'Pèlerinage historique', value: '1324 (Le Caire & La Mecque)', icon: Icons.stars_rounded),
        HistoricalKeyFact(label: 'Grandes commandes', value: 'Mosquée Djingareyber (1327)', icon: Icons.architecture_rounded),
        HistoricalKeyFact(label: 'Expansion', value: 'De l\'Atlantique au fleuve Niger', icon: Icons.public_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'L\'Avènement et la Puissance Territoriale',
          content: 'Petit-neveu de Soundiata Keïta, Kankou Moussa accède au trône en 1312 à la suite de la disparition en mer du Mansa Aboubakri II. Sous son autorité, l\'empire s\'étend sur plus de 3 000 kilomètres, reliant les mines d\'or de Bouré et Bambouk aux comptoirs marchands du Sahara, englobant les grandes cités de Tombouctou, Gao, Walata et Oualata.',
        ),
        EditorialStoryChapter(
          title: 'Le Pèlerinage de 1324 et le Rayonnement Mondial',
          content: 'En 1324, Mansa Moussa entreprend une traversée légendaire vers La Mecque accompagné d\'une caravane de 60 000 hommes, de dignitaires, de soldats et de 80 dromadaires transportant chacun des centaines de kilos d\'or pur. Sa générosité légendaire lors de son passage au Caire fut telle qu\'elle dévalua le cours mondial de l\'or pendant plus de dix ans, inscrivant à jamais le nom du Mali sur les cartes européennes et arabes.',
        ),
        EditorialStoryChapter(
          title: 'Tombouctou, Cité des 333 Saints et des Universités',
          content: 'À son retour, Mansa Moussa invite le célèbre poète et architecte andalou Abou Ishaq es-Sahéli pour concevoir des chefs-d\'œuvre d\'ingénierie en terre crue. Il ordonne la construction de la Mosquée Djingareyber en 1327 et dote l\'Université de Sankoré de financements considérables, attirant juristes, astronomes, médecins et philosophes du monde entier.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'monument_djingareyber',
          title: 'Mosquée Djingareyber',
          subtitle: 'Commandée par Mansa Moussa en 1327',
          type: ConnectedItemType.monument,
          tag: 'Patrimoine Majeur',
          regionName: 'Tombouctou',
          icon: Icons.museum_rounded,
        ),
        ConnectedItemRef(
          id: 'monument_sankore',
          title: 'Mosquée & Université de Sankoré',
          subtitle: 'Sanctuaire des manuscrits anciens',
          type: ConnectedItemType.monument,
          tag: 'Université Millénaire',
          regionName: 'Tombouctou',
          icon: Icons.school_rounded,
        ),
        ConnectedItemRef(
          id: 'ville_tombouctou',
          title: 'Tombouctou',
          subtitle: 'La Cité des 333 Saints',
          type: ConnectedItemType.ville,
          tag: 'Savoirs Sahéliens',
          regionName: 'Tombouctou',
          icon: Icons.location_city_rounded,
        ),
      ],
    ),

    // Babemba Traoré
    HistoricalFigureDetail(
      id: 'perso_babemba',
      name: 'Babemba Traoré',
      titleHonorifique: 'Roi du Kénédougou & Héros de la Résistance Nationale',
      period: '1855 – 1898',
      regionId: 'sikasso',
      regionName: 'Sikasso',
      tag: 'Héros de la Dignité',
      photoUrl: 'assets/images/culture/personnages/babemba_traore.jpg',
      photoCredits: 'Monument National Babemba Traoré, Sikasso • Fonds Photographique National',
      resume: 'Souverain du Royaume du Kénédougou de 1893 à 1898, il défendit héroïquement la cité fortifiée de Sikasso contre les assauts des troupes coloniales, préférant le sacrifice suprême à la capitulation.',
      citationHistorique: '« Anka sa ni ka malo ! » (Plutôt la mort que la honte !)\n— Devise sacrée de Babemba Traoré, 1er mai 1898',
      keyFacts: [
        HistoricalKeyFact(label: 'Règne', value: '1893 – 1898', icon: Icons.shield_rounded),
        HistoricalKeyFact(label: 'Forteresse', value: 'Tata de Sikasso (9 km de remparts)', icon: Icons.castle_rounded),
        HistoricalKeyFact(label: 'Symbole', value: 'Dignité et souveraineté patriotique', icon: Icons.military_tech_rounded),
        HistoricalKeyFact(label: 'Royaume', value: 'Kénédougou', icon: Icons.flag_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'L\'Héritage des Traoré et le Kénédougou',
          content: 'Succédant à son frère aîné Tiéba Traoré en 1893, Babemba prend les rênes d\'un royaume prospère et redoutable dont la capitale est Sikasso. Fin stratège et organisateur hors pair, il renforce les fortifications et l\'armée pour préserver l\'autonomie et la culture de son peuple.',
        ),
        EditorialStoryChapter(
          title: 'L\'Inexpugnable Tata de Sikasso',
          content: 'Sous son règne, le Tata de Sikasso — une colossale muraille en terre de 9 km de circonférence, haute de 6 mètres et large de plusieurs mètres — devient un chef-d\'œuvre d\'ingénierie militaire défensive. Même l\'armée de Samory Touré avait échoué lors d\'un siège de quinze mois en 1887-1888.',
        ),
        EditorialStoryChapter(
          title: 'Le Siège de 1898 et le Sacrifice pour l\'Honneur',
          content: 'En avril 1898, une puissante colonne d\'artillerie lourde assiège Sikasso. Après des semaines d\'une résistance acharnée où chaque brèche est défendue avec un héroïsme légendaire, les troupes pénètrent dans la ville le 1er mai 1898. Refusant catégoriquement d\'être fait prisonnier, Babemba se donne la mort, prononçant la phrase immortelle : "Anka sa ni ka malo !".',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'monument_tata_sikasso',
          title: 'Le Tata de Sikasso',
          subtitle: 'La Muraille de Résistance',
          type: ConnectedItemType.monument,
          tag: 'Fortification',
          regionName: 'Sikasso',
          icon: Icons.castle_rounded,
        ),
        ConnectedItemRef(
          id: 'ville_sikasso',
          title: 'Sikasso',
          subtitle: 'Le Verger du Mali & Cité du Kénédougou',
          type: ConnectedItemType.ville,
          tag: 'Cité Héroïque',
          regionName: 'Sikasso',
          icon: Icons.location_city_rounded,
        ),
      ],
    ),

    // Askia Mohammed
    HistoricalFigureDetail(
      id: 'perso_askia_mohammed',
      name: 'Askia Mohammed',
      titleHonorifique: 'Askia le Grand & Réformateur de l\'Empire Songhoï',
      period: '1443 – 1538',
      regionId: 'gao',
      regionName: 'Gao',
      tag: 'Grand Réformateur',
      photoUrl: 'assets/images/culture/personnages/askia_mohammed.jpg',
      photoCredits: 'Complexe Monumental des Askia, Gao • Cliché Patrimoine National',
      resume: 'Fondateur de la dynastie des Askia en 1493, il transforme l\'Empire Songhoï en un État centralisé moderne, doté d\'une armée de métier, d\'une justice équitable et d\'un réseau d\'universités florissant de Gao à Tombouctou.',
      citationHistorique: '« La justice et l\'organisation sont les piliers sur lesquels reposent la prospérité des nations. »\n— Askia Mohammed, Gao',
      keyFacts: [
        HistoricalKeyFact(label: 'Règne', value: '1493 – 1528', icon: Icons.workspace_premium_rounded),
        HistoricalKeyFact(label: 'Capitale', value: 'Gao', icon: Icons.location_city_rounded),
        HistoricalKeyFact(label: 'Sépulture', value: 'Tombeau pyramidal des Askia (UNESCO)', icon: Icons.architecture_rounded),
        HistoricalKeyFact(label: 'Empire', value: 'Songhoï', icon: Icons.public_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'L\'Avènement de la Dynastie des Askia (1493)',
          content: 'Général d\'élite et homme d\'État visionnaire sous Sonni Ali Ber, Mohammed Touré prend le pouvoir en 1493 après la bataille d\'Anfao. Il adopte le titre d\'Askia ("le Fort") et instaure un modèle d\'administration territoriale exemplaire découpé en provinces confiées à des gouverneurs compétents.',
        ),
        EditorialStoryChapter(
          title: 'La Modernisation de l\'Administration et de l\'Économie',
          content: 'Askia Mohammed standardise les poids et mesures dans tout l\'empire, crée une flotte navale fluviale sur le fleuve Niger, professionnalise l\'armée et garantit la sécurité totale des routes caravanières transsahariennes. Sous son impulsion, Gao et Tombouctou deviennent les carrefours du commerce mondial de l\'or, du sel et des livres.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'monument_tombeau_askia',
          title: 'Tombeau des Askia',
          subtitle: 'Pyramide de terre crue à Gao',
          type: ConnectedItemType.monument,
          tag: 'UNESCO',
          regionName: 'Gao',
          icon: Icons.museum_rounded,
        ),
        ConnectedItemRef(
          id: 'ville_gao',
          title: 'Gao',
          subtitle: 'La Cité Impériale des Songhoï',
          type: ConnectedItemType.ville,
          tag: 'Cité Fluviale',
          regionName: 'Gao',
          icon: Icons.location_city_rounded,
        ),
      ],
    ),

    // Biton Coulibaly
    HistoricalFigureDetail(
      id: 'perso_biton_coulibaly',
      name: 'Biton Coulibaly',
      titleHonorifique: 'Fondateur du Royaume Bambara de Ségou',
      period: '1689 – 1755',
      regionId: 'segou',
      regionName: 'Ségou',
      tag: 'Bâtisseur de Ségou',
      photoUrl: 'assets/images/culture/personnages/biton_coulibaly.jpg',
      photoCredits: 'Mausolée Royal de Biton Coulibaly, Ségou-Koro • Cliché Photographique',
      resume: 'Génie militaire et politique, Mamari "Biton" Coulibaly transforme l\'association fraternelle de jeunesse (Tôn) en une redoutable armée permanente (Tônjons) et fonde le puissant Royaume Bambara de Ségou le long du fleuve Niger.',
      citationHistorique: '« La force d\'un royaume réside dans la discipline de ses guerriers et l\'unité de son peuple. »\n— Récits des Griots de Ségou',
      keyFacts: [
        HistoricalKeyFact(label: 'Règne', value: '1712 – 1755', icon: Icons.workspace_premium_rounded),
        HistoricalKeyFact(label: 'Capitale', value: 'Ségou-Koro', icon: Icons.location_city_rounded),
        HistoricalKeyFact(label: 'Institution', value: 'Les Tônjons (Guerriers d\'élite)', icon: Icons.shield_rounded),
        HistoricalKeyFact(label: 'Royaume', value: 'Royaume Bambara de Ségou', icon: Icons.flag_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'De chef du Tôn à Roi de Ségou',
          content: 'Mamari Coulibaly se distingue dès sa jeunesse par son sens de l\'organisation et sa générosité. Élu chef du Tôn (association d\'entraide et de chasse), il prend le titre de "Biton" et transforme cette structure en une communauté militaire solidaire et disciplinée, unifiant les cités riveraines du fleuve Djoliba.',
        ),
        EditorialStoryChapter(
          title: 'L\'Essor du Royaume des 4 444 Balanzans',
          content: 'Sous son commandement, Ségou-Koro devient une forteresse imprenable et une capitale prestigieuse. Il dote Ségou d\'une flotte de pirogues de guerre contrôlant le fleuve de Bamako jusqu\'à Djenné et Tombouctou. Sa tombe séculaire à Ségou-Koro reste un haut lieu de recueillement et de mémoire.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'ville_segou_koro',
          title: 'Ségou-Koro',
          subtitle: 'Le Berceau des 4 444 Balanzans',
          type: ConnectedItemType.ville,
          tag: 'Cité Royale',
          regionName: 'Ségou',
          icon: Icons.location_city_rounded,
        ),
      ],
    ),

    // Modibo Keïta
    HistoricalFigureDetail(
      id: 'perso_modibo_keita',
      name: 'Modibo Keïta',
      titleHonorifique: 'Père de l\'Indépendance & 1er Président de la République du Mali',
      period: '1915 – 1977',
      regionId: 'bamako',
      regionName: 'Bamako',
      tag: 'Père de la Nation',
      photoUrl: 'assets/images/culture/personnages/modibo_keita.jpg',
      photoCredits: 'Photographie Officielle d\'Archives Nationales du Mali, 1961',
      resume: 'Figure majeure du panafricanisme et artisan de l\'indépendance proclamée le 22 septembre 1960, Modibo Keïta a forgé les institutions et l\'identité de la République moderne du Mali.',
      citationHistorique: '« Le Mali est une nation de bâtisseurs. Notre liberté s\'enracine dans la grandeur de nos ancêtres. »\n— Modibo Keïta, 22 septembre 1960',
      keyFacts: [
        HistoricalKeyFact(label: 'Présidence', value: '1960 – 1968', icon: Icons.flag_rounded),
        HistoricalKeyFact(label: 'Proclamation', value: 'Indépendance du Mali (22 sept. 1960)', icon: Icons.celebration_rounded),
        HistoricalKeyFact(label: 'Mouvement', value: 'Panafricanisme & Non-alignement', icon: Icons.public_rounded),
        HistoricalKeyFact(label: 'Hommage', value: 'Mémorial Modibo Keïta à Bamako', icon: Icons.museum_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'L\'Engagement pour la Dignité Africaine',
          content: 'Né à Bamako-Coura et descendant de la lignée de Soundiata Keïta, Modibo Keïta excelle comme enseignant avant de s\'engager en politique. Cofondateur de l\'Union Soudanaise-Rassemblement Démocratique Africain (US-RDA), il milite sans relâche pour l\'émancipation des peuples africains.',
        ),
        EditorialStoryChapter(
          title: 'La Naissance de la République du Mali (1960)',
          content: 'Le 22 septembre 1960, il proclame solennellement l\'indépendance de la République du Mali devant le peuple rassemblé à Bamako, choisissant délibérément le nom historique de l\'illustre Empire du Mali en hommage aux bâtisseurs du passé. Il sera l\'un des rédacteurs de la charte de l\'Organisation de l\'Unité Africaine (OUA) en 1963.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'perso_soundiata',
          title: 'Soundiata Keïta',
          subtitle: 'La lignée historique du Manden',
          type: ConnectedItemType.personnage,
          tag: 'Fondateur',
          regionName: 'Koulikoro',
          icon: Icons.person_rounded,
        ),
      ],
    ),
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // 2. MONUMENTS HISTORIQUES
  // ══════════════════════════════════════════════════════════════════════════

  static const List<MonumentDetail> monuments = [
    // Grande Mosquée de Djenné
    MonumentDetail(
      id: 'monument_mosquee_djenne',
      name: 'Grande Mosquée de Djenné',
      subtitle: 'Chef-d\'œuvre universel de l\'architecture en terre crue',
      era: 'Érigée au XIIIe siècle (reconstruite à l\'identique en 1907)',
      regionId: 'mopti',
      regionName: 'Mopti',
      tag: 'Patrimoine Mondial UNESCO (1988)',
      photoUrl: 'assets/images/culture/monuments/mosquee_djenne.jpg',
      photoCredits: 'Photographie réelle du sanctuaire de Djenné • Cliché Patrimoine UNESCO',
      locationDetails: 'Place du Marché, Ville ancienne de Djenné, Vallée du Bani',
      presentation: 'La Grande Mosquée de Djenné est le plus vaste édifice au monde entièrement construit en briques de terre crue séchées au soleil (banco). Majestueuse et imposante, elle culmine avec ses trois minarets emblématiques hérissés de pièces de bois de palmier (torons).',
      architectureAndMaterials: 'Construite selon la tradition soudano-sahélienne, elle repose sur un mélange écologique d\'argile fine du fleuve, de balle de riz et de beurre de karité. Les torons en bois intégrés dans les façades servent à la fois d\'échafaudages permanents pour le crépissage et d\'amortisseurs contre les variations thermiques.',
      whyItMatters: 'Ce monument incarne le génie bâtisseur malien et la solidarité communautaire. Chaque année, la fête sacrée du crépissage (le "Crépissage de Djenné") rassemble toute la population de la ville en une seule journée festive pour recouvrir l\'édifice d\'une nouvelle couche protectrice d\'argile.',
      keyFacts: [
        HistoricalKeyFact(label: 'Matériau', value: '100% Terre crue (Banco bio-climatique)', icon: Icons.nature_rounded),
        HistoricalKeyFact(label: 'Capacité', value: 'Plus de 3 000 fidèles', icon: Icons.people_rounded),
        HistoricalKeyFact(label: 'Tradition', value: 'Fête annuelle du Crépissage', icon: Icons.celebration_rounded),
        HistoricalKeyFact(label: 'Statut', value: 'Classée UNESCO depuis 1988', icon: Icons.verified_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'Origines médiévales et premier sanctuaire',
          content: 'Le premier édifice est érigé vers le XIIIe siècle par le roi Koy Komboro après sa conversion à l\'islam. Djenné étant le carrefour marchand par excellence entre le Sahara et la forêt tropicale, la mosquée devient immédiatement un phare spirituel et intellectuel renommé dans tout le monde musulman.',
        ),
        EditorialStoryChapter(
          title: 'Le Chef-d\'œuvre de la Maçonnerie Traditionnelle',
          content: 'La corporation des maçons traditionnels de Djenné, les "Barey Ton", transmettent de père en fils les secrets de composition du banco et la taille des voûtes. L\'intérieur de la mosquée est une forêt de 90 piliers massifs qui maintiennent une température fraîche à 22°C même sous la canicule saharienne.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'ville_djenne',
          title: 'Djenné',
          subtitle: 'La Cité Millénaire du Bani',
          type: ConnectedItemType.ville,
          tag: 'UNESCO',
          regionName: 'Mopti',
          icon: Icons.location_city_rounded,
        ),
        ConnectedItemRef(
          id: 'monument_djingareyber',
          title: 'Mosquée Djingareyber',
          subtitle: 'Autre joyau soudanais à Tombouctou',
          type: ConnectedItemType.monument,
          tag: 'UNESCO',
          regionName: 'Tombouctou',
          icon: Icons.museum_rounded,
        ),
      ],
    ),

    // Tombeau des Askia
    MonumentDetail(
      id: 'monument_tombeau_askia',
      name: 'Tombeau pyramidal des Askia',
      subtitle: 'La Pyramide Sahélienne de l\'Empire Songhoï',
      era: 'Édifié en 1495 par Askia Mohammed',
      regionId: 'gao',
      regionName: 'Gao',
      tag: 'Patrimoine Mondial UNESCO (2004)',
      photoUrl: 'assets/images/culture/monuments/tombeau_askia.jpg',
      photoCredits: 'Photographie du complexe des Askia à Gao • Cliché Patrimoine Mondial',
      locationDetails: 'Quartier historique, Ville de Gao, Bord du Niger',
      presentation: 'Le Tombeau des Askia est une impressionnante structure pyramidale à degrés en banco de 17 mètres de hauteur, entourée de deux mosquées à toit plat, d\'un cimetière historique et d\'un espace de prière en plein air.',
      architectureAndMaterials: 'Construit en terre crue et bois d\'acacia, il reflète l\'adoption par l\'Empire Songhoï des techniques monumentales sahariennes. Des poutres apparentes en bois hérissent sa façade pyramidale, permettant son entretien périodique par les artisans de Gao.',
      whyItMatters: 'Témoin unique de la grandeur et de la puissance de l\'Empire Songhoï qui dominait l\'Afrique de l\'Ouest aux XVe et XVIe siècles, le tombeau est le symbole absolu de la mémoire impériale de Gao.',
      keyFacts: [
        HistoricalKeyFact(label: 'Hauteur', value: '17 mètres (forme pyramidale)', icon: Icons.height_rounded),
        HistoricalKeyFact(label: 'Fondateur', value: 'Empereur Askia Mohammed (1495)', icon: Icons.person_rounded),
        HistoricalKeyFact(label: 'Époque', value: 'Empire Songhoï (XVe siècle)', icon: Icons.history_edu_rounded),
        HistoricalKeyFact(label: 'Classement', value: 'UNESCO depuis 2004', icon: Icons.verified_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'Un Monument Impérial au Cœur du Sahara',
          content: 'À son retour de La Mecque en 1495, Askia Mohammed ordonne la construction de ce complexe funéraire inspiré des grandes pyramides tout en conservant l\'authenticité architecturale des bâtisseurs songhoï. Il y repose entouré de la dévotion séculaire des habitants de Gao.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'perso_askia_mohammed',
          title: 'Askia Mohammed',
          subtitle: 'Le Souverain inhumé au Tombeau',
          type: ConnectedItemType.personnage,
          tag: 'Empereur',
          regionName: 'Gao',
          icon: Icons.person_rounded,
        ),
        ConnectedItemRef(
          id: 'ville_gao',
          title: 'Gao',
          subtitle: 'Capitale impériale Songhoï',
          type: ConnectedItemType.ville,
          tag: 'Cité Historique',
          regionName: 'Gao',
          icon: Icons.location_city_rounded,
        ),
      ],
    ),

    // Le Tata de Sikasso
    MonumentDetail(
      id: 'monument_tata_sikasso',
      name: 'Le Tata de Sikasso',
      subtitle: 'La Muraille Héroïque de Résistance du Kénédougou',
      era: 'Construit entre 1877 et 1890 sous Tiéba et Babemba Traoré',
      regionId: 'sikasso',
      regionName: 'Sikasso',
      tag: 'Monument National Historique',
      photoUrl: 'assets/images/culture/monuments/tata_sikasso.jpg',
      photoCredits: 'Vestiges protégés du Tata de Sikasso • Cliché Direction Nationale du Patrimoine',
      locationDetails: 'Pourtour historique de Sikasso, Colline du Mamelon',
      presentation: 'Le Tata de Sikasso était une colossale muraille fortifiée en banco et pierres latéritiques longue de plus de 9 kilomètres, ceinturant toute la ville de Sikasso avec des tours de guet, des bastions défensifs et d\'épaisses portes fortifiées.',
      architectureAndMaterials: 'Érigée avec des blocs d\'argile compactée renforcés de latérite et de pierres, la muraille atteignait jusqu\'à 6 mètres de hauteur et 3 mètres d\'épaisseur à la base, capable de résister aux tirs de canons de l\'époque.',
      whyItMatters: 'Le Tata est le symbole indélébile du courage et de la détermination du peuple malien face à la conquête. Il rappelle la devise patriotique du roi Babemba Traoré : "Plutôt la mort que la honte !".',
      keyFacts: [
        HistoricalKeyFact(label: 'Périmètre', value: '9,5 km de circonférence', icon: Icons.square_foot_rounded),
        HistoricalKeyFact(label: 'Épaisseur', value: 'Jusqu\'à 3 mètres à la base', icon: Icons.shield_rounded),
        HistoricalKeyFact(label: 'Bâtisseurs', value: 'Rois Tiéba et Babemba Traoré', icon: Icons.people_rounded),
        HistoricalKeyFact(label: 'Haut fait', value: 'Résistance héroïque de 1898', icon: Icons.military_tech_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'Une Forteresse Inexpugnable',
          content: 'Conçu en trois enceintes concentriques pour protéger les réserves agricoles, les habitations et le palais royal, le Tata de Sikasso a résisté victorieusement à de multiples assauts, notamment le siège de quinze mois mené par Samory Touré en 1887.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'perso_babemba',
          title: 'Babemba Traoré',
          subtitle: 'Le Défenseur du Tata',
          type: ConnectedItemType.personnage,
          tag: 'Héros National',
          regionName: 'Sikasso',
          icon: Icons.person_rounded,
        ),
        ConnectedItemRef(
          id: 'ville_sikasso',
          title: 'Sikasso',
          subtitle: 'La Cité du Kénédougou',
          type: ConnectedItemType.ville,
          tag: 'Capitale',
          regionName: 'Sikasso',
          icon: Icons.location_city_rounded,
        ),
      ],
    ),

    // Mosquée Djingareyber
    MonumentDetail(
      id: 'monument_djingareyber',
      name: 'Mosquée Djingareyber',
      subtitle: 'Le Grand Sanctuaire de Mansa Moussa',
      era: 'Érigée en 1327 par Abou Ishaq es-Sahéli',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      tag: 'Patrimoine Mondial UNESCO (1988)',
      photoUrl: 'assets/images/culture/monuments/mosquee_djingareyber.jpg',
      photoCredits: 'Mosquée Djingareyber, Tombouctou • Cliché Patrimoine Mondial UNESCO',
      locationDetails: 'Centre-ville de Tombouctou, Quartier Djingareyber',
      presentation: 'La Mosquée Djingareyber est le plus ancien sanctuaire encore en activité à Tombouctou. Conçue entièrement en banco, bois de palmier et pierres de calcaire, elle frappe par la pureté de ses lignes et son minaret tronconique dominant la ville mystique.',
      architectureAndMaterials: 'Construite sur commande de Mansa Moussa par le maître andalou Es-Sahéli, elle introduit dans l\'architecture soudanaise la voûte et l\'utilisation raffinée de briques cuites mêlées à la terre crue.',
      whyItMatters: 'Symbole du rayonnement intellectuel et spirituel de Tombouctou, elle a abrité des générations de savants et continue d\'accueillir chaque vendredi les fidèles de toute la région.',
      keyFacts: [
        HistoricalKeyFact(label: 'Fondation', value: '1327 (Mansa Moussa)', icon: Icons.history_edu_rounded),
        HistoricalKeyFact(label: 'Architecte', value: 'Abou Ishaq es-Sahéli (Grenade)', icon: Icons.architecture_rounded),
        HistoricalKeyFact(label: 'Statut', value: 'Patrimoine Mondial UNESCO', icon: Icons.verified_rounded),
        HistoricalKeyFact(label: 'Rôle', value: 'Cœur spirituel de Tombouctou', icon: Icons.menu_book_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'La Vision de Mansa Moussa',
          content: 'Ébloui par les monuments du Caire et de La Mecque lors de son pèlerinage de 1324, Mansa Moussa voulut doter Tombouctou d\'une mosquée digne de la grandeur de l\'Empire du Mali. Il alloua 200 kilos d\'or pour financer sa réalisation.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'perso_mansa_moussa',
          title: 'Mansa Moussa',
          subtitle: 'Le Mécène Bâtisseur',
          type: ConnectedItemType.personnage,
          tag: 'Empereur',
          regionName: 'Tombouctou',
          icon: Icons.person_rounded,
        ),
        ConnectedItemRef(
          id: 'ville_tombouctou',
          title: 'Tombouctou',
          subtitle: 'La Cité aux 333 Saints',
          type: ConnectedItemType.ville,
          tag: 'Savoirs Sahéliens',
          regionName: 'Tombouctou',
          icon: Icons.location_city_rounded,
        ),
      ],
    ),

    // Fort de Médine
    MonumentDetail(
      id: 'monument_fort_medine',
      name: 'Fort de Médine',
      subtitle: 'Sentinelle historique du Haut-Sénégal',
      era: 'Construit en 1855 sur les rives du fleuve Sénégal',
      regionId: 'kayes',
      regionName: 'Kayes',
      tag: 'Site Historique National',
      photoUrl: 'assets/images/culture/monuments/fort_medine.jpg',
      photoCredits: 'Fort de Médine sur le fleuve Sénégal, Région de Kayes • Archives Patrimoine',
      locationDetails: 'Médine, à 12 km de Kayes, au pied des chutes du Félou',
      presentation: 'Situé au bord du majestueux fleuve Sénégal, le Fort de Médine est une forteresse de pierre témoin des grandes confrontations du XIXe siècle entre les royaumes locaux, l\'épopée d\'El Hadj Oumar Tall et les forces coloniales.',
      architectureAndMaterials: 'Bâti en pierres taillées de grès rouge et maçonnerie robuste, le fort comprend des bastions de tir, une poudrière, un poste de commandement et d\'imposants remparts surplombant les eaux du fleuve.',
      whyItMatters: 'Le site de Médine est un lieu de mémoire capital pour comprendre l\'histoire diplomatique et militaire du Haut-Sénégal et la résistance des peuples khassonkés et toucouleurs.',
      keyFacts: [
        HistoricalKeyFact(label: 'Localisation', value: 'Région de Kayes (Fleuve Sénégal)', icon: Icons.water_rounded),
        HistoricalKeyFact(label: 'Siège mémorable', value: '1857 (El Hadj Oumar Tall)', icon: Icons.shield_rounded),
        HistoricalKeyFact(label: 'Cadre naturel', value: 'Près des Chutes de Félou', icon: Icons.landscape_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'Le Siège Épique de 1857',
          content: 'Pendant plusieurs mois en 1857, le fort fut assiégé par les milliers de guerriers de l\'armée d\'El Hadj Oumar Tall. L\'histoire locale retient la résistance acharnée des défenseurs commandés par Paul Holle et l\'intervention des souverains du Khasso.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'perso_soundiata',
          title: 'Soundiata Keïta',
          subtitle: 'L\'héritage mandingue de l\'Ouest',
          type: ConnectedItemType.personnage,
          tag: 'Fondateur',
          regionName: 'Koulikoro',
          icon: Icons.person_rounded,
        ),
      ],
    ),

    // Mosquée & Université de Sankoré
    MonumentDetail(
      id: 'monument_sankore',
      name: 'Université & Mosquée de Sankoré',
      subtitle: 'Le Phare Universitaire de l\'Afrique Médiévale',
      era: 'Fondée au XIVe siècle sous l\'Empire du Mali',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      tag: 'Patrimoine Mondial UNESCO',
      photoUrl: 'assets/images/culture/monuments/mosquee_sankore.jpg',
      photoCredits: 'Mosquée de Sankoré, Tombouctou • Cliché Patrimoine UNESCO',
      locationDetails: 'Quartier Sankoré, Ville de Tombouctou',
      presentation: 'Sankoré n\'était pas seulement une mosquée, mais l\'une des plus prestigieuses universités du monde médiéval. Plus de 25 000 étudiants y étudiaient simultanément le droit, l\'astronomie, la médecine, la logique et les mathématiques.',
      architectureAndMaterials: 'Construite en banco selon des proportions géométriques sacrées calquées sur la Kaaba, son minaret en gradins est l\'un des repères les plus admirés de Tombouctou.',
      whyItMatters: 'Sankoré est la preuve éclatante de la tradition scientifique et écrite séculaire du Mali, abritant des centaines de milliers de manuscrits rares préservés par les familles de lettrés.',
      keyFacts: [
        HistoricalKeyFact(label: 'Étudiants', value: '25 000 étudiants au XVIe siècle', icon: Icons.school_rounded),
        HistoricalKeyFact(label: 'Disciplines', value: 'Astronomie, Médecine, Droit, Mathématiques', icon: Icons.science_rounded),
        HistoricalKeyFact(label: 'Patrimoine', value: 'Plus de 700 000 manuscrits anciens', icon: Icons.auto_stories_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'La Capitale Mondiale du Livre',
          content: 'À son âge d\'or, le commerce des livres manuscrits à Sankoré était plus lucratif que celui de l\'or et du sel. De grands savants comme Ahmed Baba de Tombouctou y rédigeaient des traités de jurisprudence et de science consultés jusqu\'au Maghreb et au Proche-Orient.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'ville_tombouctou',
          title: 'Tombouctou',
          subtitle: 'La Cité des Manuscrits',
          type: ConnectedItemType.ville,
          tag: 'Savoirs Sahéliens',
          regionName: 'Tombouctou',
          icon: Icons.location_city_rounded,
        ),
        ConnectedItemRef(
          id: 'monument_djingareyber',
          title: 'Mosquée Djingareyber',
          subtitle: 'Le Grand Sanctuaire',
          type: ConnectedItemType.monument,
          tag: 'UNESCO',
          regionName: 'Tombouctou',
          icon: Icons.museum_rounded,
        ),
      ],
    ),
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // 3. VILLES ET VILLAGES DU MALI
  // ══════════════════════════════════════════════════════════════════════════

  static const List<PlaceDetail> places = [
    // Djenné
    PlaceDetail(
      id: 'ville_djenne',
      name: 'Djenné',
      subtitle: 'La Cité Millénaire du Bani & Joyau de l\'Architecture en Terre',
      regionId: 'mopti',
      regionName: 'Mopti',
      tag: 'Cité Classée UNESCO',
      photoUrl: 'assets/images/culture/villes/djenne_ville.jpg',
      photoCredits: 'Ruelle authentique de la cité historique de Djenné • Cliché Réel de Rue',
      fondation: 'Fondée vers 250 av. J.-C. (Djenné-Djeno) et érigée au IXe siècle',
      resume: 'Entourée par les bras du fleuve Bani, Djenné est une île fluviale féerique et l\'une des plus anciennes cités urbaines d\'Afrique subsaharienne. Ses près de 2 000 maisons traditionnelles à étage en terre crue forment un ensemble architectural homogène sans équivalent dans le monde.',
      identiteCulturelle: 'Djenné est renommée pour sa culture du banco, ses confréries de maîtres maçons (Barey Ton), ses tissus traditionnels teints à l\'indigo et son atmosphère intemporelle rythmée par le grand marché hebdomadaire du lundi.',
      traditionsAndPatrimoine: 'Les façades richement ouvragées des demeures nobles ("style toucouleur" et "style marocain") comportent des pilastres décoratifs (sarho) et des auvents protecteurs qui témoignent du raffinement séculaire des familles djennenkés.',
      keyFacts: [
        HistoricalKeyFact(label: 'Origine', value: 'Plus de 2 000 ans d\'histoire continue', icon: Icons.history_rounded),
        HistoricalKeyFact(label: 'Statut', value: 'Ensemble urbain classé UNESCO', icon: Icons.verified_rounded),
        HistoricalKeyFact(label: 'Événement', value: 'Grand marché séculaire du lundi', icon: Icons.shopping_bag_rounded),
        HistoricalKeyFact(label: 'Corporation', value: 'Les Maîtres Maçons "Barey Ton"', icon: Icons.architecture_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'Djenné-Djeno, Berceau de la Métallurgie Fluviale',
          content: 'Les fouilles archéologiques ont révélé que le site originel de Djenné-Djeno était déjà une métropole marchande florissante bien avant l\'arrivée des routes transsahariennes, attestant d\'un développement urbain et métallurgique indigène remarquable.',
        ),
        EditorialStoryChapter(
          title: 'L\'Art de Vivre Djennenké',
          content: 'Vivre à Djenné, c\'est être en symbiose avec les cycles du fleuve Bani et de la terre. Les toits-terrasses servent de lieux de fraîcheur nocturne, et les cours intérieures ombragées abritent les ateliers de broderie et de tissage qui font la renommée du Mali.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'monument_mosquee_djenne',
          title: 'Grande Mosquée de Djenné',
          subtitle: 'Le chef-d\'œuvre au cœur de la cité',
          type: ConnectedItemType.monument,
          tag: 'UNESCO',
          regionName: 'Mopti',
          icon: Icons.museum_rounded,
        ),
        ConnectedItemRef(
          id: 'ville_bandiagara',
          title: 'Bandiagara & Falaise Dogon',
          subtitle: 'Voisins du Pays Dogon',
          type: ConnectedItemType.ville,
          tag: 'Patrimoine',
          regionName: 'Mopti',
          icon: Icons.landscape_rounded,
        ),
      ],
    ),

    // Ségou-Koro
    PlaceDetail(
      id: 'ville_segou_koro',
      name: 'Ségou-Koro',
      subtitle: 'L\'Ancienne Capitale Royale des 4 444 Balanzans',
      regionId: 'segou',
      regionName: 'Ségou',
      tag: 'Cité Royale',
      photoUrl: 'assets/images/culture/villes/segou_koro.jpg',
      photoCredits: 'Bords du fleuve Niger à Ségou • Cliché Photographique Réel',
      fondation: 'Capitale du Royaume Bambara au XVIIIe siècle',
      resume: 'Situé à 10 kilomètres en amont de Ségou au bord du Djoliba, Ségou-Koro ("le Vieux Ségou") est le village historique où le roi Biton Coulibaly établit la capitale de son royaume en 1712. Ses ruelles ombragées de balanzans ancestraux conservent intacte l\'aura royale bambara.',
      identiteCulturelle: 'Terre des artisans potiers de Kalabougou et des maîtres tisserands du Bogolan, Ségou-Koro est le gardien des traditions orales et des grands récits épiques des Tônjons chantés lors du festival annuel sur le fleuve.',
      traditionsAndPatrimoine: 'Le village abrite le tombeau sacré de Biton Coulibaly, la première mosquée construite pour sa mère et les vestiges de la cour royale où les sages continuent de rendre hommage aux ancêtres fondateurs.',
      keyFacts: [
        HistoricalKeyFact(label: 'Symbole', value: 'L\'arbre sacré : le Balanzan', icon: Icons.park_rounded),
        HistoricalKeyFact(label: 'Fondateur', value: 'Roi Biton Coulibaly (1712)', icon: Icons.person_rounded),
        HistoricalKeyFact(label: 'Artisanat', value: 'Bogolan et poteries séculaires', icon: Icons.palette_rounded),
        HistoricalKeyFact(label: 'Fleuve', value: 'Sur les rives du Djoliba (Niger)', icon: Icons.water_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'Le Sanctuaire des Rois Bambaras',
          content: 'Chaque ruelle en banco de Ségou-Koro respire l\'histoire du XVIIIe siècle. Les anciens conservent avec respect le palais originel et le vestibule royal où se prenaient les décisions qui ont façonné le centre du Mali.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'perso_biton_coulibaly',
          title: 'Biton Coulibaly',
          subtitle: 'Le Fondateur inhumé à Ségou-Koro',
          type: ConnectedItemType.personnage,
          tag: 'Roi de Ségou',
          regionName: 'Ségou',
          icon: Icons.person_rounded,
        ),
      ],
    ),

    // Bandiagara & Falaise Dogon
    PlaceDetail(
      id: 'ville_bandiagara',
      name: 'Bandiagara & Falaise Dogon',
      subtitle: 'Les Villages Suspendus du Pays Dogon & la Cosmogonie de Sirius',
      regionId: 'mopti',
      regionName: 'Mopti',
      tag: 'Patrimoine Mondial UNESCO (1989)',
      photoUrl: 'assets/images/culture/villes/bandiagara_falaise.jpg',
      photoCredits: 'Village accroché à la Falaise de Bandiagara • Cliché Patrimoine UNESCO',
      fondation: 'Établissement dogon dès le XIVe siècle',
      resume: 'S\'étendant sur plus de 150 kilomètres de grès rouge, la Falaise de Bandiagara abrite des dizaines de villages spectaculaires nichés à flanc de falaise. Le peuple Dogon y a préservé l\'un des ensembles cosmogoniques, rituels et architecturaux les plus fascinants de l\'humanité.',
      identiteCulturelle: 'Réputé pour ses danses masquées rituelles (Dama), ses greniers sculptés à toits de chaume et la place centrale du Toguna (la maison de la parole des aînés), le Pays Dogon est une leçon vivante d\'harmonie entre l\'homme et la roche.',
      traditionsAndPatrimoine: 'L\'astronomie traditionnelle dogon, qui connaissait les mouvements de l\'étoile compagne invisible Sirius B bien avant les télescopes modernes, fascine les scientifiques du monde entier.',
      keyFacts: [
        HistoricalKeyFact(label: 'Falaise', value: '150 km de grès rouge spectaculaire', icon: Icons.terrain_rounded),
        HistoricalKeyFact(label: 'Architecture', value: 'Toguna (Maison de la parole) & Greniers', icon: Icons.house_rounded),
        HistoricalKeyFact(label: 'Rituel majeur', value: 'La Fête du Sigui (tous les 60 ans)', icon: Icons.celebration_rounded),
        HistoricalKeyFact(label: 'UNESCO', value: 'Double classement Nature & Culture (1989)', icon: Icons.verified_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'Le Toguna, Sanctuaire de la Démocratie Orale',
          content: 'Le Toguna est une bâtisse basse au toit de huit couches de tiges de mil. Sa hauteur volontairement réduite oblige les hommes à s\'asseoir, empêchant toute dispute violente et favorisant la conciliation paisible.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'ville_djenne',
          title: 'Djenné',
          subtitle: 'Cité sœur de la région de Mopti',
          type: ConnectedItemType.ville,
          tag: 'UNESCO',
          regionName: 'Mopti',
          icon: Icons.location_city_rounded,
        ),
      ],
    ),

    // Tombouctou
    PlaceDetail(
      id: 'ville_tombouctou',
      name: 'Tombouctou',
      subtitle: 'La Cité Mystique des 333 Saints & Carrefour Transsaharien',
      regionId: 'tombouctou',
      regionName: 'Tombouctou',
      tag: 'Patrimoine Mondial UNESCO (1988)',
      photoUrl: 'assets/images/culture/villes/tombouctou_ville.jpg',
      photoCredits: 'Ruelle de sable et portes sculptées de Tombouctou • Cliché Réel Sahélien',
      fondation: 'Fondée vers 1100 par les pasteurs touaregs',
      resume: 'Située aux portes du désert du Sahara là où la boucle du fleuve Niger s\'approche le plus du nord, Tombouctou est le carrefour mythique où se rencontraient caravanes de sel, orateurs, astronomes et marchands d\'or et de manuscrits précieux.',
      identiteCulturelle: 'Célèbre pour ses portes en bois clouté de style marocain, ses trois grandes mosquées médiévales et la ferveur de ses 333 saints protecteurs inhumés dans la cité.',
      traditionsAndPatrimoine: 'Les bibliothèques familiales privées et l\'Institut des Hautes Études Islamiques Ahmed Baba conservent plus de 700 000 manuscrits anciens rédigés en arabe et langues locales couvrant la physique, la médecine, la diplomatie et la poésie.',
      keyFacts: [
        HistoricalKeyFact(label: 'Surnom', value: 'La Cité des 333 Saints', icon: Icons.auto_stories_rounded),
        HistoricalKeyFact(label: 'Sanctuaires', value: 'Djingareyber, Sankoré, Sidi Yahya', icon: Icons.museum_rounded),
        HistoricalKeyFact(label: 'Trésor écrit', value: '700 000 Manuscrits de Tombouctou', icon: Icons.menu_book_rounded),
        HistoricalKeyFact(label: 'UNESCO', value: 'Classée depuis 1988', icon: Icons.verified_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'L\'Âge d\'Or du Savoir Saharien',
          content: 'Au XVIe siècle, Tombouctou comptait plus de 100 000 habitants et constituait le phare universitaire de l\'Afrique de l\'Ouest. Les étudiants venus d\'Égypte, du Maroc et de toute l\'Afrique subsaharienne y recevaient un enseignement d\'une rigueur absolue.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'monument_djingareyber',
          title: 'Mosquée Djingareyber',
          subtitle: 'Érigée en 1327',
          type: ConnectedItemType.monument,
          tag: 'UNESCO',
          regionName: 'Tombouctou',
          icon: Icons.museum_rounded,
        ),
        ConnectedItemRef(
          id: 'monument_sankore',
          title: 'Université de Sankoré',
          subtitle: 'Temple du savoir médiéval',
          type: ConnectedItemType.monument,
          tag: 'UNESCO',
          regionName: 'Tombouctou',
          icon: Icons.school_rounded,
        ),
        ConnectedItemRef(
          id: 'perso_mansa_moussa',
          title: 'Mansa Moussa',
          subtitle: 'Le Mécène Impérial',
          type: ConnectedItemType.personnage,
          tag: 'Empereur',
          regionName: 'Tombouctou',
          icon: Icons.person_rounded,
        ),
      ],
    ),

    // Sikasso
    PlaceDetail(
      id: 'ville_sikasso',
      name: 'Sikasso',
      subtitle: 'Le Verger Généreux du Mali & Capitale du Kénédougou',
      regionId: 'sikasso',
      regionName: 'Sikasso',
      tag: 'Cité du Kénédougou',
      photoUrl: 'assets/images/culture/villes/sikasso_ville.jpg',
      photoCredits: 'Paysage verdoyant et collines du Kénédougou, Sikasso • Cliché Réel',
      fondation: 'Fondée au XIXe siècle par Mansa Doula',
      resume: 'Deuxième ville la plus peuplée du Mali, Sikasso est réputée pour ses terres d\'une fertilité exceptionnelle et ses vergers de manguiers. Capitale du Royaume du Kénédougou, elle s\'est illustrée par sa résistance héroïque lors du siège de 1898.',
      identiteCulturelle: 'Carrefour cosmopolite et chaleureux bordé par la Côte d\'Ivoire et le Burkina Faso, Sikasso célèbre la culture des Senoufo, des Samogo et des Bambaras à travers ses danses au balafon et ses fêtes agricoles.',
      traditionsAndPatrimoine: 'La ville abrite le Mamelon (colline historique fortifiée), les vestiges du Tata de Sikasso, le Musée Régional et les grottes sacrées de Missirikoro.',
      keyFacts: [
        HistoricalKeyFact(label: 'Climat', value: 'Région la plus verte et arrosée du Mali', icon: Icons.nature_rounded),
        HistoricalKeyFact(label: 'Patrimoine', value: 'Le Mamelon & les Vestiges du Tata', icon: Icons.castle_rounded),
        HistoricalKeyFact(label: 'Culture', value: 'Le Balafon et les danses Sénoufo', icon: Icons.music_note_rounded),
        HistoricalKeyFact(label: 'Agriculture', value: 'Capitale fruitière et céréalière', icon: Icons.eco_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'La Colline Sacrée du Mamelon',
          content: 'Au cœur de la ville s\'élève le Mamelon, une butte aménagée par le roi Tiéba Traoré comme poste d\'observation stratégique et lieu de réceptions diplomatiques solennelles.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'monument_tata_sikasso',
          title: 'Le Tata de Sikasso',
          subtitle: 'La Muraille Héroïque',
          type: ConnectedItemType.monument,
          tag: 'Fortification',
          regionName: 'Sikasso',
          icon: Icons.castle_rounded,
        ),
        ConnectedItemRef(
          id: 'perso_babemba',
          title: 'Babemba Traoré',
          subtitle: 'Le Héros de Sikasso',
          type: ConnectedItemType.personnage,
          tag: 'Héros',
          regionName: 'Sikasso',
          icon: Icons.person_rounded,
        ),
      ],
    ),

    // Gao
    PlaceDetail(
      id: 'ville_gao',
      name: 'Gao',
      subtitle: 'La Cité Impériale des Songhoï & Porte de la Dune Rose',
      regionId: 'gao',
      regionName: 'Gao',
      tag: 'Cité Impériale Songhoï',
      photoUrl: 'assets/images/culture/villes/gao_dune_rose.jpg',
      photoCredits: 'La Dune Rose de Koïma surplombant le fleuve Niger à Gao • Cliché Photographique Réel',
      fondation: 'Mentionnée dès le IXe siècle sous le nom de Kaw-Kaw',
      resume: 'Ancienne capitale de l\'immense Empire Songhoï, Gao est une cité fière assise sur la rive gauche du fleuve Niger. Elle allie la majesté des paysages dunaires sahariens (comme la célèbre Dune Rose de Koïma) à la vitalité des peuples riverains.',
      identiteCulturelle: 'Gao est le cœur de la culture Songhoï, renommée pour ses chants au violon monocorde (njarka), ses nattes artisanales colorées et sa gastronomie fluviale.',
      traditionsAndPatrimoine: 'Elle abrite le Tombeau pyramidal des Askia (UNESCO), le site archéologique de Gao Saney réputé pour ses stèles funéraires médiévales en marbre et le Musée du Sahel.',
      keyFacts: [
        HistoricalKeyFact(label: 'Histoire', value: 'Capitale de l\'Empire Songhoï (1464-1591)', icon: Icons.history_edu_rounded),
        HistoricalKeyFact(label: 'Monument phare', value: 'Tombeau des Askia (UNESCO 2004)', icon: Icons.museum_rounded),
        HistoricalKeyFact(label: 'Site naturel', value: 'La Dune Rose de Koïma (Djoliba)', icon: Icons.landscape_rounded),
      ],
      chapters: [
        EditorialStoryChapter(
          title: 'Gao Saney et les Échanges Caravaniers',
          content: 'Dès le Xe siècle, Gao était le centre d\'un commerce international d\'une richesse inouïe reliant l\'Espagne musulmane, l\'Égypte et les royaumes sahéliens.',
        ),
      ],
      connectedItems: [
        ConnectedItemRef(
          id: 'monument_tombeau_askia',
          title: 'Tombeau des Askia',
          subtitle: 'La Pyramide de Gao',
          type: ConnectedItemType.monument,
          tag: 'UNESCO',
          regionName: 'Gao',
          icon: Icons.museum_rounded,
        ),
        ConnectedItemRef(
          id: 'perso_askia_mohammed',
          title: 'Askia Mohammed',
          subtitle: 'L\'Empereur des Songhoï',
          type: ConnectedItemType.personnage,
          tag: 'Empereur',
          regionName: 'Gao',
          icon: Icons.person_rounded,
        ),
      ],
    ),
  ];

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER RETRIEVERS
  // ══════════════════════════════════════════════════════════════════════════

  static HistoricalFigureDetail getFigureById(String id) {
    return figures.firstWhere(
      (f) => f.id == id,
      orElse: () => figures.first,
    );
  }

  static MonumentDetail getMonumentById(String id) {
    return monuments.firstWhere(
      (m) => m.id == id,
      orElse: () => monuments.first,
    );
  }

  static PlaceDetail getPlaceById(String id) {
    return places.firstWhere(
      (p) => p.id == id,
      orElse: () => places.first,
    );
  }
}
