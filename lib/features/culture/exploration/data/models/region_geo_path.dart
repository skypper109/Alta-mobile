import 'package:flutter/material.dart';

/// Définition vectorielle et géométrique ultra-fidèle des 8 régions du Mali
/// Les coordonnées sont normalisées sur un canevas virtuel de 1000 x 1000 pixels.
class RegionGeoPath {
  final String regionId;
  final List<Offset> points;
  final Offset centre;
  final String culturalIconName;

  const RegionGeoPath({
    required this.regionId,
    required this.points,
    required this.centre,
    this.culturalIconName = '',
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

/// Modèle pour les labels des pays limitrophes
class NeighborCountryLabel {
  final String name;
  final Offset relativePos;

  const NeighborCountryLabel({
    required this.name,
    required this.relativePos,
  });
}

/// Registre géométrique et cartographique du Mali
abstract final class MaliGeoRegistry {
  // ── 1. TOMBOUCTOU (Grand Nord & Cité des 333 Saints) ──────────────────────
  static const RegionGeoPath tombouctou = RegionGeoPath(
    regionId: 'tombouctou',
    culturalIconName: 'mosquee_sankore',
    centre: Offset(530, 360),
    points: [
      Offset(400, 180),
      Offset(410, 270),
      Offset(420, 380),
      Offset(440, 470),
      Offset(250, 480),
      Offset(350, 480),
      Offset(450, 460),
      Offset(580, 470),
      Offset(650, 370),
      Offset(620, 350),
      Offset(660, 290),
      Offset(530, 230),
      Offset(400, 180),
    ],
  );

  // ── 2. KIDAL (Nord-Est Saharien / Adrar des Ifoghas) ──────────────────────
  static const RegionGeoPath kidal = RegionGeoPath(
    regionId: 'kidal',
    culturalIconName: 'acacia_desert',
    centre: Offset(740, 370),
    points: [
      Offset(660, 290),
      Offset(760, 340),
      Offset(850, 380),
      Offset(890, 400),
      Offset(870, 440),
      Offset(780, 440),
      Offset(720, 410),
      Offset(620, 430),
      Offset(650, 370),
      Offset(620, 350),
      Offset(660, 290),
    ],
  );

  // ── 3. GAO (Est / Vallée du Fleuve & Empire Songhaï) ──────────────────────
  static const RegionGeoPath gao = RegionGeoPath(
    regionId: 'gao',
    culturalIconName: 'tombeau_askia',
    centre: Offset(735, 480),
    points: [
      Offset(650, 370),
      Offset(620, 430),
      Offset(720, 410),
      Offset(780, 440),
      Offset(870, 440),
      Offset(890, 490),
      Offset(880, 510),
      Offset(760, 520),
      Offset(670, 520),
      Offset(580, 470),
      Offset(650, 370),
    ],
  );

  // ── 4. MOPTI (Centre / Delta Intérieur & Falaise de Bandiagara) ───────────
  static const RegionGeoPath mopti = RegionGeoPath(
    regionId: 'mopti',
    culturalIconName: 'pirogue_mopti',
    centre: Offset(530, 530),
    points: [
      Offset(450, 460),
      Offset(580, 470),
      Offset(670, 520),
      Offset(640, 550),
      Offset(590, 580),
      Offset(540, 620),
      Offset(490, 590),
      Offset(460, 560),
      Offset(450, 460),
    ],
  );

  // ── 5. SÉGOU (Centre-Sud / Cité des Balanzans & Royaume Bambara) ──────────
  static const RegionGeoPath segou = RegionGeoPath(
    regionId: 'segou',
    culturalIconName: 'balanzan_segou',
    centre: Offset(360, 540),
    points: [
      Offset(250, 480),
      Offset(350, 480),
      Offset(450, 460),
      Offset(460, 560),
      Offset(400, 600),
      Offset(360, 600),
      Offset(280, 580),
      Offset(250, 480),
    ],
  );

  // ── 6. KAYES (Ouest / 1ère Région, Fort de Médine & Cascades) ─────────────
  static const RegionGeoPath kayes = RegionGeoPath(
    regionId: 'kayes',
    culturalIconName: 'case_traditionnelle',
    centre: Offset(190, 540),
    points: [
      Offset(130, 470),
      Offset(170, 465),
      Offset(250, 480),
      Offset(280, 580),
      Offset(230, 600),
      Offset(180, 595),
      Offset(140, 590),
      Offset(130, 560),
      Offset(100, 520),
      Offset(130, 470),
    ],
  );

  // ── 7. KOULIKORO (Sud-Ouest / Monts Mandingues & Vallée du Djoliba) ────────
  static const RegionGeoPath koulikoro = RegionGeoPath(
    regionId: 'koulikoro',
    culturalIconName: 'pont_manding',
    centre: Offset(310, 630),
    points: [
      Offset(280, 580),
      Offset(360, 600),
      Offset(400, 600),
      Offset(360, 660),
      Offset(300, 670),
      Offset(270, 680),
      Offset(240, 640),
      Offset(230, 600),
      Offset(280, 580),
    ],
  );

  // ── 8. SIKASSO (Sud / Le Kénédougou & Jardin du Mali) ─────────────────────
  static const RegionGeoPath sikasso = RegionGeoPath(
    regionId: 'sikasso',
    culturalIconName: 'masque_senoufo',
    centre: Offset(370, 680),
    points: [
      Offset(270, 680),
      Offset(300, 670),
      Offset(360, 660),
      Offset(400, 600),
      Offset(460, 560),
      Offset(490, 590),
      Offset(460, 620),
      Offset(450, 720),
      Offset(420, 740),
      Offset(380, 740),
      Offset(340, 730),
      Offset(280, 720),
      Offset(270, 680),
    ],
  );

  /// Liste ordonnée de toutes les 8 grandes régions culturelles
  static const List<RegionGeoPath> all = [
    tombouctou,
    kidal,
    gao,
    mopti,
    segou,
    kayes,
    koulikoro,
    sikasso,
  ];

  /// Labels des pays limitrophes du Mali
  static const List<NeighborCountryLabel> neighborCountries = [
    NeighborCountryLabel(name: 'MAURITANIE', relativePos: Offset(210, 360)),
    NeighborCountryLabel(name: 'ALGÉRIE', relativePos: Offset(810, 260)),
    NeighborCountryLabel(name: 'NIGER', relativePos: Offset(940, 480)),
    NeighborCountryLabel(name: 'BURKINA FASO', relativePos: Offset(640, 640)),
    NeighborCountryLabel(name: 'GUINÉE', relativePos: Offset(190, 700)),
    NeighborCountryLabel(name: 'SÉNÉGAL', relativePos: Offset(70, 560)),
  ];

  /// Tracé du Fleuve Niger (Djoliba)
  static Path getNigerRiverPath(Size size) {
    final scaleX = size.width / 1000.0;
    final scaleY = size.height / 1000.0;

    final path = Path();
    path.moveTo(220 * scaleX, 640 * scaleY);
    path.quadraticBezierTo(280 * scaleX, 600 * scaleY, 340 * scaleX, 560 * scaleY);
    path.quadraticBezierTo(420 * scaleX, 520 * scaleY, 500 * scaleX, 490 * scaleY);
    path.quadraticBezierTo(560 * scaleX, 470 * scaleY, 630 * scaleX, 480 * scaleY);
    path.quadraticBezierTo(710 * scaleX, 490 * scaleY, 760 * scaleX, 520 * scaleY);
    path.quadraticBezierTo(820 * scaleX, 540 * scaleY, 880 * scaleX, 560 * scaleY);
    return path;
  }
}
