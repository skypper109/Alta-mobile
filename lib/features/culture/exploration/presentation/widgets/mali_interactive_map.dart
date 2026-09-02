import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/models/mali_region.dart';
import '../../data/models/region_geo_path.dart';
import 'mali_map_painter.dart';

/// Widget interactif de la carte culturelle du Mali avec gestes fluides,
/// boussole rose des vents, boutons zoom +/- et centrage animé sur les régions.
class MaliInteractiveMap extends StatefulWidget {
  final List<MaliRegion> regions;
  final String? selectedRegionId;
  final ValueChanged<String?> onRegionSelected;

  const MaliInteractiveMap({
    super.key,
    required this.regions,
    required this.selectedRegionId,
    required this.onRegionSelected,
  });

  @override
  State<MaliInteractiveMap> createState() => _MaliInteractiveMapState();
}

class _MaliInteractiveMapState extends State<MaliInteractiveMap>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformController =
      TransformationController();
  late AnimationController _animController;
  Animation<Matrix4>? _mapAnimation;

  final Map<String, Path> _cachedPaths = {};
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
        if (_mapAnimation != null) {
          _transformController.value = _mapAnimation!.value;
        }
      });
  }

  @override
  void didUpdateWidget(covariant MaliInteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedRegionId != oldWidget.selectedRegionId &&
        widget.selectedRegionId != null) {
      _focusOnRegion(widget.selectedRegionId!);
    } else if (widget.selectedRegionId == null &&
        oldWidget.selectedRegionId != null) {
      _animateToMatrix(Matrix4.identity());
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _invalidatePathCache() {
    _cachedPaths.clear();
  }

  void _handleTapUp(TapUpDetails details) {
    final localPosition = details.localPosition;
    if (_lastSize.isEmpty) return;

    final reversedList = MaliGeoRegistry.all.reversed.toList();
    String? hitRegionId;

    for (final geoPath in reversedList) {
      final path = _cachedPaths.putIfAbsent(
        geoPath.regionId,
        () => geoPath.toPath(_lastSize),
      );
      if (path.contains(localPosition)) {
        hitRegionId = geoPath.regionId;
        break;
      }
    }

    if (hitRegionId != null) {
      HapticFeedback.mediumImpact();
      widget.onRegionSelected(hitRegionId);
    } else {
      if (widget.selectedRegionId != null) {
        HapticFeedback.lightImpact();
        widget.onRegionSelected(null);
      }
    }
  }

  void _focusOnRegion(String regionId) {
    if (_lastSize.isEmpty) return;
    final geoPath = MaliGeoRegistry.all.where((g) => g.regionId == regionId).firstOrNull;
    if (geoPath == null) return;

    final center = geoPath.getScaledCenter(_lastSize);
    final viewCenter = Offset(_lastSize.width / 2, _lastSize.height / 2);

    const targetScale = 1.30;
    final dx = (viewCenter.dx - center.dx * targetScale);
    final dy = (viewCenter.dy - center.dy * targetScale);

    final targetMatrix = Matrix4.translationValues(dx, dy, 0.0) *
        Matrix4.diagonal3Values(targetScale, targetScale, 1.0);

    _animateToMatrix(targetMatrix);
  }

  void _animateToMatrix(Matrix4 target) {
    _mapAnimation = Matrix4Tween(
      begin: _transformController.value,
      end: target,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward(from: 0);
  }

  void _zoomIn() {
    HapticFeedback.lightImpact();
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    if (currentScale < 3.2) {
      final target =
          _transformController.value * Matrix4.diagonal3Values(1.3, 1.3, 1.0);
      _animateToMatrix(target);
    }
  }

  void _zoomOut() {
    HapticFeedback.lightImpact();
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    if (currentScale > 0.9) {
      final target =
          _transformController.value * Matrix4.diagonal3Values(0.77, 0.77, 1.0);
      _animateToMatrix(target);
    } else {
      _animateToMatrix(Matrix4.identity());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;
        final mapHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : mapWidth * 1.05;

        final newSize = Size(mapWidth, mapHeight);
        if (_lastSize != newSize) {
          _invalidatePathCache();
          _lastSize = newSize;
        }

        return Stack(
          children: [
            // ── Conteneur principal de la carte ──────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0C1322) : const Color(0xFFF7F4EE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? CultureTheme.darkBorder : const Color(0xFFE8E2D5),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : const Color(0xFF6B5A42))
                        .withValues(alpha: isDark ? 0.35 : 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 0.8,
                maxScale: 3.5,
                boundaryMargin: const EdgeInsets.all(40),
                child: GestureDetector(
                  onTapUp: _handleTapUp,
                  behavior: HitTestBehavior.opaque,
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: Size(mapWidth, mapHeight),
                      painter: MaliMapPainter(
                        regions: widget.regions,
                        selectedRegionId: widget.selectedRegionId,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Rose des vents / Boussole stylisée (Haut Gauche) ────────────
            Positioned(
              top: 14,
              left: 14,
              child: _buildCompassRose(isDark),
            ),

            // ── Boutons Zoom +/- (Bas Droite) ────────────────────────────────
            Positioned(
              bottom: 14,
              right: 14,
              child: _buildZoomControls(isDark),
            ),
          ],
        );
      },
    );
  }

  // ── ROSE DES VENTS FIDÈLE À LA RÉFÉRENCE ──────────────────────────────────
  Widget _buildCompassRose(bool isDark) {
    final bgColor = (isDark ? CultureTheme.darkSurface : Colors.white)
        .withValues(alpha: 0.95);
    final borderCol = isDark ? CultureTheme.darkBorder : const Color(0xFFE8ECF2);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 4,
            child: Text(
              'N',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF283B7E),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: CustomPaint(
              size: const Size(22, 22),
              painter: _CompassStarPainter(),
            ),
          ),
        ],
      ),
    );
  }

  // ── COMMANDES DE ZOOM FLOTTANTES (PILULE VERTICALE) ────────────────────────
  Widget _buildZoomControls(bool isDark) {
    final bgColor = (isDark ? CultureTheme.darkSurface : Colors.white)
        .withValues(alpha: 0.96);
    final borderCol = isDark ? CultureTheme.darkBorder : const Color(0xFFE8ECF2);
    final iconColor = isDark ? Colors.white : const Color(0xFF283B7E);

    return Container(
      width: 40,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _zoomIn,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Icon(Icons.add_rounded, size: 22, color: iconColor),
              ),
            ),
          ),
          Container(
            width: 26,
            height: 1,
            color: borderCol,
          ),
          GestureDetector(
            onTap: _zoomOut,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: Icon(Icons.remove_rounded, size: 22, color: iconColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Peintre de l'étoile à 4 branches de la boussole
class _CompassStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Pointe Nord (Bleu foncé)
    final northPaint = Paint()
      ..color = const Color(0xFF283B7E)
      ..style = PaintingStyle.fill;
    final northPath = Path()
      ..moveTo(center.dx, center.dy - r)
      ..lineTo(center.dx + r * 0.28, center.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(northPath, northPaint);

    final northLeftPaint = Paint()
      ..color = const Color(0xFF3F5599)
      ..style = PaintingStyle.fill;
    final northLeftPath = Path()
      ..moveTo(center.dx, center.dy - r)
      ..lineTo(center.dx - r * 0.28, center.dy)
      ..lineTo(center.dx, center.dy)
      ..close();
    canvas.drawPath(northLeftPath, northLeftPaint);

    // Pointe Sud (Gris)
    final southPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.fill;
    final southPath = Path()
      ..moveTo(center.dx, center.dy + r)
      ..lineTo(center.dx - r * 0.28, center.dy)
      ..lineTo(center.dx + r * 0.28, center.dy)
      ..close();
    canvas.drawPath(southPath, southPaint);

    // Pointes Est & Ouest (Gris)
    final eastPath = Path()
      ..moveTo(center.dx + r, center.dy)
      ..lineTo(center.dx, center.dy - r * 0.28)
      ..lineTo(center.dx, center.dy + r * 0.28)
      ..close();
    canvas.drawPath(eastPath, southPaint);

    final westPath = Path()
      ..moveTo(center.dx - r, center.dy)
      ..lineTo(center.dx, center.dy - r * 0.28)
      ..lineTo(center.dx, center.dy + r * 0.28)
      ..close();
    canvas.drawPath(westPath, southPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
