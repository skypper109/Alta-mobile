import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/culture_detail_models.dart';

/// 🏛️ COMPOSANT HERO CINÉMATIQUE 2.5D MULTI-FIGURES DE CLASSE MONDIALE
/// Vrai Motion Design Multi-Plans adapté à CHAQUE grand personnage historique :
/// 1. Plan 0 : Ciel Atmosphérique Thématique (Crépuscule Mandé, Nuit Saharienne, Orage du Kénédougou, Nil Occidental, etc.).
/// 2. Plan 0 Bis : Faisceaux Solaires Célestes (God Rays) calibrés à l'aura du personnage.
/// 3. Plan 1 : Anneaux Orbitaux Impériaux 3D / Sphère Armillaire en Rotation Gyroscopique Multiaxes.
/// 4. Plan 2 : Silhouette Géographique & Monumentale Historique du Terroir (Tata de Sikasso, Tombeau des Askia, Balanzans, Djingareyber, Collines du Manden, Monument Indépendance).
/// 5. Plan 3 : Portrait Héroïque 2.5D en Relief (Translation Z, Ombre Portée Dynamique & Reflet Spéculaire Traversant).
/// 6. Plan 4 : Avant-Plan Cinématique Rapide (Bannières Mandingues, Parchemins de Sankoré, Étendards du Kénédougou, Voiles Songhoï, Rameaux de Balanzan, Rubans Tricolores).
/// 7. Caméra Tactile Interactive 3D avec Amorti Élastique (Spring Physics) & Respiration Idle.
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

    // 2. Rotation 3D gyroscopique des anneaux d'or impériaux (durée 16s)
    _gyroRingsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    // 3. Balayage volumétrique de la lumière céleste (durée 8s)
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

    final config = _FigureHeroVisualConfig.forFigure(widget.figure.id);

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
                // ── PLAN 0 : FOND DU CIEL ATMOSPHÉRIQUE DU PERSONNAGE ─────────
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: config.skyGradientColors,
                        stops: config.skyGradientStops,
                      ),
                    ),
                  ),
                ),

                // ── PLAN 0 BIS : RAYONS VOLUMÉTRIQUES CÉLESTES (GOD RAYS) ─────
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(currentTiltY * 20, -currentTiltX * 15),
                    child: CustomPaint(
                      painter: _VolumetricSunbeamsPainter(
                        progress: _sunbeamController.value,
                        sunCenter: Offset(size.width * 0.5, heroHeight * 0.32),
                        beamColor: config.primaryAccent,
                      ),
                    ),
                  ),
                ),

                // ── PLAN 1 : HALO D'OR & ANNEAUX ORBITAUX 3D (GYROSCOPE) ──────
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
                            // Halo incandescent
                            Container(
                              width: size.width * 0.65,
                              height: size.width * 0.65,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    config.haloGlow
                                        .withValues(alpha: 0.35 + idleBreath * 0.12),
                                    config.secondaryAccent
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
                                    color: config.primaryAccent
                                        .withValues(alpha: 0.38),
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
                                    color: config.secondaryAccent
                                        .withValues(alpha: 0.28),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            ),

                            // Anneau 3 spécial : Sphère Armillaire pour Mansa Moussa
                            if (config.heroArchetype == 'tombouctou')
                              Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.002)
                                  ..rotateZ(_gyroRingsController.value * 2 * math.pi)
                                  ..rotateX(1.1),
                                child: Container(
                                  width: size.width * 0.65,
                                  height: size.width * 0.65,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF38BDF8)
                                          .withValues(alpha: 0.24),
                                      width: 1.0,
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

                // ── PLAN 2 : PAYSAGE HISTORIQUE & MONUMENTAL DU TERROIR ───────
                Positioned(
                  bottom: heroHeight * 0.22,
                  left: -20,
                  right: -20,
                  height: heroHeight * 0.35,
                  child: Transform.translate(
                    offset: Offset(currentTiltY * 40, -currentTiltX * 18),
                    child: CustomPaint(
                      painter: _HistoricalLandscapeSilhouettePainter(
                        archetype: config.heroArchetype,
                        primaryColor: config.primaryAccent,
                      ),
                    ),
                  ),
                ),

                // ── PLAN 3 : LE HÉROS HISTORIQUE (RELIEF 2.5D & CAMÉRA 3D) ────
                Positioned.fill(
                  child: Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0016) // Profondeur 3D stéréoscopique
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
                            // Halo lumineux (Rim Light)
                            BoxShadow(
                              color: config.haloGlow.withValues(alpha: 0.36),
                              blurRadius: 28,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Image du héros historique
                            Hero(
                              tag: widget.heroTag ??
                                  'culture_figure_${widget.figure.id}',
                              child: Image.asset(
                                widget.figure.photoUrl,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF1E140B),
                                  child: Center(
                                    child: Icon(
                                      Icons.person_rounded,
                                      size: 80,
                                      color: config.primaryAccent,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Bordure dorée / auréolée de prestige
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: config.primaryAccent
                                      .withValues(alpha: 0.80),
                                  width: 1.8,
                                ),
                              ),
                            ),

                            // Éclat spéculaire dynamique balayant le portrait selon l'angle
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
                                          Colors.white.withValues(alpha: 0.32),
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

                // ── PLAN 4 : AVANT-PLAN CINÉMATIQUE (BANNIÈRES, ÉTOFFES, VOILES)
                // Parallaxe accélérée (1.4x) pour une stéréoscopie immersive
                Positioned.fill(
                  child: IgnorePointer(
                    child: Transform.translate(
                      offset: Offset(currentTiltY * 75, -currentTiltX * 45),
                      child: CustomPaint(
                        painter: _CinematicForegroundBannersPainter(
                          windProgress: _idleBreathController.value,
                          archetype: config.heroArchetype,
                          primaryColor: config.primaryAccent,
                          secondaryColor: config.secondaryAccent,
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
                          config.skyGradientColors.last
                              .withValues(alpha: 0.65),
                          config.skyGradientColors.last
                              .withValues(alpha: 0.95),
                          config.skyGradientColors.last,
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
                              color: config.primaryAccent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: config.primaryAccent
                                      .withValues(alpha: 0.45),
                                  blurRadius: 12,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  config.emblemIcon,
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
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Période de règne / vie
                          Text(
                            widget.figure.period,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Grand Nom du Héros
                      Text(
                        widget.figure.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 27,
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
                          color: config.primaryAccent.withValues(alpha: 0.92),
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

/// 🎨 Configuration visuelle et thématique de chaque grand personnage
class _FigureHeroVisualConfig {
  final List<Color> skyGradientColors;
  final List<double> skyGradientStops;
  final Color primaryAccent;
  final Color secondaryAccent;
  final Color haloGlow;
  final String heroArchetype; // 'manden', 'tombouctou', 'sikasso', 'gao', 'segou', 'bamako'
  final IconData emblemIcon;
  final String auraLabel;

  const _FigureHeroVisualConfig({
    required this.skyGradientColors,
    required this.skyGradientStops,
    required this.primaryAccent,
    required this.secondaryAccent,
    required this.haloGlow,
    required this.heroArchetype,
    required this.emblemIcon,
    required this.auraLabel,
  });

  static _FigureHeroVisualConfig forFigure(String id) {
    if (id.contains('soundiata')) {
      return const _FigureHeroVisualConfig(
        skyGradientColors: [
          Color(0xFF070B14),
          Color(0xFF1B0F07),
          Color(0xFF2E1508),
          Color(0xFF0F0804),
          Color(0xFF070B14),
        ],
        skyGradientStops: [0.0, 0.25, 0.55, 0.85, 1.0],
        primaryAccent: Color(0xFFF59E0B),
        secondaryAccent: Color(0xFFD97706),
        haloGlow: Color(0xFFF59E0B),
        heroArchetype: 'manden',
        emblemIcon: Icons.shield_rounded,
        auraLabel: 'LION DU MANDEN',
      );
    } else if (id.contains('mansa_moussa')) {
      return const _FigureHeroVisualConfig(
        skyGradientColors: [
          Color(0xFF030712),
          Color(0xFF0B172E),
          Color(0xFF172554),
          Color(0xFF0F172A),
          Color(0xFF030712),
        ],
        skyGradientStops: [0.0, 0.25, 0.55, 0.85, 1.0],
        primaryAccent: Color(0xFFFCD34D),
        secondaryAccent: Color(0xFF38BDF8),
        haloGlow: Color(0xFFFCD34D),
        heroArchetype: 'tombouctou',
        emblemIcon: Icons.auto_stories_rounded,
        auraLabel: 'SOUVERAIN D\'OR',
      );
    } else if (id.contains('babemba')) {
      return const _FigureHeroVisualConfig(
        skyGradientColors: [
          Color(0xFF0B0607),
          Color(0xFF2A0D11),
          Color(0xFF450A0A),
          Color(0xFF1C0A0D),
          Color(0xFF0B0607),
        ],
        skyGradientStops: [0.0, 0.25, 0.55, 0.85, 1.0],
        primaryAccent: Color(0xFFEF4444),
        secondaryAccent: Color(0xFFF59E0B),
        haloGlow: Color(0xFFEF4444),
        heroArchetype: 'sikasso',
        emblemIcon: Icons.castle_rounded,
        auraLabel: 'TATA DE SIKASSO',
      );
    } else if (id.contains('askia')) {
      return const _FigureHeroVisualConfig(
        skyGradientColors: [
          Color(0xFF020E0C),
          Color(0xFF062E27),
          Color(0xFF064E3B),
          Color(0xFF042F26),
          Color(0xFF020E0C),
        ],
        skyGradientStops: [0.0, 0.25, 0.55, 0.85, 1.0],
        primaryAccent: Color(0xFF10B981),
        secondaryAccent: Color(0xFFF59E0B),
        haloGlow: Color(0xFF10B981),
        heroArchetype: 'gao',
        emblemIcon: Icons.architecture_rounded,
        auraLabel: 'EMPIRE SONGHOÏ',
      );
    } else if (id.contains('biton')) {
      return const _FigureHeroVisualConfig(
        skyGradientColors: [
          Color(0xFF0D0803),
          Color(0xFF2E1B0A),
          Color(0xFF431407),
          Color(0xFF1E1107),
          Color(0xFF0D0803),
        ],
        skyGradientStops: [0.0, 0.25, 0.55, 0.85, 1.0],
        primaryAccent: Color(0xFFF97316),
        secondaryAccent: Color(0xFF84CC16),
        haloGlow: Color(0xFFF97316),
        heroArchetype: 'segou',
        emblemIcon: Icons.park_rounded,
        auraLabel: 'ROYAUME DE SÉGOU',
      );
    } else if (id.contains('modibo')) {
      return const _FigureHeroVisualConfig(
        skyGradientColors: [
          Color(0xFF030A14),
          Color(0xFF082038),
          Color(0xFF0C3B5E),
          Color(0xFF061A2E),
          Color(0xFF030A14),
        ],
        skyGradientStops: [0.0, 0.25, 0.55, 0.85, 1.0],
        primaryAccent: Color(0xFF38BDF8),
        secondaryAccent: Color(0xFF10B981),
        haloGlow: Color(0xFF38BDF8),
        heroArchetype: 'bamako',
        emblemIcon: Icons.flag_rounded,
        auraLabel: 'PÈRE DE LA NATION',
      );
    } else {
      return const _FigureHeroVisualConfig(
        skyGradientColors: [
          Color(0xFF070B14),
          Color(0xFF1B0F07),
          Color(0xFF2E1508),
          Color(0xFF0F0804),
          Color(0xFF070B14),
        ],
        skyGradientStops: [0.0, 0.25, 0.55, 0.85, 1.0],
        primaryAccent: Color(0xFFF59E0B),
        secondaryAccent: Color(0xFFD97706),
        haloGlow: Color(0xFFF59E0B),
        heroArchetype: 'manden',
        emblemIcon: Icons.shield_rounded,
        auraLabel: 'HÉROS DU MALI',
      );
    }
  }
}

/// Peintre de rayons lumineux volumétriques (God Rays)
class _VolumetricSunbeamsPainter extends CustomPainter {
  final double progress;
  final Offset sunCenter;
  final Color beamColor;

  _VolumetricSunbeamsPainter({
    required this.progress,
    required this.sunCenter,
    required this.beamColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const rayCount = 7;
    final rayPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < rayCount; i++) {
      final baseAngle = (i / rayCount) * math.pi + (progress * 0.15);
      final rayOpacity =
          (0.12 + 0.08 * math.sin(progress * 2 * math.pi + i)).clamp(0.04, 0.24);

      rayPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          beamColor.withValues(alpha: rayOpacity),
          beamColor.withValues(alpha: rayOpacity * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

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

/// Peintre de silhouettes géographiques et monumentales adaptées à chaque terroir
class _HistoricalLandscapeSilhouettePainter extends CustomPainter {
  final String archetype;
  final Color primaryColor;

  _HistoricalLandscapeSilhouettePainter({
    required this.archetype,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (archetype) {
      case 'tombouctou':
        _paintTombouctouDunesAndMinarets(canvas, size);
        break;
      case 'sikasso':
        _paintSikassoTataFortress(canvas, size);
        break;
      case 'gao':
        _paintGaoAskiaPyramidAndRiver(canvas, size);
        break;
      case 'segou':
        _paintSegouBalanzansAndRiver(canvas, size);
        break;
      case 'bamako':
        _paintBamakoIndependenceMonument(canvas, size);
        break;
      case 'manden':
      default:
        _paintMandeHillsAndBaobabs(canvas, size);
        break;
    }
  }

  // 1. Manden (Soundiata Keïta) : Collines du Manden & Baobabs
  void _paintMandeHillsAndBaobabs(Canvas canvas, Size size) {
    final backPaint = Paint()
      ..color = const Color(0xFF1B0E05).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final frontPaint = Paint()
      ..color = const Color(0xFF0F0804).withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    final pathBack = Path()
      ..moveTo(0, size.height * 0.65)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.35, size.width * 0.55, size.height * 0.60)
      ..quadraticBezierTo(size.width * 0.80, size.height * 0.75, size.width, size.height * 0.45)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final pathFront = Path()
      ..moveTo(0, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.55, size.width * 0.70, size.height * 0.78)
      ..quadraticBezierTo(size.width * 0.88, size.height * 0.88, size.width, size.height * 0.70)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(pathBack, backPaint);
    canvas.drawPath(pathFront, frontPaint);

    // Silhouette d'un grand baobab à gauche
    final baobabPaint = Paint()..color = const Color(0xFF0A0502);
    final trunk = Path()
      ..moveTo(size.width * 0.12, size.height)
      ..lineTo(size.width * 0.13, size.height * 0.58)
      ..lineTo(size.width * 0.17, size.height * 0.58)
      ..lineTo(size.width * 0.18, size.height)
      ..close();
    canvas.drawPath(trunk, baobabPaint);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.15, size.height * 0.52),
        width: size.width * 0.16,
        height: size.height * 0.22,
      ),
      baobabPaint,
    );
  }

  // 2. Tombouctou (Mansa Moussa) : Dunes du Sahara & Minarets de Djingareyber / Sankoré
  void _paintTombouctouDunesAndMinarets(Canvas canvas, Size size) {
    final dunePaintBack = Paint()
      ..color = const Color(0xFF131D38).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final dunePaintFront = Paint()
      ..color = const Color(0xFF091124).withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    // Dunes lointaines
    final dunesBack = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(size.width * 0.28, size.height * 0.48, size.width * 0.55, size.height * 0.65)
      ..quadraticBezierTo(size.width * 0.82, size.height * 0.42, size.width, size.height * 0.68)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final dunesFront = Path()
      ..moveTo(0, size.height * 0.88)
      ..quadraticBezierTo(size.width * 0.38, size.height * 0.62, size.width * 0.75, size.height * 0.82)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(dunesBack, dunePaintBack);
    canvas.drawPath(dunesFront, dunePaintFront);

    // Silhouette du minaret soudano-sahélien de Djingareyber à droite
    final minaretPaint = Paint()..color = const Color(0xFF060B18);
    final minaretPath = Path()
      ..moveTo(size.width * 0.82, size.height)
      ..lineTo(size.width * 0.84, size.height * 0.38)
      ..lineTo(size.width * 0.86, size.height * 0.38)
      ..lineTo(size.width * 0.88, size.height)
      ..close();
    canvas.drawPath(minaretPath, minaretPaint);

    // Flèche du sommet
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.85, size.height * 0.36),
        width: 10,
        height: 12,
      ),
      minaretPaint,
    );

    // Torons (branches de bois qui dépassent horizontalement)
    final toronPaint = Paint()
      ..color = const Color(0xFFFCD34D).withValues(alpha: 0.4)
      ..strokeWidth = 1.2;
    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.44 + i * 0.08);
      canvas.drawLine(
        Offset(size.width * 0.82 - 6, y),
        Offset(size.width * 0.88 + 6, y),
        toronPaint,
      );
    }
  }

  // 3. Sikasso (Babemba Traoré) : Murailles crénelées du Tata de Sikasso
  void _paintSikassoTataFortress(Canvas canvas, Size size) {
    final tataBack = Paint()
      ..color = const Color(0xFF22080B).withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;
    final tataFront = Paint()
      ..color = const Color(0xFF110305).withValues(alpha: 0.98)
      ..style = PaintingStyle.fill;

    // Colline du Mamelon en arrière-plan
    final mamelon = Path()
      ..moveTo(0, size.height * 0.80)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.35, size.width, size.height * 0.75)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(mamelon, tataBack);

    // Muraille crénelée du Tata de Sikasso au premier plan
    final tataPath = Path()..moveTo(0, size.height);
    tataPath.lineTo(0, size.height * 0.65);

    // Créneaux militaires
    for (double x = 0; x <= size.width; x += 18) {
      tataPath.lineTo(x, size.height * 0.65);
      tataPath.lineTo(x + 5, size.height * 0.65);
      tataPath.lineTo(x + 5, size.height * 0.69);
      tataPath.lineTo(x + 13, size.height * 0.69);
      tataPath.lineTo(x + 13, size.height * 0.65);
      tataPath.lineTo(x + 18, size.height * 0.65);
    }
    tataPath.lineTo(size.width, size.height);
    tataPath.close();

    canvas.drawPath(tataPath, tataFront);

    // Bastion de surveillance principal à gauche
    final bastion = Path()
      ..moveTo(size.width * 0.12, size.height)
      ..lineTo(size.width * 0.12, size.height * 0.50)
      ..lineTo(size.width * 0.22, size.height * 0.50)
      ..lineTo(size.width * 0.22, size.height)
      ..close();
    canvas.drawPath(bastion, tataFront);
  }

  // 4. Gao (Askia Mohammed) : Pyramide à redents du Tombeau des Askia & Niger
  void _paintGaoAskiaPyramidAndRiver(Canvas canvas, Size size) {
    final riverPaint = Paint()
      ..color = const Color(0xFF041F1A).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final pyramidPaint = Paint()
      ..color = const Color(0xFF02100E).withValues(alpha: 0.98)
      ..style = PaintingStyle.fill;

    // Vagues douces du fleuve Niger
    final riverPath = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.68, size.width * 0.6, size.height * 0.78)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.85, size.width, size.height * 0.72)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(riverPath, riverPaint);

    // Silhouette pyramidale à degrés du Tombeau des Askia
    final centerX = size.width * 0.75;
    final baseY = size.height * 0.95;
    final pyrPath = Path()
      // Degré 1 (Base large)
      ..moveTo(centerX - 55, baseY)
      ..lineTo(centerX - 45, baseY - 25)
      ..lineTo(centerX + 45, baseY - 25)
      ..lineTo(centerX + 55, baseY)
      // Degré 2
      ..moveTo(centerX - 40, baseY - 25)
      ..lineTo(centerX - 30, baseY - 55)
      ..lineTo(centerX + 30, baseY - 55)
      ..lineTo(centerX + 40, baseY - 25)
      // Degré 3 (Sommet)
      ..moveTo(centerX - 24, baseY - 55)
      ..lineTo(centerX - 10, baseY - 82)
      ..lineTo(centerX + 10, baseY - 82)
      ..lineTo(centerX + 24, baseY - 55)
      ..close();

    canvas.drawPath(pyrPath, pyramidPaint);

    // Échafaudages de bois sacrés qui rayonnent
    final stickPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.45)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(centerX - 18, baseY - 85), Offset(centerX - 28, baseY - 95), stickPaint);
    canvas.drawLine(Offset(centerX, baseY - 86), Offset(centerX, baseY - 98), stickPaint);
    canvas.drawLine(Offset(centerX + 18, baseY - 85), Offset(centerX + 28, baseY - 95), stickPaint);
  }

  // 5. Ségou (Biton Coulibaly) : Grands Balanzans légendaires & fleuve Djoliba
  void _paintSegouBalanzansAndRiver(Canvas canvas, Size size) {
    final waterPaint = Paint()
      ..color = const Color(0xFF1F1206).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final balanzanPaint = Paint()
      ..color = const Color(0xFF0E0702).withValues(alpha: 0.98)
      ..style = PaintingStyle.fill;

    // Rive du fleuve Djoliba
    final riverPath = Path()
      ..moveTo(0, size.height * 0.78)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.62, size.width, size.height * 0.75)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(riverPath, waterPaint);

    // Deux majestueux arbres Balanzans (acacias géants emblématiques de Ségou)
    // Arbre 1 à gauche
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.16, size.height * 0.52, 14, size.height * 0.45),
      balanzanPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.17, size.height * 0.48),
        width: size.width * 0.26,
        height: size.height * 0.28,
      ),
      balanzanPaint,
    );

    // Arbre 2 à droite
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.78, size.height * 0.58, 12, size.height * 0.40),
      balanzanPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.79, size.height * 0.55),
        width: size.width * 0.22,
        height: size.height * 0.24,
      ),
      balanzanPaint,
    );
  }

  // 6. Bamako (Modibo Keïta) : Flèche du Monument de l'Indépendance & Point G
  void _paintBamakoIndependenceMonument(Canvas canvas, Size size) {
    final hillPaint = Paint()
      ..color = const Color(0xFF0B2138).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final monumentPaint = Paint()
      ..color = const Color(0xFF040F1A).withValues(alpha: 0.98)
      ..style = PaintingStyle.fill;

    // Colline du Point G
    final hillPath = Path()
      ..moveTo(0, size.height * 0.82)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.52, size.width * 0.7, size.height * 0.75)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hillPath, hillPaint);

    // Flèche stylisée du Monument de l'Indépendance
    final mx = size.width * 0.80;
    final monumentPath = Path()
      ..moveTo(mx - 20, size.height)
      ..lineTo(mx - 8, size.height * 0.35)
      ..lineTo(mx, size.height * 0.25) // Pointe haute
      ..lineTo(mx + 8, size.height * 0.35)
      ..lineTo(mx + 20, size.height)
      ..close();
    canvas.drawPath(monumentPath, monumentPaint);

    // Halo d'étoile républicaine au sommet
    final starGlow = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(mx, size.height * 0.25), 6, starGlow);
  }

  @override
  bool shouldRepaint(covariant _HistoricalLandscapeSilhouettePainter oldDelegate) =>
      oldDelegate.archetype != archetype ||
      oldDelegate.primaryColor != primaryColor;
}

/// Peintre d'avant-plan cinématique adapté à chaque personnage
class _CinematicForegroundBannersPainter extends CustomPainter {
  final double windProgress;
  final String archetype;
  final Color primaryColor;
  final Color secondaryColor;

  _CinematicForegroundBannersPainter({
    required this.windProgress,
    required this.archetype,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wave = math.sin(windProgress * math.pi) * 8.0;

    final bannerPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.32)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final trimPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    // Bannière flottante à gauche
    final leftBanner = Path()
      ..moveTo(-15, 0)
      ..quadraticBezierTo(
        size.width * 0.08 + wave,
        size.height * 0.25,
        size.width * 0.05 - wave,
        size.height * 0.55,
      )
      ..lineTo(-15, size.height * 0.55)
      ..close();

    canvas.drawPath(leftBanner, bannerPaint);
    canvas.drawPath(leftBanner, trimPaint);

    // Touche d'avant-plan spécifique à droite
    if (archetype == 'tombouctou') {
      // Parchemin manuscrit ancien flottant
      final paperPaint = Paint()
        ..color = const Color(0xFFFEF3C7).withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.save();
      canvas.translate(size.width * 0.92 - wave * 0.5, size.height * 0.30);
      canvas.rotate(0.25 + wave * 0.02);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 36, 48),
          const Radius.circular(4),
        ),
        paperPaint,
      );
      canvas.restore();
    } else if (archetype == 'bamako') {
      // Ruban républicain tricolore subtil
      final ribbonPaint = Paint()
        ..color = const Color(0xFF10B981).withValues(alpha: 0.25)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      final ribbon = Path()
        ..moveTo(size.width * 0.88, 0)
        ..quadraticBezierTo(
          size.width * 0.94 - wave,
          size.height * 0.22,
          size.width * 0.90 + wave,
          size.height * 0.45,
        );
      canvas.drawPath(ribbon, ribbonPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CinematicForegroundBannersPainter oldDelegate) =>
      true;
}
