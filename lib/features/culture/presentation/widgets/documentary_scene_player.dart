import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/culture_detail_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';
import 'culture_audio_listen_badge.dart';

/// Données d'une scène documentaire avec personnages et décors
class DocuSceneData {
  final int index;
  final String actTitle;
  final String periodLocation;
  final String narrative;
  final String keyQuote;
  final String bgImagePath;
  final String primaryCharName;
  final String primaryCharRole;
  final String primaryCharImage;
  final String? opponentCharName;
  final String? opponentCharRole;
  final String? opponentCharImage;
  final bool isConfrontation;
  final String? confrontationBadgeText;
  final Color? primaryColor;
  final Color? opponentColor;

  const DocuSceneData({
    required this.index,
    required this.actTitle,
    required this.periodLocation,
    required this.narrative,
    required this.keyQuote,
    required this.bgImagePath,
    required this.primaryCharName,
    required this.primaryCharRole,
    required this.primaryCharImage,
    this.opponentCharName,
    this.opponentCharRole,
    this.opponentCharImage,
    this.isConfrontation = false,
    this.confrontationBadgeText,
    this.primaryColor,
    this.opponentColor,
  });
}

/// Lecteur de Scène Documentaire Animée (Motion Design Documentaire)
/// Anime l'entrée cinématographique des personnages (glissement depuis la gauche/droite,
/// transitions de scènes et mise en récit narrative style documentaire historique).
class DocumentaryScenePlayer extends StatefulWidget {
  final HistoricalFigureDetail figure;
  final bool isDark;

  const DocumentaryScenePlayer({
    super.key,
    required this.figure,
    required this.isDark,
  });

  @override
  State<DocumentaryScenePlayer> createState() => _DocumentaryScenePlayerState();
}

class _DocumentaryScenePlayerState extends State<DocumentaryScenePlayer>
    with TickerProviderStateMixin {
  int _currentSceneIndex = 0;
  late final List<DocuSceneData> _scenes;

  // Contrôleurs d'animations pour les personnages
  late final AnimationController _sceneEntryController;
  late final Animation<Offset> _primarySlideAnimation;
  late final Animation<double> _primaryFadeAnimation;
  late final Animation<double> _primaryScaleAnimation;

  late final Animation<Offset> _opponentSlideAnimation;
  late final Animation<double> _opponentFadeAnimation;

  late final AnimationController _kenBurnsController;
  late final AnimationController _clashPulseController;

  @override
  void initState() {
    super.initState();
    _initScenes();

    // 1. Contrôleur d'entrée de scène et des personnages
    _sceneEntryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Personnage principal : Glisse depuis la GAUCHE comme dans les documentaires
    _primarySlideAnimation = Tween<Offset>(
      begin: const Offset(-0.85, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _sceneEntryController,
        curve: const Interval(0.1, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _primaryFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sceneEntryController,
        curve: const Interval(0.1, 0.65, curve: Curves.easeIn),
      ),
    );

    _primaryScaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(
        parent: _sceneEntryController,
        curve: const Interval(0.2, 0.85, curve: Curves.easeOutBack),
      ),
    );

    // Personnage opposant / secondaire : Glisse depuis la DROITE
    _opponentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.85, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _sceneEntryController,
        curve: const Interval(0.25, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    _opponentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sceneEntryController,
        curve: const Interval(0.25, 0.80, curve: Curves.easeIn),
      ),
    );

    // 2. Mouvement lent cinématique de caméra (Effet Ken Burns)
    _kenBurnsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);

    // 3. Pulsation d'impact du choc pour la bataille de Kirina
    _clashPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Démarrer l'animation de la première scène
    _sceneEntryController.forward();
  }

  void _initScenes() {
    final figId = widget.figure.id;

    if (figId.contains('soundiata')) {
      _scenes = [
        const DocuSceneData(
          index: 0,
          actTitle: 'ACTE I : L\'ENFANCE & LA PROPHÉTIE',
          periodLocation: '1205 • Niani, Royaume du Manden',
          narrative:
              'Fils de Naré Maghann Konaté et de Sogolon Kondé, Soundiata naît paralysé. Écarté du pouvoir et raillé, il fait preuve d\'une volonté inébranlable. Grâce à la barre de fer des forgerons, le jeune prince se dresse sur ses jambes et prend son destin en main sous le regard médusé du peuple.',
          keyQuote:
              '« Qu\'on m\'apporte la plus lourde barre de fer. Aujourd\'hui, le lion va marcher ! »\n— Soundiata Keïta',
          bgImagePath: 'assets/images/culture/scenes/scene_niani_prophetie.jpg',
          primaryCharName: 'Soundiata Keïta',
          primaryCharRole: 'Jeune Prince du Manden',
          primaryCharImage: 'assets/images/culture/personnages/soundiata.jpg',
          primaryColor: Color(0xFFF59E0B),
        ),
        const DocuSceneData(
          index: 1,
          actTitle: 'ACTE II : L\'ÉPREUVE DE L\'EXIL & LES ALLIANCES',
          periodLocation: '1220 – 1234 • Royaume de Méma',
          narrative:
              'Contraint à l\'exil par les intrigues de cour, Soundiata parcourt le Sahel et trouve refuge auprès du roi de Méma. Il y devient un maître cavalier et affine son génie stratégique. Pendant ce temps, le tyran Soumaoro Kanté ravage le Manden, poussant les anciens à appeler Soundiata à la rescousse.',
          keyQuote:
              '« L\'exil n\'a pas brisé mon âme ; il a trempé ma lame pour la libération de mon peuple. »',
          bgImagePath: 'assets/images/culture/scenes/scene_niani_prophetie.jpg',
          primaryCharName: 'Soundiata Keïta',
          primaryCharRole: 'Général & Libérateur en Exil',
          primaryCharImage: 'assets/images/culture/personnages/soundiata.jpg',
          primaryColor: Color(0xFFF59E0B),
        ),
        const DocuSceneData(
          index: 2,
          actTitle: 'ACTE III : LE CHOC DÉCISIF DE KIRINA',
          periodLocation: '1235 • Plaines de Kirina, Koulikoro',
          narrative:
              'Face-à-face historique entre Soundiata Keïta et le redoutable roi-sorcier Soumaoro Kanté du Sosso. Dans un affrontement titanesque où s\'entrechoquent bravoure et magie ancestrale, Soundiata triomphe grâce à un ergot de coq blanc, mettant fin à la terreur et unifiant les royaumes sous une même bannière.',
          keyQuote:
              '« À Kirina, ce n\'est pas seulement deux rois qui se heurtent, c\'est la liberté qui brise la tyrannie. »\n— Les Griots du Manden',
          bgImagePath: 'assets/images/culture/scenes/scene_kirina_1235.jpg',
          primaryCharName: 'Soundiata Keïta',
          primaryCharRole: 'Commandant de la Coalition Mandingue',
          primaryCharImage: 'assets/images/culture/personnages/soundiata.jpg',
          opponentCharName: 'Soumaoro Kanté',
          opponentCharRole: 'Le Roi-Sorcier du Sosso',
          opponentCharImage:
              'assets/images/culture/personnages/soumaoro_kante.jpg',
          isConfrontation: true,
          confrontationBadgeText: 'CHOC DE KIRINA (1235)',
          primaryColor: Color(0xFFF59E0B),
          opponentColor: Color(0xFFEF4444),
        ),
        const DocuSceneData(
          index: 3,
          actTitle: 'ACTE IV : LA CHARTE DE KOUROUKAN FOUGA',
          periodLocation: '1236 • Clairière sacrée de Kangaba',
          narrative:
              'Proclamé Mansa de l\'Empire du Mali, Soundiata réunit les sages et chefs de clans pour proclamer la Charte du Manden. Composée de 44 articles, elle institue l\'une des toutes premières déclarations des droits humains au monde, sacralisant la vie humaine, la paix sociale et la protection de l\'environnement.',
          keyQuote:
              '« Toute vie humaine est une vie. Une vie n\'est pas plus respectable qu\'une autre. »\n— Article 5, Charte de Kouroukan Fouga (1236)',
          bgImagePath: 'assets/images/culture/scenes/scene_kouroukan_fouga.jpg',
          primaryCharName: 'Mansa Soundiata',
          primaryCharRole: 'Fondateur de l\'Empire du Mali',
          primaryCharImage: 'assets/images/culture/personnages/soundiata.jpg',
          primaryColor: Color(0xFFF59E0B),
        ),
      ];
    } else if (figId.contains('mansa_moussa')) {
      _scenes = [
        const DocuSceneData(
          index: 0,
          actTitle: 'ACTE I : L\'AVÈNEMENT & L\'EMPIRE D\'OR',
          periodLocation: '1312 • Cité Impériale & Fleuve Niger',
          narrative:
              'Petit-neveu de Soundiata Keïta, Kankou Moussa monte sur le trône après le voyage océanique du Mansa Aboubakri II. Sous son règne d\'une prospérité éclatante, l\'Empire du Mali s\'étend sur plus de 3 000 kilomètres, reliant l\'Atlantique au Sahara et fédérant 24 grandes métropoles régionales.',
          keyQuote:
              '« Le savoir et la concorde sont les deux colonnes qui soutiennent la puissance du Mali. »',
          bgImagePath: 'assets/images/culture/villes/tombouctou_ville.jpg',
          primaryCharName: 'Mansa Moussa',
          primaryCharRole: 'Souverain d\'Or & Bâtisseur',
          primaryCharImage: 'assets/images/culture/personnages/mansa_moussa.jpg',
          primaryColor: Color(0xFFF59E0B),
        ),
        const DocuSceneData(
          index: 1,
          actTitle: 'ACTE II : LE GRAND PÈLERINAGE DE 1324',
          periodLocation: '1324 • Traversée du Sahara & Le Caire',
          narrative:
              'À la tête d\'une caravane de 60 000 dignitaires, gardes et lettrés avec 80 dromadaires portant chacun de l\'or pur, Mansa Moussa traverse Le Caire vers La Mecque. Sa générosité légendaire marque le monde méditerranéen et place le Mali au sommet des cartes universelles.',
          keyQuote:
              '« La splendeur du Mali brille sous le soleil pour honorer la foi, le savoir et l\'humanité. »',
          bgImagePath: 'assets/images/culture/villes/gao_dune_rose.jpg',
          primaryCharName: 'Mansa Moussa',
          primaryCharRole: 'Pèlerin Impérial du Mali',
          primaryCharImage: 'assets/images/culture/personnages/mansa_moussa.jpg',
          opponentCharName: 'Dignitaires du Caire',
          opponentCharRole: 'Cour Mamelouke d\'Égypte',
          opponentCharImage: 'assets/images/culture/personnages/mansa_moussa.jpg',
          primaryColor: Color(0xFFF59E0B),
          opponentColor: Color(0xFF0EA5E9),
        ),
        const DocuSceneData(
          index: 2,
          actTitle: 'ACTE III : TOMBOUCTOU, CITÉ DU SAVOIR & DJINGAREYBER',
          periodLocation: '1327 • Tombouctou la Mystérieuse',
          narrative:
              'De retour de La Mecque, Mansa Moussa invite l\'architecte et poète andalou Abou Ishaq es-Sahéli à concevoir la Mosquée Djingareyber en terre crue et torons de palmier. L\'Université de Sankoré attire des docteurs en droit, astronomie et médecine venus de tout le monde connu.',
          keyQuote:
              '« Le savoir est la lumière de l\'empire ; les savants sont les gardiens de notre avenir. »\n— Mansa Moussa, 1327',
          bgImagePath: 'assets/images/culture/villes/tombouctou_ville.jpg',
          primaryCharName: 'Mansa Moussa',
          primaryCharRole: 'Mécène Universel & Bâtisseur',
          primaryCharImage: 'assets/images/culture/personnages/mansa_moussa.jpg',
          opponentCharName: 'Abou Ishaq es-Sahéli',
          opponentCharRole: 'Maître Architecte Andalous',
          opponentCharImage: 'assets/images/culture/personnages/mansa_moussa.jpg',
          primaryColor: Color(0xFFF59E0B),
          opponentColor: Color(0xFF10B981),
        ),
      ];
    } else if (figId.contains('babemba')) {
      _scenes = [
        const DocuSceneData(
          index: 0,
          actTitle: 'ACTE I : L\'HÉRITAGE DU KÉNÉDOUGOU & TIÉBA',
          periodLocation: '1893 • Sikasso, Cité des Guerriers',
          narrative:
              'Succédant à son frère illustre Tiéba Traoré en 1893, Babemba prend les rênes du Royaume du Kénédougou. Chef d\'État visionnaire et stratège hors pair, il renforce la discipline militaire et refuse catégoriquement toute capitulation face aux colonnes d\'invasion coloniale.',
          keyQuote:
              '« Le Kénédougou a été bâti par le sang et le fer des braves ; nul traité déloyal ne viendra éteindre notre flamme. »',
          bgImagePath: 'assets/images/culture/villes/sikasso_ville.jpg',
          primaryCharName: 'Babemba Traoré',
          primaryCharRole: 'Roi du Kénédougou',
          primaryCharImage: 'assets/images/culture/personnages/babemba_traore.jpg',
          primaryColor: Color(0xFFDC2626),
        ),
        const DocuSceneData(
          index: 1,
          actTitle: 'ACTE II : LE SIÈGE HÉROÏQUE DU TATA DE SIKASSO',
          periodLocation: 'Avril 1898 • Remparts Inviolables du Tata',
          narrative:
              'Entourée d\'une triple muraille de terre crue de 9 kilomètres de pourtour et de 6 mètres de haut, la forteresse du Tata subit le pilonnage intensif de l\'artillerie lourde. Pendant des semaines de combats acharnés, Babemba galvanise ses soldats qui repoussent héroïquement chaque assaut.',
          keyQuote:
              '« Les obus peuvent éventrer la terre du Tata, mais le cœur d\'un Traoré ne pliera jamais ! »',
          bgImagePath: 'assets/images/culture/monuments/monument_tata_sikasso/tat1.jpg',
          primaryCharName: 'Babemba Traoré',
          primaryCharRole: 'Commandant Suprême du Tata',
          primaryCharImage: 'assets/images/culture/personnages/babemba_traore.jpg',
          opponentCharName: 'Forces Coloniales',
          opponentCharRole: 'Artillerie du Siège de 1898',
          opponentCharImage: 'assets/images/culture/personnages/babemba_traore.jpg',
          isConfrontation: true,
          confrontationBadgeText: 'SIÈGE DU TATA (1898)',
          primaryColor: Color(0xFFDC2626),
          opponentColor: Color(0xFF991B1B),
        ),
        const DocuSceneData(
          index: 2,
          actTitle: 'ACTE III : LE SACRIFICE DE LA DIGNITÉ SUPRÊME',
          periodLocation: '1er Mai 1898 • Palais Royal de Sikasso',
          narrative:
              'Le 1er mai 1898, constatant la brèche ouverte dans les défenses par l\'ennemi supérieur en nombre, Babemba choisit l\'immortalité plutôt que l\'infamie d\'une reddition. Il ordonne à son fidèle chef de garde de l\'abattre, inscrivant sa devise dans le marbre de la conscience nationale.',
          keyQuote:
              '« Sayon te malo ye ! La mort plutôt que la honte ! »\n— Babemba Traoré, Héros de la Dignité Nationale',
          bgImagePath: 'assets/images/culture/villes/sikasso_ville.jpg',
          primaryCharName: 'Babemba Traoré',
          primaryCharRole: 'Héros Immortel de la Dignité',
          primaryCharImage: 'assets/images/culture/personnages/babemba_traore.jpg',
          primaryColor: Color(0xFFDC2626),
        ),
      ];
    } else if (figId.contains('askia_mohammed')) {
      _scenes = [
        const DocuSceneData(
          index: 0,
          actTitle: 'ACTE I : L\'AVÈNEMENT DE LA DYNASTIE DES ASKIA',
          periodLocation: '1493 • Gao, Capitale de l\'Empire Songhoï',
          narrative:
              'Grand général et administrateur avisé, Mohammed Touré accède au pouvoir en 1493 et fonde la prestigieuse dynastie des Askia. Il dote l\'Empire Songhoï d\'une administration centralisée moderne, de ministères sectoriels et d\'une armée de métier garantissant la paix sur le fleuve.',
          keyQuote:
              '« L\'ordre, la justice équitable et la foi unissent les peuples du Songhoï d\'un rivage à l\'autre. »',
          bgImagePath: 'assets/images/culture/villes/gao_dune_rose.jpg',
          primaryCharName: 'Askia Mohammed',
          primaryCharRole: 'Grand Réformateur Songhoï',
          primaryCharImage: 'assets/images/culture/personnages/askia_mohammed.jpg',
          primaryColor: Color(0xFF0D9488),
        ),
        const DocuSceneData(
          index: 1,
          actTitle: 'ACTE II : LE TRIANGLE DU SAVOIR : GAO, TOMBOUCTOU, DJENNÉ',
          periodLocation: '1497 • Flottille Impériale & Écoles Coraniques',
          narrative:
              'Askia le Grand place les savants, juristes et astronomes au cœur de la gouvernance impériale. Il finance largement les universités de Tombouctou et de Gao, transformant le Sahel en phare intellectuel où convergent manuscrits rares et penseurs de tout le continent.',
          keyQuote:
              '« L\'encre des savants est plus précieuse que le sang des martyrs. Protégez les manuscrits de nos sages. »',
          bgImagePath: 'assets/images/culture/villes/tombouctou_ville.jpg',
          primaryCharName: 'Askia le Grand',
          primaryCharRole: 'Protecteur des Savants & Écoles',
          primaryCharImage: 'assets/images/culture/personnages/askia_mohammed.jpg',
          opponentCharName: 'Cadis & Érudits',
          opponentCharRole: 'Gardiens du Droit & du Savoir',
          opponentCharImage: 'assets/images/culture/personnages/askia_mohammed.jpg',
          primaryColor: Color(0xFF0D9488),
          opponentColor: Color(0xFFD97706),
        ),
        const DocuSceneData(
          index: 2,
          actTitle: 'ACTE III : L\'ÉDIFICATION DU TOMBEAU PYRAMIDAL DE GAO',
          periodLocation: '1495 • Cité Millénaire de Gao',
          narrative:
              'De retour de son pèlerinage avec de la terre sainte, Askia Mohammed fait ériger le chef-d\'œuvre monumental du Tombeau des Askia à Gao. Cette pyramide à degrés de 17 mètres, percée de torons en bois et de minarets, s\'impose comme un joyau impérissable de l\'architecture sahélienne en terre crue.',
          keyQuote:
              '« Que ce sanctuaire de terre et d\'acacia traverse les siècles pour rappeler la foi et la puissance de Gao. »',
          bgImagePath: 'assets/images/culture/monuments/monument_tombeau_askia/tomb1.jpg',
          primaryCharName: 'Askia Mohammed',
          primaryCharRole: 'Bâtisseur du Patrimoine Mondial',
          primaryCharImage: 'assets/images/culture/personnages/askia_mohammed.jpg',
          primaryColor: Color(0xFF0D9488),
        ),
      ];
    } else if (figId.contains('biton')) {
      _scenes = [
        const DocuSceneData(
          index: 0,
          actTitle: 'ACTE I : L\'ASSOCIATION DES TÔN & LA JEUNESSE',
          periodLocation: '1712 • Ségou-Koro, Bords du Djoliba',
          narrative:
              'Mamary Coulibaly transforme l\'association fraternelle de chasse et d\'entraide agricole (le Tôn) en une organisation sociopolitique unie. Élu chef incontesté (Biton), il fédère les jeunes guerriers autour de règles d\'honneur et de solidarité inébranlables.',
          keyQuote:
              '« L\'union fait la vigueur du bras ; la loyauté partagée au Tôn brise toute division. »',
          bgImagePath: 'assets/images/culture/villes/segou_koro.jpg',
          primaryCharName: 'Biton Mamary Coulibaly',
          primaryCharRole: 'Fondateur du Royaume Bambara',
          primaryCharImage: 'assets/images/culture/personnages/biton_coulibaly.jpg',
          primaryColor: Color(0xFF059669),
        ),
        const DocuSceneData(
          index: 1,
          actTitle: 'ACTE II : LA PUISSANCE DES TÔNJONS & LA FLOTTE DU FLEUVE',
          periodLocation: '1720 • Bords du Fleuve Niger, Ségou',
          narrative:
              'Biton Coulibaly crée la toute première armée de métier permanente de la région : les Tônjons. Allié aux pêcheurs Somono qui lui fournissent une formidable flottille de pirogues blindées, il s\'assure le contrôle total du fleuve Niger de Bamako jusqu\'aux portes de Djenné.',
          keyQuote:
              '« Nos pirogues tracent la loi sur le Djoliba ; la justice et la force de Ségou règnent sur les flots. »',
          bgImagePath: 'assets/images/culture/villes/segou_koro.jpg',
          primaryCharName: 'Biton Coulibaly',
          primaryCharRole: 'Roi & Commandant Suprême',
          primaryCharImage: 'assets/images/culture/personnages/biton_coulibaly.jpg',
          opponentCharName: 'Guerriers Tônjons',
          opponentCharRole: 'Armée Permanente de Ségou',
          opponentCharImage: 'assets/images/culture/personnages/biton_coulibaly.jpg',
          primaryColor: Color(0xFF059669),
          opponentColor: Color(0xFF1E3A8A),
        ),
        const DocuSceneData(
          index: 2,
          actTitle: 'ACTE III : LA CITÉ ROYALE DES 4 444 BALANZANS',
          periodLocation: '1730 • Capitale Mythique de Ségou',
          narrative:
              'Sous l\'égide de Biton, Ségou s\'épanouit comme un grand centre de culture agraire et de métallurgie traditionnelle. Protégée par les 4 444 arbres Balanzans sacrés, la dynastie Coulibaly ancre l\'identité bambara au cœur de la mémoire vivante du Mali.',
          keyQuote:
              '« Les racines des balanzans puisent dans l\'éternité de notre terre ; ainsi demeure l\'honneur de notre peuple. »',
          bgImagePath: 'assets/images/culture/villes/segou_koro.jpg',
          primaryCharName: 'Biton Coulibaly',
          primaryCharRole: 'Maître Éternel de Ségou',
          primaryCharImage: 'assets/images/culture/personnages/biton_coulibaly.jpg',
          primaryColor: Color(0xFF059669),
        ),
      ];
    } else if (figId.contains('modibo_keita')) {
      _scenes = [
        const DocuSceneData(
          index: 0,
          actTitle: 'ACTE I : LA LUTTE ANTI-COLONIALE & L\'US-RDA',
          periodLocation: '1946 • Bamako, Soudan Français',
          narrative:
              'Instituteur dévoué et homme de culture rigoureux, Modibo Keïta fonde l\'Union Soudanaise-RDA. Porté par un idéal d\'émancipation et de justice sociale, il parcourt les cercles et villages pour éveiller la conscience nationale et organiser la résistance politique face au système colonial.',
          keyQuote:
              '« La liberté ne s\'octroie pas dans la facilité, elle s\'arrache par la conscience et l\'union sacrée de tout un peuple. »',
          bgImagePath: 'assets/images/culture/monuments/monument_tour_afrique_bamako/tour.jpg',
          primaryCharName: 'Modibo Keïta',
          primaryCharRole: 'Tribun & Militant Panafricaniste',
          primaryCharImage: 'assets/images/culture/personnages/modibo_keita.jpg',
          primaryColor: Color(0xFF10B981),
        ),
        const DocuSceneData(
          index: 1,
          actTitle: 'ACTE II : LA PROCLAMATION DE L\'INDÉPENDANCE DU MALI',
          periodLocation: '22 Septembre 1960 • Bamako',
          narrative:
              'Le 22 septembre 1960, devant les représentants du peuple et du monde entier, Modibo Keïta proclame solennellement la République du Mali souveraine et indépendante. Il redonne au pays le nom glorieux de l\'Empire médiéval de Soundiata et enracine la fierté nationale.',
          keyQuote:
              '« En ce jour mémorable du 22 septembre 1960, le Mali renaît à l\'histoire libre, fier et souverain ! »\n— Modibo Keïta',
          bgImagePath: 'assets/images/culture/monuments/monument_tour_afrique_bamako/tour1.jpg',
          primaryCharName: 'Modibo Keïta',
          primaryCharRole: 'Premier Président de la République',
          primaryCharImage: 'assets/images/culture/personnages/modibo_keita.jpg',
          opponentCharName: 'Le Peuple Malien',
          opponentCharRole: 'Nation Unie et Souveraine',
          opponentCharImage: 'assets/images/culture/personnages/modibo_keita.jpg',
          primaryColor: Color(0xFF10B981),
          opponentColor: Color(0xFFF59E0B),
        ),
        const DocuSceneData(
          index: 2,
          actTitle: 'ACTE III : LE PÈRE FONDATEUR DE L\'OUA & LE PANAFRICANISME',
          periodLocation: '1963 • Addis-Abeba & Bamako',
          narrative:
              'Cofondateur visionnaire de l\'Organisation de l\'Unité Africaine (OUA) en 1963 à Addis-Abeba, Modibo Keïta défend inlassablement l\'intégration continentale, le non-alignement positif et la dignité des peuples d\'Afrique, s\'inscrivant parmi les plus grands hommes d\'État du XXe siècle.',
          keyQuote:
              '« L\'Afrique ne sera véritablement respectée que lorsqu\'elle parlera d\'une seule et même voix unie et fraternelle. »',
          bgImagePath: 'assets/images/culture/monuments/monument_tour_afrique_bamako/tour.jpg',
          primaryCharName: 'Modibo Keïta',
          primaryCharRole: 'Père de la Nation & Bâtisseur de l\'OUA',
          primaryCharImage: 'assets/images/culture/personnages/modibo_keita.jpg',
          primaryColor: Color(0xFF10B981),
        ),
      ];
    } else {
      // Scènes générées à partir des chapitres de la figure historique avec fallback élégant
      _scenes = widget.figure.chapters.asMap().entries.map((entry) {
        final idx = entry.key;
        final chap = entry.value;
        return DocuSceneData(
          index: idx,
          actTitle: 'ACTE ${idx + 1} : ${chap.title.toUpperCase()}',
          periodLocation: '${widget.figure.period} • ${widget.figure.regionName}',
          narrative: chap.content,
          keyQuote: idx == 0
              ? (widget.figure.citationHistorique ??
                  '« L\'histoire est le guide des générations futures. »')
              : '« L\'histoire est le guide des générations futures. »',
          bgImagePath: widget.figure.photoUrl,
          primaryCharName: widget.figure.name,
          primaryCharRole: widget.figure.titleHonorifique,
          primaryCharImage: widget.figure.photoUrl,
          primaryColor: const Color(0xFFF59E0B),
        );
      }).toList();

      if (_scenes.isEmpty) {
        _scenes = [
          DocuSceneData(
            index: 0,
            actTitle: 'ACTE I : L\'HÉRITAGE DU HÉROS',
            periodLocation: '${widget.figure.period} • ${widget.figure.regionName}',
            narrative: widget.figure.resume,
            keyQuote: widget.figure.citationHistorique ??
                '« L\'histoire est le guide des générations futures. »',
            bgImagePath: widget.figure.photoUrl,
            primaryCharName: widget.figure.name,
            primaryCharRole: widget.figure.titleHonorifique,
            primaryCharImage: widget.figure.photoUrl,
            primaryColor: const Color(0xFFF59E0B),
          ),
        ];
      }
    }
  }

  @override
  void dispose() {
    _sceneEntryController.dispose();
    _kenBurnsController.dispose();
    _clashPulseController.dispose();
    super.dispose();
  }

  void _goToScene(int index) {
    if (index == _currentSceneIndex || index < 0 || index >= _scenes.length) {
      return;
    }
    CulturalHaptics.tabSwitch();
    setState(() {
      _currentSceneIndex = index;
    });
    _replayScene();
  }

  void _replayScene() {
    _sceneEntryController.reset();
    _sceneEntryController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final scene = _scenes[_currentSceneIndex];
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final theaterHeight = (screenWidth * 0.68).clamp(240.0, 290.0);
    final isDual = scene.opponentCharImage != null || scene.isConfrontation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── EN-TÊTE DE SECTION DOCUMENTAIRE ───────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.movie_filter_rounded,
                        size: 14,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'RÉCIT DOCUMENTAIRE ANIMÉ',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFF59E0B),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Bouton Rejouer l'animation de scène
            GestureDetector(
              onTap: () {
                CulturalHaptics.cardPress();
                _replayScene();
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? CultureTheme.darkSurfaceAlt
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderCol),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.replay_rounded,
                      size: 13,
                      color: subtitleColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Rejouer la scène',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── BARRE DE SÉLECTION DES SCÈNES (TIMELINE CHRONOLOGIQUE) ────────────
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(_scenes.length, (index) {
              final isSelected = _currentSceneIndex == index;
              final sc = _scenes[index];
              final shortTitle = sc.actTitle.split(':').last.trim();

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _goToScene(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8.5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF59E0B)
                          : (isDark
                              ? CultureTheme.darkSurfaceAlt
                              : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFF59E0B)
                            : borderCol,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Acte ${index + 1}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.black : titleColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.black54
                                : subtitleColor.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          shortTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isSelected ? Colors.black : subtitleColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 14),

        // ── 🎬 LE THÉÂTRE DE SCÈNE DOCUMENTAIRE (CANVAS & MOTION CHARACTERS) ───
        Container(
          height: theaterHeight,
          width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scene.isConfrontation
                      ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
                      : borderCol,
                  width: scene.isConfrontation ? 1.6 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Décor d'arrière-plan avec zoom cinématique Ken Burns
                  AnimatedBuilder(
                    animation: _kenBurnsController,
                    builder: (context, child) {
                      final scale = 1.0 + (_kenBurnsController.value * 0.08);
                      return Transform.scale(
                        scale: scale,
                        child: Image.asset(
                          scene.bgImagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      );
                    },
                  ),

                  // 2. Filtre dégradé théâtral pour la lisibilité
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.85),
                          Colors.black.withValues(alpha: 0.98),
                        ],
                        stops: const [0.0, 0.35, 0.75, 1.0],
                      ),
                    ),
                  ),

                  // 3. Indicateur de scène / Acte en haut
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              scene.actTitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFF59E0B),
                                letterSpacing: 0.6,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              scene.periodLocation,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. PERSONNAGE PRINCIPAL : PLAN 2.5D GLISSE DEPUIS LA GAUCHE !
                  Positioned(
                    left: scene.isConfrontation ? 8 : 14,
                    bottom: 10,
                    child: SlideTransition(
                      position: _primarySlideAnimation,
                      child: FadeTransition(
                        opacity: _primaryFadeAnimation,
                        child: ScaleTransition(
                          scale: _primaryScaleAnimation,
                          child: AnimatedBuilder(
                            animation: _clashPulseController,
                            builder: (context, _) => _buildCharacterFigure(
                              name: scene.primaryCharName,
                              role: scene.primaryCharRole,
                              imagePath: scene.primaryCharImage,
                              accentColor: scene.primaryColor ?? const Color(0xFFF59E0B),
                              isFacingRight: true,
                              isLarge: !isDual,
                              isDual: isDual,
                              pulseProgress: _clashPulseController.value,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 5. PERSONNAGE OPPOSANT OU ALLIÉ : GLISSE DEPUIS LA DROITE !
                  if (scene.opponentCharImage != null)
                    Positioned(
                      right: 8,
                      bottom: 10,
                      child: SlideTransition(
                        position: _opponentSlideAnimation,
                        child: FadeTransition(
                          opacity: _opponentFadeAnimation,
                          child: AnimatedBuilder(
                            animation: _clashPulseController,
                            builder: (context, _) => _buildCharacterFigure(
                              name: scene.opponentCharName!,
                              role: scene.opponentCharRole ?? (scene.isConfrontation ? 'Adversaire' : 'Allié'),
                              imagePath: scene.opponentCharImage!,
                              accentColor: scene.opponentColor ?? (scene.isConfrontation ? const Color(0xFFEF4444) : const Color(0xFF3B82F6)),
                              isFacingRight: false,
                              isLarge: false,
                              isDual: isDual,
                              pulseProgress: _clashPulseController.value,
                            ),
                          ),
                        ),
                      ),
                    ),

              // 6. Arc de tension cinématique vectorielle pour les scènes de confrontation
              if (scene.isConfrontation)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _clashPulseController,
                    builder: (context, _) => CustomPaint(
                      painter: _DocumentaryDuelTensionPainter(
                        progress: _clashPulseController.value,
                        primaryColor: scene.primaryColor ?? const Color(0xFFF59E0B),
                        opponentColor: scene.opponentColor ?? const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ),

              // 7. Symbole de confrontation centrale stylisé
              if (scene.isConfrontation)
                Positioned.fill(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _clashPulseController,
                      builder: (context, child) {
                        final screenW = MediaQuery.sizeOf(context).width;
                        final isCompact = screenW < 360;
                        final pulse = (0.95 + (_clashPulseController.value * 0.12)) *
                            (isCompact ? 0.85 : 1.0);
                        final accent = scene.primaryColor ?? const Color(0xFFF59E0B);
                        return Transform.scale(
                          scale: pulse,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: isCompact ? 7 : 10,
                                vertical: isCompact ? 4 : 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E0E05)
                                  .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: accent,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.4),
                                  blurRadius: 14,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flash_on_rounded,
                                  size: isCompact ? 12 : 14,
                                  color: accent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  scene.confrontationBadgeText ?? 'CHOC HISTORIQUE',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: isCompact ? 9 : 10,
                                    fontWeight: FontWeight.w900,
                                    color: accent,
                                    letterSpacing: 0.8,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── RÉCIT & NARRATION DE LA SCÈNE (CARTOUCHE HISTORIQUE) ──────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: Container(
            key: ValueKey('docu_text_$_currentSceneIndex'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderCol),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Récit narratif de la scène
                Text(
                  scene.narrative,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: titleColor,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                // Citation marquante
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      left: BorderSide(
                        color: const Color(0xFFF59E0B),
                        width: 3.5,
                      ),
                    ),
                  ),
                  child: Text(
                    scene.keyQuote,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? const Color(0xFFFCD34D)
                          : const Color(0xFFB45309),
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── ACTIONS : NARRATION VOCALE & NAVIGATION SCÈNE SUIVANTE ────
                Row(
                  children: [
                    // Badge d'écoute orale de la scène
                    CultureAudioListenBadge(
                      contentId: '${widget.figure.id}_scene_$_currentSceneIndex',
                      speechText:
                          '${scene.actTitle}. ${scene.periodLocation}. ${scene.narrative}',
                      label: 'Écouter la scène',
                      compact: true,
                      activeColor: const Color(0xFFF59E0B),
                    ),

                    const Spacer(),

                    // Bouton Scène Précédente
                    if (_currentSceneIndex > 0)
                      GestureDetector(
                        onTap: () => _goToScene(_currentSceneIndex - 1),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark
                                ? CultureTheme.darkSurfaceAlt
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderCol),
                          ),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            size: 22,
                            color: titleColor,
                          ),
                        ),
                      ),

                    if (_currentSceneIndex > 0) const SizedBox(width: 8),

                    // Bouton Scène Suivante
                    if (_currentSceneIndex < _scenes.length - 1)
                      GestureDetector(
                        onTap: () => _goToScene(_currentSceneIndex + 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Scène Suivante',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Fin de l\'Épopée',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Figure en relief 2.5D avec perspective 3D, reflet spéculaire dynamique, ombre portée et cartouche documentaire
  Widget _buildCharacterFigure({
    required String name,
    required String role,
    required String imagePath,
    required Color accentColor,
    required bool isFacingRight,
    required bool isLarge,
    required bool isDual,
    required double pulseProgress,
  }) {
    final double cardWidth = isLarge ? 88.0 : (isDual ? 72.0 : 80.0);
    final double cardHeight = isLarge ? 104.0 : (isDual ? 86.0 : 96.0);
    final tiltAngle = isFacingRight ? 0.08 : -0.08;
    final floatY =
        math.sin(pulseProgress * 2 * math.pi + (isFacingRight ? 0.0 : math.pi)) *
            2.8;
    final sheenProgress = ((pulseProgress * 1.5) % 1.0);

    final cardWidget = Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.9),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.4),
            blurRadius: 16,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, __, ___) => Container(
              color: accentColor.withValues(alpha: 0.25),
              child: const Icon(Icons.person_rounded,
                  color: Colors.white, size: 28),
            ),
          ),
          // Dégradé de contraste cinématique
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
                stops: const [0.45, 1.0],
              ),
            ),
          ),
          // Balayage spéculaire lumineux
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-2.0 + (sheenProgress * 4.0), -1.0),
                  end: Alignment(-1.0 + (sheenProgress * 4.0), 1.0),
                  colors: [
                    Colors.transparent,
                    Colors.white.withValues(alpha: 0.26),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Badge héroïque / icône de camp
          Positioned(
            top: 5,
            right: isFacingRight ? 5 : null,
            left: isFacingRight ? null : 5,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor,
                  width: 1.1,
                ),
              ),
              child: Icon(
                isFacingRight
                    ? Icons.shield_rounded
                    : Icons.flash_on_rounded,
                size: 10,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002) // Perspective 3D
        ..rotateY(tiltAngle)
        ..rotateZ(isFacingRight ? -0.015 : 0.015)
        ..setTranslationRaw(0.0, floatY, 0.0),
      alignment: isFacingRight ? Alignment.bottomLeft : Alignment.bottomRight,
      child: isDual
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isFacingRight
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                cardWidget,
                const SizedBox(height: 4),
                _buildCharacterLabel(
                  name,
                  role,
                  accentColor,
                  isFacingRight ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  maxWidth: cardWidth + 20,
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isFacingRight) ...[
                  _buildCharacterLabel(
                    name,
                    role,
                    accentColor,
                    CrossAxisAlignment.end,
                    maxWidth: 110,
                  ),
                  const SizedBox(width: 8),
                ],
                cardWidget,
                if (isFacingRight) ...[
                  const SizedBox(width: 8),
                  _buildCharacterLabel(
                    name,
                    role,
                    accentColor,
                    CrossAxisAlignment.start,
                    maxWidth: 110,
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildCharacterLabel(
    String name,
    String role,
    Color accentColor,
    CrossAxisAlignment align, {
    double? maxWidth,
  }) {
    return Container(
      constraints: maxWidth != null ? BoxConstraints(maxWidth: maxWidth) : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: align,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.0,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            role,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: accentColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Peintre d'arc de tension cinématique entre deux figures historiques
class _DocumentaryDuelTensionPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color opponentColor;

  _DocumentaryDuelTensionPainter({
    required this.progress,
    required this.primaryColor,
    required this.opponentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final startOffset = Offset(88, size.height - 58);
    final endOffset = Offset(size.width - 88, size.height - 58);
    final midX = size.width * 0.5;
    final midY = (size.height * 0.46) - (math.sin(progress * math.pi) * 10);

    final arcPath = Path()
      ..moveTo(startOffset.dx, startOffset.dy)
      ..quadraticBezierTo(midX, midY, endOffset.dx, endOffset.dy);

    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          primaryColor.withValues(alpha: 0.65),
          opponentColor.withValues(alpha: 0.65),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(arcPath, glowPaint);

    final corePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white,
          primaryColor,
          opponentColor,
          Colors.white,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawPath(arcPath, corePaint);

    final shockRadius = 12 + (progress * 14);
    final shockAlpha = ((1.0 - progress) * 0.6).clamp(0.0, 1.0);
    final shockPaint = Paint()
      ..color = primaryColor.withValues(alpha: shockAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    canvas.drawCircle(Offset(midX, size.height * 0.48), shockRadius, shockPaint);
  }

  @override
  bool shouldRepaint(covariant _DocumentaryDuelTensionPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
