import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/culture_detail_models.dart';

/// 🏛️ COMPOSANT HERO CINÉMATIQUE 2.5D DE CLASSE MONDIALE
/// Vrai Motion Design Multi-Plans (SANS particules de poussière d'or basiques) :
/// 1. Plan 0 : Ciel Crépusculaire Profond avec Soleil Impérial Radieux & Volumetric Sunbeams.
/// 2. Plan 1 : Collines Mandingues & Relief d'Arrière-Plan en Parallaxe Lente (0.3x).
/// 3. Plan 2 : Anneaux Orbitaux Impériaux 3D en Rotation Gyroscopique Multiaxes.
/// 4. Plan 3 : Portrait Héroïque Découpé en Perspective 3D (0.0016) avec Translation Z & Reflet Spéculaire Dynamique.
/// 5. Plan 4 : Avant-Plan Cinématique (Bannières Royales & Lances en Parallaxe Rapide 1.4x).
/// 6. Caméra Interactive au Toucher avec Ressort Élastique Amorti & Respiration Continue.
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
  // Contrôleurs cinématiques
  late final AnimationController _idleBreathController;
  late final AnimationController _gyroRingsController;
  late final AnimationController _sunbeamController;
  late final AnimationController _springBackController;

  // Variables pour la caméra interactive 3D
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  double _fromTiltX = 0.0;
  double _fromTiltY = 0.0;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();

    // 1. Respiration lente de la scène (durée 4.5s)
    _idleBreathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat(reverse: true);

    // 2. Rotation 3D gyroscopique des anneaux d'or du Manden (durée 16s)
    _gyroRingsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    // 3. Balayage volumétrique de la lumière solaire (durée 8s)
    _sunbeamController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // 4. Ressort physique d'amorti quand l'utilisateur relâche le toucher
    _springBackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _springBackController.addListener(() {
      final t = Curves.easeOutBack.transform(_springBackController.value);
      setState(() {
        _tiltX = _fromTiltX * (1.0 - t);
        _tiltY = _fromTiltY * (1.0 - t);
      });
    });
  }

  @override
  void dispose() {
    _idleBreathController.dispose();
    _gyroRingsController.dispose();
    _sunbeamController.dispose();
    _springBackController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    _springBackController.stop();
    setState(() {
      _dragOffset += details.delta;
      _tiltX = (_dragOffset.dy / (size.height * 0.45)).clamp(-0.20, 0.20);
      _tiltY = (-_dragOffset.dx / (size.width * 0.45)).clamp(-0.24, 0.24);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _fromTiltX = _tiltX;
    _fromTiltY = _tiltY;
    _dragOffset = Offset.zero;
    _springBackController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.paddingOf(context).top;
    final heroHeight =
        (size.height * 0.54 + topPadding * 0.5).clamp(410.0, 520.0);

    return GestureDetector(
      onPanUpdate: (details) =>
          _onPanUpdate(details, Size(size.width, heroHeight)),
      onPanEnd: _onPanEnd,
      child: SizedBox(
        height: heroHeight,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _idleBreathController,
            _gyroRingsController,
            _sunbeamController,
          ]),
          builder: (context, _) {
            // Mouvement de caméra ambiant continu (idle floating)
            final idleBreath = math.sin(_idleBreathController.value * math.pi);
            final currentTiltX = _tiltX + (idleBreath * 0.015);
            final currentTiltY =
                _tiltY + (math.cos(_idleBreathController.value * math.pi) * 0.015);

            return Stack(
              fit: StackFit.expand,
              clipBehavior: Clip.none,
              children: [
                // ── PLAN 0 : FOND DU CIEL CRÉPUSCULAIRE MANDINGUE ───────────
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF070B14),
                          Color(0xFF1B0F07),
                          Color(0xFF2E1508),
                          Color(0xFF0F0804),
                          Color(0xFF070B14),
                        ],
                        stops: [0.0, 0.25, 0.55, 0.85, 1.0],
                      ),
                    ),
                  ),
                ),

                // ── PLAN 0 BIS : RAYONS SOLAIRES VOLUMÉTRIQUES (GOD RAYS) ───
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(currentTiltY * 20, -currentTiltX * 15),
                    child: CustomPaint(
                      painter: _VolumetricSunbeamsPainter(
                        progress: _sunbeamController.value,
                        sunCenter: Offset(size.width * 0.5, heroHeight * 0.32),
                      ),
                    ),
                  ),
                ),

                // ── PLAN 1 : SOLEIL D'OR & ANNEAUX ORBITAUX 3D (GYROSCOPE) ──
                Positioned(
                  top: heroHeight * 0.08,
                  left: 0,
                  right: 0,
                  height: heroHeight * 0.55,
                  child: Transform.translate(
                    offset: Offset(currentTiltY * 28, -currentTiltX * 22),
                    child: Center(
                      child: SizedBox(
                        width: size.width * 0.80,
                        height: size.width * 0.80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Halo solaire incandescent
                            Container(
                              width: size.width * 0.65,
                              height: size.width * 0.65,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFF59E0B)
                                        .withValues(alpha: 0.35 + idleBreath * 0.12),
                                    const Color(0xFFD97706)
                                        .withValues(alpha: 0.18),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.45, 1.0],
                                ),
                              ),
                            ),

                            // Anneau 1 : Rotation 3D sur l'axe Y
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.002)
                                ..rotateX(0.55)
                                ..rotateY(_gyroRingsController.value * 2 * math.pi),
                              child: Container(
                                width: size.width * 0.72,
                                height: size.width * 0.72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFF59E0B)
                                        .withValues(alpha: 0.35),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),

                            // Anneau 2 : Rotation 3D inversée sur l'axe X
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.002)
                                ..rotateX(-_gyroRingsController.value * 2 * math.pi)
                                ..rotateY(-0.45),
                              child: Container(
                                width: size.width * 0.58,
                                height: size.width * 0.58,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFDE68A)
                                        .withValues(alpha: 0.25),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── PLAN 2 : RELIEF LÉGENDAIRE DU MANDEN (COLLINES & SAVANE) ─
                Positioned(
                  bottom: heroHeight * 0.22,
                  left: -20,
                  right: -20,
                  height: heroHeight * 0.35,
                  child: Transform.translate(
                    offset: Offset(currentTiltY * 40, -currentTiltX * 18),
                    child: CustomPaint(
                      painter: _MandeHillsSilhouettePainter(),
                    ),
                  ),
                ),

                // ── PLAN 3 : LE HÉROS SOUNDIATA (RELIEF 2.5D & CAMÉRA 3D) ────
                Positioned.fill(
                  child: Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0016) // Profondeur 3D puissante
                        ..rotateX(currentTiltX)
                        ..rotateY(currentTiltY)
                        ..setTranslationRaw(
                          currentTiltY * 35.0,
                          -currentTiltX * 30.0 + (idleBreath * 4.0),
                          25.0, // Sort de l'écran en relief
                        ),
                      child: Container(
                        margin: EdgeInsets.only(
                          top: topPadding + 28,
                          bottom: heroHeight * 0.14,
                        ),
                        width: size.width * 0.72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            // Ombre portée 3D volumétrique qui bouge avec la lumière
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.65),
                              blurRadius: 36,
                              offset: Offset(
                                -currentTiltY * 35,
                                18 - currentTiltX * 20,
                              ),
                            ),
                            // Halo d'or (Rim Light impérial)
                            BoxShadow(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.35),
                              blurRadius: 28,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image du héros
                            Hero(
                              tag: widget.heroTag ??
                                  'culture_figure_${widget.figure.id}',
                              child: Image.asset(
                                widget.figure.photoUrl,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF1E140B),
                                  child: const Center(
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: 80,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Bordure dorée impériale
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.75),
                                  width: 1.8,
                                ),
                              ),
                            ),

                            // Éclat spéculaire dynamique balayant l'armure selon l'angle
                            Positioned.fill(
                              child: Transform.translate(
                                offset: Offset(
                                  (currentTiltY * 320),
                                  (currentTiltX * 180),
                                ),
                                child: Transform.rotate(
                                  angle: 0.55,
                                  child: Container(
                                    width: size.width * 0.35,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withValues(alpha: 0.0),
                                          Colors.white.withValues(alpha: 0.30),
                                          Colors.white.withValues(alpha: 0.0),
                                        ],
                                        stops: const [0.0, 0.5, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── PLAN 4 : AVANT-PLAN CINÉMATIQUE (BANNIÈRES & LANCES) ─────
                // Déplacement plus rapide que le héros (1.4x) pour profondeur stéréoscopique
                Positioned.fill(
                  child: IgnorePointer(
                    child: Transform.translate(
                      offset: Offset(currentTiltY * 75, -currentTiltX * 45),
                      child: CustomPaint(
                        painter: _CinematicForegroundBannersPainter(
                          windProgress: _idleBreathController.value,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── PLAN 5 : DÉGRADÉ INFÉRIEUR CINÉMATIQUE POUR LE TEXTE ─────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: heroHeight * 0.55,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF070B14).withValues(alpha: 0.65),
                          const Color(0xFF070B14).withValues(alpha: 0.95),
                          const Color(0xFF070B14),
                        ],
                        stops: const [0.0, 0.35, 0.75, 1.0],
                      ),
                    ),
                  ),
                ),



                // ── PLAN 6 : TITRE, TAGS & ÉDITORIAL DU HÉROS ────────────────
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badges Région & Rôle
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.45),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.shield_rounded,
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
                              horizontal: 9,
                              vertical: 4.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
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
                          Text(
                            widget.figure.period,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF59E0B),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Grand Nom Héroïque
                      Text(
                        widget.figure.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.8,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.9),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Titre Honorifique (ex: Bâtisseur de l'Empire du Mali)
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
            );
          },
        ),
      ),
    );
  }


}

/// Peintre de rayons lumineux volumétriques (God Rays)
class _VolumetricSunbeamsPainter extends CustomPainter {
  final double progress;
  final Offset sunCenter;

  _VolumetricSunbeamsPainter({
    required this.progress,
    required this.sunCenter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rayPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);

    const rayCount = 7;
    for (int i = 0; i < rayCount; i++) {
      final baseAngle = (i * (math.pi / (rayCount - 1))) - (math.pi * 0.1);
      final wave = math.sin((progress * 2 * math.pi) + (i * 0.9));
      final opacity = (0.04 + (0.03 * wave)).clamp(0.01, 0.08);

      rayPaint.color = const Color(0xFFF59E0B).withValues(alpha: opacity);

      final path = Path()
        ..moveTo(sunCenter.dx, sunCenter.dy)
        ..lineTo(
          sunCenter.dx + math.cos(baseAngle - 0.12) * size.height * 1.2,
          sunCenter.dy + math.sin(baseAngle - 0.12) * size.height * 1.2,
        )
        ..lineTo(
          sunCenter.dx + math.cos(baseAngle + 0.12) * size.height * 1.2,
          sunCenter.dy + math.sin(baseAngle + 0.12) * size.height * 1.2,
        )
        ..close();

      canvas.drawPath(path, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VolumetricSunbeamsPainter oldDelegate) => true;
}

/// Peintre de silhouette des collines légendaires du Manden
class _MandeHillsSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final hillPaintBack = Paint()
      ..color = const Color(0xFF1B0E05).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final hillPaintFront = Paint()
      ..color = const Color(0xFF0F0804).withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    // Colline arrière
    final pathBack = Path()
      ..moveTo(0, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.35,
        size.width * 0.55,
        size.height * 0.60,
      )
      ..quadraticBezierTo(
        size.width * 0.80,
        size.height * 0.75,
        size.width,
        size.height * 0.45,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // Colline avant
    final pathFront = Path()
      ..moveTo(0, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.55,
        size.width * 0.70,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.88,
        size.height * 0.88,
        size.width,
        size.height * 0.70,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(pathBack, hillPaintBack);
    canvas.drawPath(pathFront, hillPaintFront);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Peintre d'avant-plan cinématique (Bannières et lances impériales en flou de bokeh)
class _CinematicForegroundBannersPainter extends CustomPainter {
  final double windProgress;

  _CinematicForegroundBannersPainter({required this.windProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final bannerPaint = Paint()
      ..color = const Color(0xFF881337).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final goldTrimPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final wave = math.sin(windProgress * math.pi) * 8.0;

    // Bannière gauche flottant au vent
    final bannerPath = Path()
      ..moveTo(-15, 0)
      ..quadraticBezierTo(
        size.width * 0.08 + wave,
        size.height * 0.25,
        size.width * 0.05 - wave,
        size.height * 0.55,
      )
      ..lineTo(-15, size.height * 0.55)
      ..close();

    canvas.drawPath(bannerPath, bannerPaint);
    canvas.drawPath(bannerPath, goldTrimPaint);
  }

  @override
  bool shouldRepaint(covariant _CinematicForegroundBannersPainter oldDelegate) =>
      true;
}
