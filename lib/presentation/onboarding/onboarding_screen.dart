library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../features/profile/user_prefs_notifier.dart';
import '../common/widgets/alternia_logo.dart';

/// Données structurées pour chaque étape de l'onboarding cinématique (3 écrans max).
class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.stepNumber,
    required this.tag,
    required this.tagColor,
    required this.title,
    required this.titleHighlight,
    required this.description,
    required this.imageAsset,
    required this.fallbackAsset,
    required this.accentGlowColor,
  });

  final String stepNumber;
  final String tag;
  final Color tagColor;
  final String title;
  final String titleHighlight;
  final String description;
  final String imageAsset;
  final String fallbackAsset;
  final Color accentGlowColor;
}

const List<_OnboardingSlideData> _kSlides = [
  // ── Écran 1 : Éducation Intelligente ──────────────────────────────────────
  _OnboardingSlideData(
    stepNumber: '01',
    tag: 'PÔLE ÉDUCATION · INTELLIGENCE ARTIFICIELLE',
    tagColor: AppColors.secondary,
    title: 'L\'Excellence Scolaire',
    titleHighlight: 'Propulsée par l\'IA',
    description:
        'Un compagnon pédagogique interactif adapté au programme national. Fiches de synthèse, méthodologie guidée et entraînement sur-mesure.',
    imageAsset: 'assets/images/onboarding/education_onboard.jpg',
    fallbackAsset: 'assets/images/culture/robot_griot_tech.jpg',
    accentGlowColor: AppColors.secondary,
  ),

  // ── Écran 2 : Richesse Culturelle Africaine ───────────────────────────────
  _OnboardingSlideData(
    stepNumber: '02',
    tag: 'PATRIMOINE VIVANT · SAGESSE ANCESTRALE',
    tagColor: AppColors.accent,
    title: 'La Richesse Culturelle',
    titleHighlight: 'À Portée de Main',
    description:
        'Plongez dans les récits des sages, les contes du Baobab et les trésors architecturaux de Tombouctou et Djenné à travers une exploration vivante.',
    imageAsset: 'assets/images/onboarding/culture_onboard.jpg',
    fallbackAsset: 'assets/images/culture/griot_sage.jpg',
    accentGlowColor: AppColors.accent,
  ),

  // ── Écran 3 : Fusion Visuelle des Deux Univers ────────────────────────────
  _OnboardingSlideData(
    stepNumber: '03',
    tag: 'SYMBIOSE 2026 · HÉRITAGE & FUTUR',
    tagColor: AppColors.primaryLight,
    title: 'Quand la Tradition',
    titleHighlight: 'Rencontre l\'Avenir',
    description:
        'L\'alliance inédite du savoir ancestral et de la pointe technologique pour éclairer les esprits d\'aujourd\'hui et bâtir ceux de demain.',
    imageAsset: 'assets/images/onboarding/fusion_onboard.jpg',
    fallbackAsset: 'assets/images/culture/robot_sage.jpg',
    accentGlowColor: AppColors.secondary,
  ),
];

/// Onboarding immersif et cinématique d'AlterniA.
/// 3 écrans plein écran, progression élégante, animations fluides 2026.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  bool _isCompleting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  void _onNextPressed() {
    HapticFeedback.lightImpact();
    if (_currentIndex < _kSlides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    HapticFeedback.mediumImpact();

    // Marquer l'onboarding comme terminé dans les préférences utilisateur
    final userPrefs = ref.read(userPrefsProvider);
    final currentName = userPrefs.name.isEmpty ? 'Apprenant' : userPrefs.name;
    final currentClass = userPrefs.studentClassId;

    await ref.read(userPrefsProvider.notifier).saveRegistration(
          name: currentName,
          classId: currentClass,
        );

    if (mounted) {
      context.go('/gateway');
    }
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
            // ── Carrousel d'Images et Contenus Immersifs ────────────────────
            PageView.builder(
              controller: _pageController,
              itemCount: _kSlides.length,
              onPageChanged: _onPageChanged,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final slide = _kSlides[index];
                return _buildSlide(slide, index);
              },
            ),

            // ── Barre Supérieure : Logo & Bouton "Passer" ───────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge AlterniA discret
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF070B14).withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: const AlterniaLogo(
                          size: 22,
                          fontSize: 13,
                          showText: true,
                        ),
                      ),

                      // Bouton Passer (uniquement visible avant le dernier écran)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: _currentIndex < _kSlides.length - 1 ? 1.0 : 0.0,
                        child: GestureDetector(
                          onTap: _currentIndex < _kSlides.length - 1
                              ? _completeOnboarding
                              : null,
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF070B14)
                                  .withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Text(
                              'Passer',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 0.2,
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

            // ── Barre Inférieure : Indicateur & Bouton Continuer ─────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(22, 12, 22, 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Indicateur de progression moderne et discret
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_kSlides.length, (i) {
                          final isActive = i == _currentIndex;
                          final activeColor = _kSlides[_currentIndex].tagColor;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 3.5),
                            width: isActive ? 28 : 7,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? activeColor
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: activeColor.withValues(alpha: 0.5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 18),

                      // Bouton Continuer / Découvrir les univers
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _onNextPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentIndex == _kSlides.length - 1
                                ? AppColors.accent
                                : AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentIndex == _kSlides.length - 1
                                    ? 'Choisir mon univers'
                                    : 'Continuer',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentIndex == _kSlides.length - 1
                                    ? Icons.auto_awesome_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
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
    );
  }

  Widget _buildSlide(_OnboardingSlideData slide, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Image Immersive Plein Écran ─────────────────────────────────────
        Image.asset(
          slide.imageAsset,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          errorBuilder: (_, __, ___) => Image.asset(
            slide.fallbackAsset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF0F172A),
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 64,
                  color: slide.tagColor.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ),

        // ── Voile Dégradé Élégant 2026 (Sans saturation excessive) ──────────
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF070B14).withValues(alpha: 0.65),
                const Color(0xFF070B14).withValues(alpha: 0.15),
                const Color(0xFF070B14).withValues(alpha: 0.65),
                const Color(0xFF070B14).withValues(alpha: 0.96),
              ],
              stops: const [0.0, 0.35, 0.65, 0.95],
            ),
          ),
        ),

        // ── Lueur d'ambiance directionnelle ──────────────────────────────────
        Positioned(
          bottom: 120,
          left: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: slide.accentGlowColor.withValues(alpha: 0.15),
              boxShadow: [
                BoxShadow(
                  color: slide.accentGlowColor.withValues(alpha: 0.22),
                  blurRadius: 90,
                  spreadRadius: 30,
                ),
              ],
            ),
          ),
        ),

        // ── Textes & Contenu Émotionnel ─────────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag & Numérotation
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF070B14).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: slide.tagColor.withValues(alpha: 0.4),
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
                          color: slide.tagColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        slide.tag,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: slide.tagColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Titre Majeur & Surlignage Élégant
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(text: '${slide.title}\n'),
                      TextSpan(
                        text: slide.titleHighlight,
                        style: TextStyle(
                          color: slide.tagColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Description Émotionnelle
                Text(
                  slide.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFCBD5E1),
                    height: 1.5,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
