import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../features/culture/core/theme/culture_theme.dart';

enum UniverseDestination {
  culture,
  education,
}

/// Les 3 segments SVG vectoriels officiels réunis de l'emblème AlterniA
const String _kAlterniaOfficialLogoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 4529.98 4458.18">
  <path d="M4528.48,3915.53c-1.54.9-3.08,1.77-4.61,2.64-34.6-825.6-515.39-1536.78-1209.19-1901.93-317.5-167.12-679.62-261.78-1064-261.78-362.91,0-705.96,84.37-1010.37,234.44-1.19-30.29-1.81-60.73-1.81-91.32,0-792.97,408.49-1490.87,1027.23-1896.12,104.44,63.94,208.11,134.08,310.46,210.21,393.62,292.77,767.53,673.93,1088.58,1130.26,598.18,850.19,888.87,1784.99,863.71,2573.6Z" fill="#f1851f"/>
  <path d="M4523.86,3918.17c-43.29,24.81-87.59,48.88-132.85,72.19-609.08,313.78-1391.95,490.76-2240.82,465.42-712.48-21.26-1370.03-182.01-1911.36-439.8,251.52,96.27,524.55,148.99,809.84,148.99,453.46,0,875.85-133.19,1230.29-362.65,592.79-383.72,995.53-1036.66,1035.7-1786.07,693.8,365.15,1174.59,1076.33,1209.19,1901.93Z" fill="#40bbcc"/>
  <path d="M2278.97,3802.32c-354.44,229.46-776.83,362.65-1230.29,362.65-285.29,0-558.31-52.72-809.84-148.99-82.38-39.22-162.07-80.69-238.84-124.25,6.06-130.64,18.06-263.65,36.12-398.38,51.27-382.47,151.38-778.84,303.44-1174.18C764.11,1215.53,1494.63,377.31,2263.32,0c.8.47,1.59.98,2.41,1.47-618.74,405.25-1027.23,1103.15-1027.23,1896.12,0,30.58.62,61.02,1.81,91.32,30.24,760.63,436.51,1424.94,1038.67,1813.42Z" fill="#314999"/>
</svg>
''';

class UniverseSplashTransition {
  static void toCulture(BuildContext context,
      {required VoidCallback onComplete}) {
    _showTransition(
      context,
      destination: UniverseDestination.culture,
      onComplete: onComplete,
    );
  }

  static void toEducation(BuildContext context,
      {required VoidCallback onComplete}) {
    _showTransition(
      context,
      destination: UniverseDestination.education,
      onComplete: onComplete,
    );
  }

  static void _showTransition(
    BuildContext context, {
    required UniverseDestination destination,
    required VoidCallback onComplete,
  }) {
    HapticFeedback.heavyImpact();

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, anim1, anim2) {
        return _UniverseSplashView(
          destination: destination,
          onFinish: () {
            Navigator.of(dialogContext, rootNavigator: true).pop();
            onComplete();
          },
        );
      },
    );
  }
}

class _UniverseSplashView extends StatefulWidget {
  const _UniverseSplashView({
    required this.destination,
    required this.onFinish,
  });

  final UniverseDestination destination;
  final VoidCallback onFinish;

  @override
  State<_UniverseSplashView> createState() => _UniverseSplashViewState();
}

class _UniverseSplashViewState extends State<_UniverseSplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _slideAnim;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
    );

    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
    );

    _slideAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.20, 0.55, curve: Curves.easeOutCubic),
    );

    _ctrl.forward();

    // Transition fluide vers l'univers demandé
    Timer(const Duration(milliseconds: 1750), _finishOnce);
  }

  void _finishOnce() {
    if (_finished || !mounted) return;
    _finished = true;
    HapticFeedback.mediumImpact();
    widget.onFinish();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isToCulture = widget.destination == UniverseDestination.culture;

    // Palette dynamique fidèle à la charte AlterniA selon la destination
    final List<Color> bgGradientColors = isToCulture
        ? const [
            Color(0xFF140A04), // Teinte braise / obsidian ambré
            Color(0xFF2B1306), // Cœur chaud marron/orange foncé
            Color(0xFF0E0603), // Noir charbon chaleureux
          ]
        : const [
            Color(0xFF060B18), // Bleu marine profond officiel
            Color(0xFF0D1C38), // Cœur bleu nuit royal
            Color(0xFF03060C), // Noir abyssal
          ];

    final primaryAccent =
        isToCulture ? CultureTheme.accentOrange : AppColors.primary;
    final secondaryAccent =
        isToCulture ? const Color(0xFFF59E0B) : const Color(0xFF40BBCC);

    final bottomBadgeLabel = isToCulture ? 'Espace Culture' : 'Espace Éducation';
    final bottomBadgeIcon = isToCulture
        ? Icons.explore_rounded
        : Icons.school_rounded;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _finishOnce,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. FOND DÉGRADÉ & FLOU SUBTIL ────────────────────────────────
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: bgGradientColors,
                  ),
                ),
              ),
            ),

            // ── 2. HALOS & SPHÈRES LUMINEUSES RESPONSIVES (ORBS) ─────────────
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, child) {
                  final t = _ctrl.value;
                  final pulse1 = 0.85 + 0.15 * math.sin(t * math.pi * 2);
                  final pulse2 = 0.85 + 0.15 * math.cos(t * math.pi * 2);

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final size = math.min(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );

                      return Stack(
                        children: [
                          // Halo Haut / Droite (Orange charte pour Culture, Bleu pour Éducation)
                          Align(
                            alignment: const Alignment(0.68, -0.42),
                            child: Opacity(
                              opacity: (_fadeAnim.value * 0.9).clamp(0.0, 1.0),
                              child: Container(
                                width: size * 0.52 * pulse1,
                                height: size * 0.52 * pulse1,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryAccent.withValues(
                                    alpha: isToCulture ? 0.22 : 0.28,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryAccent.withValues(
                                        alpha: isToCulture ? 0.32 : 0.38,
                                      ),
                                      blurRadius: 90,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Halo Bas / Gauche (Nuance chaude pour Culture, Cyan pour Éducation)
                          Align(
                            alignment: const Alignment(-0.62, 0.40),
                            child: Opacity(
                              opacity: (_fadeAnim.value * 0.75).clamp(0.0, 1.0),
                              child: Container(
                                width: size * 0.46 * pulse2,
                                height: size * 0.46 * pulse2,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: secondaryAccent.withValues(
                                    alpha: isToCulture ? 0.16 : 0.20,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: secondaryAccent.withValues(
                                        alpha: isToCulture ? 0.22 : 0.26,
                                      ),
                                      blurRadius: 85,
                                      spreadRadius: 15,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            // ── 3. CONTENU PRINCIPAL CENTRÉ STYLE CAPTURE 1 ──────────────────
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: AnimatedBuilder(
                      animation: _ctrl,
                      builder: (context, child) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 24),

                            // ── CARTE BLANCHE CENTRALE AVEC L'EMBLÈME ALTERNIA ──
                            Transform.scale(
                              scale: _scaleAnim.value,
                              child: Opacity(
                                opacity: _fadeAnim.value,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(34),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.45),
                                        blurRadius: 30,
                                        offset: const Offset(0, 12),
                                      ),
                                      BoxShadow(
                                        color: primaryAccent.withValues(alpha: 0.28),
                                        blurRadius: 35,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: 82,
                                      height: 82,
                                      child: SvgPicture.string(
                                        _kAlterniaOfficialLogoSvg,
                                        width: 82,
                                        height: 82,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // ── TITRE : AlterniA + Slogan Officiel ────────────
                            Transform.translate(
                              offset: Offset(0, (1.0 - _slideAnim.value) * 16),
                              child: Opacity(
                                opacity: _slideAnim.value,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                          color: Colors.white,
                                        ),
                                        children: const [
                                          TextSpan(text: 'Altern'),
                                          TextSpan(
                                            text: 'iA',
                                            style: TextStyle(
                                              color: CultureTheme.iaYellow,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Alternative pour apprendre l\'essentiel',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF94A3B8),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 48),

                            // ── BADGE D'UNIVERS : "Espace Culture" ou "Espace Éducation" ──
                            Transform.translate(
                              offset: Offset(0, (1.0 - _slideAnim.value) * 10),
                              child: Opacity(
                                opacity: _slideAnim.value,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryAccent.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: primaryAccent.withValues(alpha: 0.55),
                                      width: 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryAccent.withValues(alpha: 0.25),
                                        blurRadius: 18,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        bottomBadgeIcon,
                                        size: 15,
                                        color: isToCulture
                                            ? const Color(0xFFF1851F)
                                            : const Color(0xFF40BBCC),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        bottomBadgeLabel,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── MALI • 2026 (Signature Officielle) ───────────
                            Opacity(
                              opacity: (_ctrl.value * 0.4).clamp(0.0, 0.4),
                              child: Text(
                                'MALI • 2026',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.2,
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
