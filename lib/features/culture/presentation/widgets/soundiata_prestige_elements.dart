import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../immersive/services/cultural_haptics.dart';

// ══════════════════════════════════════════════════════════════════════════════
// 1. THÈMES DE LECTURE DU LIVRE : NUIT IMPÉRIALE vs PARCHEMIN ANCIEN
// ══════════════════════════════════════════════════════════════════════════════

enum SoundiataReadingTheme {
  imperialDark,
  ancientParchment,
}

class SoundiataThemeColors {
  final Color background;
  final Color cardBackground;
  final Color cardBackgroundAlt;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color goldAccent;
  final Color quoteBackground;

  const SoundiataThemeColors({
    required this.background,
    required this.cardBackground,
    required this.cardBackgroundAlt,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.goldAccent,
    required this.quoteBackground,
  });

  static const imperialDark = SoundiataThemeColors(
    background: Color(0xFF070B14),
    cardBackground: Color(0xFF0F172A),
    cardBackgroundAlt: Color(0xFF1E293B),
    border: Color(0x33F59E0B),
    textPrimary: Colors.white,
    textSecondary: Color(0xFF94A3B8),
    goldAccent: Color(0xFFF59E0B),
    quoteBackground: Color(0x1AF59E0B),
  );

  static const ancientParchment = SoundiataThemeColors(
    background: Color(0xFFF6F0DF),
    cardBackground: Color(0xFFFCF9EE),
    cardBackgroundAlt: Color(0xFFEFE8D3),
    border: Color(0x55B45309),
    textPrimary: Color(0xFF291B0E),
    textSecondary: Color(0xFF6B4F35),
    goldAccent: Color(0xFFB45309),
    quoteBackground: Color(0x22F59E0B),
  );

  static SoundiataThemeColors of(SoundiataReadingTheme theme) {
    return theme == SoundiataReadingTheme.imperialDark
        ? imperialDark
        : ancientParchment;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 2. MOTEUR DE PARTICULES ATMOSPHÉRIQUES MULTI-ACTES
// ══════════════════════════════════════════════════════════════════════════════

enum SoundiataAtmosphereType {
  dawnEmbers, // Actes 1 & 2 : Lucioles d'aube et étincelles
  caravanDust, // Actes 3 & 4 : Poussière d'or et vent saharien
  sacredLeaves, // Acte 5 : Feuilles de baobab tourbillonnantes
  kirinaTempest, // Acte 6 : Fracas d'éclairs et poussière de bataille
  celestialRays; // Acte 7 : Rayons divins de paix et pollen céleste

  static SoundiataAtmosphereType forChapter(int chapterNumber) {
    switch (chapterNumber) {
      case 1:
      case 2:
        return SoundiataAtmosphereType.dawnEmbers;
      case 3:
      case 4:
        return SoundiataAtmosphereType.caravanDust;
      case 5:
        return SoundiataAtmosphereType.sacredLeaves;
      case 6:
        return SoundiataAtmosphereType.kirinaTempest;
      case 7:
      default:
        return SoundiataAtmosphereType.celestialRays;
    }
  }
}

class SoundiataAtmospherePainter extends CustomPainter {
  final double progress;
  final SoundiataAtmosphereType type;

  SoundiataAtmospherePainter({
    required this.progress,
    required this.type,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case SoundiataAtmosphereType.dawnEmbers:
        _paintDawnEmbers(canvas, size);
        break;
      case SoundiataAtmosphereType.caravanDust:
        _paintCaravanDust(canvas, size);
        break;
      case SoundiataAtmosphereType.sacredLeaves:
        _paintSacredLeaves(canvas, size);
        break;
      case SoundiataAtmosphereType.kirinaTempest:
        _paintKirinaTempest(canvas, size);
        break;
      case SoundiataAtmosphereType.celestialRays:
        _paintCelestialRays(canvas, size);
        break;
    }
  }

  void _paintDawnEmbers(Canvas canvas, Size size) {
    // 1. Voiles de brume d'aube mandingue (vagues volumétriques horizontales)
    for (int i = 0; i < 3; i++) {
      final waveOffset = (progress * (0.2 + i * 0.15)) % 1.0;
      final yBase = size.height * (0.55 + i * 0.15);
      final mistPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            const Color(0xFFF59E0B).withValues(alpha: 0.12 - (i * 0.03)),
            const Color(0xFFD97706).withValues(alpha: 0.18 - (i * 0.04)),
            Colors.transparent,
          ],
          stops: const [0.0, 0.35, 0.65, 1.0],
        ).createShader(Rect.fromLTWH(0, yBase - 30, size.width, 60))
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(0, yBase);
      for (double x = 0; x <= size.width; x += 30) {
        final relX = (x / size.width + waveOffset) * 2 * math.pi;
        final waveY = yBase + math.sin(relX + i) * (8 + i * 4);
        path.lineTo(x, waveY);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, mistPaint);
    }
  }

  void _paintCaravanDust(Canvas canvas, Size size) {
    // 2. Traînées aérodynamiques du vent Harmattan (vecteurs cinétiques épurés)
    final windPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 7; i++) {
      final speed = 0.5 + (i * 0.12);
      final streamProgress = (progress * speed + (i * 0.17)) % 1.0;
      final y = size.height * (0.2 + (i * 0.11));
      final startX = (streamProgress * (size.width + 120)) - 60;
      final length = 60.0 + (i * 14.0);

      final alpha = (math.sin(streamProgress * math.pi) * 0.32).clamp(0.0, 1.0);
      windPaint.strokeWidth = 1.2 + (i % 3) * 0.6;
      windPaint.shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFFFCD34D).withValues(alpha: alpha),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(startX, y, length, 4));

      final path = Path();
      path.moveTo(startX, y);
      path.quadraticBezierTo(
        startX + (length * 0.5),
        y - 4 + math.sin(progress * 2 * math.pi + i) * 6,
        startX + length,
        y,
      );
      canvas.drawPath(path, windPaint);
    }
  }

  void _paintSacredLeaves(Canvas canvas, Size size) {
    // 3. Feuilles sacrées du baobab en vrille perspective 3D (yaw + pitch)
    final leafPaint = Paint()..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final t = (progress * 0.4 + (i * 0.16)) % 1.0;
      final x = (size.width * 0.15) + (i * (size.width * 0.14)) +
          math.sin(t * 2 * math.pi + i) * 25;
      final y = t * size.height;

      // Rotation et perspective 3D
      final angle = (t * 2 * math.pi * 1.5) + (i * 1.2);
      final flip3D = math.cos(angle); // Simule le retournement en profondeur 3D
      final leafScale = (0.7 + (i % 3) * 0.25) * flip3D.abs().clamp(0.25, 1.0);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(math.sin(angle) * 0.5);

      // Ombre portée en profondeur
      canvas.save();
      canvas.translate(3, 4);
      canvas.scale(leafScale, 0.7);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 14, height: 6),
        shadowPaint,
      );
      canvas.restore();

      // Corps de la feuille sacrée
      canvas.scale(leafScale, 1.0);
      leafPaint.color = flip3D > 0
          ? const Color(0xFFD97706).withValues(alpha: 0.6)
          : const Color(0xFFB45309).withValues(alpha: 0.75);

      final leafPath = Path()
        ..moveTo(-8, 0)
        ..quadraticBezierTo(0, -5, 8, 0)
        ..quadraticBezierTo(0, 5, -8, 0)
        ..close();
      canvas.drawPath(leafPath, leafPaint);

      // Nervure centrale
      final veinPaint = Paint()
        ..color = const Color(0xFFFEF3C7).withValues(alpha: 0.5)
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(-7, 0), const Offset(7, 0), veinPaint);

      canvas.restore();
    }
  }

  void _paintKirinaTempest(Canvas canvas, Size size) {
    // 4. Fracas d'éclairs de Kirina (arcs énergétiques vectoriels et flash d'orage)
    final flashCycle = (math.sin(progress * 4 * math.pi)).clamp(0.0, 1.0);

    // Éclat d'orage ambiant
    if (flashCycle > 0.75) {
      final ambientAlpha = ((flashCycle - 0.75) / 0.25 * 0.18).clamp(0.0, 1.0);
      final flashPaint = Paint()
        ..color = const Color(0xFFFEF08A).withValues(alpha: ambientAlpha)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);
    }

    // Arc d'éclair vectoriel foudroyant
    final boltPhase = ((progress * 3) % 1.0);
    if (boltPhase < 0.35) {
      final boltAlpha = (math.sin((boltPhase / 0.35) * math.pi) * 0.9).clamp(0.0, 1.0);
      final boltPaint = Paint()
        ..color = const Color(0xFFFDE047).withValues(alpha: boltAlpha)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.miter;

      final glowPaint = Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: boltAlpha * 0.5)
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final boltPath = Path()
        ..moveTo(size.width * 0.62, 0)
        ..lineTo(size.width * 0.56, size.height * 0.28)
        ..lineTo(size.width * 0.60, size.height * 0.32)
        ..lineTo(size.width * 0.52, size.height * 0.65)
        ..lineTo(size.width * 0.55, size.height * 0.68)
        ..lineTo(size.width * 0.48, size.height * 0.95);

      canvas.drawPath(boltPath, glowPaint);
      canvas.drawPath(boltPath, boltPaint);
    }
  }

  void _paintCelestialRays(Canvas canvas, Size size) {
    // 5. Faisceaux volumétriques célestes et halo anamorphique (Kouroukan Fouga)
    final sweep = math.sin(progress * 2 * math.pi) * (size.width * 0.08);

    final rayPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFDE68A).withValues(alpha: 0.22),
          const Color(0xFFF59E0B).withValues(alpha: 0.08),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Faisceaux volumétriques amples
    final rayPath = Path()
      ..moveTo((size.width * 0.5) + sweep, 0)
      ..lineTo(size.width * 0.05, size.height)
      ..lineTo(size.width * 0.30, size.height)
      ..close()
      ..moveTo((size.width * 0.5) + sweep, 0)
      ..lineTo(size.width * 0.45, size.height)
      ..lineTo(size.width * 0.70, size.height)
      ..close()
      ..moveTo((size.width * 0.5) + sweep, 0)
      ..lineTo(size.width * 0.78, size.height)
      ..lineTo(size.width * 0.98, size.height)
      ..close();

    canvas.drawPath(rayPath, rayPaint);

    // Flare horizontal anamorphique central
    final flareY = size.height * 0.38;
    final flarePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          const Color(0xFFFEF3C7).withValues(alpha: 0.35),
          const Color(0xFFF59E0B).withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(size.width * 0.5 + sweep * 0.5, flareY),
        width: size.width * 0.85,
        height: 16,
      ))
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5 + sweep * 0.5, flareY),
        width: size.width * 0.85,
        height: 14,
      ),
      flarePaint,
    );
  }

  @override
  bool shouldRepaint(covariant SoundiataAtmospherePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.type != type;
}

// ══════════════════════════════════════════════════════════════════════════════
// 3. SCEAU ROYAL D'OR & CÉRÉMONIE DE COMPLÉTION (PASSEPORT CULTUREL)
// ══════════════════════════════════════════════════════════════════════════════

class SoundiataRoyalSealCelebration extends StatefulWidget {
  final VoidCallback onReplay;
  final VoidCallback onLaunchFullscreen;
  final bool isDark;

  const SoundiataRoyalSealCelebration({
    super.key,
    required this.onReplay,
    required this.onLaunchFullscreen,
    required this.isDark,
  });

  @override
  State<SoundiataRoyalSealCelebration> createState() =>
      _SoundiataRoyalSealCelebrationState();
}

class _SoundiataRoyalSealCelebrationState
    extends State<SoundiataRoyalSealCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stampController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _stampController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 2.5, end: 0.95).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
    ]).animate(_stampController);

    _rotationAnimation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _stampController, curve: Curves.easeOutCubic),
    );

    _triggerCelebrationStamp();
  }

  Future<void> _triggerCelebrationStamp() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      _stampController.forward();
      CulturalHaptics.stamp();
    }
  }

  @override
  void dispose() {
    _stampController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF140E06) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF59E0B),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Titre solennel
          Text(
            'ÉPOPÉE DU MANDEN ACCOMPLIE',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFF59E0B),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'L\'Héritage du Lion est en Vous',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF291B0E),
              letterSpacing: -0.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // ── SCEAU ROYAL D'OR ANIMÉ (FRAPPE PHYSIQUE HAPTIQUE) ──
          AnimatedBuilder(
            animation: _stampController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFFCD34D),
                    Color(0xFFF59E0B),
                    Color(0xFFB45309),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.7),
                  width: 3.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Cercle dentelé intérieur
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: Colors.black87,
                        size: 34,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'SCEAU ROYAL',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        '1236 • MANDEN',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Récapitulatif des 3 prouesses culturelles
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                _buildAchievementRow(
                  icon: Icons.auto_stories_rounded,
                  title: '7 Actes Vivants Traversés',
                  subtitle: 'De la prophétie de Niani à la Paix universelle',
                  isDark: isDark,
                ),
                const Divider(height: 12),
                _buildAchievementRow(
                  icon: Icons.explore_rounded,
                  title: '6 Cités Médiévales Explorées',
                  subtitle: 'Voies caravanières de l\'Or et du Sel du Manden',
                  isDark: isDark,
                ),
                const Divider(height: 12),
                _buildAchievementRow(
                  icon: Icons.account_balance_rounded,
                  title: 'Charte de Kouroukan Fouga Intériorisée',
                  subtitle: 'Première charte des droits humains au monde (UNESCO)',
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Boutons d'action : Rejouer & Mode Plein Écran
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onReplay,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Relire l\'Épopée'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF59E0B),
                    side: const BorderSide(color: Color(0xFFF59E0B)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onLaunchFullscreen,
                  icon: const Icon(Icons.fullscreen_rounded, size: 18, color: Colors.black),
                  label: Text(
                    'Plein Écran',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
          ),
          child: Icon(icon, color: const Color(0xFFF59E0B), size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 4. SÉLECTEUR DE THÈME D'AFFICHAGE (NUIT IMPÉRIALE / PARCHEMIN ANCIEN)
// ══════════════════════════════════════════════════════════════════════════════

class SoundiataThemeSwitchButton extends StatelessWidget {
  final SoundiataReadingTheme currentTheme;
  final ValueChanged<SoundiataReadingTheme> onThemeChanged;
  final bool isCompact;

  const SoundiataThemeSwitchButton({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isImperial = currentTheme == SoundiataReadingTheme.imperialDark;

    return GestureDetector(
      onTap: () {
        CulturalHaptics.cardPress();
        onThemeChanged(
          isImperial
              ? SoundiataReadingTheme.ancientParchment
              : SoundiataReadingTheme.imperialDark,
        );
      },
      child: Tooltip(
        message: isImperial
            ? 'Basculer en Parchemin Ancien'
            : 'Basculer en Nuit Impériale',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: isCompact
              ? const EdgeInsets.all(8)
              : const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isImperial
                ? const Color(0xFF1E293B)
                : const Color(0xFFEFE8D3),
            shape: isCompact ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCompact ? null : BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isImperial ? Icons.dark_mode_rounded : Icons.menu_book_rounded,
                size: isCompact ? 16 : 13,
                color: const Color(0xFFF59E0B),
              ),
              if (!isCompact) ...[
                const SizedBox(width: 5),
                Text(
                  isImperial ? 'Nuit Impériale' : 'Parchemin',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isImperial ? Colors.white : const Color(0xFF291B0E),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
