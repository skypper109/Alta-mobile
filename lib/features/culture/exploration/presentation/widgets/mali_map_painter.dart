import 'package:flutter/material.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/models/mali_region.dart';
import '../../data/models/region_geo_path.dart';

/// CustomPainter haute performance pour la carte interactive du Mali
class MaliMapPainter extends CustomPainter {
  final List<MaliRegion> regions;
  final String? selectedRegionId;
  final bool isDark;

  // Cache interne des paths pour éviter le recalcul à chaque frame
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

    // ── 1. Fond cartographique avec texture subtile ───────────────────────────
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF0C1322) : const Color(0xFFF3EFE6)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // Grille de coordonnées stylisée très discrète (lignes cartographiques)
    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.03)
          : Colors.black.withValues(alpha: 0.03)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (double x = 0; x < size.width; x += size.width / 8) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += size.height / 8) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ── 2. Dessin des polygones régionaux ────────────────────────────────────
    for (final geoPath in MaliGeoRegistry.all) {
      final path = _getPath(geoPath, size);

      final isSelected = geoPath.regionId == selectedRegionId;
      final regionData = regions.where((r) => r.id == geoPath.regionId).firstOrNull;
      final accentColor = regionData?.couleurAccent ?? CultureTheme.ocreTerre;

      if (isSelected) {
        // Remplissage éclatant et net de la région sélectionnée
        final fillPaint = Paint()
          ..color = accentColor.withValues(alpha: isDark ? 0.90 : 0.80)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);

        // Bordure contrastée
        final borderPaint = Paint()
          ..color = isDark ? Colors.white : CultureTheme.primaryBlue
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, borderPaint);
      } else {
        // Remplissage normal de région non sélectionnée
        final normalColor = isDark
            ? Color.alphaBlend(
                accentColor.withValues(alpha: 0.12),
                const Color(0xFF131D30),
              )
            : Color.alphaBlend(
                accentColor.withValues(alpha: 0.10),
                const Color(0xFFE8E2D5),
              );

        final fillPaint = Paint()
          ..color = normalColor
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);

        // Bordure fine
        final borderPaint = Paint()
          ..color = isDark
              ? const Color(0xFF263753)
              : const Color(0xFFC7BDAC)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, borderPaint);
      }
    }

    // ── 3. Tracé du Fleuve Niger (Djoliba) ───────────────────────────────────
    final riverPath = MaliGeoRegistry.getNigerRiverPath(size);

    // Lueur du fleuve
    final riverGlowPaint = Paint()
      ..color = CultureTheme.fleuveNiger.withValues(alpha: isDark ? 0.45 : 0.35)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(riverPath, riverGlowPaint);

    // Ligne nette du fleuve
    final riverPaint = Paint()
      ..color = CultureTheme.fleuveNiger
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(riverPath, riverPaint);

    // ── 4. Labels et marqueurs sur les régions ───────────────────────────────
    for (final geoPath in MaliGeoRegistry.all) {
      final center = geoPath.getScaledCenter(size);
      final isSelected = geoPath.regionId == selectedRegionId;
      final regionData = regions.where((r) => r.id == geoPath.regionId).firstOrNull;
      final name = regionData?.nom ?? geoPath.regionId.toUpperCase();
      final accentColor = regionData?.couleurAccent ?? CultureTheme.ocreTerre;

      if (isSelected) {
        // Anneau statique sur le centre
        final ringPaint = Paint()
          ..color = accentColor.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5;
        canvas.drawCircle(center, 14.0, ringPaint);

        // Pastille centrale solide
        final dotPaint = Paint()
          ..color = isDark ? Colors.white : CultureTheme.primaryBlue
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 6.0, dotPaint);

        // Badge élégant du nom de la région sélectionnée
        _drawPillLabel(
          canvas: canvas,
          center: Offset(center.dx, center.dy - 20),
          text: name.toUpperCase(),
          textColor: Colors.white,
          bgColor: isDark ? CultureTheme.darkSurface : CultureTheme.primaryBlue,
          borderColor: accentColor,
          isBold: true,
        );
      } else {
        // Point repère discret
        final dotPaint = Paint()
          ..color = isDark
              ? Colors.white.withValues(alpha: 0.6)
              : const Color(0xFF4A5568)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 3.0, dotPaint);

        // Label texte sobre
        _drawTextLabel(
          canvas: canvas,
          center: Offset(center.dx, center.dy + 8),
          text: name,
          isDark: isDark,
        );
      }
    }
  }

  void _drawPillLabel({
    required Canvas canvas,
    required Offset center,
    required String text,
    required Color textColor,
    required Color bgColor,
    required Color borderColor,
    bool isBold = false,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: textColor,
        fontSize: 10,
        fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
        letterSpacing: 0.6,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    final paddingH = 8.0;
    final paddingV = 3.5;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: textPainter.width + paddingH * 2,
        height: textPainter.height + paddingV * 2,
      ),
      const Radius.circular(10),
    );

    // Fond
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRRect(rrect, bgPaint);

    // Bordure
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(rrect, borderPaint);

    // Texte
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  void _drawTextLabel({
    required Canvas canvas,
    required Offset center,
    required String text,
    required bool isDark,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: isDark
            ? Colors.white.withValues(alpha: 0.85)
            : const Color(0xFF1A202C),
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        shadows: [
          Shadow(
            color: isDark ? Colors.black : Colors.white,
            blurRadius: 3,
          ),
        ],
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant MaliMapPainter oldDelegate) {
    return oldDelegate.selectedRegionId != selectedRegionId ||
        oldDelegate.isDark != isDark ||
        oldDelegate.regions != regions;
  }

  @override
  bool shouldRebuildSemantics(covariant MaliMapPainter oldDelegate) => false;
}
