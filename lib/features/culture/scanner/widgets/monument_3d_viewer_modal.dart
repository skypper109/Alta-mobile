import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/vivienne_tts_service.dart';
import '../../core/theme/culture_theme.dart';
import '../models/monument_scan_models.dart';

/// Modes d'éclairage cinématographiques pour le rendu 3D
enum LightingEnvironment {
  soleilSahelien, // Plein soleil d'or zénithal
  crepuscule,     // Coucher de soleil ambré
  nuitEtoilee,    // Nuit saharienne avec projecteurs
}

/// Point d'intérêt architectural ancré en coordonnées 3D réelles (X, Y, Z)
class Architectural3DHotspot {
  final double x;
  final double y;
  final double z;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  const Architectural3DHotspot({
    required this.x,
    required this.y,
    required this.z,
    required this.title,
    required this.subtitle,
    required this.description,
    this.icon = Icons.architecture_rounded,
  });
}

/// Facette 3D triangulaire ou polygonale avec calcul d'éclairage Lambertian
class PolygonFace3D {
  final List<List<double>> vertices; // Coordonnées [x, y, z]
  final Color baseColor;
  final double roughness; // 0.0 lisse, 1.0 mat (banco)
  final String? textureType; // 'banco', 'metal', 'marble', 'wood'

  const PolygonFace3D({
    required this.vertices,
    required this.baseColor,
    this.roughness = 0.8,
    this.textureType,
  });
}

/// Modal d'exploration 3D haute fidélité pour les monuments de CultureLens
class Monument3DViewerModal extends StatefulWidget {
  final MonumentScanTarget target;

  const Monument3DViewerModal({
    super.key,
    required this.target,
  });

  static Future<void> show(BuildContext context, MonumentScanTarget target) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Monument3DViewerModal(target: target),
    );
  }

  @override
  State<Monument3DViewerModal> createState() => _Monument3DViewerModalState();
}

class _Monument3DViewerModalState extends State<Monument3DViewerModal>
    with TickerProviderStateMixin {
  // Angles de rotation 3D (orbite)
  double _rotX = -0.22;
  double _rotY = 0.45;
  double _scale = 1.0;
  Offset _panOffset = Offset.zero;

  // Contrôles interactifs
  bool _isArMode = false;
  bool _showWireframe = false;
  bool _autoRotate = true;
  LightingEnvironment _lighting = LightingEnvironment.soleilSahelien;
  Architectural3DHotspot? _activeHotspot;

  late final AnimationController _animController;
  late final AnimationController _particlesController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..addListener(() {
        if (_autoRotate && mounted) {
          setState(() {
            _rotY += 0.004;
          });
        }
      });
    _animController.repeat();

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  List<Architectural3DHotspot> _getHotspotsForTarget(MonumentScanTarget target) {
    final id = target.id.toLowerCase();
    if (id.contains('independance')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -140,
          z: 0,
          title: 'Flèche Minaret Soudanaise',
          subtitle: 'Sommet pyramidal couronné de l\'emblème national',
          description:
              'Symbole d\'élévation spirituelle et civique, cette flèche géométrique s\'inspire des minarets de Tombouctou et Djenné.',
          icon: Icons.flag_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: -20,
          z: 32,
          title: 'Frises Géométriques Mandingues',
          subtitle: 'Reliefs ciselés dans le béton stabilisé',
          description:
              'Motifs traditionnels symbolisant l\'union sacrée des peuples du Mali et la transmission intergénérationnelle.',
          icon: Icons.grain_rounded,
        ),
        Architectural3DHotspot(
          x: 35,
          y: 70,
          z: 35,
          title: 'Piédestal Républicain',
          subtitle: 'Base octogonale monumentale',
          description:
              'Socle cérémoniel en pierre de taille où se tiennent les célébrations solennelles de la souveraineté du 22 septembre 1960.',
          icon: Icons.account_balance_rounded,
        ),
      ];
    } else if (id.contains('tour_afrique')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -150,
          z: 0,
          title: 'Le Flambeau Éternel de l\'Unité',
          subtitle: 'Sculpture métallique culminante',
          description:
              'Brasier en cuivre stylisé rappelant la flamme de la libération panafricaine allumée par les pères fondateurs de l\'OUA.',
          icon: Icons.local_fire_department_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: -85,
          z: 42,
          title: 'Plateforme Panoramique',
          subtitle: 'Belvédère à 360° sur Bamako',
          description:
              'Galerie circulaire offrant une vue plongeante sur l\'échangeur de Faladié et les collines du Mandé.',
          icon: Icons.remove_red_eye_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: 30,
          z: 46,
          title: 'Fût Cannelé en Baobab',
          subtitle: 'Tour cylindrique de 46 mètres',
          description:
              'Inspirée de la circonférence d\'un baobab protecteur, la structure est habillée de bas-reliefs narrant les luttes africaines.',
          icon: Icons.park_rounded,
        ),
      ];
    } else if (id.contains('paix')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -110,
          z: 0,
          title: 'Colombe Métallique Ajourée',
          subtitle: 'Envergure d\'acier de 12 mètres',
          description:
              'Chef-d\'œuvre de ferronnerie d\'art figurant la concorde et la réconciliation nationale proclamée lors de la Flamme de la Paix.',
          icon: Icons.flutter_dash_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: 40,
          z: 28,
          title: 'Stèle en Marbre de Sélinkegny',
          subtitle: 'Socle pyramidal blanc immaculé',
          description:
              'Bloc monolithique taillé dans les carrières de marbre malien, gravé d\'inscriptions en hommage à la paix.',
          icon: Icons.architecture_rounded,
        ),
      ];
    } else if (id.contains('ciwara')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -140,
          z: 10,
          title: 'Cornes Mythiques de l\'Antilope',
          subtitle: 'Élancement vers le soleil et la pluie',
          description:
              'Les cornes recourbées symbolisent la croissance vigoureuse des céréales bénies par le génie agricole.',
          icon: Icons.pets_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: -20,
          z: 25,
          title: 'Crinière Ajourée en Dents de Scie',
          subtitle: 'Détail sculptural traditionnel',
          description:
              'Représente le mouvement ondoyant du soleil et l\'énergie infatigable du paysan labourant la terre.',
          icon: Icons.auto_awesome_rounded,
        ),
      ];
    } else if (id.contains('armee_noire')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -30,
          z: 10,
          title: 'Statuaire de Bronze des Tirailleurs',
          subtitle: 'Groupe héroïque commémoratif (1924)',
          description:
              'Sculptures de bronze rendant hommage aux régiments de tirailleurs africains pour leur sacrifice lors de la Grande Guerre.',
          icon: Icons.groups_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: 45,
          z: 32,
          title: 'Piédestal en Pierre de Taille',
          subtitle: 'Reliefs de mémoire & cartouche historique',
          description:
              'Plinthe solennelle en pierre sculptée reproduisant à l\'identique le célèbre monument de Reims.',
          icon: Icons.account_balance_rounded,
        ),
      ];
    } else if (id.contains('samory')) {
      return const [
        Architectural3DHotspot(
          x: 10,
          y: -40,
          z: 15,
          title: 'Almamy Samory & Sabre Sacré',
          subtitle: 'Héros de la résistance anticoloniale',
          description:
              'Représentation magistrale de l\'empereur du Wassoulou brandissant le sabre de la liberté et de l\'insoumission.',
          icon: Icons.shield_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: 0,
          z: 20,
          title: 'Étalon Cabré de Guerre',
          subtitle: 'Dynamique héroïque de cavalerie',
          description:
              'Cheval impérial en plein élan symbolisant l\'esprit d\'audace et la mobilité légendaire de l\'armée mandingue.',
          icon: Icons.pets_rounded,
        ),
      ];
    } else if (id.contains('martyrs')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -45,
          z: 18,
          title: 'Grande Arche du 26 Mars 1991',
          subtitle: 'Passerelle républicaine vers la démocratie',
          description:
              'Structure en arc monumentale reliant symboliquement la mémoire des disparus à l\'avenir démocratique du Mali.',
          icon: Icons.door_sliding_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: 10,
          z: 0,
          title: 'Flamme Démocratique Éternelle',
          subtitle: 'Stèle mémorielle du Pont des Martyrs',
          description:
              'Foyer solennel dominant le cours du fleuve Djoliba où les gerbes de fleurs nationales sont déposées chaque 26 mars.',
          icon: Icons.local_fire_department_rounded,
        ),
      ];
    } else if (id.contains('nkrumah')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -35,
          z: 10,
          title: 'Buste de Kwamé Nkrumah',
          subtitle: 'Père de l\'indépendance et panafricain',
          description:
              'Sculpture de bronze à l\'effigie du visionnaire des États-Unis d\'Afrique et grand ami du président Modibo Keïta.',
          icon: Icons.public_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: 50,
          z: 28,
          title: 'Stèle en Granit Noir Gravée',
          subtitle: 'Médaillon commémoratif de l\'OUA',
          description:
              'Monolithe sombre célébrant le traité de l\'Union des États Africains scellé en 1958.',
          icon: Icons.article_rounded,
        ),
      ];
    } else if (id.contains('cathedrale')) {
      return const [
        Architectural3DHotspot(
          x: -36,
          y: -80,
          z: 35,
          title: 'Tours Jumelles & Clochers Néo-Romans',
          subtitle: 'Façade de grès extrait des carrières de Bamako',
          description:
              'Clochers élancés abritant les cloches historiques qui rythment le centre-ville depuis 1927.',
          icon: Icons.church_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: 0,
          z: 25,
          title: 'Grande Rosace & Nef Sahélienne',
          subtitle: 'Vitraux et portails en arc plein cintre',
          description:
              'Vaisseau central lumineux associant les canons byzantins à la chaleur des pierres ocres locales.',
          icon: Icons.flare_rounded,
        ),
      ];
    } else if (id.contains('mosquee_bamako')) {
      return const [
        Architectural3DHotspot(
          x: -48,
          y: -115,
          z: 45,
          title: 'Hauts Minarets de Dabanani',
          subtitle: 'Balcons de muezzin et croissants dorés',
          description:
              'Tours blanches dominant le cœur commercial de Bamako et visibles depuis les berges du fleuve Niger.',
          icon: Icons.mosque_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: 15,
          z: 0,
          title: 'Coupole Islamique Verte',
          subtitle: 'Dôme central de la grande salle de prière',
          description:
              'Édifice majestueux pouvant accueillir des milliers de fidèles lors des prières du vendredi et de l\'Aïd.',
          icon: Icons.wb_twilight_rounded,
        ),
      ];
    } else if (id.contains('sogolon')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -40,
          z: 0,
          title: 'Effigie de Sogolon Kolonkan',
          subtitle: 'Sœur royale de Soundiata Keïta',
          description:
              'Incarne la sagesse politique, la connaissance des plantes sacrées et le pouvoir protecteur des femmes du Mandé.',
          icon: Icons.woman_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: -10,
          z: 15,
          title: 'Calebasse de Bénédiction',
          subtitle: 'Emblème de prospérité et d\'hospitalité',
          description:
              'Récipient rituel symbolisant la fertilité, le partage de l\'eau de paix et la souveraineté matricielle.',
          icon: Icons.spa_rounded,
        ),
      ];
    } else if (id.contains('quouds') || id.contains('qods')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -50,
          z: 0,
          title: 'Coupole Dorée d\'Al-Qods',
          subtitle: 'Dôme étincelant surmonté du croissant',
          description:
              'Inspiré de l\'architecture islamique sacrée, ce dôme doré célèbre la paix, la foi et la solidarité internationale.',
          icon: Icons.stars_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: 35,
          z: 40,
          title: 'Arcades Orientales de l\'ACI 2000',
          subtitle: 'Pavillon octogonal à piliers sculptés',
          description:
              'Portiques ouverts bordant un grand carrefour moderne de la capitale au quartier d\'affaires.',
          icon: Icons.architecture_rounded,
        ),
      ];
    } else if (id.contains('maliba')) {
      return const [
        Architectural3DHotspot(
          x: -44,
          y: 20,
          z: 15,
          title: 'Lettres Vert-Jaune-Rouge « MALIBA »',
          subtitle: 'Fierté patriotique et jeunesse républicaine',
          description:
              'Typographie monumentale en 3D aux couleurs du drapeau national célébrant la grandeur du Mali.',
          icon: Icons.emoji_flags_rounded,
        ),
        Architectural3DHotspot(
          x: 74,
          y: -60,
          z: 0,
          title: 'Mât du Pavillon National',
          subtitle: 'Étendard tricolore flottant au vent',
          description:
              'Lieu cérémoniel de rassemblement populaire et point de fierté civique en plein centre-ville.',
          icon: Icons.flag_rounded,
        ),
      ];
    } else if (id.contains('obelisque')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -140,
          z: 0,
          title: 'Pyramidion Monolithique',
          subtitle: 'Sommet en pointe de grès de Bamako',
          description:
              'L\'aiguille de l\'obélisque capte la lumière zénithale et structure la perspective visuelle de la grande avenue.',
          icon: Icons.vertical_align_top_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: 65,
          z: 35,
          title: 'Plinthe Historique à Degrés',
          subtitle: 'Soubassement colonial et républicain',
          description:
              'Socle à trois gradins en granit rose taillé, repère central de l\'urbanisme de la capitale depuis plus d\'un siècle.',
          icon: Icons.layers_rounded,
        ),
      ];
    } else if (id.contains('liberte')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: 10,
          z: 0,
          title: 'Fontaine & Esplanade Circulaire',
          subtitle: 'Le carrefour républicain de Bamako',
          description:
              'Bassin central entouré d\'allées pavées, de palmiers et de massifs fleuris reliant la gare au palais présidentiel.',
          icon: Icons.place_rounded,
        ),
        Architectural3DHotspot(
          x: -50,
          y: 40,
          z: 20,
          title: 'Anneau Arboré & Colonnade Civique',
          subtitle: 'Cœur battant du centre administratif',
          description:
              'Lieu historique des grandes manifestations patriotiques et des festivités citoyennes.',
          icon: Icons.park_rounded,
        ),
      ];
    } else if (id.contains('musee_national')) {
      return const [
        Architectural3DHotspot(
          x: -25,
          y: 30,
          z: 20,
          title: 'Toiture Sahélienne à Débord',
          subtitle: 'Architecture bioclimatique en terre cuite',
          description:
              'Auvents monumentaux protégeant les façades du soleil brûlant et créant une ventilation naturelle douce.',
          icon: Icons.architecture_rounded,
        ),
        Architectural3DHotspot(
          x: 20,
          y: 60,
          z: 25,
          title: 'Colonnade des Galeries Tellem',
          subtitle: 'Conservation des trésors millénaires',
          description:
              'Portiques ouverts sur les jardins botaniques abritant les chefs-d\'œuvre archéologiques et les textiles du XIe siècle.',
          icon: Icons.museum_rounded,
        ),
      ];
    } else if (id.contains('palais_culture')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -10,
          z: 20,
          title: 'Coque Acoustique du Djoliba',
          subtitle: 'Scène ouverte sur le fleuve Niger',
          description:
              'Amphithéâtre où résonnent la kora, le balafon et les récits des grands maîtres griots lors des festivals nationaux.',
          icon: Icons.theater_comedy_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: 65,
          z: -20,
          title: 'Gradins en Hémicycle',
          subtitle: 'Arène des arts vivants de Badalabougou',
          description:
              'Tribunes en gradins pouvant accueillir 3 000 spectateurs face au coucher de soleil sur le grand fleuve.',
          icon: Icons.stadium_rounded,
        ),
      ];
    } else if (id.contains('djenne')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -85,
          z: 15,
          title: 'Minaret Central & Œuf d\'Autruche',
          subtitle: 'Symbole de fertilité et de pureté',
          description:
              'Sommet conique surmonté d\'un œuf d\'autruche blanc protecteur selon la tradition architecturale soudanaise.',
          icon: Icons.egg_rounded,
        ),
        Architectural3DHotspot(
          x: -25,
          y: -15,
          z: 32,
          title: 'Torons en Bois de Palmier',
          subtitle: 'Échafaudages rituels permanents',
          description:
              'Poutres de rônier saillantes servant d\'appui aux maçons lors de la grande fête sacrée du crépissage annuel.',
          icon: Icons.carpenter_rounded,
        ),
      ];
    } else if (id.contains('askia')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -75,
          z: 0,
          title: 'Pyramide en Terre à Degrés (17m)',
          subtitle: 'Nécropole impériale de l\'Empire Songhoï (1495)',
          description:
              'Seul complexe pyramidal en banco préservé dans tout le Sahara, érigé par Askia Mohammed.',
          icon: Icons.change_history_rounded,
        ),
        Architectural3DHotspot(
          x: 25,
          y: -20,
          z: 25,
          title: 'Échafaudages en Épine d\'Acacia',
          subtitle: 'Structure d\'entretien séculaire',
          description:
              'Branches d\'acacia blanc hérissées sur les quatre faces pour faciliter l\'ascension et l\'enduit d\'argile.',
          icon: Icons.architecture_rounded,
        ),
      ];
    } else if (id.contains('djingareyber')) {
      return const [
        Architectural3DHotspot(
          x: -32,
          y: -80,
          z: 10,
          title: 'Minaret Conique de Mansa Moussa (1327)',
          subtitle: 'Le phare spirituel de Tombouctou',
          description:
              'Tour tronconique conçue par l\'architecte Abou Ishaq es-Sahéli avec 200 kg d\'or pur à son retour du pèlerinage.',
          icon: Icons.mosque_rounded,
        ),
        Architectural3DHotspot(
          x: 20,
          y: 40,
          z: 20,
          title: 'Sanctuaire aux 25 Colonnes',
          subtitle: 'Murs en pierre d\'Alchor et terre crue',
          description:
              'Nef sacrée abritant la chaire de prière séculaire et les sépultures des érudits sahéliens.',
          icon: Icons.temple_buddhist_rounded,
        ),
      ];
    } else if (id.contains('sankore')) {
      return const [
        Architectural3DHotspot(
          x: -30,
          y: -40,
          z: 25,
          title: 'Minaret aux Proportions de la Kaaba',
          subtitle: 'Le temple des 25 000 savants et étudiants',
          description:
              'Tour en gradins cubiques dont les dimensions intérieures correspondent exactement à la Kaaba de La Mecque.',
          icon: Icons.school_rounded,
        ),
        Architectural3DHotspot(
          x: 15,
          y: 45,
          z: 0,
          title: 'Cour des Manuscrits Précieux',
          subtitle: 'Berceau des traités d\'astronomie et de médecine',
          description:
              'Cour intérieure où les caravanes de savants copiaient et débattaient les 700 000 manuscrits anciens.',
          icon: Icons.auto_stories_rounded,
        ),
      ];
    } else if (id.contains('tata')) {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: 30,
          z: 20,
          title: 'Courtine de Banco & Pierres (Tiéba Traoré)',
          subtitle: 'Muraille militaire de 9 km',
          description:
              'Rempart inexpugnable qui résista pendant 15 mois au siège de Samory Touré en 1887.',
          icon: Icons.shield_rounded,
        ),
        Architectural3DHotspot(
          x: -58,
          y: -10,
          z: 10,
          title: 'Tour de Guet du Mamelon',
          subtitle: 'Bastion d\'observation stratégique',
          description:
              'Tour d\'angle circulaire fortifiée dominant les plaines fertiles du Kénédougou.',
          icon: Icons.castle_rounded,
        ),
      ];
    } else if (id.contains('medine')) {
      return const [
        Architectural3DHotspot(
          x: -52,
          y: 0,
          z: 32,
          title: 'Échauguette & Embrasures de Pierre',
          subtitle: 'Bastion fortifié sur le fleuve Sénégal',
          description:
              'Tourelle de surveillance en pierre de taille surplombant les rapides et les chutes du Félou.',
          icon: Icons.fort_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: 35,
          z: 0,
          title: 'Remparts du Siège de 1857',
          subtitle: 'Témoin de l\'épopée d\'El Hadj Oumar Tall',
          description:
              'Forteresse historique de grès rouge construite en 1855, clé de voûte de la navigation fluviale au XIXe siècle.',
          icon: Icons.history_edu_rounded,
        ),
      ];
    } else if (id.contains('segou')) {
      return const [
        Architectural3DHotspot(
          x: -15,
          y: 30,
          z: 25,
          title: 'Vestibule Royal de Bitòn Coulibaly',
          subtitle: 'Palais ancestral du Royaume Bambara',
          description:
              'Porte d\'entrée sacrée en banco avec linteaux sculptés et tombeau des souverains de Ségou-Koro.',
          icon: Icons.temple_hindu_rounded,
        ),
        Architectural3DHotspot(
          x: 48,
          y: -30,
          z: 0,
          title: 'Balanzan Sacré du Djoliba',
          subtitle: 'Arbre protecteur des 4 444 balanzans',
          description:
              'Acacia albida tutélaire dont l\'ombre vénérable protégeait les guerriers Tônjons au bord de l\'eau.',
          icon: Icons.nature_rounded,
        ),
      ];
    } else {
      return const [
        Architectural3DHotspot(
          x: 0,
          y: -100,
          z: 0,
          title: 'Architecture Monumentale Malienne',
          subtitle: 'Patrimoine historique & identité culturelle',
          description:
              'Édifice emblématique témoignant du génie constructif sahélien et de la mémoire vivante de la nation.',
          icon: Icons.account_balance_rounded,
        ),
        Architectural3DHotspot(
          x: 0,
          y: 20,
          z: 30,
          title: 'Socle & Ornements Républicains',
          subtitle: 'Ancrage dans la mémoire collective',
          description:
              'Lieu de célébration civique et transmission patrimoniale honoré par le peuple malien.',
          icon: Icons.stars_rounded,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.target;
    final size = MediaQuery.of(context).size;
    final hotspots = _getHotspotsForTarget(target);

    return Container(
      height: size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF080C16),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── TIREUR ────────────────────────────────────────────────────────
          Container(
            width: 44,
            height: 4.5,
            margin: const EdgeInsets.only(top: 12, bottom: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // ── EN-TÊTE IMMERSIF ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: CultureTheme.accentOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.view_in_ar_rounded,
                    color: CultureTheme.accentOrange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Modèle 3D',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'DÉTAILS',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF34D399),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${target.name} • ${target.regionName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF1E293B), height: 1),

          // ── SCÈNE DE RENDU 3D RÉALISTE ────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Fond d'ambiance selon le mode d'éclairage
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.1,
                        colors: _getBackgroundColors(),
                      ),
                    ),
                  ),
                ),

                // Particules atmosphériques (poussière d'or / étoiles)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _particlesController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _AtmosphericDustPainter(
                          progress: _particlesController.value,
                          lighting: _lighting,
                        ),
                      );
                    },
                  ),
                ),

                // Podestat circulaire avec ombre de contact projetée
                Center(
                  child: CustomPaint(
                    size: const Size(280, 280),
                    painter: _PedestalShadowPainter(
                      rotX: _rotX,
                      scale: _scale,
                    ),
                  ),
                ),

                // Modèle 3D architectural interactif
                Positioned.fill(
                  child: GestureDetector(
                    onScaleStart: (_) => setState(() => _autoRotate = false),
                    onScaleUpdate: (details) {
                      setState(() {
                        if (details.pointerCount > 1) {
                          _panOffset += details.focalPointDelta;
                        } else {
                          _rotY += details.focalPointDelta.dx * 0.012;
                          _rotX -= details.focalPointDelta.dy * 0.012;
                          _rotX = _rotX.clamp(-math.pi / 2.5, math.pi / 2.5);
                        }
                        _scale = (_scale * details.scale).clamp(0.6, 2.5);
                      });
                    },
                    child: Center(
                      child: CustomPaint(
                        size: const Size(360, 360),
                        painter: _RealisticMonument3DPainter(
                          target: target,
                          rotX: _rotX,
                          rotY: _rotY,
                          scale: _scale,
                          panOffset: _panOffset,
                          lighting: _lighting,
                          showWireframe: _showWireframe,
                        ),
                      ),
                    ),
                  ),
                ),

                // Hotspots 3D projetés en perspective
                for (final hp in hotspots) _buildProjected3DHotspot(hp),

                // ── HUD COMMANDES DROITE ────────────────────────────────────
                Positioned(
                  right: 16,
                  top: 16,
                  child: Column(
                    children: [
                      _buildHudPill(
                        icon: _autoRotate ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        tooltip: _autoRotate ? 'Mettre en pause rotation' : 'Rotation automatique',
                        isActive: _autoRotate,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _autoRotate = !_autoRotate);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildHudPill(
                        icon: Icons.wb_sunny_rounded,
                        tooltip: 'Changer éclairage',
                        onTap: _cycleLighting,
                      ),
                      const SizedBox(height: 8),
                      _buildHudPill(
                        icon: Icons.grid_4x4_rounded,
                        tooltip: 'Afficher la structure',
                        isActive: _showWireframe,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _showWireframe = !_showWireframe);
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildHudPill(
                        icon: Icons.refresh_rounded,
                        tooltip: 'Réinitialiser vue',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _rotX = -0.22;
                            _rotY = 0.45;
                            _scale = 1.0;
                            _activeHotspot = null;
                            _autoRotate = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // ── SÉLECTEUR D'AMBIANCE LUMINEUSE GAUCHE ────────────────────
                Positioned(
                  left: 16,
                  top: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _lighting == LightingEnvironment.soleilSahelien
                              ? Icons.wb_sunny_rounded
                              : _lighting == LightingEnvironment.crepuscule
                                  ? Icons.wb_twilight_rounded
                                  : Icons.nightlight_round,
                          size: 14,
                          color: CultureTheme.accentOrange,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getLightingLabel(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── POPUP D'INFORMATION DU POINT CHAUD ──────────────────────
                if (_activeHotspot != null)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 84,
                    child: _buildHotspotDetailCard(_activeHotspot!),
                  ),

                // ── BARRE INFÉRIEURE D'ACTIONS ──────────────────────────────
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 18,
                  child: Row(
                    children: [
                      // Bouton AR Mode
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            setState(() => _isArMode = !_isArMode);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF1E293B),
                                behavior: SnackBarBehavior.floating,
                                content: Row(
                                  children: [
                                    const Icon(Icons.view_in_ar_rounded, color: CultureTheme.accentOrange),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _isArMode
                                            ? 'Mode AR actif : Dirigez la caméra vers un sol plat.'
                                            : 'Mode 3D temps réel actif.',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isArMode
                                    ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                    : [CultureTheme.primaryBlue, const Color(0xFF253B82)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: CultureTheme.primaryBlue.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isArMode ? Icons.check_circle_rounded : Icons.view_in_ar_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isArMode ? 'AR Activée' : 'Ancrer en AR',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Bouton En Savoir Plus
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _showDossierArchitectural(context, target);
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: CultureTheme.accentOrange,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: CultureTheme.accentOrange.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.auto_stories_rounded, color: Colors.black, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'En savoir plus',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _cycleLighting() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_lighting == LightingEnvironment.soleilSahelien) {
        _lighting = LightingEnvironment.crepuscule;
      } else if (_lighting == LightingEnvironment.crepuscule) {
        _lighting = LightingEnvironment.nuitEtoilee;
      } else {
        _lighting = LightingEnvironment.soleilSahelien;
      }
    });
  }

  String _getLightingLabel() {
    switch (_lighting) {
      case LightingEnvironment.soleilSahelien:
        return 'Plein Soleil Sahélien';
      case LightingEnvironment.crepuscule:
        return 'Coucher de Soleil Ambré';
      case LightingEnvironment.nuitEtoilee:
        return 'Nuit Étoilée & Projecteurs';
    }
  }

  List<Color> _getBackgroundColors() {
    switch (_lighting) {
      case LightingEnvironment.soleilSahelien:
        return const [
          Color(0xFF1E293B),
          Color(0xFF0F172A),
          Color(0xFF070B14),
        ];
      case LightingEnvironment.crepuscule:
        return const [
          Color(0xFF3B1E1E),
          Color(0xFF1E1118),
          Color(0xFF0A060E),
        ];
      case LightingEnvironment.nuitEtoilee:
        return const [
          Color(0xFF0B172E),
          Color(0xFF070E1C),
          Color(0xFF03060B),
        ];
    }
  }

  Widget _buildProjected3DHotspot(Architectural3DHotspot hp) {
    // Calcul de projection 3D exacte du hotspot
    const double d = 420.0;
    // Rotation Y
    final double cosY = math.cos(_rotY);
    final double sinY = math.sin(_rotY);
    final double x1 = hp.x * cosY + hp.z * sinY;
    final double z1 = -hp.x * sinY + hp.z * cosY;

    // Rotation X
    final double cosX = math.cos(_rotX);
    final double sinX = math.sin(_rotX);
    final double y2 = hp.y * cosX - z1 * sinX;
    final double z2 = hp.y * sinX + z1 * cosX;

    // Masque si la facette est tournée vers l'arrière
    if (z2 < -60) return const SizedBox.shrink();

    final double proj = (d / (d + z2)) * _scale;
    final double screenX = x1 * proj;
    final double screenY = y2 * proj;

    final bool isSelected = _activeHotspot == hp;

    return Center(
      child: Transform.translate(
        offset: Offset(screenX, screenY),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _activeHotspot = isSelected ? null : hp;
              _autoRotate = false;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isSelected ? 38 : 30,
            height: isSelected ? 38 : 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.white : CultureTheme.accentOrange,
              border: Border.all(
                color: isSelected ? CultureTheme.accentOrange : Colors.white,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSelected ? Colors.white : CultureTheme.accentOrange).withValues(alpha: 0.8),
                  blurRadius: isSelected ? 16 : 8,
                  spreadRadius: isSelected ? 3 : 1,
                ),
              ],
            ),
            child: Icon(
              hp.icon,
              size: isSelected ? 20 : 16,
              color: isSelected ? CultureTheme.accentOrange : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotspotDetailCard(Architectural3DHotspot hp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131D33).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CultureTheme.accentOrange, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(hp.icon, color: CultureTheme.accentOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hp.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      hp.subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: CultureTheme.accentOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _activeHotspot = null),
                icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hp.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.45,
              color: const Color(0xFFE2E8F0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHudPill({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isActive
                ? CultureTheme.accentOrange
                : Colors.black.withValues(alpha: 0.65),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? CultureTheme.accentOrange
                  : Colors.white.withValues(alpha: 0.2),
            ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
            ],
          ),
          child: Icon(
            icon,
            size: 19,
            color: isActive ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  void _showDossierArchitectural(BuildContext context, MonumentScanTarget target) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dossier Architectural & Symbolique',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          target.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: CultureTheme.accentOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildDossierSection(
                      icon: Icons.foundation_rounded,
                      title: 'Matériaux & Génie Constructif',
                      content:
                          'Conçu pour résister aux amplitudes thermiques sahéliennes, cet édifice intègre des techniques bio-climatiques ancestrales et des matériaux locaux de haute tenue (latérite, grès rouge, banco stabilisé).',
                    ),
                    const SizedBox(height: 14),
                    _buildDossierSection(
                      icon: Icons.straighten_rounded,
                      title: 'Orientation Cosmique & Proportions',
                      content:
                          'L\'alignement avec la course du soleil et les axes fluviaux du fleuve Niger (Djoliba) confère au monument une présence magnétique et une aération naturelle optimale.',
                    ),
                    const SizedBox(height: 14),
                    _buildDossierSection(
                      icon: Icons.auto_stories_rounded,
                      title: 'Transmission & Récits Populaires',
                      content: target.historicalStory,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        VivienneTtsService.instance.speak(
                          '${target.name}. ${target.historicalStory}',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CultureTheme.accentOrange,
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.volume_up_rounded),
                      label: Text(
                        'Écouter la Narration Historique',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDossierSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: CultureTheme.accentOrange, size: 18),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              height: 1.5,
              color: const Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }
}

/// Peintre du podestat circulaire et de l'ombre d'occlusion ambiante
class _PedestalShadowPainter extends CustomPainter {
  final double rotX;
  final double scale;

  _PedestalShadowPainter({required this.rotX, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 130 * scale);
    final shadowRadiusX = 110.0 * scale;
    final shadowRadiusY = (34.0 + rotX * 14.0) * scale;

    // Ombre d'occlusion portée diffuse
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: shadowRadiusX * 2, height: shadowRadiusY * 2),
      shadowPaint,
    );

    // Disque de base en marbre / grès
    final diskPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2C394F),
          const Color(0xFF151D2C),
        ],
      ).createShader(Rect.fromCenter(center: center, width: shadowRadiusX * 1.6, height: shadowRadiusY * 1.6));
    canvas.drawOval(
      Rect.fromCenter(center: center, width: shadowRadiusX * 1.6, height: shadowRadiusY * 1.6),
      diskPaint,
    );

    // Cerclage métallique doré de base
    final ringPaint = Paint()
      ..color = CultureTheme.accentOrange.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: shadowRadiusX * 1.6, height: shadowRadiusY * 1.6),
      ringPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PedestalShadowPainter oldDelegate) =>
      oldDelegate.rotX != rotX || oldDelegate.scale != scale;
}

/// Peintre volumétrique 3D réaliste calculant la géométrie, normales et éclairage Phong
class _RealisticMonument3DPainter extends CustomPainter {
  final MonumentScanTarget target;
  final double rotX;
  final double rotY;
  final double scale;
  final Offset panOffset;
  final LightingEnvironment lighting;
  final bool showWireframe;

  _RealisticMonument3DPainter({
    required this.target,
    required this.rotX,
    required this.rotY,
    required this.scale,
    required this.panOffset,
    required this.lighting,
    required this.showWireframe,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2 + panOffset.dx, size.height / 2 + panOffset.dy);

    // Vecteur de lumière directionnel selon l'éclairage choisi
    final List<double> lightDir = _getLightDirection();

    // Génération des polygones du monument ciblé
    final List<PolygonFace3D> faces = _generateMonumentFaces(target);

    // Transformation 3D -> 2D avec tri par profondeur Z (Painter's Algorithm)
    final List<_ProjectedPolygon> projectedList = [];

    const double d = 420.0;
    final double cosY = math.cos(rotY);
    final double sinY = math.sin(rotY);
    final double cosX = math.cos(rotX);
    final double sinX = math.sin(rotX);

    for (final face in faces) {
      final List<Offset> screenPoints = [];
      double sumZ = 0.0;
      final List<List<double>> transformedVertices = [];

      for (final v in face.vertices) {
        // Rotation Y (azimut)
        final double x1 = v[0] * cosY + v[2] * sinY;
        final double z1 = -v[0] * sinY + v[2] * cosY;

        // Rotation X (élévation)
        final double y2 = v[1] * cosX - z1 * sinX;
        final double z2 = v[1] * sinX + z1 * cosX;

        transformedVertices.add([x1, y2, z2]);
        sumZ += z2;

        // Projection perspective
        final double proj = (d / (d + z2)) * scale;
        screenPoints.add(Offset(center.dx + x1 * proj, center.dy + y2 * proj));
      }

      final double avgZ = sumZ / face.vertices.length;

      // Calcul de la normale de surface
      if (transformedVertices.length >= 3) {
        final v0 = transformedVertices[0];
        final v1 = transformedVertices[1];
        final v2 = transformedVertices[2];

        final ab = [v1[0] - v0[0], v1[1] - v0[1], v1[2] - v0[2]];
        final ac = [v2[0] - v0[0], v2[1] - v0[1], v2[2] - v0[2]];

        // Produit vectoriel pour la normale
        double nx = ab[1] * ac[2] - ab[2] * ac[1];
        double ny = ab[2] * ac[0] - ab[0] * ac[2];
        double nz = ab[0] * ac[1] - ab[1] * ac[0];

        final len = math.sqrt(nx * nx + ny * ny + nz * nz);
        if (len > 0) {
          nx /= len;
          ny /= len;
          nz /= len;
        }

        // Back-face culling partiel (conserve pour le wireframe)
        if (nz <= 0 && !showWireframe) continue;

        // Éclairage diffus Lambertian : dot(N, L)
        final double dot = math.max(0.0, nx * lightDir[0] + ny * lightDir[1] + nz * lightDir[2]);
        final double ambient = (lighting == LightingEnvironment.nuitEtoilee) ? 0.20 : 0.35;
        final double intensity = (ambient + dot * 0.65).clamp(0.15, 1.0);

        final shadedColor = _applyShading(face.baseColor, intensity, face.roughness);

        projectedList.add(_ProjectedPolygon(
          points: screenPoints,
          avgZ: avgZ,
          fillColor: shadedColor,
          textureType: face.textureType,
        ));
      }
    }

    // Tri du fond vers l'avant (Z décroissant)
    projectedList.sort((a, b) => b.avgZ.compareTo(a.avgZ));

    // Dessin des polygones projetés
    for (final poly in projectedList) {
      final path = Path();
      if (poly.points.isNotEmpty) {
        path.moveTo(poly.points[0].dx, poly.points[0].dy);
        for (int i = 1; i < poly.points.length; i++) {
          path.lineTo(poly.points[i].dx, poly.points[i].dy);
        }
        path.close();
      }

      if (!showWireframe) {
        final fillPaint = Paint()
          ..color = poly.fillColor
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);

        // Arêtes subtiles pour rehausser la géométrie
        final borderPaint = Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawPath(path, borderPaint);
      } else {
        // Mode Écorché / Wireframe architectural
        final wirePaint = Paint()
          ..color = CultureTheme.accentOrange.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawPath(path, wirePaint);
      }
    }
  }

  List<double> _getLightDirection() {
    switch (lighting) {
      case LightingEnvironment.soleilSahelien:
        return [-0.55, -0.75, 0.45]; // Soleil haut à gauche
      case LightingEnvironment.crepuscule:
        return [-0.85, -0.30, 0.40]; // Lumière rasante ambrée
      case LightingEnvironment.nuitEtoilee:
        return [0.0, 0.90, 0.40];    // Projecteurs orientés du bas vers le haut
    }
  }

  Color _applyShading(Color base, double intensity, double roughness) {
    if (lighting == LightingEnvironment.crepuscule) {
      // Teinte chaude ambrée de coucher de soleil
      final r = (base.r * intensity * 1.15).clamp(0.0, 1.0);
      final g = (base.g * intensity * 0.90).clamp(0.0, 1.0);
      final b = (base.b * intensity * 0.70).clamp(0.0, 1.0);
      return Color.fromRGBO((r * 255).round(), (g * 255).round(), (b * 255).round(), 1.0);
    } else if (lighting == LightingEnvironment.nuitEtoilee) {
      // Teinte bleutée nocturne avec surbrillance dorée ponctuelle
      final r = (base.r * intensity * 0.85).clamp(0.0, 1.0);
      final g = (base.g * intensity * 0.95).clamp(0.0, 1.0);
      final b = (base.b * intensity * 1.20).clamp(0.0, 1.0);
      return Color.fromRGBO((r * 255).round(), (g * 255).round(), (b * 255).round(), 1.0);
    } else {
      // Rendu plein soleil
      final r = (base.r * intensity).clamp(0.0, 1.0);
      final g = (base.g * intensity).clamp(0.0, 1.0);
      final b = (base.b * intensity).clamp(0.0, 1.0);
      return Color.fromRGBO((r * 255).round(), (g * 255).round(), (b * 255).round(), 1.0);
    }
  }

  List<PolygonFace3D> _generateMonumentFaces(MonumentScanTarget target) {
    final id = target.id.toLowerCase();
    if (id.contains('tour_afrique')) {
      return _buildTourAfriqueFaces();
    } else if (id.contains('paix')) {
      return _buildMonumentPaixFaces();
    } else if (id.contains('ciwara')) {
      return _buildCiwaraFaces();
    } else if (id.contains('armee_noire')) {
      return _buildArmeeNoireFaces();
    } else if (id.contains('samory')) {
      return _buildSamoryToureFaces();
    } else if (id.contains('martyrs')) {
      return _buildMartyrsFaces();
    } else if (id.contains('nkrumah')) {
      return _buildKwameNkrumahFaces();
    } else if (id.contains('cathedrale')) {
      return _buildCathedraleFaces();
    } else if (id.contains('mosquee_bamako')) {
      return _buildMosqueeBamakoFaces();
    } else if (id.contains('sogolon')) {
      return _buildSogolonFaces();
    } else if (id.contains('quouds') || id.contains('qods')) {
      return _buildAlQudsFaces();
    } else if (id.contains('maliba')) {
      return _buildMalibaFaces();
    } else if (id.contains('obelisque')) {
      return _buildObelisqueFaces();
    } else if (id.contains('liberte')) {
      return _buildPlaceLiberteFaces();
    } else if (id.contains('musee_national')) {
      return _buildMuseeNationalFaces();
    } else if (id.contains('palais_culture')) {
      return _buildPalaisCultureFaces();
    } else if (id.contains('djenne')) {
      return _buildMosqueeDjenneFaces();
    } else if (id.contains('tombeau_askia') || id.contains('askia')) {
      return _buildTombeauAskiaFaces();
    } else if (id.contains('djingareyber')) {
      return _buildDjingareyberFaces();
    } else if (id.contains('sankore')) {
      return _buildSankoreFaces();
    } else if (id.contains('tata_sikasso') || id.contains('tata')) {
      return _buildTataSikassoFaces();
    } else if (id.contains('fort_medine') || id.contains('medine')) {
      return _buildFortMedineFaces();
    } else if (id.contains('segou')) {
      return _buildSegouFaces();
    } else if (id.contains('kamablon')) {
      return _buildKamablonFaces();
    } else if (id.contains('adrar')) {
      return _buildAdrarFaces();
    } else {
      // Monument de l'Indépendance ou style soudanais étagé
      return _buildIndependanceFaces();
    }
  }

  /// Géométrie 3D fidèle du Monument de l'Indépendance à Bamako
  List<PolygonFace3D> _buildIndependanceFaces() {
    final List<PolygonFace3D> faces = [];
    const stoneColor = Color(0xFFD6A76C); // Grès ocre doré
    const darkStone = Color(0xFFAC7C46);

    // 1. Base octogonale / carrée évasée (socle de cérémonie)
    faces.addAll(_buildBox(
      cx: 0, cy: 90, cz: 0,
      w: 120, h: 26, d: 120,
      color: darkStone,
    ));

    // 2. Étage intermédiaire avec arcades
    faces.addAll(_buildBox(
      cx: 0, cy: 62, cz: 0,
      w: 86, h: 32, d: 86,
      color: stoneColor,
    ));

    // 3. Obélisque / minaret tronconique élancé (3 sections effilées)
    // Section basse du tronc
    faces.addAll(_buildPyramidFrustum(
      yBottom: 46, yTop: -30,
      wBottom: 68, wTop: 48,
      color: stoneColor,
    ));

    // Section médiane avec frises géométriques
    faces.addAll(_buildPyramidFrustum(
      yBottom: -30, yTop: -100,
      wBottom: 48, wTop: 32,
      color: stoneColor,
    ));

    // Section haute
    faces.addAll(_buildPyramidFrustum(
      yBottom: -100, yTop: -145,
      wBottom: 32, wTop: 18,
      color: const Color(0xFFE2B880),
    ));

    // 4. Couronnement sommital pyramidal (flèche républicaine)
    faces.addAll([
      const PolygonFace3D(
        vertices: [
          [-9, -145, -9],
          [9, -145, -9],
          [0, -170, 0],
        ],
        baseColor: Color(0xFFF1851F),
      ),
      const PolygonFace3D(
        vertices: [
          [9, -145, -9],
          [9, -145, 9],
          [0, -170, 0],
        ],
        baseColor: Color(0xFFF1851F),
      ),
      const PolygonFace3D(
        vertices: [
          [9, -145, 9],
          [-9, -145, 9],
          [0, -170, 0],
        ],
        baseColor: Color(0xFFF1851F),
      ),
      const PolygonFace3D(
        vertices: [
          [-9, -145, 9],
          [-9, -145, -9],
          [0, -170, 0],
        ],
        baseColor: Color(0xFFF1851F),
      ),
    ]);

    return faces;
  }

  /// Géométrie 3D fidèle de la Tour de l'Afrique (Faladié, Bamako)
  List<PolygonFace3D> _buildTourAfriqueFaces() {
    final List<PolygonFace3D> faces = [];
    const concreteOcre = Color(0xFFBF8A52);
    const torchColor = Color(0xFFF59E0B);

    // 1. Base cylindrique circulaire
    faces.addAll(_buildCylinder(
      cx: 0, yBottom: 100, yTop: 75,
      radiusBottom: 85, radiusTop: 75,
      segments: 14,
      color: const Color(0xFF8B5A2B),
    ));

    // 2. Fût cannelé baobab (hauteur 46m modélisée en 2 tronçons)
    faces.addAll(_buildCylinder(
      cx: 0, yBottom: 75, yTop: -30,
      radiusBottom: 65, radiusTop: 45,
      segments: 14,
      color: concreteOcre,
    ));

    faces.addAll(_buildCylinder(
      cx: 0, yBottom: -30, yTop: -90,
      radiusBottom: 45, radiusTop: 38,
      segments: 14,
      color: concreteOcre,
    ));

    // 3. Plateforme panoramique circulaire en encorbellement
    faces.addAll(_buildCylinder(
      cx: 0, yBottom: -90, yTop: -108,
      radiusBottom: 58, radiusTop: 54,
      segments: 14,
      color: const Color(0xFF475569),
    ));

    // 4. Sommet et flamme stylisée
    faces.addAll(_buildCylinder(
      cx: 0, yBottom: -108, yTop: -130,
      radiusBottom: 30, radiusTop: 18,
      segments: 10,
      color: const Color(0xFF94A3B8),
    ));

    // Flamme dorée
    faces.addAll([
      const PolygonFace3D(
        vertices: [
          [-10, -130, 0],
          [10, -130, 0],
          [0, -170, 0],
        ],
        baseColor: torchColor,
      ),
      const PolygonFace3D(
        vertices: [
          [0, -130, -10],
          [0, -130, 10],
          [0, -170, 0],
        ],
        baseColor: torchColor,
      ),
    ]);

    return faces;
  }

  /// Géométrie 3D du Monument de la Paix (Hamdallaye ACI 2000)
  List<PolygonFace3D> _buildMonumentPaixFaces() {
    final List<PolygonFace3D> faces = [];
    const marbleWhite = Color(0xFFECEFF1);
    const doveSteel = Color(0xFFCFD8DC);

    // 1. Pyramide tronquée en marbre de Sélinkegny
    faces.addAll(_buildPyramidFrustum(
      yBottom: 100, yTop: 10,
      wBottom: 90, wTop: 40,
      color: marbleWhite,
    ));

    // 2. Colombe monumentale déployée (corps et ailes ajourées)
    // Corps
    faces.addAll(_buildBox(
      cx: 0, cy: -10, cz: 0,
      w: 22, h: 38, d: 36,
      color: doveSteel,
    ));

    // Aile gauche déployée vers le haut
    faces.add(const PolygonFace3D(
      vertices: [
        [-11, -15, 0],
        [-95, -115, 20],
        [-65, -85, -15],
      ],
      baseColor: Color(0xFFB0BEC5),
    ));
    faces.add(const PolygonFace3D(
      vertices: [
        [-11, -25, 0],
        [-120, -130, 25],
        [-95, -115, 20],
      ],
      baseColor: Colors.white,
    ));

    // Aile droite déployée vers le haut
    faces.add(const PolygonFace3D(
      vertices: [
        [11, -15, 0],
        [65, -85, -15],
        [95, -115, 20],
      ],
      baseColor: Color(0xFFB0BEC5),
    ));
    faces.add(const PolygonFace3D(
      vertices: [
        [11, -25, 0],
        [95, -115, 20],
        [120, -130, 25],
      ],
      baseColor: Colors.white,
    ));

    // Tête et bec levés vers le ciel
    faces.add(const PolygonFace3D(
      vertices: [
        [-6, -30, 10],
        [6, -30, 10],
        [0, -55, 24],
      ],
      baseColor: Colors.white,
    ));

    return faces;
  }

  /// Géométrie 3D du Masque Ciwara (Sénou, Bamako)
  List<PolygonFace3D> _buildCiwaraFaces() {
    final List<PolygonFace3D> faces = [];
    const woodDark = Color(0xFF5D4037);
    const goldHorn = Color(0xFFD7CCC8);

    // Socle
    faces.addAll(_buildBox(
      cx: 0, cy: 90, cz: 0,
      w: 80, h: 25, d: 80,
      color: const Color(0xFF3E2723),
    ));

    // Corps de l'antilope
    faces.addAll(_buildBox(
      cx: 0, cy: 50, cz: 0,
      w: 32, h: 55, d: 50,
      color: woodDark,
    ));

    // Crinière ajourée en dents de scie
    faces.add(const PolygonFace3D(
      vertices: [
        [0, 20, -15],
        [0, -40, -45],
        [0, -10, -5],
      ],
      baseColor: Color(0xFF8D6E63),
    ));

    // Grandes cornes recourbées en arc
    faces.add(const PolygonFace3D(
      vertices: [
        [-8, 0, 10],
        [-14, -80, 5],
        [-4, -150, -35],
      ],
      baseColor: goldHorn,
    ));
    faces.add(const PolygonFace3D(
      vertices: [
        [8, 0, 10],
        [4, -150, -35],
        [14, -80, 5],
      ],
      baseColor: goldHorn,
    ));

    return faces;
  }

  
  /// ── 5. Monument des Héros de l'Armée Noire (Place de la Liberté) ──────────
  List<PolygonFace3D> _buildArmeeNoireFaces() {
    final List<PolygonFace3D> faces = [];
    const stoneColor = Color(0xFFB0BEC5);
    const darkPlinth = Color(0xFF455A64);
    const bronzeStatue = Color(0xFF6D4C41);
    const goldBrass = Color(0xFFFFD54F);

    // Socle à degrés
    faces.addAll(_buildBox(cx: 0, cy: 95, cz: 0, w: 110, h: 20, d: 110, color: darkPlinth));
    faces.addAll(_buildBox(cx: 0, cy: 75, cz: 0, w: 85, h: 22, d: 85, color: stoneColor));
    faces.addAll(_buildBox(cx: 0, cy: 45, cz: 0, w: 60, h: 40, d: 60, color: darkPlinth));

    // Cartouche commémoratif frontal
    faces.addAll(_buildBox(cx: 0, cy: 45, cz: 31, w: 42, h: 24, d: 4, color: goldBrass));

    // Soldat central (porte-drapeau)
    faces.addAll(_buildBox(cx: 0, cy: 0, cz: 0, w: 22, h: 50, d: 18, color: bronzeStatue));
    faces.addAll(_buildBox(cx: 0, cy: -32, cz: 0, w: 12, h: 14, d: 12, color: bronzeStatue));

    // Soldats camarades latéraux
    faces.addAll(_buildBox(cx: -22, cy: 10, cz: 4, w: 18, h: 42, d: 16, color: bronzeStatue));
    faces.addAll(_buildBox(cx: 22, cy: 10, cz: 4, w: 18, h: 42, d: 16, color: bronzeStatue));

    // Fusils et hampe du drapeau
    faces.addAll(_buildCylinder(cx: 8, yBottom: 30, yTop: -80, radiusBottom: 2.5, radiusTop: 2.0, segments: 6, color: bronzeStatue));

    // Pavillon flottant
    faces.add(const PolygonFace3D(
      vertices: [
        [8, -80, 0],
        [45, -70, 8],
        [40, -50, 4],
        [8, -55, 0],
      ],
      baseColor: Color(0xFFE53935),
    ));

    return faces;
  }

  /// ── 6. Monument Almamy Samory Touré (Sébénikoro) ───────────────────────────
  List<PolygonFace3D> _buildSamoryToureFaces() {
    final List<PolygonFace3D> faces = [];
    const stoneBastion = Color(0xFF78909C);
    const bronzeHorse = Color(0xFF4E342E);
    const bronzeRider = Color(0xFF6D4C41);
    const goldSaber = Color(0xFFFFD54F);

    // Bastion de pierre
    faces.addAll(_buildBox(cx: 0, cy: 95, cz: 0, w: 120, h: 22, d: 90, color: const Color(0xFF37474F)));
    faces.addAll(_buildBox(cx: 0, cy: 68, cz: 0, w: 90, h: 34, d: 65, color: stoneBastion));

    // Cheval cabré (corps, cou, tête, pattes)
    faces.addAll(_buildBox(cx: 0, cy: 25, cz: -5, w: 26, h: 32, d: 60, color: bronzeHorse));
    faces.addAll(_buildBox(cx: 0, cy: -5, cz: 20, w: 16, h: 36, d: 24, color: bronzeHorse));
    faces.addAll(_buildBox(cx: 0, cy: -28, cz: 30, w: 12, h: 18, d: 20, color: bronzeHorse));
    faces.addAll(_buildBox(cx: -8, cy: -10, cz: 42, w: 6, h: 28, d: 6, color: bronzeHorse));
    faces.addAll(_buildBox(cx: 8, cy: -10, cz: 42, w: 6, h: 28, d: 6, color: bronzeHorse));
    faces.addAll(_buildBox(cx: -10, cy: 58, cz: -22, w: 8, h: 36, d: 10, color: bronzeHorse));
    faces.addAll(_buildBox(cx: 10, cy: 58, cz: -22, w: 8, h: 36, d: 10, color: bronzeHorse));

    // Cavalier Almamy Samory Touré
    faces.addAll(_buildBox(cx: 0, cy: -15, cz: 0, w: 20, h: 30, d: 18, color: bronzeRider));
    faces.addAll(_buildBox(cx: 0, cy: -38, cz: 2, w: 14, h: 16, d: 14, color: bronzeRider));

    // Sabre brandi vers le ciel
    faces.addAll(_buildBox(cx: 14, cy: -50, cz: 8, w: 4, h: 34, d: 4, color: goldSaber));

    // Cape flottante
    faces.add(const PolygonFace3D(
      vertices: [
        [-10, -25, -5],
        [10, -25, -5],
        [20, 15, -45],
        [-20, 15, -45],
      ],
      baseColor: Color(0xFF3E2723),
    ));

    return faces;
  }

  /// ── 7. Monument des Martyrs (Pont des Martyrs) ────────────────────────────
  List<PolygonFace3D> _buildMartyrsFaces() {
    final List<PolygonFace3D> faces = [];
    const whiteMarble = Color(0xFFECEFF1);
    const redGranite = Color(0xFFC2185B);
    const goldFlame = Color(0xFFFFB300);

    // Esplanade fluviale
    faces.addAll(_buildBox(cx: 0, cy: 95, cz: 0, w: 130, h: 18, d: 90, color: const Color(0xFF455A64)));

    // Grande arche républicaine (Pylône gauche, droit et traverse)
    faces.addAll(_buildBox(cx: -55, cy: 20, cz: 0, w: 22, h: 130, d: 35, color: whiteMarble));
    faces.addAll(_buildBox(cx: 55, cy: 20, cz: 0, w: 22, h: 130, d: 35, color: whiteMarble));
    faces.addAll(_buildBox(cx: 0, cy: -45, cz: 0, w: 132, h: 22, d: 35, color: whiteMarble));
    faces.addAll(_buildBox(cx: 0, cy: -45, cz: 18, w: 100, h: 12, d: 3, color: const Color(0xFFFFD54F)));

    // Stèle centrale de la Flamme
    faces.addAll(_buildBox(cx: 0, cy: 75, cz: 0, w: 32, h: 22, d: 32, color: redGranite));
    faces.addAll(_buildPyramidFrustum(yBottom: 64, yTop: 5, wBottom: 22, wTop: 14, color: redGranite));

    // Flamme démocratique
    faces.add(const PolygonFace3D(
      vertices: [
        [-6, 5, 0],
        [6, 5, 0],
        [0, -25, 0],
      ],
      baseColor: goldFlame,
    ));

    return faces;
  }

  /// ── 8. Monument Kwamé Nkrumah (Avenue Nkrumah) ─────────────────────────────
  List<PolygonFace3D> _buildKwameNkrumahFaces() {
    final List<PolygonFace3D> faces = [];
    const basaltBlack = Color(0xFF212121);
    const bronzeBust = Color(0xFF8D6E63);
    const goldMedallion = Color(0xFFFFD54F);

    // Socle en granit noir poli
    faces.addAll(_buildBox(cx: 0, cy: 95, cz: 0, w: 90, h: 18, d: 90, color: const Color(0xFF1E293B)));
    faces.addAll(_buildBox(cx: 0, cy: 45, cz: 0, w: 55, h: 80, d: 55, color: basaltBlack));
    faces.addAll(_buildBox(cx: 0, cy: 50, cz: 28, w: 30, h: 30, d: 4, color: goldMedallion));

    // Buste de Kwamé Nkrumah
    faces.addAll(_buildBox(cx: 0, cy: -5, cz: 0, w: 46, h: 24, d: 26, color: bronzeBust));
    faces.addAll(_buildBox(cx: 0, cy: -22, cz: 0, w: 18, h: 14, d: 18, color: bronzeBust));
    faces.addAll(_buildBox(cx: 0, cy: -40, cz: 2, w: 24, h: 26, d: 24, color: bronzeBust));

    return faces;
  }

  /// ── 9. Cathédrale du Sacré-Cœur de Bamako ──────────────────────────────────
  List<PolygonFace3D> _buildCathedraleFaces() {
    final List<PolygonFace3D> faces = [];
    const sandstone = Color(0xFFD4A373);
    const darkSandstone = Color(0xFFBC6C25);
    const tileRed = Color(0xFF933321);

    // Nef centrale
    faces.addAll(_buildBox(cx: 0, cy: 50, cz: -15, w: 75, h: 80, d: 95, color: sandstone));

    // Toiture inclinée
    faces.add(const PolygonFace3D(
      vertices: [
        [-38, 10, -62],
        [0, -25, -62],
        [0, -25, 32],
        [-38, 10, 32],
      ],
      baseColor: tileRed,
    ));
    faces.add(const PolygonFace3D(
      vertices: [
        [38, 10, -62],
        [38, 10, 32],
        [0, -25, 32],
        [0, -25, -62],
      ],
      baseColor: tileRed,
    ));

    // Clocher Gauche
    faces.addAll(_buildBox(cx: -36, cy: 10, cz: 35, w: 26, h: 155, d: 26, color: sandstone));
    faces.addAll(_buildBox(cx: -36, cy: -75, cz: 35, w: 22, h: 20, d: 22, color: darkSandstone));
    faces.addAll(_buildPyramidFrustum(yBottom: -85, yTop: -125, wBottom: 24, wTop: 4, color: tileRed));

    // Clocher Droit
    faces.addAll(_buildBox(cx: 36, cy: 10, cz: 35, w: 26, h: 155, d: 26, color: sandstone));
    faces.addAll(_buildBox(cx: 36, cy: -75, cz: 35, w: 22, h: 20, d: 22, color: darkSandstone));
    faces.addAll(_buildPyramidFrustum(yBottom: -85, yTop: -125, wBottom: 24, wTop: 4, color: tileRed));

    // Rosace centrale
    faces.addAll(_buildBox(cx: 0, cy: 15, cz: 34, w: 24, h: 24, d: 3, color: const Color(0xFF0288D1)));

    return faces;
  }

  /// ── 10. Grande Mosquée de Bamako (Dabanani) ────────────────────────────────
  List<PolygonFace3D> _buildMosqueeBamakoFaces() {
    final List<PolygonFace3D> faces = [];
    const whiteWall = Color(0xFFF8FAFC);
    const greenTrim = Color(0xFF15803D);

    // Salle de prière principale
    faces.addAll(_buildBox(cx: 0, cy: 55, cz: 0, w: 90, h: 65, d: 90, color: whiteWall));
    faces.addAll(_buildBox(cx: 0, cy: 55, cz: 48, w: 70, h: 45, d: 15, color: whiteWall));

    // Coupole centrale verte
    faces.addAll(_buildCylinder(cx: 0, yBottom: 22, yTop: 8, radiusBottom: 32, radiusTop: 24, segments: 12, color: greenTrim));
    faces.addAll(_buildPyramidFrustum(yBottom: 8, yTop: -20, wBottom: 28, wTop: 6, color: greenTrim));

    // Minaret Gauche
    faces.addAll(_buildBox(cx: -48, cy: -10, cz: 45, w: 18, h: 195, d: 18, color: whiteWall));
    faces.addAll(_buildBox(cx: -48, cy: -115, cz: 45, w: 24, h: 14, d: 24, color: greenTrim));
    faces.addAll(_buildPyramidFrustum(yBottom: -122, yTop: -150, wBottom: 14, wTop: 4, color: whiteWall));

    // Minaret Droit
    faces.addAll(_buildBox(cx: 48, cy: -10, cz: 45, w: 18, h: 195, d: 18, color: whiteWall));
    faces.addAll(_buildBox(cx: 48, cy: -115, cz: 45, w: 24, h: 14, d: 24, color: greenTrim));
    faces.addAll(_buildPyramidFrustum(yBottom: -122, yTop: -150, wBottom: 14, wTop: 4, color: whiteWall));

    return faces;
  }

  /// ── 11. Statue de Sogolon Kolonkan (ACI 2000) ──────────────────────────────
  List<PolygonFace3D> _buildSogolonFaces() {
    final List<PolygonFace3D> faces = [];
    const ochreBase = Color(0xFFD97706);
    const bronzeStatue = Color(0xFF78350F);
    const goldBrass = Color(0xFFFFD54F);

    // Socle Mandé
    faces.addAll(_buildBox(cx: 0, cy: 85, cz: 0, w: 75, h: 26, d: 75, color: const Color(0xFF92400E)));
    faces.addAll(_buildBox(cx: 0, cy: 62, cz: 0, w: 55, h: 22, d: 55, color: ochreBase));

    // Statue féminine royale
    faces.addAll(_buildPyramidFrustum(yBottom: 51, yTop: 5, wBottom: 42, wTop: 24, color: bronzeStatue));
    faces.addAll(_buildBox(cx: 0, cy: -15, cz: 0, w: 22, h: 32, d: 18, color: bronzeStatue));
    faces.addAll(_buildBox(cx: 0, cy: -40, cz: 0, w: 14, h: 18, d: 14, color: bronzeStatue));
    faces.addAll(_buildBox(cx: 0, cy: -53, cz: 0, w: 18, h: 10, d: 18, color: goldBrass));

    // Calebasse sacrée tenue devant
    faces.addAll(_buildCylinder(cx: 0, yBottom: 0, yTop: -14, radiusBottom: 10, radiusTop: 14, segments: 10, color: goldBrass));

    return faces;
  }

  /// ── 12. Monument Al-Qoods (Al-Qods) ───────────────────────────────────────
  List<PolygonFace3D> _buildAlQudsFaces() {
    final List<PolygonFace3D> faces = [];
    const goldDome = Color(0xFFFFD700);
    const arcadeBlue = Color(0xFF0284C7);

    // Rond-point
    faces.addAll(_buildCylinder(cx: 0, yBottom: 100, yTop: 80, radiusBottom: 85, radiusTop: 78, segments: 12, color: const Color(0xFF64748B)));

    // Pavillon octogonal aux arcades orientales
    faces.addAll(_buildCylinder(cx: 0, yBottom: 80, yTop: 10, radiusBottom: 60, radiusTop: 55, segments: 8, color: arcadeBlue));
    faces.addAll(_buildCylinder(cx: 0, yBottom: 10, yTop: -5, radiusBottom: 62, radiusTop: 62, segments: 8, color: goldDome));

    // Coupole dorée étincelante
    faces.addAll(_buildCylinder(cx: 0, yBottom: -5, yTop: -35, radiusBottom: 50, radiusTop: 42, segments: 12, color: goldDome));
    faces.addAll(_buildCylinder(cx: 0, yBottom: -35, yTop: -65, radiusBottom: 42, radiusTop: 24, segments: 12, color: goldDome));
    faces.addAll(_buildPyramidFrustum(yBottom: -65, yTop: -95, wBottom: 30, wTop: 6, color: goldDome));

    return faces;
  }

  /// ── 13. Monument MaliBa (Grand Mali) ───────────────────────────────────────
  List<PolygonFace3D> _buildMalibaFaces() {
    final List<PolygonFace3D> faces = [];
    const greenMali = Color(0xFF00E676);
    const yellowMali = Color(0xFFFFD600);
    const redMali = Color(0xFFE53935);

    // Podium paysager
    faces.addAll(_buildBox(cx: 0, cy: 90, cz: 0, w: 140, h: 20, d: 65, color: const Color(0xFF334155)));
    faces.addAll(_buildBox(cx: 0, cy: 74, cz: 0, w: 130, h: 14, d: 55, color: const Color(0xFF475569)));

    // Lettres 3D « M A L I B A »
    faces.addAll(_buildBox(cx: -55, cy: 25, cz: 0, w: 18, h: 70, d: 18, color: greenMali));
    faces.addAll(_buildBox(cx: -33, cy: 25, cz: 0, w: 18, h: 70, d: 18, color: greenMali));
    faces.addAll(_buildBox(cx: -11, cy: 25, cz: 0, w: 16, h: 70, d: 18, color: yellowMali));
    faces.addAll(_buildBox(cx: 8, cy: 25, cz: 0, w: 12, h: 70, d: 18, color: yellowMali));
    faces.addAll(_buildBox(cx: 28, cy: 25, cz: 0, w: 18, h: 70, d: 18, color: redMali));
    faces.addAll(_buildBox(cx: 52, cy: 25, cz: 0, w: 18, h: 70, d: 18, color: redMali));

    // Mât de drapeau
    faces.addAll(_buildCylinder(cx: 74, yBottom: 80, yTop: -80, radiusBottom: 2.5, radiusTop: 2.0, segments: 6, color: Colors.white));

    return faces;
  }

  /// ── 14. Obélisque de Bamako ────────────────────────────────────────────────
  List<PolygonFace3D> _buildObelisqueFaces() {
    final List<PolygonFace3D> faces = [];
    const granitePink = Color(0xFFD4A373);
    const graniteDark = Color(0xFF8D5B4C);

    // Socle à 3 degrés
    faces.addAll(_buildBox(cx: 0, cy: 95, cz: 0, w: 90, h: 18, d: 90, color: graniteDark));
    faces.addAll(_buildBox(cx: 0, cy: 77, cz: 0, w: 68, h: 18, d: 68, color: granitePink));
    faces.addAll(_buildBox(cx: 0, cy: 59, cz: 0, w: 50, h: 18, d: 50, color: granitePink));

    // Fût monolithique élancé
    faces.addAll(_buildPyramidFrustum(yBottom: 50, yTop: -30, wBottom: 38, wTop: 28, color: granitePink));
    faces.addAll(_buildPyramidFrustum(yBottom: -30, yTop: -120, wBottom: 28, wTop: 18, color: granitePink));

    // Pyramidion doré sommital
    faces.add(const PolygonFace3D(
      vertices: [
        [-9, -120, -9],
        [9, -120, -9],
        [0, -160, 0],
      ],
      baseColor: Color(0xFFFFD54F),
    ));
    faces.add(const PolygonFace3D(
      vertices: [
        [9, -120, -9],
        [9, -120, 9],
        [0, -160, 0],
      ],
      baseColor: Color(0xFFFFD54F),
    ));
    faces.add(const PolygonFace3D(
      vertices: [
        [9, -120, 9],
        [-9, -120, 9],
        [0, -160, 0],
      ],
      baseColor: Color(0xFFFFD54F),
    ));
    faces.add(const PolygonFace3D(
      vertices: [
        [-9, -120, 9],
        [-9, -120, -9],
        [0, -160, 0],
      ],
      baseColor: Color(0xFFFFD54F),
    ));

    return faces;
  }

  /// ── 15. Place de la Liberté (Esplanade centrale) ───────────────────────────
  List<PolygonFace3D> _buildPlaceLiberteFaces() {
    final List<PolygonFace3D> faces = [];
    const pavingGray = Color(0xFF94A3B8);
    const lawnGreen = Color(0xFF2E7D32);
    const waterBlue = Color(0xFF0288D1);
    const stoneCol = Color(0xFFCBD5E1);

    // Esplanade circulaire et pelouse
    faces.addAll(_buildCylinder(cx: 0, yBottom: 100, yTop: 92, radiusBottom: 100, radiusTop: 98, segments: 14, color: pavingGray));
    faces.addAll(_buildCylinder(cx: 0, yBottom: 92, yTop: 86, radiusBottom: 85, radiusTop: 82, segments: 14, color: lawnGreen));
    faces.addAll(_buildCylinder(cx: 0, yBottom: 86, yTop: 78, radiusBottom: 60, radiusTop: 58, segments: 14, color: waterBlue));

    // Colonne civique centrale
    faces.addAll(_buildCylinder(cx: 0, yBottom: 78, yTop: -20, radiusBottom: 14, radiusTop: 10, segments: 10, color: stoneCol));
    faces.addAll(_buildPyramidFrustum(yBottom: -20, yTop: -45, wBottom: 16, wTop: 4, color: const Color(0xFFFFD54F)));

    // 4 colonnes d'angle républicaines
    faces.addAll(_buildCylinder(cx: -55, yBottom: 86, yTop: 20, radiusBottom: 6, radiusTop: 5, segments: 8, color: stoneCol));
    faces.addAll(_buildCylinder(cx: 55, yBottom: 86, yTop: 20, radiusBottom: 6, radiusTop: 5, segments: 8, color: stoneCol));
    faces.addAll(_buildCylinder(cx: 0, yBottom: 86, yTop: 20, radiusBottom: 6, radiusTop: 5, segments: 8, color: stoneCol));

    return faces;
  }

  /// ── 16. Musée National du Mali (Koulouba) ──────────────────────────────────
  List<PolygonFace3D> _buildMuseeNationalFaces() {
    final List<PolygonFace3D> faces = [];
    const bancoRed = Color(0xFFB45309);
    const woodRoof = Color(0xFF78350F);
    const gardenGreen = Color(0xFF15803D);

    // Sol et jardins
    faces.addAll(_buildBox(cx: 0, cy: 95, cz: 0, w: 130, h: 16, d: 90, color: gardenGreen));

    // Pavillon principal en terre cuite stabilisée
    faces.addAll(_buildBox(cx: -25, cy: 60, cz: 0, w: 65, h: 54, d: 65, color: bancoRed));
    faces.addAll(_buildBox(cx: -25, cy: 30, cz: 0, w: 80, h: 8, d: 80, color: woodRoof));

    // Pavillon secondaire relié par colonnade
    faces.addAll(_buildBox(cx: 40, cy: 65, cz: 10, w: 45, h: 44, d: 45, color: bancoRed));
    faces.addAll(_buildBox(cx: 40, cy: 40, cz: 10, w: 55, h: 6, d: 55, color: woodRoof));

    // Piliers de galerie ouverte
    faces.addAll(_buildBox(cx: 5, cy: 62, cz: 25, w: 6, h: 50, d: 6, color: bancoRed));
    faces.addAll(_buildBox(cx: 5, cy: 62, cz: -15, w: 6, h: 50, d: 6, color: bancoRed));

    return faces;
  }

  /// ── 17. Palais de la Culture Amadou Hampâté Bâ ──────────────────────────────
  List<PolygonFace3D> _buildPalaisCultureFaces() {
    final List<PolygonFace3D> faces = [];
    const riverBlue = Color(0xFF0284C7);
    const shellWhite = Color(0xFFF1F5F9);
    const tierGray = Color(0xFF64748B);

    // Berges du Djoliba
    faces.addAll(_buildBox(cx: 0, cy: 95, cz: 0, w: 140, h: 16, d: 90, color: riverBlue));

    // Gradins étagés en hémicycle
    faces.addAll(_buildCylinder(cx: 0, yBottom: 87, yTop: 72, radiusBottom: 80, radiusTop: 72, segments: 12, color: tierGray));
    faces.addAll(_buildCylinder(cx: 0, yBottom: 72, yTop: 57, radiusBottom: 68, radiusTop: 60, segments: 12, color: tierGray));
    faces.addAll(_buildCylinder(cx: 0, yBottom: 57, yTop: 42, radiusBottom: 56, radiusTop: 48, segments: 12, color: tierGray));

    // Scène et coque acoustique géante
    faces.addAll(_buildBox(cx: 0, cy: 42, cz: 25, w: 55, h: 12, d: 35, color: const Color(0xFF334155)));
    faces.addAll(_buildCylinder(cx: 0, yBottom: 36, yTop: -30, radiusBottom: 38, radiusTop: 28, segments: 8, color: shellWhite));

    return faces;
  }

  /// ── 18. Grande Mosquée de Djenné ───────────────────────────────────────────
  List<PolygonFace3D> _buildMosqueeDjenneFaces() {
    final List<PolygonFace3D> faces = [];
    const bancoColor = Color(0xFFB58852);
    const darkBanco = Color(0xFF8B6538);
    const toronColor = Color(0xFF3E2723);

    // Plateforme surélevée
    faces.addAll(_buildBox(cx: 0, cy: 95, cz: 0, w: 130, h: 20, d: 90, color: darkBanco));

    // Façade monumentale
    faces.addAll(_buildBox(cx: 0, cy: 45, cz: 0, w: 105, h: 80, d: 65, color: bancoColor));

    // Minaret Central
    faces.addAll(_buildPyramidFrustum(yBottom: 25, yTop: -90, wBottom: 24, wTop: 15, color: bancoColor));
    faces.addAll(_buildBox(cx: 0, cy: -96, cz: 0, w: 7, h: 10, d: 7, color: Colors.white));

    // Minaret Ouest
    faces.addAll(_buildPyramidFrustum(yBottom: 25, yTop: -80, wBottom: 20, wTop: 13, color: bancoColor));
    faces.addAll(_buildBox(cx: -38, cy: -86, cz: 0, w: 6, h: 8, d: 6, color: Colors.white));

    // Minaret Est
    faces.addAll(_buildPyramidFrustum(yBottom: 25, yTop: -80, wBottom: 20, wTop: 13, color: bancoColor));
    faces.addAll(_buildBox(cx: 38, cy: -86, cz: 0, w: 6, h: 8, d: 6, color: Colors.white));

    // Torons de palmier saillants
    faces.addAll(_buildBox(cx: -18, cy: -15, cz: 36, w: 3, h: 3, d: 14, color: toronColor));
    faces.addAll(_buildBox(cx: 18, cy: -15, cz: 36, w: 3, h: 3, d: 14, color: toronColor));
    faces.addAll(_buildBox(cx: 0, cy: -45, cz: 36, w: 3, h: 3, d: 14, color: toronColor));

    return faces;
  }

  /// ── 19. Tombeau des Askia (Gao) ────────────────────────────────────────────
  List<PolygonFace3D> _buildTombeauAskiaFaces() {
    final List<PolygonFace3D> faces = [];
    const adobeBanco = Color(0xFFA67B48);
    const groundMud = Color(0xFF78552D);
    const branchColor = Color(0xFF3E2723);

    // Sol désertique
    faces.addAll(_buildBox(cx: 0, cy: 95, cz: 0, w: 120, h: 18, d: 120, color: groundMud));

    // Pyramide tronquée à 3 degrés
    faces.addAll(_buildPyramidFrustum(yBottom: 86, yTop: 35, wBottom: 95, wTop: 72, color: adobeBanco));
    faces.addAll(_buildPyramidFrustum(yBottom: 35, yTop: -20, wBottom: 72, wTop: 48, color: adobeBanco));
    faces.addAll(_buildPyramidFrustum(yBottom: -20, yTop: -80, wBottom: 48, wTop: 24, color: adobeBanco));
    faces.addAll(_buildBox(cx: 0, cy: -86, cz: 0, w: 16, h: 12, d: 16, color: groundMud));

    // Échafaudages en branches d'acacia saillantes
    faces.addAll(_buildBox(cx: 0, cy: 20, cz: 42, w: 4, h: 4, d: 16, color: branchColor));
    faces.addAll(_buildBox(cx: -25, cy: -10, cz: 30, w: 4, h: 4, d: 16, color: branchColor));
    faces.addAll(_buildBox(cx: 25, cy: -10, cz: 30, w: 4, h: 4, d: 16, color: branchColor));
    faces.addAll(_buildBox(cx: 0, cy: -50, cz: 18, w: 4, h: 4, d: 14, color: branchColor));

    return faces;
  }

  /// ── 20. Mosquée Djingareyber (Tombouctou) ──────────────────────────────────
  List<PolygonFace3D> _buildDjingareyberFaces() {
    final List<PolygonFace3D> faces = [];
    const tombouctouEarth = Color(0xFFB38955);
    const minaretEarth = Color(0xFF9E7441);
    const woodBeams = Color(0xFF4A3525);

    // Grande nef en terre crue et pierres d'alchor
    faces.addAll(_buildBox(cx: 20, cy: 55, cz: 0, w: 85, h: 65, d: 85, color: tombouctouEarth));

    // Grand minaret conique de Mansa Moussa
    faces.addAll(_buildCylinder(cx: -32, yBottom: 85, yTop: 15, radiusBottom: 28, radiusTop: 20, segments: 10, color: minaretEarth));
    faces.addAll(_buildCylinder(cx: -32, yBottom: 15, yTop: -90, radiusBottom: 20, radiusTop: 10, segments: 10, color: minaretEarth));
    faces.addAll(_buildPyramidFrustum(yBottom: -90, yTop: -125, wBottom: 16, wTop: 3, color: tombouctouEarth));

    // Poutres de bois traversantes
    faces.addAll(_buildBox(cx: -32, cy: -40, cz: 0, w: 30, h: 3, d: 3, color: woodBeams));
    faces.addAll(_buildBox(cx: -32, cy: -10, cz: 0, w: 36, h: 3, d: 3, color: woodBeams));

    return faces;
  }

  /// ── 21. Université & Mosquée de Sankoré (Tombouctou) ───────────────────────
  List<PolygonFace3D> _buildSankoreFaces() {
    final List<PolygonFace3D> faces = [];
    const sankoreGold = Color(0xFFA88250);
    const stoneEarth = Color(0xFF8C6839);

    // Cour des manuscrits
    faces.addAll(_buildBox(cx: 15, cy: 60, cz: 0, w: 80, h: 60, d: 80, color: sankoreGold));

    // Minaret à gradins (proportions de la Kaaba)
    faces.addAll(_buildBox(cx: -30, cy: 45, cz: 25, w: 42, h: 48, d: 42, color: sankoreGold));
    faces.addAll(_buildBox(cx: -30, cy: 0, cz: 25, w: 32, h: 42, d: 32, color: sankoreGold));
    faces.addAll(_buildBox(cx: -30, cy: -40, cz: 25, w: 22, h: 38, d: 22, color: sankoreGold));
    faces.addAll(_buildPyramidFrustum(yBottom: -59, yTop: -95, wBottom: 16, wTop: 4, color: stoneEarth));

    return faces;
  }

  /// ── 22. Tata de Sikasso ───────────────────────────────────────────────────
  List<PolygonFace3D> _buildTataSikassoFaces() {
    final List<PolygonFace3D> faces = [];
    const wallLaterite = Color(0xFF8D5832);
    const bastionDark = Color(0xFF5D4037);

    // Soubassement
    faces.addAll(_buildBox(cx: 0, cy: 90, cz: 0, w: 130, h: 22, d: 75, color: bastionDark));

    // Muraille défensive
    faces.addAll(_buildBox(cx: 0, cy: 45, cz: 0, w: 120, h: 68, d: 40, color: wallLaterite));

    // Tours de guet circulaires d'angle
    faces.addAll(_buildCylinder(cx: -58, yBottom: 85, yTop: -10, radiusBottom: 18, radiusTop: 15, segments: 8, color: const Color(0xFF794624)));
    faces.addAll(_buildCylinder(cx: 58, yBottom: 85, yTop: -10, radiusBottom: 18, radiusTop: 15, segments: 8, color: const Color(0xFF794624)));

    // Porte fortifiée
    faces.addAll(_buildBox(cx: 0, cy: 55, cz: 22, w: 28, h: 45, d: 6, color: const Color(0xFF3E2723)));

    return faces;
  }

  /// ── 23. Fort de Médine (Kayes) ─────────────────────────────────────────────
  List<PolygonFace3D> _buildFortMedineFaces() {
    final List<PolygonFace3D> faces = [];
    const fortSandstone = Color(0xFFA84A33);
    const darkFort = Color(0xFF7E3827);

    // Bastion de pierre
    faces.addAll(_buildBox(cx: 0, cy: 90, cz: 0, w: 125, h: 22, d: 85, color: darkFort));
    faces.addAll(_buildBox(cx: 0, cy: 45, cz: 0, w: 110, h: 68, d: 70, color: fortSandstone));

    // Échauguettes d'angle
    faces.addAll(_buildBox(cx: -52, cy: 0, cz: 32, w: 16, h: 32, d: 16, color: darkFort));
    faces.addAll(_buildBox(cx: 52, cy: 0, cz: 32, w: 16, h: 32, d: 16, color: darkFort));

    return faces;
  }

  /// ── 24. Ségou-Koro & Balanzans ─────────────────────────────────────────────
  List<PolygonFace3D> _buildSegouFaces() {
    final List<PolygonFace3D> faces = [];
    const palaceBanco = Color(0xFFA1887F);
    const darkWood = Color(0xFF4E342E);
    const treeGreen = Color(0xFF2E7D32);

    // Vestibule royal de Bitòn Coulibaly
    faces.addAll(_buildBox(cx: -15, cy: 90, cz: 0, w: 95, h: 22, d: 65, color: const Color(0xFF8D6E63)));
    faces.addAll(_buildBox(cx: -15, cy: 45, cz: 0, w: 85, h: 68, d: 55, color: palaceBanco));
    faces.addAll(_buildBox(cx: -45, cy: 20, cz: 28, w: 14, h: 90, d: 14, color: const Color(0xFF6D4C41)));
    faces.addAll(_buildBox(cx: 15, cy: 20, cz: 28, w: 14, h: 90, d: 14, color: const Color(0xFF6D4C41)));

    // Balanzan sacré tutélaire
    faces.addAll(_buildCylinder(cx: 48, yBottom: 85, yTop: 0, radiusBottom: 9, radiusTop: 6, segments: 8, color: darkWood));
    faces.addAll(_buildCylinder(cx: 48, yBottom: 5, yTop: -65, radiusBottom: 32, radiusTop: 12, segments: 10, color: treeGreen));

    return faces;
  }

  /// ── 25. Sanctuaire Kamablon de Kangaba ─────────────────────────────────────
  List<PolygonFace3D> _buildKamablonFaces() {
    final List<PolygonFace3D> faces = [];
    const mudSanctuary = Color(0xFFBCAAA4);
    const thatchRoof = Color(0xFFD7CCC8);

    // Hutte sacrée ronde
    faces.addAll(_buildCylinder(cx: 0, yBottom: 90, yTop: 20, radiusBottom: 55, radiusTop: 52, segments: 14, color: mudSanctuary));

    // Toit de chaume conique réfectionné tous les sept ans
    faces.addAll(_buildCylinder(cx: 0, yBottom: 20, yTop: -25, radiusBottom: 68, radiusTop: 45, segments: 14, color: thatchRoof));
    faces.addAll(_buildPyramidFrustum(yBottom: -25, yTop: -85, wBottom: 50, wTop: 6, color: thatchRoof));

    return faces;
  }

  /// ── 26. Adrar des Ifoghas (Massif Saharien) ────────────────────────────────
  List<PolygonFace3D> _buildAdrarFaces() {
    final List<PolygonFace3D> faces = [];
    const desertSand = Color(0xFFE0C49F);
    const graniteRock = Color(0xFF616161);

    // Plateau rocheux désertique
    faces.addAll(_buildBox(cx: 0, cy: 95, cz: 0, w: 130, h: 18, d: 90, color: desertSand));

    // Massif granitique aux gravures rupestres
    faces.addAll(_buildPyramidFrustum(yBottom: 86, yTop: -70, wBottom: 65, wTop: 16, color: graniteRock));
    faces.addAll(_buildBox(cx: 35, cy: 45, cz: 10, w: 42, h: 75, d: 35, color: const Color(0xFF757575)));

    return faces;
  }

  // ── UTILITAIRES DE GÉOMÉTRIE 3D ───────────────────────────────────────────

  List<PolygonFace3D> _buildBox({
    required double cx,
    required double cy,
    required double cz,
    required double w,
    required double h,
    required double d,
    required Color color,
  }) {
    final hw = w / 2;
    final hh = h / 2;
    final hd = d / 2;

    return [
      // Devant (+Z)
      PolygonFace3D(
        vertices: [
          [cx - hw, cy - hh, cz + hd],
          [cx + hw, cy - hh, cz + hd],
          [cx + hw, cy + hh, cz + hd],
          [cx - hw, cy + hh, cz + hd],
        ],
        baseColor: color,
      ),
      // Derrière (-Z)
      PolygonFace3D(
        vertices: [
          [cx + hw, cy - hh, cz - hd],
          [cx - hw, cy - hh, cz - hd],
          [cx - hw, cy + hh, cz - hd],
          [cx + hw, cy + hh, cz - hd],
        ],
        baseColor: color,
      ),
      // Gauche (-X)
      PolygonFace3D(
        vertices: [
          [cx - hw, cy - hh, cz - hd],
          [cx - hw, cy - hh, cz + hd],
          [cx - hw, cy + hh, cz + hd],
          [cx - hw, cy + hh, cz - hd],
        ],
        baseColor: color,
      ),
      // Droite (+X)
      PolygonFace3D(
        vertices: [
          [cx + hw, cy - hh, cz + hd],
          [cx + hw, cy - hh, cz - hd],
          [cx + hw, cy + hh, cz - hd],
          [cx + hw, cy + hh, cz + hd],
        ],
        baseColor: color,
      ),
      // Haut (-Y)
      PolygonFace3D(
        vertices: [
          [cx - hw, cy - hh, cz - hd],
          [cx + hw, cy - hh, cz - hd],
          [cx + hw, cy - hh, cz + hd],
          [cx - hw, cy - hh, cz + hd],
        ],
        baseColor: color,
      ),
      // Bas (+Y)
      PolygonFace3D(
        vertices: [
          [cx - hw, cy + hh, cz + hd],
          [cx + hw, cy + hh, cz + hd],
          [cx + hw, cy + hh, cz - hd],
          [cx - hw, cy + hh, cz - hd],
        ],
        baseColor: color,
      ),
    ];
  }

  List<PolygonFace3D> _buildPyramidFrustum({
    required double yBottom,
    required double yTop,
    required double wBottom,
    required double wTop,
    required Color color,
  }) {
    final hb = wBottom / 2;
    final ht = wTop / 2;

    return [
      // Devant (+Z)
      PolygonFace3D(
        vertices: [
          [-ht, yTop, ht],
          [ht, yTop, ht],
          [hb, yBottom, hb],
          [-hb, yBottom, hb],
        ],
        baseColor: color,
      ),
      // Derrière (-Z)
      PolygonFace3D(
        vertices: [
          [ht, yTop, -ht],
          [-ht, yTop, -ht],
          [-hb, yBottom, -hb],
          [hb, yBottom, -hb],
        ],
        baseColor: color,
      ),
      // Gauche (-X)
      PolygonFace3D(
        vertices: [
          [-ht, yTop, -ht],
          [-ht, yTop, ht],
          [-hb, yBottom, hb],
          [-hb, yBottom, -hb],
        ],
        baseColor: color,
      ),
      // Droite (+X)
      PolygonFace3D(
        vertices: [
          [ht, yTop, ht],
          [ht, yTop, -ht],
          [hb, yBottom, -hb],
          [hb, yBottom, hb],
        ],
        baseColor: color,
      ),
    ];
  }

  List<PolygonFace3D> _buildCylinder({
    required double cx,
    required double yBottom,
    required double yTop,
    required double radiusBottom,
    required double radiusTop,
    required int segments,
    required Color color,
  }) {
    final List<PolygonFace3D> faces = [];
    final double step = (math.pi * 2) / segments;

    for (int i = 0; i < segments; i++) {
      final a1 = i * step;
      final a2 = (i + 1) * step;

      final x1b = cx + math.cos(a1) * radiusBottom;
      final z1b = math.sin(a1) * radiusBottom;
      final x2b = cx + math.cos(a2) * radiusBottom;
      final z2b = math.sin(a2) * radiusBottom;

      final x1t = cx + math.cos(a1) * radiusTop;
      final z1t = math.sin(a1) * radiusTop;
      final x2t = cx + math.cos(a2) * radiusTop;
      final z2t = math.sin(a2) * radiusTop;

      faces.add(PolygonFace3D(
        vertices: [
          [x1t, yTop, z1t],
          [x2t, yTop, z2t],
          [x2b, yBottom, z2b],
          [x1b, yBottom, z1b],
        ],
        baseColor: color,
      ));
    }
    return faces;
  }

  @override
  bool shouldRepaint(covariant _RealisticMonument3DPainter oldDelegate) {
    return oldDelegate.rotX != rotX ||
        oldDelegate.rotY != rotY ||
        oldDelegate.scale != scale ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.lighting != lighting ||
        oldDelegate.showWireframe != showWireframe;
  }
}

class _ProjectedPolygon {
  final List<Offset> points;
  final double avgZ;
  final Color fillColor;
  final String? textureType;

  _ProjectedPolygon({
    required this.points,
    required this.avgZ,
    required this.fillColor,
    this.textureType,
  });
}

/// Peintre de poussières atmosphériques et particules de lumière sahéliennes
class _AtmosphericDustPainter extends CustomPainter {
  final double progress;
  final LightingEnvironment lighting;

  _AtmosphericDustPainter({required this.progress, required this.lighting});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint();

    final Color particleColor = (lighting == LightingEnvironment.nuitEtoilee)
        ? const Color(0xFF60A5FA)
        : CultureTheme.accentOrange;

    for (int i = 0; i < 36; i++) {
      final double seedX = random.nextDouble() * size.width;
      final double seedY = random.nextDouble() * size.height;
      final double speed = 0.2 + random.nextDouble() * 0.8;
      final double currentY = (seedY - (progress * speed * size.height)) % size.height;
      final double radius = 1.0 + random.nextDouble() * 2.2;
      final double alpha = (math.sin(progress * math.pi * 2 + i) * 0.3 + 0.5).clamp(0.1, 0.8);

      paint.color = particleColor.withValues(alpha: alpha * 0.45);
      canvas.drawCircle(Offset(seedX, currentY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AtmosphericDustPainter oldDelegate) => true;
}
