import 'package:flutter/material.dart';
import '../models/culture_detail_models.dart';
import '../models/culture_item.dart';

/// Jeu de données initial certifié conforme à la base de données centrale
/// Utilisé en cache hors-ligne initial lors du premier lancement sans réseau.
abstract final class CultureDatabaseSeed {
  // ── FIGURES INITIALES CERTIFIÉES ──────────────────────────────────────────
  static const List<CultureItem> initialFigures = [
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
    CultureItem(
      id: 'perso_modibo_keita',
      title: 'Modibo Keïta',
      subtitle: 'Père de l\'Indépendance & Premier Président',
      category: 'decouvrir',
      subCategory: 'personnages',
      description:
          'Figure majeure du panafricanisme et artisan de la proclamation de l\'indépendance le 22 septembre 1960.',
      regionId: 'bamako',
      regionName: 'Bamako',
      tag: 'Père de la Nation',
      icon: Icons.flag_rounded,
      imageUrl: 'assets/images/culture/personnages/modibo_keita.jpg',
      info: '1915 – 1977',
    ),
  ];

  // ── LIEUX & TERROIRS INITIAUX CERTIFIÉS ──────────────────────────────────
  static const List<CultureItem> initialPlaces = [
    CultureItem(
      id: 'ville_bamako',
      title: 'Bamako',
      subtitle: 'La Cité des Trois Caïmans',
      category: 'decouvrir',
      subCategory: 'villes',
      description:
          'Capitale politique et artistique du Mali étirée le long du fleuve Niger.',
      regionId: 'bamako',
      regionName: 'Bamako',
      tag: 'Capitale',
      icon: Icons.location_city_rounded,
      imageUrl: 'assets/images/culture/monuments/monument_independance.jpg',
      info: 'Fondée au XVIIe s.',
    ),
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
    CultureItem(
      id: 'ville_gao',
      title: 'Gao',
      subtitle: 'La Cité Impériale des Songhoï',
      category: 'decouvrir',
      subCategory: 'villes',
      description:
          'Ancienne capitale de l\'immense Empire Songhoï sur la rive gauche du fleuve Niger.',
      regionId: 'gao',
      regionName: 'Gao',
      tag: 'Empire Songhoï',
      icon: Icons.landscape_rounded,
      imageUrl: 'assets/images/culture/villes/gao_dune_rose.jpg',
      info: 'Dune Rose de Koïma',
    ),
  ];

  // ── CONTES INITIAUX CERTIFIÉS ─────────────────────────────────────────────
  static const List<CultureItem> initialStories = [
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
      tag: 'Conte Populaire',
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

  // ── DÉFIS ET DEVINETTES INITIAUX CERTIFIÉS ────────────────────────────────
  static const List<CultureItem> initialDefis = [
    CultureItem(
      id: 'defi_nda_baobab',
      title: '« Nda ! » — Les Énigmes du Baobab',
      subtitle: 'Devinettes traditionnelles Bambara',
      category: 'defis',
      subCategory: 'devinettes',
      description:
          'Répondez par « N\'sira » et élucidez les énigmes poétiques posées par nos aïeux.',
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

  // ── FICHES DÉTAILLÉES DE PERSONNAGES (OFFLINE FALLBACK) ────────────────────
  static HistoricalFigureDetail? getInitialFigureDetail(String id) {
    switch (id) {
      case 'perso_soundiata':
        return const HistoricalFigureDetail(
          id: 'perso_soundiata',
          name: 'Soundiata Keïta',
          titleHonorifique: 'Le Lion du Manden & Fondateur de l\'Empire du Mali',
          period: '1190 – 1255',
          regionId: 'koulikoro',
          regionName: 'Koulikoro',
          tag: 'Mansa Bâtisseur',
          photoUrl: 'assets/images/culture/personnages/soundiata.jpg',
          photoCredits: 'Mémorial Historique du Manden, Kangaba • Archives Patrimoniales',
          resume:
              'Bâtisseur de l\'Empire du Mali après sa victoire décisive à la bataille de Kirina en 1235, il proclame en 1236 la Charte de Kouroukan Fouga, l\'une des toutes premières déclarations des droits humains et du vivre-ensemble.',
          citationHistorique:
              '« Toute vie humaine est une vie. Le tort fait à autrui demande réparation. Respectez l\'étranger, l\'aîné et la femme. »\n— Charte du Manden, 1236',
          keyFacts: [
            HistoricalKeyFact(label: 'Règne', value: '1235 – 1255', icon: Icons.workspace_premium_rounded),
            HistoricalKeyFact(label: 'Victoire majeure', value: 'Bataille de Kirina (1235)', icon: Icons.shield_rounded),
            HistoricalKeyFact(label: 'Héritage universel', value: 'Charte du Manden (UNESCO)', icon: Icons.auto_stories_rounded),
            HistoricalKeyFact(label: 'Capitale originelle', value: 'Niani', icon: Icons.location_city_rounded),
          ],
          chapters: [
            EditorialStoryChapter(
              title: 'L\'Enfance et la Prophétie du Manden',
              content:
                  'Fils de Naré Maghann Konaté et de Sogolon Kondé, Soundiata naît paralysé des jambes. Écarté du pouvoir après la mort de son père et contraint à l\'exil avec sa mère, il fait preuve d\'une volonté inébranlable. Guidé par la foi en son destin et la parole des aînés, il réussit à se redresser à l\'aide d\'une barre de fer forgée par les maîtres du feu, devenant un chasseur émérite et un meneur d\'hommes admiré de tout le Manden.',
            ),
            EditorialStoryChapter(
              title: 'L\'Unification et la Victoire de Kirina (1235)',
              content:
                  'Face à la tyrannie du roi-sorcier Soumaoro Kanté du Sosso, les clans mandingues opprimés appellent Soundiata au secours. Il rassemble les tribus alliées, forgeant une coalition puissante fondée sur la loyauté et la bravoure. La confrontation finale se déroule à Kirina (dans l\'actuelle région de Koulikoro). Soundiata triomphe grâce à sa clairvoyance stratégique et brise l\'hégémonie du Sosso, unifiant pour la première fois les peuples du fleuve Niger.',
            ),
            EditorialStoryChapter(
              title: 'La Charte de Kouroukan Fouga (1236)',
              content:
                  'Réunis dans la clairière de Kouroukan Fouga à Kangaba, Soundiata et les chefs de tribus proclament en 1236 une constitution orale de 44 articles. Cette charte sacralise la dignité de la personne, abolit la servitude cruelle, institue la paix sociale par la parenté à plaisanterie (Sinankunya), accorde une place centrale aux femmes et protège la nature. Reconnue par l\'UNESCO comme patrimoine immatériel universel, elle demeure le socle moral du Mali.',
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
          ],
        );

      case 'perso_mansa_moussa':
        return const HistoricalFigureDetail(
          id: 'perso_mansa_moussa',
          name: 'Mansa Moussa',
          titleHonorifique: 'Le Souverain d\'Or & Bâtisseur du Savoir Universel',
          period: '1312 – 1337',
          regionId: 'tombouctou',
          regionName: 'Tombouctou',
          tag: 'Âge d\'Or Impérial',
          photoUrl: 'assets/images/culture/personnages/mansa_moussa.jpg',
          photoCredits: 'Atlas Catalan de 1375, Abraham Cresques • Bibliothèque Nationale de France',
          resume:
              'Mansa Kankou Moussa porte l\'Empire du Mali à son apogée économique, culturel et territorial. Son pèlerinage mémorable à La Mecque en 1324 révèle au monde la richesse colossale du Mali et fait de Tombouctou et Gao les capitales intellectuelles de l\'Afrique.',
          citationHistorique:
              '« Le savoir est la lumière de l\'empire ; les savants sont les gardiens de notre avenir. »\n— Mansa Moussa, 1327',
          keyFacts: [
            HistoricalKeyFact(label: 'Règne', value: '1312 – 1337', icon: Icons.workspace_premium_rounded),
            HistoricalKeyFact(label: 'Pèlerinage historique', value: '1324 (Le Caire & La Mecque)', icon: Icons.stars_rounded),
            HistoricalKeyFact(label: 'Grandes commandes', value: 'Mosquée Djingareyber (1327)', icon: Icons.architecture_rounded),
            HistoricalKeyFact(label: 'Expansion', value: 'De l\'Atlantique au fleuve Niger', icon: Icons.public_rounded),
          ],
          chapters: [
            EditorialStoryChapter(
              title: 'L\'Avènement et la Puissance Territoriale',
              content:
                  'Petit-neveu de Soundiata Keïta, Kankou Moussa accède au trône en 1312 à la suite de la disparition en mer du Mansa Aboubakri II. Sous son autorité, l\'empire s\'étend sur plus de 3 000 kilomètres, reliant les mines d\'or de Bouré et Bambouk aux comptoirs marchands du Sahara, englobant les grandes cités de Tombouctou, Gao, Walata et Oualata.',
            ),
            EditorialStoryChapter(
              title: 'Le Pèlerinage de 1324 et le Rayonnement Mondial',
              content:
                  'En 1324, Mansa Moussa entreprend une traversée légendaire vers La Mecque accompagné d\'une caravane de 60 000 hommes, de dignitaires, de soldats et de 80 dromadaires transportant chacun des centaines de kilos d\'or pur. Sa générosité légendaire lors de son passage au Caire fut telle qu\'elle dévalua le cours mondial de l\'or pendant plus de dix ans, inscrivant à jamais le nom du Mali sur les cartes européennes et arabes.',
            ),
            EditorialStoryChapter(
              title: 'Tombouctou, Cité des 333 Saints et des Universités',
              content:
                  'À son retour, Mansa Moussa invite le célèbre poète et architecte andalou Abou Ishaq es-Sahéli pour concevoir des chefs-d\'œuvre d\'ingénierie en terre crue. Il ordonne la construction de la Mosquée Djingareyber en 1327 et dote l\'Université de Sankoré de financements considérables, attirant juristes, astronomes, médecins et philosophes du monde entier.',
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
          ],
        );

      case 'perso_babemba':
        return const HistoricalFigureDetail(
          id: 'perso_babemba',
          name: 'Babemba Traoré',
          titleHonorifique: 'Roi du Kénédougou & Héros de la Résistance Nationale',
          period: '1855 – 1898',
          regionId: 'sikasso',
          regionName: 'Sikasso',
          tag: 'Héros de la Dignité',
          photoUrl: 'assets/images/culture/personnages/babemba_traore.jpg',
          photoCredits: 'Monument National Babemba Traoré, Sikasso • Fonds Photographique National',
          resume:
              'Souverain du Royaume du Kénédougou de 1893 à 1898, il défendit héroïquement la cité fortifiée de Sikasso contre les assauts des troupes coloniales, préférant le sacrifice suprême à la capitulation.',
          citationHistorique:
              '« Anka sa ni ka malo ! » (Plutôt la mort que la honte !)\n— Devise sacrée de Babemba Traoré, 1er mai 1898',
          keyFacts: [
            HistoricalKeyFact(label: 'Règne', value: '1893 – 1898', icon: Icons.shield_rounded),
            HistoricalKeyFact(label: 'Forteresse', value: 'Tata de Sikasso (9 km de remparts)', icon: Icons.castle_rounded),
            HistoricalKeyFact(label: 'Symbole', value: 'Dignité et souveraineté patriotique', icon: Icons.military_tech_rounded),
            HistoricalKeyFact(label: 'Royaume', value: 'Kénédougou', icon: Icons.flag_rounded),
          ],
          chapters: [
            EditorialStoryChapter(
              title: 'L\'Héritage des Traoré et le Kénédougou',
              content:
                  'Succédant à son frère aîné Tiéba Traoré en 1893, Babemba prend les rênes d\'un royaume prospère et redoutable dont la capitale est Sikasso. Fin stratège et organisateur hors pair, il renforce les fortifications et l\'armée pour préserver l\'autonomie et la culture de son peuple.',
            ),
            EditorialStoryChapter(
              title: 'L\'Inexpugnable Tata de Sikasso',
              content:
                  'Sous son règne, le Tata de Sikasso — une colossale muraille en terre de 9 km de circonférence, haute de 6 mètres et large de plusieurs mètres — devient un chef-d\'œuvre d\'ingénierie militaire défensive.',
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
          ],
        );

      case 'perso_askia_mohammed':
        return const HistoricalFigureDetail(
          id: 'perso_askia_mohammed',
          name: 'Askia Mohammed',
          titleHonorifique: 'Askia le Grand & Réformateur de l\'Empire Songhoï',
          period: '1443 – 1538',
          regionId: 'gao',
          regionName: 'Gao',
          tag: 'Grand Réformateur',
          photoUrl: 'assets/images/culture/personnages/askia_mohammed.jpg',
          photoCredits: 'Complexe Monumental des Askia, Gao • Cliché Patrimoine National',
          resume:
              'Fondateur de la dynastie des Askia en 1493, il transforme l\'Empire Songhoï en un État centralisé moderne, doté d\'une armée de métier, d\'une justice équitable et d\'un réseau d\'universités florissant de Gao à Tombouctou.',
          citationHistorique:
              '« La justice et l\'organisation sont les piliers sur lesquels reposent la prospérité des nations. »\n— Askia Mohammed, Gao',
          keyFacts: [
            HistoricalKeyFact(label: 'Règne', value: '1493 – 1528', icon: Icons.workspace_premium_rounded),
            HistoricalKeyFact(label: 'Capitale', value: 'Gao', icon: Icons.location_city_rounded),
            HistoricalKeyFact(label: 'Sépulture', value: 'Tombeau pyramidal des Askia (UNESCO)', icon: Icons.architecture_rounded),
            HistoricalKeyFact(label: 'Empire', value: 'Songhoï', icon: Icons.public_rounded),
          ],
          chapters: [
            EditorialStoryChapter(
              title: 'L\'Avènement de la Dynastie des Askia (1493)',
              content:
                  'Général d\'élite et homme d\'État visionnaire sous Sonni Ali Ber, Mohammed Touré prend le pouvoir en 1493 après la bataille d\'Anfao. Il adopte le titre d\'Askia et instaure un modèle d\'administration territoriale exemplaire.',
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
          ],
        );

      case 'perso_biton_coulibaly':
        return const HistoricalFigureDetail(
          id: 'perso_biton_coulibaly',
          name: 'Biton Coulibaly',
          titleHonorifique: 'Fondateur du Royaume Bambara de Ségou',
          period: '1689 – 1755',
          regionId: 'segou',
          regionName: 'Ségou',
          tag: 'Bâtisseur de Ségou',
          photoUrl: 'assets/images/culture/personnages/biton_coulibaly.jpg',
          photoCredits: 'Mausolée Royal de Biton Coulibaly, Ségou-Koro • Cliché Photographique',
          resume:
              'Génie militaire et politique, Mamari "Biton" Coulibaly transforme l\'association fraternelle de jeunesse (Tôn) en une redoutable armée permanente (Tônjons) et fonde le puissant Royaume Bambara de Ségou.',
          citationHistorique:
              '« La force d\'un royaume réside dans la discipline de ses guerriers et l\'unité de son peuple. »\n— Récits des Griots de Ségou',
          keyFacts: [
            HistoricalKeyFact(label: 'Règne', value: '1712 – 1755', icon: Icons.workspace_premium_rounded),
            HistoricalKeyFact(label: 'Capitale', value: 'Ségou-Koro', icon: Icons.location_city_rounded),
            HistoricalKeyFact(label: 'Institution', value: 'Les Tônjons (Guerriers d\'élite)', icon: Icons.shield_rounded),
            HistoricalKeyFact(label: 'Royaume', value: 'Royaume Bambara de Ségou', icon: Icons.flag_rounded),
          ],
          chapters: [
            EditorialStoryChapter(
              title: 'De chef du Tôn à Roi de Ségou',
              content:
                  'Mamari Coulibaly se distingue dès sa jeunesse par son sens de l\'organisation et sa générosité. Élu chef du Tôn, il prend le titre de "Biton" et transforme cette structure en une communauté militaire solidaire et disciplinée.',
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
        );

      case 'perso_modibo_keita':
        return const HistoricalFigureDetail(
          id: 'perso_modibo_keita',
          name: 'Modibo Keïta',
          titleHonorifique: 'Père de l\'Indépendance & 1er Président de la République du Mali',
          period: '1915 – 1977',
          regionId: 'bamako',
          regionName: 'Bamako',
          tag: 'Père de la Nation',
          photoUrl: 'assets/images/culture/personnages/modibo_keita.jpg',
          photoCredits: 'Photographie Officielle d\'Archives Nationales du Mali, 1961',
          resume:
              'Figure majeure du panafricanisme et artisan de l\'indépendance proclamée le 22 septembre 1960, Modibo Keïta a forgé les institutions et l\'identité de la République moderne du Mali.',
          citationHistorique:
              '« Le Mali est une nation de bâtisseurs. Notre liberté s\'enracine dans la grandeur de nos ancêtres. »\n— Modibo Keïta, 22 septembre 1960',
          keyFacts: [
            HistoricalKeyFact(label: 'Présidence', value: '1960 – 1968', icon: Icons.flag_rounded),
            HistoricalKeyFact(label: 'Proclamation', value: 'Indépendance du Mali (22 sept. 1960)', icon: Icons.celebration_rounded),
            HistoricalKeyFact(label: 'Mouvement', value: 'Panafricanisme & Non-alignement', icon: Icons.public_rounded),
            HistoricalKeyFact(label: 'Hommage', value: 'Mémorial Modibo Keïta à Bamako', icon: Icons.museum_rounded),
          ],
          chapters: [
            EditorialStoryChapter(
              title: 'L\'Engagement pour la Dignité Africaine',
              content:
                  'Né à Bamako-Coura et descendant de la lignée de Soundiata Keïta, Modibo Keïta excelle comme enseignant avant de s\'engager en politique. Il milite sans relâche pour l\'émancipation des peuples africains.',
            ),
            EditorialStoryChapter(
              title: 'La Naissance de la République du Mali (1960)',
              content:
                  'Le 22 septembre 1960, il proclame solennellement l\'indépendance de la République du Mali devant le peuple rassemblé à Bamako, choisissant délibérément le nom historique de l\'illustre Empire du Mali.',
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
        );

      default:
        return null;
    }
  }

  // ── FICHES DÉTAILLÉES DE LIEUX (OFFLINE FALLBACK) ──────────────────────────
  static PlaceDetail? getInitialPlaceDetail(String id) {
    switch (id) {
      case 'ville_bamako':
        return const PlaceDetail(
          id: 'ville_bamako',
          name: 'Bamako',
          subtitle: 'La Cité des Trois Caïmans & Capitale Vivante',
          regionId: 'bamako',
          regionName: 'Bamako',
          tag: 'Capitale',
          photoUrl: 'assets/images/culture/monuments/monument_independance.jpg',
          photoCredits: 'Photographie du Pont des Martyrs et du fleuve Niger à Bamako',
          fondation: 'Établie au XVIIe siècle par les Niaré',
          resume:
              'Bâtie sur les rives du fleuve Niger au pied des monts mandingues, Bamako est le cœur vibrant de la vie malienne, mêlant traditions séculaires, marchés animés et effervescence contemporaine.',
          identiteCulturelle:
              'Bamako est le carrefour de toutes les cultures maliennes, réputée pour ses tisserands, ses sculpteurs, ses musiciens de renommée mondiale et son fleuve Djoliba.',
          traditionsAndPatrimoine:
              'Abritant le Musée National, le Parc National du Mali, la colline de Koulouba et des dizaines de monuments commémoratifs patriotiques.',
          keyFacts: [
            HistoricalKeyFact(label: 'Symbole', value: 'Les Trois Caïmans sacrés', icon: Icons.pets_rounded),
            HistoricalKeyFact(label: 'Fleuve', value: 'Bordée par le majestueux Niger', icon: Icons.water_rounded),
            HistoricalKeyFact(label: 'Statut', value: 'Capitale de la République', icon: Icons.flag_rounded),
          ],
          chapters: [
            EditorialStoryChapter(
              title: 'Des Trois Caïmans à la Métropole',
              content:
                  'Fondée à l\'origine par Seriba Niaré, Bamako tire son nom de "Bama-kɔ" (la mare aux caïmans). Elle s\'est métamorphosée au XXe siècle pour devenir l\'une des capitales culturelles les plus vivantes du continent.',
            ),
          ],
          connectedItems: [
            ConnectedItemRef(
              id: 'monument_independance_bamako',
              title: 'Monument de l\'Indépendance',
              subtitle: 'Symbole républicain',
              type: ConnectedItemType.monument,
              tag: 'Monument',
              regionName: 'Bamako',
            ),
          ],
        );

      case 'ville_djenne':
        return const PlaceDetail(
          id: 'ville_djenne',
          name: 'Djenné',
          subtitle: 'La Cité Millénaire du Bani & Joyau de l\'Architecture en Terre',
          regionId: 'mopti',
          regionName: 'Mopti',
          tag: 'Cité Classée UNESCO',
          photoUrl: 'assets/images/culture/villes/djenne_ville.jpg',
          photoCredits: 'Ruelle authentique de la cité historique de Djenné • Cliché Réel',
          fondation: 'Fondée vers 250 av. J.-C. (Djenné-Djeno) et érigée au IXe siècle',
          resume:
              'Entourée par les bras du fleuve Bani, Djenné est une île fluviale féerique et l\'une des plus anciennes cités urbaines d\'Afrique subsaharienne. Ses près de 2 000 maisons traditionnelles à étage en terre crue forment un ensemble architectural homogène sans équivalent dans le monde.',
          identiteCulturelle:
              'Djenné est renommée pour sa culture du banco, ses confréries de maîtres maçons (Barey Ton), ses tissus traditionnels teints à l\'indigo et son grand marché hebdomadaire du lundi.',
          traditionsAndPatrimoine:
              'Les façades richement ouvragées des demeures nobles comportent des pilastres décoratifs (sarho) qui témoignent du raffinement séculaire des familles djennenkés.',
          keyFacts: [
            HistoricalKeyFact(label: 'Origine', value: 'Plus de 2 000 ans d\'histoire', icon: Icons.history_rounded),
            HistoricalKeyFact(label: 'Statut', value: 'Ensemble urbain classé UNESCO', icon: Icons.verified_rounded),
            HistoricalKeyFact(label: 'Corporation', value: 'Les Maîtres Maçons Barey Ton', icon: Icons.architecture_rounded),
          ],
          chapters: [
            EditorialStoryChapter(
              title: 'Djenné-Djeno, Berceau Urbain Fluvial',
              content:
                  'Les fouilles archéologiques ont révélé que le site originel de Djenné-Djeno était déjà une métropole marchande florissante bien avant l\'arrivée des routes transsahariennes.',
            ),
          ],
          connectedItems: [
            ConnectedItemRef(
              id: 'monument_mosquee_djenne',
              title: 'Grande Mosquée de Djenné',
              subtitle: 'Le chef-d\'œuvre en banco',
              type: ConnectedItemType.monument,
              tag: 'UNESCO',
              regionName: 'Mopti',
            ),
          ],
        );

      case 'ville_segou_koro':
        return const PlaceDetail(
          id: 'ville_segou_koro',
          name: 'Ségou-Koro',
          subtitle: 'L\'Ancienne Capitale Royale des 4 444 Balanzans',
          regionId: 'segou',
          regionName: 'Ségou',
          tag: 'Cité Royale',
          photoUrl: 'assets/images/culture/villes/segou_koro.jpg',
          photoCredits: 'Bords du fleuve Niger à Ségou • Cliché Photographique',
          fondation: 'Capitale du Royaume Bambara au XVIIIe siècle',
          resume:
              'Situé à 10 kilomètres en amont de Ségou au bord du Djoliba, Ségou-Koro est le village historique où le roi Biton Coulibaly établit la capitale de son royaume en 1712.',
          identiteCulturelle:
              'Terre des artisans potiers et des maîtres tisserands du Bogolan, Ségou-Koro est le gardien des traditions orales et des grands récits épiques des Tônjons.',
          traditionsAndPatrimoine:
              'Le village abrite le tombeau sacré de Biton Coulibaly, la première mosquée construite pour sa mère et les vestiges de la cour royale.',
          keyFacts: [
            HistoricalKeyFact(label: 'Symbole', value: 'L\'arbre sacré : le Balanzan', icon: Icons.park_rounded),
            HistoricalKeyFact(label: 'Fondateur', value: 'Roi Biton Coulibaly (1712)', icon: Icons.person_rounded),
            HistoricalKeyFact(label: 'Artisanat', value: 'Bogolan et poteries séculaires', icon: Icons.palette_rounded),
          ],
          chapters: [
            EditorialStoryChapter(
              title: 'Le Sanctuaire des Rois Bambaras',
              content:
                  'Chaque ruelle en banco de Ségou-Koro respire l\'histoire du XVIIIe siècle. Les anciens conservent avec respect le vestibule royal où se prenaient les décisions fondatrices.',
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
            ),
          ],
        );

      case 'ville_bandiagara':
        return const PlaceDetail(
          id: 'ville_bandiagara',
          name: 'Bandiagara & Falaise Dogon',
          subtitle: 'Les Villages Suspendus du Pays Dogon & la Cosmogonie de Sirius',
          regionId: 'mopti',
          regionName: 'Mopti',
          tag: 'Patrimoine Mondial UNESCO (1989)',
          photoUrl: 'assets/images/culture/villes/bandiagara_falaise.jpg',
          photoCredits: 'Village accroché à la Falaise de Bandiagara • Cliché UNESCO',
          fondation: 'Établissement dogon dès le XIVe siècle',
          resume:
              'S\'étendant sur plus de 150 kilomètres de grès rouge, la Falaise de Bandiagara abrite des dizaines de villages spectaculaires nichés à flanc de roche.',
          identiteCulturelle:
              'Réputé pour ses danses masquées rituelles (Dama), ses greniers sculptés et le Toguna (la maison de la parole des aînés).',
          traditionsAndPatrimoine:
              'L\'astronomie traditionnelle dogon et la cosmogonie transmise par les initiés fascinent les savants du monde entier.',
          keyFacts: [
            HistoricalKeyFact(label: 'Falaise', value: '150 km de grès rouge', icon: Icons.terrain_rounded),
            HistoricalKeyFact(label: 'Architecture', value: 'Toguna & Greniers sculptés', icon: Icons.house_rounded),
            HistoricalKeyFact(label: 'UNESCO', value: 'Double classement Nature & Culture', icon: Icons.verified_rounded),
          ],
          chapters: [
            EditorialStoryChapter(
              title: 'Le Toguna, Sanctuaire de la Démocratie Orale',
              content:
                  'Le Toguna est une bâtisse basse dont la hauteur réduite oblige les hommes à s\'asseoir, empêchant toute dispute violente et favorisant la conciliation.',
            ),
          ],
          connectedItems: [
            ConnectedItemRef(
              id: 'ville_djenne',
              title: 'Djenné',
              subtitle: 'Cité sœur de Mopti',
              type: ConnectedItemType.ville,
              tag: 'UNESCO',
              regionName: 'Mopti',
            ),
          ],
        );

      case 'ville_tombouctou':
        return const PlaceDetail(
          id: 'ville_tombouctou',
          name: 'Tombouctou',
          subtitle: 'La Cité Mystique des 333 Saints & Carrefour Transsaharien',
          regionId: 'tombouctou',
          regionName: 'Tombouctou',
          tag: 'Patrimoine Mondial UNESCO (1988)',
          photoUrl: 'assets/images/culture/villes/tombouctou_ville.jpg',
          photoCredits: 'Ruelle de sable et portes sculptées de Tombouctou',
          fondation: 'Fondée vers 1100 par les pasteurs touaregs',
          resume:
              'Située aux portes du désert du Sahara là où la boucle du Niger s\'approche le plus du nord, Tombouctou est le carrefour mythique des manuscrits et du savoir sahélien.',
          identiteCulturelle:
              'Célèbre pour ses portes en bois clouté, ses trois grandes mosquées médiévales et ses 333 saints protecteurs.',
          traditionsAndPatrimoine:
              'Plus de 700 000 manuscrits anciens préservés couvrant l\'astronomie, le droit, la médecine et les sciences.',
          keyFacts: [
            HistoricalKeyFact(label: 'Surnom', value: 'La Cité des 333 Saints', icon: Icons.auto_stories_rounded),
            HistoricalKeyFact(label: 'Trésor écrit', value: '700 000 Manuscrits de Tombouctou', icon: Icons.menu_book_rounded),
            HistoricalKeyFact(label: 'UNESCO', value: 'Classée depuis 1988', icon: Icons.verified_rounded),
          ],
          chapters: [
            EditorialStoryChapter(
              title: 'L\'Âge d\'Or du Savoir Saharien',
              content:
                  'Au XVIe siècle, Tombouctou comptait plus de 100 000 habitants et constituait le phare universitaire de l\'Afrique de l\'Ouest.',
            ),
          ],
          connectedItems: [
            ConnectedItemRef(
              id: 'monument_djingareyber',
              title: 'Mosquée Djingareyber',
              subtitle: 'Bâtie en 1327',
              type: ConnectedItemType.monument,
              tag: 'UNESCO',
              regionName: 'Tombouctou',
            ),
          ],
        );

      case 'ville_sikasso':
        return const PlaceDetail(
          id: 'ville_sikasso',
          name: 'Sikasso',
          subtitle: 'Le Verger Généreux du Mali & Capitale du Kénédougou',
          regionId: 'sikasso',
          regionName: 'Sikasso',
          tag: 'Cité du Kénédougou',
          photoUrl: 'assets/images/culture/villes/sikasso_ville.jpg',
          photoCredits: 'Paysage verdoyant et collines de Sikasso',
          fondation: 'Fondée au XIXe siècle par Mansa Doula',
          resume:
              'Capitale verdoyante du Royaume du Kénédougou, Sikasso s\'est illustrée par sa résistance héroïque lors du siège de 1898.',
          identiteCulturelle:
              'Carrefour chaleureux célébrant la culture des Sénoufo et des Bambaras à travers ses musiques au balafon et sa gastronomie.',
          traditionsAndPatrimoine:
              'Abritant la butte historique du Mamelon, les vestiges du Tata et les grottes sacrées de Missirikoro.',
          keyFacts: [
            HistoricalKeyFact(label: 'Patrimoine', value: 'Le Mamelon & le Tata de Sikasso', icon: Icons.castle_rounded),
            HistoricalKeyFact(label: 'Culture', value: 'Le Balafon et rythmes Sénoufo', icon: Icons.music_note_rounded),
          ],
          chapters: [
            EditorialStoryChapter(
              title: 'La Colline Sacrée du Mamelon',
              content:
                  'Au cœur de la ville s\'élève le Mamelon, poste d\'observation stratégique aménagé par le roi Tiéba Traoré.',
            ),
          ],
          connectedItems: [
            ConnectedItemRef(
              id: 'monument_tata_sikasso',
              title: 'Le Tata de Sikasso',
              subtitle: 'Muraille héroïque',
              type: ConnectedItemType.monument,
              tag: 'Fortification',
              regionName: 'Sikasso',
            ),
          ],
        );

      case 'ville_gao':
        return const PlaceDetail(
          id: 'ville_gao',
          name: 'Gao',
          subtitle: 'La Cité Impériale des Songhoï & Porte de la Dune Rose',
          regionId: 'gao',
          regionName: 'Gao',
          tag: 'Cité Impériale Songhoï',
          photoUrl: 'assets/images/culture/villes/gao_dune_rose.jpg',
          photoCredits: 'La Dune Rose de Koïma à Gao',
          fondation: 'Mentionnée dès le IXe siècle',
          resume:
              'Ancienne capitale de l\'Empire Songhoï, Gao allie la majesté des paysages dunaires sahariens à la vitalité des peuples riverains.',
          identiteCulturelle:
              'Cœur de la culture Songhoï, renommée pour ses chants au violon monocorde et son artisanat d\'excellence.',
          traditionsAndPatrimoine:
              'Abritant le Tombeau pyramidal des Askia (UNESCO) et le site archéologique de Gao Saney.',
          keyFacts: [
            HistoricalKeyFact(label: 'Histoire', value: 'Capitale Songhoï (1464-1591)', icon: Icons.history_edu_rounded),
            HistoricalKeyFact(label: 'Monument', value: 'Tombeau des Askia (UNESCO)', icon: Icons.museum_rounded),
          ],
          chapters: [
            EditorialStoryChapter(
              title: 'Gao Saney et les Échanges Caravaniers',
              content:
                  'Dès le Xe siècle, Gao était le centre d\'un commerce international d\'une richesse inouïe reliant le Maghreb et le Sahel.',
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
            ),
          ],
        );

      default:
        return null;
    }
  }
}
