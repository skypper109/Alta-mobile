import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/story_experience_models.dart';

/// Scène visuelle cinématique multi-plans temps réel (Zero Video, 100% Flutter GPU)
///
/// Superpose les plans :
/// - Plan 0 : Ciel / Arrière-plan animé dérivant lentement
/// - Plan 1 : Décor principal avec mouvement de caméra fluide (Ken Burns 60 FPS)
/// - Plan 2 : Vol d'oiseaux migrateurs et météo vivante (Particules / Brume)
/// - Plan 3 : Acteurs et silhouettes découpées
class CinematicStageViewport extends StatefulWidget {
  final StorySceneModel scene;
  final bool isPaused;

  const CinematicStageViewport({
    super.key,
    required this.scene,
    this.isPaused = false,
  });

  @override
  State<CinematicStageViewport> createState() => _CinematicStageViewportState();
}

class _CinematicStageViewportState extends State<CinematicStageViewport>
    with TickerProviderStateMixin {
  // Contrôleur de la caméra Ken Burns
  late AnimationController _cameraController;
  late Animation<double> _scaleAnimation;
  late Animation<Alignment> _alignmentAnimation;

  // Contrôleur de dérive horizontale du ciel (drift)
  late AnimationController _skyDriftController;

  // Contrôleur des oiseaux migrateurs traversant l'écran
  late AnimationController _birdsController;

  // Contrôleur de respiration et présence des acteurs
  late AnimationController _actorBreathingController;

  // Contrôleur de secousse de bataille (shake)
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _playSceneAnimations();
  }

  void _initControllers() {
    // 1. Caméra
    _cameraController = AnimationController(
      vsync: this,
      duration: widget.scene.camera.duration,
    );

    // 2. Dérive du ciel (boucle lente de 30 secondes)
    _skyDriftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 32),
    )..repeat();

    // 3. Oiseaux migrateurs (boucle de 14 secondes)
    _birdsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    // 4. Respiration acteur
    _actorBreathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    // 5. Secousse de combat
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  void _playSceneAnimations() {
    final cam = widget.scene.camera;
    _cameraController.duration = cam.duration;

    // Définition de l'échelle
    _scaleAnimation = Tween<double>(
      begin: cam.beginScale,
      end: cam.endScale,
    ).animate(CurvedAnimation(
      parent: _cameraController,
      curve: cam.curve,
    ));

    // Définition du cadrage
    final targetAlign = _getTargetAlignment(cam.preset, cam.focusAlignment);
    _alignmentAnimation = AlignmentTween(
      begin: cam.preset == CameraPreset.panLeftToRight
          ? const Alignment(-0.35, 0.0)
          : cam.preset == CameraPreset.panRightToLeft
              ? const Alignment(0.35, 0.0)
              : Alignment.center,
      end: targetAlign,
    ).animate(CurvedAnimation(
      parent: _cameraController,
      curve: cam.curve,
    ));

    _cameraController.forward(from: 0.0);

    if (cam.preset == CameraPreset.epicBattleShake) {
      _shakeController.repeat(reverse: true);
    } else {
      _shakeController.stop();
    }
  }

  Alignment _getTargetAlignment(CameraPreset preset, Alignment defaultFocus) {
    switch (preset) {
      case CameraPreset.panLeftToRight:
        return const Alignment(0.35, 0.0);
      case CameraPreset.panRightToLeft:
        return const Alignment(-0.35, 0.0);
      case CameraPreset.slowZoomInFocus:
        return defaultFocus;
      case CameraPreset.dramaticPullBack:
      case CameraPreset.slowZoomInCenter:
      case CameraPreset.epicBattleShake:
      case CameraPreset.staticSteady:
        return Alignment.center;
    }
  }

  @override
  void didUpdateWidget(covariant CinematicStageViewport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.id != widget.scene.id) {
      _playSceneAnimations();
    }
    if (widget.isPaused && !oldWidget.isPaused) {
      _cameraController.stop();
    } else if (!widget.isPaused && oldWidget.isPaused) {
      _cameraController.forward();
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _skyDriftController.dispose();
    _birdsController.dispose();
    _actorBreathingController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: ClipRect(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _cameraController,
            _skyDriftController,
            _birdsController,
            _actorBreathingController,
            _shakeController,
          ]),
          builder: (context, _) {
            // Calcul de la secousse éventuelle
            double shakeOffsetX = 0.0;
            double shakeOffsetY = 0.0;
            if (_shakeController.isAnimating) {
              final val = _shakeController.value;
              shakeOffsetX = math.sin(val * math.pi * 8) * 3.5;
              shakeOffsetY = math.cos(val * math.pi * 6) * 2.0;
            }

            final currentScale = _scaleAnimation.value;
            final currentAlign = _alignmentAnimation.value;

            return Transform.translate(
              offset: Offset(shakeOffsetX, shakeOffsetY),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── PLAN 0 : CIEL & DÉRIVE ATMOSPHÉRIQUE ─────────────────────
                  _buildSkyLayer(isDark),

                  // ── PLAN 1 : DÉCOR PRINCIPAL AVEC CAMÉRA KEN BURNS ───────────
                  _buildDecorLayers(currentScale, currentAlign),

                  // ── PLAN 2 : PARTICULES & OISEAUX VIVANTS ────────────────────
                  _buildAtmosphereFxLayer(),

                  // ── PLAN 3 : ACTEURS & SILHOUETTES DE BATAILLE ───────────────
                  if (widget.scene.actor != null) _buildActorLayer(),
                  if (widget.scene.type == SceneType.conflictAction)
                    _buildBattleSilhouettesLayer(),

                  // ── PLAN 4 : VIGNETTAGE CINÉMA & CONTRASTE ───────────────────
                  _buildCinematicVignette(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkyLayer(bool isDark) {
    final hasDrift = widget.scene.layers.any(
      (l) => l.movement == LayerMovement.driftHorizontal,
    );

    if (!hasDrift) {
      return Container(
        color: isDark ? const Color(0xFF0D1117) : const Color(0xFF1E293B),
      );
    }

    final driftX = (_skyDriftController.value * 120.0) % 60.0;

    return Transform.translate(
      offset: Offset(-driftX, 0),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
        ),
        child: CustomPaint(
          painter: _ProceduralSkyPainter(
            driftProgress: _skyDriftController.value,
          ),
        ),
      ),
    );
  }

  Widget _buildDecorLayers(double scale, Alignment align) {
    final decorLayers = widget.scene.layers
        .where((l) => l.zIndex <= 1 && l.movement != LayerMovement.driftHorizontal)
        .toList();

    return Transform(
      alignment: align,
      transform: Matrix4.diagonal3Values(scale, scale, 1.0),
      child: Stack(
        fit: StackFit.expand,
        children: decorLayers.map((layer) {
          return Image.asset(
            layer.assetPath,
            fit: layer.fit,
            alignment: layer.alignment,
            opacity: AlwaysStoppedAnimation(layer.opacity),
            errorBuilder: (_, __, ___) => _buildFallbackAtmosphereDecor(layer),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFallbackAtmosphereDecor(StageLayer layer) {
    // Si l'image locale personnalisée est encore un chemin d'intention, génère un fond stylisé
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2B1B17),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: const Color(0xFFF1851F).withValues(alpha: 0.35),
              size: 54,
            ),
            const SizedBox(height: 8),
            Text(
              widget.scene.title.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFF1851F),
                fontSize: 12,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAtmosphereFxLayer() {
    final hasBirds = widget.scene.layers.any(
      (l) => l.movement == LayerMovement.birdsCrossing,
    );

    return CustomPaint(
      painter: _BirdsFlockAndDustPainter(
        birdsProgress: _birdsController.value,
        hasBirds: hasBirds,
        particlesProgress: _skyDriftController.value,
      ),
    );
  }

  Widget _buildActorLayer() {
    final actor = widget.scene.actor!;
    final breath = _actorBreathingController.value;
    final breathScale = 0.985 + (breath * 0.03);

    return Align(
      alignment: actor.position,
      child: Transform.scale(
        scale: breathScale,
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 280, maxWidth: 220),
          child: Image.asset(
            actor.assetPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _buildActorFallback(actor),
          ),
        ),
      ),
    );
  }

  Widget _buildActorFallback(ActorPresence actor) {
    return Container(
      width: 140,
      height: 180,
      decoration: BoxDecoration(
        color: actor.accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: actor.accentColor, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_rounded, size: 64, color: actor.accentColor),
          const SizedBox(height: 8),
          Text(
            actor.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: actor.accentColor,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattleSilhouettesLayer() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      height: 160,
      child: CustomPaint(
        painter: _BattleSilhouettesPainter(
          phase: _skyDriftController.value,
        ),
      ),
    );
  }

  Widget _buildCinematicVignette() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFF1851F).withValues(alpha: 0.12),
            width: 1.5,
          ),
          color: Colors.transparent,
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ── PAINTERS SPÉCIALISÉS 60 FPS
// ═════════════════════════════════════════════════════════════════════════════

class _ProceduralSkyPainter extends CustomPainter {
  final double driftProgress;

  _ProceduralSkyPainter({required this.driftProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF1851F).withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Bancs de brume sahélienne dérivants
    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.15 + (i * 0.18));
      final xOffset = (driftProgress * size.width * 0.4 + (i * 90)) % (size.width + 100) - 50;

      final path = Path()
        ..moveTo(xOffset, y)
        ..quadraticBezierTo(xOffset + 120, y - 25, xOffset + 240, y)
        ..quadraticBezierTo(xOffset + 360, y + 25, xOffset + 480, y)
        ..lineTo(xOffset + 480, y + 40)
        ..lineTo(xOffset, y + 40)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProceduralSkyPainter oldDelegate) =>
      oldDelegate.driftProgress != driftProgress;
}

class _BirdsFlockAndDustPainter extends CustomPainter {
  final double birdsProgress;
  final bool hasBirds;
  final double particlesProgress;

  _BirdsFlockAndDustPainter({
    required this.birdsProgress,
    required this.hasBirds,
    required this.particlesProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Particules de poussière d'or / harmattan
    final dustPaint = Paint()
      ..color = const Color(0xFFF1851F).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 18; i++) {
      final seed = i * 47.0;
      final x = (size.width * ((seed % 100) / 100.0) + (particlesProgress * 40)) % size.width;
      final y = (size.height * (((seed * 3) % 100) / 100.0) + math.sin(particlesProgress * math.pi * 2 + i) * 12) % size.height;
      final radius = 1.2 + ((i % 3) * 0.8);
      canvas.drawCircle(Offset(x, y), radius, dustPaint);
    }

    // 2. Vol d'oiseaux migrateurs
    if (!hasBirds) return;

    final birdPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final startX = size.width + 60;
    final endX = -80.0;
    final flockX = startX + (endX - startX) * birdsProgress;
    final flockY = size.height * 0.22 + math.sin(birdsProgress * math.pi * 2) * 18;

    // 5 oiseaux en formation de flèche
    final offsets = [
      Offset(flockX, flockY),
      Offset(flockX + 22, flockY - 14),
      Offset(flockX + 26, flockY + 16),
      Offset(flockX + 44, flockY - 26),
      Offset(flockX + 48, flockY + 28),
    ];

    final wingWing = math.sin(birdsProgress * math.pi * 24) * 6.0;

    for (final pt in offsets) {
      if (pt.dx < -50 || pt.dx > size.width + 50) continue;
      final path = Path()
        ..moveTo(pt.dx - 8, pt.dy - wingWing)
        ..quadraticBezierTo(pt.dx - 4, pt.dy, pt.dx, pt.dy + 2)
        ..quadraticBezierTo(pt.dx + 4, pt.dy, pt.dx + 8, pt.dy - wingWing);
      canvas.drawPath(path, birdPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BirdsFlockAndDustPainter oldDelegate) => true;
}

class _BattleSilhouettesPainter extends CustomPainter {
  final double phase;

  _BattleSilhouettesPainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final silhouettePaint = Paint()
      ..color = const Color(0xFF0F0B08)
      ..style = PaintingStyle.fill;

    final spearPaint = Paint()
      ..color = const Color(0xFF0F0B08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    // Lances dressées avec léger balancement
    for (int i = 0; i < 9; i++) {
      final x = (size.width * 0.08) + (i * (size.width * 0.10));
      final sway = math.sin(phase * math.pi * 4 + i) * 4;
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + 12 + sway, size.height - 85 - (i % 3 * 18)),
        spearPaint,
      );
    }

    // Sol inégal de la plaine de Kirina
    final ground = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height - 45)
      ..quadraticBezierTo(size.width * 0.25, size.height - 65, size.width * 0.5, size.height - 40)
      ..quadraticBezierTo(size.width * 0.75, size.height - 55, size.width, size.height - 48)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(ground, silhouettePaint);
  }

  @override
  bool shouldRepaint(covariant _BattleSilhouettesPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
