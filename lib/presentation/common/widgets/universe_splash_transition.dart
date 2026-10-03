library;

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

/// Les 3 segments SVG vectoriels officiels d'AlterniA issus de `assets/icons/icone_svg.svg`
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

enum UniverseDestination {
  culture,
  education,
}

/// Transition cinématique inter-univers de rang mondial.
/// Utilise l'animation dynamique des 3 morceaux vectoriels du logo AlterniA
/// qui se rassemblent dans l'espace avec ondes d'impact haptiques et révélation
/// épurée du titre de l'univers ("UNIVERS CULTURE" ou "UNIVERS ÉDUCATION").
class UniverseSplashTransition {
  static void toCulture(
    BuildContext context, {
    required VoidCallback onComplete,
  }) {
    _showTransition(
      context,
      destination: UniverseDestination.culture,
      onComplete: onComplete,
    );
  }

  static void toEducation(
    BuildContext context, {
    required VoidCallback onComplete,
  }) {
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
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (dialogContext, anim1, anim2) {
        return _UniverseLogoAssemblyView(
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

class _UniverseLogoAssemblyView extends StatefulWidget {
  const _UniverseLogoAssemblyView({
    required this.destination,
    required this.onFinish,
  });

  final UniverseDestination destination;
  final VoidCallback onFinish;

  @override
  State<_UniverseLogoAssemblyView> createState() =>
      _UniverseLogoAssemblyViewState();
}

class _UniverseLogoAssemblyViewState extends State<_UniverseLogoAssemblyView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasTriggeredApproachHaptic = false;
  bool _hasTriggeredSnapImpact = false;
  bool _hasTriggeredFinish = false;

  @override
  void initState() {
    super.initState();
    // Durée calibrée pour un ressenti dynamique et cinématographique (~1850ms)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1850),
    );

    _controller.addListener(_onTick);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_hasTriggeredFinish) {
        _hasTriggeredFinish = true;
        widget.onFinish();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  void _onTick() {
    final t = _controller.value;

    if (t >= 0.25 && !_hasTriggeredApproachHaptic) {
      _hasTriggeredApproachHaptic = true;
      HapticFeedback.selectionClick();
    }

    if (t >= 0.56 && !_hasTriggeredSnapImpact) {
      _hasTriggeredSnapImpact = true;
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isToCulture = widget.destination == UniverseDestination.culture;

    // Couleurs d'ambiance et accents
    final bgColors = isToCulture
        ? const [
            Color(0xFF070B14),
            Color(0xFF261205),
            Color(0xFF451A03),
            Color(0xFF0B111E),
          ]
        : const [
            Color(0xFF070B14),
            Color(0xFF0B1A3A),
            Color(0xFF142C5E),
            Color(0xFF070B14),
          ];

    final primaryAccent =
        isToCulture ? AppColors.accent : AppColors.secondary;

    // Titre épuré et percutant (seul texte conservé selon la demande)
    final title = isToCulture ? 'UNIVERS CULTURE' : 'UNIVERS ÉDUCATION';

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Fond flouté & dégradé cosmique ────────────────────────────────
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: bgColors,
                ),
              ),
            ),
          ),

          // ── Animation du rassemblement du logo et du titre ────────────────
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;

              // Fondu global d'entrée (0.0 -> 0.15) et sortie (0.92 -> 1.0)
              final inOpacity = (t / 0.15).clamp(0.0, 1.0);
              final outOpacity = t > 0.92
                  ? (1.0 - (t - 0.92) / 0.08).clamp(0.0, 1.0)
                  : 1.0;
              final globalOpacity = inOpacity * outOpacity;

              // Constantes de taille
              const badgeSize = 112.0;
              const logoSize = 80.0;

              // ── Épanouissement du badge blanc uniquement à l'assemblage ────
              final badgeProgress = ((t - 0.50) / 0.16).clamp(0.0, 1.0);
              final badgeScale = Curves.easeOutBack.transform(badgeProgress);
              final badgeOpacity = Curves.easeOutCubic.transform(badgeProgress);

              // ── Transformations des 3 segments qui se rassemblent ─────────
              // 1. BLEU ROYAL (Gauche)
              final blue = _computePieceArc(
                t: t,
                assembleStart: 0.10,
                assembleEnd: 0.54,
                initialOffset: const Offset(-75, 22),
                initialRotation: 0.28,
                initialScale: 1.20,
                arcCurvature: const Offset(-18, -22),
              );

              // 2. ORANGE SOLAIRE (Haut / Droit)
              final orange = _computePieceArc(
                t: t,
                assembleStart: 0.10,
                assembleEnd: 0.56,
                initialOffset: const Offset(68, -60),
                initialRotation: -0.32,
                initialScale: 1.20,
                arcCurvature: const Offset(24, -16),
              );

              // 3. TURQUOISE LUMINEUX (Bas / Droit)
              final turquoise = _computePieceArc(
                t: t,
                assembleStart: 0.10,
                assembleEnd: 0.58,
                initialOffset: const Offset(52, 70),
                initialRotation: 0.35,
                initialScale: 1.20,
                arcCurvature: const Offset(18, 25),
              );

              // Ondes d'impact lumineuses
              final impactProgress = ((t - 0.56) / 0.22).clamp(0.0, 1.0);
              final impactOpacity = (1.0 - impactProgress) * 0.9;
              final shockwaveRadius = (badgeSize * 0.5) + impactProgress * 65;

              // Rebond d'impact final (0.56 -> 0.72)
              double grandPulse = 1.0;
              if (t >= 0.56 && t <= 0.72) {
                final pulseP = (t - 0.56) / 0.16;
                grandPulse = 1.0 + 0.10 * math.sin(pulseP * math.pi);
              }

              // Révélation du Titre (0.60 -> 0.82)
              final textProgress = ((t - 0.60) / 0.18).clamp(0.0, 1.0);
              final textOpacity = Curves.easeOutCubic.transform(textProgress);
              final textSlide = (1.0 - Curves.easeOutBack.transform(textProgress)) * 16;

              return Opacity(
                opacity: globalOpacity,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── LOGO ALTERNIA QUI SE RASSEMBLE ET BADGE ───────────
                        SizedBox(
                          width: badgeSize * 1.6,
                          height: badgeSize * 1.6,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              // Ondes de choc photoniques à l'impact
                              if (t >= 0.56 && impactProgress < 1.0)
                                _buildCenteredRipple(
                                  radius: shockwaveRadius,
                                  color: Colors.white,
                                  opacity: impactOpacity * 0.85,
                                  borderWidth: 2.5,
                                ),

                              if (t >= 0.58 && impactProgress < 1.0)
                                _buildCenteredRipple(
                                  radius: shockwaveRadius * 0.82,
                                  color: primaryAccent,
                                  opacity: impactOpacity * 0.9,
                                  borderWidth: 2.0,
                                ),

                              // Le badge conteneur blanc lustré qui s'épanouit au snap
                              if (badgeProgress > 0)
                                Transform.scale(
                                  scale: badgeScale * grandPulse,
                                  child: Opacity(
                                    opacity: badgeOpacity,
                                    child: Container(
                                      width: badgeSize,
                                      height: badgeSize,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(28),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.45),
                                            blurRadius: 32,
                                            offset: const Offset(0, 12),
                                          ),
                                          BoxShadow(
                                            color: primaryAccent.withValues(alpha: 0.35),
                                            blurRadius: 40,
                                            spreadRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              // ── Les 3 pièces vectorielles qui s'assemblent ──
                              Transform.scale(
                                scale: grandPulse,
                                child: SizedBox(
                                  width: logoSize,
                                  height: logoSize,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      // 1. Morceau BLEU ROYAL (Gauche)
                                      _buildPiece(
                                        svgString: _kBluePieceSvg,
                                        transform: blue,
                                        size: logoSize,
                                      ),

                                      // 2. Morceau ORANGE (Haut / Droit)
                                      _buildPiece(
                                        svgString: _kOrangePieceSvg,
                                        transform: orange,
                                        size: logoSize,
                                      ),

                                      // 3. Morceau TURQUOISE (Bas / Droit)
                                      _buildPiece(
                                        svgString: _kTurquoisePieceSvg,
                                        transform: turquoise,
                                        size: logoSize,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── TITRE ÉPURÉ DE L'UNIVERS (Seul texte conservé) ───
                        Transform.translate(
                          offset: Offset(0, textSlide),
                          child: Opacity(
                            opacity: textOpacity,
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: primaryAccent.withValues(alpha: 0.7),
                                    blurRadius: 20,
                                    offset: const Offset(0, 3),
                                  ),
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
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
          ),
        ],
      ),
    );
  }

  /// Calcule la trajectoire incurvée d'une pièce
  _PieceTransform _computePieceArc({
    required double t,
    required double assembleStart,
    required double assembleEnd,
    required Offset initialOffset,
    required double initialRotation,
    required double initialScale,
    required Offset arcCurvature,
  }) {
    if (t < assembleStart) {
      final floatTime = t * 16.0;
      final floatX = math.sin(floatTime) * 2.0;
      final floatY = math.cos(floatTime * 0.9) * 2.0;
      final rotWobble = math.sin(floatTime * 0.7) * 0.025;

      return _PieceTransform(
        offset: Offset(initialOffset.dx + floatX, initialOffset.dy + floatY),
        rotation: initialRotation + rotWobble,
        scale: initialScale,
      );
    }

    if (t >= assembleStart && t < assembleEnd) {
      final rawProgress = ((t - assembleStart) / (assembleEnd - assembleStart))
          .clamp(0.0, 1.0);

      final progress = Curves.easeInOutCubic.transform(rawProgress);
      final remaining = 1.0 - progress;

      final arcFactor = math.sin(rawProgress * math.pi);
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

    return const _PieceTransform(
      offset: Offset.zero,
      rotation: 0.0,
      scale: 1.0,
    );
  }

  Widget _buildCenteredRipple({
    required double radius,
    required Color color,
    required double opacity,
    required double borderWidth,
  }) {
    return IgnorePointer(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: opacity.clamp(0.0, 1.0)),
            width: borderWidth,
          ),
        ),
      ),
    );
  }

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
