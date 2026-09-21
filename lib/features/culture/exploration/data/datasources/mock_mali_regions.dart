import 'package:flutter/material.dart';
import '../../../core/theme/culture_theme.dart';
import '../models/mali_region.dart';

/// Données culturelles, géographiques et historiques de référence pour les régions du Mali
abstract final class MockMaliRegions {
  static const List<MaliRegion> regions = [
    // ── 1. KAYES (1ère Région) ───────────────────────────────────────────────
    MaliRegion(
      id: 'kayes',
      nom: 'Kayes',
      code: 'R1',
      surnom: 'La Cité des Rails & Terre des Cascades',
      chefLieu: 'Kayes',
      descriptionCourte: 'Région historique marquée par les grands fleuves, le Fort de Médine et le Royaume du Khasso.',
      descriptionComplete:
          'Kayes est le carrefour de l\'histoire coloniale et des grands royaumes d\'Afrique de l\'Ouest. Traversée par le fleuve Sénégal, la région abrite le célèbre Fort de Médine, les spectaculaires chutes de Félou et de Gouina, ainsi que la mythique histoire du Royaume du Khasso et de l\'épopée ferroviaire.',
      pointsForts: [
        'Fort de Médine',
        'Chutes de Gouina & Félou',
        'Chemin de fer historique',
        'Royaume du Khasso',
      ],
      symbolesEtTraditions: [
        'Danse Dansa',
        'Tissage traditionnel Maninka',
        'Honneur aux griots du Khasso',
      ],
      couleurAccent: CultureTheme.rougeKoulikoro,
      icone: Icons.castle_rounded,
      superficie: '120 760 km²',
      population: '~2 000 000 hab.',
      centreRelatif: Offset(0.13, 0.62),
    ),

    // ── 2. KOULIKORO (2ème Région) ───────────────────────────────────────────
    MaliRegion(
      id: 'koulikoro',
      nom: 'Koulikoro',
      code: 'R2',
      surnom: 'Le Berceau du Manden & Terminus Fluvial',
      chefLieu: 'Koulikoro',
      descriptionCourte: 'Haut lieu de l\'Empire du Mali, sanctuaire de Soundiata Keïta et des Monts Mandingues.',
      descriptionComplete:
          'Koulikoro est le cœur battant de l\'histoire Mandingue. C\'est ici que s\'est déroulée la célèbre bataille de Kirina en 1235 où Soundiata Keïta triompha de Soumaoro Kanté. La région s\'étend le long des monts Mandingues et marque le terminus de la navigation fluviale sur le Djoliba.',
      pointsForts: [
        'Bataille de Kirina (1235)',
        'Monts Mandingues',
        'Port fluvial de Koulikoro',
        'Sanctuaire de Kamablon (Kangaba)',
      ],
      symbolesEtTraditions: [
        'Charte du Manden (Kouroukan Fouga)',
        'Griotisme et Kora',
        'Artisanat de la poterie',
      ],
      couleurAccent: CultureTheme.ocreTerre,
      icone: Icons.terrain_rounded,
      superficie: '90 120 km²',
      population: '~2 400 000 hab.',
      centreRelatif: Offset(0.23, 0.74),
    ),

    // ── 3. SIKASSO (3ème Région) ─────────────────────────────────────────────
    MaliRegion(
      id: 'sikasso',
      nom: 'Sikasso',
      code: 'R3',
      surnom: 'Le Royaume du Kénédougou & Le Jardin du Mali',
      chefLieu: 'Sikasso',
      descriptionCourte: 'Terre fertile de résistance héroïque avec le Tata de Tiéba et Babemba Traoré.',
      descriptionComplete:
          'Sikasso est la région la plus verte et généreuse du Mali, réputée pour sa production agricole florissante. Elle est immortalisée par la résistance héroïque de Babemba Traoré face aux troupes coloniales derrière les murailles imprenables du Tata de Sikasso.',
      pointsForts: [
        'Le Tata de Sikasso',
        'Mamelon de Sikasso',
        'Chutes de Farako & Woroni',
        'Royaume du Kénédougou',
      ],
      symbolesEtTraditions: [
        'Balafon Sénoufo',
        'Masques rituels et danses',
        'Célébration du Triangle du Balafon',
      ],
      couleurAccent: CultureTheme.vertNaturel,
      icone: Icons.eco_rounded,
      superficie: '71 640 km²',
      population: '~2 600 000 hab.',
      centreRelatif: Offset(0.36, 0.85),
    ),

    // ── 4. SÉGOU (4ème Région) ───────────────────────────────────────────────
    MaliRegion(
      id: 'segou',
      nom: 'Ségou',
      code: 'R4',
      surnom: 'La Cité des Balanzans & Royaume Bambara',
      chefLieu: 'Ségou',
      descriptionCourte: 'Capitale du Royaume Bambara de Biton Coulibaly, berceau de l\'art du Bogolan.',
      descriptionComplete:
          'Ségou est la majestueuse cité aux 4 444 balanzans (arbres sacrés). Fondée comme capitale du puissant Royaume Bambara par Biton Coulibaly puis Dah Monzon Diarra, la région est un épicentre artistique et artisanal mondialement réputé pour son textile Bogolan et sa poterie de Kalabougou.',
      pointsForts: [
        'Palais de Biton Coulibaly',
        'Village de potières de Kalabougou',
        'Festival sur le Niger',
        'Architecture coloniale et soudanienne',
      ],
      symbolesEtTraditions: [
        'Tissu Bogolan traditionnel',
        'Marionnettes géantes (Sogobô)',
        'Contes et épopées des rois Bambaras',
      ],
      couleurAccent: CultureTheme.orPatrimoine,
      icone: Icons.palette_rounded,
      superficie: '64 947 km²',
      population: '~2 300 000 hab.',
      centreRelatif: Offset(0.32, 0.64),
    ),

    // ── 5. MOPTI (5ème Région) ───────────────────────────────────────────────
    MaliRegion(
      id: 'mopti',
      nom: 'Mopti',
      code: 'R5',
      surnom: 'La Venise Malienne & Le Pays Dogon',
      chefLieu: 'Mopti',
      descriptionCourte: 'Carrefour fluvial du Delta intérieur, falaises de Bandiagara et Grande Mosquée de Djenné.',
      descriptionComplete:
          'Mopti est le carrefour magique où se rencontrent le fleuve Niger et le Bani. La région abrite des trésors classés au patrimoine mondial de l\'UNESCO : la grandiose Mosquée en banco de Djenné et la spectaculaire falaise de Bandiagara, sanctuaire millénaire du peuple Dogon.',
      pointsForts: [
        'Grande Mosquée de Djenné',
        'Falaise de Bandiagara (Pays Dogon)',
        'Delta intérieur du Niger',
        'Port aux pinasses de Mopti',
      ],
      symbolesEtTraditions: [
        'Cosmogonie et masques Dogons',
        'Crépissage annuel de Djenné',
        'Architecture en terre crue soudano-sahélienne',
      ],
      couleurAccent: CultureTheme.cyanTurquoise,
      icone: Icons.mosque_rounded,
      superficie: '79 017 km²',
      population: '~2 100 000 hab.',
      centreRelatif: Offset(0.47, 0.56),
    ),

    // ── 6. TOMBOUCTOU (6ème Région) ──────────────────────────────────────────
    MaliRegion(
      id: 'tombouctou',
      nom: 'Tombouctou',
      code: 'R6',
      surnom: 'La Cité des 333 Saints & Perle du Désert',
      chefLieu: 'Tombouctou',
      descriptionCourte: 'Centre intellectuel et spirituel médiéval de l\'Islam, université de Sankoré et manuscrits anciens.',
      descriptionComplete:
          'Tombouctou est une légende universelle. Porte du Sahara et point de rencontre des caravaniers de l\'or et du sel, elle rayonna mondialement aux XIVe-XVIe siècles avec son université de Sankoré et ses centaines de milliers de manuscrits scientifiques, philosophiques et juridiques.',
      pointsForts: [
        'Université & Mosquée Sankoré',
        'Manuscrits anciens de Tombouctou',
        'Mosquée Djingareyber',
        'Mausolées des 333 Saints',
      ],
      symbolesEtTraditions: [
        'Calligraphie et conservation des manuscrits',
        'Thé du désert sous la tente',
        'Caravanes de l\'Azalaï (sel gemme)',
      ],
      couleurAccent: CultureTheme.orPatrimoine,
      icone: Icons.menu_book_rounded,
      superficie: '497 926 km²',
      population: '~680 000 hab.',
      centreRelatif: Offset(0.49, 0.35),
    ),

    // ── 7. GAO (7ème Région) ─────────────────────────────────────────────────
    MaliRegion(
      id: 'gao',
      nom: 'Gao',
      code: 'R7',
      surnom: 'La Capitale de l\'Empire Songhaï',
      chefLieu: 'Gao',
      descriptionCourte: 'Siège des grands empereurs Sonni Ali Ber et Askia Mohamed, Tombeau des Askia.',
      descriptionComplete:
          'Gao fut la capitale de l\'un des plus vastes empires de l\'histoire africaine : l\'Empire Songhaï. Baignée par le fleuve Niger, la cité abrite le pyramidal Tombeau des Askia érigé en 1495 et la fascinante Dune rose de Koïma dominant les flots.',
      pointsForts: [
        'Tombeau pyramidal des Askia (UNESCO)',
        'Dune rose de Koïma',
        'Vallée du fleuve Niger',
        'Île légendaire de Gounzourey',
      ],
      symbolesEtTraditions: [
        'Danse Takamba',
        'Poésie et récits de l\'Empire Songhaï',
        'Artisanat du cuir et du fer',
      ],
      couleurAccent: CultureTheme.accentOrange,
      icone: Icons.auto_awesome_rounded,
      superficie: '170 572 km²',
      population: '~550 000 hab.',
      centreRelatif: Offset(0.74, 0.52),
    ),

    // ── 8. KIDAL (8ème Région) ───────────────────────────────────────────────
    MaliRegion(
      id: 'kidal',
      nom: 'Kidal',
      code: 'R8',
      surnom: 'Le Sanctuaire de l\'Adrar des Ifoghas',
      chefLieu: 'Kidal',
      descriptionCourte: 'Massif granitique saharien majestueux, berceau de la culture nomade et touarègue.',
      descriptionComplete:
          'Kidal est un univers minéral d\'une beauté saisissante sculpté par l\'Adrar des Ifoghas. Région de poésie millénaire et de liberté, elle perpétue avec fierté les coutumes pastorales sahariennes, les gravures rupestres préhistoriques et la musique du désert.',
      pointsForts: [
        'Massif de l\'Adrar des Ifoghas',
        'Gravures rupestres d\'Essouk-Tadmekka',
        'Vallées et gueltas mystiques',
        'Poésie et musique Tinde',
      ],
      symbolesEtTraditions: [
        'Musique acoustique et guitare touarègue',
        'Bijoux d\'argent et travail du cuir',
        'Tenue traditionnelle (Tagelmust / Chèche)',
      ],
      couleurAccent: CultureTheme.sable,
      icone: Icons.wb_sunny_rounded,
      superficie: '151 430 km²',
      population: '~80 000 hab.',
      centreRelatif: Offset(0.80, 0.31),
    ),

    // ── 9. TAOUDÉNIT (9ème Région) ───────────────────────────────────────────
    MaliRegion(
      id: 'taoudenit',
      nom: 'Taoudénit',
      code: 'R9',
      surnom: 'L\'Immensité du Bassin Saharien & Mines d\'Or Blanc',
      chefLieu: 'Taoudénit',
      descriptionCourte: 'Cœur du Tanezrouft, mines ancestrales de sel gemme et route mythique de l\'Azalaï.',
      descriptionComplete:
          'Taoudénit s\'étend sur le grand erg désertique du Nord malien. Connue depuis des siècles pour ses mines de sel gemme exploitées à ciel ouvert, elle est le point de départ des grandes caravanes chamelières traversant le désert infini vers Tombouctou.',
      pointsForts: [
        'Mines de sel gemme millénaires',
        'La grande traversée de l\'Azalaï',
        'Dunes géantes du Tanezrouft',
        'Astronomie saharienne nocturne',
      ],
      symbolesEtTraditions: [
        'Navigation stellaire nomade',
        'Épopées des caravaniers du sel',
        'Hospitalité saharienne inviolable',
      ],
      couleurAccent: CultureTheme.orPatrimoine,
      icone: Icons.diamond_rounded,
      superficie: '323 326 km²',
      population: '~20 000 hab.',
      centreRelatif: Offset(0.55, 0.15),
    ),

    // ── 10. MÉNAKA (10ème Région) ────────────────────────────────────────────
    MaliRegion(
      id: 'menaka',
      nom: 'Ménaka',
      code: 'R10',
      surnom: 'La Vallée de l\'Iullemmeden & Terre Pastorale',
      chefLieu: 'Ménaka',
      descriptionCourte: 'Région aux confins du Sahel et du Sahara, riche en traditions d\'élevage et d\'orfèvrerie.',
      descriptionComplete:
          'Ménaka est une région pastorale stratégique située au Sud-Est du Mali. Ses vallées abritent une mosaïque de peuples fiers (Touaregs, Peuls, Songhaïs, Daoussahak) unis par une tradition millénaire d\'artisanat fin, d\'élevage et de solidarité communautaire.',
      pointsForts: [
        'Vallée de l\'Ezgeuret',
        'Artisanat fin des métaux et du cuir',
        'Foires pastorales sahéliennes',
        'Oasis et palmeraies locales',
      ],
      symbolesEtTraditions: [
        'Courses de chameaux et festivités',
        'Tannage traditionnel des peaux',
        'Récits oraux des confins sahéliens',
      ],
      couleurAccent: CultureTheme.ocreTerre,
      icone: Icons.shield_rounded,
      superficie: '81 040 km²',
      population: '~60 000 hab.',
      centreRelatif: Offset(0.89, 0.58),
    ),

    // ── 11. DISTRICT DE BAMAKO (Capitale) ────────────────────────────────────
    MaliRegion(
      id: 'bamako',
      nom: 'Bamako',
      code: 'DB',
      surnom: 'La Cité des Trois Caïmans & Cœur Vibrant',
      chefLieu: 'Bamako',
      descriptionCourte: 'Capitale dynamique au bord du Djoliba, carrefour culturel et artistique contemporain de l\'Afrique.',
      descriptionComplete:
          'Fondée sur les berges du fleuve Niger au pied de la colline du Point G, Bamako est la capitale vibrante du Mali. Métropole cosmopolite, elle accueille le Musée National du Mali, le Monument de l\'Indépendance et rayonne mondialement à travers la musique, la mode et la photographie africaine.',
      pointsForts: [
        'Musée National du Mali',
        'Colline du Point G & falaises',
        'Monument de l\'Indépendance',
        'Berges animées du Djoliba',
      ],
      symbolesEtTraditions: [
        'Rencontres de Bamako (Biennale photo)',
        'Musique live mandingue & afrobeat',
        'Marché d\'artisanat de N\'Golonina',
      ],
      couleurAccent: CultureTheme.primaryBlue,
      icone: Icons.location_city_rounded,
      superficie: '252 km²',
      population: '~3 000 000 hab.',
      centreRelatif: Offset(0.22, 0.77),
    ),
  ];
}
