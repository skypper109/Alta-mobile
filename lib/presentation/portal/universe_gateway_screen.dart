library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../features/profile/user_prefs_notifier.dart';
import '../common/widgets/alternia_logo.dart';
import '../common/widgets/universe_splash_transition.dart';

/// Porte d'entrée spectaculaire d'AlterniA : "Choisissez votre univers".
/// Conçue pour une expérience internationale de concours (Design 2026).
/// Deux grandes zones visuelles immersives et interactives (Éducation vs Culture).
class UniverseGatewayScreen extends ConsumerStatefulWidget {
  const UniverseGatewayScreen({super.key});

  @override
  ConsumerState<UniverseGatewayScreen> createState() =>
      _UniverseGatewayScreenState();
}

class _UniverseGatewayScreenState extends ConsumerState<UniverseGatewayScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _revealCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _headerSlideAnim;
  late final Animation<double> _portalScaleAnim;

  // Univers actif en survol ou touché (0 = aucun/neutre, 1 = Éducation, 2 = Culture)
  int _hoveredUniverse = 0;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _revealCtrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _headerSlideAnim = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _revealCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _portalScaleAnim = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealCtrl,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _revealCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectEducation() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    HapticFeedback.heavyImpact();

    final userPrefs = ref.read(userPrefsProvider);
    // Première visite : saisie des identifiants de l'apprenant puis choix de la filière
    if (!userPrefs.hasSelectedClass || userPrefs.name.isEmpty) {
      if (mounted) {
        setState(() => _isNavigating = false);
        context.go('/education-setup');
      }
      return;
    }

    if (mounted) {
      UniverseSplashTransition.toEducation(
        context,
        onComplete: () {
          if (mounted) {
            setState(() => _isNavigating = false);
            context.go('/home');
          }
        },
      );
    }
  }

  void _selectCulture() {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);
    HapticFeedback.heavyImpact();

    UniverseSplashTransition.toCulture(
      context,
      onComplete: () {
        if (mounted) {
          setState(() => _isNavigating = false);
          context.go('/culture');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF070B14),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF070B14),
        body: Stack(
          children: [
            // Fond subtil d'ambiance cosmique avec lueurs ultra-douces
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.08),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      blurRadius: 100,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.08),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      blurRadius: 100,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── En-tête Supérieur Élégant ────────────────────────────
                    SlideTransition(
                      position: _headerSlideAnim,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: _buildHeader(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Les Deux Portails Immersifs (Split Screen Dynamique) ─
                    Expanded(
                      child: ScaleTransition(
                        scale: _portalScaleAnim,
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final totalH = constraints.maxHeight;
                              const spacing = 14.0;
                              final availableH = totalH - spacing;

                              // Flex dynamique au toucher/hover
                              double topFlex = 1.0;
                              double bottomFlex = 1.0;

                              if (_hoveredUniverse == 1) {
                                topFlex = 1.35;
                                bottomFlex = 0.85;
                              } else if (_hoveredUniverse == 2) {
                                topFlex = 0.85;
                                bottomFlex = 1.35;
                              }

                              final sumFlex = topFlex + bottomFlex;
                              final topHeight = (availableH * (topFlex / sumFlex))
                                  .clamp(140.0, availableH - 140.0);
                              final bottomHeight = availableH - topHeight;

                              return Column(
                                children: [
                                  // Portail 1 : UNIVERS ÉDUCATION
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 320),
                                    curve: Curves.easeOutCubic,
                                    height: topHeight,
                                    child: _buildUniversePortal(
                                      id: 1,
                                      title: 'ÉDUCATION',
                                      tag: 'SAVOIR & INNOVATION IA',
                                      tagColor: AppColors.secondary,
                                      subtitle:
                                          'Tuteur IA interactif, méthodologie de révision et excellence scolaire.',
                                      imagePath:
                                          'assets/images/onboarding/education_onboard.jpg',
                                      fallbackAsset:
                                          'assets/images/culture/robot_griot_tech.jpg',
                                      primaryColor: AppColors.primary,
                                      accentColor: AppColors.secondary,
                                      isHovered: _hoveredUniverse == 1,
                                      isDimmed: _hoveredUniverse == 2,
                                      actionLabel: 'Entrer dans l\'Éducation',
                                      onTap: _selectEducation,
                                      onHoverChange: (hovered) {
                                        setState(() {
                                          _hoveredUniverse = hovered ? 1 : 0;
                                        });
                                      },
                                    ),
                                  ),

                                  const SizedBox(height: spacing),

                                  // Portail 2 : UNIVERS CULTURE
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 320),
                                    curve: Curves.easeOutCubic,
                                    height: bottomHeight,
                                    child: _buildUniversePortal(
                                      id: 2,
                                      title: 'CULTURE',
                                      tag: 'PATRIMOINE VIVANT & MÉMOIRE',
                                      tagColor: AppColors.accent,
                                      subtitle:
                                          'Contes du Baobab, monuments mythiques du Mali et récits ancestraux.',
                                      imagePath:
                                          'assets/images/onboarding/culture_onboard.jpg',
                                      fallbackAsset:
                                          'assets/images/culture/griot_sage.jpg',
                                      primaryColor: const Color(0xFFC45A10),
                                      accentColor: AppColors.accent,
                                      isHovered: _hoveredUniverse == 2,
                                      isDimmed: _hoveredUniverse == 1,
                                      actionLabel: 'Explorer la Culture',
                                      onTap: _selectCulture,
                                      onHoverChange: (hovered) {
                                        setState(() {
                                          _hoveredUniverse = hovered ? 2 : 0;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ── Bas de page discret : Mention discrète ──────────────
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Center(
                        child: Text(
                          'Basculez librement entre les univers à tout moment',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF141C2E).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF23314D).withValues(alpha: 0.6),
                ),
              ),
              child: const AlterniaLogo(
                size: 20,
                fontSize: 12,
                showText: true,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Choisissez votre univers',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Deux expériences complémentaires pour apprendre et s\'élever',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildUniversePortal({
    required int id,
    required String title,
    required String tag,
    required Color tagColor,
    required String subtitle,
    required String imagePath,
    required String fallbackAsset,
    required Color primaryColor,
    required Color accentColor,
    required bool isHovered,
    required bool isDimmed,
    required String actionLabel,
    required VoidCallback onTap,
    required ValueChanged<bool> onHoverChange,
  }) {
    final borderColor = isHovered
        ? accentColor.withValues(alpha: 0.8)
        : const Color(0xFF23314D).withValues(alpha: 0.85);

    return MouseRegion(
      onEnter: (_) => onHoverChange(true),
      onExit: (_) => onHoverChange(false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.selectionClick();
          onHoverChange(true);
        },
        onTapUp: (_) => onHoverChange(false),
        onTapCancel: () => onHoverChange(false),
        onTap: onTap,
        child: AnimatedScale(
          scale: isHovered ? 1.015 : (isDimmed ? 0.985 : 1.0),
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: isDimmed ? 0.72 : 1.0,
            duration: const Duration(milliseconds: 280),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: borderColor,
                  width: isHovered ? 2.0 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isHovered ? accentColor : primaryColor)
                        .withValues(alpha: isHovered ? 0.28 : 0.12),
                    blurRadius: isHovered ? 28 : 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── Image de Fond Immersive avec Parallaxe Subtile ───────
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    errorBuilder: (_, __, ___) => Image.asset(
                      fallbackAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF141C2E),
                        child: Center(
                          child: Icon(
                            id == 1
                                ? Icons.school_rounded
                                : Icons.auto_stories_rounded,
                            size: 48,
                            color: accentColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Voile sombre cinématographique avec dégradé subtil ────
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF070B14).withValues(alpha: 0.35),
                          const Color(0xFF070B14).withValues(alpha: 0.60),
                          const Color(0xFF070B14).withValues(alpha: 0.94),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),

                  // ── Halo lumineux d'angle (Teinte officielle) ─────────────
                  Positioned(
                    top: -40,
                    right: -40,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      width: isHovered ? 160 : 110,
                      height: isHovered ? 160 : 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withValues(alpha: isHovered ? 0.25 : 0.12),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.2),
                            blurRadius: 40,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Contenu Visuel du Portail ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tag Supérieur
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF070B14)
                                    .withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: tagColor.withValues(alpha: 0.45),
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
                                      color: tagColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: tagColor.withValues(alpha: 0.8),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    tag,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: tagColor,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isHovered ? accentColor : Colors.white)
                                    .withValues(alpha: isHovered ? 0.22 : 0.1),
                                border: Border.all(
                                  color: (isHovered ? accentColor : Colors.white)
                                      .withValues(alpha: isHovered ? 0.6 : 0.15),
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_outward_rounded,
                                size: 16,
                                color: isHovered ? accentColor : Colors.white,
                              ),
                            ),
                          ],
                        ),

                        // Bloc Titre, Description & Action
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFCBD5E1),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 12),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: isHovered
                                    ? accentColor
                                    : const Color(0xFF141C2E)
                                        .withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isHovered
                                      ? accentColor
                                      : accentColor.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    actionLabel,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isHovered
                                          ? const Color(0xFF070B14)
                                          : Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: isHovered
                                        ? const Color(0xFF070B14)
                                        : accentColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
