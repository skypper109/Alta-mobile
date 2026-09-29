import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/story_experience_models.dart';

/// Vue cinématique d'une carte historique du Mali qui se trace en temps réel
class AnimatedMapStage extends StatefulWidget {
  final MapDirective mapDirective;

  const AnimatedMapStage({
    super.key,
    required this.mapDirective,
  });

  @override
  State<AnimatedMapStage> createState() => _AnimatedMapStageState();
}

class _AnimatedMapStageState extends State<AnimatedMapStage>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawController;
  late Animation<double> _drawProgress;

  @override
  void initState() {
    super.initState();
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _drawProgress = CurvedAnimation(
      parent: _drawController,
      curve: Curves.easeInOutCubic,
    );

    _drawController.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedMapStage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mapDirective.focalCityId != widget.mapDirective.focalCityId) {
      _drawController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _drawController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1B140E),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Texture parchemin stylisée
          Opacity(
            opacity: 0.20,
            child: Image.asset(
              'assets/images/culture/villes/gao_dune_rose.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),

          // Tracé vectoriel de la carte
          AnimatedBuilder(
            animation: _drawProgress,
            builder: (context, _) {
              return CustomPaint(
                painter: _HistoricalMapPainter(
                  progress: _drawProgress.value,
                  mapDirective: widget.mapDirective,
                ),
              );
            },
          ),

          // Cartouche explicatif du royaume
          Positioned(
            top: 24,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF1851F).withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.map_rounded,
                    color: Color(0xFFF1851F),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.mapDirective.mapCaption.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoricalMapPainter extends CustomPainter {
  final double progress;
  final MapDirective mapDirective;

  _HistoricalMapPainter({
    required this.progress,
    required this.mapDirective,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Échelle relative basée sur un canevas 400x300
    final scaleX = size.width / 400.0;
    final scaleY = size.height / 300.0;

    // 1. Fond du fleuve Niger (Djoliba) en courbe majestueuse
    final riverPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(30 * scaleX, 260 * scaleY)
      ..cubicTo(
        110 * scaleX, 190 * scaleY,
        180 * scaleX, 220 * scaleY,
        240 * scaleX, 120 * scaleY,
      )
      ..cubicTo(
        280 * scaleX, 60 * scaleY,
        340 * scaleX, 70 * scaleY,
        380 * scaleX, 140 * scaleY,
      );

    canvas.drawPath(riverPath, riverPaint);

    // 2. Territoire du Manden (Frontière animée qui s'illumine)
    final mandenBorder = Path()
      ..moveTo(80 * scaleX, 170 * scaleY)
      ..lineTo(160 * scaleX, 150 * scaleY)
      ..lineTo(210 * scaleX, 220 * scaleY)
      ..lineTo(140 * scaleX, 270 * scaleY)
      ..lineTo(70 * scaleX, 230 * scaleY)
      ..close();

    final borderPaint = Paint()
      ..color = const Color(0xFFF1851F).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final fillPaint = Paint()
      ..color = const Color(0xFFF1851F).withValues(alpha: 0.14 * progress)
      ..style = PaintingStyle.fill;

    canvas.drawPath(mandenBorder, fillPaint);

    // Tracé progressif de la frontière
    final metrics = mandenBorder.computeMetrics();
    for (final metric in metrics) {
      final extract = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extract, borderPaint);
    }

    // 3. Ligne de marche militaire ou d'alliance
    final marchPaint = Paint()
      ..color = Colors.amberAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(90 * scaleX, 230 * scaleY);
    path.quadraticBezierTo(130 * scaleX, 200 * scaleY, 170 * scaleX, 185 * scaleY);

    for (final metric in path.computeMetrics()) {
      final extract = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extract, marchPaint);
    }

    // 4. Points clés (Kirina, Kangaba, Koulikoro)
    if (progress > 0.4) {
      _drawCityNode(
        canvas: canvas,
        center: Offset(90 * scaleX, 230 * scaleY),
        label: 'KANGABA',
        isFocal: widgetIsFocal('kangaba'),
        alpha: progress,
      );
    }

    if (progress > 0.7) {
      _drawCityNode(
        canvas: canvas,
        center: Offset(170 * scaleX, 185 * scaleY),
        label: 'KIRINA (1235)',
        isFocal: widgetIsFocal('kirina'),
        alpha: progress,
      );
    }
  }

  bool widgetIsFocal(String id) => mapDirective.focalCityId == id;

  void _drawCityNode({
    required Canvas canvas,
    required Offset center,
    required String label,
    required bool isFocal,
    required double alpha,
  }) {
    final dotPaint = Paint()
      ..color = isFocal ? const Color(0xFFF1851F) : Colors.white
      ..style = PaintingStyle.fill;

    final haloPaint = Paint()
      ..color = (isFocal ? const Color(0xFFF1851F) : Colors.white)
          .withValues(alpha: 0.3 * alpha)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, isFocal ? 8.0 : 5.0, haloPaint);
    canvas.drawCircle(center, isFocal ? 4.5 : 3.0, dotPaint);

    final textSpan = TextSpan(
      text: label,
      style: GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        backgroundColor: Colors.black.withValues(alpha: 0.6),
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: ui.TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - (textPainter.width / 2), center.dy + 8),
    );
  }

  @override
  bool shouldRepaint(covariant _HistoricalMapPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
