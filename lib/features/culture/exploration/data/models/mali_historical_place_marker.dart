import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Catégorie de lieu historique pour le badge et l'icône
enum HistoricalPlaceCategory {
  monument,
  unesco,
  citeRoyale,
  siteNaturel,
  sanctuaire,
}

/// Modèle d'un lieu historique représenté sous forme de point rouge interactif
/// sur la carte culturelle du Mali.
class MaliHistoricalPlaceMarker {
  final String id;
  final String name;
  final String fullName;
  final String subtitle;
  final String regionId;
  final String regionName;
  final Offset normalizedPosition;
  final double latitude;
  final double longitude;
  final HistoricalPlaceCategory category;
  final String tag;
  final String era;
  final String photoUrl;
  final String description;
  final String keyFact;
  final String routePath;
  final String? scannerId;
  final IconData icon;

  const MaliHistoricalPlaceMarker({
    required this.id,
    required this.name,
    required this.fullName,
    required this.subtitle,
    required this.regionId,
    required this.regionName,
    required this.normalizedPosition,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.tag,
    required this.era,
    required this.photoUrl,
    required this.description,
    required this.keyFact,
    required this.routePath,
    this.scannerId,
    this.icon = Icons.account_balance_rounded,
  });

  /// Coordonnées GPS réelles pour FlutterMap
  LatLng get latLng => LatLng(latitude, longitude);

  /// Calcule l'emplacement réel sur l'écran selon la taille de la carte (pour fallback vectoriel)
  Offset getScaledOffset(Size size) {
    final scaleX = size.width / 1000.0;
    final scaleY = size.height / 1000.0;
    return Offset(
      normalizedPosition.dx * scaleX,
      normalizedPosition.dy * scaleY,
    );
  }
}

/// Registre exhaustif des lieux et monuments historiques du Mali
/// avec leurs coordonnées GPS réelles et références culturelles
abstract final class MaliHistoricalPlacesRegistry {
  // ── 1. TOMBOUCTOU ──────────────────────────────────────────────────────────
  static const MaliHistoricalPlaceMarker sankore = MaliHistoricalPlaceMarker(
    id: 'monument_sankore',
    name: 'Univ. de Sankoré',
    fullName: 'Université & Mosquée de Sankoré',
    subtitle: 'Le Phare Universitaire de l\'Afrique Médiévale',
    regionId: 'tombouctou',
    regionName: 'Tombouctou',
    normalizedPosition: Offset(515, 345),
    latitude: 16.7758,
    longitude: -3.0042,
    category: HistoricalPlaceCategory.unesco,
    tag: 'UNESCO',
    era: 'XIVe siècle · Empire du Mali',
    photoUrl: 'assets/images/culture/monuments/mosquee_sankore.jpg',
    description:
        'L\'une des plus prestigieuses universités du monde médiéval. Plus de 25 000 étudiants y étudiaient l\'astronomie, le droit et la médecine.',
    keyFact: '25 000 étudiants & 700 000 manuscrits anciens',
    routePath: '/culture/monument/monument_sankore',
    scannerId: 'monument_sankore',
    icon: Icons.school_rounded,
  );

  static const MaliHistoricalPlaceMarker djingareyber =
      MaliHistoricalPlaceMarker(
    id: 'monument_djingareyber',
    name: 'Mosquée Djingareyber',
    fullName: 'Grande Mosquée Djingareyber',
    subtitle: 'Le Grand Sanctuaire de Mansa Moussa',
    regionId: 'tombouctou',
    regionName: 'Tombouctou',
    normalizedPosition: Offset(548, 385),
    latitude: 16.7711,
    longitude: -3.0094,
    category: HistoricalPlaceCategory.unesco,
    tag: 'UNESCO (1327)',
    era: 'Érigée en 1327 par Abou Ishaq es-Sahéli',
    photoUrl: 'assets/images/culture/monuments/mosquee_djingareyber.jpg',
    description:
        'Plus ancien sanctuaire encore en activité à Tombouctou, érigé sur commande de Mansa Moussa avec son minaret tronconique dominant la cité.',
    keyFact: 'Édifice impérial financé par 200 kg d\'or',
    routePath: '/culture/monument/monument_djingareyber',
    scannerId: 'monument_djingareyber',
    icon: Icons.mosque_rounded,
  );

  static const MaliHistoricalPlaceMarker villeTombouctou =
      MaliHistoricalPlaceMarker(
    id: 'ville_tombouctou',
    name: 'Cité des 333 Saints',
    fullName: 'Tombouctou, la Cité aux 333 Saints',
    subtitle: 'Carrefour Transsaharien & Manuscrits Précieux',
    regionId: 'tombouctou',
    regionName: 'Tombouctou',
    normalizedPosition: Offset(562, 310),
    latitude: 16.7666,
    longitude: -3.0026,
    category: HistoricalPlaceCategory.unesco,
    tag: 'Patrimoine Mondial',
    era: 'Fondée vers 1100 par les Touaregs',
    photoUrl: 'assets/images/culture/villes/tombouctou_ville.jpg',
    description:
        'Cité mystique où caravanes de sel et d\'or convergeaient. Elle abrite les bibliothèques des plus grands savants sahéliens.',
    keyFact: 'Gardienne de 700 000 traités séculaires',
    routePath: '/culture/ville/ville_tombouctou',
    icon: Icons.auto_stories_rounded,
  );

  // ── 2. MOPTI ───────────────────────────────────────────────────────────────
  static const MaliHistoricalPlaceMarker mosqueeDjenne =
      MaliHistoricalPlaceMarker(
    id: 'monument_mosquee_djenne',
    name: 'Mosquée de Djenné',
    fullName: 'Grande Mosquée de Djenné',
    subtitle: 'Le Chef-d\'œuvre Mondial en Terre Crue',
    regionId: 'mopti',
    regionName: 'Mopti',
    normalizedPosition: Offset(495, 535),
    latitude: 13.9056,
    longitude: -4.5550,
    category: HistoricalPlaceCategory.unesco,
    tag: 'UNESCO (1988)',
    era: 'Architecture Soudano-Sahélienne',
    photoUrl: 'assets/images/culture/monuments/mosquee_djenne.jpg',
    description:
        'Le plus grand édifice en terre crue au monde. Chaque année, la fête sacrée du crépissage rassemble toute la ville dans une liesse populaire.',
    keyFact: '100% banco bio-climatique, 3 000 fidèles',
    routePath: '/culture/monument/monument_mosquee_djenne',
    scannerId: 'monument_mosquee_djenne',
    icon: Icons.museum_rounded,
  );

  static const MaliHistoricalPlaceMarker falaiseBandiagara =
      MaliHistoricalPlaceMarker(
    id: 'ville_bandiagara',
    name: 'Falaise de Bandiagara',
    fullName: 'Falaise de Bandiagara & Pays Dogon',
    subtitle: 'Villages Suspendus & Cosmogonie de Sirius',
    regionId: 'mopti',
    regionName: 'Mopti',
    normalizedPosition: Offset(565, 505),
    latitude: 14.3500,
    longitude: -3.6167,
    category: HistoricalPlaceCategory.unesco,
    tag: 'UNESCO Nature & Culture',
    era: 'Peuple Dogon · Établissement XIVe siècle',
    photoUrl: 'assets/images/culture/villes/bandiagara_falaise.jpg',
    description:
        '150 km de grès rouge abritant des villages suspendus extraordinaires, le Toguna de parole et les rituels masqués du Sigui.',
    keyFact: 'Double classement UNESCO & Toguna de justice',
    routePath: '/culture/ville/ville_bandiagara',
    scannerId: 'monument_falaise_bandiagara',
    icon: Icons.terrain_rounded,
  );

  static const MaliHistoricalPlaceMarker komoguelMopti =
      MaliHistoricalPlaceMarker(
    id: 'monument_komoguel',
    name: 'Mosquée de Komoguel',
    fullName: 'Grande Mosquée de Komoguel',
    subtitle: 'Joyau Architectural au Cœur de la Venise Malienne',
    regionId: 'mopti',
    regionName: 'Mopti',
    normalizedPosition: Offset(525, 475),
    latitude: 14.4958,
    longitude: -4.1856,
    category: HistoricalPlaceCategory.monument,
    tag: 'Patrimoine Fluvial',
    era: '1908 · Style Soudanais Fluvial',
    photoUrl: 'assets/images/culture/villes/djenne_ville.jpg',
    description:
        'Située au confluent du fleuve Niger et du Bani, cette mosquée en banco veille sur le port de pêche et les pirogues marchandes.',
    keyFact: 'Confluent du Djoliba et port des pinasses',
    routePath: '/culture/monument/monument_mosquee_djenne',
    icon: Icons.sailing_rounded,
  );

  // ── 3. SIKASSO ─────────────────────────────────────────────────────────────
  static const MaliHistoricalPlaceMarker tataSikasso =
      MaliHistoricalPlaceMarker(
    id: 'monument_tata_sikasso',
    name: 'Le Tata de Sikasso',
    fullName: 'Le Tata de Sikasso & Le Mamelon',
    subtitle: 'La Muraille Héroïque du Kénédougou',
    regionId: 'sikasso',
    regionName: 'Sikasso',
    normalizedPosition: Offset(380, 670),
    latitude: 11.3176,
    longitude: -5.6664,
    category: HistoricalPlaceCategory.monument,
    tag: 'Monument National',
    era: '1877-1890 · Rois Tiéba et Babemba Traoré',
    photoUrl: 'assets/images/culture/monuments/tata_sikasso.jpg',
    description:
        'Colossale forteresse de banco et pierres de 9,5 km de circonférence qui résista aux plus rudes sièges. Berceau de la devise : "Plutôt la mort que la honte !".',
    keyFact: 'Muraille de 9,5 km & colline du Mamelon',
    routePath: '/culture/monument/monument_tata_sikasso',
    scannerId: 'monument_tata_sikasso',
    icon: Icons.castle_rounded,
  );

  static const MaliHistoricalPlaceMarker villeSikasso =
      MaliHistoricalPlaceMarker(
    id: 'ville_sikasso',
    name: 'Cité du Kénédougou',
    fullName: 'Sikasso, Capitale du Kénédougou',
    subtitle: 'Le Verger du Mali & Balafons Sacrés',
    regionId: 'sikasso',
    regionName: 'Sikasso',
    normalizedPosition: Offset(330, 700),
    latitude: 11.3160,
    longitude: -5.6720,
    category: HistoricalPlaceCategory.siteNaturel,
    tag: 'Cité Royale & Nature',
    era: 'Royaume Sénoufo et Bambara',
    photoUrl: 'assets/images/culture/villes/sikasso_ville.jpg',
    description:
        'Terre féconde aux milles vergers de manguiers, grottes sacrées de Missirikoro et carrefour des grands maîtres du Balafon.',
    keyFact: 'Terroir agricole & grottes mystiques',
    routePath: '/culture/ville/ville_sikasso',
    icon: Icons.eco_rounded,
  );

  // ── 4. GAO ─────────────────────────────────────────────────────────────────
  static const MaliHistoricalPlaceMarker tombeauAskia =
      MaliHistoricalPlaceMarker(
    id: 'monument_tombeau_askia',
    name: 'Tombeau des Askia',
    fullName: 'Tombeau pyramidal des Askia',
    subtitle: 'La Pyramide Sahélienne de l\'Empire Songhoï',
    regionId: 'gao',
    regionName: 'Gao',
    normalizedPosition: Offset(710, 485),
    latitude: 16.2997,
    longitude: -0.0447,
    category: HistoricalPlaceCategory.unesco,
    tag: 'UNESCO (2004)',
    era: 'Édifié en 1495 par l\'Empereur Askia Mohammed',
    photoUrl: 'assets/images/culture/monuments/tombeau_askia.jpg',
    description:
        'Structure pyramidale à degrés en terre crue de 17 mètres hérissée de torons, symbole de l\'apogée de l\'Empire Songhoï.',
    keyFact: 'Pyramide de 17 m en banco et bois d\'acacia',
    routePath: '/culture/monument/monument_tombeau_askia',
    scannerId: 'monument_tombeau_askia',
    icon: Icons.architecture_rounded,
  );

  static const MaliHistoricalPlaceMarker duneRoseKoima =
      MaliHistoricalPlaceMarker(
    id: 'monument_dune_rose_koima',
    name: 'Dune Rose de Koïma',
    fullName: 'La Dune Rose de Koïma (Koyima)',
    subtitle: 'Sentinelle de Sable Rose dominant le Djoliba',
    regionId: 'gao',
    regionName: 'Gao',
    normalizedPosition: Offset(760, 450),
    latitude: 16.2717,
    longitude: -0.0511,
    category: HistoricalPlaceCategory.siteNaturel,
    tag: 'Site Naturel Sacré',
    era: 'Légendes Songhoï ancestrales',
    photoUrl: 'assets/images/culture/villes/gao_dune_rose.jpg',
    description:
        'Dune légendaire qui prend des reflets rose vif au coucher du soleil, offrant un panorama féerique sur la boucle du fleuve Niger.',
    keyFact: 'Belvédère dunaire mythique du fleuve Niger',
    routePath: '/culture/ville/ville_gao',
    scannerId: 'monument_dune_rose_koima',
    icon: Icons.wb_sunny_rounded,
  );

  // ── 5. SÉGOU ───────────────────────────────────────────────────────────────
  static const MaliHistoricalPlaceMarker segouKoro = MaliHistoricalPlaceMarker(
    id: 'ville_segou_koro',
    name: 'Cité de Ségou-Koro',
    fullName: 'Ségou-Koro, Cité Royale de Biton',
    subtitle: 'Capitale des 4 444 Balanzans du Djoliba',
    regionId: 'segou',
    regionName: 'Ségou',
    normalizedPosition: Offset(370, 530),
    latitude: 13.3986,
    longitude: -6.3267,
    category: HistoricalPlaceCategory.citeRoyale,
    tag: 'Cité Royale Bambara',
    era: '1712 · Roi Biton Coulibaly',
    photoUrl: 'assets/images/culture/villes/segou_koro.jpg',
    description:
        'Village originel abritant le tombeau de Biton Coulibaly, la première mosquée royale et les maîtres artisans du Bogolan et de la poterie.',
    keyFact: 'Sanctuaire des Rois et berceau du Bogolan',
    routePath: '/culture/ville/ville_segou_koro',
    scannerId: 'monument_segou_koro',
    icon: Icons.palette_rounded,
  );

  static const MaliHistoricalPlaceMarker balanzansSegou =
      MaliHistoricalPlaceMarker(
    id: 'monument_balanzans',
    name: 'Les 4 444 Balanzans',
    fullName: 'L\'Allée Royale des 4 444 Balanzans',
    subtitle: 'Arbres Tutélaires du Royaume de Ségou',
    regionId: 'segou',
    regionName: 'Ségou',
    normalizedPosition: Offset(325, 515),
    latitude: 13.4317,
    longitude: -6.2157,
    category: HistoricalPlaceCategory.citeRoyale,
    tag: 'Tradition Royale',
    era: 'Royaume Bambara du XVIIIe siècle',
    photoUrl: 'assets/images/culture/villes/segou_koro.jpg',
    description:
        'Légende vivante de Ségou, ces arbres sacrés (Acacia albida) protégeaient les guerriers Tônjons et rythment la vie des berges du fleuve.',
    keyFact: '4 444 arbres protecteurs de la cité',
    routePath: '/culture/ville/ville_segou_koro',
    icon: Icons.park_rounded,
  );

  // ── 6. KAYES ───────────────────────────────────────────────────────────────
  static const MaliHistoricalPlaceMarker fortMedine = MaliHistoricalPlaceMarker(
    id: 'monument_fort_medine',
    name: 'Fort de Médine',
    fullName: 'Fort Historique de Médine',
    subtitle: 'Sentinelle de Pierre sur le Fleuve Sénégal',
    regionId: 'kayes',
    regionName: 'Kayes',
    normalizedPosition: Offset(205, 520),
    latitude: 14.3725,
    longitude: -11.3653,
    category: HistoricalPlaceCategory.monument,
    tag: 'Monument Historique',
    era: 'Construit en 1855 sur les rives du fleuve Sénégal',
    photoUrl: 'assets/images/culture/monuments/fort_medine.jpg',
    description:
        'Forteresse de grès rouge témoin du siège mémorable de 1857 mené par El Hadj Oumar Tall, au pied des chutes du Félou.',
    keyFact: 'Forteresse de 1855 & bastion de pierre',
    routePath: '/culture/monument/monument_fort_medine',
    scannerId: 'monument_fort_medine',
    icon: Icons.shield_rounded,
  );

  static const MaliHistoricalPlaceMarker chutesGouina =
      MaliHistoricalPlaceMarker(
    id: 'monument_chutes_gouina',
    name: 'Chutes de Gouina',
    fullName: 'Chutes de Gouina & Chutes du Félou',
    subtitle: 'Les Chutes du Niagara Maliennes',
    regionId: 'kayes',
    regionName: 'Kayes',
    normalizedPosition: Offset(160, 555),
    latitude: 14.0133,
    longitude: -11.1067,
    category: HistoricalPlaceCategory.siteNaturel,
    tag: 'Merveille Fluviale',
    era: 'Haut-Bassin du Fleuve Sénégal',
    photoUrl: 'assets/images/culture/monuments/fort_medine.jpg',
    description:
        'Spectaculaire cataracte de 16 mètres de haut sur 500 mètres de large, créant un rideau d\'eau rugissant au milieu des formations rocheuses.',
    keyFact: 'Front de 500 m de chutes et rapides sauvages',
    routePath: '/culture/monument/monument_fort_medine',
    scannerId: 'monument_chutes_gouina',
    icon: Icons.water_rounded,
  );

  // ── 7. KOULIKORO / BAMAKO ──────────────────────────────────────────────────
  static const MaliHistoricalPlaceMarker monumentIndependance =
      MaliHistoricalPlaceMarker(
    id: 'monument_independance_bamako',
    name: 'Monument Indépendance',
    fullName: 'Monument de l\'Indépendance du Mali',
    subtitle: 'Symbole Éternel de Souveraineté & Fraternité',
    regionId: 'koulikoro',
    regionName: 'Koulikoro',
    normalizedPosition: Offset(280, 615),
    latitude: 12.6392,
    longitude: -8.0029,
    category: HistoricalPlaceCategory.monument,
    tag: 'Monument National',
    era: '1960 · Hommage aux Pères de l\'Indépendance',
    photoUrl: 'assets/images/culture/personnages/soundiata.jpg',
    description:
        'Édifice majestueux au centre de la capitale symbolisant la marche du peuple malien vers la liberté et l\'unité africaine.',
    keyFact: 'Mémorial national et flamme de la patrie',
    routePath: '/culture/monuments',
    scannerId: 'monument_independance_bamako',
    icon: Icons.flag_rounded,
  );

  static const MaliHistoricalPlaceMarker tourAfrique =
      MaliHistoricalPlaceMarker(
    id: 'monument_tour_afrique_bamako',
    name: 'Tour de l\'Afrique',
    fullName: 'La Tour de l\'Afrique de Bamako',
    subtitle: 'Phare Panafricain & Étoile de Faladié',
    regionId: 'bamako',
    regionName: 'Bamako',
    normalizedPosition: Offset(295, 630),
    latitude: 12.5935,
    longitude: -7.9463,
    category: HistoricalPlaceCategory.monument,
    tag: 'Symbole Panafricain',
    era: '2001 · Baobab de la Fraternité Africaine',
    photoUrl: 'assets/images/culture/villes/djenne_ville.jpg',
    description:
        'Tour monumentale néo-soudanaise de 46 mètres évoquant un baobab surmonté d\'une corbeille sacrée.',
    keyFact: 'Haute de 46m au carrefour de la paix',
    routePath: '/culture/monuments',
    scannerId: 'monument_tour_afrique_bamako',
    icon: Icons.nature_rounded,
  );

  static const MaliHistoricalPlaceMarker monumentPaix =
      MaliHistoricalPlaceMarker(
    id: 'monument_paix_bamako',
    name: 'Monument de la Paix',
    fullName: 'Monument de la Paix d\'Hamdallaye ACI 2000',
    subtitle: 'La Colombe de la Réconciliation',
    regionId: 'bamako',
    regionName: 'Bamako',
    normalizedPosition: Offset(275, 620),
    latitude: 12.6322,
    longitude: -8.0261,
    category: HistoricalPlaceCategory.monument,
    tag: 'Concorde Nationale',
    era: '1996 · Dans la ferveur de la Flamme de la Paix',
    photoUrl: 'assets/images/culture/contes/savane_crepuscule_stage.jpg',
    description:
        'Colombe blanche sculpturale géante prenant son envol au-dessus du globe terrestre.',
    keyFact: 'Symbole du dialogue et de la concorde',
    routePath: '/culture/monuments',
    scannerId: 'monument_paix_bamako',
    icon: Icons.flutter_dash_rounded,
  );

  static const MaliHistoricalPlaceMarker monumentArmeeNoire =
      MaliHistoricalPlaceMarker(
    id: 'monument_armee_noire_bamako',
    name: 'Héros de l\'Armée Noire',
    fullName: 'Monument des Héros de l\'Armée Noire',
    subtitle: 'Mémoire Éternelle des Combattants Africains',
    regionId: 'bamako',
    regionName: 'Bamako',
    normalizedPosition: Offset(282, 610),
    latitude: 12.6514,
    longitude: -7.9982,
    category: HistoricalPlaceCategory.monument,
    tag: 'Mémoire Militaire',
    era: '1924 · Place de la Liberté',
    photoUrl: 'assets/images/culture/personnages/soundiata.jpg',
    description:
        'Statuaire monumentale en bronze honorant le sacrifice suprême des tirailleurs pour la liberté.',
    keyFact: 'Réplique historique du monument de Reims',
    routePath: '/culture/monuments',
    scannerId: 'monument_armee_noire_bamako',
    icon: Icons.groups_rounded,
  );

  static const MaliHistoricalPlaceMarker museeNationalBamako =
      MaliHistoricalPlaceMarker(
    id: 'monument_musee_national_bamako',
    name: 'Musée National du Mali',
    fullName: 'Musée National du Mali à Koulouba',
    subtitle: 'Trésor Millénaire des Civilisations Sahéliennes',
    regionId: 'bamako',
    regionName: 'Bamako',
    normalizedPosition: Offset(280, 605),
    latitude: 12.6597,
    longitude: -7.9989,
    category: HistoricalPlaceCategory.monument,
    tag: 'Patrimoine & Musée',
    era: '1953 · Rénovation Prix Aga Khan 2003',
    photoUrl: 'assets/images/culture/monuments/mosquee_djenne.jpg',
    description:
        'Architecture bioclimatique en grès rouge abritant plus de 10 000 chefs-d\'œuvre archéologiques.',
    keyFact: 'Conserve les textiles Tellem du XIe siècle',
    routePath: '/culture/monuments',
    scannerId: 'monument_musee_national_bamako',
    icon: Icons.museum_rounded,
  );

  static const MaliHistoricalPlaceMarker ciwaraSenou =
      MaliHistoricalPlaceMarker(
    id: 'monument_ciwara_senou_bamako',
    name: 'Masque Ciwara de Sénou',
    fullName: 'Monument de l\'Hospitalité (Ciwara)',
    subtitle: 'L\'Emblème Sacré de l\'Agriculture et de l\'Accueil',
    regionId: 'bamako',
    regionName: 'Bamako',
    normalizedPosition: Offset(305, 640),
    latitude: 12.5517,
    longitude: -7.9548,
    category: HistoricalPlaceCategory.monument,
    tag: 'Hospitalité Malienne',
    era: 'Porte d\'entrée aéroportuaire',
    photoUrl: 'assets/images/culture/villes/djenne_ville.jpg',
    description:
        'Sculpture monumentale d\'antilope Ciwara souhaitant la bienvenue aux voyageurs entrant à Bamako.',
    keyFact: 'Emblème culturel majeur du labeur et de la dignité',
    routePath: '/culture/monuments',
    scannerId: 'monument_ciwara_senou_bamako',
    icon: Icons.pets_rounded,
  );

  static const MaliHistoricalPlaceMarker palaisCultureBamako =
      MaliHistoricalPlaceMarker(
    id: 'monument_palais_culture_bamako',
    name: 'Palais Amadou Hampâté Bâ',
    fullName: 'Palais de la Culture Amadou Hampâté Bâ',
    subtitle: 'L\'Agora des Arts Vivants et du Djoliba',
    regionId: 'bamako',
    regionName: 'Bamako',
    normalizedPosition: Offset(286, 622),
    latitude: 12.6262,
    longitude: -7.9897,
    category: HistoricalPlaceCategory.monument,
    tag: 'Arts & Théâtre',
    era: '1976 · Rive droite du fleuve Niger',
    photoUrl: 'assets/images/culture/villes/segou_koro.jpg',
    description:
        'Grand complexe artistique et amphithéâtre au bord du fleuve Niger nommé d\'après le grand sage malien.',
    keyFact: 'Temple des griots et de la kora malienne',
    routePath: '/culture/monuments',
    scannerId: 'monument_palais_culture_bamako',
    icon: Icons.theater_comedy_rounded,
  );

  static const MaliHistoricalPlaceMarker kamablonKangaba =
      MaliHistoricalPlaceMarker(
    id: 'monument_kamablon_kangaba',
    name: 'Sanctuaire Kamablon',
    fullName: 'Sanctuaire Kamablon de Kangaba',
    subtitle: 'Le Cœur Sacré de la Charte de Kouroukan Fouga',
    regionId: 'koulikoro',
    regionName: 'Koulikoro',
    normalizedPosition: Offset(320, 650),
    latitude: 11.9333,
    longitude: -8.4167,
    category: HistoricalPlaceCategory.sanctuaire,
    tag: 'UNESCO Immatériel',
    era: '1236 · Soundiata Keïta & Empire du Mandé',
    photoUrl: 'assets/images/culture/personnages/soundiata.jpg',
    description:
        'Huttes sacrées rondes où est récité tous les sept ans le mythe originel du Mandé lors de la réfection solennelle du toit de chaume.',
    keyFact: 'Berceau de la première déclaration des droits (1236)',
    routePath: '/culture/personnage/perso_soundiata',
    scannerId: 'monument_kamablon_kangaba',
    icon: Icons.temple_buddhist_rounded,
  );


  // ── 8. KIDAL ───────────────────────────────────────────────────────────────
  static const MaliHistoricalPlaceMarker adrarIfoghas =
      MaliHistoricalPlaceMarker(
    id: 'monument_adrar_ifoghas',
    name: 'Adrar des Ifoghas',
    fullName: 'Massif de l\'Adrar des Ifoghas',
    subtitle: 'Sanctuaire Rupestre & Berceau Saharien',
    regionId: 'kidal',
    regionName: 'Kidal',
    normalizedPosition: Offset(760, 365),
    latitude: 19.1667,
    longitude: 1.0000,
    category: HistoricalPlaceCategory.siteNaturel,
    tag: 'Art Rupestre Saharien',
    era: 'Période Pastorale Préhistorique (-4000)',
    photoUrl: 'assets/images/culture/villes/gao_dune_rose.jpg',
    description:
        'Vaste massif granitique parsemé d\'oueds, d\'oasis secrètes et de gravures rupestres millénaires retraçant la faune disparue du Sahara vert.',
    keyFact: 'Gravures rupestres millénaires & vallées rocheuses',
    routePath: '/culture/monuments',
    scannerId: 'monument_adrar_ifoghas',
    icon: Icons.landscape_rounded,
  );

  static const MaliHistoricalPlaceMarker oasisKidal =
      MaliHistoricalPlaceMarker(
    id: 'ville_kidal',
    name: 'Oasis de Kidal',
    fullName: 'L\'Oasis Saharienne de Kidal',
    subtitle: 'Porte d\'Accueil des Caravanes Kel Tamasheq',
    regionId: 'kidal',
    regionName: 'Kidal',
    normalizedPosition: Offset(805, 410),
    latitude: 18.4411,
    longitude: 1.4078,
    category: HistoricalPlaceCategory.siteNaturel,
    tag: 'Culture Nomade',
    era: 'Traditions Touaregs séculaires',
    photoUrl: 'assets/images/culture/villes/gao_dune_rose.jpg',
    description:
        'Palmeraie désertique et carrefour de la poésie targuie, du thé à la menthe rituel et des tentes en cuir d\'indigo.',
    keyFact: 'Tradition poétique & hospitalité des nomades',
    routePath: '/culture/monuments',
    icon: Icons.night_shelter_rounded,
  );

  /// Liste complète de tous les lieux historiques géoréférencés
  static const List<MaliHistoricalPlaceMarker> all = [
    // Bamako (priorité capitale)
    monumentIndependance,
    tourAfrique,
    monumentPaix,
    monumentArmeeNoire,
    museeNationalBamako,
    ciwaraSenou,
    palaisCultureBamako,
    // Autres régions du Mali
    sankore,
    djingareyber,
    villeTombouctou,
    mosqueeDjenne,
    falaiseBandiagara,
    komoguelMopti,
    tataSikasso,
    villeSikasso,
    tombeauAskia,
    duneRoseKoima,
    segouKoro,
    balanzansSegou,
    fortMedine,
    chutesGouina,
    kamablonKangaba,
    adrarIfoghas,
    oasisKidal,
  ];

  /// Retourne les lieux d'une région donnée
  static List<MaliHistoricalPlaceMarker> forRegion(String regionId) {
    return all.where((m) => m.regionId == regionId).toList();
  }

  /// Recherche un lieu par son identifiant
  static MaliHistoricalPlaceMarker? findById(String id) {
    return all.where((m) => m.id == id).firstOrNull;
  }
}

/// Coordonnées géographiques de cadrage des régions pour FlutterMap
abstract final class MaliRegionCoordinates {
  /// Cadrage national du Mali
  static const LatLng maliCenter = LatLng(17.0, -3.8);
  static const double maliOverviewZoom = 5.2;

  /// Centre d'une région
  static LatLng getRegionCenter(String? regionId) {
    switch (regionId) {
      case 'bamako':
        return const LatLng(12.6392, -8.0029);
      case 'kayes':
        return const LatLng(14.3, -11.3);
      case 'koulikoro':
        return const LatLng(12.6, -8.0);
      case 'sikasso':
        return const LatLng(11.32, -5.67);
      case 'segou':
        return const LatLng(13.43, -6.23);
      case 'mopti':
        return const LatLng(14.35, -4.15);
      case 'tombouctou':
        return const LatLng(16.77, -3.01);
      case 'gao':
        return const LatLng(16.28, -0.04);
      case 'kidal':
        return const LatLng(18.8, 1.2);
      default:
        return maliCenter;
    }
  }

  /// Zoom idéal pour explorer la région
  static double getRegionZoom(String? regionId) {
    switch (regionId) {
      case 'bamako':
        return 12.5;
      case 'tombouctou':
        return 12.0; // Zoom immersif sur les 3 monuments de la ville
      case 'segou':
        return 11.0;
      case 'sikasso':
        return 11.0;
      case 'gao':
        return 10.5;
      case 'koulikoro':
        return 9.8;
      case 'kayes':
        return 9.2;
      case 'mopti':
        return 9.0;
      case 'kidal':
        return 8.0;
      default:
        return maliOverviewZoom;
    }
  }
}
