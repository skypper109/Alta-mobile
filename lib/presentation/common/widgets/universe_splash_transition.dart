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
/// qui se rassemblent dans l'espace avec ondes d'impact haptiques et lueur de l'univers cible.
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
  bool _hasTriggeredBlue = false;
  bool _hasTriggeredOrange = false;
  bool _hasTriggeredTurquoise = false;
  bool _hasTriggeredFinish = false;

  @override
  void initState() {
    super.initState();
    // Durée calibrée pour un ressenti dynamique et cinématographique (~1800ms)
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

    // Vibrations haptiques synchronisées aux jonctions des pièces
    if (t >= 0.40 && !_hasTriggeredBlue) {
      _hasTriggeredBlue = true;
      HapticFeedback.lightImpact();
    }
    if (t >= 0.62 && !_hasTriggeredOrange) {
      _hasTriggeredOrange = true;
      HapticFeedback.lightImpact();
    }
    if (t >= 0.82 && !_hasTriggeredTurquoise) {
      _hasTriggeredTurquoise = true;
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

    final badgeLabel = isToCulture
        ? 'PATRIMOINE VIVANT & MÉMOIRE'
        : 'SAVOIR & INNOVATION IA';

    final title = isToCulture ? 'UNIVERS CULTURE' : 'UNIVERS ÉDUCATION';

    final subtitle = isToCulture
        ? 'Contes du Baobab, récits des sages et trésors millénaires'
        : 'Tuteur IA interactif, méthodologie et fiches d\'excellence';

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

          // ── Animation du rassemblement du logo et du contenu ──────────────
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
              const badgeSize = 110.0;
              const logoSize = 78.0;

              // Apparition du badge blanc (0.0 -> 0.20)
              final badgeScale = Curves.easeOutBack.transform(
                (t / 0.22).clamp(0.0, 1.0),
              );

              // ── Transformations des 3 segments qui se rassemblent ─────────
              // 1. BLEU ROYAL (Gauche) -> s'assemble entre 0.18 et 0.42
              final blue = _computePieceArc(
                t: t,
                assembleStart: 0.18,
                assembleEnd: 0.42,
                initialOffset: const Offset(-55, 16),
                initialRotation: 0.24,
                initialScale: 1.15,
                arcCurvature: const Offset(-15, -18),
              );

              // 2. ORANGE (Haut / Droit) -> s'assemble entre 0.42 et 0.64
              final orange = _computePieceArc(
                t: t,
                assembleStart: 0.42,
                assembleEnd: 0.64,
                initialOffset: const Offset(48, -45),
                initialRotation: -0.28,
                initialScale: 1.15,
                arcCurvature: const Offset(20, -12),
              );

              // 3. TURQUOISE (Bas / Droit) -> s'assemble entre 0.64 et 0.82
              final turquoise = _computePieceArc(
                t: t,
                assembleStart: 0.64,
                assembleEnd: 0.82,
                initialOffset: const Offset(38, 52),
                initialRotation: 0.30,
                initialScale: 1.15,
                arcCurvature: const Offset(14, 20),
              );

              // Ondes d'impact lumineuses
              final blueRipple = _computeRippleProgress(t, start: 0.42, duration: 0.16);
              final orangeRipple = _computeRippleProgress(t, start: 0.64, duration: 0.16);
              final turquoiseRipple = _computeRippleProgress(t, start: 0.82, duration: 0.18);

              // Rebond d'impact final (0.82 -> 0.94)
              double grandPulse = 1.0;
              if (t >= 0.82 && t <= 0.94) {
                final pulseP = (t - 0.82) / 0.12;
                grandPulse = 1.0 + 0.08 * math.sin(pulseP * math.pi);
              }

              // Révélation du texte (0.70 -> 0.90)
              final textProgress = ((t - 0.70) / 0.20).clamp(0.0, 1.0);
              final textOpacity = Curves.easeOutCubic.transform(textProgress);
              final textSlide = (1.0 - Curves.easeOutBack.transform(textProgress)) * 14;

              return Opacity(
                opacity: globalOpacity,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── LOGO ALTERNIA QUI SE RASSEMBLE DANS LE BADGE ─────
                        Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Onde d'impact Bleu
                            if (blueRipple > 0)
                              _buildCenteredRipple(
                                radius: (badgeSize * 0.5) + blueRipple * 40,
                                color: const Color(0xFF314999),
                                opacity: (1.0 - blueRipple) * 0.8,
                              ),

                            // Onde d'impact Orange
                            if (orangeRipple > 0)
                              _buildCenteredRipple(
                                radius: (badgeSize * 0.5) + orangeRipple * 50,
                                color: const Color(0xFFF1851F),
                                opacity: (1.0 - orangeRipple) * 0.85,
                              ),

                            // Onde d'impact Turquoise finale (ou couleur de l'univers)
                            if (turquoiseRipple > 0)
                              _buildCenteredRipple(
                                radius: (badgeSize * 0.5) + turquoiseRipple * 65,
                                color: primaryAccent,
                                opacity: (1.0 - turquoiseRipple) * 0.9,
                              ),

                            // Le badge conteneur blanc lustré avec ombre 3D
                            Transform.scale(
                              scale: badgeScale * grandPulse,
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
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // ── TEXTES DE L'UNIVERS CIBLE ────────────────────────
                        Transform.translate(
                          offset: Offset(0, textSlide),
                          child: Opacity(
                            opacity: textOpacity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Badge Univers
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF070B14)
                                        .withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: primaryAccent.withValues(alpha: 0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: primaryAccent,
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryAccent.withValues(alpha: 0.8),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Text(
                                        badgeLabel,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: primaryAccent,
                                          letterSpacing: 0.9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Titre
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                // Sous-titre
                                Text(
                                  subtitle,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFCBD5E1),
                                    height: 1.4,
                                  ),
                                ),
                              ],
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
      final progress = ((t - assembleStart) / (assembleEnd - assembleStart))
          .clamp(0.0, 1.0);

      final p = Curves.easeOutBack.transform(progress);
      final remaining = 1.0 - p;

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

    return const _PieceTransform(
      offset: Offset.zero,
      rotation: 0.0,
      scale: 1.0,
    );
  }

  double _computeRippleProgress(double t,
      {required double start, required double duration}) {
    if (t < start || t > (start + duration)) return 0.0;
    return ((t - start) / duration).clamp(0.0, 1.0);
  }

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
            width: 2.0,
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
