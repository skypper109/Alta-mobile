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

/// Écran d'accueil cinématique au lancement (~2.6s) :
/// - DÈS LE PREMIER MILLISECONDE : Les 3 pièces du logo s'affichent DÉTACHÉES dans l'espace cosmic.
///   (Aucun bloc statique, aucun badge blanc initial, aucun retard).
/// - Convergence magnétique avec trajectoires paraboliques en arc et auras lumineuses.
/// - Snap de fusion au millimètre près avec retour haptique puissant et onde de choc photonique.
/// - Le badge blanc s'épanouit au moment exact de l'impact sous le logo unifié.
/// - Balayage de brillance spéculaire sur le logo assemblé.
/// - Révélation de la marque : "AlterniA" + Slogan officiel.
/// - 100% Responsive et scroll-safe sur tous les téléphones et tablettes.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasTriggeredSnapImpact = false;
  bool _hasTriggeredApproachHaptic = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
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

    // Déclenchement haptique léger quand les pièces amorcent leur accélération magnétique
    if (t >= 0.28 && !_hasTriggeredApproachHaptic) {
      _hasTriggeredApproachHaptic = true;
      HapticFeedback.selectionClick();
    }

    // Déclenchement haptique puissant au moment précis de l'assemblage (t = 0.58)
    if (t >= 0.58 && !_hasTriggeredSnapImpact) {
      _hasTriggeredSnapImpact = true;
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
        onTap: _navigateToNextScreen, // Tap pour passer immédiatement
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final availableWidth = constraints.maxWidth;
              final shortestSide = math.min(availableWidth, availableHeight);

              // ── Calculs d'échelle responsive ───────────────────────────────
              final isCompactHeight = availableHeight < 620;
              final isUltraCompact = availableHeight < 500;

              final double badgeSize;
              if (isUltraCompact) {
                badgeSize = 92.0;
              } else if (isCompactHeight) {
                badgeSize = (availableHeight * 0.22).clamp(95.0, 125.0);
              } else {
                badgeSize = (shortestSide * 0.36).clamp(120.0, 150.0);
              }

              final logoSize = badgeSize * 0.60;
              final scaleFactor = logoSize / 85.0;
              final spacing = isUltraCompact ? 12.0 : (isCompactHeight ? 20.0 : 32.0);
              final borderRadius = badgeSize * 0.26;

              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.value;

                  // ── 1. TRANSFORMATION DES PIÈCES DÉTACHÉES DÈS t = 0 ────────
                  // DÈS LE LANCEMENT (t=0) : les 3 pièces sont LARGEMENT DÉTACHÉES dans l'espace.
                  // À t = 0.10, la force magnétique s'active et les attire en arc vers le centre.
                  // À t = 0.58, elles se verrouillent avec une précision chirurgicale à (0,0).

                  // Pièce 1 : BLEU ROYAL (Éducation / Savoir) - vient de la gauche
                  final blue = _computeDetachedPieceArc(
                    t: t,
                    startDelay: 0.10,
                    lockTime: 0.56,
                    initialOffset: Offset(-115 * scaleFactor, 32 * scaleFactor),
                    initialRotation: 0.28,
                    initialScale: 1.25,
                    arcCurvature: Offset(-24 * scaleFactor, -30 * scaleFactor),
                  );

                  // Pièce 2 : ORANGE SOLAIRE (Culture / Héritage) - vient du haut droit
                  final orange = _computeDetachedPieceArc(
                    t: t,
                    startDelay: 0.10,
                    lockTime: 0.58,
                    initialOffset: Offset(105 * scaleFactor, -90 * scaleFactor),
                    initialRotation: -0.34,
                    initialScale: 1.25,
                    arcCurvature: Offset(32 * scaleFactor, -20 * scaleFactor),
                  );

                  // Pièce 3 : TURQUOISE LUMINEUX (Innovation / IA) - vient du bas droit
                  final turquoise = _computeDetachedPieceArc(
                    t: t,
                    startDelay: 0.10,
                    lockTime: 0.60,
                    initialOffset: Offset(80 * scaleFactor, 105 * scaleFactor),
                    initialRotation: 0.36,
                    initialScale: 1.25,
                    arcCurvature: Offset(22 * scaleFactor, 32 * scaleFactor),
                  );

                  // ── 2. ÉPANOOUISSEMENT DU BADGE BLANC AU MOMENT DU VERROUILLAGE ─
                  // Le badge blanc NE S'AFFICHE PAS au départ !
                  // Il n'apparaît qu'au moment précis où les morceaux fusionnent (t = 0.54 -> 0.68)
                  final badgeProgress = ((t - 0.54) / 0.14).clamp(0.0, 1.0);
                  final badgeScale = Curves.easeOutBack.transform(badgeProgress);
                  final badgeOpacity = Curves.easeOutCubic.transform(badgeProgress);

                  // ── 3. REBOND ÉLASTIQUE DU LOGO COMPLET (0.58 -> 0.72) ──────
                  double grandPulse = 1.0;
                  if (t >= 0.58 && t <= 0.74) {
                    final pulseP = (t - 0.58) / 0.16;
                    grandPulse = 1.0 + 0.12 * math.sin(pulseP * math.pi);
                  }

                  // ── 4. BALAYAGE LUMINEUX SPÉCULAIRE (0.66 -> 0.82) ──────────
                  final sheenProgress = ((t - 0.66) / 0.16).clamp(0.0, 1.0);

                  // ── 5. ONDES DE CHOC QUANTIQUE D'IMPACT (0.58 -> 0.78) ──────
                  final impactProgress = ((t - 0.58) / 0.18).clamp(0.0, 1.0);
                  final flashOpacity = (1.0 - impactProgress) * 0.9;
                  final shockwaveRadius = (badgeSize * 0.5) + impactProgress * 90 * scaleFactor;

                  // ── 6. RÉVÉLATION DU TEXTE "AlterniA" (0.64 -> 0.86) ────────
                  final textProgress = ((t - 0.64) / 0.18).clamp(0.0, 1.0);
                  final textOpacity = Curves.easeOutCubic.transform(textProgress);
                  final textSlide = (1.0 - Curves.easeOutBack.transform(textProgress)) * 20;

                  // ── 7. FONDU DE SORTIE VERS L'ONBOARDING (0.95 -> 1.0) ──────
                  final globalOpacity = t > 0.95
                      ? (1.0 - (t - 0.95) / 0.05).clamp(0.0, 1.0)
                      : 1.0;

                  return Opacity(
                    opacity: globalOpacity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // ── Fond Cosmique Dégradé Radial Profond ─────────────
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment.center,
                                radius: 1.35,
                                colors: [
                                  Color(0xFF131D31),
                                  Color(0xFF070A11),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ── Auras Lumineuses Flottantes Dynamiques ───────────
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Stack(
                              children: [
                                // Halo Orange Solaire (Haut / Droite)
                                Align(
                                  alignment: const Alignment(0.65, -0.45),
                                  child: Opacity(
                                    opacity: (0.35 + 0.25 * math.sin(t * math.pi * 3))
                                        .clamp(0.0, 1.0),
                                    child: Container(
                                      width: shortestSide * 0.45,
                                      height: shortestSide * 0.45,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CultureTheme.accentOrange
                                            .withValues(alpha: 0.16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: CultureTheme.accentOrange
                                                .withValues(alpha: 0.24),
                                            blurRadius: 85,
                                            spreadRadius: 25,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Halo Bleu Royal (Gauche)
                                Align(
                                  alignment: const Alignment(-0.65, 0.08),
                                  child: Opacity(
                                    opacity: (0.35 + 0.25 * math.cos(t * math.pi * 3))
                                        .clamp(0.0, 1.0),
                                    child: Container(
                                      width: shortestSide * 0.45,
                                      height: shortestSide * 0.45,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFF314999)
                                            .withValues(alpha: 0.16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF314999)
                                                .withValues(alpha: 0.24),
                                            blurRadius: 85,
                                            spreadRadius: 25,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Halo Turquoise Lumineux (Bas / Droite)
                                Align(
                                  alignment: const Alignment(0.55, 0.48),
                                  child: Opacity(
                                    opacity: (0.35 + 0.25 * math.sin((t + 0.5) * math.pi * 3))
                                        .clamp(0.0, 1.0),
                                    child: Container(
                                      width: shortestSide * 0.42,
                                      height: shortestSide * 0.42,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: CultureTheme.cyanTurquoise
                                            .withValues(alpha: 0.14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: CultureTheme.cyanTurquoise
                                                .withValues(alpha: 0.22),
                                            blurRadius: 80,
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
                                vertical: 16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // ── CONTENEUR MAÎTRE DU LOGO ET DU BADGE ───
                                  SizedBox(
                                    width: badgeSize * 1.8,
                                    height: badgeSize * 1.8,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.none,
                                      children: [
                                        // Onde de choc 1 : Flash blanc photonique à l'impact
                                        if (t >= 0.58 && impactProgress < 1.0)
                                          _buildShockwaveRing(
                                            radius: shockwaveRadius,
                                            color: Colors.white,
                                            opacity: flashOpacity,
                                            borderWidth: 3.0 * (1.0 - impactProgress),
                                          ),

                                        // Onde de choc 2 : Anneau cyan turquoise
                                        if (t >= 0.60 && impactProgress < 1.0)
                                          _buildShockwaveRing(
                                            radius: shockwaveRadius * 0.85,
                                            color: const Color(0xFF40BBCC),
                                            opacity: flashOpacity * 0.8,
                                            borderWidth: 2.0,
                                          ),

                                        // Onde de choc 3 : Anneau orange solaire
                                        if (t >= 0.62 && impactProgress < 1.0)
                                          _buildShockwaveRing(
                                            radius: shockwaveRadius * 0.70,
                                            color: const Color(0xFFF1851F),
                                            opacity: flashOpacity * 0.85,
                                            borderWidth: 2.0,
                                          ),

                                        // ── BADGE BLANC ÉLÉGANT ──────────────
                                        // Ne s'affiche qu'à l'assemblage des morceaux !
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
                                                  borderRadius:
                                                      BorderRadius.circular(borderRadius),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(alpha: 0.45),
                                                      blurRadius: 32,
                                                      offset: const Offset(0, 14),
                                                    ),
                                                    BoxShadow(
                                                      color: CultureTheme.accentOrange
                                                          .withValues(alpha: 0.28),
                                                      blurRadius: 40,
                                                      spreadRadius: 3,
                                                    ),
                                                  ],
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                                child: Stack(
                                                  children: [
                                                    // Balayage spéculaire (brillance de lumière)
                                                    if (sheenProgress > 0.0 && sheenProgress < 1.0)
                                                      Positioned.fill(
                                                        child: Transform.translate(
                                                          offset: Offset(
                                                            (sheenProgress * 2.6 - 1.3) *
                                                                badgeSize,
                                                            0,
                                                          ),
                                                          child: Transform.rotate(
                                                            angle: 0.45,
                                                            child: Container(
                                                              width: badgeSize * 0.45,
                                                              decoration: BoxDecoration(
                                                                gradient: LinearGradient(
                                                                  colors: [
                                                                    Colors.white
                                                                        .withValues(alpha: 0.0),
                                                                    Colors.white
                                                                        .withValues(alpha: 0.45),
                                                                    Colors.white
                                                                        .withValues(alpha: 0.0),
                                                                  ],
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

                                        // ── LES 3 PIÈCES VECTORIELLES DÉTACHÉES ───
                                        // Flottent librement dans l'espace DÈS t=0
                                        // et s'assemblent vers le centre !
                                        Transform.scale(
                                          scale: grandPulse,
                                          child: SizedBox(
                                            width: logoSize,
                                            height: logoSize,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              clipBehavior: Clip.none,
                                              children: [
                                                // Halo propre à la pièce Bleu (Éducation)
                                                if (t < 0.65)
                                                  _buildPieceGlow(
                                                    transform: blue,
                                                    color: const Color(0xFF314999),
                                                    size: logoSize * 0.9,
                                                  ),

                                                // Halo propre à la pièce Orange (Culture)
                                                if (t < 0.65)
                                                  _buildPieceGlow(
                                                    transform: orange,
                                                    color: const Color(0xFFF1851F),
                                                    size: logoSize * 0.9,
                                                  ),

                                                // Halo propre à la pièce Turquoise (Innovation)
                                                if (t < 0.65)
                                                  _buildPieceGlow(
                                                    transform: turquoise,
                                                    color: const Color(0xFF40BBCC),
                                                    size: logoSize * 0.9,
                                                  ),

                                                // 1. Morceau BLEU ROYAL (Gauche)
                                                _buildPiece(
                                                  svgString: _kBluePieceSvg,
                                                  transform: blue,
                                                  size: logoSize,
                                                ),

                                                // 2. Morceau ORANGE SOLAIRE (Haut / Droite)
                                                _buildPiece(
                                                  svgString: _kOrangePieceSvg,
                                                  transform: orange,
                                                  size: logoSize,
                                                ),

                                                // 3. Morceau TURQUOISE LUMINEUX (Bas / Droite)
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

                                  SizedBox(height: spacing),

                                  // ── TEXTE RÉVÉLÉ : "AlterniA" + Slogan Responsive ──
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
                                                  fontSize: isCompactHeight ? 28 : 34,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: -0.6,
                                                  color: Colors.white,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black
                                                          .withValues(alpha: 0.5),
                                                      blurRadius: 16,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ],
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
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'Alternative pour apprendre l\'essentiel',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: isCompactHeight ? 12 : 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF94A3B8),
                                                  letterSpacing: 0.4,
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

                                  // ── Signature MALI 2026 intégrée au flux ──────────
                                  Opacity(
                                    opacity: (textOpacity * 0.5).clamp(0.0, 0.5),
                                    child: Text(
                                      'MALI • 2026',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 2.5,
                                        color: Colors.white.withValues(alpha: 0.45),
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

  /// Calcule la trajectoire des pièces DÉTACHÉES :
  /// - DÈS t=0 : Les morceaux sont DÉJÀ DÉTACHÉS et flottent avec une douce oscillation dans l'espace.
  /// - Dès que t >= startDelay : attraction magnétique exponentielle avec courbure parabolique.
  /// - À lockTime : les pièces se verrouillent à (0, 0) avec orientation et échelle parfaites.
  _PieceTransform _computeDetachedPieceArc({
    required double t,
    required double startDelay,
    required double lockTime,
    required Offset initialOffset,
    required double initialRotation,
    required double initialScale,
    required Offset arcCurvature,
  }) {
    // ── Phase 1 : DÉTACHÉ DANS L'ESPACE (DÈS t=0) ──────────────────────────
    if (t < startDelay) {
      final floatProgress = t / startDelay;
      final floatX = math.sin(floatProgress * math.pi) * 3.0;
      final floatY = math.cos(floatProgress * math.pi) * 3.0;
      final rotWobble = math.sin(floatProgress * math.pi) * 0.02;

      return _PieceTransform(
        offset: Offset(initialOffset.dx + floatX, initialOffset.dy + floatY),
        rotation: initialRotation + rotWobble,
        scale: initialScale,
      );
    }

    // ── Phase 2 : VOL DE CONVERGENCE MAGNÉTIQUE EN ARC ──────────────────────
    if (t >= startDelay && t < lockTime) {
      final rawProgress = ((t - startDelay) / (lockTime - startDelay)).clamp(0.0, 1.0);

      // Courbe d'accélération puis amorti magnétique (Cubic)
      final progress = Curves.easeInOutCubic.transform(rawProgress);
      final remaining = 1.0 - progress;

      // Arc parabolique accentué
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

    // ── Phase 3 : VERROUILLÉ EN POSITION OFFICIELLE (0, 0) ──────────────────
    return const _PieceTransform(
      offset: Offset.zero,
      rotation: 0.0,
      scale: 1.0,
    );
  }

  /// Halo lumineux qui suit la pièce dans l'espace
  Widget _buildPieceGlow({
    required _PieceTransform transform,
    required Color color,
    required double size,
  }) {
    return Transform.translate(
      offset: transform.offset,
      child: Transform.scale(
        scale: transform.scale,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Anneau de choc circulaire lors de l'impact
  Widget _buildShockwaveRing({
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
