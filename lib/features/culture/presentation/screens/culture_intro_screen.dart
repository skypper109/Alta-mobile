import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/controllers/culture_intro_controller.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/controllers/narration_coordinator.dart';
import '../../immersive/widgets/cultural_atmosphere_canvas.dart';
import '../../immersive/widgets/cultural_interactive_card.dart';
import '../../immersive/widgets/culture_narrator_widget.dart';

/// Écran 1 : CultureIntroScreen — Portail Immersif Culture d'AlternIA
/// Accueil chaleureux et immédiat avec le Sage du Manden / Griot-Bot
/// Question centrale : « Quel conte veux-tu écouter ou que veux-tu découvrir aujourd'hui ? »
/// Accès en 1 clic direct vers : Contes, Héros, Monuments et Accueil complet
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI
/// AUCUN EMOJI
class CultureIntroScreen extends ConsumerStatefulWidget {
  final void Function(int tabIndex)? onStartExploration;

  const CultureIntroScreen({
    super.key,
    this.onStartExploration,
  });

  @override
  ConsumerState<CultureIntroScreen> createState() => _CultureIntroScreenState();
}

class _CultureIntroScreenState extends ConsumerState<CultureIntroScreen>
    with SingleTickerProviderStateMixin {
  static const String _narrationSpeech =
      "Bienvenue voyageur dans la mémoire vivante du Mali. "
      "Quel conte veux-tu écouter ou que veux-tu découvrir aujourd'hui ?";

  static const List<_DocumentarySlide> _slides = [
    _DocumentarySlide(
      title: 'Soundiata Keïta',
      location: 'Manden • Koulikoro',
      assetPath: 'assets/images/culture/personnages/soundiata.jpg',
    ),
    _DocumentarySlide(
      title: 'Grande Mosquée de Djenné',
      location: 'Djenné • Mopti',
      assetPath: 'assets/images/culture/monuments/mosquee_djenne.jpg',
    ),
    _DocumentarySlide(
      title: 'Tombouctou la Mystique',
      location: 'Cité des 333 Saints',
      assetPath: 'assets/images/culture/villes/tombouctou_ville.jpg',
    ),
    _DocumentarySlide(
      title: 'Kankou Moussa',
      location: 'Empire du Mali',
      assetPath: 'assets/images/culture/personnages/mansa_moussa.jpg',
    ),
  ];

  int _currentSlideIndex = 0;
  Timer? _slideTimer;
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    // Apparition immédiate à 60 FPS (zéro écran noir)
    _entranceController.forward();

    // Diaporama doux des patrimoines en arrière-plan
    _slideTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentSlideIndex = (_currentSlideIndex + 1) % _slides.length;
      });
    });
  }

  void _completeIntro([int tabIndex = 0]) {
    HapticFeedback.mediumImpact();
    ref.read(narrationCoordinatorProvider.notifier).stop();
    ref.read(cultureIntroControllerProvider.notifier).markAsSeen();

    if (widget.onStartExploration != null) {
      widget.onStartExploration!(tabIndex);
    } else {
      if (mounted && context.canPop()) {
        context.pop();
      } else if (mounted) {
        context.go('/culture');
      }
    }
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final narrationState = ref.watch(narrationCoordinatorProvider);
    final activeSlide = _slides[_currentSlideIndex];

    return Scaffold(
      backgroundColor: CultureTheme.darkBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. ARRIÈRE-PLAN PATRIMONIAL VIVANT (SANS DÉGRADÉ) ──────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1200),
            child: Container(
              key: ValueKey<int>(_currentSlideIndex),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(activeSlide.assetPath),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.60),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),

          // ── 2. MOTIFS GÉOMÉTRIQUES BOGOLAN & ÉTINCELLES D'OR ────────────────
          const CulturalAtmosphereCanvas(
            enableParticles: true,
            enableBogolanMotifs: true,
            motifOpacity: 0.08,
            child: SizedBox.expand(),
          ),

          // ── 3. CONTENU PRINCIPAL SÉCURISÉ SANS DÉBORDEMENT (SCROLLABLE) ────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // ── Barre supérieure : Badge du lieu + Boutons Son & Passer ─
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Badge du lieu affiché en arrière-plan
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: CultureTheme.darkSurface
                                  .withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: CultureTheme.accentOrange
                                    .withValues(alpha: 0.35),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.place_rounded,
                                  size: 12,
                                  color: CultureTheme.accentOrange,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  activeSlide.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Contrôles à droite (Son et Passer)
                          Row(
                            children: [
                              // Bouton voix du Griot
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(narrationCoordinatorProvider.notifier)
                                      .toggle(_narrationSpeech);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: CultureTheme.darkSurface
                                        .withValues(alpha: 0.85),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: narrationState.isSpeaking
                                          ? CultureTheme.accentOrange
                                          : CultureTheme.darkBorder,
                                    ),
                                  ),
                                  child: Icon(
                                    narrationState.isSpeaking
                                        ? Icons.volume_up_rounded
                                        : Icons.volume_off_rounded,
                                    size: 16,
                                    color: narrationState.isSpeaking
                                        ? CultureTheme.accentOrange
                                        : CultureTheme.textMutedDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Bouton Passer
                              GestureDetector(
                                onTap: () => _completeIntro(0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: CultureTheme.darkSurface
                                        .withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: CultureTheme.darkBorder,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Passer',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: CultureTheme.textMutedDark,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 10,
                                        color: CultureTheme.textMutedDark,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Corps de l'écran avec scroll fluide ─────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),

                            // Badge univers AlternIA Culture
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4.5),
                              decoration: BoxDecoration(
                                color: CultureTheme.primaryBlue
                                    .withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: CultureTheme.primaryBlue
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 13,
                                    color: CultureTheme.cyanTurquoise,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'PORTAIL DE LA MÉMOIRE DU MALI',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      color: CultureTheme.cyanTurquoise,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            // ── AVATAR DU VIEUX SAGE / GRIOT-BOT ─────────────
                            CultureNarratorWidget(
                              size: 115,
                              imagePath: 'assets/images/culture/robot_sage.jpg',
                              name: 'Griot-Bot • Le Sage',
                              subtitle: 'Mémoire vivante du Mali',
                              primaryColor: CultureTheme.accentOrange,
                              onTap: () {
                                ref
                                    .read(narrationCoordinatorProvider.notifier)
                                    .toggle(_narrationSpeech);
                              },
                            ),

                            const SizedBox(height: 20),

                            // ── QUESTION D'ACCUEIL DU SAGE ───────────────────
                            CulturalInteractiveCard(
                              padding: const EdgeInsets.all(18),
                              showSudaneseCorners: true,
                              activeAccentColor: CultureTheme.accentOrange,
                              backgroundColor: CultureTheme.darkSurface,
                              borderRadius: 20,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 14,
                                        color: CultureTheme.accentOrange,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'LE SAGE VOUS DEMANDE',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.0,
                                          color: CultureTheme.accentOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '« Quel conte veux-tu écouter ou que souhaites-tu découvrir aujourd\'hui ? »',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      height: 1.4,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 22),

                            // ── CHOIX D'EXPLORATION DIRECTS (3 CARTES TACTILES) ─
                            Row(
                              children: [
                                // Choix 1 : Écouter un conte (Tab 2)
                                Expanded(
                                  child: _buildChoiceCard(
                                    title: 'Contes & Veillées',
                                    subtitle: 'Fables orales',
                                    icon: Icons.auto_stories_rounded,
                                    color: CultureTheme.accentOrange,
                                    onTap: () => _completeIntro(2),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Choix 2 : Héros & Figures (Tab 1)
                                Expanded(
                                  child: _buildChoiceCard(
                                    title: 'Héros & Bâtisseurs',
                                    subtitle: 'Grandes figures',
                                    icon: Icons.shield_rounded,
                                    color: CultureTheme.primaryBlue,
                                    onTap: () => _completeIntro(1),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Row(
                              children: [
                                // Choix 3 : Monuments sacrés (Tab 1)
                                Expanded(
                                  child: _buildChoiceCard(
                                    title: 'Monuments Sacrés',
                                    subtitle: 'Architecture banco',
                                    icon: Icons.account_balance_rounded,
                                    color: CultureTheme.cyanTurquoise,
                                    onTap: () => _completeIntro(1),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Choix 4 : Passeport du Voyageur (Tab 3)
                                Expanded(
                                  child: _buildChoiceCard(
                                    title: 'Mon Passeport',
                                    subtitle: 'Sceaux royaux',
                                    icon: Icons.verified_user_rounded,
                                    color: CultureTheme.vertNaturel,
                                    onTap: () => _completeIntro(3),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ── BOUTON PRINCIPAL "EXPLORER TOUT L'ACCUEIL" ───
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: () => _completeIntro(0),
                                icon: const Icon(
                                  Icons.explore_rounded,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  "Entrer dans l'Univers Culture",
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CultureTheme.accentOrange,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),
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
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CulturalInteractiveCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      showSudaneseCorners: false,
      activeAccentColor: color,
      backgroundColor: CultureTheme.darkSurface,
      borderRadius: 16,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: CultureTheme.textMutedDark,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DocumentarySlide {
  final String title;
  final String location;
  final String assetPath;

  const _DocumentarySlide({
    required this.title,
    required this.location,
    required this.assetPath,
  });
}
