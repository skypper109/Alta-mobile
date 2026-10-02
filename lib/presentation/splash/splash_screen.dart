import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/culture/core/theme/culture_theme.dart';
import '../../features/profile/user_prefs_notifier.dart';

/// Les 3 segments SVG vectoriels officiels d'AlterniA issus de `assets/icons/icone_svg.svg`
/// Partageant tous le même viewBox "0 0 4529.98 4458.18" pour un assemblage au millimètre près.
const String _kOrangePieceSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 4529.98 4458.18">
  <path d="M4528.48,3915.53c-1.54.9-3.08,1.77-4.61,2.64-34.6-825.6-515.39-1536.78-1209.19-1901.93-317.5-167.12-679.62-261.78-1064-261.78-362.91,0-705.96,84.37-1010.37,234.44-1.19-30.29-1.81-60.73-1.81-91.32,0-792.97,408.49-1490.87,1027.23-1896.12,104.44,63.94,208.11,134.08,310.46,210.21,393.62,292.77,767.53,673.93,1088.58,1130.26,598.18,850.19,888.87,1784.99,863.71,2573.6Z" fill="#f1851f"/>
</svg>
''';

const String _kTurquoisePieceSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 4529.98 4458.18">
  <path d="M4523.86,3918.17c-43.29,24.81-87.59,48.88-132.85,72.19-609.08,313.78-1391.95,490.76-2240.82,465.42-712.48-21.26-1370.03-182.01-1911.36-439.8,251.52,96.27,524.55,148.99,809.84,148.99,453.46,0,875.85-133.19,1230.29-362.65,592.79-383.72,995.53-1036.66,1035.7-1786.07,693.8,365.15,1174.59,1076.33,1209.19,1901.93Z" fill="#40bbcc"/>
</svg>
''';

const String _kBluePieceSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 4529.98 4458.18">
  <path d="M2278.97,3802.32c-354.44,229.46-776.83,362.65-1230.29,362.65-285.29,0-558.31-52.72-809.84-148.99-82.38-39.22-162.07-80.69-238.84-124.25,6.06-130.64,18.06-263.65,36.12-398.38,51.27-382.47,151.38-778.84,303.44-1174.18C764.11,1215.53,1494.63,377.31,2263.32,0c.8.47,1.59.98,2.41,1.47-618.74,405.25-1027.23,1103.15-1027.23,1896.12,0,30.58.62,61.02,1.81,91.32,30.24,760.63,436.51,1424.94,1038.67,1813.42Z" fill="#314999"/>
</svg>
''';

/// Écran d'accueil cinématique au lancement (~4.6s) 100% RESPONSIVE :
/// - Adapté à toutes les résolutions d'écran (petits téléphones, grands écrans, tablettes, orientation paysage).
/// - Zéro dépassement de pixels (protection overflow totale).
/// - Dès le départ : les 3 morceaux sont DÉJÀ DÉTACHÉS et flottent dans l'espace.
/// - Rassemblement un par un avec trajectoires courbées, vibrations haptiques synchronisées et ondes d'impact.
/// - Révélation élégante : "AlterniA" + "Alternative pour apprendre l'essentiel".
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasTriggeredBlue = false;
  bool _hasTriggeredOrange = false;
  bool _hasTriggeredTurquoise = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    );

    _controller.addListener(_onAnimationTick);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  void _onAnimationTick() {
    final t = _controller.value;

    // Déclenchements haptiques calibrés aux impacts de chaque morceau
    if (t >= 0.44 && !_hasTriggeredBlue) {
      _hasTriggeredBlue = true;
      HapticFeedback.lightImpact();
    }
    if (t >= 0.66 && !_hasTriggeredOrange) {
      _hasTriggeredOrange = true;
      HapticFeedback.lightImpact();
    }
    if (t >= 0.86 && !_hasTriggeredTurquoise) {
      _hasTriggeredTurquoise = true;
      HapticFeedback.heavyImpact();
    }
  }

  void _navigateToNextScreen() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final userPrefs = ref.read(userPrefsProvider);
    if (!userPrefs.hasCompletedOnboarding) {
      context.go('/onboarding');
    } else {
      context.go('/gateway');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onAnimationTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A11),
      body: GestureDetector(
        onTap: _navigateToNextScreen, // Permet de passer immédiatement d'un tap
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final availableWidth = constraints.maxWidth;
              final shortestSide = math.min(availableWidth, availableHeight);

              // ── Calculs dynamiques d'échelle responsive ────────────────────
              final isCompactHeight = availableHeight < 620;
              final isUltraCompact = availableHeight < 500;

              // Taille adaptative du badge blanc et du logo interne
              final double badgeSize;
              if (isUltraCompact) {
                badgeSize = 90.0;
              } else if (isCompactHeight) {
                badgeSize = (availableHeight * 0.22).clamp(95.0, 125.0);
              } else {
                badgeSize = (shortestSide * 0.36).clamp(120.0, 152.0);
              }

              final logoSize = badgeSize * 0.58;
              final scaleFactor = logoSize / 88.0;
              final spacing = isUltraCompact ? 10.0 : (isCompactHeight ? 18.0 : 30.0);
              final borderRadius = badgeSize * 0.25;

              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.value;

                  // ── 1. Apparition du badge (0.0 -> 0.16) ───────────────────
                  final badgeScale = Curves.easeOutBack.transform(
                    (t / 0.16).clamp(0.0, 1.0),
                  );
                  final badgeOpacity = (t / 0.10).clamp(0.0, 1.0);

                  // ── 2. Calcul des transformations (DÉJÀ DÉTACHÉS DÈS t=0) ───
                  // Morceau 1 : BLEU ROYAL (Gauche) -> s'assemble entre 0.22 et 0.44
                  final blue = _computePieceArc(
                    t: t,
                    assembleStart: 0.22,
                    assembleEnd: 0.44,
                    initialOffset: Offset(-68 * scaleFactor, 20 * scaleFactor),
                    initialRotation: 0.28,
                    initialScale: 1.12,
                    arcCurvature: Offset(-18 * scaleFactor, -22 * scaleFactor),
                  );

                  // Morceau 2 : ORANGE VIF (Haut-Droit) -> s'assemble entre 0.44 et 0.66
                  final orange = _computePieceArc(
                    t: t,
                    assembleStart: 0.44,
                    assembleEnd: 0.66,
                    initialOffset: Offset(58 * scaleFactor, -54 * scaleFactor),
                    initialRotation: -0.32,
                    initialScale: 1.12,
                    arcCurvature: Offset(26 * scaleFactor, -15 * scaleFactor),
                  );

                  // Morceau 3 : TURQUOISE (Bas-Droit) -> s'assemble entre 0.66 et 0.86
                  final turquoise = _computePieceArc(
                    t: t,
                    assembleStart: 0.66,
                    assembleEnd: 0.86,
                    initialOffset: Offset(44 * scaleFactor, 62 * scaleFactor),
                    initialRotation: 0.35,
                    initialScale: 1.12,
                    arcCurvature: Offset(18 * scaleFactor, 26 * scaleFactor),
                  );

                  // ── 3. Ondes d'impact concentriques à la taille du badge ────
                  final blueRipple = _computeRippleProgress(t, start: 0.44, duration: 0.12);
                  final orangeRipple = _computeRippleProgress(t, start: 0.66, duration: 0.12);
                  final turquoiseRipple = _computeRippleProgress(t, start: 0.86, duration: 0.14);

                  // ── 4. Rebond d'impact à l'assemblage final (0.86 -> 0.96) ─
                  double grandPulse = 1.0;
                  if (t >= 0.86 && t <= 0.97) {
                    final pulseP = (t - 0.86) / 0.11;
                    grandPulse = 1.0 + 0.08 * math.sin(pulseP * math.pi);
                  }

                  // ── 5. Révélation progressive du nom & slogan (0.78 -> 0.94)
                  final textProgress = ((t - 0.78) / 0.16).clamp(0.0, 1.0);
                  final textOpacity = Curves.easeOutCubic.transform(textProgress);
                  final textSlide = (1.0 - Curves.easeOutBack.transform(textProgress)) * 18;

                  // ── 6. Fondu de sortie global vers l'application (0.96 -> 1.0)
                  final globalOpacity = t > 0.96
                      ? (1.0 - (t - 0.96) / 0.04).clamp(0.0, 1.0)
                      : 1.0;

                  return Opacity(
                    opacity: globalOpacity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // ── Fond dégradé radial subtil ───────────────────────
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.3,
                                colors: [
                                  Color(0xFF131D31),
                                  Color(0xFF070A11),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ── Auras lumineuses positionnées de façon 100% responsive
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Stack(
                              children: [
                                // Aura Orange (Haut / Droite)
                                Align(
                                  alignment: const Alignment(0.65, -0.45),
                                  child: Opacity(
                                    opacity: (0.4 + 0.3 * math.sin(t * math.pi * 3))
                                        .clamp(0.0, 1.0),
                                    child: Container(
                                      width: shortestSide * 0.45,
                                      height: shortestSide * 0.45,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CultureTheme.accentOrange
                                            .withValues(alpha: 0.15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: CultureTheme.accentOrange
                                                .withValues(alpha: 0.22),
                                            blurRadius: 80,
                                            spreadRadius: 25,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Aura Bleu Royal (Gauche)
                                Align(
                                  alignment: const Alignment(-0.65, 0.05),
                                  child: Opacity(
                                    opacity: (0.4 + 0.3 * math.cos(t * math.pi * 3))
                                        .clamp(0.0, 1.0),
                                    child: Container(
                                      width: shortestSide * 0.45,
                                      height: shortestSide * 0.45,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF314999)
                                            .withValues(alpha: 0.15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF314999)
                                                .withValues(alpha: 0.22),
                                            blurRadius: 80,
                                            spreadRadius: 25,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Aura Turquoise (Bas / Droite)
                                Align(
                                  alignment: const Alignment(0.55, 0.48),
                                  child: Opacity(
                                    opacity: (0.4 + 0.3 * math.sin((t + 0.5) * math.pi * 3))
                                        .clamp(0.0, 1.0),
                                    child: Container(
                                      width: shortestSide * 0.42,
                                      height: shortestSide * 0.42,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CultureTheme.cyanTurquoise
                                            .withValues(alpha: 0.12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: CultureTheme.cyanTurquoise
                                                .withValues(alpha: 0.20),
                                            blurRadius: 75,
                                            spreadRadius: 20,
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

                        // ── CONTENU CENTRAL SCROLL-SAFE ET CENTRÉ ─────────────
                        Center(
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // ── BADGE BLANC AVEC ONDES CONCENTRIQUES ET PIÈCES ──
                                  Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Onde d'impact Bleu
                                      if (blueRipple > 0)
                                        _buildCenteredRipple(
                                          radius: (badgeSize * 0.5) + blueRipple * 50 * scaleFactor,
                                          color: const Color(0xFF314999),
                                          opacity: (1.0 - blueRipple) * 0.75,
                                        ),

                                      // Onde d'impact Orange
                                      if (orangeRipple > 0)
                                        _buildCenteredRipple(
                                          radius: (badgeSize * 0.5) + orangeRipple * 65 * scaleFactor,
                                          color: const Color(0xFFF1851F),
                                          opacity: (1.0 - orangeRipple) * 0.8,
                                        ),

                                      // Onde d'impact Turquoise (finale)
                                      if (turquoiseRipple > 0)
                                        _buildCenteredRipple(
                                          radius: (badgeSize * 0.5) + turquoiseRipple * 85 * scaleFactor,
                                          color: const Color(0xFF40BBCC),
                                          opacity: (1.0 - turquoiseRipple) * 0.9,
                                        ),

                                      // Le badge blanc conteneur
                                      Transform.scale(
                                        scale: badgeScale * grandPulse,
                                        child: Opacity(
                                          opacity: badgeOpacity,
                                          child: Container(
                                            width: badgeSize,
                                            height: badgeSize,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(borderRadius),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.45),
                                                  blurRadius: 30,
                                                  offset: const Offset(0, 12),
                                                ),
                                                BoxShadow(
                                                  color: CultureTheme.accentOrange
                                                      .withValues(alpha: 0.22),
                                                  blurRadius: 35,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            clipBehavior: Clip.none,
                                            child: Center(
                                              child: SizedBox(
                                                width: logoSize,
                                                height: logoSize,
                                                child: Stack(
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    // 1. Morceau BLEU ROYAL (Gauche)
                                                    _buildPiece(
                                                      svgString: _kBluePieceSvg,
                                                      transform: blue,
                                                      size: logoSize,
                                                    ),

                                                    // 2. Morceau ORANGE (Haut / Droite)
                                                    _buildPiece(
                                                      svgString: _kOrangePieceSvg,
                                                      transform: orange,
                                                      size: logoSize,
                                                    ),

                                                    // 3. Morceau TURQUOISE (Bas / Droite)
                                                    _buildPiece(
                                                      svgString: _kTurquoisePieceSvg,
                                                      transform: turquoise,
                                                      size: logoSize,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: spacing),

                                  // ── TEXTE RÉVÉLÉ : "AlterniA" + Slogan Responsive
                                  Transform.translate(
                                    offset: Offset(0, textSlide),
                                    child: Opacity(
                                      opacity: textOpacity,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: RichText(
                                              text: TextSpan(
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: isCompactHeight ? 26 : 32,
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
                                          ),
                                          const SizedBox(height: 8),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'Alternative pour apprendre l\'essentiel',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: isCompactHeight ? 12 : 13.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF94A3B8),
                                                  letterSpacing: 0.3,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: spacing * 0.9),

                                  // Signature MALI 2026 intégrée au flux (zéro collision)
                                  Opacity(
                                    opacity: (t / 0.4).clamp(0.0, 0.4),
                                    child: Text(
                                      'MALI • 2026',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2.0,
                                        color: Colors.white.withValues(alpha: 0.4),
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
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  /// Calcule la trajectoire incurvée et l'oscillation d'un morceau
  /// DÈS t=0 : le morceau est DÉJÀ DÉTACHÉ et lévite dans l'espace.
  /// Puis à assembleStart, il entame un vol en arc de cercle vers (0, 0).
  _PieceTransform _computePieceArc({
    required double t,
    required double assembleStart,
    required double assembleEnd,
    required Offset initialOffset,
    required double initialRotation,
    required double initialScale,
    required Offset arcCurvature,
  }) {
    // Phase 1 : AVANT L'ASSEMBLAGE -> LE MORCEAU FLOTTE DÉJÀ AU LOIN DANS L'ESPACE
    if (t < assembleStart) {
      final floatTime = t * 14.0;
      final floatX = math.sin(floatTime) * 2.5;
      final floatY = math.cos(floatTime * 0.85) * 2.5;
      final rotWobble = math.sin(floatTime * 0.7) * 0.035;

      return _PieceTransform(
        offset: Offset(initialOffset.dx + floatX, initialOffset.dy + floatY),
        rotation: initialRotation + rotWobble,
        scale: initialScale,
      );
    }

    // Phase 2 : VOL DE RASSEMBLEMENT EN ARC DE CERCLE ("UNE PAR UNE")
    if (t >= assembleStart && t < assembleEnd) {
      final progress = ((t - assembleStart) / (assembleEnd - assembleStart))
          .clamp(0.0, 1.0);

      final p = Curves.easeOutBack.transform(progress);
      final remaining = 1.0 - p;

      // Arc de déviation parabolique pour une trajectoire dynamique
      final arcFactor = math.sin(progress * math.pi);
      final arcX = arcCurvature.dx * arcFactor;
      final arcY = arcCurvature.dy * arcFactor;

      final currentOffset = Offset(
        initialOffset.dx * remaining + arcX,
        initialOffset.dy * remaining + arcY,
      );

      final currentRotation = initialRotation * remaining;
      final currentScale = 1.0 + (initialScale - 1.0) * remaining;

      return _PieceTransform(
        offset: currentOffset,
        rotation: currentRotation,
        scale: currentScale,
      );
    }

    // Phase 3 : ASSEMBLÉ ET VERROUILLÉ EN POSITION OFFICIELLE (0, 0)
    return const _PieceTransform(
      offset: Offset.zero,
      rotation: 0.0,
      scale: 1.0,
    );
  }

  /// Calcule l'onde de choc circulaire lors de l'impact
  double _computeRippleProgress(double t,
      {required double start, required double duration}) {
    if (t < start || t > (start + duration)) return 0.0;
    return ((t - start) / duration).clamp(0.0, 1.0);
  }

  /// Affiche l'onde de choc directement centrée autour du badge
  Widget _buildCenteredRipple({
    required double radius,
    required Color color,
    required double opacity,
  }) {
    return IgnorePointer(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
            width: 2.2,
          ),
        ),
      ),
    );
  }

  /// Rend un morceau vectoriel officiel avec sa transformation spatiale
  Widget _buildPiece({
    required String svgString,
    required _PieceTransform transform,
    required double size,
  }) {
    return Transform.translate(
      offset: transform.offset,
      child: Transform.rotate(
        angle: transform.rotation,
        child: Transform.scale(
          scale: transform.scale,
          child: SvgPicture.string(
            svgString,
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class _PieceTransform {
  final Offset offset;
  final double rotation;
  final double scale;

  const _PieceTransform({
    required this.offset,
    required this.rotation,
    required this.scale,
  });
}
