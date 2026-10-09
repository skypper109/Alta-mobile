import 'package:flutter/material.dart';
import '../models/culture_detail_models.dart';

/// Pilier d'ingénierie et secret architectural d'un monument historique
class MonumentArchitecturePillar {
  final String number;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const MonumentArchitecturePillar({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });
}

/// Étape chronologique ou rituelle d'une fête / célébration patrimoniale
class MonumentRitualStepData {
  final String time;
  final String title;
  final String content;
  final IconData icon;

  const MonumentRitualStepData({
    required this.time,
    required this.title,
    required this.content,
    required this.icon,
  });
}

/// Données vivantes de la tradition, célébration ou rituel unique d'un monument
class MonumentTraditionData {
  final String tabLabel;
  final IconData tabIcon;
  final String badge;
  final String title;
  final String photoAsset;
  final String description;
  final String audioListenTitle;
  final String audioContentId;
  final String audioSpeechText;
  final String chronologyTitle;
  final String chronologySubtitle;
  final List<MonumentRitualStepData> steps;

  const MonumentTraditionData({
    required this.tabLabel,
    required this.tabIcon,
    required this.badge,
    required this.title,
    required this.photoAsset,
    required this.description,
    required this.audioListenTitle,
    required this.audioContentId,
    required this.audioSpeechText,
    required this.chronologyTitle,
    required this.chronologySubtitle,
    required this.steps,
  });
}

/// Événement jalon de la frise chronologique historique d'un monument
class MonumentTimelineEvent {
  final String year;
  final String title;
  final String content;
  final bool isFirst;
  final bool isLast;

  const MonumentTimelineEvent({
    required this.year,
    required this.title,
    required this.content,
    this.isFirst = false,
    this.isLast = false,
  });
}

/// Registre fournissant les contenus éditoriaux, architecturaux, rituels et historiques
/// strictement dédiés à chaque monument du Mali (zéro duplication, chacun son histoire).
abstract final class MonumentBespokeContentRegistry {
  // ══════════════════════════════════════════════════════════════════════════
  // 1. TITRE DE LA SECTION ARCHITECTURE
  // ══════════════════════════════════════════════════════════════════════════
  static String getArchitectureSectionTitle(MonumentDetail monument) {
    final id = monument.id.toLowerCase();
    if (id.contains('djenne')) {
      return 'Les 4 Piliers de l\'Ingénierie de Djenné';
    } else if (id.contains('askia')) {
      return 'Les 4 Piliers de la Pyramide de Gao';
    } else if (id.contains('sikasso')) {
      return 'Les 4 Piliers Défensifs du Tata';
    } else if (id.contains('sankore')) {
      return 'Les 4 Piliers de l\'Architecture du Savoir';
    } else if (id.contains('djingareyber')) {
      return 'Les 4 Piliers du Sanctuaire d\'Es-Sahéli';
    } else if (id.contains('independance')) {
      return 'Les 4 Repères du Symbole Républicain';
    } else if (id.contains('tour_afrique')) {
      return 'Les 4 Piliers du Phare Panafricain';
    } else if (id.contains('medine')) {
      return 'Les 4 Piliers de la Sentinelle du Fleuve';
    }
    return 'Les Piliers Bâtisseurs & Secrets d\'Édification';
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2. PILIERS ARCHITECTURAUX DÉDIÉS
  // ══════════════════════════════════════════════════════════════════════════
  static List<MonumentArchitecturePillar> getPillars(MonumentDetail monument) {
    final id = monument.id.toLowerCase();

    // ── DJENNÉ ─────────────────────────────────────────────────────────────
    if (id.contains('djenne')) {
      return const [
        MonumentArchitecturePillar(
          number: '01',
          title: 'Le Banco Alchimique (Terre Crue)',
          subtitle: 'Une composition vivante et imperméable',
          description:
              'Mélange d\'argile limoneuse extraite des berges du Bani, de balle de riz, de beurre de karité et de baobab. Cette alchimie ancestrale crée une matière isolante qui respire, gardant l\'intérieur à 22°C même sous 45°C.',
          icon: Icons.layers_rounded,
        ),
        MonumentArchitecturePillar(
          number: '02',
          title: 'Les Torons en Bois de Rônier',
          subtitle: 'L\'échafaudage permanent et le squelette anti-séisme',
          description:
              'Poutres de palmier rônier imputrescibles et inattaquables par les termites. Elles percent les murailles pour servir d\'appuis aux maçons Barey Ton lors du crépissage et absorbent les contraintes mécaniques.',
          icon: Icons.carpenter_rounded,
        ),
        MonumentArchitecturePillar(
          number: '03',
          title: 'Les 104 Lucarnes Zénithales du Toit',
          subtitle: 'Climatisation naturelle et gestion thermique',
          description:
              'Le toit-terrasse est percé de 104 orifices fermés par des couvercles en terre cuite. En saison chaude, les fidèles ôtent les chapeaux pour créer un tirage d\'air ascendant. En hivernage, ils sont scellés contre les pluies.',
          icon: Icons.wb_sunny_rounded,
        ),
        MonumentArchitecturePillar(
          number: '04',
          title: 'Les Minarets & Œufs d\'Autruche Sacrés',
          subtitle: 'Symbolisme spirituel et protection céleste',
          description:
              'Chaque minaret est couronné d\'un cône d\'argile coiffé d\'un œuf d\'autruche véritable, symbole universel de pureté, de fertilité et de protection divine dans les cosmogonies sahéliennes.',
          icon: Icons.egg_rounded,
        ),
      ];
    }

    // ── TOMBEAU DES ASKIA (GAO) ─────────────────────────────────────────────
    if (id.contains('askia')) {
      return const [
        MonumentArchitecturePillar(
          number: '01',
          title: 'La Pyramide Sahélienne à Degrés',
          subtitle: 'Un modèle funéraire inspiré d\'Égypte',
          description:
              'Élevée à 17 mètres de hauteur, cette pyramide tronconique en gradins témoigne de la volonté d\'Askia Mohammed de réconcilier la tradition monumentale pharaonique et l\'art constructif songhoï en terre battue.',
          icon: Icons.change_history_rounded,
        ),
        MonumentArchitecturePillar(
          number: '02',
          title: 'Les Madriers d\'Acacia Blanc Saillants',
          subtitle: 'Résistance extrême aux vents de sable sahariens',
          description:
              'Des dizaines de madriers en bois d\'acacia épineux hérissent les quatre faces. Ce bois dense résiste à la sécheresse absolue et permet l\'ascension annuelle des artisans pour entretenir l\'enduit protecteur.',
          icon: Icons.forest_rounded,
        ),
        MonumentArchitecturePillar(
          number: '03',
          title: 'Les Deux Mosquées à Toit Plat',
          subtitle: 'Sobriété et recueillement impérial',
          description:
              'Le complexe intègre deux sanctuaires à toiture plane supportés par d\'épaisses colonnes de terre crue, conçus pour abriter les prières communautaires des dignitaires et des pèlerins du Sahara.',
          icon: Icons.mosque_rounded,
        ),
        MonumentArchitecturePillar(
          number: '04',
          title: 'L\'Enceinte & La Nécropole Impériale',
          subtitle: 'Cour sacrée de sépulture dynastique',
          description:
              'Une muraille protectrice entoure la nécropole où reposent les descendants de la dynastie des Askia, créant un espace de piété préservé des tempêtes sahariennes et de l\'érosion éolienne.',
          icon: Icons.shield_rounded,
        ),
      ];
    }

    // ── TATA DE SIKASSO ────────────────────────────────────────────────────
    if (id.contains('sikasso')) {
      return const [
        MonumentArchitecturePillar(
          number: '01',
          title: 'L\'Enceinte Colossale de 9,5 km',
          subtitle: 'Une ceinture défensive imprenable',
          description:
              'Muraille continue de plus de neuf kilomètres ceinturant toute la ville, construite en banco compacté et atteignant jusqu\'à 6 mètres de hauteur pour 3 mètres d\'épaisseur à sa base.',
          icon: Icons.security_rounded,
        ),
        MonumentArchitecturePillar(
          number: '02',
          title: 'Bastions de Latérite & Pierres Rouges',
          subtitle: 'Matériaux locaux capables de défier le canon',
          description:
              'Les bâtisseurs du Kénédougou ont combiné la terre argileuse avec des blocs massifs de latérite et des concrétions ferrugineuses, offrant une résistance exceptionnelle aux tirs d\'artillerie de l\'époque.',
          icon: Icons.terrain_rounded,
        ),
        MonumentArchitecturePillar(
          number: '03',
          title: 'Les Cinq Grandes Portes Fortifiées',
          subtitle: 'Contrôle douanier et verrous stratégiques',
          description:
              'Chaque porte d\'accès était un bastion fortifié équipé de chicanes, de sas de surveillance et de portes massives en bois de vène renforcées de ferrures, gardées nuit et jour par les guerriers sofa.',
          icon: Icons.sensor_door_rounded,
        ),
        MonumentArchitecturePillar(
          number: '04',
          title: 'Le Piton Stratégique du Mamelon',
          subtitle: 'Poste de guet panoramique à 360°',
          description:
              'La colline naturelle du Mamelon au centre de Sikasso servait de poste de commandement aux rois Tiéba et Babemba, permettant de repérer tout mouvement ennemi à plus de vingt kilomètres à la ronde.',
          icon: Icons.visibility_rounded,
        ),
      ];
    }

    // ── UNIVERSITÉ & MOSQUÉE DE SANKORÉ (TOMBOUCTOU) ─────────────────────────
    if (id.contains('sankore')) {
      return const [
        MonumentArchitecturePillar(
          number: '01',
          title: 'La Cour aux Proportions de la Kaaba',
          subtitle: 'Un tracé géométrique sacré et symbolique',
          description:
              'La cour intérieure de Sankoré a été conçue en reproduisant fidèlement les proportions métriques exactes de la Kaaba de La Mecque, insufflant une sacralité unique aux espaces d\'enseignement.',
          icon: Icons.crop_square_rounded,
        ),
        MonumentArchitecturePillar(
          number: '02',
          title: 'Le Minaret en Gradins de 15 Mètres',
          subtitle: 'L\'icône de la cité des 333 saints',
          description:
              'Tour pyramidale à ressauts en banco et solives de palmier doum, servant à la fois d\'appel à la prière et de repère visuel pour les caravanes arrivant du désert du Sahara.',
          icon: Icons.architecture_rounded,
        ),
        MonumentArchitecturePillar(
          number: '03',
          title: 'Les Alcôves et Niches à Manuscrits',
          subtitle: 'Bibliothèques intégrées à la maçonnerie',
          description:
              'Les parois épaisses intègrent des dizaines de niches en banco appelées "taqas", ventilées naturellement pour préserver les reliures en cuir et les encres végétales de précieux parchemins.',
          icon: Icons.menu_book_rounded,
        ),
        MonumentArchitecturePillar(
          number: '04',
          title: 'Régulation Hygrothermique du Banco',
          subtitle: 'Une climatisation naturelle pour l\'étude',
          description:
              'L\'inertie thermique de la terre crue permettait aux 25 000 étudiants de travailler dans des salles fraîches le jour et tempérées durant les nuits glaciales du désert.',
          icon: Icons.thermostat_rounded,
        ),
      ];
    }

    // ── MOSQUÉE DJINGAREYBER (TOMBOUCTOU) ───────────────────────────────────
    if (id.contains('djingareyber')) {
      return const [
        MonumentArchitecturePillar(
          number: '01',
          title: 'La Voûte Sahélo-Andalouse d\'Es-Sahéli',
          subtitle: 'Rencontre du génie de Grenade et de Tombouctou',
          description:
              'Conçue en 1327 par le maître andalou Abou Ishaq es-Sahéli à la demande de Mansa Moussa, la mosquée introduit pour la première fois en Afrique de l\'Ouest l\'utilisation de la voûte et des arcs en plein cintre.',
          icon: Icons.architecture_rounded,
        ),
        MonumentArchitecturePillar(
          number: '02',
          title: 'Les 25 Rangées de Piliers Massifs',
          subtitle: 'Une forêt de colonnes en calcaire et terre',
          description:
              'Vingt-cinq travées de piliers monumentaux soutiennent le plafond en rondins de palmier doum, créant une acoustique feutrée et une atmosphère propice à la méditation spirituelle.',
          icon: Icons.view_column_rounded,
        ),
        MonumentArchitecturePillar(
          number: '03',
          title: 'Le Minaret Tronconique Imposant',
          subtitle: 'Une silhouette visible depuis les dunes',
          description:
              'Haut de 16 mètres, ce minaret conique orné de torons en bois domine l\'axe commercial menant au port fluvial de Kabara sur le fleuve Niger.',
          icon: Icons.location_city_rounded,
        ),
        MonumentArchitecturePillar(
          number: '04',
          title: 'L\'Enduit d\'Alhor (Calcaire Blanc)',
          subtitle: 'Pierres fossiles mêlées au banco',
          description:
              'Utilisation unique de la pierre calcaire locale "alhor" associée à la terre crue, offrant une robustesse accrue face aux vents de sable desséchants de l\'Harmattan.',
          icon: Icons.landscape_rounded,
        ),
      ];
    }

    // ── MONUMENT DE L'INDÉPENDANCE (BAMAKO) ──────────────────────────────────
    if (id.contains('independance')) {
      return const [
        MonumentArchitecturePillar(
          number: '01',
          title: 'Le Minaret Laïque Pyramidale',
          subtitle: 'Élévation et modernité républicaine',
          description:
              'Flèche élancée en béton armé et marbre blanc qui réinterprète le minaret soudanais sous une forme laïque et épurée, symbole de la liberté et de l\'ascension nationale.',
          icon: Icons.upgrade_rounded,
        ),
        MonumentArchitecturePillar(
          number: '02',
          title: 'Frises Géométriques Mandingues',
          subtitle: 'Les motifs traditionnels gravés dans la pierre',
          description:
              'Les parois de la structure sont sculptées de motifs géométriques mandingues et de losanges inspirés des tissus Bogolan, ancrant la modernité de l\'édifice dans l\'art séculaire malien.',
          icon: Icons.pattern_rounded,
        ),
        MonumentArchitecturePillar(
          number: '03',
          title: 'Le Socle Civique Monumental',
          subtitle: 'Plateforme commémorative du 22 septembre',
          description:
              'Un podium surélevé pavé de granit accueille la flamme de la patrie et les plaques honorant le président Modibo Keïta et les pères de l\'émancipation africaine.',
          icon: Icons.foundation_rounded,
        ),
        MonumentArchitecturePillar(
          number: '04',
          title: 'L\'Axe Triomphal du Boulevard',
          subtitle: 'Perspective urbaine majeure de Bamako',
          description:
              'Le monument s\'inscrit dans une large perspective axiale au cœur du centre-ville, conçu pour accueillir les grands défilés militaires et les rassemblements patriotiques.',
          icon: Icons.alt_route_rounded,
        ),
      ];
    }

    // ── TOUR DE L'AFRIQUE (BAMAKO) ──────────────────────────────────────────
    if (id.contains('tour_afrique')) {
      return const [
        MonumentArchitecturePillar(
          number: '01',
          title: 'La Forme Baobab Cylindrique de 46m',
          subtitle: 'Symbole du baobab protecteur continental',
          description:
              'Cette tour cylindrique monumentale s\'élance à 46 mètres, évoquant le tronc majestueux d\'un baobab protecteur sous lequel les peuples d\'Afrique trouvent refuge et fraternité.',
          icon: Icons.park_rounded,
        ),
        MonumentArchitecturePillar(
          number: '02',
          title: 'Le Flambeau Métallique Sommitale',
          subtitle: 'Lanterne de l\'Unité Africaine',
          description:
              'La tour est couronnée d\'un gigantesque brasier d\'acier forgé figurant la flamme éternelle de la liberté des peuples africains, visible de nuit depuis les deux rives du Niger.',
          icon: Icons.local_fire_department_rounded,
        ),
        MonumentArchitecturePillar(
          number: '03',
          title: 'Bas-Reliefs des Héros Panafricains',
          subtitle: 'Fresques de la mémoire anticoloniale',
          description:
              'Le socle circulaire est orné de bas-reliefs détaillés rendant hommage aux grandes figures de l\'Union : Kwamé Nkrumah, Modibo Keïta, Patrice Lumumba, Sékou Touré et Gamal Abdel Nasser.',
          icon: Icons.groups_rounded,
        ),
        MonumentArchitecturePillar(
          number: '04',
          title: 'Briques de Terre Stabilisée (BTS)',
          subtitle: 'Alliance de haute technologie et de tradition',
          description:
              'Le parement intérieur et extérieur utilise des briques de terre compressée stabilisée, mariant l\'identité de la terre malienne à la résistance du béton armé.',
          icon: Icons.view_in_ar_rounded,
        ),
      ];
    }

    // ── FORT DE MÉDINE (KAYES) ──────────────────────────────────────────────
    if (id.contains('medine')) {
      return const [
        MonumentArchitecturePillar(
          number: '01',
          title: 'Remparts en Pierres de Grès Rouge',
          subtitle: 'Maçonnerie militaire robuste du XIXe siècle',
          description:
              'Murs de soutènement et remparts appareillés en moellons de grès rouge extrait des falaises du Félou, liés par un mortier résistant aux crues violentes du fleuve Sénégal.',
          icon: Icons.castle_rounded,
        ),
        MonumentArchitecturePillar(
          number: '02',
          title: 'Bastions de Tir & Échauguettes',
          subtitle: 'Architecture militaire de surveillance fluviale',
          description:
              'Bastions polygonaux placés aux angles stratégiques, dotés de meurtrières et de créneaux assurant un contrôle total de la navigation sur le fleuve Sénégal.',
          icon: Icons.security_rounded,
        ),
        MonumentArchitecturePillar(
          number: '03',
          title: 'La Poudrière & Magasins Voûtés',
          subtitle: 'Infrastructures défensives préservées',
          description:
              'Casemates voûtées sous terre protégées par d\'épaisses dalles de pierre pour abriter les munitions et réserves de vivres pendant les longs sièges militaires.',
          icon: Icons.inventory_2_rounded,
        ),
        MonumentArchitecturePillar(
          number: '04',
          title: 'Le Belvédère sur les Chutes du Félou',
          subtitle: 'Contrôle du seuil naturel navigable',
          description:
              'Le fort a été bâti au dernier point navigable du fleuve Sénégal avant les impressionnantes chutes du Félou, constituant le verrou stratégique par excellence de la région.',
          icon: Icons.water_drop_rounded,
        ),
      ];
    }

    // ── DÉFAUT DYNAMIQUE ────────────────────────────────────────────────────
    return [
      MonumentArchitecturePillar(
        number: '01',
        title: 'Style & Conception d\'Origine',
        subtitle: monument.era,
        description: monument.architectureAndMaterials,
        icon: Icons.architecture_rounded,
      ),
      MonumentArchitecturePillar(
        number: '02',
        title: 'Matériaux & Génie Constructif',
        subtitle: monument.locationDetails,
        description: monument.presentation,
        icon: Icons.layers_rounded,
      ),
      MonumentArchitecturePillar(
        number: '03',
        title: 'Portée Patrimoniale & Savoir-Faire',
        subtitle: monument.tag,
        description: monument.whyItMatters,
        icon: Icons.verified_rounded,
      ),
    ];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 3. TRADITION / CÉLÉBRATION / RITUEL SPÉCIFIQUE (ONGLET 3)
  // ══════════════════════════════════════════════════════════════════════════
  static MonumentTraditionData getTradition(MonumentDetail monument) {
    final id = monument.id.toLowerCase();

    // ── DJENNÉ : LE CRÉPISSAGE SACRÉ ────────────────────────────────────────
    if (id.contains('djenne')) {
      return const MonumentTraditionData(
        tabLabel: 'Le Crépissage',
        tabIcon: Icons.celebration_rounded,
        badge: 'TRADITION SÉCULAIRE UNIQUE AU MONDE',
        title: 'La Fête Sacrée du Crépissage',
        photoAsset:
            'assets/images/culture/monuments/monument_mosquee_djenne/dje_4.webp',
        description:
            'Chaque année, à la fin de la saison sèche, toute la cité de Djenné s\'unit en une seule matinée de liesse collective pour réenduire entièrement la mosquée d\'une nouvelle couche d\'argile sacrée.',
        audioListenTitle: 'Écouter le récit de la fête du Crépissage',
        audioContentId: 'crepissage_djenne',
        audioSpeechText:
            'La fête sacrée du Crépissage de Djenné. '
            'Chaque année, la veille au crépuscule, des milliers de garçons malaxent le banco dans les fosses du Bani. '
            'À quatre heures du matin, le tambour retentit depuis les minarets. '
            'À l\'aube, une marée humaine s\'élance avec les corbeilles de mortier. '
            'Les jeunes escaladent les torons en bois et réenduient les murailles à mains nues sous le chant des femmes et le regard vigilant des maîtres maçons Barey Ton.',
        chronologyTitle: 'Chronologie de la Journée Sacrée',
        chronologySubtitle:
            'De la veillée du banco aux festivités du couronnement.',
        steps: [
          MonumentRitualStepData(
            time: 'Veille au crépuscule',
            title: 'Le Malaxage Collectif du Banco',
            content:
                'Des centaines de jeunes garçons sautent pieds nus dans les fosses d\'argile le long du fleuve Bani pour pétrir la boue avec la balle de riz et le beurre de karité au rythme des tambours.',
            icon: Icons.waves_rounded,
          ),
          MonumentRitualStepData(
            time: '4h00 du matin',
            title: 'L\'Appel des Tambours de Guerre',
            content:
                'Le tambour sacré résonne du haut des minarets, réveillant toute la cité. Les familles se parent de leurs habits de travail et convergent vers la place du marché dans une ferveur solennelle.',
            icon: Icons.notifications_active_rounded,
          ),
          MonumentRitualStepData(
            time: '5h30 – 7h00',
            title: 'La Ruée vers les Fosses d\'Argile',
            content:
                'Au signal des chefs de quartier, des milliers de porteurs s\'élancent en courant avec des paniers d\'osier remplis d\'argile fraîche vers les façades de la mosquée dans une course d\'émulation fraternelle.',
            icon: Icons.directions_run_rounded,
          ),
          MonumentRitualStepData(
            time: '7h00 – 10h00',
            title: 'L\'Escalade des Torons & L\'Enduit à Mains Nues',
            content:
                'Perchés à 15 mètres de hauteur sur les poutres de palmier, les jeunes maçons étalent l\'argile à mains nues avec une agilité acrobatique. En bas, les femmes apportent l\'eau fraîche du fleuve en entonnant des hymnes guerriers et spirituels.',
            icon: Icons.pan_tool_rounded,
          ),
          MonumentRitualStepData(
            time: 'Midi',
            title: 'L\'Inspection des Maîtres Barey Ton & Le Festin',
            content:
                'Les doyens de la corporation des maçons inspectent chaque pan de mur. La mosquée brille d\'une robe neuve ocre-dorée. La journée se termine par un immense banquet populaire où tous les différends de la cité sont pardonnés.',
            icon: Icons.restaurant_rounded,
          ),
        ],
      );
    }

    // ── TOMBEAU DES ASKIA (GAO) : RITUELS & NÉCROPOLE ───────────────────────
    if (id.contains('askia')) {
      return MonumentTraditionData(
        tabLabel: 'Rituels & Nécropole',
        tabIcon: Icons.change_history_rounded,
        badge: 'CÉRÉMONIE ANCESTRALE SONGHOÏ',
        title: 'L\'Enduit Sacré de la Pyramide des Askia',
        photoAsset: monument.photoUrl,
        description:
            'Sous la conduite des notables de Gao et des gardiens du tombeau, la pyramide bénéficie d\'un rituel périodique où la communauté songhoï renouvelle l\'argile de la sépulture de l\'empereur Askia Mohammed.',
        audioListenTitle: 'Écouter le récit des rituels du Tombeau des Askia',
        audioContentId: 'rituels_askia',
        audioSpeechText:
            'Les rituels ancestraux du Tombeau des Askia à Gao. '
            'Édifiée en 1495, cette pyramide est le cœur battant de la mémoire songhoï. '
            'Régulièrement, les maîtres de terre de Gao préparent un banco d\'argile fine au bord du fleuve Niger. '
            'Les jeunes hommes escaladent les madriers en acacia blanc pour étaler l\'enduit protecteur sous les prières des anciens, perpétuant ainsi cinq siècles de dévotion ininterrompue.',
        chronologyTitle: 'Déroulement du Rituel de Rénovation',
        chronologySubtitle: 'La transmission vivante de la mémoire impériale.',
        steps: const [
          MonumentRitualStepData(
            time: 'La veille au crépuscule',
            title: 'La Préparation de l\'Argile Fluviale',
            content:
                'Extraction du limon fin des rives du Niger et mélange avec de la paille hachée et des huiles végétales pour former un enduit souple et résistant aux vents de sable.',
            icon: Icons.waves_rounded,
          ),
          MonumentRitualStepData(
            time: 'À l\'aube',
            title: 'Les Prières Solennelles dans la Cour',
            content:
                'Rassemblement des dignitaires religieux et des familles de Gao devant les deux mosquées du complexe pour invoquer la paix et la prospérité sur le pays.',
            icon: Icons.auto_stories_rounded,
          ),
          MonumentRitualStepData(
            time: 'Matinée',
            title: 'L\'Escalade des Madriers d\'Acacia Blanc',
            content:
                'Les jeunes artisans prennent appui sur les poutres saillantes d\'acacia pour atteindre le sommet de 17 mètres et renouveler l\'enduit des quatre faces de la pyramide.',
            icon: Icons.pan_tool_rounded,
          ),
          MonumentRitualStepData(
            time: 'Après-midi',
            title: 'La Veillée des Contes Impériaux Songhoï',
            content:
                'Les griots et conteurs de Gao déclament l\'épopée d\'Askia Mohammed, le pèlerinage à La Mecque et l\'âge d\'or de l\'Empire Songhoï.',
            icon: Icons.history_edu_rounded,
          ),
        ],
      );
    }

    // ── TATA DE SIKASSO : LA RÉSISTANCE HÉROÏQUE ─────────────────────────────
    if (id.contains('sikasso')) {
      return MonumentTraditionData(
        tabLabel: 'La Résistance',
        tabIcon: Icons.shield_rounded,
        badge: 'DEVISE ÉTERNELLE DU KÉNÉDOUGOU',
        title: 'L\'Épopée Militaire & Le Siège Héroïque',
        photoAsset: monument.photoUrl,
        description:
            'Le Tata de Sikasso est le monument immortel de la résistance anticoloniale. Il incarne la détermination légendaire du roi Babemba Traoré : "Plutôt la mort que la honte !".',
        audioListenTitle: 'Écouter le récit de la résistance du Tata',
        audioContentId: 'resistance_sikasso',
        audioSpeechText:
            'L\'épopée de la résistance du Tata de Sikasso. '
            'En 1887, les neuf kilomètres de remparts résistent victorieusement pendant quinze mois au siège de l\'Almamy Samory Touré. '
            'En avril 1898, face aux canons coloniaux, le roi Babemba Traoré refuse toute reddition et prononce la devise sacrée : An bi sa, n\'ka an te malo. Plutôt mourir que de subir la honte.',
        chronologyTitle: 'Les Grandes Heures de la Résistance',
        chronologySubtitle: 'Chronologie des combats héroïques du Kénédougou.',
        steps: const [
          MonumentRitualStepData(
            time: '1877 – 1887',
            title: 'L\'Érection Héroïque de la Muraille',
            content:
                'Le roi Tiéba Traoré mobilise des milliers d\'artisans et de guerriers pour ceinturer Sikasso d\'une forteresse de 9,5 km capable de défier toutes les armées de la région.',
            icon: Icons.foundation_rounded,
          ),
          MonumentRitualStepData(
            time: 'Avril 1887 – Août 1888',
            title: 'Le Siège Victorieux de 15 Mois',
            content:
                'L\'armée de Samory Touré encercle Sikasso mais se heurte aux bastions inexpugnables du Tata. Les habitants résistent grâce aux réserves agricoles protégées à l\'intérieur.',
            icon: Icons.shield_rounded,
          ),
          MonumentRitualStepData(
            time: 'Avril 1898',
            title: 'L\'Assaut Colonial & Le Sacrifice Suprême',
            content:
                'Face à l\'artillerie lourde, les guerriers du Kénédougou luttent pied à pied sur les remparts. Le roi Babemba Traoré choisit la mort héroïque en martyr plutôt que la capitulation.',
            icon: Icons.military_tech_rounded,
          ),
          MonumentRitualStepData(
            time: 'Mémoire Vivante',
            title: 'La Flamme Patriotique Éternelle',
            content:
                'Chaque année, Sikasso célèbre la mémoire des martyrs du Tata lors de commémorations patriotiques rappelant la devise : Plutôt la mort que la honte.',
            icon: Icons.local_fire_department_rounded,
          ),
        ],
      );
    }

    // ── UNIVERSITÉ & MOSQUÉE DE SANKORÉ : LES MANUSCRITS ─────────────────────
    if (id.contains('sankore')) {
      return MonumentTraditionData(
        tabLabel: 'Les Manuscrits',
        tabIcon: Icons.menu_book_rounded,
        badge: 'CULTURE DU SAVOIR UNIVERSEL',
        title: 'La Nuit des Manuscrits & Le Culte du Livre',
        photoAsset: monument.photoUrl,
        description:
            'Au cœur de Tombouctou, Sankoré perpétue la tradition du livre manuscrit. Plus de 25 000 étudiants y ont étudié la médecine, le droit, l\'astronomie et la philosophie.',
        audioListenTitle: 'Écouter le récit de l\'Université de Sankoré',
        audioContentId: 'manuscrits_sankore',
        audioSpeechText:
            'L\'Université et Mosquée de Sankoré à Tombouctou. '
            'Au XVIe siècle, Tombouctou était la capitale mondiale du livre manuscrit. '
            'Le commerce des livres y rapportait plus que celui de l\'or et du sel. '
            'Des savants illustres comme Ahmed Baba rédigeaient des traités de mathématiques, d\'astronomie et de droits humains qui éclairent encore l\'humanité aujourd\'hui.',
        chronologyTitle: 'Le Parcours de la Connaissance à Sankoré',
        chronologySubtitle: 'De l\'école coranique à la thèse doctorale.',
        steps: const [
          MonumentRitualStepData(
            time: 'Première étape',
            title: 'L\'Apprentissage des Sciences et de la Langue',
            content:
                'Les étudiants arrivant de toute l\'Afrique de l\'Ouest s\'initient à la grammaire arabe, à la rhétorique et à la mémorisation des textes sacrés dans les cours de la mosquée.',
            icon: Icons.school_rounded,
          ),
          MonumentRitualStepData(
            time: 'Deuxième étape',
            title: 'Les Hautes Études : Astronomie, Droit & Médecine',
            content:
                'Enseignement magistral dispensé par les oulémas. Les étudiants analysent le mouvement des astres et les traités de pharmacopée sous les voûtes de terre crue.',
            icon: Icons.science_rounded,
          ),
          MonumentRitualStepData(
            time: 'Troisième étape',
            title: 'L\'Art de la Copie & La Calligraphie',
            content:
                'Des centaines de scribes copient les ouvrages rares à l\'encre de suie sur papier filigrané d\'Italie, créant un trésor de 700 000 manuscrits anciens.',
            icon: Icons.edit_note_rounded,
          ),
          MonumentRitualStepData(
            time: 'Couronnement',
            title: 'La Remise Solennelle du Turban Blanc',
            content:
                'Après avoir soutenu sa thèse devant le collège des maîtres, le lauréat est intronisé savant émérite lors d\'une cérémonie festive rassemblant toute la cité.',
            icon: Icons.workspace_premium_rounded,
          ),
        ],
      );
    }

    // ── MOSQUÉE DJINGAREYBER : SPIRITUALITÉ & MAOULOUD ───────────────────────
    if (id.contains('djingareyber')) {
      return MonumentTraditionData(
        tabLabel: 'Spiritualité',
        tabIcon: Icons.mosque_rounded,
        badge: '7 SIÈCLES DE FOI ININTERROMPUE',
        title: 'Le Grand Vendredi & La Nuit du Maouloud',
        photoAsset: monument.photoUrl,
        description:
            'Depuis 1327, Djingareyber rythme la vie spirituelle de Tombouctou. Chaque vendredi et lors du Maouloud, des milliers de fidèles et de pèlerins se rassemblent sous ses arcades séculaires.',
        audioListenTitle: 'Écouter le récit spirituel de Djingareyber',
        audioContentId: 'spiritualite_djingareyber',
        audioSpeechText:
            'La Mosquée Djingareyber, grand sanctuaire de Tombouctou fondé par Mansa Moussa en 1327. '
            'Ici, la tradition soufie de tolérance et de paix résonne depuis plus de sept cents ans. '
            'Lors des nuits de prière du Maouloud, les poèmes à la gloire de la création sont chantés à l\'unisson par toute la communauté dans une ferveur lumineuse.',
        chronologyTitle: 'Les Rituels Vivants de Djingareyber',
        chronologySubtitle: 'Sept siècles de paix, de tolérance et de foi.',
        steps: const [
          MonumentRitualStepData(
            time: 'Chaque Vendredi',
            title: 'La Grande Prière Fédératrice',
            content:
                'Les commerçants du marché, les savants et les familles de Tombouctou remplissent les 25 travées de piliers pour écouter le prêche de concorde de l\'imam.',
            icon: Icons.groups_rounded,
          ),
          MonumentRitualStepData(
            time: 'Nuit du Maouloud',
            title: 'La Veillée Mystique des 333 Saints',
            content:
                'Chants soufis et récitation de poèmes panégyriques éclairés par les lanternes sous le ciel étoilé du désert jusqu\'aux premières lueurs du jour.',
            icon: Icons.nightlight_round,
          ),
          MonumentRitualStepData(
            time: 'Chaque Automne',
            title: 'L\'Entretien Rituel de la Toiture',
            content:
                'Les maçons de Tombouctou vérifient les chenaux et renouvellent les enduits de banco pour protéger le sanctuaire des rares mais violentes pluies du Sahel.',
            icon: Icons.handyman_rounded,
          ),
        ],
      );
    }

    // ── MONUMENT DE L'INDÉPENDANCE (BAMAKO) : COMMÉMORATION ─────────────────
    if (id.contains('independance')) {
      return MonumentTraditionData(
        tabLabel: 'Commémoration',
        tabIcon: Icons.flag_rounded,
        badge: 'CÉRÉMONIAL CIVIQUE & PATRIOTIQUE',
        title: 'Le Grand Défilé du 22 Septembre',
        photoAsset: monument.photoUrl,
        description:
            'Chaque 22 septembre, le boulevard et le monument de l\'Indépendance deviennent le cœur battant de la République lors de la fête nationale célébrant la souveraineté du Mali proclamée en 1960.',
        audioListenTitle: 'Écouter le récit de l\'Indépendance du Mali',
        audioContentId: 'commemoration_independance',
        audioSpeechText:
            'La célébration au Monument de l\'Indépendance à Bamako. '
            'Le 22 septembre 1960, le président Modibo Keïta proclamait solennellement devant le peuple rassemblé la naissance de la République du Mali souveraine. '
            'Chaque année, les couleurs nationales vert, jaune et rouge flottent au sommet du monument lors d\'un hommage vibrant aux bâtisseurs de la nation.',
        chronologyTitle: 'Le Protocole Républicain du 22 Septembre',
        chronologySubtitle: 'Célébration solennelle de la souveraineté nationale.',
        steps: const [
          MonumentRitualStepData(
            time: '7h30',
            title: 'La Levée des Couleurs Nationales',
            content:
                'Le drapeau du Mali est hissé au mât d\'honneur au son de l\'hymne national "Pour l\'Afrique et pour toi, Mali" exécuté par la fanfare nationale.',
            icon: Icons.flag_rounded,
          ),
          MonumentRitualStepData(
            time: '8h30',
            title: 'Le Dépôt de la Gerbe de Fleurs',
            content:
                'Le chef de l\'État dépose solennellement une gerbe de fleurs au pied du monument à la mémoire de tous les héros et martyrs de la patrie.',
            icon: Icons.local_florist_rounded,
          ),
          MonumentRitualStepData(
            time: '9h00 – 12h00',
            title: 'Le Grand Défilé Militaire & Populaire',
            content:
                'Parade impressionnante des corps constitués, des forces armées et de sécurité, suivie des mouvements de jeunesse et des troupes folkloriques du Mali profond.',
            icon: Icons.military_tech_rounded,
          ),
          MonumentRitualStepData(
            time: 'Soirée',
            title: 'Les Réjouissances Populaires & Concerts',
            content:
                'Concerts de musique moderne et traditionnelle, illuminations artistiques du monument et fête citoyenne ouverte à tous les Bamakois.',
            icon: Icons.celebration_rounded,
          ),
        ],
      );
    }

    // ── TOUR DE L'AFRIQUE : PANAFRICANISME ──────────────────────────────────
    if (id.contains('tour_afrique')) {
      return MonumentTraditionData(
        tabLabel: 'Panafricanisme',
        tabIcon: Icons.local_fire_department_rounded,
        badge: 'FLAMBEAU DE L\'INTÉGRATION CONTINENTALE',
        title: 'La Journée de l\'Afrique (25 Mai)',
        photoAsset: monument.photoUrl,
        description:
            'Érigée pour symboliser l\'idéal des États-Unis d\'Afrique, la Tour de l\'Afrique accueille chaque 25 mai les célébrations de la Journée de l\'Afrique et de l\'Unité continentale.',
        audioListenTitle: 'Écouter le récit de la Tour de l\'Afrique',
        audioContentId: 'panafricanisme_tour',
        audioSpeechText:
            'La Tour de l\'Afrique, phare de la renaissance panafricaine à Bamako. '
            'Haute de 46 mètres, couronnée par la flamme de la solidarité africaine, elle rappelle l\'engagement indéfectible du Mali pour l\'unité des peuples du continent, inscrit au cœur même de sa Constitution.',
        chronologyTitle: 'La Célébration Panafricaine du 25 Mai',
        chronologySubtitle: 'Commémoration de la création de l\'OUA en 1963.',
        steps: const [
          MonumentRitualStepData(
            time: 'Matinée',
            title: 'L\'Allumage de la Lanterne Sommitale',
            content:
                'Allumage symbolique de la flamme au sommet des 46 mètres en présence du corps diplomatique africain et des représentants de l\'Union Africaine.',
            icon: Icons.local_fire_department_rounded,
          ),
          MonumentRitualStepData(
            time: 'Midi',
            title: 'L\'Hommage aux Pères Fondateurs',
            content:
                'Recueillement devant les bas-reliefs de Kwamé Nkrumah, Modibo Keïta, Patrice Lumumba, Amilcar Cabral et Nelson Mandela.',
            icon: Icons.people_rounded,
          ),
          MonumentRitualStepData(
            time: 'Après-midi',
            title: 'Le Forum de la Jeunesse Africaine',
            content:
                'Débats sur l\'intégration économique, la culture et l\'innovation, réunissant des étudiants de tous les pays du continent résidant à Bamako.',
            icon: Icons.public_rounded,
          ),
        ],
      );
    }

    // ── FORT DE MÉDINE (KAYES) : L'ÉPOPÉE ───────────────────────────────────
    if (id.contains('medine')) {
      return MonumentTraditionData(
        tabLabel: 'L\'Épopée',
        tabIcon: Icons.military_tech_rounded,
        badge: 'MÉMOIRE DU HAUT-SÉNÉGAL',
        title: 'La Commémoration du Siège de 1857',
        photoAsset: monument.photoUrl,
        description:
            'Le Fort de Médine est le témoin d\'un tournant capital de l\'histoire ouest-africaine : le siège épique de 97 jours mené par l\'armée toucouleure d\'El Hadj Oumar Tall en 1857.',
        audioListenTitle: 'Écouter le récit du siège du Fort de Médine',
        audioContentId: 'epopee_medine',
        audioSpeechText:
            'L\'épopée historique du Fort de Médine au bord du fleuve Sénégal. '
            'En avril 1857, des milliers de cavaliers et fantassins d\'El Hadj Oumar Tall investissent la forteresse. '
            'Pendant plus de trois mois de canicule et d\'assauts acharnés, les défenseurs tiennent jusqu\'à l\'arrivée des renforts par le fleuve. '
            'Aujourd\'hui, Médine est un sanctuaire de réconciliation et de mémoire partagée.',
        chronologyTitle: 'Les 97 Jours du Siège de Médine',
        chronologySubtitle: 'Chronologie de la bataille historique du Haut-Sénégal.',
        steps: const [
          MonumentRitualStepData(
            time: 'Avril 1857',
            title: 'L\'Investissement du Fort par El Hadj Oumar Tall',
            content:
                'Les troupes du grand conquérant et réformateur religieux encerclent le fort de pierres rouges, coupant toutes les communications terrestres.',
            icon: Icons.history_rounded,
          ),
          MonumentRitualStepData(
            time: 'Mai – Juin 1857',
            title: 'Les Assauts Répétés sous la Canicule',
            content:
                'Multiples assauts sur les remparts sous des températures extrêmes de plus de 45°C, repoussés par les tireurs embusqués dans les bastions.',
            icon: Icons.shield_rounded,
          ),
          MonumentRitualStepData(
            time: '18 Juillet 1857',
            title: 'La Délivrance Fluviale & La Retraite',
            content:
                'Arrivée de la flottille armée remontant le fleuve Sénégal en crue. El Hadj Oumar Tall ordonne la levée du siège et poursuit sa marche vers le Kaarta.',
            icon: Icons.sailing_rounded,
          ),
          MonumentRitualStepData(
            time: 'Mémoire Contemporaine',
            title: 'Le Festival des Chutes du Félou',
            content:
                'Chaque année, le site accueille des artistes, historiens et visiteurs pour célébrer la paix et le riche patrimoine historique de la région de Kayes.',
            icon: Icons.celebration_rounded,
          ),
        ],
      );
    }

    // ── FALLBACK DYNAMIQUE ──────────────────────────────────────────────────
    return MonumentTraditionData(
      tabLabel: 'Patrimoine',
      tabIcon: Icons.auto_stories_rounded,
      badge: 'MÉMOIRE & TRANSMISSION',
      title: 'L\'Héritage Vivant de ${monument.name}',
      photoAsset: monument.photoUrl,
      description: monument.presentation,
      audioListenTitle: 'Écouter le récit historique',
      audioContentId: 'tradition_${monument.id}',
      audioSpeechText: '${monument.presentation} ${monument.whyItMatters}',
      chronologyTitle: 'Temps Forts & Mémoire',
      chronologySubtitle: 'Ce qui fait la grandeur de cet édifice.',
      steps: monument.chapters.map((ch) {
        return MonumentRitualStepData(
          time: 'Récit historique',
          title: ch.title,
          content: ch.content,
          icon: Icons.bookmark_added_rounded,
        );
      }).toList(),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 4. FRISE CHRONOLOGIQUE HISTORIQUE DÉDIÉE (ONGLET 4)
  // ══════════════════════════════════════════════════════════════════════════
  static List<MonumentTimelineEvent> getTimeline(MonumentDetail monument) {
    final id = monument.id.toLowerCase();

    // ── DJENNÉ ─────────────────────────────────────────────────────────────
    if (id.contains('djenne')) {
      return const [
        MonumentTimelineEvent(
          year: '1280',
          title: 'Fondation par le Roi Koy Konboro',
          content:
              'Le 26e roi de Djenné, Koy Konboro, se convertit à l\'islam. En signe d\'humilité spirituelle, il fait raser son somptueux palais royal pour édifier à sa place la toute première Grande Mosquée.',
          isFirst: true,
        ),
        MonumentTimelineEvent(
          year: '1324',
          title: 'L\'Âge d\'Or de l\'Empire du Mali',
          content:
              'Sous le règne de l\'empereur Mansa Moussa, Djenné devient la métropole commerciale sœur de Tombouctou. Des caravanes de sel et d\'or transitent chaque jour devant la mosquée.',
        ),
        MonumentTimelineEvent(
          year: '1834',
          title: 'L\'Épreuve de l\'Empire du Macina',
          content:
              'Le conquérant peul Sékou Amadou juge l\'édifice originel trop luxueux. Il fait bâtir une mosquée austère à proximité et laisse l\'ancien sanctuaire se dégrader sous les intempéries.',
        ),
        MonumentTimelineEvent(
          year: '1907',
          title: 'La Renaissance Triomphale des Barey Ton',
          content:
              'La corporation des maçons traditionnels de Djenné, dirigée par le maître d\'œuvre Ismaïla Traoré, reconstruit le monument selon son architecture originelle monumentale avec ses trois minarets.',
        ),
        MonumentTimelineEvent(
          year: '1988',
          title: 'Consécration au Patrimoine Mondial UNESCO',
          content:
              'L\'UNESCO classe la Grande Mosquée et la ville ancienne de Djenné au Patrimoine Mondial, consacrant le plus grand chef-d\'œuvre architectural en terre crue de la planète.',
          isLast: true,
        ),
      ];
    }

    // ── TOMBEAU DES ASKIA (GAO) ─────────────────────────────────────────────
    if (id.contains('askia')) {
      return const [
        MonumentTimelineEvent(
          year: '1493',
          title: 'Avènement de l\'Empereur Askia Mohammed',
          content:
              'Askia Mohammed prend la tête de l\'Empire Songhoï et fait de Gao la métropole administrative, religieuse et commerciale la plus rayonnante du Sahara.',
          isFirst: true,
        ),
        MonumentTimelineEvent(
          year: '1495',
          title: 'Retour de La Mecque & Érection de la Pyramide',
          content:
              'À son retour triomphal du pèlerinage, Askia Mohammed fait ériger le complexe funéraire en banco et acacia blanc, créant la première pyramide sahélienne d\'Afrique de l\'Ouest.',
        ),
        MonumentTimelineEvent(
          year: '1591',
          title: 'La Bataille de Tondibi & Préservation par la Cité',
          content:
              'Malgré la chute de l\'Empire Songhoï face aux troupes saadiennes, la population de Gao protège farouchement le tombeau comme son sanctuaire spirituel suprême.',
        ),
        MonumentTimelineEvent(
          year: '2004',
          title: 'Inscription au Patrimoine Mondial UNESCO',
          content:
              'L\'UNESCO consacre le Tombeau des Askia pour son authenticité architecturale en terre crue et son témoignage capital sur la grandeur de l\'Empire Songhoï.',
        ),
        MonumentTimelineEvent(
          year: 'Aujourd\'hui',
          title: 'Symbole Immortel de la Fierté Songhoï',
          content:
              'Le site reste une nécropole vénérée, entretenue avec ferveur par les familles de Gao et protégée comme un trésor de l\'humanité.',
          isLast: true,
        ),
      ];
    }

    // ── TATA DE SIKASSO ────────────────────────────────────────────────────
    if (id.contains('sikasso')) {
      return const [
        MonumentTimelineEvent(
          year: '1877',
          title: 'Fondation des Fortifications par Tiéba Traoré',
          content:
              'Le roi Tiéba Traoré entreprend la construction de la colossale muraille pour protéger la capitale du Kénédougou des menaces militaires environnantes.',
          isFirst: true,
        ),
        MonumentTimelineEvent(
          year: '1887',
          title: 'Le Siège Victorieux de Quinze Mois',
          content:
              'L\'Almamy Samory Touré assiège Sikasso avec ses armées. Derrière les remparts du Tata, la cité résiste héroïquement pendant 15 mois et repousse l\'envahisseur.',
        ),
        MonumentTimelineEvent(
          year: '1890',
          title: 'Renforcement sous le Roi Babemba Traoré',
          content:
              'Succédant à son frère, Babemba parfait les tours de guet, approfondit les fossés et renforce les cinq grandes portes de bois et de ferrures.',
        ),
        MonumentTimelineEvent(
          year: '1898',
          title: 'L\'Assaut Colonial & La Devise Immortelle',
          content:
              'Face à l\'artillerie lourde du colonel Audéoud, Babemba et ses guerriers luttent jusqu\'au bout. Le roi choisit le sacrifice suprême : "Plutôt la mort que la honte !".',
        ),
        MonumentTimelineEvent(
          year: 'Aujourd\'hui',
          title: 'Monument National & Mémoire du Courage',
          content:
              'Les vestiges du Tata et la colline du Mamelon sont des lieux de pèlerinage patriotique majeurs de la République du Mali.',
          isLast: true,
        ),
      ];
    }

    // ── UNIVERSITÉ & MOSQUÉE DE SANKORÉ (TOMBOUCTOU) ─────────────────────────
    if (id.contains('sankore')) {
      return const [
        MonumentTimelineEvent(
          year: '1327',
          title: 'Édification sous l\'Empire du Mali',
          content:
              'Fondation de la mosquée sous le règne de Mansa Moussa, financée par une noble et pieuse dame de Tombouctou qui consacre sa fortune à l\'édification.',
          isFirst: true,
        ),
        MonumentTimelineEvent(
          year: '1500',
          title: 'L\'Âge d\'Or : 25 000 Étudiants du Savoir',
          content:
              'Sous l\'Empire Songhoï, Sankoré devient l\'une des universités les plus renommées du monde musulman, accueillant étudiants et lettrés du Maghreb et du Moyen-Orient.',
        ),
        MonumentTimelineEvent(
          year: '1594',
          title: 'Le Grand Savant Ahmed Baba de Tombouctou',
          content:
              'Ahmed Baba, jurisconsulte et philosophe formé à Sankoré, rédige plus de quarante traités majeurs avant d\'être déporté au Maroc lors de l\'invasion saadienne.',
        ),
        MonumentTimelineEvent(
          year: '1988',
          title: 'Inscription au Patrimoine Mondial UNESCO',
          content:
              'Sankoré et les mosquées de Tombouctou sont classées par l\'UNESCO au titre de chefs-d\'œuvre du patrimoine spirituel et intellectuel universel.',
        ),
        MonumentTimelineEvent(
          year: 'Aujourd\'hui',
          title: 'Sauvegarde des 700 000 Manuscrits Anciens',
          content:
              'Les familles dépositaires et les instituts préservent jalousement les manuscrits séculaires traitant d\'astronomie, de mathématiques, de droit et de paix.',
          isLast: true,
        ),
      ];
    }

    // ── MOSQUÉE DJINGAREYBER (TOMBOUCTOU) ───────────────────────────────────
    if (id.contains('djingareyber')) {
      return const [
        MonumentTimelineEvent(
          year: '1324',
          title: 'Le Pèlerinage Royal de Mansa Moussa',
          content:
              'De retour de La Mecque avec l\'architecte andalou Abou Ishaq es-Sahéli, l\'empereur Mansa Moussa décide d\'ériger le plus grand sanctuaire du Sahara à Tombouctou.',
          isFirst: true,
        ),
        MonumentTimelineEvent(
          year: '1327',
          title: 'Achèvement avec 200 Kilos d\'Or Pur',
          content:
              'Mansa Moussa alloue 200 kilos d\'or pour financer la construction en terre crue et calcaire, introduisant la voûte et le minaret tronconique.',
        ),
        MonumentTimelineEvent(
          year: '1570',
          title: 'L\'Agrandissement Majeur du Cadi Al-Aqib',
          content:
              'L\'érudit cadi Al-Aqib supervise une extension magistrale de la salle de prière pour accueillir l\'afflux croissant de caravaniers et d\'étudiants.',
        ),
        MonumentTimelineEvent(
          year: '1988',
          title: 'Consécration UNESCO',
          content:
              'Classée au Patrimoine Mondial de l\'Humanité comme fleuron exceptionnel de l\'architecture religieuse soudano-sahélienne.',
        ),
        MonumentTimelineEvent(
          year: 'Aujourd\'hui',
          title: 'Sept Siècles d\'Activité Continue',
          content:
              'Plus ancien édifice en activité ininterrompue de Tombouctou, la mosquée continue de rassembler les fidèles chaque vendredi.',
          isLast: true,
        ),
      ];
    }

    // ── MONUMENT DE L'INDÉPENDANCE (BAMAKO) ──────────────────────────────────
    if (id.contains('independance')) {
      return const [
        MonumentTimelineEvent(
          year: '1958',
          title: 'Proclamation de la République Soudanaise',
          content:
              'Émancipation politique au sein de la Communauté française sous l\'impulsion des leaders nationalistes de l\'US-RDA.',
          isFirst: true,
        ),
        MonumentTimelineEvent(
          year: '1960 (22 Septembre)',
          title: 'Proclamation Historique de l\'Indépendance',
          content:
              'Le président Modibo Keïta proclame la pleine souveraineté de la République du Mali devant le Congrès extraordinaire réuni à Bamako.',
        ),
        MonumentTimelineEvent(
          year: '1995',
          title: 'Inauguration du Monument Monumental',
          content:
              'Érection de la grande tour commémorative en marbre et béton au centre du grand boulevard pour pérenniser la mémoire des pères de la liberté.',
        ),
        MonumentTimelineEvent(
          year: 'Aujourd\'hui',
          title: 'Sanctuaire Civique des Défilés Nationaux',
          content:
              'Lieu incontournable de rassemblement patriotique où bat le cœur civique de la République du Mali.',
          isLast: true,
        ),
      ];
    }

    // ── TOUR DE L'AFRIQUE (BAMAKO) ──────────────────────────────────────────
    if (id.contains('tour_afrique')) {
      return const [
        MonumentTimelineEvent(
          year: '1963',
          title: 'Création de l\'Organisation de l\'Unité Africaine (OUA)',
          content:
              'Le président Modibo Keïta et ses pairs signent la charte historique de l\'OUA à Addis-Abeba, scellant la vocation panafricaine du Mali.',
          isFirst: true,
        ),
        MonumentTimelineEvent(
          year: '1999',
          title: 'Décision du Mémorial de la Renaissance Africaine',
          content:
              'Lancement du projet monumental pour doter Bamako d\'un phare architectural célébrant le passage au XXIe siècle sous le signe de l\'union continentale.',
        ),
        MonumentTimelineEvent(
          year: '2001 (Janvier)',
          title: 'Inauguration Solennelle au Sommet de Bamako',
          content:
              'La Tour de 46 mètres est inaugurée en présence des chefs d\'État du continent lors du grand sommet international tenu à Bamako.',
        ),
        MonumentTimelineEvent(
          year: 'Aujourd\'hui',
          title: 'Phare Emblématique de la Rive Droite',
          content:
              'Repère visuel majeur à Faladié, illuminant les nuits bamakoises aux couleurs de la liberté et de l\'intégration africaine.',
          isLast: true,
        ),
      ];
    }

    // ── FORT DE MÉDINE (KAYES) ──────────────────────────────────────────────
    if (id.contains('medine')) {
      return const [
        MonumentTimelineEvent(
          year: '1855',
          title: 'Construction de la Forteresse Fluviale',
          content:
              'Édification du fort en pierres de grès rouge au bord du fleuve Sénégal pour contrôler le commerce caravanier et la navigation fluviale.',
          isFirst: true,
        ),
        MonumentTimelineEvent(
          year: '1857',
          title: 'Le Siège Héroïque de 97 Jours',
          content:
              'Les troupes de l\'empire d\'El Hadj Oumar Tall assiègent le fort pendant plus de trois mois dans l\'une des batailles les plus célèbres du XIXe siècle.',
        ),
        MonumentTimelineEvent(
          year: '1890',
          title: 'Transition Civile & Capitale du Cercle',
          content:
              'Fin des opérations militaires et transformation du site en centre administratif historique du Haut-Sénégal.',
        ),
        MonumentTimelineEvent(
          year: '1992',
          title: 'Classement Monument Historique National',
          content:
              'Inscription du Fort de Médine au patrimoine culturel national malien pour préserver la mémoire des peuples khassonkés et toucouleurs.',
        ),
        MonumentTimelineEvent(
          year: 'Aujourd\'hui',
          title: 'Site Muséal & Destination Écotouristique',
          content:
              'Lieu de découverte majeur surplombant les magnifiques chutes du Félou, visité par des milliers de passionnés d\'histoire.',
          isLast: true,
        ),
      ];
    }

    // ── FALLBACK DYNAMIQUE ──────────────────────────────────────────────────
    return [
      MonumentTimelineEvent(
        year: 'Origines',
        title: 'Édification & Fondation',
        content: monument.era,
        isFirst: true,
      ),
      ...monument.chapters.map((ch) {
        return MonumentTimelineEvent(
          year: 'Histoire',
          title: ch.title,
          content: ch.content,
        );
      }),
      MonumentTimelineEvent(
        year: 'Aujourd\'hui',
        title: 'Préservation & Héritage',
        content: monument.whyItMatters,
        isLast: true,
      ),
    ];
  }
}
