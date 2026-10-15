import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../core/constants/app_colors.dart';

// ══════════════════════════════════════════════════════════════════════════════
// MODÈLES DE PARTICULES, ÉTOILES ET BRAISES
// ══════════════════════════════════════════════════════════════════════════════

enum ParticleType { flame, spark, steam }

class CampfireParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double life;
  double maxLife;
  final ParticleType type;
  final double randomSeed;

  CampfireParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.maxLife,
    required this.type,
    this.life = 0.0,
    double? randomSeed,
  }) : randomSeed = randomSeed ?? math.Random().nextDouble();

  bool get isDead => life >= 1.0;

  void update(double dt, double time, double fireIntensity) {
    life += dt / maxLife;

    switch (type) {
      case ParticleType.flame:
        x += vx * dt * 60;
        y += vy * dt * 60 * fireIntensity;
        vx += math.sin(time * 4.0 + y * 0.05) * 0.06;
        break;

      case ParticleType.spark:
        x += vx * dt * 60;
        y += vy * dt * 60 * fireIntensity;
        // Dérive sinusoïdale du vent sahélien
        vx += math.sin(time * 3.2 + y * 0.04) * 0.16;
        break;

      case ParticleType.steam:
        x += vx * dt * 60;
        y += vy * dt * 60;
        vx += math.sin(time * 1.8 + y * 0.03) * 0.07;
        break;
    }
  }

  Color getColor() {
    final t = life.clamp(0.0, 1.0);
    switch (type) {
      case ParticleType.flame:
        if (t < 0.22) {
          final localT = t / 0.22;
          return Color.lerp(
            const Color(0xFFFFFFF0),
            const Color(0xFFFDE047),
            localT,
          )!;
        } else if (t < 0.6) {
          final localT = (t - 0.22) / 0.38;
          return Color.lerp(
            const Color(0xFFFBBF24),
            AppColors.accent,
            localT,
          )!;
        } else {
          final localT = (t - 0.6) / 0.4;
          return Color.lerp(
            const Color(0xFFDC2626),
            const Color(0xFF9A3412).withValues(alpha: 0.0),
            localT,
          )!;
        }

      case ParticleType.spark:
        final alpha = (1.0 - t).clamp(0.0, 1.0);
        return Color.lerp(
          const Color(0xFFFEF08A),
          AppColors.accent,
          t,
        )!.withValues(alpha: alpha);

      case ParticleType.steam:
        final alpha = math.sin(t * math.pi) * 0.25;
        return const Color(0xFFF1F5F9).withValues(alpha: alpha);
    }
  }
}

class TwinklingStar {
  final double xRatio;
  final double yRatio;
  final double radius;
  final double speed;
  final double phase;

  const TwinklingStar({
    required this.xRatio,
    required this.yRatio,
    required this.radius,
    required this.speed,
    required this.phase,
  });

  double getOpacity(double time) {
    final s = math.sin(time * speed + phase);
    return 0.25 + 0.75 * ((s + 1.0) / 2.0);
  }
}

class ShootingStar {
  bool isActive = false;
  double startX = 0;
  double startY = 0;
  double currentX = 0;
  double currentY = 0;
  double length = 50;
  double progress = 0.0;
  double dx = 1.0;
  double dy = 0.55;

  void trigger(double width, double height, math.Random random) {
    isActive = true;
    progress = 0.0;
    startX = width * (0.05 + random.nextDouble() * 0.45);
    startY = height * (0.04 + random.nextDouble() * 0.2);
    currentX = startX;
    currentY = startY;
    length = 45.0 + random.nextDouble() * 30.0;
    final angle = 0.45 + random.nextDouble() * 0.25;
    dx = math.cos(angle);
    dy = math.sin(angle);
  }

  void update(double dt) {
    if (!isActive) return;
    progress += dt * 1.5;
    currentX = startX + dx * (progress * 180.0);
    currentY = startY + dy * (progress * 180.0);
    if (progress >= 1.0) {
      isActive = false;
    }
  }
}

class Firefly {
  double xRatio;
  double yRatio;
  double phase;
  double speed;
  double radius;

  Firefly({
    required this.xRatio,
    required this.yRatio,
    required this.phase,
    required this.speed,
    required this.radius,
  });

  void update(double dt) {
    phase += dt * speed;
  }

  Offset getPosition(double width, double height) {
    final x = (xRatio + 0.03 * math.sin(phase * 0.8)) * width;
    final y = (yRatio + 0.025 * math.cos(phase * 1.1)) * height;
    return Offset(x, y);
  }

  double getOpacity() {
    final s = math.sin(phase * 1.6);
    return 0.2 + 0.8 * ((s + 1.0) / 2.0);
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WIDGET PRINCIPAL : VillageCampfireWidget
// ══════════════════════════════════════════════════════════════════════════════

class VillageCampfireWidget extends StatefulWidget {
  final double height;
  final bool isThinking;
  final String? visitorName;
  final bool isSoundActive;
  final VoidCallback? onSoundToggle;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onBackTap;
  final VoidCallback? onElderTap;
  final VoidCallback? onFireStoked;

  const VillageCampfireWidget({
    super.key,
    this.height = 280.0,
    this.isThinking = false,
    this.visitorName,
    this.isSoundActive = true,
    this.onSoundToggle,
    this.onSettingsTap,
    this.onBackTap,
    this.onElderTap,
    this.onFireStoked,
  });

  @override
  State<VillageCampfireWidget> createState() => _VillageCampfireWidgetState();
}

class _VillageCampfireWidgetState extends State<VillageCampfireWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final math.Random _random = math.Random(77);

  final List<TwinklingStar> _stars = [];
  final List<Firefly> _fireflies = [];
  final ShootingStar _shootingStar = ShootingStar();
  double _timeUntilShootingStar = 8.0;

  final List<CampfireParticle> _particles = [];
  double _fireIntensity = 1.0;
  double _elapsedTime = 0.0;
  double _lastTick = 0.0;

  bool _showBubble = false;
  String _currentQuote = '';
  int _quoteIndex = 0;

  static const List<String> _elderProverbs = [
    '« I ni sou, mon enfant ! Approche, assieds-toi près du feu... L\'eau chaude n\'oublie jamais qu\'elle a été froide. »',
    '« I ni ce ! Pose ta calebasse de fatigue. Une grand-mère qui conte la nuit sous le baobab nourrit l\'âme de toute une génération. »',
    '« Écoute le chant des flammes... La sagesse d\'une femme est comme l\'eau du puits : plus on y puise, plus elle est claire. »',
    '« De Soundiata, de la reine Sogolon ou de Mansa Moussa, quelle histoire veux-tu que ta doyenne te conte ce soir ? »',
    '« Donne-moi ton nom de famille ou ton prénom, et je te révélerai ses racines profondes et son animal totem ! »',
    '« La parole est comme le feu : attisée avec sagesse, elle réchauffe les esprits et éclaire les chemins. »',
    '« Les étoiles du ciel sahélien veillent sur notre mémoire. Que désires-tu apprendre aujourd\'hui ? »',
  ];

  @override
  void initState() {
    super.initState();
    _currentQuote = _elderProverbs[0];
    _initCosmos();

    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_onTick);
    _ticker.repeat();
  }

  void _initCosmos() {
    _stars.clear();
    for (int i = 0; i < 42; i++) {
      _stars.add(
        TwinklingStar(
          xRatio: _random.nextDouble(),
          yRatio: _random.nextDouble() * 0.45,
          radius: 0.6 + _random.nextDouble() * 1.5,
          speed: 1.2 + _random.nextDouble() * 2.8,
          phase: _random.nextDouble() * math.pi * 2,
        ),
      );
    }

    _fireflies.clear();
    for (int i = 0; i < 16; i++) {
      _fireflies.add(
        Firefly(
          xRatio: 0.05 + _random.nextDouble() * 0.90,
          yRatio: 0.15 + _random.nextDouble() * 0.65,
          phase: _random.nextDouble() * math.pi * 2,
          speed: 1.0 + _random.nextDouble() * 1.8,
          radius: 1.4 + _random.nextDouble() * 1.6,
        ),
      );
    }
  }

  void _onTick() {
    final now = DateTime.now().microsecondsSinceEpoch / 1000000.0;
    if (_lastTick == 0.0) _lastTick = now;
    final dt = (now - _lastTick).clamp(0.005, 0.05);
    _lastTick = now;
    _elapsedTime += dt;

    if (_fireIntensity > 1.0) {
      _fireIntensity = math.max(1.0, _fireIntensity - dt * 0.42);
    }

    // Étoile filante (toutes les 16 à 26s)
    _timeUntilShootingStar -= dt;
    if (_timeUntilShootingStar <= 0) {
      _shootingStar.trigger(context.size?.width ?? 360, widget.height, _random);
      _timeUntilShootingStar = 16.0 + _random.nextDouble() * 10.0;
    }
    _shootingStar.update(dt);

    // Mise à jour des braises dorées
    for (final f in _fireflies) {
      f.update(dt);
    }

    _updateParticles(dt);

    setState(() {});
  }

  void _updateParticles(double dt) {
    _particles.removeWhere((p) => p.isDead);

    final width = context.size?.width ?? 360.0;
    final fireBaseX = width * 0.28;
    final fireBaseY = widget.height * 0.78;

    // Étincelles dorées ascendantes émanant naturellement du foyer
    final sparkBonus = widget.isThinking ? 2 : 1;
    final sparkRate = (3.0 * _fireIntensity * sparkBonus).round();
    for (int i = 0; i < sparkRate; i++) {
      if (_random.nextDouble() < 0.88) {
        final spreadX = (_random.nextDouble() - 0.5) * 35.0;
        _particles.add(
          CampfireParticle(
            x: fireBaseX + spreadX,
            y: fireBaseY - 2.0,
            vx: (_random.nextDouble() - 0.5) * 1.8,
            vy: -2.6 - _random.nextDouble() * 3.4,
            size: 1.6 + _random.nextDouble() * 2.2,
            maxLife: 1.4 + _random.nextDouble() * 1.2,
            type: ParticleType.spark,
          ),
        );
      }
    }

    // Brume chaude / vapeur douce
    if (_random.nextDouble() < 0.22) {
      _particles.add(
        CampfireParticle(
          x: fireBaseX + 6.0 + (_random.nextDouble() - 0.5) * 16.0,
          y: fireBaseY - 4.0,
          vx: (_random.nextDouble() - 0.5) * 0.25,
          vy: -0.6 - _random.nextDouble() * 0.5,
          size: 4.0 + _random.nextDouble() * 4.0,
          maxLife: 1.6 + _random.nextDouble() * 0.8,
          type: ParticleType.steam,
        ),
      );
    }

    for (final p in _particles) {
      p.update(dt, _elapsedTime, _fireIntensity);
    }
  }

  void _stokeFire() {
    HapticFeedback.heavyImpact();
    setState(() {
      _fireIntensity = 3.0;
      _currentQuote =
          '« Les braises chantent, mon enfant ! Tu nourris la flamme de nos ancêtres. »';
      _showBubble = true;
    });

    final width = context.size?.width ?? 360.0;
    final fireBaseX = width * 0.28;
    final fireBaseY = widget.height * 0.80;

    for (int i = 0; i < 64; i++) {
      _particles.add(
        CampfireParticle(
          x: fireBaseX + (_random.nextDouble() - 0.5) * 38.0,
          y: fireBaseY - 2.0,
          vx: (_random.nextDouble() - 0.5) * 4.8,
          vy: -3.8 - _random.nextDouble() * 6.2,
          size: 1.8 + _random.nextDouble() * 2.8,
          maxLife: 1.6 + _random.nextDouble() * 1.4,
          type: ParticleType.spark,
        ),
      );
    }

    widget.onFireStoked?.call();
  }

  void _tapElder() {
    HapticFeedback.selectionClick();
    setState(() {
      _quoteIndex = (_quoteIndex + 1) % _elderProverbs.length;
      _currentQuote = _elderProverbs[_quoteIndex];
      _showBubble = true;
    });
    widget.onElderTap?.call();
  }

  void _handleTapDown(TapDownDetails details, double width) {
    final pos = details.localPosition;
    if (pos.dx < width * 0.46) {
      _stokeFire();
    } else {
      _tapElder();
    }
  }

  void _showElderBioDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 1.2),
              ),
              child: const Icon(Icons.auto_awesome, size: 16, color: AppColors.accentLight),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grand-mère Mah',
                    style: GoogleFonts.cinzel(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '78 ans • Griotte & Gardienne de la Parole',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gardienne de la parole ancienne et mémoire vive du Mandé, Grand-mère Mah perpétue la tradition orale et la généalogie des familles au coin du feu sacré.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  height: 1.55,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '« Chez nous, une vieille assise voit plus loin qu\'un jeune debout. Donne-moi ton nom, et je te dirai qui tu es selon les pactes de nos ancêtres. »',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  color: AppColors.accentLight,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.touch_app,
                        color: AppColors.accent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Astuce : Touchez la doyenne pour entendre ses proverbes, ou touchez le feu pour faire jaillir les étincelles !',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'J\'ai compris',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ticker.removeListener(_onTick);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final fireBaseX = width * 0.28;
        final fireBaseY = widget.height * 0.80;

        return ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
          child: SizedBox(
            width: width,
            height: widget.height,
            child: GestureDetector(
              onTapDown: (details) => _handleTapDown(details, width),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── COUCHE 1 : DÉCOR 3D AVEC RESPIRATION 2.5D ──
                  Transform.scale(
                    scale: 1.02 + 0.012 * math.sin(_elapsedTime * 1.5),
                    child: Transform.translate(
                      offset: Offset(0, math.sin(_elapsedTime * 1.2) * 1.2),
                      child: Image.asset(
                        'assets/images/culture/doyenne_vivienne_campfire.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (ctx, err, stack) {
                          return Container(
                            color: AppColors.background,
                          );
                        },
                      ),
                    ),
                  ),

                  // ── COUCHE 2 : MOTEUR PHYSIQUE 2D/3D (LUMIÈRE RADIALE, FLAMMES, ÉTINCELLES DORÉES) ──
                  RepaintBoundary(
                    child: CustomPaint(
                      size: Size(width, widget.height),
                      painter: LivingCampfireOverlayPainter(
                        time: _elapsedTime,
                        fireIntensity: _fireIntensity,
                        fireX: fireBaseX,
                        fireY: fireBaseY,
                        stars: _stars,
                        fireflies: _fireflies,
                        shootingStar: _shootingStar,
                        particles: _particles,
                        isThinking: widget.isThinking,
                      ),
                    ),
                  ),

                  // ── COUCHE 3 : GRADIENTS D'ATMOSPHÈRE & OMBRAGE ──
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.4),
                              Colors.transparent,
                              AppColors.background.withValues(alpha: 0.55),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── COUCHE 4 : INTERFACE SUPÉRIEURE (CHARTE ALTERNIA) ──
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LIGNE 1 : SOUS LE BAOBAB DU VILLAGE | Son du village | Réglages
                        Row(
                          children: [
                            if (widget.onBackTap != null) ...[
                              GestureDetector(
                                onTap: widget.onBackTap,
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withValues(alpha: 0.88),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.border,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_rounded,
                                    size: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],

                            // 1. SOUS LE BAOBAB DU VILLAGE (AUCUN POINT VERT)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4.5),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.accent,
                                  width: 1.1,
                                ),
                              ),
                              child: Text(
                                'SOUS LE BAOBAB DU VILLAGE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.2,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accentLight,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),

                            const Spacer(),

                            // 2. Son du village (Bouton interactif)
                            GestureDetector(
                              onTap: widget.onSoundToggle,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4.5),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: widget.isSoundActive
                                        ? AppColors.accent
                                        : AppColors.border,
                                    width: 1.1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      widget.isSoundActive
                                          ? Icons.volume_up_rounded
                                          : Icons.volume_off_rounded,
                                      size: 12,
                                      color: widget.isSoundActive
                                          ? AppColors.accentLight
                                          : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Son du village',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9.2,
                                        fontWeight: FontWeight.w700,
                                        color: widget.isSoundActive
                                            ? AppColors.accentLight
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 6),

                            // 3. Bouton réglages / ambiance
                            GestureDetector(
                              onTap: widget.onSettingsTap,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(alpha: 0.88),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1.1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.tune_rounded,
                                  size: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── COUCHE 5 : BAS DE L'EN-TÊTE ──
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Titre & Rôle de la Doyenne (à gauche)
                        GestureDetector(
                          onTap: () => _showElderBioDialog(context),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Grand-mère Mah',
                                    style: GoogleFonts.cinzel(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    size: 13,
                                    color: AppColors.accent,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(alpha: 0.88),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  '78 ans • Griotte & Gardienne de la Parole',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 8.8,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accentLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Nuit étoilée au Mali / Tisonner le feu (à droite)
                        GestureDetector(
                          onTap: _stokeFire,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.88),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.accent,
                                width: 1.1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.nightlight_round, size: 11, color: AppColors.accentLight),
                                const SizedBox(width: 4),
                                Text(
                                  'Nuit étoilée au Mali',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.2,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── COUCHE 6 : BULLE DE PAROLE FLOTTANTE DE LA DOYENNE ──
                  if (_showBubble)
                    Positioned(
                      left: width * 0.12,
                      top: 48,
                      right: 12,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _showBubble ? 1.0 : 0.0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 9, 8, 9),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.accent,
                              width: 1.3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.65),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2, right: 6),
                                child: Icon(Icons.auto_stories_rounded, size: 13, color: AppColors.accentLight),
                              ),
                              Expanded(
                                child: Text(
                                  _currentQuote,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.italic,
                                    height: 1.35,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _showBubble = false),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: Icon(
                                    Icons.close,
                                    size: 14,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PAINTER 2D/3D VIVANT : LUMIÈRE RADIALE, FLAMMES & ÉTINCELLES DORÉES
// ══════════════════════════════════════════════════════════════════════════════

class LivingCampfireOverlayPainter extends CustomPainter {
  final double time;
  final double fireIntensity;
  final double fireX;
  final double fireY;
  final List<TwinklingStar> stars;
  final List<Firefly> fireflies;
  final ShootingStar shootingStar;
  final List<CampfireParticle> particles;
  final bool isThinking;

  const LivingCampfireOverlayPainter({
    required this.time,
    required this.fireIntensity,
    required this.fireX,
    required this.fireY,
    required this.stars,
    required this.fireflies,
    required this.shootingStar,
    required this.particles,
    required this.isThinking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Étoiles scintillantes & Étoile filante dans le ciel
    _paintStarsAndSky(canvas, w, h);

    // 2. Halo lumineux radial vacillant du feu naturel
    _paintDynamicFireLighting(canvas, w, h);

    // 3. Particules et étincelles dorées ascendantes
    _paintParticles(canvas);

    // 5. Braises/lucioles dorées flottant dans la nuit (SANS AUCUN VERT)
    _paintGoldenEmbers(canvas, w, h);

    // 6. Halo de pensée de la Doyenne
    if (isThinking) {
      _paintThinkingAura(canvas, w, h);
    }
  }

  // ── 1. ÉTOILES & ÉTOILE FILANTE ───────────────────────────────────────────

  void _paintStarsAndSky(Canvas canvas, double w, double h) {
    final starPaint = Paint()..style = PaintingStyle.fill;
    final groundLimit = h * 0.45;

    for (final star in stars) {
      final sx = star.xRatio * w;
      final sy = star.yRatio * groundLimit;
      final opacity = star.getOpacity(time);
      starPaint.color = Colors.white.withValues(alpha: opacity * 0.85);
      canvas.drawCircle(Offset(sx, sy), star.radius, starPaint);

      if (star.radius > 1.2) {
        final haloPaint = Paint()
          ..color = const Color(0xFFFEF08A).withValues(alpha: opacity * 0.35);
        canvas.drawCircle(Offset(sx, sy), star.radius * 2.2, haloPaint);
      }
    }

    if (shootingStar.isActive) {
      final trailPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            const Color(0xFFFDE047).withValues(alpha: 0.6),
            Colors.white.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(
          Rect.fromPoints(
            Offset(
              shootingStar.currentX - shootingStar.dx * shootingStar.length,
              shootingStar.currentY - shootingStar.dy * shootingStar.length,
            ),
            Offset(shootingStar.currentX, shootingStar.currentY),
          ),
        );

      canvas.drawLine(
        Offset(
          shootingStar.currentX - shootingStar.dx * shootingStar.length,
          shootingStar.currentY - shootingStar.dy * shootingStar.length,
        ),
        Offset(shootingStar.currentX, shootingStar.currentY),
        trailPaint,
      );
    }
  }

  // ── 2. LUMIÈRE RADIALE DU FEU (VOLUMETRIC LIGHTING 60 FPS) ────────────────

  void _paintDynamicFireLighting(Canvas canvas, double w, double h) {
    final flicker = 0.84 +
        0.16 * math.sin(time * 12.5) +
        0.10 * math.cos(time * 19.0) +
        0.05 * math.sin(time * 33.0);

    final glowRadius = (85.0 * fireIntensity * flicker).clamp(50.0, 220.0);

    final fireGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFD54F).withValues(
            alpha: (0.42 * fireIntensity * flicker).clamp(0.0, 0.85),
          ),
          AppColors.accent.withValues(
            alpha: (0.24 * fireIntensity * flicker).clamp(0.0, 0.6),
          ),
          const Color(0xFFE65100).withValues(
            alpha: (0.09 * fireIntensity).clamp(0.0, 0.35),
          ),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.7, 1.0],
      ).createShader(
        Rect.fromCircle(center: Offset(fireX, fireY), radius: glowRadius),
      );

    canvas.drawCircle(Offset(fireX, fireY), glowRadius, fireGlowPaint);

    final directionalGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.6, 0.2),
        colors: [
          const Color(0xFFFFE082).withValues(
            alpha: (0.26 * fireIntensity * flicker).clamp(0.0, 0.65),
          ),
          AppColors.accent.withValues(
            alpha: (0.12 * fireIntensity).clamp(0.0, 0.4),
          ),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(
        Rect.fromLTWH(fireX - 10, fireY - 110, w - fireX + 10, 130),
      );

    canvas.drawRect(
      Rect.fromLTWH(fireX - 10, fireY - 110, w - fireX + 10, 130),
      directionalGlow,
    );
  }

  // ── 3. PARTICULES & ÉTINCELLES DORÉES (ÉMANANT DU FOYER NATUREL) ───────────

  void _paintParticles(Canvas canvas) {
    final pPaint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      pPaint.color = p.getColor();
      switch (p.type) {
        case ParticleType.flame:
          break;
        case ParticleType.spark:
        case ParticleType.steam:
          canvas.drawCircle(Offset(p.x, p.y), p.size, pPaint);
          break;
      }
    }
  }

  // ── 5. BRAISES DORÉES FLOTTANTES ───────────────────────────────────────────

  void _paintGoldenEmbers(Canvas canvas, double w, double h) {
    final flyPaint = Paint()..style = PaintingStyle.fill;
    for (final f in fireflies) {
      final pos = f.getPosition(w, h);
      final opacity = f.getOpacity();

      flyPaint.color =
          const Color(0xFFFDE047).withValues(alpha: opacity * 0.9);
      canvas.drawCircle(pos, f.radius, flyPaint);

      final aura = Paint()
        ..color = AppColors.accent.withValues(alpha: opacity * 0.35);
      canvas.drawCircle(pos, f.radius * 2.2, aura);
    }
  }

  // ── 6. HALO DE PENSÉE ──────────────────────────────────────────────────────

  void _paintThinkingAura(Canvas canvas, double w, double h) {
    final elderX = w * 0.62;
    final elderY = h * 0.48;
    final pulse = 0.5 + 0.5 * math.sin(time * 4.5);

    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFDE047).withValues(alpha: 0.18 * pulse),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(elderX, elderY), radius: 80.0),
      );

    canvas.drawCircle(Offset(elderX, elderY), 80.0, auraPaint);
  }

  @override
  bool shouldRepaint(covariant LivingCampfireOverlayPainter oldDelegate) => true;
}
