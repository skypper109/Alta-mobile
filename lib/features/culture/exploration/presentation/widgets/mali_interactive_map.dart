import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/culture_theme.dart';
import '../../data/models/mali_region.dart';
import '../../data/models/region_geo_path.dart';
import 'mali_map_painter.dart';

/// Widget interactif de la carte vectorielle du Mali avec gestion tactile et zoom
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
  late final AnimationController _pulseController;
  final TransformationController _transformController =
      TransformationController();
  // Cache local pour les hit-tests (recalculé si la taille change)
  final Map<String, Path> _cachedPaths = {};
  Size _lastSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      // Ralenti à 2400ms pour réduire la charge CPU (moins de repaints/sec)
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  void _invalidatePathCache() {
    _cachedPaths.clear();
  }

  void _handleTapUp(TapUpDetails details) {
    final localPosition = details.localPosition;
    if (_lastSize.isEmpty) return;

    // Calcul des paths à la volée (déjà optimisé avec cache dans le painter)
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
      // Tap dans le vide (hors du Mali) -> désélectionne
      if (widget.selectedRegionId != null) {
        HapticFeedback.lightImpact();
        widget.onRegionSelected(null);
      }
    }
  }

  void _resetZoom() {
    HapticFeedback.selectionClick();
    _transformController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final mapWidth = constraints.maxWidth;
        // Hauteur proportionnelle à la géographie du Mali (format portrait / carré étendu)
        final mapHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : mapWidth * 0.95;

        final newSize = Size(mapWidth, mapHeight);
        // Invalider le cache des paths si la taille a changé
        if (_lastSize != newSize) {
          _invalidatePathCache();
          _lastSize = newSize;
        }

        return Stack(
          children: [
            // ── Conteneur interactif avec zoom et déplacement ──────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0C1322) : const Color(0xFFF3EFE6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? Colors.black : CultureTheme.primaryBlue)
                          .withValues(alpha: isDark ? 0.40 : 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 0.85,
                  maxScale: 3.5,
                  boundaryMargin: const EdgeInsets.all(40),
                  child: GestureDetector(
                    onTapUp: _handleTapUp,
                    behavior: HitTestBehavior.opaque,
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: Size(mapWidth, mapHeight),
                            painter: MaliMapPainter(
                              regions: widget.regions,
                              selectedRegionId: widget.selectedRegionId,
                              pulseValue: _pulseController.value,
                              isDark: isDark,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Boussole / Rose des vents culturelle (Haut Droite) ───────────
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (isDark ? CultureTheme.darkSurface : Colors.white)
                      .withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.explore_rounded,
                      size: 16,
                      color: CultureTheme.orPatrimoine,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'N',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : CultureTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bouton Réinitialiser le Zoom (Bas Droite) ────────────────────
            Positioned(
              bottom: 14,
              right: 14,
              child: GestureDetector(
                onTap: _resetZoom,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isDark ? CultureTheme.darkSurface : Colors.white)
                        .withValues(alpha: 0.90),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.center_focus_strong_rounded,
                    size: 18,
                    color: isDark ? CultureTheme.cyanTurquoise : CultureTheme.primaryBlue,
                  ),
                ),
              ),
            ),

            // ── Légende du Fleuve Niger (Bas Gauche) ─────────────────────────
            Positioned(
              bottom: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (isDark ? CultureTheme.darkSurface : Colors.white)
                      .withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 3,
                      decoration: BoxDecoration(
                        color: CultureTheme.fleuveNiger,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Djoliba (Fleuve Niger)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
