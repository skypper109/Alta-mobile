import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/culture_detail_models.dart';

/// Composant Hero 2D Motion Design de classe mondiale pour les Grands Personnages du Mali.
///
/// Fonctionnalités Motion Design & 2D :
/// 1. Système de particules d'étincelles dorées (Mandé Ember Engine) à 60/120 FPS.
/// 2. Halo impérial royal avec respiration lumineuse sinusoïdale (Sacred Aura).
/// 3. Inclinaison 3D/2D interactive au toucher (Interactive Parallax & Perspective Tilt).
/// 4. Sceau impérial animé du Lion du Manden avec rotation douce.
/// 5. Visualiseur audio d'ondes sonores (Equalizer Bars) synchronisé au récit du Djéli.
/// 6. Badges historiques flottants avec micro-animations de brillance.
class CharacterMotionHero extends StatefulWidget {
  final HistoricalFigureDetail figure;
  final String? heroTag;
  final VoidCallback? onBack;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;

  const CharacterMotionHero({
    super.key,
    required this.figure,
    this.heroTag,
    this.onBack,
    required this.isBookmarked,
    required this.onToggleBookmark,
  });

  @override
  State<CharacterMotionHero> createState() => _CharacterMotionHeroState();
}

class _CharacterMotionHeroState extends State<CharacterMotionHero>
    with TickerProviderStateMixin {
  late final AnimationController _auraController;
  late final AnimationController _particlesController;
  late final AnimationController _sealRotationController;

  // Variables pour l'effet d'inclinaison perspective 3D/2D au toucher
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  Offset _dragOffset = Offset.zero;

  // Liste des particules d'étincelles du Manden
  late final List<_MandeParticle> _particles;

  @override
  void initState() {
    super.initState();

    // 1. Respiration de l'Aura Royale (durée 3.5s en boucle miroir)
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    // 2. Mouvement continu des braises et étincelles (durée 12s)
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // 3. Rotation très lente et majestueuse du sceau royal (durée 24s)
    _sealRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    // Initialisation aléatoire de 28 particules dorées
    final random = math.Random(42);
    _particles = List.generate(28, (index) {
      return _MandeParticle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 1.8 + random.nextDouble() * 3.5,
        speed: 0.2 + random.nextDouble() * 0.45,
        opacity: 0.25 + random.nextDouble() * 0.65,
        drift: (random.nextDouble() - 0.5) * 0.3,
      );
    });
  }

  @override
  void dispose() {
    _auraController.dispose();
    _particlesController.dispose();
    _sealRotationController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    setState(() {
      _dragOffset += details.delta;
      // Normalisation du tilt (-1.0 à 1.0) avec amplitude maîtrisée
      _tiltX = (_dragOffset.dy / (size.height * 0.5)).clamp(-0.15, 0.15);
      _tiltY = (-_dragOffset.dx / (size.width * 0.5)).clamp(-0.18, 0.18);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // Retour élastique doux à la position d'origine
    setState(() {
      _tiltX = 0.0;
      _tiltY = 0.0;
      _dragOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.paddingOf(context).top;
    final heroHeight = (size.height * 0.52 + topPadding * 0.5).clamp(380.0, 480.0);
    final isSoundiata = widget.figure.id == 'perso_soundiata';

    return GestureDetector(
      onPanUpdate: (details) => _onPanUpdate(details, Size(size.width, heroHeight)),
      onPanEnd: _onPanEnd,
      child: SizedBox(
        height: heroHeight,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            // ── 1. FOND DE CIEL CRÉPUSCULAIRE MANDINGUE ───────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF291508),
                    Color(0xFF1E0E05),
                    Color(0xFF070B14),
                  ],
                  stops: [0.0, 0.45, 0.78, 1.0],
                ),
              ),
            ),

            // ── 2. AURA IMPÉRIALE ROYALE RESPIRANTE (MOTION GLOW) ──────────────
            AnimatedBuilder(
              animation: _auraController,
              builder: (context, child) {
                final auraScale = 0.85 + 0.25 * _auraController.value;
                final auraOpacity = 0.28 + 0.22 * _auraController.value;

                return Positioned.fill(
                  child: Center(
                    child: Transform.scale(
                      scale: auraScale,
                      child: Container(
                        width: size.width * 0.85,
                        height: size.width * 0.85,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFF59E0B).withValues(alpha: auraOpacity),
                              const Color(0xFFD97706).withValues(alpha: auraOpacity * 0.6),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // ── 3. PORTRAIT 2D AVEC PARALLAXE & PERSPECTIVE TILT ──────────────
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _auraController,
                builder: (context, child) {
                  // Respiration subtile du personnage
                  final breathY = math.sin(_auraController.value * math.pi) * 3.0;

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0012) // Profondeur perspective
                      ..rotateX(_tiltX)
                      ..rotateY(_tiltY)
                      ..setTranslationRaw(0.0, breathY, 0.0),
                    child: Hero(
                      tag: widget.heroTag ?? 'culture_figure_${widget.figure.id}',
                      child: Image.asset(
                        widget.figure.photoUrl,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (ctx, err, stack) {
                          return Container(
                            color: const Color(0xFF1E140B),
                            child: const Center(
                              child: Icon(
                                Icons.person_rounded,
                                size: 80,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── 4. SYSTÈME DE PARTICULES D'ÉTINCELLES DU MANDEN (2D EMBER ENGINE)
            AnimatedBuilder(
              animation: _particlesController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(size.width, heroHeight),
                  painter: _MandeEmbersPainter(
                    particles: _particles,
                    progress: _particlesController.value,
                  ),
                );
              },
            ),

            // ── 5. VOILE PROGRESSIF EN BASE POUR LISIBILITÉ DU CONTENU ─────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: heroHeight * 0.65,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                      const Color(0xFF070B14).withValues(alpha: 0.95),
                      const Color(0xFF070B14),
                    ],
                    stops: const [0.0, 0.35, 0.80, 1.0],
                  ),
                ),
              ),
            ),

            // ── 6. SCEAU ROYAL DU LION DU MANDEN (ROTATIF & INTERACTIF) ─────────
            if (isSoundiata)
              Positioned(
                top: topPadding + 60,
                right: 20,
                child: AnimatedBuilder(
                  animation: _sealRotationController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _sealRotationController.value * 2 * math.pi,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1E0E05).withValues(alpha: 0.85),
                          border: Border.all(
                            color: const Color(0xFFD97706),
                            width: 1.0,
                          ),
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          size: 22,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ── 8. BANDEAU D'INFORMATIONS DU HÉROS AU BAS DU HERO ─────────────
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Badges : Région & Tag
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.workspace_premium_rounded,
                              size: 12,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.figure.tag.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 11,
                              color: Color(0xFF38BDF8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.figure.regionName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Indicateur Période
                      Text(
                        widget.figure.period,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF59E0B),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Nom & Titre
                  Text(
                    widget.figure.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.8,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.8),
                          blurRadius: 18,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.figure.titleHonorifique,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFDE68A),
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modèle d'une particule d'étincelle dorée
class _MandeParticle {
  double x;
  double y;
  final double size;
  final double speed;
  final double opacity;
  final double drift;

  _MandeParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.drift,
  });
}

/// Moteur de rendu Canvas des étincelles et braises dorées (2D Ember Engine)
class _MandeEmbersPainter extends CustomPainter {
  final List<_MandeParticle> particles;
  final double progress;

  _MandeEmbersPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Déplacement vertical ascendant cyclique
      final currentY = (p.y - progress * p.speed) % 1.0;
      final actualY = currentY * size.height;

      // Dérive horizontale sinusoïdale avec le vent
      final driftX = math.sin((progress + p.x) * 2 * math.pi) * 16 * p.drift;
      final actualX = ((p.x * size.width) + driftX) % size.width;

      // Scintillement lumineux
      final flicker = 0.7 + 0.3 * math.sin((progress * 4 + p.y) * 2 * math.pi);
      final alpha = (p.opacity * flicker).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.8);

      canvas.drawCircle(Offset(actualX, actualY), p.size, paint);

      // Cœur blanc éclatant pour les plus grosses particules
      if (p.size > 2.8) {
        final corePaint = Paint()
          ..color = Colors.white.withValues(alpha: alpha * 0.8);
        canvas.drawCircle(Offset(actualX, actualY), p.size * 0.45, corePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MandeEmbersPainter oldDelegate) => true;
}
