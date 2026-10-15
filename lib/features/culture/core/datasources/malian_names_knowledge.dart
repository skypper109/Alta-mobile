// ─── AlterniA — Dictionnaire & Généalogie des Noms & Patronymes du Mali ────────
// Base de connaissances des patronymes (Jamu / Djamou) et prénoms traditionnels.
// Fournit pour chaque nom : origine géographique, signification étymologique,
// rôle de clan/caste, totem ancestral (tanan) et cousinage à plaisanterie (senankouya).
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
    final deviseSection = (deviseOuLouange != null && deviseOuLouange!.isNotEmpty)
        ? '\n\nRetiens cette noble louange des griots : $deviseOuLouange'
        : '';

    if (type == 'prenom') {
      return '« Mon enfant, approche et écoute ce que Grand-mère Mah lit dans le chant des flammes sur ton prénom, « $name ».\n\n'
          'Sais-tu ce que signifie réellement porter ce prénom ? $meaning. '
          'Ce n\'est pas un simple mot que l\'on crie dans la cour : dans nos terroirs de $origin, c\'est une bénédiction soufflée à l\'oreille du nouveau-né au septième jour pour guider chacun de ses pas.\n\n'
          'Les anciens racontent que $anecdote. $clanRole.$deviseSection\n\n'
          'Garde toujours la tête haute : un prénom n\'est pas donné par hasard dans notre savane, il est une graine d\'honneur semée en toi. Fais-en un arbre bienveillant dont l\'ombre protègera les autres. »';
    }

    final totemPhrase = (totem.isNotEmpty)
        ? 'Vois-tu ces étincelles qui s\'élèvent vers les étoiles ? C\'est ainsi que doit briller ta conduite. Ton animal totem (*Tanan*) est $totem — non pour te vanter, mais pour te rappeler l\'alliance sacrée avec la nature et la parole donnée.'
        : '';

    final senankouyaPhrase = (senankouya.isNotEmpty)
        ? 'Et si un $senankouya vient te taquiner au bord du fleuve en prétendant être ton maître, souris : c\'est le Senankouya, notre pacte millénaire de paix et de fraternité par le rire.'
        : '';

    return '« Mon enfant, assieds-toi plus près des braises. Laisse Grand-mère Mah te conter la véritable histoire du nom « $name ».\n\n'
        'Vois-tu, beaucoup croient qu\'un nom n\'est qu\'une suite de lettres sur une carte. Mais chez nous, $name signifie $meaning ! '
        'Tes racines plongent au cœur de $origin, là où tes nobles aïeux étaient reconnus comme $clanRole.\n\n'
        'Écoute bien cette histoire que les griots se transmettent depuis la nuit des temps : $anecdote.\n\n'
        '$totemPhrase\n\n'
        '$senankouyaPhrase'
        '$deviseSection\n\n'
        'Porte ton nom avec la fierté tranquille du baobab, car en toi coule la mémoire de mille veillées. »';
  }
}

abstract final class MalianNamesKnowledge {
  static const Map<String, MalianNameInfo> _surnames = {
    'keita': MalianNameInfo(
      name: 'Keïta',
      type: 'nom',
      origin: 'Mandé ancestral (Kangaba, Niani, Kita)',
      meaning: '« Les Héritiers » ou « Ceux qui ont pris possession de la royauté » (*Ké-I-Ta* en Mandingue).',
      clanRole: 'Dynastie impériale fondatrice du Mali (*Mansa*), noblesse guerrière et gardiens de la Charte de Kouroukan Fouga.',
      totem: 'L\'Hippopotame (*Mali*) et le Lion (*Jara*).',
      senankouya: 'Coulibaly, Soumaoro, Diarra, Samaké.',
      anecdote: 'Lignée directe de Soundiata Keïta, le héros au destin prophétisé qui unifia les 12 royaumes du Mandé en 1235 après la bataille de Kirina.',
    ),
    'traore': MalianNameInfo(
      name: 'Traoré',
      type: 'nom',
      origin: 'Mandé et Kénédougou (Sikasso, Bougouni, Kolondiéba)',
      meaning: '« Les Clairvoyants » ou « Nous avons vu la piste » (*An bè tara*), maîtres de la confrérie des chasseurs (*Donson*).',
      clanRole: 'Conquérants, grands stratèges de guerre et fondateurs du fier Royaume du Kénédougou.',
      totem: 'La Panthère (*Wara*) et le Chien de chasse.',
      senankouya: 'Diarra, Coulibaly, Konaté.',
      anecdote: 'Descendants de Tiramakhan Traoré, général intrépide de Soundiata Keïta. Plus tard, Babemba Traoré illustra la devise : « Plutôt la mort que la honte » (*Saya ka fisa malo yé*) face aux troupes coloniales à Sikasso.',
    ),
    'coulibaly': MalianNameInfo(
      name: 'Coulibaly',
      type: 'nom',
      origin: 'Ségou, Kaarta et Bélédougou',
      meaning: '« Sans Pirogue » (*Kouloun-bali*), ceux dont la bravoure et la force permettent de traverser les fleuves sans embarcation.',
      clanRole: 'Fondateurs du puissant Royaume Bambara de Ségou, seigneurs de la terre et bâtisseurs d\'armées (*Tônjon*).',
      totem: 'Le Silure géant (*Mankoro*) et le Crocodile.',
      senankouya: 'Keïta, Samaké, Traoré, Cissé.',
      anecdote: 'Biton Mamary Coulibaly fonda Ségou en unifiant les jeunes chasseurs en une confrérie indomptable qui fit de la cité aux balanzans la maîtresse du Niger.',
    ),
    'diakite': MalianNameInfo(
      name: 'Diakité',
      type: 'nom',
      origin: 'Wassoulou, Macina, Foulassaba et Fouta',
      meaning: '« Les Veilleurs des Pâturages » et nobles cavaliers peuls intégrés à l\'espace mandingue.',
      clanRole: 'Chefs pastoraux, cavaliers réputés et maîtres de la liberté des grands espaces.',
      totem: 'La Vache blanche sans tache et l\'Oiseau migrateur.',
      senankouya: 'Diallo, Sidibé, Sangaré.',
      anecdote: 'Les Diakité du Wassoulou ont allié la fierté pastorale peule à la magie musicale des chasseurs mandingues, donnant naissance au cœur battant du terroir Wassoulou.',
    ),
    'diallo': MalianNameInfo(
      name: 'Diallo',
      type: 'nom',
      origin: 'Macina (Mopti, Ténenkou, Djenné) et Sahel',
      meaning: '« Les Nobles Pasteurs » (*Jallo* en Pulaar), hommes d\'honneur, de parole et de tempérance.',
      clanRole: 'Lignée guerrière et royale de l\'Empire Peul du Macina (Sékou Amadou).',
      totem: 'Le Bélier blanc et l\'eau du Djoliba.',
      senankouya: 'Diakité, Sangaré, Dicko.',
      anecdote: 'Les Diallo incarnent le « Pulaaku », le code d\'honneur peul fondé sur la retenue, la patience, le courage stoïque et la générosité sans faille.',
    ),
    'toure': MalianNameInfo(
      name: 'Touré',
      type: 'nom',
      origin: 'Tombouctou, Gao, San et boucle du Niger',
      meaning: '« Les Bâtisseurs de Cités » et grands dignitaires de l\'Empire Songhoï.',
      clanRole: 'Dynastie des Askia (Askia Mohammed Touré), érudits coraniques, diplomates et grands marchands du commerce transsaharien.',
      totem: 'L\'Éléphant et la Grue couronnée.',
      senankouya: 'Cissé, Haïdara, Sylla.',
      anecdote: 'Sous Askia Mohammed Touré au XVIᵉ siècle, Tombouctou et l\'Université Sankoré devinrent le phare mondial du savoir où les livres se vendaient plus cher que l\'or.',
    ),
    'cisse': MalianNameInfo(
      name: 'Cissé',
      type: 'nom',
      origin: 'Ancien Empire du Ghana / Wagadou (Koumbi Saleh, Nara)',
      meaning: '« Les Premiers Cavaliers » (*Si-ssé*), première dynastie impériale d\'Afrique de l\'Ouest.',
      clanRole: 'Empereurs fondateurs du Wagadou (*Kaya Magan Cissé*), marabouts prestigieux et gardiens des pactes ancestraux.',
      totem: 'Le Cheval et le serpent mythique Wagadou Bida.',
      senankouya: 'Touré, Traoré, Sylla.',
      anecdote: 'Les Cissé régnaient sur la terre de l\'or où les chevaux s\'abritaient sous des tentures de soie, ouvrant la voie à la grandeur de toutes les civilisations sahéliennes.',
    ),
    'diarra': MalianNameInfo(
      name: 'Diarra',
      type: 'nom',
      origin: 'Ségou, Bélédougou et pays Bambara',
      meaning: '« Le Lion » (*Jara* en Bambara), incarnation de la force majestueuse et de l\'intrépidité.',
      clanRole: 'Dynastie régnante de Ségou (Ngolo Diarra, Monzon Diarra), maîtres de la savane et souverains indomptés.',
      totem: 'Le Lion (*Jara*).',
      senankouya: 'Traoré, Coulibaly.',
      anecdote: 'Ngolo Diarra, par sa sagesse et sa bravoure, rétablit la paix à Ségou et étendit le royaume jusqu\'à Tombouctou, faisant rugir le lion sur les deux rives du fleuve.',
    ),
    'camara': MalianNameInfo(
      name: 'Camara',
      type: 'nom',
      origin: 'Siby, Mandé montagneux et Tabon',
      meaning: '« Ceux qui tranchent la roche », maîtres forgerons et dompteurs de la montagne.',
      clanRole: 'Rois alliés de Soundiata (Kamandjan Camara), forgerons sacrés et gardiens des secrets telluriques.',
      totem: 'Le Singe ou le Varan des rochers.',
      senankouya: 'Sanogo, Doumbia, Koné.',
      anecdote: 'À Siby, Kamandjan Camara transperça la montagne d\'un coup de sabre pour prouver la victoire future sur Soumaoro Kanté : l\'Arche de Kamandjan se dresse encore aujourd\'hui.',
    ),
    'maiga': MalianNameInfo(
      name: 'Maïga',
      type: 'nom',
      origin: 'Empire Songhoï (Gao, Ansongo, Tombouctou, Bourem)',
      meaning: '« Le Maître / Le Chef Suprême » en langue Songhoï.',
      clanRole: 'Princes, gouverneurs et cavaliers d\'élite de l\'Empire Songhoï.',
      totem: 'L\'Aigle pêcheur et le Cheval bai.',
      senankouya: 'Touré, Soumaré, Cissé.',
      anecdote: 'Les Maïga perpétuent la gloire de Sonni Ali Ber et des guerriers du fleuve qui patrouillaient sur des centaines de pirogues de guerre entre Gao et Djenné.',
    ),
    'sidibe': MalianNameInfo(
      name: 'Sidibé',
      type: 'nom',
      origin: 'Wassoulou (Yanfolila, Bougouni)',
      meaning: '« La Noblesse pastorale et les voix mélodieuses du Wassoulou ».',
      clanRole: 'Cavaliers d\'honneur, conteurs et dépositaires de l\'âme musicale du sud du Mali.',
      totem: 'La Tourterelle et le Zébu.',
      senankouya: 'Diakité, Diallo, Sangaré.',
      anecdote: 'Le terroir Sidibé est le berceau du Kamalen N\'goni et des chansons qui célèbrent la bravoure paysanne et la beauté des femmes peules du Wassoulou.',
    ),
    'sangare': MalianNameInfo(
      name: 'Sangaré',
      type: 'nom',
      origin: 'Wassoulou, Mopti et Mandé sud',
      meaning: '« Les Puissants de la savane », clan lié à la force tranquille de la nature.',
      clanRole: 'Nobles pasteurs et gardiens des troupeaux ancestraux.',
      totem: 'L\'Éléphant et le Serpent d\'eau.',
      senankouya: 'Diakité, Diallo, Samaké.',
      anecdote: 'Partout au Mali, un Sangaré et un Diakité qui se croisent débutent immédiatement les joutes de cousinage à plaisanterie, ciment de la paix nationale.',
    ),
    'samake': MalianNameInfo(
      name: 'Samaké',
      type: 'nom',
      origin: 'Mandé (Ménaka, Kangaba, Ouelessebougou)',
      meaning: '« La Force de l\'Éléphant » (*Sama* = Éléphant en Bambara).',
      clanRole: 'Grands chasseurs et maîtres de la forêt dense.',
      totem: 'L\'Éléphant (*Sama*).',
      senankouya: 'Coulibaly, Diakité.',
      anecdote: 'Les Samaké incarnent la mémoire de la forêt : calmes et inébranlables comme l\'éléphant, mais invincibles quand leur honneur est bravé.',
    ),
    'kouyate': MalianNameInfo(
      name: 'Kouyaté',
      type: 'nom',
      origin: 'Mandé (Kéla, Kangaba)',
      meaning: '« Il y a un secret entre nous » (*Kouya-té*), première lignée sacrée de griots (*Jeli*).',
      clanRole: 'Dépositaires suprêmes de la parole, détenteurs du Balafon sacré Sosso-Bala et conseillers intimes des rois.',
      totem: 'Aucun interdit alimentaire (le verbe purifie tout).',
      senankouya: 'Tous les nobles du Mandé (le griot est le cousin de tout le monde).',
      anecdote: 'Balla Fasséké Kouyaté reçut de Soundiata Keïta le privilège éternel de conter l\'Histoire et de réconcilier les rois en colère par le chant des louanges.',
    ),
    'diabate': MalianNameInfo(
      name: 'Diabaté',
      type: 'nom',
      origin: 'Kita (la capitale des griots), Mandé',
      meaning: '« Rien ne peut nous abattre » (*Djan-bali-té*).',
      clanRole: 'Maîtres virtuoses de la Kora à 21 cordes et de la poésie épique.',
      totem: 'La Parole sacrée et le Bois de Vène.',
      senankouya: 'Sissoko, Kouyaté, N\'Diaye.',
      anecdote: 'À Kita, au pied de la colline sacrée Kita Kourou, les Diabaté font vibrer les cordes de la kora depuis des siècles pour apaiser les cœurs et immortaliser la grandeur du Mali.',
    ),
    'doumbia': MalianNameInfo(
      name: 'Doumbia',
      type: 'nom',
      origin: 'Mandé, Bélédougou et Bougouni',
      meaning: '« Maîtres des Forges et des Mystères souterrains ».',
      clanRole: 'Héritiers du grand Fakoli Doumbia (Koumba Fakoli), grand maître de guerre et forgeron mystique allié de Soundiata.',
      totem: 'L\'Aigle et l\'Enclume.',
      senankouya: 'Camara, Sanogo, Koné.',
      anecdote: 'Fakoli Doumbia portait un bonnet orné de cornes magiques et commandait aux forgerons pour équiper en pointes de flèches l\'armée du Mandé.',
    ),
    'konate': MalianNameInfo(
      name: 'Konaté',
      type: 'nom',
      origin: 'Mandé historique (Toron, Kankan)',
      meaning: '« Ceux qui détiennent le pouvoir premier ».',
      clanRole: 'Ancienne dynastie royale dont est issu Naré Maghann Konaté, père de Soundiata Keïta.',
      totem: 'Le Python d\'eau et le Lion.',
      senankouya: 'Keïta, Traoré.',
      anecdote: 'Avant que Soundiata ne prenne le nom de Keïta, la couronne du Manden reposait sur le front des fiers Konaté.',
    ),
    'dembele': MalianNameInfo(
      name: 'Dembélé',
      type: 'nom',
      origin: 'Pays Sénoufo et Bwa (Koutiala, San, Sikasso)',
      meaning: '« Les Bâtisseurs infatigables de greniers ».',
      clanRole: 'Maîtres de l\'agriculture héroïque et des danses rituelles au balafon sénoufo.',
      totem: 'Le Calao et la Perdrix.',
      senankouya: 'Camara, Traoré, Sanogo.',
      anecdote: 'Les Dembélé ont fait du grenier plein le symbole ultime de la dignité de l\'homme et de la prospérité du village.',
    ),
    'sacko': MalianNameInfo(
      name: 'Sacko',
      type: 'nom',
      origin: 'Khasso et pays Soninké (Kayes, Bafoulabé)',
      meaning: '« Les Cavaliers du Khasso » et gardiens du fleuve Sénégal.',
      clanRole: 'Noblesse soninkée et khassonkée, guerriers d\'honneur.',
      totem: 'Le Cheval et le Poisson blanc.',
      senankouya: 'Niakaté, Cissé, Bathily.',
      anecdote: 'Au confluent du Bafing et du Bakoye à Bafoulabé, les Sacko ont régné avec panache sur les royaumes du Khasso.',
    ),
    'haidara': MalianNameInfo(
      name: 'Haïdara',
      type: 'nom',
      origin: 'Tombouctou, Djenné et Sahel',
      meaning: '« Le Lion de Dieu » (lignée chérifienne).',
      clanRole: 'Gardiens des manuscrits anciens de Tombouctou et érudits de paix.',
      totem: 'L\'Encre sacrée et la Colombe.',
      senankouya: 'Touré, Cissé, Dramé.',
      anecdote: 'Les bibliothèques familiales Haïdara abritent encore des milliers de manuscrits médiévaux sur l\'astronomie, les mathématiques et la tolérance.',
    ),
  };

  static const Map<String, MalianNameInfo> _firstNames = {
    'mamadou': MalianNameInfo(
      name: 'Mamadou',
      type: 'prenom',
      origin: 'Forme mandingue et peule de Muhammad.',
      meaning: '« Celui qui est digne d\'éloges et de respect universel ».',
      clanRole: 'Prénom de sagesse, attribué traditionnellement à l\'aîné des garçons pour qu\'il veille sur ses cadets.',
      totem: '',
      senankouya: '',
      anecdote: 'Au Mali, Mamadou est souvent surnommé Madou ou Baba, symbole d\'affection et de responsabilité familiale.',
    ),
    'modibo': MalianNameInfo(
      name: 'Modibo',
      type: 'prenom',
      origin: 'Tradition peule et soninkée du Macina et de Tombouctou.',
      meaning: '« Le Lettré, le Grand Érudit, le Savant » (*Moodibo* en Pulaar).',
      clanRole: 'Titre d\'honneur donné à celui qui maîtrise les sciences et l\'écriture sacrée.',
      totem: '',
      senankouya: '',
      anecdote: 'Porté par le premier président du Mali indépendant, Modibo Keïta, apôtre du panafricanisme et de la dignité africaine.',
    ),
    'soundiata': MalianNameInfo(
      name: 'Soundiata',
      type: 'prenom',
      origin: 'Mandé ancestral (contraction de Sogolon-Djata).',
      meaning: '« Le Lion de Sogolon » (*Sogolon-Jata*).',
      clanRole: 'Prénom impérial de bravoure surmontant tous les obstacles du destin.',
      totem: '',
      senankouya: '',
      anecdote: 'Né infirme, il marcha à l\'aide d\'un bâton de fer pour venger l\'honneur de sa mère et bâtit le plus grand empire d\'Afrique de l\'Ouest.',
    ),
    'fatoumata': MalianNameInfo(
      name: 'Fatoumata',
      type: 'prenom',
      origin: 'Racine islamique et sahélienne, très populaire au Mandé.',
      meaning: '« Celle qui protège, sèvre et nourrit l\'âme » (surnommée Fanta, Fatou ou Tehou).',
      clanRole: 'Prénom de reine-mère, pilier de concorde et de bénédiction dans la cour familiale.',
      totem: '',
      senankouya: '',
      anecdote: 'Au Mali, une Fatoumata est respectée comme une mère de famille dont la bénédiction apporte la prospérité.',
    ),
    'aminata': MalianNameInfo(
      name: 'Aminata',
      type: 'prenom',
      origin: 'Sahara et Sahel (surnommée Ami ou Amita).',
      meaning: '« La femme digne de confiance, fidèle et sereine ».',
      clanRole: 'Prénom de pureté de cœur et de loyauté indéfectible.',
      totem: '',
      senankouya: '',
      anecdote: 'Porté par Aminata Traoré, grande voix de la culture et de l\'artisanat malien.',
    ),
    'sekou': MalianNameInfo(
      name: 'Sékou',
      type: 'prenom',
      origin: 'Forme mandingue et peule de Cheick / Sheikh.',
      meaning: '« Le Guide spirituel, le Patriarche, le Sage vénéré ».',
      clanRole: 'Désigne l\'autorité morale et l\'écoute bienveillante.',
      totem: '',
      senankouya: '',
      anecdote: 'Attribué souvent en hommage aux grands érudits comme Sékou Amadou, fondateur de l\'Empire théocratique du Macina.',
    ),
    'tenin': MalianNameInfo(
      name: 'Tênin',
      type: 'prenom',
      origin: 'Tradition mandingue et bambara des jours de naissance.',
      meaning: '« Enfant née un lundi » (*Tênin-don*), jour béni des marchés et de l\'abondance.',
      clanRole: 'Symbole de fertilité, de renouveau et de douceur de vivre.',
      totem: '',
      senankouya: '',
      anecdote: 'Chez les Bambaras, les enfants nés le lundi (*Tênin*) apportent la prospérité marchande et le sourire dans la concession.',
    ),
    'kankou': MalianNameInfo(
      name: 'Kankou',
      type: 'prenom',
      origin: 'Royauté du Mandé.',
      meaning: '« La noble souveraine » (hommage à la mère de Mansa Moussa).',
      clanRole: 'Prénom féminin d\'élégance et de haute dignité.',
      totem: '',
      senankouya: '',
      anecdote: 'L\'Empereur Mansa Moussa signait souvent Kankou Moussa pour honorer sa prestigieuse mère.',
    ),
    'amadou': MalianNameInfo(
      name: 'Amadou',
      type: 'prenom',
      origin: 'Peul, Bambara et Songhoï (forme locale d\'Ahmad).',
      meaning: '« Le plus digne de louanges et le plus humble ».',
      clanRole: 'Prénom d\'homme d\'honneur et de dévouement.',
      totem: '',
      senankouya: '',
      anecdote: 'Amadou Hampâté Bâ grava pour l\'éternité la maxime : « En Afrique, un vieillard qui meurt est une bibliothèque qui brûle ».',
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
    // Si la requête demande généralement son nom ou son prénom sans précision
    if (lower.contains('mon nom') ||
        lower.contains('mon prénom') ||
        lower.contains('mon prenom') ||
        lower.contains('nom de famille') ||
        lower.contains('djamou') ||
        lower.contains('jamu')) {
      return '« I ni ce, mon enfant ! Chaque patronyme au Mali (*Jamu*) est un trésor vivant.\n\n'
          'Dis-moi simplement quel est **ton nom de famille** (ex : *Keïta, Traoré, Coulibaly, Diakité, Diallo, Touré, Cissé, Diarra, Camara, Maïga, Sidibé, Doumbia, Dembélé...*) ou **ton prénom** (ex : *Modibo, Soundiata, Fatoumata, Aminata, Sékou, Tênin...*).\n\n'
          'Je te révèlerai aussitôt son origine sacrée, sa signification, son clan historique, son animal totem (*Tanan*) et ton cousinage à plaisanterie (*Senankouya*) ! »';
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
