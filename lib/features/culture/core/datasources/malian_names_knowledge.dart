// ─── AlterniA — Dictionnaire & Généalogie des Noms & Patronymes du Mali ────────
// Base de connaissances certifiée des patronymes (Jamu / Djamou) et prénoms traditionnels.
// Règle éditoriale : données rigoureusement attestées par la tradition orale et l'histoire.
library;

class MalianNameInfo {
  final String name;
  final String type; // 'nom' ou 'prenom'
  final String origin;
  final String meaning;
  final String clanRole;
  final String totem;
  final String senankouya;
  final String anecdote;
  final String? deviseOuLouange;

  const MalianNameInfo({
    required this.name,
    required this.type,
    required this.origin,
    required this.meaning,
    required this.clanRole,
    required this.totem,
    required this.senankouya,
    required this.anecdote,
    this.deviseOuLouange,
  });

  factory MalianNameInfo.fromJson(Map<String, dynamic> json) {
    return MalianNameInfo(
      name: (json['name'] ?? json['nom'] ?? '') as String,
      type: (json['type'] ?? 'nom') as String,
      origin: (json['origin'] ?? json['ethnieOuRegion'] ?? json['ethnie_ou_region'] ?? '') as String,
      meaning: (json['meaning'] ?? json['signification'] ?? '') as String,
      clanRole: (json['clanRole'] ?? json['clan_role'] ?? '') as String,
      totem: (json['totem'] ?? '') as String,
      senankouya: (json['senankouya'] ?? '') as String,
      anecdote: (json['anecdote'] ?? '') as String,
      deviseOuLouange: (json['deviseOuLouange'] ?? json['devise_ou_louange']) as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'nom': name,
    'type': type,
    'origin': origin,
    'ethnieOuRegion': origin,
    'meaning': meaning,
    'signification': meaning,
    'clanRole': clanRole,
    'clan_role': clanRole,
    'totem': totem,
    'senankouya': senankouya,
    'anecdote': anecdote,
    if (deviseOuLouange != null) 'deviseOuLouange': deviseOuLouange,
  };

  String toNarrativeText() {
    final parts = <String>[];

    if (type == 'prenom') {
      parts.add('« Mon enfant, écoute ce que Grand-mère Mah sait du prénom « $name ».');
      if (meaning.isNotEmpty) parts.add(meaning);
      if (clanRole.isNotEmpty) parts.add(clanRole);
      if (anecdote.isNotEmpty) parts.add('Les anciens racontent ceci : $anecdote');
      parts.add(
          'Chez nous, le prénom est donné lors du baptême, au septième jour après la naissance. Porte-le avec honneur. »');
      return parts.join('\n\n');
    }

    parts.add('« Mon enfant, assieds-toi près des braises. Voici ce que la tradition sait du nom « $name ».');
    if (meaning.isNotEmpty) parts.add(meaning);
    final berceau = origin.isNotEmpty ? 'Berceau : $origin.' : '';
    final role = clanRole.isNotEmpty ? clanRole : '';
    final originAndRole = [berceau, role].where((s) => s.isNotEmpty).join(' ');
    if (originAndRole.isNotEmpty) parts.add(originAndRole);

    if (anecdote.isNotEmpty) {
      parts.add('Écoute ce que racontent les griots : $anecdote');
    }
    if (totem.isNotEmpty) {
      parts.add('Le tana (interdit) associé à ce clan : $totem');
    }
    if (senankouya.isNotEmpty) {
      parts.add('Ton senankun (cousin à plaisanterie) : $senankouya Entre vous, on se taquine, mais jamais on ne se fâche.');
    }
    if (deviseOuLouange != null && deviseOuLouange!.isNotEmpty) {
      parts.add('Les griots disent : $deviseOuLouange');
    }
    parts.add(
        'Chaque lignée garde aussi ses propres récits et ses propres interdits : demande aux anciens de ta famille, ils compléteront ce que je t\'ai dit. »');

    return parts.join('\n\n');
  }
}

abstract final class MalianNamesKnowledge {
  static const String _pactePeulsForgerons =
      'Les forgerons (numu : Kanté, Doumbia, Fané…), selon le grand pacte de cousinage à plaisanterie entre Peuls et forgerons.';
  static const String _pacteForgeronsPeuls =
      'Les Peuls (Diallo, Diakité, Sidibé, Sangaré…), selon le grand pacte de cousinage à plaisanterie entre forgerons et Peuls.';

  static const Map<String, MalianNameInfo> _surnames = {
    'keita': MalianNameInfo(
      name: 'Keïta',
      type: 'nom',
      origin: 'Mandé (Niani, Kangaba, Kita) — Malinké',
      meaning:
          'Selon l\'explication la plus répandue chez les griots, Keïta viendrait de « kè ita » : « prendre l\'héritage », c\'est-à-dire « celui qui a reçu l\'héritage ».',
      clanRole:
          'Lignée royale du Mandé : la dynastie des Mansa de l\'Empire du Mali (Soundiata Keïta, Mansa Moussa).',
      totem: '',
      senankouya: 'Coulibaly (le pacte Keïta–Coulibaly est l\'un des plus connus du Mali).',
      deviseOuLouange: '« Keïta, descendants de Soundiata, le lion du Mandé ! »',
      anecdote:
          'Soundiata Keïta, fils de Naré Maghan Kon Fatta et de Sogolon Kédjou, vainquit Soumaoro Kanté à Kirina (vers 1235) et fonda l\'Empire du Mali ; la tradition lui attribue la Charte de Kouroukan Fouga. Depuis Balla Fasséké, les griots Kouyaté sont les griots attitrés des Keïta.',
    ),
    'traore': MalianNameInfo(
      name: 'Traoré',
      type: 'nom',
      origin: 'Mandé, Kénédougou (Sikasso) et tout l\'espace mandingue',
      meaning:
          'Traoré est la forme francisée de Tarawele. Une étymologie populaire rapportée par les griots y voit « tara wele » (« va l\'appeler »), en souvenir du guerrier qu\'on allait chercher dans les moments de péril ; ce sens reste une tradition, pas une certitude.',
      clanRole:
          'Clan noble guerrier du Mandé, issu selon l\'épopée de Tiramakan Traoré, général de Soundiata. Au XIXe siècle, des Traoré régnèrent sur le royaume du Kénédougou (Sikasso).',
      totem: '',
      senankouya: 'Diarra (le pacte Traoré–Diarra est l\'un des plus célèbres du Mali).',
      deviseOuLouange: '« Tarawele, descendants de Tiramakan ! »',
      anecdote:
          'Après Kirina, Tiramakan Traoré mena la conquête de l\'ouest, jusqu\'au Kaabu. En 1898, à Sikasso, le roi Babemba Traoré préféra la mort à la reddition face aux troupes coloniales ; on lui prête la parole « Plutôt la mort que la honte ».',
    ),
    'coulibaly': MalianNameInfo(
      name: 'Coulibaly',
      type: 'nom',
      origin: 'Ségou, Kaarta et Bélédougou — Bambara',
      meaning: '« Sans pirogue », du bambara « kulun » (pirogue) et « bali » (sans, absence de).',
      clanRole:
          'Fondateurs du royaume bambara de Ségou (Biton Coulibaly, début du XVIIIe siècle) et du royaume du Kaarta (les Massassi).',
      totem: 'Le silure (poisson-chat), qui selon la légende fit traverser le fleuve aux ancêtres du clan.',
      senankouya: 'Keïta.',
      anecdote:
          'La légende raconte que deux frères ancêtres du clan, Niangolo et Baramangolo, poursuivis par leurs ennemis, arrivèrent au bord du Niger sans pirogue. Un silure les fit traverser : d\'où le nom « sans pirogue » et l\'interdit de manger ce poisson. Plus tard, Biton Coulibaly transforma l\'association des jeunes (ton) en armée et fit de Ségou un royaume puissant.',
    ),
    'diakite': MalianNameInfo(
      name: 'Diakité',
      type: 'nom',
      origin: 'Wassoulou, Macina et Mandé — famille d\'origine peule',
      meaning:
          'Nom d\'origine peule porté par des familles intégrées au monde mandingue ; la tradition le rattache au clan peul des Diallo. Son sens littéral n\'est pas établi de façon fiable.',
      clanRole:
          'Avec les Diallo, Sidibé et Sangaré, les Diakité forment dans la tradition du Wassoulou les « quatre frères » peuls.',
      totem: '',
      senankouya: _pactePeulsForgerons,
      anecdote:
          'Au Wassoulou, Peuls et Malinké se sont tant mêlés que les Diakité, Sidibé et Sangaré parlent le malinké ou le bambara tout en revendiquant fièrement leur ascendance peule.',
    ),
    'diallo': MalianNameInfo(
      name: 'Diallo',
      type: 'nom',
      origin: 'Macina, Sahel et toute l\'Afrique de l\'Ouest — Peul',
      meaning:
          'Forme de « Jallo », l\'un des grands clans peuls (Jallube), aux côtés des Bâ, Sow et Barry. Son sens littéral n\'est pas établi de façon fiable.',
      clanRole: 'Clan peul parmi les plus répandus, du Macina au Fouta-Djalon.',
      totem: '',
      senankouya: _pactePeulsForgerons,
      anecdote:
          'Les Diallo, comme tous les Peuls, se réfèrent au pulaaku, le code de conduite peul fondé sur la retenue (semteende), la patience (munyal) et la sagesse (hakkille).',
    ),
    'toure': MalianNameInfo(
      name: 'Touré',
      type: 'nom',
      origin: 'Boucle du Niger (Tombouctou, Gao), pays soninké et mandingue',
      meaning: 'Patronyme d\'origine soninké et mandingue. Son sens littéral n\'est pas établi de façon fiable.',
      clanRole:
          'Nombreuses familles maraboutiques et commerçantes ; la tradition nomme Mohammed Touré le fondateur de la dynastie des Askia.',
      totem: '',
      senankouya: 'Cissé (selon plusieurs traditions).',
      anecdote:
          'Askia Mohammed, appelé Mohammed Touré par la tradition, prit le pouvoir dans l\'Empire songhaï en 1493. Sous son règne, Tombouctou et ses mosquées-universités (Sankoré, Djingareyber) connurent un grand rayonnement intellectuel.',
    ),
    'cisse': MalianNameInfo(
      name: 'Cissé',
      type: 'nom',
      origin: 'Ancien Ghana / Wagadou (Nara, Nioro, Kayes) — Soninké',
      meaning: 'Patronyme soninké lié à l\'ancien royaume du Wagadou. Son sens littéral n\'est pas établi de façon fiable.',
      clanRole:
          'Selon la tradition soninké, les Cissé (Cissé Tounkara) fournissaient les rois du Wagadou, l\'ancien Ghana.',
      totem: '',
      senankouya: 'Touré (selon plusieurs traditions).',
      anecdote:
          'Selon la légende du Wagadou, la prospérité du royaume dépendait du serpent Bida, à qui l\'on offrait chaque année une jeune fille. Quand Mamadi le Taciturne tua le serpent pour sauver sa fiancée Sia Yatabaré, la pluie d\'or cessa, le Wagadou déclina et les Soninké se dispersèrent.',
    ),
    'diarra': MalianNameInfo(
      name: 'Diarra',
      type: 'nom',
      origin: 'Ségou, Kaarta et Bélédougou — Bambara',
      meaning: '« Le lion », du bambara « jara ».',
      clanRole:
          'Dynastie qui régna sur le royaume bambara de Ségou après les Coulibaly, fondée par Ngolo Diarra vers 1766.',
      totem: '',
      senankouya: 'Traoré.',
      deviseOuLouange: '« Diarra, jara : le lion ! »',
      anecdote:
          'Ngolo Diarra, ancien captif de la cour de Biton Coulibaly, prit le pouvoir à Ségou. Son fils Monzon Diarra, puis son petit-fils Da Monzon Diarra, portèrent le royaume à son apogée au tournant du XIXe siècle.',
    ),
    'camara': MalianNameInfo(
      name: 'Camara',
      type: 'nom',
      origin: 'Mandé (Siby, Tabon, Kita) — Malinké',
      meaning: 'Patronyme mandingue parmi les plus anciens. Son sens littéral n\'est pas établi de façon fiable.',
      clanRole:
          'Clan noble du Mandé, réputé pour ses chasseurs ; les Camara de Siby et de Tabon figurent parmi les alliés de Soundiata.',
      totem: '',
      senankouya: '',
      anecdote:
          'Dans l\'épopée, Kamandjan Camara, roi de Siby, rejoint Soundiata contre Soumaoro. Près de Siby, l\'arche de pierre naturelle porte son nom : l\'Arche de Kamandjan.',
    ),
    'maiga': MalianNameInfo(
      name: 'Maïga',
      type: 'nom',
      origin: 'Gao, Bourem, Ansongo, Tombouctou — Songhaï',
      meaning: 'Grand patronyme songhaï. Son sens littéral n\'est pas établi de façon fiable.',
      clanRole: 'Patronyme emblématique du pays songhaï, berceau de l\'Empire de Gao.',
      totem: '',
      senankouya: '',
      anecdote:
          'L\'Empire songhaï, dont Gao était la capitale, domina la boucle du Niger aux XVe et XVIe siècles, sous Sonni Ali Ber puis les Askia.',
    ),
    'sidibe': MalianNameInfo(
      name: 'Sidibé',
      type: 'nom',
      origin: 'Wassoulou (Yanfolila, Bougouni) — famille d\'origine peule',
      meaning:
          'Nom peul du Wassoulou, souvent considéré comme l\'équivalent mandingue du patronyme peul Sow. Son sens littéral n\'est pas établi de façon fiable.',
      clanRole: 'L\'un des « quatre frères » peuls du Wassoulou, avec les Diallo, Diakité et Sangaré.',
      totem: '',
      senankouya: _pactePeulsForgerons,
      anecdote:
          'Le Wassoulou, terre des Sidibé, Diakité et Sangaré, a donné naissance à la musique wassoulou, portée par des chanteuses comme Coumba Sidibé.',
    ),
    'sangare': MalianNameInfo(
      name: 'Sangaré',
      type: 'nom',
      origin: 'Wassoulou, Macina — famille d\'origine peule',
      meaning:
          'Nom peul, souvent rapproché du patronyme Barry ; on le retrouve sous les formes Sankara (Burkina Faso) ou Shagari (Nigeria). Son sens littéral n\'est pas établi de façon fiable.',
      clanRole: 'L\'un des « quatre frères » peuls du Wassoulou, avec les Diallo, Diakité et Sidibé.',
      totem: '',
      senankouya: _pactePeulsForgerons,
      anecdote:
          'Oumou Sangaré, grande voix du Wassoulou, a fait connaître dans le monde entier la musique de cette région.',
    ),
    'samake': MalianNameInfo(
      name: 'Samaké',
      type: 'nom',
      origin: 'Mandé et région de Bamako — Bambara',
      meaning: 'Généralement expliqué par le bambara « sama » (éléphant) et « kɛ » (mâle) : « l\'éléphant mâle ».',
      clanRole: 'Patronyme bambara du Mandé.',
      totem: '',
      senankouya: '',
      anecdote: 'L\'éléphant, que le nom évoque, est dans les contes mandingues le symbole de la force tranquille.',
    ),
    'kouyate': MalianNameInfo(
      name: 'Kouyaté',
      type: 'nom',
      origin: 'Mandé (Niagassola, Kita, Kangaba) — griots malinké',
      meaning:
          'Selon la tradition, le nom signifierait « il y a un secret entre nous », parole liée au lien unissant Balla Fasséké à son roi.',
      clanRole:
          'Première lignée de griots (jeli) du Mandé, descendants de Balla Fasséké, griot de Soundiata ; griots attitrés des Keïta.',
      totem: '',
      senankouya: '',
      anecdote:
          'Balla Fasséké, captif chez Soumaoro Kanté, joua du Sosso-Bala, le balafon sacré du roi du Sosso. Ce balafon est aujourd\'hui gardé par les Kouyaté à Niagassola (Guinée) et inscrit au patrimoine immatériel de l\'UNESCO.',
    ),
    'diabate': MalianNameInfo(
      name: 'Diabaté',
      type: 'nom',
      origin: 'Mandé (Kéla, Kangaba, Kita) — griots malinké',
      meaning: 'Grande lignée de griots. Plusieurs étymologies populaires circulent, mais aucune n\'est établie.',
      clanRole: 'Griots (jeli) : les Diabaté de Kéla récitent l\'histoire du Mandé lors du Kamablon de Kangaba.',
      totem: '',
      senankouya: '',
      anecdote:
          'Tous les sept ans, à Kangaba, on refait le toit de la case sacrée Kamablon ; les griots Diabaté de Kéla y récitent l\'histoire du Mandé. Cette cérémonie est inscrite au patrimoine immatériel de l\'UNESCO (2009). Le joueur de kora Toumani Diabaté est issu de cette tradition.',
    ),
    'doumbia': MalianNameInfo(
      name: 'Doumbia',
      type: 'nom',
      origin: 'Mandé, Bélédougou, Wassoulou — Malinké et Bambara',
      meaning: 'Son sens littéral n\'est pas établi de façon fiable.',
      clanRole:
          'Patronyme souvent associé aux forgerons (numu) ; la tradition rattache des Doumbia à Fakoli, neveu de Soumaoro Kanté devenu général de Soundiata.',
      totem: '',
      senankouya: _pacteForgeronsPeuls,
      anecdote:
          'Selon l\'épopée, Fakoli abandonna son oncle Soumaoro, qui lui avait pris son épouse Kéléya, et rejoignit Soundiata avec ses guerriers.',
    ),
    'konate': MalianNameInfo(
      name: 'Konaté',
      type: 'nom',
      origin: 'Mandé (Niani, Kangaba) — Malinké',
      meaning: 'Son sens littéral n\'est pas établi de façon fiable.',
      clanRole:
          'Lignée royale ancienne du Mandé, étroitement liée aux Keïta : la tradition rattache aux Konaté le père de Soundiata, Naré Maghan Kon Fatta.',
      totem: '',
      senankouya: '',
      anecdote:
          'Les Konaté et les Keïta partagent une même souche dans la tradition : avant de devenir la marque de la dynastie impériale, les ancêtres de Soundiata sont aussi désignés comme Konaté.',
    ),
    'dembele': MalianNameInfo(
      name: 'Dembélé',
      type: 'nom',
      origin: 'Centre et sud du Mali — Bambara, Minianka',
      meaning: 'Son sens littéral n\'est pas établi de façon fiable.',
      clanRole: 'Patronyme répandu chez les Bambara et les Minianka.',
      totem: '',
      senankouya: '',
      anecdote: '',
    ),
    'sacko': MalianNameInfo(
      name: 'Sacko',
      type: 'nom',
      origin: 'Région de Kayes — Soninké et Khassonké',
      meaning: 'Son sens littéral n\'est pas établi de façon fiable.',
      clanRole: 'Patronyme soninké et khassonké de la région de Kayes.',
      totem: '',
      senankouya: '',
      anecdote: '',
    ),
    'haidara': MalianNameInfo(
      name: 'Haïdara',
      type: 'nom',
      origin: 'Tombouctou, Djenné, Gao — familles chérifiennes',
      meaning: 'De l\'arabe « Haydar », « le lion », surnom d\'Ali, gendre du Prophète.',
      clanRole: 'Familles chérifiennes (se réclamant de la descendance du Prophète) et lettrées, gardiennes de bibliothèques de manuscrits.',
      totem: '',
      senankouya: '',
      anecdote:
          'En 2012-2013, Abdel Kader Haïdara organisa l\'évacuation clandestine de centaines de milliers de manuscrits de Tombouctou vers Bamako pour les sauver de la destruction.',
    ),
    'kone': MalianNameInfo(
      name: 'Koné',
      type: 'nom',
      origin: 'Sud du Mali, Côte d\'Ivoire, Burkina Faso — Bambara, Malinké, Sénoufo',
      meaning: 'Son sens littéral n\'est pas établi de façon fiable.',
      clanRole: 'Patronyme très répandu chez les Bambara, les Malinké et les Sénoufo.',
      totem: '',
      senankouya: '',
      anecdote: '',
    ),
    'fofana': MalianNameInfo(
      name: 'Fofana',
      type: 'nom',
      origin: 'Pays soninké et mandingue',
      meaning: 'Son sens littéral n\'est pas établi de façon fiable.',
      clanRole: 'Patronyme soninké et mandingue.',
      totem: '',
      senankouya: '',
      anecdote: '',
    ),
    'bagayoko': MalianNameInfo(
      name: 'Bagayoko',
      type: 'nom',
      origin: 'Mandé, Tombouctou — Bambara et familles lettrées',
      meaning: 'Son sens littéral n\'est pas établi de façon fiable.',
      clanRole: 'Patronyme mandingue, porté aussi par une célèbre lignée de savants de Tombouctou.',
      totem: '',
      senankouya: '',
      anecdote:
          'Au XVIe siècle, le savant Mohammed Bagayogo (1523-1594) enseignait à Tombouctou ; il fut le maître du grand érudit Ahmed Baba.',
    ),
    'sissoko': MalianNameInfo(
      name: 'Sissoko',
      type: 'nom',
      origin: 'Khasso (Kayes), Kita, Mandé — Malinké et Khassonké',
      meaning: 'Son sens littéral n\'est pas établi de façon fiable.',
      clanRole: 'Patronyme porté à la fois par des familles nobles et par des lignées de griots.',
      totem: '',
      senankouya: '',
      anecdote: 'Le joueur de kora Ballaké Sissoko perpétue aujourd\'hui l\'art des griots mandingues.',
    ),
    'guindo': MalianNameInfo(
      name: 'Guindo',
      type: 'nom',
      origin: 'Pays dogon (falaise de Bandiagara, Bankass, Koro)',
      meaning: 'Patronyme dogon. Son sens littéral n\'est pas établi de façon fiable.',
      clanRole: 'L\'un des patronymes dogon les plus répandus, avec Dolo, Togo, Ongoïba ou Kassogué.',
      totem: '',
      senankouya: 'Les Bozo (pacte Dogon–Bozo).',
      anecdote:
          'Dogon et Bozo sont liés par un pacte ancien : ils se doivent assistance, ne peuvent se faire de mal et, selon la tradition, ne se marient pas entre eux.',
    ),
    'thiero': MalianNameInfo(
      name: 'Thiéro',
      type: 'nom',
      origin: 'Région de Mopti et delta intérieur du Niger',
      meaning: 'Son sens et son rattachement ethnique précis ne sont pas documentés de façon fiable.',
      clanRole: 'Patronyme présent dans la région de Mopti.',
      totem: '',
      senankouya: '',
      anecdote: '',
    ),
  };

  static const Map<String, MalianNameInfo> _firstNames = {
    'mamadou': MalianNameInfo(
      name: 'Mamadou',
      type: 'prenom',
      origin: 'Tout le Mali (Bambara, Peuls, Soninké, Songhaï…)',
      meaning: 'Forme ouest-africaine de Muhammad, de l\'arabe : « le loué », « celui qui est digne de louanges ».',
      clanRole: 'Prénom donné en hommage au Prophète de l\'islam ; diminutifs courants : Madou, Mady.',
      totem: '',
      senankouya: '',
      anecdote: '',
    ),
    'fatoumata': MalianNameInfo(
      name: 'Fatoumata',
      type: 'prenom',
      origin: 'Tout le Mali',
      meaning: 'Forme ouest-africaine de Fatima, de l\'arabe : « celle qui sèvre (son enfant) ».',
      clanRole: 'Prénom donné en hommage à Fatima, fille du Prophète ; diminutifs courants : Fatou, Fanta.',
      totem: '',
      senankouya: '',
      anecdote: '',
    ),
    'soundiata': MalianNameInfo(
      name: 'Soundiata',
      type: 'prenom',
      origin: 'Mandé — prénom historique',
      meaning:
          'Contraction de « Sogolon Jara », « le lion de Sogolon », du nom de sa mère et du mot bambara/malinké « jara » (lion).',
      clanRole: 'Prénom du fondateur de l\'Empire du Mali, aussi appelé Mari Djata.',
      totem: '',
      senankouya: '',
      anecdote:
          'Selon l\'épopée, l\'enfant ne pouvait pas marcher et était moqué. Un jour, humilié pour sa mère, il se leva en s\'appuyant sur une barre de fer forgée, puis arracha un jeune baobab pour en offrir les feuilles à Sogolon.',
    ),
    'awa': MalianNameInfo(
      name: 'Awa',
      type: 'prenom',
      origin: 'Tout le Mali',
      meaning:
          'Forme de Hawwa, Ève en arabe, nom généralement compris comme « la vivante », « celle qui donne la vie ».',
      clanRole: 'Prénom donné en hommage à la première femme de la tradition biblique et coranique.',
      totem: '',
      senankouya: '',
      anecdote:
          'Aoua Keïta, sage-femme et militante, fut en 1959 la première femme élue députée au Soudan français, futur Mali.',
    ),
    'modibo': MalianNameInfo(
      name: 'Modibo',
      type: 'prenom',
      origin: 'Tout le Mali (d\'origine peule)',
      meaning: 'Du peul « moodibbo » : « le savant, le lettré » (en sciences islamiques).',
      clanRole: 'Titre d\'érudit devenu prénom.',
      totem: '',
      senankouya: '',
      anecdote: 'Modibo Keïta fut le premier président du Mali indépendant, proclamé le 22 septembre 1960.',
    ),
    'aminata': MalianNameInfo(
      name: 'Aminata',
      type: 'prenom',
      origin: 'Tout le Mali',
      meaning: 'Forme ouest-africaine d\'Amina, de l\'arabe : « digne de confiance, fidèle ».',
      clanRole: 'Prénom donné en hommage à Amina, mère du Prophète.',
      totem: '',
      senankouya: '',
      anecdote: 'L\'essayiste Aminata Dramane Traoré fut ministre de la Culture du Mali de 1997 à 2000.',
    ),
    'sekou': MalianNameInfo(
      name: 'Sékou',
      type: 'prenom',
      origin: 'Tout le Mali',
      meaning: 'Forme mandingue de Cheikh, de l\'arabe : « l\'ancien », « le maître (spirituel) ».',
      clanRole: 'Prénom de respect, lié au savoir religieux.',
      totem: '',
      senankouya: '',
      anecdote:
          'Sékou Amadou (Cheikou Amadou Barry) fonda en 1818 la Diina, l\'État peul du Macina, avec Hamdallaye pour capitale.',
    ),
    'tenin': MalianNameInfo(
      name: 'Tênin',
      type: 'prenom',
      origin: 'Bambara et Malinké',
      meaning: 'Du bambara « tɛnɛn » : « lundi ». Prénom donné à une fille née un lundi.',
      clanRole: 'Fait partie des prénoms liés au jour de naissance.',
      totem: '',
      senankouya: '',
      anecdote: '',
    ),
    'bintou': MalianNameInfo(
      name: 'Bintou',
      type: 'prenom',
      origin: 'Tout le Mali',
      meaning: 'Généralement rattaché à l\'arabe « bint » : « la fille ».',
      clanRole: 'Prénom féminin courant ; variante : Binta.',
      totem: '',
      senankouya: '',
      anecdote: '',
    ),
    'boubacar': MalianNameInfo(
      name: 'Boubacar',
      type: 'prenom',
      origin: 'Tout le Mali',
      meaning: 'Forme ouest-africaine d\'Abou Bakr, de l\'arabe : « le père du jeune chameau ».',
      clanRole:
          'Prénom donné en hommage à Abou Bakr, compagnon du Prophète et premier calife ; formes mandingues : Bakary, Bocar.',
      totem: '',
      senankouya: '',
      anecdote: '',
    ),
    'sogolon': MalianNameInfo(
      name: 'Sogolon',
      type: 'prenom',
      origin: 'Mandé — prénom historique',
      meaning: 'Nom de la mère de Soundiata, Sogolon Kédjou (Sogolon Condé). Son sens littéral n\'est pas établi.',
      clanRole: 'Prénom porté en hommage à la mère du fondateur de l\'Empire du Mali.',
      totem: '',
      senankouya: '',
      anecdote:
          'Selon l\'épopée, deux chasseurs vainquirent la femme-buffle du pays de Dô et reçurent en récompense Sogolon, jeune femme bossue et laide, qu\'ils conduisirent au roi Naré Maghan. Elle devint la mère de Soundiata.',
    ),
    'kadiatou': MalianNameInfo(
      name: 'Kadiatou',
      type: 'prenom',
      origin: 'Tout le Mali',
      meaning: 'Forme ouest-africaine de Khadija, de l\'arabe : « née avant terme », « la prématurée ».',
      clanRole: 'Prénom donné en hommage à Khadija, première épouse du Prophète ; diminutifs : Kadia, Kadidia.',
      totem: '',
      senankouya: '',
      anecdote: '',
    ),
  };

  /// Recherche l'objet MalianNameInfo complet si la requête mentionne un nom de famille ou un prénom malien
  static MalianNameInfo? findNameInfo(String query) {
    final lower = query.toLowerCase();

    for (final entry in _surnames.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }

    for (final entry in _firstNames.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Recherche une explication détaillée si la requête mentionne un nom de famille ou un prénom malien
  static String? findExplanation(String query) {
    final info = findNameInfo(query);
    if (info != null) {
      return info.toNarrativeText();
    }

    final lower = query.toLowerCase();
    if (lower.contains('mon nom') ||
        lower.contains('mon prénom') ||
        lower.contains('mon prenom') ||
        lower.contains('nom de famille') ||
        lower.contains('djamou') ||
        lower.contains('jamu')) {
      return '« I ni ce, mon enfant ! Chaque patronyme au Mali (*Jamu*) porte l\'histoire de nos terroirs.\n\n'
          'Dis-moi simplement quel est **ton nom de famille** (ex : *Keïta, Traoré, Coulibaly, Diakité, Diallo, Touré, Cissé, Diarra, Camara, Maïga, Sidibé, Doumbia, Dembélé, Guindo...*) ou **ton prénom** (ex : *Mamadou, Fatoumata, Soundiata, Modibo, Aminata, Sékou, Tênin...*).\n\n'
          'Je te dirai ce que la tradition rapporte de son origine, de son berceau et de ses liens d\'alliance (*Senankouya*) ! »';
    }

    return null;
  }

  /// Liste complète des patronymes et prénoms disponibles localement en repli hors-ligne
  static List<MalianNameInfo> get allNames => [
        ..._surnames.values,
        ..._firstNames.values,
      ];

  /// Liste des patronymes maliens de référence
  static List<MalianNameInfo> get surnames => _surnames.values.toList();

  /// Liste des prénoms maliens de référence
  static List<MalianNameInfo> get firstNames => _firstNames.values.toList();
}
