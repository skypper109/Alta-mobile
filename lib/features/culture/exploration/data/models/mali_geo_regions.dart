import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;

/// Modèle pour les délimitations géographiques précises des régions du Mali
class MaliRegionBoundary {
  final String id;
  final String name;
  final Color color;
  final List<LatLng> polygon;
  final LatLng center;

  const MaliRegionBoundary({
    required this.id,
    required this.name,
    required this.color,
    required this.polygon,
    required this.center,
  });
}

/// Modèle pour l'affichage des villes phares du Mali sur la carte
class MaliMajorCity {
  final String name;
  final LatLng latLng;
  final String regionId;
  final bool isCapital;

  const MaliMajorCity({
    required this.name,
    required this.latLng,
    required this.regionId,
    this.isCapital = false,
  });
}

/// Registre des 8 régions géographiques et des villes principales du Mali
abstract final class MaliGeoRegionsRegistry {
  // ── 1. RÉGION DE KAYES (Ouest) ─────────────────────────────────────────────
  static const MaliRegionBoundary kayes = MaliRegionBoundary(
    id: 'kayes',
    name: 'Kayes',
    color: Color(0xFFE65100), // Orange chaleureux
    center: LatLng(14.4, -11.3),
    polygon: [
      LatLng(15.8, -12.5),
      LatLng(16.2, -11.5),
      LatLng(15.6, -10.5),
      LatLng(14.2, -10.2),
      LatLng(13.0, -11.0),
      LatLng(12.4, -11.8),
      LatLng(13.2, -12.4),
      LatLng(14.5, -12.5),
      LatLng(15.8, -12.5),
    ],
  );

  // ── 2. RÉGION DE KOULIKORO & BAMAKO (Sud-Ouest) ───────────────────────────
  static const MaliRegionBoundary koulikoro = MaliRegionBoundary(
    id: 'koulikoro',
    name: 'Koulikoro',
    color: Color(0xFFF57F17), // Jaune ambre mandingue
    center: LatLng(12.7, -7.9),
    polygon: [
      LatLng(15.0, -8.8),
      LatLng(14.8, -7.5),
      LatLng(13.6, -6.8),
      LatLng(12.2, -7.2),
      LatLng(11.8, -8.6),
      LatLng(12.8, -8.9),
      LatLng(14.2, -8.8),
      LatLng(15.0, -8.8),
    ],
  );

  // ── 3. RÉGION DE SIKASSO (Sud Kénédougou) ──────────────────────────────────
  static const MaliRegionBoundary sikasso = MaliRegionBoundary(
    id: 'sikasso',
    name: 'Sikasso',
    color: Color(0xFF2E7D32), // Vert savane et vergers
    center: LatLng(11.4, -6.0),
    polygon: [
      LatLng(12.5, -7.2),
      LatLng(12.8, -5.8),
      LatLng(11.8, -5.0),
      LatLng(10.2, -5.5),
      LatLng(10.5, -6.5),
      LatLng(11.2, -7.5),
      LatLng(12.5, -7.2),
    ],
  );

  // ── 4. RÉGION DE SÉGOU (Centre / 4 444 Balanzans) ──────────────────────────
  static const MaliRegionBoundary segou = MaliRegionBoundary(
    id: 'segou',
    name: 'Ségou',
    color: Color(0xFF8E24AA), // Pourpre royal
    center: LatLng(13.4, -6.0),
    polygon: [
      LatLng(14.6, -6.8),
      LatLng(14.2, -5.4),
      LatLng(13.2, -5.2),
      LatLng(12.8, -5.8),
      LatLng(13.2, -6.8),
      LatLng(14.0, -7.2),
      LatLng(14.6, -6.8),
    ],
  );

  // ── 5. RÉGION DE MOPTI (Venise Malienne & Pays Dogon) ──────────────────────
  static const MaliRegionBoundary mopti = MaliRegionBoundary(
    id: 'mopti',
    name: 'Mopti',
    color: Color(0xFF0288D1), // Bleu fleuve Djoliba
    center: LatLng(14.4, -4.1),
    polygon: [
      LatLng(15.8, -5.2),
      LatLng(15.6, -3.2),
      LatLng(14.2, -2.8),
      LatLng(13.8, -3.5),
      LatLng(13.6, -4.5),
      LatLng(14.2, -5.2),
      LatLng(15.8, -5.2),
    ],
  );

  // ── 6. RÉGION DE TOMBOUCTOU (Nord Sahélien / Cité 333 Saints) ──────────────
  static const MaliRegionBoundary tombouctou = MaliRegionBoundary(
    id: 'tombouctou',
    name: 'Tombouctou',
    color: Color(0xFFD4A017), // Or sahélien
    center: LatLng(17.5, -3.5),
    polygon: [
      LatLng(24.5, -5.0),
      LatLng(24.8, -3.0),
      LatLng(21.5, -1.2),
      LatLng(16.5, -1.8),
      LatLng(15.8, -3.5),
      LatLng(16.2, -4.5),
      LatLng(19.5, -6.2),
      LatLng(24.5, -5.0),
    ],
  );

  // ── 7. RÉGION DE GAO (Est / Vallée du Fleuve & Songhaï) ────────────────────
  static const MaliRegionBoundary gao = MaliRegionBoundary(
    id: 'gao',
    name: 'Gao',
    color: Color(0xFFE64A19), // Ocre rouge Songhoï
    center: LatLng(16.3, -0.1),
    polygon: [
      LatLng(18.0, -1.5),
      LatLng(18.2, 1.0),
      LatLng(16.0, 1.5),
      LatLng(15.0, 0.5),
      LatLng(14.8, -0.8),
      LatLng(16.5, -1.8),
      LatLng(18.0, -1.5),
    ],
  );

  // ── 8. RÉGION DE KIDAL (Nord-Est / Adrar des Ifoghas) ──────────────────────
  static const MaliRegionBoundary kidal = MaliRegionBoundary(
    id: 'kidal',
    name: 'Kidal',
    color: Color(0xFF558B2F), // Vert olive désertique
    center: LatLng(18.8, 1.3),
    polygon: [
      LatLng(21.5, -1.2),
      LatLng(21.0, 2.5),
      LatLng(19.5, 4.2),
      LatLng(17.5, 2.8),
      LatLng(18.2, 1.0),
      LatLng(18.0, -1.5),
      LatLng(21.5, -1.2),
    ],
  );

  /// Liste complète des 8 délimitations régionales
  static const List<MaliRegionBoundary> allRegions = [
    kayes,
    koulikoro,
    sikasso,
    segou,
    mopti,
    tombouctou,
    gao,
    kidal,
  ];

  /// Villes phares affichées sur la carte
  static const List<MaliMajorCity> majorCities = [
    MaliMajorCity(
      name: 'Bamako',
      latLng: LatLng(12.6392, -8.0029),
      regionId: 'koulikoro',
      isCapital: true,
    ),
    MaliMajorCity(
      name: 'Kayes',
      latLng: LatLng(14.4469, -11.4445),
      regionId: 'kayes',
    ),
    MaliMajorCity(
      name: 'Koulikoro',
      latLng: LatLng(12.8627, -7.5599),
      regionId: 'koulikoro',
    ),
    MaliMajorCity(
      name: 'Sikasso',
      latLng: LatLng(11.3176, -5.6664),
      regionId: 'sikasso',
    ),
    MaliMajorCity(
      name: 'Ségou',
      latLng: LatLng(13.4317, -6.2157),
      regionId: 'segou',
    ),
    MaliMajorCity(
      name: 'Mopti',
      latLng: LatLng(14.4958, -4.1856),
      regionId: 'mopti',
    ),
    MaliMajorCity(
      name: 'Djenné',
      latLng: LatLng(13.9056, -4.5550),
      regionId: 'mopti',
    ),
    MaliMajorCity(
      name: 'Tombouctou',
      latLng: LatLng(16.7666, -3.0026),
      regionId: 'tombouctou',
    ),
    MaliMajorCity(
      name: 'Gao',
      latLng: LatLng(16.2717, -0.0447),
      regionId: 'gao',
    ),
    MaliMajorCity(
      name: 'Kidal',
      latLng: LatLng(18.4411, 1.4078),
      regionId: 'kidal',
    ),
  ];
}
