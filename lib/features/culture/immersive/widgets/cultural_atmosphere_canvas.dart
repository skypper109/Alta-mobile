import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/culture_theme.dart';

/// Canvas d'ambiance culturelle malienne vivante à 60 FPS
///
/// Intègre :
/// 1. Motifs ancestraux Bogolan en filigrane (géométrie du Manden, chevrons du Djoliba, losanges de la sagesse)
/// 2. Particules de veillée / poussière d'or de Mansa Moussa flottant doucement
/// 3. STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI
/// 4. Couleurs officielles : #F1851F (accentOrange) et #314999 (primaryBlue)
class CulturalAtmosphereCanvas extends StatefulWidget {
  final Widget child;

  /// Activer ou désactiver les micro-particules dorées
  final bool enableParticles;

  /// Activer ou désactiver les motifs géométriques Bogolan
  final bool enableBogolanMotifs;

  /// Opacité des motifs Bogolan (par défaut 0.10, visible et raffiné)
  final double motifOpacity;

  const CulturalAtmosphereCanvas({
    super.key,
    required this.child,
    this.enableParticles = true,
    this.enableBogolanMotifs = true,
    this.motifOpacity = 0.10,
  });

  @override
  State<CulturalAtmosphereCanvas> createState() =>
      _CulturalAtmosphereCanvasState();
}

class _CulturalAtmosphereCanvasState extends State<CulturalAtmosphereCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motionController;
  final List<_GoldenParticle> _particles = [];
  final math.Random _random = math.Random(42);

  @override
  void initState() {
    super.initState();

    // Boucle continue 60 FPS pour le mouvement des braises et motifs
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialisation des 28 micro-particules dorées de veillée
    if (widget.enableParticles) {
      for (int i = 0; i < 28; i++) {
        _particles.add(
          _GoldenParticle(
            x: _random.nextDouble(),
            y: _random.nextDouble(),
            size: 2.2 + _random.nextDouble() * 3.4,
            speed: 0.07 + _random.nextDouble() * 0.11,
            opacity: 0.25 + _random.nextDouble() * 0.50,
            wobbleSpeed: 1.2 + _random.nextDouble() * 2.0,
            wobbleDistance: 0.02 + _random.nextDouble() * 0.03,
            color: _random.nextBool()
                ? CultureTheme.accentOrange
                : CultureTheme.orPatrimoine,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _motionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        // Fond de texture culturelle animé
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _motionController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _BogolanAtmospherePainter(
                    progress: _motionController.value,
                    particles: widget.enableParticles ? _particles : const [],
                    isDark: isDark,
                    enableBogolan: widget.enableBogolanMotifs,
                    motifOpacity: widget.motifOpacity,
                  ),
                );
              },
            ),
          ),
        ),

        // Contenu utilisateur au premier plan
        widget.child,
      ],
    );
  }
}

/// Painter haute performance des motifs Bogolan et des particules
class _BogolanAtmospherePainter extends CustomPainter {
  final double progress;
  final List<_GoldenParticle> particles;
  final bool isDark;
  final bool enableBogolan;
  final double motifOpacity;

  _BogolanAtmospherePainter({
    required this.progress,
    required this.particles,
    required this.isDark,
    required this.enableBogolan,
    required this.motifOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // ── 1. DESSIN DES MOTIFS BOGOLAN ANCESTRAUX EN FILIGRANE ──────────────
    if (enableBogolan) {
      _paintBogolanPatterns(canvas, size);
    }

    // ── 2. DESSIN DES MICRO-PARTICULES DORÉES DE VEILLÉE ──────────────────
    if (particles.isNotEmpty) {
      _paintGoldenParticles(canvas, size);
    }
  }

  /// Peint les motifs géométriques traditionnels Bogolan (chevrons, croix, losanges)
  /// STRICTEMENT avec des couleurs plates et unies sans aucun dégradé
  void _paintBogolanPatterns(Canvas canvas, Size size) {
    final strokeColor = (isDark ? CultureTheme.accentOrange : CultureTheme.primaryBlue)
        .withValues(alpha: isDark ? motifOpacity : motifOpacity * 0.85);

    final linePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = (isDark ? CultureTheme.primaryBlue : CultureTheme.accentOrange)
          .withValues(alpha: isDark ? motifOpacity * 0.6 : motifOpacity * 0.5)
      ..style = PaintingStyle.fill;

    // Motif 1 : Chevrons du Fleuve Niger (Djoliba) le long de la marge droite
    const double chevronStep = 44.0;
    final int chevronCount = (size.height / chevronStep).ceil();
    final double rightX = size.width - 24.0;

    for (int i = 0; i < chevronCount; i++) {
      final double y = i * chevronStep;
      final path = Path()
        ..moveTo(rightX, y)
        ..lineTo(rightX + 12, y + 14)
        ..lineTo(rightX, y + 28);
      canvas.drawPath(path, linePaint);
    }

    // Motif 2 : Losanges sacrés Bogolan (Symbole de la sagesse N'Da) côté gauche
    const double diamondStep = 72.0;
    final int diamondCount = (size.height / diamondStep).ceil();
    const double leftX = 22.0;

    for (int i = 0; i < diamondCount; i++) {
      final double centerY = i * diamondStep + 36.0;
      const double radius = 9.0;

      final diamondPath = Path()
        ..moveTo(leftX, centerY - radius)
        ..lineTo(leftX + radius, centerY)
        ..lineTo(leftX, centerY + radius)
        ..lineTo(leftX - radius, centerY)
        ..close();

      canvas.drawPath(diamondPath, linePaint);

      // Point central uni
      if (i % 2 == 0) {
        canvas.drawCircle(Offset(leftX, centerY), 2.2, fillPaint);
      }
    }

    // Motif 3 : Frise de créneaux architecturaux de Djenné (sommet subtil)
    const double notchWidth = 16.0;
    const double notchHeight = 8.0;
    final int notchCount = (size.width / (notchWidth * 2)).ceil();

    final topFriezePath = Path();
    for (int i = 0; i < notchCount; i++) {
      final double startX = i * notchWidth * 2;
      topFriezePath.moveTo(startX, 6.0);
      topFriezePath.lineTo(startX + notchWidth, 6.0);
      topFriezePath.lineTo(startX + notchWidth, 6.0 + notchHeight);
      topFriezePath.lineTo(startX + notchWidth * 2, 6.0 + notchHeight);
    }
    canvas.drawPath(topFriezePath, linePaint);
  }

  /// Peint les braises montantes et la poussière d'or de veillée (60 FPS, sans dégradé)
  void _paintGoldenParticles(Canvas canvas, Size size) {
    for (final p in particles) {
      // Déplacement vertical lent vers le haut
      final double currentY = (p.y - (progress * p.speed)) % 1.0;
      // Oscillation sinusoïdale horizontale
      final double currentX =
          p.x + (math.sin((progress * p.wobbleSpeed * math.pi * 2) + p.y * 10) * p.wobbleDistance);

      final double px = (currentX % 1.0) * size.width;
      final double py = currentY * size.height;

      // Dessin du point uni (strictement aplat sans radial gradient)
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(px, py), p.size, paint);

      // Halo externe uni discret pour les plus grosses particules
      if (p.size > 3.0) {
        final haloPaint = Paint()
          ..color = p.color.withValues(alpha: p.opacity * 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawCircle(Offset(px, py), p.size * 1.8, haloPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BogolanAtmospherePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

/// Modèle d'une particule dorée pour l'atmosphère
class _GoldenParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double opacity;
  final double wobbleSpeed;
  final double wobbleDistance;
  final Color color;

  _GoldenParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.wobbleSpeed,
    required this.wobbleDistance,
    required this.color,
  });
}
