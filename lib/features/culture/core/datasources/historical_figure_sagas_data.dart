import 'package:flutter/material.dart';
import '../theme/culture_theme.dart';

/// 📜 CHAPITRE D'UNE ÉPOPÉE HISTORIQUE CONTINUE (MOTION DESIGN CINÉMATIQUE)
/// Charte graphique AlterniA & Culture : Or Patrimoine, Ocre Terre, Sable et Bleu Nuit.
class CharacterStoryChapter {
  final String id;
  final String chapterNumber;
  final String title;
  final String kicker;
  final String dateAndPlace;
  final String mainImage;
  final String? antagonistImage;
  final String fullNarrative;
  final List<String> kineticQuotes;
  final Color accentColor;
  final int readingDurationSeconds;

  const CharacterStoryChapter({
    required this.id,
    required this.chapterNumber,
    required this.title,
    required this.kicker,
    required this.dateAndPlace,
    required this.mainImage,
    this.antagonistImage,
    required this.fullNarrative,
    required this.kineticQuotes,
    required this.accentColor,
    required this.readingDurationSeconds,
  });
}

/// Rétrocompatibilité avec le code de Soundiata
typedef SoundiataStoryChapter = CharacterStoryChapter;

/// 📜 ARTICLE DE DÉCRET OU DE CHARTE HISTORIQUE
class HistoricalDecreeArticle {
  final int number;
  final String title;
  final String quote;
  final String explanation;

  const HistoricalDecreeArticle({
    required this.number,
    required this.title,
    required this.quote,
    required this.explanation,
  });
}

/// Rétrocompatibilité avec CharterArticle
typedef CharterArticle = HistoricalDecreeArticle;

/// 🏛️ MODÈLE COMPLET D'UNE ÉPOPÉE HISTORIQUE CINÉMATIQUE
class HistoricalFigureSaga {
  final String figureId;
  final String figureName;
  final String titleHonorifique;
  final String sagaTitle;
  final String sagaSubtitle;
  final Color primaryAccent;
  final Color secondaryAccent;
  final List<CharacterStoryChapter> chapters;
  final String landmarkChapterId;
  final String landmarkModalButtonText;
  final String landmarkModalTitle;
  final String landmarkModalSubtitle;
  final List<HistoricalDecreeArticle> landmarkArticles;
  final String? antagonistChapterId;
  final String? antagonistPrimaryLabel;
  final String? antagonistSecondaryLabel;

  const HistoricalFigureSaga({
    required this.figureId,
    required this.figureName,
    required this.titleHonorifique,
    required this.sagaTitle,
    required this.sagaSubtitle,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.chapters,
    required this.landmarkChapterId,
    required this.landmarkModalButtonText,
    required this.landmarkModalTitle,
    required this.landmarkModalSubtitle,
    required this.landmarkArticles,
    this.antagonistChapterId,
    this.antagonistPrimaryLabel,
    this.antagonistSecondaryLabel,
  });
}

/// 📚 CATALOGUE OFFICIEL DES SAGAS HISTORIQUES DU MALI
class HistoricalFigureSagas {
  // ════════════════════════════════════════════════════════════════════════════
  // 1. SOUNDIATA KEÏTA — LE LION DU MANDEN (1190 – 1255)
  // ════════════════════════════════════════════════════════════════════════════
  static const HistoricalFigureSaga soundiata = HistoricalFigureSaga(
    figureId: 'perso_soundiata',
    figureName: 'Soundiata Keïta',
    titleHonorifique: 'Mansa du Manden & Fondateur de l\'Empire du Mali',
    sagaTitle: 'Épopée de Soundiata Keïta',
    sagaSubtitle: 'Du Lion Rampant au Bâtisseur de l\'Empire du Mali',
    primaryAccent: CultureTheme.orPatrimoine,
    secondaryAccent: CultureTheme.accentOrange,
    antagonistChapterId: 'kirina',
    antagonistPrimaryLabel: 'VOIR SOUNDIATA (ARC SACRÉ)',
    antagonistSecondaryLabel: 'VOIR SOUMAORO KANTÉ (SOSSO)',
    landmarkChapterId: 'charte',
    landmarkModalButtonText: 'CONSULTER LES LOIS DE LA CHARTE (UNESCO)',
    landmarkModalTitle: 'Charte de Kouroukan Fouga (1236)',
    landmarkModalSubtitle: 'Première déclaration des droits humains • UNESCO',
    landmarkArticles: [
      HistoricalDecreeArticle(
        number: 5,
        title: 'Éducation & Jeunesse',
        quote: '« L\'éducation des enfants incombe à l\'ensemble de la communauté. »',
        explanation: 'Tout enfant appartient à la société entière qui veille solidairement à son instruction et son honneur.',
      ),
      HistoricalDecreeArticle(
        number: 7,
        title: 'Concorde Sociale (Sanankuya)',
        quote: '« Le Sanankuya ou parenté à plaisanterie est institué pour désamorcer les rancœurs et sceller la fraternité. »',
        explanation: 'Un mécanisme institutionnel d\'apaisement verbal empêchant tout conflit armé entre les clans alliés.',
      ),
      HistoricalDecreeArticle(
        number: 16,
        title: 'Protection de la Vie Humaine',
        quote: '« Une vie n\'est pas supérieure à une autre vie. Toute atteinte à la vie exige réparation équitable. »',
        explanation: 'Sacralisation absolue de l\'existence humaine et interdiction solennelle des exécutions arbitraires.',
      ),
      HistoricalDecreeArticle(
        number: 20,
        title: 'Adoucissement de la Condition Servile',
        quote: '« Ne maltraitez point les captifs ; ils doivent être nourris, vêtus et respectés comme vos frères. »',
        explanation: 'Interdiction formelle de maltraiter les serviteurs et obligation de les émanciper après un temps de labeur.',
      ),
      HistoricalDecreeArticle(
        number: 24,
        title: 'Dignité et Droits des Femmes',
        quote: '« Ne portez jamais atteinte à la dignité de la femme, mère de la nation et gardienne de nos foyers. »',
        explanation: 'Protection juridique intégrale des femmes et reconnaissance solennelle de leur rôle politique au conseil.',
      ),
      HistoricalDecreeArticle(
        number: 41,
        title: 'Préservation des Forêts & de l\'Environnement',
        quote: '« La brousse et les arbres sont des dons sacrés ; nul ne mettra le feu aux forêts sans l\'accord des maîtres de la terre. »',
        explanation: 'Première loi écologique historique protégeant la faune, la flore et les cours d\'eau du Sahel.',
      ),
    ],
    chapters: [
      CharacterStoryChapter(
        id: 'prophetie',
        chapterNumber: 'CHAPITRE I',
        title: 'La Prophétie & L\'Enfance Éprouvée',
        kicker: 'L\'AUBE DU MANDEN • NIANI',
        dateAndPlace: 'Cité Royale de Niani • Vers 1190',
        mainImage: 'assets/images/culture/personnages/soundiata_enfant_realiste.jpg',
        fullNarrative:
            'Au cœur du Manden, dans la cité royale de Niani, le roi Naré Maghann Konaté reçoit la visite d\'un mystérieux devin chasseur. La prédiction des anciens est formelle : de son union avec une femme mystique, Sogolon Kedjou, naîtra le plus grand souverain d\'Afrique. Mais à sa naissance, le jeune Soundiata est paralysé des jambes et rampe dans la poussière. Moqué cruellement par la première reine Sassouma Bérété pour favoriser son propre fils Dankaran Touman, l\'enfant endure l\'humiliation avec patience, forgeant dans le silence le destin d\'un empire millénaire.',
        kineticQuotes: [
          'LE GRAND ARBRE DORT DANS LA PETITE GRAINE',
          'INFIRME DE NAISSANCE, FORGÉ PAR LA PATIENCE',
          'LE DESTIN ATTENDAIT SON HEURE GLORIEUSE',
        ],
        accentColor: CultureTheme.orPatrimoine,
        readingDurationSeconds: 38,
      ),
      CharacterStoryChapter(
        id: 'eveil',
        chapterNumber: 'CHAPITRE II',
        title: 'Le Redressement & Le Baobab Déraciné',
        kicker: 'L\'ARC D\'ACIER DES MAÎTRES FORGERONS',
        dateAndPlace: 'Cour royale de Niani • Vers 1205',
        mainImage: 'assets/images/culture/personnages/soundiata_redressement_realiste.jpg',
        fullNarrative:
            'À la mort du roi, Sassouma installe son fils sur le trône et humilie Sogolon en lui refusant avec mépris une poignée de feuilles de baobab. Devant les larmes brûlantes de sa mère, Soundiata prononce un serment inoubliable : « Mère, sèche tes larmes, aujourd\'hui je t\'apporterai le baobab tout entier avec ses racines ! » Il ordonne aux forgerons du feu de lui fondre une barre de fer colossale. S\'appuyant de toute la force de sa volonté, la barre d\'acier plie sous sa poigne surhumaine. Dans un cri titanesque qui fait trembler la terre, Soundiata se dresse enfin sur ses deux jambes, déracine l\'arbre géant et le dépose aux pieds de sa mère. Le Lion du Manden s\'est éveillé !',
        kineticQuotes: [
          '« MÈRE, AUJOURD\'HUI JE T\'APPORTE LE BAOBAB ENTIER ! »',
          'LA BARRE D\'ACIER SE PLIA SOUS SA POIGNE',
          'LE LION DU MANDEN S\'EST DRESSÉ SUR SES JAMBES',
        ],
        accentColor: CultureTheme.accentOrange,
        readingDurationSeconds: 44,
      ),
      CharacterStoryChapter(
        id: 'exil',
        chapterNumber: 'CHAPITRE III',
        title: 'L\'Exil Formateur & L\'Art de la Guerre',
        kicker: 'LES PISTES DU SAHEL & LE ROYAUME DE MÉMA',
        dateAndPlace: 'Pistes de Tabon, Ghana & Royaume de Méma • 1215 – 1234',
        mainImage: 'assets/images/culture/personnages/soundiata_portrait_realiste.jpg',
        fullNarrative:
            'Pour échapper aux complots mortels de Sassouma, Sogolon prend les routes de l\'exil avec ses enfants. De royaume en royaume, de Tabon jusqu\'aux confins du Sahel, Soundiata s\'endurcit. Au royaume de Méma, le roi Moussa Tounkara l\'accueille en fils et en frère d\'armes. Là-bas, Soundiata devient un cavalier d\'élite hors pair, un maître archer et un diplomate respecté de tous les chefs de clans. Respecté pour sa loyauté et sa force sage, il prend le commandement des troupes de Méma tout en préservant intacte la mémoire sacrée de sa patrie d\'origine.',
        kineticQuotes: [
          'L\'EXIL EST LA FORGE DES GRANDS BÂTISSEURS',
          'MAÎTRE CAVALIER ET STRATÈGE INCONTESTÉ',
          'LE RESPECT ET LA FRATERNITÉ DES PEUPLES',
        ],
        accentColor: CultureTheme.ocreTerre,
        readingDurationSeconds: 38,
      ),
      CharacterStoryChapter(
        id: 'appel',
        chapterNumber: 'CHAPITRE IV',
        title: 'L\'Appel du Manden & Le Soulèvement des Clans',
        kicker: 'L\'INVASION DU SOSSO & L\'UNION SACRÉE',
        dateAndPlace: 'Aux frontières du Manden • 1234',
        mainImage: 'assets/images/culture/personnages/soundiata_portrait_realiste.jpg',
        fullNarrative:
            'Au Manden, le roi-sorcier forgeron Soumaoro Kanté du Sosso envahit le pays avec ses légions de fer, massacre la famille royale et instaure un régime de terreur. Face au désespoir, des notables mandingues et des griots traversent le continent, apportant des légumes de la terre ancestrale pour supplier l\'héritier légitime de revenir. Entendant les cris de détresse de son peuple, Soundiata quitte Méma et rallie tous les souverains frères : Kamandjan Camara qui fend la montagne de Siby, Fakoli Doumbia et les fiers chasseurs mandingues s\'unissent dans une coalition invincible pour la liberté.',
        kineticQuotes: [
          '« MANDENMANSA, REVIENS ! TON PEUPLE T\'ATTEND »',
          'L\'UNION SACRÉE DE TOUS LES CLANS DU NIGER',
          'LES FORCES DE LA LIBERTÉ EN MARCHE',
        ],
        accentColor: CultureTheme.orPatrimoine,
        readingDurationSeconds: 40,
      ),
      CharacterStoryChapter(
        id: 'kirina',
        chapterNumber: 'CHAPITRE V',
        title: 'La Bataille Historique de Kirina (1235)',
        kicker: 'LE CHOC DES EMPIRES & LA FLÈCHE SACRÉE',
        dateAndPlace: 'Plaines de Kirina, Koulikoro • 1235',
        mainImage: 'assets/images/culture/personnages/soundiata_kirina_realiste.jpg',
        antagonistImage: 'assets/images/culture/personnages/soumaoro_kante_realiste.jpg',
        fullNarrative:
            'En 1235, dans la plaine brûlante de Kirina, les armées du Sosso et du Manden s\'affrontent dans un fracas légendaire. Face aux sortilèges terrifiants de Soumaoro qui le rendent invulnérable aux lames, Soundiata utilise le secret mystique percé par sa sœur Nana Triban et le griot Balla Fasséké : le seul totem capable de briser sa magie est un ergot de coq blanc. D\'un tir d\'arc magistral guidé par les ancêtres, Soundiata décoche la flèche sacrée qui érafle le roi-sorcier. Privé de sa force occulte, Soumaoro s\'enfuit affolé et s\'évanouit à tout jamais dans les falaises rocheuses de Koulikoro. Le Manden est libéré !',
        kineticQuotes: [
          'KIRINA 1235 : LE CHOC DES EMPIRES',
          'FACE AUX SORTILÈGES DU ROI-SORCIER DU SOSSO',
          'LA FLÈCHE SACRÉE BRISE LE SORTILÈGE DU TYRAN',
        ],
        accentColor: CultureTheme.ocreTerre,
        readingDurationSeconds: 42,
      ),
      CharacterStoryChapter(
        id: 'charte',
        chapterNumber: 'CHAPITRE VI',
        title: 'Kouroukan Fouga & La Première Charte Humaine',
        kicker: 'PREMIÈRE DÉCLARATION DES DROITS HUMAINS • UNESCO',
        dateAndPlace: 'Kangaba, sous le grand baobab sacré • 1236',
        mainImage: 'assets/images/culture/personnages/soundiata_charte_realiste.jpg',
        fullNarrative:
            'Au lendemain de la victoire, Soundiata réunit l\'assemblée générale des sages, des reines, des maîtres forgerons et des chasseurs sous le grand baobab de Kangaba à Kouroukan Fouga. Proclamé Mansa suprême, il dicte une constitution orale révolutionnaire de quarante-quatre articles sacrés : la Charte du Manden. Elle sacralise l\'existence humaine en décrétant que « Toute vie est une vie, et nul ne doit humilier son semblable ». Elle protège la dignité de la femme, abolit les supplices de la servitude, instaure la paix éternelle par la parenté à plaisanterie (Sinankunya) et défend la nature. Première constitution humaniste de l\'humanité, elle fonde l\'Empire du Mali.',
        kineticQuotes: [
          'KOUROUKAN FOUGA • 1236',
          '« TOUTE VIE HUMAINE EST UNE VIE »',
          'PATRIMOINE IMMATÉRIEL UNIVERSEL DE L\'UNESCO',
        ],
        accentColor: CultureTheme.orPatrimoine,
        readingDurationSeconds: 44,
      ),
      CharacterStoryChapter(
        id: 'heritage',
        chapterNumber: 'CHAPITRE VII',
        title: 'L\'Empire du Mali & La Mémoire Vivante des Griots',
        kicker: 'HUIT SIÈCLES DE GLOIRE & DE CONCORDE SOCIALE',
        dateAndPlace: 'Du Sahara à l\'Atlantique • 1236 – 1255 & Aujourd\'hui',
        mainImage: 'assets/images/culture/personnages/soundiata_portrait_realiste.jpg',
        fullNarrative:
            'Mansa Soundiata Keïta fit régner la justice, la prospérité et la concorde jusqu\'en 1255, léguant au monde l\'un des empires les plus florissants et respectés de l\'histoire humaine, reliant les mines d\'or du Djoliba aux universités de Tombouctou. Huit siècles plus tard, la voix des griots et le chant de la kora continuent de célébrer sa mémoire le long du fleuve Niger. De l\'enfant rampant dans la poussière au bâtisseur immortel de l\'Empire du Mali, Soundiata Keïta demeure le flambeau éternel du courage, de la dignité et de la grandeur africaine.',
        kineticQuotes: [
          'HUIT SIÈCLES D\'HISTOIRE ET DE FIERTÉ PURE',
          'DE LA POUSSIÈRE D\'ENFANCE AU ROI DES ROIS',
          'LE FLAMBEAU ÉTERNEL DE LA DIGNITÉ AFRICAINE',
        ],
        accentColor: CultureTheme.accentOrange,
        readingDurationSeconds: 38,
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 2. MANSA MOUSSA — LE SOUVERAIN D'OR & BÂTISSEUR DU SAVOIR (1312 – 1337)
  // ════════════════════════════════════════════════════════════════════════════
  static const HistoricalFigureSaga mansaMoussa = HistoricalFigureSaga(
    figureId: 'perso_mansa_moussa',
    figureName: 'Mansa Moussa',
    titleHonorifique: 'Le Souverain d\'Or & Bâtisseur du Savoir Universel',
    sagaTitle: 'Épopée de Mansa Moussa',
    sagaSubtitle: 'L\'Âge d\'Or Impérial, l\'Or du Sahel & Les Universités de Tombouctou',
    primaryAccent: CultureTheme.orPatrimoine,
    secondaryAccent: CultureTheme.sable,
    landmarkChapterId: 'savoir',
    landmarkModalButtonText: 'CONSULTER LES DÉCRETS DU SAVOIR (1327)',
    landmarkModalTitle: 'Décrets du Savoir & Chartes des Universités (1327)',
    landmarkModalSubtitle: 'Édits impériaux de Tombouctou & Mosquée Djingareyber',
    landmarkArticles: [
      HistoricalDecreeArticle(
        number: 1,
        title: 'Sanctuaire Universitaire de Sankoré',
        quote: '« La recherche du savoir est le plus noble devoir de l\'empire ; savants et étudiants seront logés et nourris aux frais du trésor impérial. »',
        explanation: 'Financement perpétuel accordé par Mansa Moussa pour attirer mathématiciens, astronomes et médecins du monde entier.',
      ),
      HistoricalDecreeArticle(
        number: 2,
        title: 'Protection des Manuscrits Anciens',
        quote: '« Tout livre copié ou traduit à Tombouctou recevra son pesant en or fin, car la sagesse dépasse l\'éclat des richesses terrestres. »',
        explanation: 'Institution d\'un marché florissant du livre et de la calligraphie faisant de Tombouctou le conservatoire intellectuel de l\'Afrique.',
      ),
      HistoricalDecreeArticle(
        number: 3,
        title: 'Édification de Djingareyber',
        quote: '« La grande maison de prière sera bâtie en briques de terre sainte avec le concours des maîtres d\'Al-Andalus et des artisans du Niger. »',
        explanation: 'Commande passée en 1327 à Abou Ishaq es-Sahéli, inaugurant l\'architecture monumentale en banco soudano-sahélienne.',
      ),
      HistoricalDecreeArticle(
        number: 4,
        title: 'Équité Commerciale Transsaharienne',
        quote: '« Nul marchand de sel, d\'or ou de soieries ne sera spolié sur les marchés de Gao et Tombouctou ; la sécurité des caravanes est totale. »',
        explanation: 'Création d\'un corps de gardes du désert assurant la paix commerciale de l\'Atlantique au fleuve Nil.',
      ),
      HistoricalDecreeArticle(
        number: 5,
        title: 'Partage de la Richesse',
        quote: '« L\'or est un prêt divin destiné à soulager l\'indigent, construire des ponts de concorde et honorer la dignité humaine. »',
        explanation: 'Philosophie de générosité philanthropique déployée lors du pèlerinage mémorable de 1324.',
      ),
    ],
    chapters: [
      CharacterStoryChapter(
        id: 'accession',
        chapterNumber: 'CHAPITRE I',
        title: 'L\'Héritage d\'Aboubakri II & La Puissance de Niani',
        kicker: 'L\'AVÈNEMENT DU MONARQUE ÉCLAIRÉ • 1312',
        dateAndPlace: 'Cour Impériale de Niani • 1312',
        mainImage: 'assets/images/culture/personnages/mansa_moussa.jpg',
        fullNarrative:
            'En 1312, après le départ audacieux du Mansa Aboubakri II parti explorer les limites de l\'océan Atlantique à la tête d\'une immense armada de deux mille navires, son régent et petit-neveu de Soundiata, Kankou Moussa, monte sur le trône de l\'Empire du Mali. Héritier d\'une paix séculaire et d\'une organisation politique sans faille, il prend la tête d\'un territoire immense qui s\'étend de l\'Atlantique au méandre du fleuve Niger. Sous sa gouvernance visionnaire, le Mali structure ses routes commerciales, sécurise l\'exploitation des mines d\'or de Bouré et de Bambouk, et s\'impose comme la plus grande puissance économique du monde médiéval.',
        kineticQuotes: [
          'L\'OR ET LA SAGESSE GUIDENT L\'EMPIRE DU MALI',
          'HÉRITIER D\'ABOUBAKRI II ET DES FONDATEURS',
          'LA PAIX CIVILE ET LA PROSPÉRITÉ DES CLANS',
        ],
        accentColor: CultureTheme.orPatrimoine,
        readingDurationSeconds: 40,
      ),
      CharacterStoryChapter(
        id: 'pelerinage',
        chapterNumber: 'CHAPITRE II',
        title: 'Le Pèlerinage de 1324 & Le Rayonnement Mondial',
        kicker: 'LA CARAVANE D\'OR À TRAVERS LE SAHARA',
        dateAndPlace: 'Le Caire, Alexandrie & La Mecque • 1324 – 1325',
        mainImage: 'assets/images/culture/personnages/mansa_moussa.jpg',
        fullNarrative:
            'En 1324, Mansa Moussa entreprend le voyage le plus prodigieux de l\'histoire médiévale : le pèlerinage à La Mecque. Traversant le désert du Sahara, sa caravane compte plus de soixante mille personnes, des milliers de dignitaires parés de soieries persanes et quatre-vingts dromadaires transportant chacun plus de cent trente kilos de poudre d\'or pur. Arrivé au Caire, le sultan mamelouk al-Nasir Muhammad est subjugué par sa piété et sa distinction aristocratique. La générosité inouïe de Mansa Moussa, distribuant des lingots d\'or aux indigents et aux sanctuaires, fut telle qu\'elle dévalua le cours mondial de l\'or sur tout le bassin méditerranéen pendant plus d\'une décennie.',
        kineticQuotes: [
          'SOIXANTE MILLE HOMMES À TRAVERS LE SAHARA',
          'L\'OR DU MALI ÉBLOUIT LE CAIRE ET LE MONDE',
          'L\'EMPIRE DU MALI ENTRE DANS L\'HISTOIRE UNIVERSELLE',
        ],
        accentColor: CultureTheme.sable,
        readingDurationSeconds: 44,
      ),
      CharacterStoryChapter(
        id: 'djingareyber',
        chapterNumber: 'CHAPITRE III',
        title: 'Le Retour Triomphal & La Mosquée Djingareyber (1327)',
        kicker: 'GÉNIE ARCHITECTURAL EN TERRE CRUE',
        dateAndPlace: 'Tombouctou & Gao • 1326 – 1327',
        mainImage: 'assets/images/culture/monuments/monument_djingareyber/wm_djin_1.jpg',
        fullNarrative:
            'À son retour en 1325, Mansa Moussa ne rapporte pas seulement le prestige spirituel ; il invite à sa cour des juristes, des mathématiciens, des théologiens et le célèbre poète et architecte andalou Abou Ishaq es-Sahéli. Émerveillé par la position stratégique de Tombouctou au carrefour des pistes sahariennes et du fleuve Djoliba, il commande en 1327 l\'édification de la Grande Mosquée Djingareyber. Conçue entièrement en briques de banco, en terre cuite et en poutres de rônier locales, cette merveille d\'ingénierie bioclimatique défie les siècles et fonde l\'architecture soudano-sahélienne que le monde admire encore aujourd\'hui.',
        kineticQuotes: [
          '1327 : NAISSANCE DU CHEF-D\'ŒUVRE DE DJINGAREYBER',
          'L\'ARCHITECTE ES-SAHÉLI ET LA TERRE SACRÉE DU SAHEL',
          'DES SIÈCLES DE FOI ET D\'INGÉNIERIE SOUDANAISE',
        ],
        accentColor: CultureTheme.orPatrimoine,
        readingDurationSeconds: 42,
      ),
      CharacterStoryChapter(
        id: 'savoir',
        chapterNumber: 'CHAPITRE IV',
        title: 'L\'Université de Sankoré & La Cité des Savoirs',
        kicker: 'CENTRES UNIVERSITAIRES & MANUSCRITS ANCIENS',
        dateAndPlace: 'Université de Sankoré, Tombouctou • 1327 – 1335',
        mainImage: 'assets/images/culture/monuments/monument_sankore/wm_san_1.jpg',
        fullNarrative:
            'Fervent protecteur des sciences, Mansa Moussa transforme Tombouctou en un phare intellectuel universel. Il finance richement la madrasa de Sankoré, qui devient l\'une des plus illustres universités du monde, accueillant jusqu\'à vingt-cinq mille étudiants venus d\'Afrique du Nord, d\'Andalousie et du Proche-Orient. Astronomie, médecine, algèbre, droit, philosophie et grammaire y sont enseignés avec une rigueur exemplaire. Les bibliothèques privées s\'enrichissent de centaines de milliers de manuscrits calligraphiés à la main, consacrant l\'adage des sages : « Le sel vient du nord, l\'or vient du sud, mais la parole de Dieu et les trésors de la science ne se trouvent qu\'à Tombouctou ».',
        kineticQuotes: [
          'VINGT-CINQ MILLE ÉTUDIANTS SOUS LES COLONNADES DE SANKORÉ',
          'L\'ASTRONOMIE, LA MÉDECINE ET LE DROIT UNIVERSEL',
          'LES MANUSCRITS DE TOMBOUCTOU, PHARE DU CONTINENT',
        ],
        accentColor: CultureTheme.accentOrange,
        readingDurationSeconds: 44,
      ),
      CharacterStoryChapter(
        id: 'atlas',
        chapterNumber: 'CHAPITRE V',
        title: 'L\'Atlas Catalan de 1375 & La Postérité Éternelle',
        kicker: 'LE REGARD DU MONDE SUR LA RICHESSE DU MALI',
        dateAndPlace: 'De Palma de Majorque au Sahara • 1375 à nos jours',
        mainImage: 'assets/images/culture/villes/tombouctou_ville.jpg',
        fullNarrative:
            'À la fin de son règne en 1337, Mansa Moussa laisse un empire pacifié, respecté et prospère, doté d\'une administration exemplaire. En 1375, le cartographe majorquin Abraham Cresques dessine le célèbre Atlas Catalan : au cœur du continent africain figure Mansa Moussa, assis majestueusement sur son trône en or, coiffé d\'une couronne étincelante et brandissant un globe d\'or pur vers les souverains d\'Europe. Il symbolise pour l\'éternité l\'âge d\'or de la civilisation malienne, prouvant que la grandeur d\'un monarque s\'évalue autant par sa générosité et ses universités que par la force de son or.',
        kineticQuotes: [
          'L\'ATLAS CATALAN : LE SOUVERAIN D\'OR IMMORTALISÉ',
          'LA RICHESSE MATÉRIELLE AU SERVICE DU SAVOIR',
          'L\'ÂGE D\'OR ÉTERNEL DU ROYAUME DU MALI',
        ],
        accentColor: CultureTheme.orPatrimoine,
        readingDurationSeconds: 40,
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 3. ASKIA MOHAMMED — ASKIA LE GRAND (1443 – 1538)
  // ════════════════════════════════════════════════════════════════════════════
  static const HistoricalFigureSaga askiaMohammed = HistoricalFigureSaga(
    figureId: 'perso_askia_mohammed',
    figureName: 'Askia Mohammed',
    titleHonorifique: 'Askia le Grand & Réformateur de l\'Empire Songhoï',
    sagaTitle: 'Épopée d\'Askia Mohammed',
    sagaSubtitle: 'La Dynastie des Askia, l\'État Moderne & La Pyramide de Gao',
    primaryAccent: CultureTheme.ocreTerre,
    secondaryAccent: CultureTheme.orPatrimoine,
    landmarkChapterId: 'reforme',
    landmarkModalButtonText: 'CONSULTER LE CODE DE JUSTICE D\'ASKIA (1498)',
    landmarkModalTitle: 'Code de Justice & Réformes Administratives (1498)',
    landmarkModalSubtitle: 'Organisation d\'État à Gao & Fleuve Niger',
    landmarkArticles: [
      HistoricalDecreeArticle(
        number: 1,
        title: 'Standardisation des Poids et Mesures',
        quote: '« Tout marché de Gao, Tombouctou et Djenné appliquera les étalons officiels impériaux ; nulle fraude sur le grain et l\'or ne sera tolérée. »',
        explanation: 'Création d\'un système métrologique unifié protégeant les paysans et les marchands honnêtes.',
      ),
      HistoricalDecreeArticle(
        number: 2,
        title: 'Indépendance de la Justice des Cadis',
        quote: '« Le cadi juge selon la loi et la conscience ; nul gouverneur ni prince ne peut modifier son verdict sous peine de destitution. »',
        explanation: 'Séparation exemplaire du pouvoir judiciaire et du pouvoir exécutif dans l\'Afrique du XVe siècle.',
      ),
      HistoricalDecreeArticle(
        number: 3,
        title: 'La Flotte du Niger & Le Hi-Koy',
        quote: '« Le grand amiral du fleuve veille à la paix des eaux, escortant les pirogues des voyageurs et garantissant le commerce des cités riveraines. »',
        explanation: 'Mise sur pied d\'une force navale fluviale professionnelle contrôlant le fleuve Niger sur plus de deux mille kilomètres.',
      ),
      HistoricalDecreeArticle(
        number: 4,
        title: 'Greniers Impériaux de Secours',
        quote: '« Dans chaque province, des greniers de réserve seront constitués pour nourrir les populations en temps de sécheresse. »',
        explanation: 'Planification économique prévenant toute disette au sein des provinces de l\'Empire Songhoï.',
      ),
    ],
    chapters: [
      CharacterStoryChapter(
        id: 'anfao',
        chapterNumber: 'CHAPITRE I',
        title: 'L\'Avènement de la Dynastie des Askia (1493)',
        kicker: 'LA BATAILLE D\'ANFAO & L\'ORDRE NOUVEAU',
        dateAndPlace: 'Plaine d\'Anfao près de Gao • 1493',
        mainImage: 'assets/images/culture/personnages/askia_mohammed.jpg',
        fullNarrative:
            'Né vers 1443 dans le clan prestigieux des Touré, Mohammed est un brillant général et gouverneur de province sous le règne conquérant de Sonni Ali Ber. À la disparition de ce dernier en 1492, son successeur refuse d\'accorder les réformes attendues par les érudits et les marchands. Le 3 mars 1493, lors de la bataille décisive d\'Anfao, Mohammed défait les troupes loyalistes et prend le pouvoir. Lorsque les filles de Sonni Ali apprennent son triomphe, elles s\'écrient « A si tya ! » (« Il ne le sera pas ! »), exclamation qui deviendra son titre glorieux : l\'Askia, le souverain résolu, juste et réformateur.',
        kineticQuotes: [
          'ANFAO 1493 : LE TOURNANT MAJEUR DU SONGHOÏ',
          'L\'ASKIA : LA VOLONTÉ D\'UN HOMME D\'ÉTAT SAGE',
          'FONDATEUR D\'UNE NOUVELLE ÈRE DE PROGRÈS',
        ],
        accentColor: CultureTheme.ocreTerre,
        readingDurationSeconds: 40,
      ),
      CharacterStoryChapter(
        id: 'armee',
        chapterNumber: 'CHAPITRE II',
        title: 'L\'Armée de Métier & La Flotte Fluviale du Hi-Koy',
        kicker: 'PROVINCES DÉCENTRALISÉES & FLOTTE DU FLEUVE NIGER',
        dateAndPlace: 'Gao & Fleuve Djoliba • 1495 – 1500',
        mainImage: 'assets/images/culture/villes/gao_dune_rose.jpg',
        fullNarrative:
            'Askia Mohammed transforme radicalement la structure de l\'Empire Songhoï. Il remplace les levées paysannes par une armée de métier permanente, hautement disciplinée, comprenant une cavalerie lourde redoutable et des corps d\'archers chevronnés. Sur le fleuve Niger, il crée une véritable flotte navale militaire commandée par le Hi-koy (grand amiral des pirogues), garantissant le contrôle des voies navigables et la sécurité absolue du transport des denrées. Il divise l\'empire en provinces dirigées par des gouverneurs révocables, instaurant un appareil fiscal rigoureux et une chancellerie diplomatique moderne.',
        kineticQuotes: [
          'UNE ARMÉE PROFESSIONNELLE ET UNE MARINE FLUVIALE',
          'LE HI-KOY : MAÎTRE DU MAJESTUEUX FLEUVE NIGER',
          'UNE ADMINISTRATION MODERNE AU CŒUR DU SAHEL',
        ],
        accentColor: CultureTheme.orPatrimoine,
        readingDurationSeconds: 42,
      ),
      CharacterStoryChapter(
        id: 'reforme',
        chapterNumber: 'CHAPITRE III',
        title: 'Le Pèlerinage des Savants & L\'Unification Commerciale',
        kicker: 'RENCONTRE AVEC AL-SUYUTI & COMMERCE ÉQUITABLE',
        dateAndPlace: 'Le Caire, Médine & Gao • 1496 – 1498',
        mainImage: 'assets/images/culture/personnages/askia_mohammed.jpg',
        fullNarrative:
            'Entre 1496 et 1498, Askia Mohammed accomplit son pèlerinage à La Mecque avec une suite de mille fantassins et trois cent mille pièces d\'or. Au Caire, il s\'entretient longuement avec le grand juriste encyclopédiste Al-Suyuti et consulte les plus brillants penseurs sur l\'art de gouverner avec justice. À son retour, il standardise les poids et mesures dans tous les marchés de Gao, Tombouctou et Djenné, nomme des juges intègres (cadis) indépendants du pouvoir politique, et réprime sévèrement la fraude et l\'usure. Le Songhoï devient un modèle de probité et d\'équité juridique.',
        kineticQuotes: [
          'STANDARDISATION DES POIDS ET MESURES DU COMMERCE',
          'DES JUGES INDÉPENDANTS POUR RENDRE LA JUSTICE',
          'PROBITÉ, SAVOIR ET ÉQUITÉ DANS TOUT LE SONGHOÏ',
        ],
        accentColor: CultureTheme.ocreTerre,
        readingDurationSeconds: 42,
      ),
      CharacterStoryChapter(
        id: 'tombeau',
        chapterNumber: 'CHAPITRE IV',
        title: 'Le Tombeau Pyramidal des Askia & La Postérité (UNESCO)',
        kicker: 'PYRAMIDE DE TERRE CRUE • GLOIRE ÉTERNELLE DE GAO',
        dateAndPlace: 'Gao • 1495 – 1538 & Présent',
        mainImage: 'assets/images/culture/monuments/monument_tombeau_askia/wm_tomb_1.jpg',
        fullNarrative:
            'À Gao, sa capitale impériale, Askia Mohammed fait ériger un complexe funéraire unique au monde : le Tombeau des Askia, une pyramide de terre crue de dix-sept mètres de hauteur avec ses échafaudages de bois apparents en rônier, ses deux mosquées à toit plat et sa nécropole sacrée. Même après sa déposition dans sa vieillesse par son fils Askia Moussa en 1528, Askia Mohammed conserva le respect unanime de ses peuples jusqu\'à son repos éternel en 1538 à l\'âge vénérable de quatre-vingt-quinze ans. Inscrit au Patrimoine Mondial de l\'UNESCO, son tombeau pyramidal veille sur le fleuve Niger comme le symbole immortel de l\'intelligence d\'État et de la grandeur africaine.',
        kineticQuotes: [
          'LE TOMBEAU PYRAMIDAL DE GAO • TRÉSOR DE L\'UNESCO',
          'DIX-SEPT MÈTRES DE MAJESTÉ EN BANCO SUR LE FLEUVE NIGER',
          'L\'INTELLIGENCE D\'ÉTAT GRAVÉE DANS LES MÉMOIRES',
        ],
        accentColor: CultureTheme.orPatrimoine,
        readingDurationSeconds: 44,
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 4. BABEMBA TRAORÉ — LE HÉROS DE SIKASSO (1855 – 1898)
  // ════════════════════════════════════════════════════════════════════════════
  static const HistoricalFigureSaga babembaTraore = HistoricalFigureSaga(
    figureId: 'perso_babemba',
    figureName: 'Babemba Traoré',
    titleHonorifique: 'Roi du Kénédougou & Héros Suprême de la Résistance',
    sagaTitle: 'Épopée de Babemba Traoré',
    sagaSubtitle: 'Le Tata de Sikasso, le Siège Héroïque & « Anka sa ni ka malo ! »',
    primaryAccent: CultureTheme.accentOrange,
    secondaryAccent: CultureTheme.ocreTerre,
    antagonistChapterId: 'siege',
    antagonistPrimaryLabel: 'VOIR BABEMBA TRAORÉ (MAMELON)',
    antagonistSecondaryLabel: 'VOIR LES REMPARTS DU TATA (SIKASSO)',
    landmarkChapterId: 'serment',
    landmarkModalButtonText: 'CONSULTER LE SERMENT DU KÉNÉDOUGOU (1898)',
    landmarkModalTitle: 'Serment de Dignité du Kénédougou (1898)',
    landmarkModalSubtitle: 'Résolution patriotique & Défense de Sikasso',
    landmarkArticles: [
      HistoricalDecreeArticle(
        number: 1,
        title: 'La Devise Suprême d\'Honneur',
        quote: '« Anka sa ni ka malo ! — Plutôt la mort que la honte de l\'asservissement ou de la capitulation. »',
        explanation: 'Serment absolu guidant le roi et son armée jusqu\'au sacrifice suprême du 1er mai 1898.',
      ),
      HistoricalDecreeArticle(
        number: 2,
        title: 'Inviolabilité du Territoire',
        quote: '« La terre de nos aïeux ne sera ni cédée, ni négociée avec l\'envahisseur ; chaque pouce de terre sera défendu. »',
        explanation: 'Refus solennel opposé par Babemba à toutes les sommations de reddition des colonnes militaires.',
      ),
      HistoricalDecreeArticle(
        number: 3,
        title: 'Solidarité Civile du Tata',
        quote: '« Tous les habitants réfugiés derrière les remparts partagent également l\'eau des puits et les réserves de mil. »',
        explanation: 'Organisation sociale assurant la subsistance de plus de quarante mille citoyens pendant les mois de siège.',
      ),
      HistoricalDecreeArticle(
        number: 4,
        title: 'Honneur aux Artisans Forgerons',
        quote: '« Gloire aux forgerons et maçons qui coulent les munitions et relèvent les brèches sous les tirs d\'artillerie. »',
        explanation: 'Reconnaissance du dévouement héroïque des artisans locaux tenant les murs jour et nuit.',
      ),
    ],
    chapters: [
      CharacterStoryChapter(
        id: 'kenedougou',
        chapterNumber: 'CHAPITRE I',
        title: 'L\'Héritage des Traoré & Le Trône du Kénédougou',
        kicker: 'SIKASSO CAPITALE • FRATERNITÉ D\'ARMES AVEC TIÉBA',
        dateAndPlace: 'Palais Royal de Sikasso • 1877 – 1893',
        mainImage: 'assets/images/culture/personnages/babemba_traore.jpg',
        fullNarrative:
            'Né en 1855, Babemba est le frère cadet et le compagnon d\'armes le plus fidèle du roi Tiéba Traoré. Ensemble, ils fondent la puissance du Royaume du Kénédougou face aux turbulences régionales. Dès 1877, ils choisissent Sikasso comme capitale et entreprennent de la fortifier avec une détermination farouche. Lieutenant général de l\'armée royale, Babemba fait preuve d\'un courage téméraire et d\'une loyauté absolue envers son peuple senoufo et mandingue. À la mort subite de Tiéba en 1893 à Bama, Babemba monte sur le trône et jure de défendre jusqu\'au dernier souffle la liberté et la souveraineté de sa terre.',
        kineticQuotes: [
          'FRÈRES D\'ARMES ET BÂTISSEURS DE SIKASSO',
          'L\'INDÉPENDANCE DU KÉNÉDOUGOU COMME DEVOIR SACRÉ',
          'LA FLAMME DE LA RÉSISTANCE S\'ALLUME',
        ],
        accentColor: CultureTheme.accentOrange,
        readingDurationSeconds: 40,
      ),
      CharacterStoryChapter(
        id: 'tata',
        chapterNumber: 'CHAPITRE II',
        title: 'L\'Inexpugnable Tata de Sikasso (9 km de remparts)',
        kicker: 'LE CHEF-D\'ŒUVRE MILITAIRE DE TERRE ARMÉE',
        dateAndPlace: 'Les remparts du Tata, Sikasso • 1887 – 1895',
        mainImage: 'assets/images/culture/monuments/monument_tata_sikasso/wm_tata_1.jpg',
        fullNarrative:
            'Pour protéger Sikasso des assauts ennemis, Babemba parachève l\'édification du Tata : une gigantesque muraille défensive en terre crue de neuf kilomètres de circonférence, haute de six mètres et large de plusieurs mètres à sa base, protégée par des tours de guet crénelées et un fossé infranchissable. La muraille comprend trois enceintes imbriquées : le Dionfouto pour la population civile, le grand rempart militaire et le sanctuaire du Mamelon. Dès 1887-1888, l\'armée de Samory Touré avait assiégé Sikasso pendant quinze mois sans jamais réussir à franchir ce rempart titanesque. Le Tata devient le symbole vivant de l\'invincibilité africaine.',
        kineticQuotes: [
          'NEUF KILOMÈTRES DE REMPARTS INEXPUGNABLES',
          'LE TATA : CHEF-D\'ŒUVRE MILITAIRE DU KÉNÉDOUGOU',
          'QUINZE MOIS DE SIÈGE REPOUSSÉS AVEC BRAVOURE',
        ],
        accentColor: CultureTheme.ocreTerre,
        readingDurationSeconds: 42,
      ),
      CharacterStoryChapter(
        id: 'siege',
        chapterNumber: 'CHAPITRE III',
        title: 'La Bataille d\'Avril 1898 & Les Assauts d\'Artillerie',
        kicker: 'LA PUISSANCE COLONIALE FACE AU REMPART D\'HONNEUR',
        dateAndPlace: 'Plaines et portes de Sikasso • Avril 1898',
        mainImage: 'assets/images/culture/villes/sikasso_ville.jpg',
        antagonistImage: 'assets/images/culture/monuments/monument_tata_sikasso/wm_tata_1.jpg',
        fullNarrative:
            'En avril 1898, les troupes coloniales françaises dirigées par le colonel Audéoud marchent sur Sikasso avec une puissante artillerie lourde de canons de siège. Devant les sommations de capitulation et les promesses de reddition honorable, Babemba oppose un refus méprisant : un roi libre ne négocie pas l\'asservissement de sa patrie. Pendant trois semaines, les bombardements acharnés pilonnent sans relâche les murs en terre du Tata. Les guerriers du Kénédougou, postés aux meurtrières, repoussent chaque assaut d\'infanterie avec une bravoure prodigieuse, réparant la nuit sous le feu les brèches béantes ouvertes par les obus.',
        kineticQuotes: [
          'REFUS CATÉGORIQUE DE TOUTE SOUMISSION',
          'TROIS SEMAINES D\'ASSAUTS ET DE BOMBARDEMENTS',
          'LE COURAGE HÉROÏQUE DES DÉFENSEURS DE SIKASSO',
        ],
        accentColor: CultureTheme.accentOrange,
        readingDurationSeconds: 42,
      ),
      CharacterStoryChapter(
        id: 'serment',
        chapterNumber: 'CHAPITRE IV',
        title: 'Le 1er Mai 1898 : « Anka sa ni ka malo ! »',
        kicker: 'LE SACRIFICE IMMORTEL POUR LA DIGNITÉ SUPRÊME',
        dateAndPlace: 'Colline du Mamelon, Sikasso • 1er Mai 1898',
        mainImage: 'assets/images/culture/personnages/babemba_traore.jpg',
        fullNarrative:
            'Le 1er mai 1898 à l\'aube, les canons ouvrent une brèche décisive au sud du grand rempart et les assaillants pénètrent dans la ville en ruine. Refusant avec dédain de fuir ou d\'être capturé vivant pour être exhibé en trophée par l\'ennemi, Babemba monte au sommet de son quartier général près du Mamelon. Dans un geste d\'une dignité stoïque sublime, il ordonne à ses fidèles gardes de ne point céder à la panique, prononce sa devise immortelle : « Anka sa ni ka malo ! » (« Plutôt la mort que la honte ! ») et se donne la mort. Par son sacrifice, Babemba entre dans le panthéon des immortels comme le martyr absolu de la dignité patriotique malienne.',
        kineticQuotes: [
          '« ANKA SA NI KA MALO ! »',
          'PLUTÔT LA MORT QUE LA HONTE DE L\'ASSERVISSEMENT',
          'LE MARTYR IMMORTEL DE LA DIGNITÉ NATIONALE',
        ],
        accentColor: CultureTheme.orPatrimoine,
        readingDurationSeconds: 44,
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 5. BITON COULIBALY — LE FONDATEUR DE SÉGOU (1689 – 1755)
  // ════════════════════════════════════════════════════════════════════════════
  static const HistoricalFigureSaga bitonCoulibaly = HistoricalFigureSaga(
    figureId: 'perso_biton_coulibaly',
    figureName: 'Biton Coulibaly',
    titleHonorifique: 'Fondateur du Royaume Bambara de Ségou & Père des Tônjons',
    sagaTitle: 'Épopée de Biton Coulibaly',
    sagaSubtitle: 'Le Serment du Tôn, la Cité des 4 444 Balanzans & La Flotte Fluviale',
    primaryAccent: CultureTheme.orPatrimoine,
    secondaryAccent: CultureTheme.ocreTerre,
    landmarkChapterId: 'balanzans',
    landmarkModalButtonText: 'CONSULTER LE PACTE DES TÔNJONS (1712)',
    landmarkModalTitle: 'Pacte d\'Union des Tônjons (1712)',
    landmarkModalSubtitle: 'Statuts fraternels de Ségou-Koro & Fleuve Niger',
    landmarkArticles: [
      HistoricalDecreeArticle(
        number: 1,
        title: 'Pacte de Sang et d\'Entraide',
        quote: '« Tous les membres du Tôn forment un seul corps et une seule âme ; l\'offense faite à un compagnon blesse l\'assemblée tout entière. »',
        explanation: 'Fondement de l\'armée des Tônjons, soudée par une fraternité transcendant les origines claniques.',
      ),
      HistoricalDecreeArticle(
        number: 2,
        title: 'Protection des Paysans et Moissons',
        quote: '« Les greniers à mil des cultivateurs sont sacrés ; nul guerrier ne pillera le travail de la glèbe sous peine de bannissement. »',
        explanation: 'Discipline stricte assurant l\'autosuffisance alimentaire et la paix civile dans tout le royaume bambara.',
      ),
      HistoricalDecreeArticle(
        number: 3,
        title: 'Traité Fluvial avec les Bozos et Somonos',
        quote: '« Les maîtres des eaux conservent le secret des pirogues et le tribut du poisson ; en échange, ils conduisent la flotte de guerre de Ségou. »',
        explanation: 'Alliance stratégique qui donna à Ségou la suprématie navale sur le cours moyen du fleuve Niger.',
      ),
      HistoricalDecreeArticle(
        number: 4,
        title: 'Conseil des Sages sous les Balanzans',
        quote: '« Les décisions de paix et de justice sont arrêtées sous les balanzans centenaires à l\'écoute de la coutume et des anciens. »',
        explanation: 'Tradition démocratique locale ancrant le pouvoir royal dans le respect des aînés.',
      ),
    ],
    chapters: [
      CharacterStoryChapter(
        id: 'jeunesse',
        chapterNumber: 'CHAPITRE I',
        title: 'La Jeunesse de Mamari & La Fraternité du Tôn',
        kicker: 'DES ASSOCIATIONS DE CHASSE AU COMMANDEMENT • SÉGOU',
        dateAndPlace: 'Cités du fleuve Niger à Ségou • 1710 – 1712',
        mainImage: 'assets/images/culture/personnages/biton_coulibaly.jpg',
        fullNarrative:
            'Né vers 1689 le long du majestueux fleuve Djoliba, Mamari Coulibaly se distingue dès son plus jeune âge par son charisme magnétique, sa générosité proverbiale et son sens exceptionnel de la justice. Élu à la tête du Tôn local — l\'association traditionnelle de travail d\'entraide, de culture et de chasse de la jeunesse —, il prend le titre distinctif de « Biton ». Mamari révolutionne cette confrérie en transformant les liens de camaraderie en un pacte de solidarité indéfectible, transcendant les rivalités de villages pour unir la jeunesse bambara autour d\'un idéal commun d\'entraide et d\'émancipation.',
        kineticQuotes: [
          'LA FORCE DE L\'ASSOCIATION DE JEUNESSE',
          'MAMARI ÉLU CHEF DU TÔN : LA NAISSANCE DE BITON',
          'LA SOLIDARITÉ PLUS FORTE QUE TOUTE DIVISION',
        ],
        accentColor: CultureTheme.orPatrimoine,
        readingDurationSeconds: 38,
      ),
      CharacterStoryChapter(
        id: 'tonjons',
        chapterNumber: 'CHAPITRE II',
        title: 'L\'Ordre des Tônjons & La Fondation du Royaume (1712)',
        kicker: 'LA CRÉATION D\'UNE ARMÉE PERMANENTE DISCIPLINÉE',
        dateAndPlace: 'Ségou-Koro • 1712 – 1725',
        mainImage: 'assets/images/culture/villes/segou_koro.jpg',
        fullNarrative:
            'Vers 1712, Biton Coulibaly opère une innovation institutionnelle majeure dans l\'histoire de l\'Afrique de l\'Ouest. Il affranchit les membres du Tôn des corvées agricoles traditionnelles pour en faire une véritable armée de métier permanente : les « Tônjons ». Liés au chef par un serment d\'allégeance rituel, nourris et entretenus par le trésor commun, les Tônjons forment une force militaire d\'élite dévouée corps et âme à la défense du territoire. Biton fonde sa capitale à Ségou-Koro et établit le Royaume Bambara de Ségou, apportant stabilité, prospérité et sécurité dans une région autrefois déchirée par les rezzous.',
        kineticQuotes: [
          'LES TÔNJONS : L\'ARMÉE D\'ÉLITE DU FLEUVE DJOLIBA',
          '1712 : FONDATION DU ROYAUME BAMBARA DE SÉGOU',
          'SÉGOU-KORO, CITÉ ROYALE DU COURAGE ET DU DROIT',
        ],
        accentColor: CultureTheme.ocreTerre,
        readingDurationSeconds: 42,
      ),
      CharacterStoryChapter(
        id: 'balanzans',
        chapterNumber: 'CHAPITRE III',
        title: 'La Flotte Fluviale & La Cité des 4 444 Balanzans',
        kicker: 'DE BAMAKO À DJENNÉ • LA MAÎTRISE HYDRAULIQUE',
        dateAndPlace: 'Le cours du Niger entre Ségou et Djenné • 1725 – 1745',
        mainImage: 'assets/images/culture/monuments/segou/segou_!.jpg',
        fullNarrative:
            'Comprenant que le fleuve Niger est l\'artère vitale du commerce sahélien, Biton s\'allie étroitement avec les pêcheurs bozos et somonos pour constituer une gigantesque flotte navale fluviale composée de centaines de grandes pirogues de guerre. Grâce à cette maîtrise hydraulique, Ségou étend son influence de Bamako jusqu\'à Djenné et aux portes de Tombouctou. Ségou devient la légendaire « Cité des 4 444 Balanzans » (acacias albida), célèbre pour sa verdure ombragée, ses marchés florissants de mil, de beurre de karité et de poterie, et son hospitalité généreuse qui accueille dignement voyageurs et artisans de toutes contrées.',
        kineticQuotes: [
          'ALLIANCE SACRÉE AVEC LES BOZOS ET LES SOMONOS',
          'UNE FLOTTE DE CENTAINES DE PIROGUES SUR LE FLEUVE',
          'SÉGOU, LA VILLE AUX 4 444 BALANZANS MYSTIQUES',
        ],
        accentColor: CultureTheme.orPatrimoine,
        readingDurationSeconds: 42,
      ),
      CharacterStoryChapter(
        id: 'mausolee',
        chapterNumber: 'CHAPITRE IV',
        title: 'Le Mausolée Royal de Ségou-Koro & La Mémoire Bambara',
        kicker: 'HÉRITAGE SÉCULAIRE DE SOUVERAINETÉ ET DE TRADITION',
        dateAndPlace: 'Sanctuaire de Ségou-Koro • 1755 à nos jours',
        mainImage: 'assets/images/culture/personnages/biton_coulibaly.jpg',
        fullNarrative:
            'À sa mort en 1755 après plus de quarante ans de règne pacificateur, Biton Coulibaly repose dans son imposant tombeau traditionnel en terre crue à Ségou-Koro, tout près de la mosquée historique en banco édifiée pour sa mère. Son mausolée séculaire, entouré de balanzans sacrés, demeure un haut lieu de mémoire nationale, de pèlerinage et de respect des traditions orales du peuple bambara. Les griots continuent d\'entonner au son du balafon et du ngoni les louanges de Mamari Biton Coulibaly, l\'homme qui partit d\'une simple association fraternelle de jeunesse pour bâtir l\'un des plus puissants royaumes d\'Afrique.',
        kineticQuotes: [
          'QUARANTE ANS DE RÈGNE DE PROSPÉRITÉ ET DE FORCE',
          'LE MAUSOLÉE ROYAL DE SÉGOU-KORO EN BANCO',
          'LES LOUANGES DU BALAFON ET DU NGONI ÉTERNEL',
        ],
        accentColor: CultureTheme.ocreTerre,
        readingDurationSeconds: 40,
      ),
    ],
  );

  // ════════════════════════════════════════════════════════════════════════════
  // 6. MODIBO KEÏTA — LE PÈRE DE L'INDÉPENDANCE (1915 – 1977)
  // ════════════════════════════════════════════════════════════════════════════
  static const HistoricalFigureSaga modiboKeita = HistoricalFigureSaga(
    figureId: 'perso_modibo_keita',
    figureName: 'Modibo Keïta',
    titleHonorifique: 'Père de l\'Indépendance & 1er Président de la République du Mali',
    sagaTitle: 'Épopée de Modibo Keïta',
    sagaSubtitle: 'Le 22 Septembre 1960, le Panafricanisme & Le Monument de l\'Indépendance',
    primaryAccent: CultureTheme.orPatrimoine,
    secondaryAccent: CultureTheme.vertNaturel,
    landmarkChapterId: 'independance',
    landmarkModalButtonText: 'CONSULTER LE MANIFESTE DU 22 SEPTEMBRE 1960',
    landmarkModalTitle: 'Manifeste de l\'Indépendance (22 Septembre 1960)',
    landmarkModalSubtitle: 'Acte fondateur de la République du Mali souveraine',
    landmarkArticles: [
      HistoricalDecreeArticle(
        number: 1,
        title: 'Proclamation de Souveraineté Totale',
        quote: '« La République du Mali est proclamée libre, indépendante et maîtresse exclusive de son destin politique et économique. »',
        explanation: 'Discours historique prononcé par Modibo Keïta devant le peuple souverain réuni à Bamako.',
      ),
      HistoricalDecreeArticle(
        number: 2,
        title: 'Continuité avec les Grands Empires',
        quote: '« En choisissant le nom millénaire de Mali, nous renouons avec la grandeur de Soundiata Keïta et de Mansa Moussa. »',
        explanation: 'Filiation spirituelle et patriotique assumée reliant l\'État moderne à huit siècles de gloire africaine.',
      ),
      HistoricalDecreeArticle(
        number: 3,
        title: 'L\'Idéal des États-Unis d\'Afrique',
        quote: '« La République du Mali déclare qu\'elle est prête à abandonner tout ou partie de sa souveraineté au profit de l\'Unité Africaine. »',
        explanation: 'Principe constitutionnel précurseur gravé dans les lois fondamentales de la République.',
      ),
      HistoricalDecreeArticle(
        number: 4,
        title: 'Éducation Populaire et Émancipation',
        quote: '« L\'école est le bien commun de la patrie ; chaque enfant du Mali, du nord au sud, a droit au savoir gratuit et libérateur. »',
        explanation: 'Politique volontariste de scolarisation massive et de promotion des langues nationales.',
      ),
    ],
    chapters: [
      CharacterStoryChapter(
        id: 'instituteur',
        chapterNumber: 'CHAPITRE I',
        title: 'L\'Instituteur Engagé & L\'Éveil Anticolonial',
        kicker: 'DE L\'ÉCOLE WILLIAM-PONTY AUX COMBATS SYNDICAUX',
        dateAndPlace: 'Bamako & Sikasso • 1915 – 1946',
        mainImage: 'assets/images/culture/personnages/modibo_keita.jpg',
        fullNarrative:
            'Né le 4 juin 1915 à Bamako-Coura, descendant direct des rois fondateurs du Manden de la prestigieuse lignée des Keïta, Modibo Keïta se distingue brillamment à l\'École normale William-Ponty de Dakar, dont il sort major de promotion. Devenu instituteur émérite, il enseigne avec passion à Bamako, Sikasso et Tombouctou. Très tôt révolté par les injustices du système colonial, il fonde des syndicats d\'enseignants, anime des troupes théâtrales d\'éveil populaire et milite sans relâche pour la dignité des peuples d\'Afrique. Pour son audace militante, il est emprisonné à Paris en 1947, forgeant dans l\'épreuve sa stature d\'homme d\'État inflexible.',
        kineticQuotes: [
          'DESCENDANT DE LA NOBLE LIGNÉE DE SOUNDIATA',
          'MAJOR DE L\'ÉCOLE WILLIAM-PONTY DE DAKAR',
          'L\'ÉDUCATION COMME PREMIÈRE ARME D\'ÉMANCIPATION',
        ],
        accentColor: CultureTheme.orPatrimoine,
        readingDurationSeconds: 40,
      ),
      CharacterStoryChapter(
        id: 'independance',
        chapterNumber: 'CHAPITRE II',
        title: 'Le 22 Septembre 1960 : Proclamation de l\'Indépendance',
        kicker: 'LA RENAISSANCE DE LA RÉPUBLIQUE DU MALI',
        dateAndPlace: 'Palais de Koulouba, Bamako • 22 Septembre 1960',
        mainImage: 'assets/images/culture/monuments/monument_independance_bamako/ind_1.jpg',
        fullNarrative:
            'Après la dislocation de la Fédération du Mali, Modibo Keïta convoque le congrès extraordinaire de l\'Union Soudanaise-RDA le 22 septembre 1960 à Bamako. D\'une voix vibrante et solennelle qui galvanise des millions de citoyens, il proclame l\'indépendance totale de la jeune nation et choisit le nom glorieux de « Mali » en hommage direct à l\'empire médiéval de Soundiata Keïta et Mansa Moussa. « Le Mali est né. Le Mali continue. Le Mali triomphera », déclare-t-il devant une foule en liesse. Il dote aussitôt le pays de sa propre monnaie souveraine — le franc malien —, de ses sociétés d\'État nationales et d\'une diplomatie souveraine respectée dans le monde entier.',
        kineticQuotes: [
          '« LE MALI EST NÉ, LE MALI CONTINUE, LE MALI TRIOMPHERA ! »',
          '22 SEPTEMBRE 1960 : RENAISSANCE D\'UNE NATION MILLÉNAIRE',
          'LE RETOUR AUX RACINES GLORIEUSES DE L\'EMPIRE',
        ],
        accentColor: CultureTheme.vertNaturel,
        readingDurationSeconds: 44,
      ),
      CharacterStoryChapter(
        id: 'panafricanisme',
        chapterNumber: 'CHAPITRE III',
        title: 'Le Panafricanisme & Les Pères Fondateurs de l\'OUA',
        kicker: 'AUX CÔTÉS DE NKRUMAH, SÉKOU TOURÉ ET HAÏLÉ SÉLASSIÉ',
        dateAndPlace: 'Accra, Addis-Abeba & Bamako • 1961 – 1963',
        mainImage: 'assets/images/culture/personnages/modibo_keita.jpg',
        fullNarrative:
            'Pionnier visionnaire des États-Unis d\'Afrique, Modibo Keïta œuvre avec passion pour l\'unité politique continentale. Il crée avec Kwamé Nkrumah du Ghana et Ahmed Sékou Touré de Guinée l\'Union des États Africains dès 1961. En mai 1963 à Addis-Abeba, il est l\'un des architectes majeurs et signataires fondateurs de la charte de l\'Organisation de l\'Unité Africaine (OUA, actuelle Union Africaine). Médiateur respecté lors du conflit frontalier entre l\'Algérie et le Maroc lors de la Guerre des Sables en 1963, il fait de Bamako la capitale de la fraternité et du Mouvement des pays non-alignés aux côtés de Nasser, Tito et Nehru.',
        kineticQuotes: [
          'L\'IDÉAL CARDINAL DES ÉTATS-UNIS D\'AFRIQUE',
          'ARCHITECTE FONDATEUR DE L\'OUA À ADDIS-ABEBA',
          'BAMAKO, CARREFOUR DU NON-ALIGNEMENT MONDIAL',
        ],
        accentColor: CultureTheme.orPatrimoine,
        readingDurationSeconds: 42,
      ),
      CharacterStoryChapter(
        id: 'memorial',
        chapterNumber: 'CHAPITRE IV',
        title: 'Le Monument de l\'Indépendance & Le Flambeau Éternel',
        kicker: 'MÉMORIAL MODIBO KEÏTA • LE GÉANT DE LA SOUVERAINETÉ',
        dateAndPlace: 'Boulevard de l\'Indépendance & Mémorial, Bamako • 1977 à nos jours',
        mainImage: 'assets/images/culture/monuments/monument_tour_afrique_bamako/wm_tour_1.jpg',
        fullNarrative:
            'Modibo Keïta s\'éteint le 16 mai 1977, laissant une empreinte indélébile dans la conscience collective du peuple malien et de l\'Afrique tout entière. À Bamako, le grandiose Monument de l\'Indépendance élevant son obélisque doré vers le ciel et le Mémorial Modibo Keïta célèbrent sa mémoire vivante et son sacerdoce pour la dignité nationale. Modibo Keïta incarne l\'intégrité morale inébranlable, la fierté d\'être africain et la conviction que le Mali est une terre de bâtisseurs capables d\'éclairer le destin du continent. Son nom reste synonyme de courage patriotique et de justice sociale.',
        kineticQuotes: [
          'LE MONUMENT DE L\'INDÉPENDANCE DRESSÉ VERS LE CIEL',
          'L\'INTÉGRITÉ SANS CONCESSION D\'UN PÈRE DE LA NATION',
          'LE FLAMBEAU ÉTERNEL DE LA FIERTÉ MALIENNE',
        ],
        accentColor: CultureTheme.vertNaturel,
        readingDurationSeconds: 42,
      ),
    ],
  );

  /// Dictionnaire universel indexé par ID
  static final Map<String, HistoricalFigureSaga> sagas = {
    'perso_soundiata': soundiata,
    'perso_mansa_moussa': mansaMoussa,
    'perso_askia_mohammed': askiaMohammed,
    'perso_babemba': babembaTraore,
    'perso_biton_coulibaly': bitonCoulibaly,
    'perso_modibo_keita': modiboKeita,
  };

  /// Récupère la saga correspondante selon l'identifiant du personnage
  static HistoricalFigureSaga getSaga(String? figureId) {
    if (figureId == null || figureId.isEmpty) {
      return soundiata;
    }
    final clean = figureId.toLowerCase();
    if (clean.contains('moussa') || clean.contains('mansa')) {
      return mansaMoussa;
    }
    if (clean.contains('askia')) {
      return askiaMohammed;
    }
    if (clean.contains('babemba')) {
      return babembaTraore;
    }
    if (clean.contains('biton') || clean.contains('coulibaly')) {
      return bitonCoulibaly;
    }
    if (clean.contains('modibo') || (clean.contains('keita') && !clean.contains('soundiata'))) {
      return modiboKeita;
    }
    return soundiata;
  }
}
