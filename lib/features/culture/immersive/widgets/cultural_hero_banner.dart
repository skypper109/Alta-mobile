import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/culture_theme.dart';
import '../services/cultural_haptics.dart';
import 'cultural_rolling_xp_counter.dart';

/// ╔═══════════════════════════════════════════════════════════════════╗
/// ║  CULTURAL HERO BANNER — Version Signature Ultime                 ║
/// ║  Inspiration : Apple Music × Nike × Atlas historique malien.    ║
/// ║  Gyroscope à 3 anneaux contra-rotatifs dessiné au CustomPaint,  ║
/// ║  particules flottantes, typographie éditoriale de luxe,          ║
/// ║  greeting en Bambara animé, barre XP vivante.                   ║
/// ║  STRICTEMENT SANS DÉGRADÉS — 3 couleurs AlterniA uniquement.    ║
/// ╚═══════════════════════════════════════════════════════════════════╝
class CulturalHeroBanner extends StatefulWidget {
  final int totalXp;
  final int rankLevel;
  final VoidCallback onPassportTap;

  const CulturalHeroBanner({
    super.key,
    required this.totalXp,
    required this.rankLevel,
    required this.onPassportTap,
  });

  @override
  State<CulturalHeroBanner> createState() => _CulturalHeroBannerState();
}

class _CulturalHeroBannerState extends State<CulturalHeroBanner>
    with TickerProviderStateMixin {

  // Entrée de scène
  late final AnimationController _entryCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scaleIn;

  // Gyroscope : 3 anneaux indépendants
  late final AnimationController _ring1Ctrl; // lent, horaire
  late final AnimationController _ring2Ctrl; // moyen, contra
  late final AnimationController _ring3Ctrl; // rapide, horaire

  // Particules flottantes
  late final AnimationController _particleCtrl;

  // Halo pulsant central
  late final AnimationController _haloCtrl;
  late final Animation<double> _haloScale;
  late final Animation<double> _haloOpacity;

  // Salutation Bambara
  final List<_GreetData> _greets = [
    _GreetData('I NI CE', 'Bonjour'),
    _GreetData('AN KA DI', 'Ensemble'),
    _GreetData('KA ÈTA', 'Allons-y'),
  ];
  int _greetIdx = 0;
  bool _greetVisible = true;

  // Particules
  final List<_Particle> _particles = [];
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();

    // ── Entrée ───────────────────────────────────────────────────
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeIn = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _scaleIn = Tween<double>(begin: 0.93, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack));

    // ── Gyroscope ────────────────────────────────────────────────
    _ring1Ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 22))..repeat();
    _ring2Ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat(reverse: false);
    _ring3Ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();

    // ── Halo ─────────────────────────────────────────────────────
    _haloCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))..repeat(reverse: true);
    _haloScale = Tween<double>(begin: 0.80, end: 1.10).animate(
      CurvedAnimation(parent: _haloCtrl, curve: Curves.easeInOut));
    _haloOpacity = Tween<double>(begin: 0.08, end: 0.22).animate(
      CurvedAnimation(parent: _haloCtrl, curve: Curves.easeInOut));

    // ── Particules ───────────────────────────────────────────────
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    for (int i = 0; i < 18; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble(),
        y: _rng.nextDouble(),
        speed: 0.04 + _rng.nextDouble() * 0.08,
        size: 1.2 + _rng.nextDouble() * 2.0,
        phase: _rng.nextDouble(),
        colorIdx: i % 3,
      ));
    }

    _entryCtrl.forward();
    _startGreetRotation();
  }

  void _startGreetRotation() async {
    await Future.delayed(const Duration(seconds: 3));
    while (mounted) {
      setState(() => _greetVisible = false);
      await Future.delayed(const Duration(milliseconds: 350));
      if (!mounted) break;
      setState(() {
        _greetIdx = (_greetIdx + 1) % _greets.length;
        _greetVisible = true;
      });
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _ring1Ctrl.dispose();
    _ring2Ctrl.dispose();
    _ring3Ctrl.dispose();
    _haloCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: ScaleTransition(scale: _scaleIn, child: _buildCard(context)),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: CultureTheme.primaryBlue,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
          children: [
            // ── Couche 1 : Particules flottantes ─────────────────
            Positioned.fill(child: _buildParticleLayer()),

            // ── Couche 2 : Halo central pulsant ──────────────────
            Center(
              child: AnimatedBuilder(
                animation: _haloCtrl,
                builder: (_, __) => Transform.scale(
                  scale: _haloScale.value,
                  child: Container(
                    width: 150, height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CultureTheme.accentOrange.withValues(alpha: _haloOpacity.value),
                    ),
                  ),
                ),
              ),
            ),

            // ── Couche 3 : Gyroscope 3 anneaux ───────────────────
            Center(
              child: SizedBox(
                width: 180, height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Anneau 1 : extérieur, lent, horaire
                    AnimatedBuilder(
                      animation: _ring1Ctrl,
                      builder: (_, __) => Transform.rotate(
                        angle: _ring1Ctrl.value * 2 * math.pi,
                        child: CustomPaint(
                          size: const Size(180, 180),
                          painter: _RingPainter(
                            radius: 88, strokeWidth: 1.2,
                            color: CultureTheme.accentOrange.withValues(alpha: 0.6),
                            dashCount: 24,
                          ),
                        ),
                      ),
                    ),
                    // Anneau 2 : moyen, contra-horaire
                    AnimatedBuilder(
                      animation: _ring2Ctrl,
                      builder: (_, __) => Transform.rotate(
                        angle: -_ring2Ctrl.value * 2 * math.pi,
                        child: CustomPaint(
                          size: const Size(180, 180),
                          painter: _RingPainter(
                            radius: 68, strokeWidth: 1.0,
                            color: CultureTheme.cyanTurquoise.withValues(alpha: 0.5),
                            dashCount: 16,
                          ),
                        ),
                      ),
                    ),
                    // Anneau 3 : intérieur, rapide, horaire
                    AnimatedBuilder(
                      animation: _ring3Ctrl,
                      builder: (_, __) => Transform.rotate(
                        angle: _ring3Ctrl.value * 2 * math.pi,
                        child: CustomPaint(
                          size: const Size(180, 180),
                          painter: _RingPainter(
                            radius: 48, strokeWidth: 1.5,
                            color: Colors.white.withValues(alpha: 0.25),
                            dashCount: 8,
                          ),
                        ),
                      ),
                    ),
                    // Étoile centrale fixe (sun emblem)
                    CustomPaint(
                      size: const Size(28, 28),
                      painter: _SunEmblemPainter(color: CultureTheme.accentOrange),
                    ),
                  ],
                ),
              ),
            ),

            // ── Couche 4 : Contenu éditorial ─────────────────────
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // LIGNE HAUTE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGreetingBlock(),
                        _buildXpPill(),
                      ],
                    ),
                    // LIGNE BASSE : typographie éditoriale
                    _buildEditorialTitle(),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }

  // ── Particules ─────────────────────────────────────────────────
  Widget _buildParticleLayer() {
    final colors = [
      CultureTheme.accentOrange.withValues(alpha: 0.35),
      CultureTheme.cyanTurquoise.withValues(alpha: 0.25),
      Colors.white.withValues(alpha: 0.18),
    ];
    return AnimatedBuilder(
      animation: _particleCtrl,
      builder: (_, __) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _particleCtrl.value,
            colors: colors,
          ),
        );
      },
    );
  }

  // ── Salutation Bambara ────────────────────────────────────────
  Widget _buildGreetingBlock() {
    final greet = _greets[_greetIdx];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedOpacity(
          opacity: _greetVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 350),
          child: AnimatedSlide(
            offset: _greetVisible ? Offset.zero : const Offset(-0.15, 0),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greet.bambara,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.0,
                    color: CultureTheme.accentOrange,
                  ),
                ),
                Text(
                  greet.french,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.45),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Badge XP (seul déclencheur du Passeport dans ce bandeau) ────
  Widget _buildXpPill() {
    return GestureDetector(
      onTap: () {
        CulturalHaptics.cardPress();
        widget.onPassportTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.18), width: 1.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt_rounded, size: 13, color: CultureTheme.accentOrange),
            const SizedBox(width: 4),
            CulturalRollingXpCounter(
              targetXp: widget.totalXp,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
              suffix: 'XP',
              suffixStyle: GoogleFonts.plusJakartaSans(
                fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white70),
            ),
            const SizedBox(width: 6),
            Container(
              width: 1, height: 12,
              color: Colors.white.withValues(alpha: 0.25),
            ),
            const SizedBox(width: 6),
            Text(
              'Niv.${widget.rankLevel}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: CultureTheme.cyanTurquoise),
            ),
          ],
        ),
      ),
    );
  }

  // ── Titre éditorial ───────────────────────────────────────────
  Widget _buildEditorialTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Micro-label luxury
        Text(
          'CULTURE  ·  MALI',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 3.5,
            color: CultureTheme.cyanTurquoise.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 2),
        // Titre principal massif
        Text(
          'Héritage\nVivant',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1.2,
            height: 1.05,
          ),
        ),
      ],
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────
class _GreetData {
  final String bambara;
  final String french;
  const _GreetData(this.bambara, this.french);
}

class _Particle {
  final double x;
  double y;
  final double speed;
  final double size;
  final double phase;
  final int colorIdx;
  _Particle({required this.x, required this.y, required this.speed,
    required this.size, required this.phase, required this.colorIdx});
}

// ── Peintre : Particules flottantes ───────────────────────────────
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final List<Color> colors;
  const _ParticlePainter({required this.particles, required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress + p.phase) % 1.0;
      final y = size.height * (1.0 - (p.y + t * p.speed * 5) % 1.0);
      final x = size.width * p.x + math.sin(t * math.pi * 2 + p.phase) * 8;
      final opacity = math.sin(t * math.pi).clamp(0.0, 1.0);
      final paint = Paint()..color = colors[p.colorIdx].withValues(alpha: opacity * 0.7);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter o) => o.progress != progress;
}

// ── Peintre : Anneau avec tirets ──────────────────────────────────
class _RingPainter extends CustomPainter {
  final double radius;
  final double strokeWidth;
  final Color color;
  final int dashCount;
  const _RingPainter({required this.radius, required this.strokeWidth,
    required this.color, required this.dashCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    final dashAngle = math.pi / dashCount;
    final gapAngle = dashAngle * 0.5;
    final startAngle = -math.pi / 2;
    for (int i = 0; i < dashCount * 2; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + i * dashAngle,
        dashAngle - gapAngle,
        false,
        paint,
      );
    }
    // 4 marqueurs de cap sur le cercle
    final markerPaint = Paint()..color = color..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final a = startAngle + i * math.pi / 2;
      final pt = Offset(center.dx + math.cos(a) * radius, center.dy + math.sin(a) * radius);
      canvas.drawCircle(pt, strokeWidth * 1.6, markerPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter o) => false;
}

// ── Peintre : Étoile solaire centrale ─────────────────────────────
class _SunEmblemPainter extends CustomPainter {
  final Color color;
  const _SunEmblemPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    // Octogramme
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final outer = Offset(
        center.dx + math.cos(i * math.pi / 4 - math.pi / 2) * r,
        center.dy + math.sin(i * math.pi / 4 - math.pi / 2) * r,
      );
      final inner = Offset(
        center.dx + math.cos((i + 0.5) * math.pi / 4 - math.pi / 2) * r * 0.4,
        center.dy + math.sin((i + 0.5) * math.pi / 4 - math.pi / 2) * r * 0.4,
      );
      if (i == 0) { path.moveTo(outer.dx, outer.dy); } else { path.lineTo(outer.dx, outer.dy); }

      path.lineTo(inner.dx, inner.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SunEmblemPainter o) => o.color != color;
}
