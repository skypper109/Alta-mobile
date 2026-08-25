import 'package:flutter/material.dart';

/// Définition vectorielle et géométrique des frontières régionales du Mali
/// Les coordonnées sont normalisées sur un canevas virtuel de 1000 x 1000 pixels.
class RegionGeoPath {
  final String regionId;
  final List<Offset> points;
  final Offset centre;

  const RegionGeoPath({
    required this.regionId,
    required this.points,
    required this.centre,
  });

  /// Construit un [Path] Flutter mis à l'échelle pour la taille donnée
  Path toPath(Size size) {
    final scaleX = size.width / 1000.0;
    final scaleY = size.height / 1000.0;

    final path = Path();
    if (points.isEmpty) return path;

    path.moveTo(points.first.dx * scaleX, points.first.dy * scaleY);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx * scaleX, points[i].dy * scaleY);
    }
    path.close();
    return path;
  }

  /// Retourne le centre géométrique mis à l'échelle
  Offset getScaledCenter(Size size) {
    return Offset(
      centre.dx * (size.width / 1000.0),
      centre.dy * (size.height / 1000.0),
    );
  }
}

/// Registre de toutes les régions géométriques du Mali
abstract final class MaliGeoRegistry {
  // ── 1. TAOUDÉNIT (Nord saharien extrême) ───────────────────────────────────
  static const RegionGeoPath taoudenit = RegionGeoPath(
    regionId: 'taoudenit',
    centre: Offset(550, 150),
    points: [
      Offset(430, 190),
      Offset(480, 70),
      Offset(580, 20),
      Offset(660, 40),
      Offset(720, 110),
      Offset(680, 220),
      Offset(600, 260),
      Offset(510, 250),
      Offset(440, 220),
    ],
  );

  // ── 2. KIDAL (Nord-Est / Adrar des Ifoghas) ────────────────────────────────
  static const RegionGeoPath kidal = RegionGeoPath(
    regionId: 'kidal',
    centre: Offset(800, 310),
    points: [
      Offset(680, 220),
      Offset(720, 110),
      Offset(850, 150),
      Offset(950, 230),
      Offset(960, 350),
      Offset(880, 420),
      Offset(780, 410),
      Offset(730, 340),
      Offset(710, 260),
    ],
  );

  // ── 3. TOMBOUCTOU (Centre-Nord / Cité des 333 Saints & Boucle du Nord) ─────
  static const RegionGeoPath tombouctou = RegionGeoPath(
    regionId: 'tombouctou',
    centre: Offset(490, 350),
    points: [
      Offset(330, 260),
      Offset(430, 190),
      Offset(510, 250),
      Offset(600, 260),
      Offset(680, 220),
      Offset(710, 260),
      Offset(730, 340),
      Offset(680, 430),
      Offset(580, 460),
      Offset(510, 470),
      Offset(440, 450),
      Offset(380, 420),
      Offset(320, 350),
    ],
  );

  // ── 4. GAO (Est / Vallée du Fleuve & Empire Songhaï) ────────────────────────
  static const RegionGeoPath gao = RegionGeoPath(
    regionId: 'gao',
    centre: Offset(740, 520),
    points: [
      Offset(680, 430),
      Offset(730, 340),
      Offset(780, 410),
      Offset(880, 420),
      Offset(860, 510),
      Offset(800, 610),
      Offset(720, 620),
      Offset(660, 560),
      Offset(620, 490),
    ],
  );

  // ── 5. MÉNAKA (Sud-Est / Région pastorale) ─────────────────────────────────
  static const RegionGeoPath menaka = RegionGeoPath(
    regionId: 'menaka',
    centre: Offset(890, 580),
    points: [
      Offset(880, 420),
      Offset(960, 460),
      Offset(970, 590),
      Offset(910, 680),
      Offset(820, 670),
      Offset(800, 610),
      Offset(860, 510),
    ],
  );

  // ── 6. MOPTI (Centre / Delta Intérieur & Falaise de Bandiagara) ─────────────
  static const RegionGeoPath mopti = RegionGeoPath(
    regionId: 'mopti',
    centre: Offset(470, 560),
    points: [
      Offset(380, 420),
      Offset(440, 450),
      Offset(510, 470),
      Offset(580, 460),
      Offset(620, 490),
      Offset(590, 580),
      Offset(550, 660),
      Offset(480, 670),
      Offset(410, 640),
      Offset(380, 570),
      Offset(370, 490),
    ],
  );

  // ── 7. SÉGOU (Centre-Sud / Cité des Balanzans & Royaume Bambara) ───────────
  static const RegionGeoPath segou = RegionGeoPath(
    regionId: 'segou',
    centre: Offset(320, 640),
    points: [
      Offset(270, 510),
      Offset(330, 470),
      Offset(370, 490),
      Offset(380, 570),
      Offset(410, 640),
      Offset(420, 710),
      Offset(360, 740),
      Offset(290, 740),
      Offset(260, 680),
      Offset(250, 590),
    ],
  );

  // ── 8. KAYES (Ouest / 1ère Région, Fort de Médine & Cascades) ──────────────
  static const RegionGeoPath kayes = RegionGeoPath(
    regionId: 'kayes',
    centre: Offset(130, 620),
    points: [
      Offset(130, 440),
      Offset(230, 430),
      Offset(270, 510),
      Offset(250, 590),
      Offset(230, 670),
      Offset(190, 740),
      Offset(120, 770),
      Offset(40, 740),
      Offset(30, 620),
      Offset(60, 520),
    ],
  );

  // ── 9. KOULIKORO (Sud-Ouest / Monts Mandingues & Vallée du Niger) ───────────
  static const RegionGeoPath koulikoro = RegionGeoPath(
    regionId: 'koulikoro',
    centre: Offset(230, 740),
    points: [
      Offset(230, 670),
      Offset(250, 590),
      Offset(260, 680),
      Offset(290, 740),
      Offset(280, 810),
      Offset(220, 870),
      Offset(170, 840),
      Offset(160, 770),
      Offset(190, 740),
    ],
  );

  // ── 10. BAMAKO (District de la Capitale / Les Trois Caïmans) ────────────────
  static const RegionGeoPath bamako = RegionGeoPath(
    regionId: 'bamako',
    centre: Offset(220, 775),
    points: [
      Offset(205, 760),
      Offset(235, 760),
      Offset(242, 785),
      Offset(225, 798),
      Offset(202, 788),
    ],
  );

  // ── 11. SIKASSO (Sud / Le Kénédougou & Jardin du Mali) ──────────────────────
  static const RegionGeoPath sikasso = RegionGeoPath(
    regionId: 'sikasso',
    centre: Offset(360, 850),
    points: [
      Offset(290, 740),
      Offset(360, 740),
      Offset(420, 710),
      Offset(460, 760),
      Offset(470, 860),
      Offset(410, 950),
      Offset(320, 960),
      Offset(260, 910),
      Offset(280, 810),
    ],
  );

  /// Liste ordonnée de tous les tracés vectoriels
  static const List<RegionGeoPath> all = [
    taoudenit,
    kidal,
    tombouctou,
    gao,
    menaka,
    mopti,
    segou,
    kayes,
    koulikoro,
    sikasso,
    bamako, // Dessiné en dernier pour superposer l'enclave de la capitale
  ];

  /// Tracé fluide stylisé du Fleuve Niger (Djoliba) traversant le Mali
  static Path getNigerRiverPath(Size size) {
    final scaleX = size.width / 1000.0;
    final scaleY = size.height / 1000.0;

    final path = Path();
    // Départ frontière Sud-Ouest (Guinée) vers Bamako
    path.moveTo(180 * scaleX, 830 * scaleY);
    // Passe par Bamako
    path.quadraticBezierTo(210 * scaleX, 780 * scaleY, 230 * scaleX, 765 * scaleY);
    // Vers Koulikoro
    path.quadraticBezierTo(255 * scaleX, 745 * scaleY, 280 * scaleX, 710 * scaleY);
    // Vers Ségou
    path.quadraticBezierTo(310 * scaleX, 660 * scaleY, 340 * scaleX, 620 * scaleY);
    // Vers le Delta Intérieur / Mopti
    path.quadraticBezierTo(390 * scaleX, 580 * scaleY, 440 * scaleX, 530 * scaleY);
    // Vers la boucle de Tombouctou
    path.quadraticBezierTo(490 * scaleX, 470 * scaleY, 560 * scaleX, 460 * scaleY);
    // Descente vers Gao
    path.quadraticBezierTo(640 * scaleX, 480 * scaleY, 710 * scaleX, 550 * scaleY);
    // Sortie vers la frontière du Niger
    path.quadraticBezierTo(760 * scaleX, 600 * scaleY, 810 * scaleX, 660 * scaleY);

    return path;
  }
}
