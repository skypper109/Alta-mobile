import 'package:flutter/material.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/models/mali_region.dart';
import '../../data/models/region_geo_path.dart';

/// CustomPainter haute précision calqué sur la direction artistique de référence
class MaliMapPainter extends CustomPainter {
  final List<MaliRegion> regions;
  final String? selectedRegionId;
  final bool isDark;

  final Map<String, Path> _pathCache = {};
  Size _cachedSize = Size.zero;

  MaliMapPainter({
    required this.regions,
    required this.selectedRegionId,
    required this.isDark,
  });

  Path _getPath(RegionGeoPath geoPath, Size size) {
    if (_cachedSize != size) {
      _pathCache.clear();
      _cachedSize = size;
    }
    return _pathCache.putIfAbsent(geoPath.regionId, () => geoPath.toPath(size));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // ── 1. Fond cartographique avec texture lin / parchemin clair ────────────
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF0C1322) : const Color(0xFFF7F4EE)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Décorations subtiles de l'Afrique de l'Ouest (côte ouest, arbres, dunes)
    _drawWestAfricaContext(canvas, size);

    // Noms des pays voisins en typographie sérif douce
    _drawNeighborCountryLabels(canvas, size);

    // ── 2. Ombre portée globale sous la carte du Mali ────────────────────────
    _drawCountryGlobalShadow(canvas, size);

    // ── 3. Remplissage des 8 régions avec leurs couleurs pastel authentiques ──
    for (final geoPath in MaliGeoRegistry.all) {
      _drawRegionPolygon(canvas, geoPath, size);
    }

    // ── 4. Bordures blanches nettes entre toutes les régions ─────────────────
    _drawRegionBorders(canvas, size);

    // ── 5. Tracé du Fleuve Niger (Djoliba) ───────────────────────────────────
    _drawNigerRiver(canvas, size);

    // ── 6. Icônes culturelles vectorielles et noms des régions ───────────────
    for (final geoPath in MaliGeoRegistry.all) {
      final isSelected = geoPath.regionId == selectedRegionId;
      _drawRegionBadge(canvas, geoPath, size, isSelected: isSelected);
    }
  }

  // ── DÉCORATION DE L'ARRIÈRE-PLAN GÉOGRAPHIQUE ──────────────────────────────
  void _drawWestAfricaContext(Canvas canvas, Size size) {
    final scaleX = size.width / 1000.0;
    final scaleY = size.height / 1000.0;

    // Ligne de côte atlantique très douce à l'ouest (Sénégal / Mauritanie)
    final coastPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.04)
          : const Color(0xFFD6CEBD).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final coastPath = Path();
    coastPath.moveTo(40 * scaleX, 200 * scaleY);
    coastPath.quadraticBezierTo(
      10 * scaleX, 400 * scaleY,
      60 * scaleX, 600 * scaleY,
    );
    coastPath.quadraticBezierTo(
      30 * scaleX, 800 * scaleY,
      100 * scaleX, 950 * scaleY,
    );
    canvas.drawPath(coastPath, coastPaint);

    // Arbres clairsemés de savane en arrière-plan
    final treePaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.06)
          : const Color(0xFF8C7D6B).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    _drawBackgroundTree(canvas, Offset(290 * scaleX, 380 * scaleY), 16 * scaleX, treePaint);
    _drawBackgroundTree(canvas, Offset(920 * scaleX, 300 * scaleY), 18 * scaleX, treePaint);
    _drawBackgroundTree(canvas, Offset(820 * scaleX, 550 * scaleY), 15 * scaleX, treePaint);
    _drawBackgroundTree(canvas, Offset(390 * scaleX, 440 * scaleY), 14 * scaleX, treePaint);
    _drawBackgroundTree(canvas, Offset(690 * scaleX, 200 * scaleY), 15 * scaleX, treePaint);
  }

  void _drawBackgroundTree(Canvas canvas, Offset pos, double size, Paint paint) {
    final fillPaint = Paint()
      ..color = paint.color.withValues(alpha: isDark ? 0.04 : 0.12)
      ..style = PaintingStyle.fill;

    // Tronc
    canvas.drawLine(pos, Offset(pos.dx, pos.dy - size * 0.7), paint);
    // Feuillage acacia
    final crown = Rect.fromCenter(
      center: Offset(pos.dx, pos.dy - size * 0.85),
      width: size * 1.5,
      height: size * 0.5,
    );
    canvas.drawOval(crown, fillPaint);
    canvas.drawOval(crown, paint);
  }

  // ── LABELS DES PAYS VOISINS ────────────────────────────────────────────────
  void _drawNeighborCountryLabels(Canvas canvas, Size size) {
    final scaleX = size.width / 1000.0;
    final scaleY = size.height / 1000.0;

    for (final neighbor in MaliGeoRegistry.neighborCountries) {
      final textSpan = TextSpan(
        text: neighbor.name,
        style: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.22)
              : const Color(0xFF8A7E6C).withValues(alpha: 0.45),
          fontSize: 10.5 * scaleX.clamp(0.8, 1.2),
          fontWeight: FontWeight.w700,
          letterSpacing: 2.2,
          fontFamily: 'serif',
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      final pos = Offset(
        neighbor.relativePos.dx * scaleX - textPainter.width / 2,
        neighbor.relativePos.dy * scaleY - textPainter.height / 2,
      );
      textPainter.paint(canvas, pos);
    }
  }

  // ── OMBRE PORTÉE GLOBALE DU PAYS ───────────────────────────────────────────
  void _drawCountryGlobalShadow(Canvas canvas, Size size) {
    final combinedPath = Path();
    for (final geoPath in MaliGeoRegistry.all) {
      combinedPath.addPath(_getPath(geoPath, size), Offset.zero);
    }

    final shadowPaint = Paint()
      ..color = (isDark ? Colors.black : const Color(0xFF6B583E))
          .withValues(alpha: isDark ? 0.45 : 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    canvas.save();
    canvas.translate(0, 6);
    canvas.drawPath(combinedPath, shadowPaint);
    canvas.restore();
  }

  // ── REMPLISSAGE POLYGONES DES RÉGIONS ──────────────────────────────────────
  void _drawRegionPolygon(Canvas canvas, RegionGeoPath geoPath, Size size) {
    final path = _getPath(geoPath, size);
    final isSelected = geoPath.regionId == selectedRegionId;
    final baseColor = _getExactRegionColor(geoPath.regionId);

    if (isSelected) {
      // Région sélectionnée : mise en valeur éclatante avec lueur interne
      final fillPaint = Paint()
        ..color = baseColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);

      final highlightGlow = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 8);
      canvas.drawPath(path, highlightGlow);
    } else {
      // Région standard : remplissage doux pastel
      final fillPaint = Paint()
        ..color = isDark
            ? Color.alphaBlend(baseColor.withValues(alpha: 0.65), const Color(0xFF0F172A))
            : baseColor
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);
    }
  }

  // ── BORDURES BLANCHES ENTRE LES RÉGIONS ───────────────────────────────────
  void _drawRegionBorders(Canvas canvas, Size size) {
    for (final geoPath in MaliGeoRegistry.all) {
      final path = _getPath(geoPath, size);
      final isSelected = geoPath.regionId == selectedRegionId;

      if (isSelected) {
        // Bordure sélectionnée renforcée
        final borderPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 3.2
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, borderPaint);

        final strokeAccent = Paint()
          ..color = CultureTheme.primaryBlue.withValues(alpha: 0.7)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, strokeAccent);
      } else {
        // Bordure blanche élégante de 2.0px
        final borderPaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(path, borderPaint);
      }
    }
  }

  // ── TRACÉ DU FLEUVE NIGER ──────────────────────────────────────────────────
  void _drawNigerRiver(Canvas canvas, Size size) {
    final riverPath = MaliGeoRegistry.getNigerRiverPath(size);

    final riverGlowPaint = Paint()
      ..color = CultureTheme.cyanTurquoise.withValues(alpha: 0.30)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(riverPath, riverGlowPaint);

    final riverPaint = Paint()
      ..color = const Color(0xFF5AB6D3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(riverPath, riverPaint);
  }

  // ── BADGE CULTUREL SUR LA RÉGION (ICÔNE VECTORIELLE + LIBELLÉ) ─────────────
  void _drawRegionBadge(
    Canvas canvas,
    RegionGeoPath geoPath,
    Size size, {
    required bool isSelected,
  }) {
    final center = geoPath.getScaledCenter(size);
    final regionData = regions.where((r) => r.id == geoPath.regionId).firstOrNull;
    final regionName = regionData?.nom ?? geoPath.regionId;
    final scale = (size.width / 1000.0).clamp(0.75, 1.3);

    // Dessin de l'icône culturelle
    _drawExactCulturalIcon(
      canvas: canvas,
      iconType: geoPath.culturalIconName,
      center: Offset(center.dx, center.dy - 12 * scale),
      scale: scale * (isSelected ? 1.2 : 1.0),
    );

    // Dessin du texte de la région
    final textSpan = TextSpan(
      text: regionName,
      style: TextStyle(
        color: const Color(0xFF1E284A),
        fontSize: (isSelected ? 14 : 12.5) * scale,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.2,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final textPos = Offset(
      center.dx - textPainter.width / 2,
      center.dy + 4 * scale,
    );

    textPainter.paint(canvas, textPos);
  }

  // ── ICÔNES CULTURELLES VECTORIELLES FIDÈLES À LA RÉFÉRENCE ─────────────────
  void _drawExactCulturalIcon({
    required Canvas canvas,
    required String iconType,
    required Offset center,
    required double scale,
  }) {
    final s = 16.0 * scale;

    switch (iconType) {
      case 'mosquee_sankore':
        // Minaret de Tombouctou avec torons saillants
        final iconPaint = Paint()
          ..color = const Color(0xFF4A3416)
          ..style = PaintingStyle.fill;
        final stroke = Paint()
          ..color = const Color(0xFF4A3416)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4 * scale;

        final tower = Path();
        tower.moveTo(center.dx - s * 0.45, center.dy + s * 0.5);
        tower.lineTo(center.dx - s * 0.25, center.dy - s * 0.5);
        tower.lineTo(center.dx + s * 0.25, center.dy - s * 0.5);
        tower.lineTo(center.dx + s * 0.45, center.dy + s * 0.5);
        tower.close();
        canvas.drawPath(tower, iconPaint);

        // Torons horizontaux
        canvas.drawLine(Offset(center.dx - s * 0.55, center.dy - s * 0.2), Offset(center.dx + s * 0.55, center.dy - s * 0.2), stroke);
        canvas.drawLine(Offset(center.dx - s * 0.65, center.dy + s * 0.1), Offset(center.dx + s * 0.65, center.dy + s * 0.1), stroke);
        // Pinacle sommital
        canvas.drawCircle(Offset(center.dx, center.dy - s * 0.65), 2.8 * scale, iconPaint);
        break;

      case 'acacia_desert':
        // Grand acacia parasol de Kidal
        final treePaint = Paint()
          ..color = const Color(0xFF2E4624)
          ..style = PaintingStyle.fill;
        final trunkPaint = Paint()
          ..color = const Color(0xFF2E4624)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0 * scale;

        final base = Offset(center.dx, center.dy + s * 0.5);
        canvas.drawLine(base, Offset(base.dx, base.dy - s * 0.8), trunkPaint);
        canvas.drawLine(Offset(base.dx, base.dy - s * 0.4), Offset(base.dx - s * 0.4, base.dy - s * 0.7), trunkPaint);
        canvas.drawLine(Offset(base.dx, base.dy - s * 0.4), Offset(base.dx + s * 0.4, base.dy - s * 0.7), trunkPaint);

        final canopy = Rect.fromCenter(
          center: Offset(base.dx, base.dy - s * 0.85),
          width: s * 1.5,
          height: s * 0.55,
        );
        canvas.drawOval(canopy, treePaint);
        break;

      case 'tombeau_askia':
        // Tombeau des Askia à degrés (Gao)
        final iconPaint = Paint()
          ..color = const Color(0xFF4C2F15)
          ..style = PaintingStyle.fill;

        final path = Path();
        path.moveTo(center.dx - s * 0.6, center.dy + s * 0.45);
        path.lineTo(center.dx - s * 0.45, center.dy + s * 0.1);
        path.lineTo(center.dx - s * 0.3, center.dy - s * 0.2);
        path.lineTo(center.dx, center.dy - s * 0.6);
        path.lineTo(center.dx + s * 0.3, center.dy - s * 0.2);
        path.lineTo(center.dx + s * 0.45, center.dy + s * 0.1);
        path.lineTo(center.dx + s * 0.6, center.dy + s * 0.45);
        path.close();
        canvas.drawPath(path, iconPaint);
        break;

      case 'pirogue_mopti':
        // Pirogue sur le Niger avec 2 rameurs (Mopti)
        final iconPaint = Paint()
          ..color = const Color(0xFF1B3D55)
          ..style = PaintingStyle.fill;

        final boat = Path();
        boat.moveTo(center.dx - s * 0.7, center.dy + s * 0.15);
        boat.quadraticBezierTo(center.dx, center.dy + s * 0.55, center.dx + s * 0.7, center.dy + s * 0.15);
        boat.close();
        canvas.drawPath(boat, iconPaint);

        canvas.drawCircle(Offset(center.dx - s * 0.25, center.dy - s * 0.12), 2.8 * scale, iconPaint);
        canvas.drawCircle(Offset(center.dx + s * 0.25, center.dy - s * 0.12), 2.8 * scale, iconPaint);
        break;

      case 'balanzan_segou':
        // Minaret / Balanzan de Ségou
        final iconPaint = Paint()
          ..color = const Color(0xFF4A203C)
          ..style = PaintingStyle.fill;

        final path = Path();
        path.moveTo(center.dx - s * 0.35, center.dy + s * 0.5);
        path.lineTo(center.dx - s * 0.2, center.dy - s * 0.4);
        path.lineTo(center.dx, center.dy - s * 0.7);
        path.lineTo(center.dx + s * 0.2, center.dy - s * 0.4);
        path.lineTo(center.dx + s * 0.35, center.dy + s * 0.5);
        path.close();
        canvas.drawPath(path, iconPaint);
        break;

      case 'case_traditionnelle':
        // Case traditionnelle de Kayes
        final iconPaint = Paint()
          ..color = const Color(0xFF552212)
          ..style = PaintingStyle.fill;

        final hutBase = Rect.fromCenter(
          center: Offset(center.dx, center.dy + s * 0.2),
          width: s * 0.8,
          height: s * 0.55,
        );
        canvas.drawRect(hutBase, iconPaint);

        final roof = Path();
        roof.moveTo(center.dx - s * 0.55, center.dy - s * 0.05);
        roof.lineTo(center.dx, center.dy - s * 0.65);
        roof.lineTo(center.dx + s * 0.55, center.dy - s * 0.05);
        roof.close();
        canvas.drawPath(roof, iconPaint);
        break;

      case 'pont_manding':
        // Pont / Monts Mandingues de Koulikoro
        final iconPaint = Paint()
          ..color = const Color(0xFF5A3C08)
          ..style = PaintingStyle.fill;

        final path = Path();
        path.moveTo(center.dx - s * 0.7, center.dy + s * 0.35);
        path.lineTo(center.dx - s * 0.2, center.dy - s * 0.4);
        path.lineTo(center.dx + s * 0.2, center.dy + s * 0.05);
        path.lineTo(center.dx + s * 0.5, center.dy - s * 0.25);
        path.lineTo(center.dx + s * 0.7, center.dy + s * 0.35);
        path.close();
        canvas.drawPath(path, iconPaint);
        break;

      case 'masque_senoufo':
      default:
        // Masque rituel Sénoufo de Sikasso
        final iconPaint = Paint()
          ..color = const Color(0xFF1E4416)
          ..style = PaintingStyle.fill;

        final maskRect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: s * 0.65, height: s * 1.05),
          Radius.circular(s * 0.32),
        );
        canvas.drawRRect(maskRect, iconPaint);

        // Yeux ajourés
        final eyePaint = Paint()
          ..color = const Color(0xFFAACFA2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(center.dx - s * 0.15, center.dy - s * 0.15), 1.8 * scale, eyePaint);
        canvas.drawCircle(Offset(center.dx + s * 0.15, center.dy - s * 0.15), 1.8 * scale, eyePaint);
        break;
    }
  }

  // ── COULEURS DES 8 RÉGIONS (CALQUÉES SUR L'IMAGE) ─────────────────────────
  Color _getExactRegionColor(String regionId) {
    switch (regionId) {
      case 'tombouctou':
        return const Color(0xFFE8C576); // Sable Doré
      case 'kidal':
        return const Color(0xFFC8D4AC); // Vert Sauge
      case 'gao':
        return const Color(0xFFE0B885); // Camel / Grès
      case 'mopti':
        return const Color(0xFFA6CCE2); // Bleu Delta
      case 'segou':
        return const Color(0xFFCEABC1); // Lilas / Mauve
      case 'kayes':
        return const Color(0xFFEAA082); // Terracotta / Corail
      case 'koulikoro':
        return const Color(0xFFF0C058); // Ocre / Bouton d'or
      case 'sikasso':
        return const Color(0xFFAACFA2); // Vert Feuille
      default:
        return const Color(0xFFE8C576);
    }
  }

  @override
  bool shouldRepaint(covariant MaliMapPainter oldDelegate) {
    return oldDelegate.selectedRegionId != selectedRegionId ||
        oldDelegate.isDark != isDark ||
        oldDelegate.regions != regions;
  }
}
