import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/culture_theme.dart';
import '../models/monument_scan_models.dart';

/// Viseur HUD de vision par ordinateur pour le Scanner IA de Lieux & Monuments
/// Anime un réticule laser vertical, des cornières soudanaises et un indicateur d'analyse.
class MonumentViewfinderOverlay extends StatefulWidget {
  final ScannerState scannerState;
  final VoidCallback? onReset;

  const MonumentViewfinderOverlay({
    super.key,
    required this.scannerState,
    this.onReset,
  });

  @override
  State<MonumentViewfinderOverlay> createState() =>
      _MonumentViewfinderOverlayState();
}

class _MonumentViewfinderOverlayState extends State<MonumentViewfinderOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.08, end: 0.92).animate(
      CurvedAnimation(
        parent: _laserController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAnalyzing = widget.scannerState.isAnalyzing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        // Viseur carré harmonieux adapté à la zone centrale disponible
        final boxSize = (availableWidth * 0.76)
            .clamp(220.0, availableHeight * 0.68);

        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // ── CADRE DU VISEUR AVEC CORNIÈRES DE STYLE SOUDANAIS ───────────
            Container(
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isAnalyzing
                      ? CultureTheme.accentOrange
                      : Colors.white.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  // Coins marqués (Corner brackets)
                  _buildCorner(Alignment.topLeft),
                  _buildCorner(Alignment.topRight),
                  _buildCorner(Alignment.bottomLeft),
                  _buildCorner(Alignment.bottomRight),

                  // Réticule central discret
                  Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: CultureTheme.accentOrange.withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: CultureTheme.accentOrange,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── FAISCEAU LASER VERTICAL ANIMÉ ─────────────────────────
                  AnimatedBuilder(
                    animation: _laserAnimation,
                    builder: (context, child) {
                      final topPos = boxSize * _laserAnimation.value;
                      return Positioned(
                        top: topPos,
                        left: 12,
                        right: 12,
                        child: Container(
                          height: 2.5,
                          decoration: BoxDecoration(
                            color: CultureTheme.accentOrange,
                            boxShadow: [
                              BoxShadow(
                                color: CultureTheme.accentOrange
                                    .withValues(alpha: 0.75),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── BANDEAU D'ÉTAT SUPÉRIEUR DU VISEUR ───────────────────────────
            Positioned(
              top: (availableHeight - boxSize) / 2 - 42,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isAnalyzing
                            ? CultureTheme.accentOrange
                            : const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAnalyzing
                          ? 'ANALYSE EN COURS...'
                          : 'EDGE AI EN VEILLE ACTIVE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── INSTRUCTIONS AU BAS DU VISEUR ────────────────────────────────
            Positioned(
              bottom: (availableHeight - boxSize) / 2 - 44,
              child: Container(
                constraints: BoxConstraints(maxWidth: availableWidth * 0.85),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.scannerState.currentStepMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCorner(Alignment alignment) {
    const double length = 22;
    const double thickness = 3.5;

    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;

    return Align(
      alignment: alignment,
      child: Container(
        width: length,
        height: length,
        margin: const EdgeInsets.all(3),
        child: CustomPaint(
          painter: _CornerBracketPainter(
            color: CultureTheme.accentOrange,
            isTop: isTop,
            isLeft: isLeft,
            thickness: thickness,
          ),
        ),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final Color color;
  final bool isTop;
  final bool isLeft;
  final double thickness;

  _CornerBracketPainter({
    required this.color,
    required this.isTop,
    required this.isLeft,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) => false;
}
