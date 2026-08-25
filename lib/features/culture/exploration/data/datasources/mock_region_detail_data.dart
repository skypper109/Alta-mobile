import 'package:flutter/material.dart';
import '../models/cultural_discovery.dart';
import '../models/heritage_item.dart';
import '../models/mali_region.dart';
import '../models/region_detail_data.dart';
import '../models/region_testimony.dart';
import '../models/regional_challenge.dart';
import 'mock_mali_regions.dart';

/// Données éditoriales immersives et réalistes pour chaque région du Mali
abstract final class MockRegionDetailData {
  static RegionDetailData getDetailForRegion(MaliRegion region) {
    switch (region.id) {
      case 'segou':
        return _segouDetail(region);
      case 'sikasso':
        return _sikassoDetail(region);
      case 'tombouctou':
        return _tombouctouDetail(region);
      case 'mopti':
        return _moptiDetail(region);
      case 'kayes':
        return _kayesDetail(region);
      case 'bamako':
        return _bamakoDetail(region);
      case 'gao':
        return _gaoDetail(region);
      case 'kidal':
        return _kidalDetail(region);
      case 'koulikoro':
        return _koulikoroDetail(region);
      case 'taoudenit':
        return _taoudenitDetail(region);
      case 'menaka':
        return _menakaDetail(region);
      default:
        return _defaultDetail(region);
    }
  }

  // ── SÉGOU ──────────────────────────────────────────────────────────────────
  static RegionDetailData _segouDetail(MaliRegion region) {
    return RegionDetailData(
      region: region,
      accrocheEditoriale: 'Au cœur de l\'histoire, du fleuve Djoliba et des traditions millénaires du Royaume Bambara.',
      heroImageUrl: 'assets/images/segou_hero.jpg',
      discoveries: const [
        CulturalDiscovery(
          id: 'segou_bogolan',
          titre: 'L\'Art sacré du Bogolan',
          categorie: 'Artisanat & Savoir-faire',
          description: 'Teinture ancestrale à base d\'argile fermentée du fleuve et d\'extraits d\'écorces et feuilles médicinales.',
          tag: 'Textile Traditionnel',
          icone: Icons.palette_rounded,
          lieu: 'San & Ségou Ville',
          isFeatured: true,
        ),
        CulturalDiscovery(
          id: 'segou_kalabougou',
          titre: 'Les Potières de Kalabougou',
          categorie: 'Tradition Vivante',
          description: 'Village d\'artisanes potières réputé pour sa spectaculaire cuisson à ciel ouvert chaque fin de semaine.',
          tag: 'Poterie Millénaire',
          icone: Icons.local_fire_department_rounded,
          lieu: 'Kalabougou (Rive gauche)',
        ),
        CulturalDiscovery(
          id: 'segou_festival_niger',
          titre: 'Festival sur le Niger',
          categorie: 'Événement Culturel',
          description: 'Grand rassemblement annuel d\'art contemporain, de musique acoustique et de danses sur les rives du Djoliba.',
          tag: 'Musique & Danse',
          icone: Icons.music_note_rounded,
          lieu: 'Quai des Arts, Ségou',
        ),
        CulturalDiscovery(
          id: 'segou_sogobo',
          titre: 'Les Masques & Marionnettes Sogobô',
          categorie: 'Théâtre Populaire',
          description: 'Représentations théâtrales masquées célébrant les forces de la nature, les animaux mythiques et la cohésion sociale.',
          tag: 'Récits Masqués',
          icone: Icons.theater_comedy_rounded,
          lieu: 'Markala & Région de Ségou',
        ),
      ],
      testimonies: const [
        RegionTestimony(
          id: 'testimony_segou_1',
          conteur: 'Vieux Bakary Coulibaly',
          qualiteConteur: 'Griot et Gardien de la mémoire de Sékoro',
          lieu: 'Ségou-Koro',
          titreHistoire: 'La fondation du Royaume sous les 4 444 balanzans',
          duree: '4 min 12s',
          extrait: '« Mon grand-père disait que chaque arbre balanzan de Ségou veille sur un secret du roi Biton Coulibaly... »',
          epoqueOuAnnee: 'XVIIIe siècle',
        ),
        RegionTestimony(
          id: 'testimony_segou_2',
          conteur: 'Aminata Traoré',
          qualiteConteur: 'Maître teinturière de Bogolan',
          lieu: 'Ateliers Ndomo',
          titreHistoire: 'Le langage secret des motifs géométriques',
          duree: '3 min 45s',
          extrait: '« Dans nos tissus, chaque trait raconte un vœu de protection, une alliance ou le passage d\'une saison. »',
          epoqueOuAnnee: 'Transmission orale',
        ),
      ],
      heritages: const [
        HeritageItem(
          id: 'heritage_segoukoro',
          nom: 'Vestiges de Ségou-Koro & Tombeau de Biton Coulibaly',
          categorie: 'Site Historique',
          description: 'L\'ancienne capitale royale préservée avec ses mosquées historiques en banco et le mausolée du fondateur de l\'Empire Bambara.',
          estUnesco: false,
          epoque: '1712 - Règne de Biton',
          localisation: '11 km à l\'ouest de Ségou',
        ),
        HeritageItem(
          id: 'heritage_pont_markala',
          nom: 'Barrage & Pont de Markala',
          categorie: 'Patrimoine Hydraulique',
          description: 'Ouvrage colossal régulant les crues du fleuve Niger et irriguant les vastes terres rizicoles de l\'Office du Niger.',
          estUnesco: false,
          epoque: 'XXe siècle',
          localisation: 'Markala',
        ),
      ],
      challenge: const RegionalChallenge(
        id: 'challenge_segou_1',
        titre: 'Déchiffrez le symbole du Balanzan',
        description: 'Explorez l\'histoire de Ségou-Koro et découvrez pourquoi l\'arbre Balanzan perd ses feuilles pendant la saison des pluies.',
        xpPoints: 50,
        difficulte: 'Explorateur',
        badgeNom: 'Initié du Manden',
        tempsEstime: '4 min',
      ),
      neighborRegionIds: ['mopti', 'koulikoro', 'sikasso'],
    );
  }

  // ── SIKASSO ────────────────────────────────────────────────────────────────
  static RegionDetailData _sikassoDetail(MaliRegion region) {
    return RegionDetailData(
      region: region,
      accrocheEditoriale: 'Le grenier vert du Mali, terre de résistance héroïque et berceau du Balafon Sénoufo.',
      heroImageUrl: 'assets/images/sikasso_hero.jpg',
      discoveries: const [
        CulturalDiscovery(
          id: 'sikasso_balafon',
          titre: 'Le Balafon Sénoufo (Triangle du Balafon)',
          categorie: 'Musique Traditionnelle',
          description: 'Instrument sacré sculpté en bois de vène résonnant avec des calebasses accordées, classé au patrimoine immatériel.',
          tag: 'Musique Sacrée',
          icone: Icons.music_note_rounded,
          lieu: 'Kénédougou',
          isFeatured: true,
        ),
        CulturalDiscovery(
          id: 'sikasso_farako',
          titre: 'Les Chutes de Farako & Woroni',
          categorie: 'Nature & Sanctuaires',
          description: 'Cascades luxuriantes sculptées dans le grès au milieu des vergers de manguiers et des forêts denses.',
          tag: 'Paysage Verdoyant',
          icone: Icons.water_drop_rounded,
          lieu: 'Woroni & Farako',
        ),
        CulturalDiscovery(
          id: 'sikasso_mamelon',
          titre: 'Le Mamelon de Sikasso',
          categorie: 'Histoire Royale',
          description: 'Colline artificielle fortifiée au cœur de la ville où les rois du Kénédougou tenaient leurs conseils de guerre.',
          tag: 'Haut-Lieu Stratégique',
          icone: Icons.landscape_rounded,
          lieu: 'Centre-ville de Sikasso',
        ),
      ],
      testimonies: const [
        RegionTestimony(
          id: 'testimony_sikasso_1',
          conteur: 'El Hadj Souleymane Sanogo',
          qualiteConteur: 'Historien du Kénédougou',
          lieu: 'Sikasso Centre',
          titreHistoire: 'Le serment de Babemba Traoré : « Sayi Ni Maloya »',
          duree: '5 min 10s',
          extrait: '« Plutôt la mort que la honte : c\'est le serment immortel gravé dans le cœur de tous les enfants du Kénédougou... »',
          epoqueOuAnnee: '1898',
        ),
      ],
      heritages: const [
        HeritageItem(
          id: 'heritage_tata_sikasso',
          nom: 'Le Tata de Sikasso (Murailles défensives)',
          categorie: 'Monument Historique',
          description: 'Grande muraille de banco et de pierre longue de 9 km construite par le roi Tiéba pour résister aux sièges de Samory Touré.',
          estUnesco: false,
          epoque: 'XIXe siècle (1890)',
          localisation: 'Sikasso',
        ),
      ],
      challenge: const RegionalChallenge(
        id: 'challenge_sikasso_1',
        titre: 'Gardien du Tata',
        description: 'Découvrez la composition des trois enceintes fortifiées du Tata de Tiéba et l\'histoire de sa construction.',
        xpPoints: 50,
        difficulte: 'Explorateur',
        badgeNom: 'Protecteur du Kénédougou',
        tempsEstime: '5 min',
      ),
      neighborRegionIds: ['segou', 'koulikoro'],
    );
  }

  // ── TOMBOUCTOU ─────────────────────────────────────────────────────────────
  static RegionDetailData _tombouctouDetail(MaliRegion region) {
    return RegionDetailData(
      region: region,
      accrocheEditoriale: 'La Cité des 333 Saints, phare intellectuel médiéval et carrefour mythique du sel et de l\'or.',
      heroImageUrl: 'assets/images/tombouctou_hero.jpg',
      discoveries: const [
        CulturalDiscovery(
          id: 'tombouctou_manuscrits',
          titre: 'Les Manuscrits Anciens de l\'Institut Ahmed Baba',
          categorie: 'Science & Philosophie',
          description: 'Trésors documentaires inestimables traitant d\'astronomie, de médecine, de mathématiques, de droit et de poésie.',
          tag: 'Savoir Universel',
          icone: Icons.menu_book_rounded,
          lieu: 'Institut Ahmed Baba',
          isFeatured: true,
        ),
        CulturalDiscovery(
          id: 'tombouctou_azalai',
          titre: 'La Caravane de l\'Azalaï',
          categorie: 'Tradition Saharienne',
          description: 'Traversée chamelière bimillénaire transportant les barres de sel gemme des mines de Taoudénit.',
          tag: 'Route du Sel',
          icone: Icons.wb_sunny_rounded,
          lieu: 'Désert du Tanezrouft',
        ),
      ],
      testimonies: const [
        RegionTestimony(
          id: 'testimony_tombouctou_1',
          conteur: 'Cheick Abdoul Kader Haïdara',
          qualiteConteur: 'Conservateur des bibliothèques familiales',
          lieu: 'Bibliothèque Mamma Haïdara',
          titreHistoire: 'Le sauvetage secret des manuscrits en 2012',
          duree: '6 min 30s',
          extrait: '« Nous avons transporté des milliers de malles dans les pirogues sur le fleuve, de nuit, pour sauver notre mémoire. »',
          epoqueOuAnnee: 'Époque contemporaine',
        ),
      ],
      heritages: const [
        HeritageItem(
          id: 'heritage_sankore',
          nom: 'Mosquée & Université de Sankoré',
          categorie: 'Patrimoine Mondial UNESCO',
          description: 'L\'une des plus anciennes universités du monde arabo-africain, attirant plus de 25 000 étudiants au XVIe siècle.',
          estUnesco: true,
          epoque: 'XIVe siècle',
          localisation: 'Tombouctou Nord',
        ),
        HeritageItem(
          id: 'heritage_djingareyber',
          nom: 'Grande Mosquée Djingareyber',
          categorie: 'Patrimoine Mondial UNESCO',
          description: 'Chef-d\'œuvre architectural en terre crue conçu par l\'architecte andalou Abou Ishaq es-Sahéli sur ordre de Mansa Moussa.',
          estUnesco: true,
          epoque: '1327 (Mansa Moussa)',
          localisation: 'Tombouctou Centre',
        ),
      ],
      challenge: const RegionalChallenge(
        id: 'challenge_tombouctou_1',
        titre: 'L\'Étoile de Sankoré',
        description: 'Explorez un traité d\'astronomie médiévale rédigé à Tombouctou et découvrez le calcul des solstices.',
        xpPoints: 50,
        difficulte: 'Savant',
        badgeNom: 'Astronome Saharien',
        tempsEstime: '6 min',
      ),
      neighborRegionIds: ['gao', 'mopti', 'taoudenit'],
    );
  }

  // ── MOPTI ──────────────────────────────────────────────────────────────────
  static RegionDetailData _moptiDetail(MaliRegion region) {
    return RegionDetailData(
      region: region,
      accrocheEditoriale: 'La Venise Malienne au confluent du Djoliba et du Bani, sanctuaire du Pays Dogon et de Djenné.',
      heroImageUrl: 'assets/images/mopti_hero.jpg',
      discoveries: const [
        CulturalDiscovery(
          id: 'mopti_pinasses',
          titre: 'Les Chantiers Navals des Pinasses',
          categorie: 'Artisanat Fluvial',
          description: 'Fabrication artisanale des grandes pirogues en bois cousu qui sillonnent tout le bassin du fleuve Niger.',
          tag: 'Navigation Fluviale',
          icone: Icons.directions_boat_rounded,
          lieu: 'Port de Mopti',
          isFeatured: true,
        ),
        CulturalDiscovery(
          id: 'mopti_masques_dogon',
          titre: 'Cosmogonie et Masques Dogons',
          categorie: 'Spiritualité & Philosophie',
          description: 'Cérémonies du Dama et masques Kanaga reliant le ciel, la terre et la connaissance des étoiles.',
          tag: 'Patrimoine Millénaire',
          icone: Icons.auto_awesome_rounded,
          lieu: 'Bandiagara & Sangha',
        ),
      ],
      testimonies: const [
        RegionTestimony(
          id: 'testimony_mopti_1',
          conteur: 'Ogotemmêli le Sage',
          qualiteConteur: 'Ancien de la falaise de Bandiagara',
          lieu: 'Ogossagou / Sangha',
          titreHistoire: 'Paroles sur l\'origine du monde et l\'étoile Sirius B',
          duree: '5 min 20s',
          extrait: '« L\'eau est la force vive du monde, comme la parole est la semence de l\'homme... »',
          epoqueOuAnnee: 'Cosmogonie Dogon',
        ),
      ],
      heritages: const [
        HeritageItem(
          id: 'heritage_djenne',
          nom: 'Grande Mosquée en Banco de Djenné',
          categorie: 'Patrimoine Mondial UNESCO',
          description: 'Le plus grand édifice en terre crue au monde, restauré annuellement lors de la fête collective du crépissage.',
          estUnesco: true,
          epoque: 'Fondée au XIIIe siècle',
          localisation: 'Djenné',
        ),
        HeritageItem(
          id: 'heritage_bandiagara',
          nom: 'Falaise de Bandiagara (Pays Dogon)',
          categorie: 'Patrimoine Mondial UNESCO (Mixte)',
          description: 'Spectaculaire falaise de grès de 150 km abritant des villages troglodytiques Tellem et Dogon suspendus à la roche.',
          estUnesco: true,
          epoque: 'Millénaire',
          localisation: 'Plateau de Bandiagara',
        ),
      ],
      challenge: const RegionalChallenge(
        id: 'challenge_mopti_1',
        titre: 'Le Mystère du Masque Kanaga',
        description: 'Découvrez la signification des branches croisées du masque Kanaga et son lien avec le créateur Amma.',
        xpPoints: 50,
        difficulte: 'Explorateur',
        badgeNom: 'Guide du Pays Dogon',
        tempsEstime: '5 min',
      ),
      neighborRegionIds: ['segou', 'tombouctou', 'gao'],
    );
  }

  // ── KAYES ──────────────────────────────────────────────────────────────────
  static RegionDetailData _kayesDetail(MaliRegion region) {
    return RegionDetailData(
      region: region,
      accrocheEditoriale: 'La 1ère région du Mali, terre de fleuves tumultueux, de résistance coloniale et de cascades d\'or.',
      heroImageUrl: 'assets/images/kayes_hero.jpg',
      discoveries: const [
        CulturalDiscovery(
          id: 'kayes_gouina',
          titre: 'Les Chutes spectaculaires de Gouina',
          categorie: 'Merveille Naturelle',
          description: 'Surnommées les chutes du Niagara maliennes, s\'étendant sur 500 m de largeur sur le fleuve Sénégal.',
          tag: 'Cascades Majestueuses',
          icone: Icons.water_rounded,
          lieu: 'Diamou & Bafoulabé',
          isFeatured: true,
        ),
        CulturalDiscovery(
          id: 'kayes_rails',
          titre: 'L\'Épopée du Chemin de Fer Dakar-Niger',
          categorie: 'Histoire Industrielle & Sociale',
          description: 'Histoire des cheminots héroïques de la cité des rails et de la grande grève syndicale de 1947.',
          tag: 'Cité des Rails',
          icone: Icons.train_rounded,
          lieu: 'Gare historique de Kayes',
        ),
      ],
      testimonies: const [
        RegionTestimony(
          id: 'testimony_kayes_1',
          conteur: 'Doyen Mamadou Sissoko',
          qualiteConteur: 'Mémoire vivante du Khasso',
          lieu: 'Médine',
          titreHistoire: 'Le siège du Fort de Médine par El Hadj Oumar Tall',
          duree: '4 min 50s',
          extrait: '« Les canons résonnaient contre les falaises de Médine, et le fleuve Sénégal charriait les récits de courage. »',
          epoqueOuAnnee: '1857',
        ),
      ],
      heritages: const [
        HeritageItem(
          id: 'heritage_medine',
          nom: 'Fort de Médine & Palais des Rois du Khasso',
          categorie: 'Monument Historique',
          description: 'Premier grand fort établi dans le haut fleuve, témoin des batailles décisives de l\'Empire Toucouleur.',
          estUnesco: false,
          epoque: '1855',
          localisation: '12 km de Kayes',
        ),
      ],
      challenge: const RegionalChallenge(
        id: 'challenge_kayes_1',
        titre: 'Le confluent de Bafoulabé',
        description: 'Découvrez la légende de Mali Sadio, l\'hippopotame mythique protecteur des eaux de Bafoulabé.',
        xpPoints: 50,
        difficulte: 'Explorateur',
        badgeNom: 'Pionnier du Khasso',
        tempsEstime: '4 min',
      ),
      neighborRegionIds: ['koulikoro'],
    );
  }

  // ── DISTRICT DE BAMAKO ─────────────────────────────────────────────────────
  static RegionDetailData _bamakoDetail(MaliRegion region) {
    return RegionDetailData(
      region: region,
      accrocheEditoriale: 'La capitale cosmopolite au bord du Djoliba, épicentre de la création contemporaine, de la musique et de la mode.',
      heroImageUrl: 'assets/images/bamako_hero.jpg',
      discoveries: const [
        CulturalDiscovery(
          id: 'bamako_musee',
          titre: 'Le Musée National du Mali',
          categorie: 'Art & Archéologie',
          description: 'Collections prestigieuses de textiles, statuaires et maquettes grandeur nature de l\'habitat traditionnel.',
          tag: 'Musée d\'Excellence',
          icone: Icons.museum_rounded,
          lieu: 'Parc National du Mali',
          isFeatured: true,
        ),
        CulturalDiscovery(
          id: 'bamako_photo',
          titre: 'Les Rencontres Photographiques de Bamako',
          categorie: 'Photographie & Art Moderne',
          description: 'Biennale africaine de la photographie reconnue mondialement, inspirée par Seydou Keïta et Malick Sidibé.',
          tag: 'Arts Visuels',
          icone: Icons.camera_alt_rounded,
          lieu: 'Quartiers artistiques de Bamako',
        ),
      ],
      testimonies: const [
        RegionTestimony(
          id: 'testimony_bamako_1',
          conteur: 'Maître Toumani Diabaté',
          qualiteConteur: 'Virtuose légendaire de la Kora',
          lieu: 'N\'Tomikorobougou',
          titreHistoire: 'La 71ème génération de joueurs de Kora',
          duree: '5 min 00s',
          extrait: '« La Kora ne ment jamais : ses 21 cordes résument la philosophie de paix du Manden. »',
          epoqueOuAnnee: 'XXIe siècle',
        ),
      ],
      heritages: const [
        HeritageItem(
          id: 'heritage_monument_independance',
          nom: 'Monument de l\'Indépendance & Point G',
          categorie: 'Patrimoine Moderne',
          description: 'Symbole monumental de l\'accession du Mali à la souveraineté en 1960 au pied des falaises sacrées du Point G.',
          estUnesco: false,
          epoque: '1960',
          localisation: 'Boulevard de l\'Indépendance',
        ),
      ],
      challenge: const RegionalChallenge(
        id: 'challenge_bamako_1',
        titre: 'Les Trois Caïmans de Bamako',
        description: 'Découvrez pourquoi la ville porte le nom de Bamako (le marigot aux caïmans) et l\'histoire de Bamba Sanogo.',
        xpPoints: 50,
        difficulte: 'Facile',
        badgeNom: 'Citoyen de Bamako',
        tempsEstime: '3 min',
      ),
      neighborRegionIds: ['koulikoro'],
    );
  }

  // ── GAO ────────────────────────────────────────────────────────────────────
  static RegionDetailData _gaoDetail(MaliRegion region) {
    return RegionDetailData(
      region: region,
      accrocheEditoriale: 'L\'ancienne capitale du grand Empire Songhaï, sentinelle du désert baignée par les eaux du fleuve.',
      heroImageUrl: 'assets/images/gao_hero.jpg',
      discoveries: const [
        CulturalDiscovery(
          id: 'gao_koima',
          titre: 'La Dune rose de Koïma',
          categorie: 'Paysage Mythique',
          description: 'Dune de sable fin dominant le fleuve Niger, lieu de contes et de magie populaire Songhaï.',
          tag: 'Dune Sacrée',
          icone: Icons.landscape_rounded,
          lieu: 'Koïma (5 km de Gao)',
          isFeatured: true,
        ),
        CulturalDiscovery(
          id: 'gao_takamba',
          titre: 'La Danse royale du Takamba',
          categorie: 'Danse & Rythme',
          description: 'Danse ondulante et majestueuse exécutée au son du luth Ngoni et des tambours de calebasse.',
          tag: 'Rythme Songhaï',
          icone: Icons.music_note_rounded,
          lieu: 'Gao Ville',
        ),
      ],
      testimonies: const [
        RegionTestimony(
          id: 'testimony_gao_1',
          conteur: 'Moussa Maïga',
          qualiteConteur: 'Griot et érudit Songhaï',
          lieu: 'Quartier Château',
          titreHistoire: 'La grandeur d\'Askia Mohamed et l\'expansion de l\'Empire',
          duree: '5 min 40s',
          extrait: '« De Gao rayonnaient la justice, les écoles et les caravanes commerciales jusqu\'aux rives de la Méditerranée... »',
          epoqueOuAnnee: '1493 - 1528',
        ),
      ],
      heritages: const [
        HeritageItem(
          id: 'heritage_tombeau_askia',
          nom: 'Tombeau Pyramidal des Askia',
          categorie: 'Patrimoine Mondial UNESCO',
          description: 'Complexe funéraire pyramidal en terre crue édifié en 1495 par l\'empereur Askia Mohamed à son retour de La Mecque.',
          estUnesco: true,
          epoque: '1495',
          localisation: 'Gao Centre',
        ),
      ],
      challenge: const RegionalChallenge(
        id: 'challenge_gao_1',
        titre: 'L\'Héritage des Askia',
        description: 'Explorez la structure pyramidale du Tombeau des Askia et l\'organisation de l\'Empire Songhaï.',
        xpPoints: 50,
        difficulte: 'Explorateur',
        badgeNom: 'Fils du Songhaï',
        tempsEstime: '5 min',
      ),
      neighborRegionIds: ['tombouctou', 'kidal', 'menaka'],
    );
  }

  // ── KIDAL ──────────────────────────────────────────────────────────────────
  static RegionDetailData _kidalDetail(MaliRegion region) {
    return RegionDetailData(
      region: region,
      accrocheEditoriale: 'Le sanctuaire granitique de l\'Adrar des Ifoghas, berceau de la poésie nomade et de la culture touarègue.',
      heroImageUrl: 'assets/images/kidal_hero.jpg',
      discoveries: const [
        CulturalDiscovery(
          id: 'kidal_ifoghas',
          titre: 'Le Massif de l\'Adrar des Ifoghas',
          categorie: 'Sanctuaire Géologique',
          description: 'Montagnes majestueuses aux gueltas secrètes sculptées par l\'érosion éolienne et abritant des espèces rares.',
          tag: 'Montagnes du Désert',
          icone: Icons.terrain_rounded,
          lieu: 'Massif des Ifoghas',
          isFeatured: true,
        ),
        CulturalDiscovery(
          id: 'kidal_artisanat_argent',
          titre: 'L\'Orfèvrerie et la Croix d\'Agadez / Kidal',
          categorie: 'Artisanat du Métal & Cuir',
          description: 'Pendentifs ciselés en argent pur transmis de génération en génération comme boussoles protectrices.',
          tag: 'Bijouterie Touarègue',
          icone: Icons.diamond_rounded,
          lieu: 'Kidal & Tessalit',
        ),
      ],
      testimonies: const [
        RegionTestimony(
          id: 'testimony_kidal_1',
          conteur: 'Almoustapha ag Rhissa',
          qualiteConteur: 'Poète et joueur de Tinde',
          lieu: 'Vallée d\'Abeïbara',
          titreHistoire: 'La traversée de la nuit et l\'orientation par les étoiles',
          duree: '4 min 15s',
          extrait: '« Dans le désert, le ciel est notre livre ouvert. Chaque constellation guide nos pas vers l\'eau et la vie. »',
          epoqueOuAnnee: 'Tradition nomade',
        ),
      ],
      heritages: const [
        HeritageItem(
          id: 'heritage_essouk',
          nom: 'Cité médiévale d\'Essouk-Tadmekka',
          categorie: 'Site Archéologique',
          description: 'Carrefour caravanier précurseur du Sahara abritant d\'anciennes inscriptions rupestres en tifinagh et arabe coufique.',
          estUnesco: false,
          epoque: 'IXe - XIIe siècles',
          localisation: '45 km au nord-ouest de Kidal',
        ),
      ],
      challenge: const RegionalChallenge(
        id: 'challenge_kidal_1',
        titre: 'L\'Écriture Tifinagh',
        description: 'Déchiffrez votre premier mot en alphabet Tifinagh, l\'écriture millénaire des peuples sahariens.',
        xpPoints: 50,
        difficulte: 'Savant',
        badgeNom: 'Scribe du Tifinagh',
        tempsEstime: '5 min',
      ),
      neighborRegionIds: ['gao', 'menaka', 'taoudenit'],
    );
  }

  // ── KOULIKORO ──────────────────────────────────────────────────────────────
  static RegionDetailData _koulikoroDetail(MaliRegion region) {
    return RegionDetailData(
      region: region,
      accrocheEditoriale: 'Le berceau impérial du Manden, sanctuaire de Soundiata Keïta et de la Charte de Kouroukan Fouga.',
      heroImageUrl: 'assets/images/koulikoro_hero.jpg',
      discoveries: const [
        CulturalDiscovery(
          id: 'koulikoro_kamablon',
          titre: 'Le Sanctuaire sacré du Kamablon',
          categorie: 'Patrimoine Sacré',
          description: 'Case sacrée au toit de chaume réfectionnée tous les 7 ans lors de la récitation intégrale de la genèse Mandingue.',
          tag: 'Sanctuaire Historique',
          icone: Icons.home_rounded,
          lieu: 'Kangaba',
          isFeatured: true,
        ),
      ],
      testimonies: const [
        RegionTestimony(
          id: 'testimony_koulikoro_1',
          conteur: 'Griot Balla Fasséké Kouyaté',
          qualiteConteur: 'Lignée des griots impériaux',
          lieu: 'Kirina',
          titreHistoire: 'La proclamation de la Charte du Manden (1236)',
          duree: '5 min 30s',
          extrait: '« Toute vie humaine est une vie : une vie n\'est pas plus ancienne ni plus respectable qu\'une autre... »',
          epoqueOuAnnee: '1236 (Kouroukan Fouga)',
        ),
      ],
      heritages: const [
        HeritageItem(
          id: 'heritage_kirina',
          nom: 'Champ de bataille historique de Kirina',
          categorie: 'Site Mémorial',
          description: 'Lieu de la bataille décisive de 1235 qui vit la victoire de Soundiata Keïta et la naissance de l\'Empire du Mali.',
          estUnesco: false,
          epoque: '1235',
          localisation: 'Kirina',
        ),
      ],
      challenge: const RegionalChallenge(
        id: 'challenge_koulikoro_1',
        titre: 'La Charte des Droits Humains',
        description: 'Explorez les articles fondamentaux de la Charte du Manden proclamée en 1236.',
        xpPoints: 50,
        difficulte: 'Explorateur',
        badgeNom: 'Chancelier du Manden',
        tempsEstime: '4 min',
      ),
      neighborRegionIds: ['bamako', 'kayes', 'segou', 'sikasso'],
    );
  }

  // ── TAOUDÉNIT ──────────────────────────────────────────────────────────────
  static RegionDetailData _taoudenitDetail(MaliRegion region) {
    return RegionDetailData(
      region: region,
      accrocheEditoriale: 'L\'immensité du grand erg saharien, mines de sel gemme et route mythique des caravanes du désert.',
      heroImageUrl: 'assets/images/taoudenit_hero.jpg',
      discoveries: const [
        CulturalDiscovery(
          id: 'taoudenit_mines_sel',
          titre: 'Les Mines d\'Or Blanc de Taoudénit',
          categorie: 'Extraction Ancestrale',
          description: 'Découpe manuelle de dalles de sel pur d\'un ancien lac asséché, transportées à dos de chameau vers le sud.',
          tag: 'Mines Millénaires',
          icone: Icons.diamond_rounded,
          lieu: 'Bassin de Taoudénit',
          isFeatured: true,
        ),
      ],
      testimonies: const [
        RegionTestimony(
          id: 'testimony_taoudenit_1',
          conteur: 'Mahmoud Ould Sidi',
          qualiteConteur: 'Caravanier en chef de l\'Azalaï',
          lieu: 'Puits d\'Agorgot',
          titreHistoire: 'Trois semaines sans ombre sous le soleil saharien',
          duree: '4 min 40s',
          extrait: '« Le sel de Taoudénit a nourri des millions d\'âmes depuis mille ans. Le désert exige le respect absolu. »',
          epoqueOuAnnee: 'Mémoire caravanière',
        ),
      ],
      heritages: const [
        HeritageItem(
          id: 'heritage_mines_taoudenit',
          nom: 'Salines historiques du Tanezrouft',
          categorie: 'Patrimoine Industriel Ancien',
          description: 'Gisement géologique unique fournissant le sel gemme de toute l\'Afrique de l\'Ouest.',
          estUnesco: false,
          epoque: 'Depuis le Moyen Âge',
          localisation: 'Taoudénit',
        ),
      ],
      challenge: const RegionalChallenge(
        id: 'challenge_taoudenit_1',
        titre: 'Le Maître de l\'Azalaï',
        description: 'Calculez le poids d\'une cargaison d\'une caravane de 200 chameaux portant le sel gemme.',
        xpPoints: 50,
        difficulte: 'Explorateur',
        badgeNom: 'Seigneur du Tanezrouft',
        tempsEstime: '3 min',
      ),
      neighborRegionIds: ['tombouctou', 'kidal'],
    );
  }

  // ── MÉNAKA ─────────────────────────────────────────────────────────────────
  static RegionDetailData _menakaDetail(MaliRegion region) {
    return RegionDetailData(
      region: region,
      accrocheEditoriale: 'La vallée pastorale de l\'Iullemmeden, carrefour sahélien d\'élevage, de solidarité et d\'orfèvrerie fine.',
      heroImageUrl: 'assets/images/menaka_hero.jpg',
      discoveries: const [
        CulturalDiscovery(
          id: 'menaka_cuir',
          titre: 'L\'Art du Cuir et de la Selle Pastorale',
          categorie: 'Artisanat Sahélien',
          description: 'Tannage végétal et broderies de cuir coloré pour confectionner les selles de monture et bourses d\'apparat.',
          tag: 'Travail du Cuir',
          icone: Icons.shield_rounded,
          lieu: 'Vallée de l\'Ezgeuret',
          isFeatured: true,
        ),
      ],
      testimonies: const [
        RegionTestimony(
          id: 'testimony_menaka_1',
          conteur: 'Ibrahim ag Mohamed',
          qualiteConteur: 'Éleveur et conteur de la vallée',
          lieu: 'Ménaka',
          titreHistoire: 'La solidarité pastorale lors des grandes transhumances',
          duree: '3 min 55s',
          extrait: '« Quand les pâturages s\'assèchent, tous les campements partagent l\'eau du même puits sans distinction. »',
          epoqueOuAnnee: 'Tradition pastorale',
        ),
      ],
      heritages: const [
        HeritageItem(
          id: 'heritage_oasis_menaka',
          nom: 'Palmeraies & Oasis de la Vallée d\'Ezgeuret',
          categorie: 'Patrimoine Naturel & Agricole',
          description: 'Écosystème précieux alimenté par les nappes phréatiques assurant la subsistance des communautés pastorales.',
          estUnesco: false,
          epoque: 'Ancestrale',
          localisation: 'Ménaka',
        ),
      ],
      challenge: const RegionalChallenge(
        id: 'challenge_menaka_1',
        titre: 'La Route des Pâturages',
        description: 'Découvrez comment les éleveurs de Ménaka préservent les points d\'eau et la végétation sahélienne.',
        xpPoints: 50,
        difficulte: 'Explorateur',
        badgeNom: 'Gardien du Sahel',
        tempsEstime: '4 min',
      ),
      neighborRegionIds: ['gao', 'kidal'],
    );
  }

  // ── FALLBACK GÉNÉRIQUE ─────────────────────────────────────────────────────
  static RegionDetailData _defaultDetail(MaliRegion region) {
    return RegionDetailData(
      region: region,
      accrocheEditoriale: 'Découvrez les trésors historiques, les traditions et les mémoires vivantes de ${region.nom}.',
      heroImageUrl: 'assets/images/default_hero.jpg',
      discoveries: [
        CulturalDiscovery(
          id: '${region.id}_disc_1',
          titre: 'Patrimoine vivant de ${region.nom}',
          categorie: 'Tradition & Savoir',
          description: region.descriptionCourte,
          tag: 'Culture Locale',
          icone: Icons.explore_rounded,
          lieu: region.chefLieu,
          isFeatured: true,
        ),
      ],
      testimonies: [
        RegionTestimony(
          id: 'testimony_${region.id}_1',
          conteur: 'Doyen de ${region.nom}',
          qualiteConteur: 'Gardien de la tradition',
          lieu: region.chefLieu,
          titreHistoire: 'Récits anciens de ${region.nom}',
          duree: '4 min',
          extrait: '« Nos ancêtres ont bâti cette terre avec sagesse, honneur et fraternité... »',
        ),
      ],
      heritages: [
        HeritageItem(
          id: 'heritage_${region.id}_1',
          nom: 'Monuments historiques de ${region.nom}',
          categorie: 'Monument National',
          description: 'Haut-lieu de mémoire et de transmission culturelle.',
          estUnesco: false,
          localisation: region.chefLieu,
        ),
      ],
      challenge: RegionalChallenge(
        id: 'challenge_${region.id}_1',
        titre: 'Explorateur de ${region.nom}',
        description: 'Découvrez les points forts de cette région emblématique du Mali.',
        xpPoints: 50,
        badgeNom: 'Explorateur',
      ),
      neighborRegionIds: MockMaliRegions.regions
          .where((r) => r.id != region.id)
          .take(3)
          .map((r) => r.id)
          .toList(),
    );
  }
}
