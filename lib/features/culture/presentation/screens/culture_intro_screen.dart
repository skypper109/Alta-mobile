import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/controllers/culture_intro_controller.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/controllers/narration_coordinator.dart';
import '../../immersive/widgets/culture_narrator_widget.dart';

/// Écran 1 : CultureIntroScreen — Portail Immersif Culture d'AlternIA
///
/// Déroule les 6 phases immersives :
/// - Phase 1 : Logo AlternIA Culture avec Fade In (0.85 -> 1.0) et respiration (1200ms)
/// - Phase 2 : Titre "Bienvenue dans la mémoire vivante du Mali"
/// - Phase 3 : Narrateur culturel vivant (CultureNarratorWidget)
/// - Phase 4 : Narration automatique via FlutterTTS (NarrationCoordinator)
/// - Phase 5 : Carrousel documentaire lent d'images en arrière-plan (Ken Burns lent)
/// - Phase 6 : Bouton "Commencer l'exploration" avec pulsation douce toutes les 4s
///
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI
/// AUCUN EMOJI
class CultureIntroScreen extends ConsumerStatefulWidget {
  /// Callback facultatif déclenché au clic sur "Commencer l'exploration"
  final VoidCallback? onStartExploration;

  const CultureIntroScreen({
    super.key,
    this.onStartExploration,
  });

  @override
  ConsumerState<CultureIntroScreen> createState() => _CultureIntroScreenState();
}

class _CultureIntroScreenState extends ConsumerState<CultureIntroScreen>
    with TickerProviderStateMixin {
  // ── Constante : Texte de la narration du Griot ─────────────────────────────
  static const String _narrationSpeech =
      "Bienvenue voyageur. "
      "Tu t'apprêtes à découvrir les héros qui ont façonné le Mali. "
      "Les contes transmis par les griots. "
      "Les monuments qui témoignent de notre histoire. "
      "Les traditions qui vivent encore aujourd'hui. "
      "Chaque découverte enrichira ton passeport culturel. "
      "Que l'exploration commence.";

  // ── Constante : Liste des 6 images patrimoniales documentaires ─────────────
  static const List<_DocumentarySlide> _slides = [
    _DocumentarySlide(
      title: 'Soundiata Keïta',
      location: 'Manden • Koulikoro',
      assetPath: 'assets/images/culture/personnages/soundiata.jpg',
    ),
    _DocumentarySlide(
      title: 'Kankou Moussa',
      location: 'Empire du Mali • Tombouctou',
      assetPath: 'assets/images/culture/personnages/mansa_moussa.jpg',
    ),
    _DocumentarySlide(
      title: 'Grande Mosquée de Djenné',
      location: 'Djenné • Mopti',
      assetPath: 'assets/images/culture/monuments/mosquee_djenne.jpg',
    ),
    _DocumentarySlide(
      title: 'Tombouctou la Mystérieuse',
      location: 'Cité des 333 Saints',
      assetPath: 'assets/images/culture/villes/tombouctou_ville.jpg',
    ),
    _DocumentarySlide(
      title: 'Falaises de Bandiagara',
      location: 'Pays Dogon',
      assetPath: 'assets/images/culture/villes/bandiagara_falaise.jpg',
    ),
    _DocumentarySlide(
      title: 'Mosquée de Sankoré',
      location: 'Université Millénaire',
      assetPath: 'assets/images/culture/monuments/mosquee_sankore.jpg',
    ),
  ];

  // ── Contrôleurs d'animations de phases ─────────────────────────────────────
  // Phase 1 : Logo (Fade + Scale 0.85 -> 1.0 + Respiration)
  late final AnimationController _logoController;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final AnimationController _logoBreathingController;
  late final Animation<double> _logoBreathingScale;

  // Phase 2 : Titre "Bienvenue dans la mémoire vivante du Mali"
  late final AnimationController _titleController;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;

  // Phase 3 & 4 : Narrateur culturel & texte narré
  late final AnimationController _narratorEntranceController;
  late final Animation<double> _narratorFade;
  late final Animation<Offset> _narratorSlide;

  // Phase 6 : Bouton "Commencer l'exploration"
  late final AnimationController _buttonEntranceController;
  late final Animation<double> _buttonFade;
  late final AnimationController _buttonPulseController;
  late final Animation<double> _buttonPulseScale;
  Timer? _pulseTimer;

  // Phase 5 : Diaporama documentaire lent
  int _currentSlideIndex = 0;
  Timer? _slideTimer;
  late final AnimationController _kenBurnsController;
  late final Animation<double> _kenBurnsScale;
  late final Animation<Offset> _kenBurnsPan;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    // ── Configuration Phase 1 (Logo 1200ms) ───────────────────────────────────
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutCubic,
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _logoBreathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _logoBreathingScale = Tween<double>(begin: 0.985, end: 1.015).animate(
      CurvedAnimation(
        parent: _logoBreathingController,
        curve: Curves.easeInOutSine,
      ),
    );

    // ── Configuration Phase 2 (Titre) ─────────────────────────────────────────
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _titleFade = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOut,
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic));

    // ── Configuration Phase 3 (Narrateur) ─────────────────────────────────────
    _narratorEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _narratorFade = CurvedAnimation(
      parent: _narratorEntranceController,
      curve: Curves.easeOut,
    );
    _narratorSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _narratorEntranceController,
      curve: Curves.easeOutCubic,
    ));

    // ── Configuration Phase 6 (Bouton et pulsation toutes les 4s) ─────────────
    _buttonEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _buttonFade = CurvedAnimation(
      parent: _buttonEntranceController,
      curve: Curves.easeOut,
    );

    _buttonPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _buttonPulseScale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _buttonPulseController,
        curve: Curves.easeInOutSine,
      ),
    );

    // ── Configuration Phase 5 (Ken Burns documentaire lent) ───────────────────
    _kenBurnsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );
    _kenBurnsScale = Tween<double>(begin: 1.0, end: 1.10).animate(
      CurvedAnimation(
        parent: _kenBurnsController,
        curve: Curves.linear,
      ),
    );
    _kenBurnsPan = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(-0.02, -0.015),
    ).animate(
      CurvedAnimation(
        parent: _kenBurnsController,
        curve: Curves.linear,
      ),
    );

    // Lancer la séquence orchestrée
    _startIntroSequence();
  }

  /// Déroulement automatique et progressif des 6 phases
  Future<void> _startIntroSequence() async {
    if (_isDisposed) return;

    // Phase 1 : Logo apparaît (1200ms)
    await _logoController.forward();
    if (_isDisposed) return;
    _logoBreathingController.repeat(reverse: true);

    // Pause théâtrale (400ms)
    await Future.delayed(const Duration(milliseconds: 400));
    if (_isDisposed) return;

    // Phase 2 : Titre apparaît
    await _titleController.forward();
    if (_isDisposed) return;

    // Pause (500ms)
    await Future.delayed(const Duration(milliseconds: 500));
    if (_isDisposed) return;

    // Phase 3 : Narrateur entre en scène
    await _narratorEntranceController.forward();
    if (_isDisposed) return;

    // Démarrer le diaporama lent en arrière-plan (Phase 5)
    _startBackgroundSlideshow();

    // Phase 4 : Démarrer la narration vocale automatique (FlutterTTS)
    _startNarration();

    // Phase 6 : Faire apparaître le bouton d'action
    await Future.delayed(const Duration(milliseconds: 1400));
    if (_isDisposed) return;
    await _buttonEntranceController.forward();

    // Programmer la pulsation douce du bouton toutes les 4 secondes
    _scheduleButtonPulse();
  }

  /// Démarre la synthèse vocale via NarrationCoordinator
  void _startNarration() {
    ref.read(narrationCoordinatorProvider.notifier).speak(_narrationSpeech);
  }

  /// Lance le carrousel très lent des images culturelles (Ken Burns)
  void _startBackgroundSlideshow() {
    _kenBurnsController.forward(from: 0.0);
    _slideTimer = Timer.periodic(const Duration(milliseconds: 7000), (timer) {
      if (_isDisposed || !mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentSlideIndex = (_currentSlideIndex + 1) % _slides.length;
      });
      _kenBurnsController.forward(from: 0.0);
    });
  }

  /// Planifie la pulsation du bouton toutes les 4 secondes
  void _scheduleButtonPulse() {
    _pulseTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_isDisposed || !mounted) {
        timer.cancel();
        return;
      }
      _buttonPulseController.forward().then((_) {
        if (!_isDisposed && mounted) {
          _buttonPulseController.reverse();
        }
      });
    });
  }

  /// Termine l'introduction et bascule vers l'univers Culture
  Future<void> _completeIntro() async {
    HapticFeedback.mediumImpact();

    // 1. Arrêt immédiat de la synthèse vocale
    await ref.read(narrationCoordinatorProvider.notifier).stop();

    // 2. Marquer l'intro comme complétée dans le state Riverpod
    await ref.read(cultureIntroControllerProvider.notifier).markAsSeen();

    // 3. Callback personnalisé ou navigation
    if (widget.onStartExploration != null) {
      widget.onStartExploration!();
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
    _isDisposed = true;
    _slideTimer?.cancel();
    _pulseTimer?.cancel();
    _logoController.dispose();
    _logoBreathingController.dispose();
    _titleController.dispose();
    _narratorEntranceController.dispose();
    _buttonEntranceController.dispose();
    _buttonPulseController.dispose();
    _kenBurnsController.dispose();
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
          // ── PHASE 5 : ARRIÈRE-PLAN CARROUSEL DOCUMENTAIRE LENT (KEN BURNS) ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1600),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: KeyedSubtree(
              key: ValueKey<int>(_currentSlideIndex),
              child: AnimatedBuilder(
                animation: _kenBurnsController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      _kenBurnsPan.value.dx * MediaQuery.of(context).size.width,
                      _kenBurnsPan.value.dy *
                          MediaQuery.of(context).size.height,
                    ),
                    child: Transform.scale(
                      scale: _kenBurnsScale.value,
                      child: Image.asset(
                        activeSlide.assetPath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: CultureTheme.darkBackground,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── VOILE SOMBRE PROFOND UNI (STRICTEMENT AUCUN DÉGRADÉ) ───────────
          // Contraste cinématographique puissant sans dégradé
          Container(
            color: CultureTheme.darkBackground.withValues(alpha: 0.84),
          ),

          // ── BADGE DISCRET DU LIEU ACTUEL EN FOND DOCUMENTAIRE ──────────────
          Positioned(
            top: 50,
            left: 20,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: Container(
                key: ValueKey<String>(activeSlide.title),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: CultureTheme.darkSurface.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.35),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 11,
                      color: CultureTheme.accentOrange,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${activeSlide.title} • ${activeSlide.location}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── BOUTONS SUPÉRIEURS : PASSER & CONTRÔLE DU SON ─────────────────
          Positioned(
            top: 46,
            right: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bouton bascule voix du Griot
                IconButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(narrationCoordinatorProvider.notifier)
                        .toggle(_narrationSpeech);
                  },
                  tooltip: narrationState.isSpeaking
                      ? 'Couper la voix'
                      : 'Activer la voix',
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CultureTheme.darkSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: narrationState.isSpeaking
                            ? CultureTheme.accentOrange
                            : CultureTheme.darkBorder,
                        width: 1.2,
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

                // Bouton "Passer" discret pour accès immédiat
                GestureDetector(
                  onTap: _completeIntro,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: CultureTheme.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: CultureTheme.darkBorder,
                        width: 1.0,
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
          ),

          // ── CONTENU PRINCIPAL CENTRÉ : SÉQUENCE DES PHASES ─────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // ── PHASE 1 : LOGO ALTERNIA CULTURE (1200ms) ───────────────
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: AnimatedBuilder(
                        animation: _logoBreathingController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoBreathingScale.value,
                            child: child,
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Logo AlternIA avec cadre épuré
                            Container(
                              width: 76,
                              height: 76,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: CultureTheme.darkSurface,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: CultureTheme.primaryBlue,
                                  width: 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/images/alternia_logo.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.account_balance_rounded,
                                  size: 38,
                                  color: CultureTheme.accentOrange,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: CultureTheme.primaryBlue
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: CultureTheme.primaryBlue
                                      .withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                'ALTERNIA CULTURE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                  color: CultureTheme.cyanTurquoise,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── PHASE 2 : TITRE "BIENVENUE DANS LA MÉMOIRE VIVANTE DU MALI"
                  FadeTransition(
                    opacity: _titleFade,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: Text(
                        'Bienvenue dans la mémoire\nvivante du Mali',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── PHASE 3 & 4 : NARRATEUR CULTUREL VIVANT & CITATION ──────
                  FadeTransition(
                    opacity: _narratorFade,
                    child: SlideTransition(
                      position: _narratorSlide,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Widget Narrateur réutilisable avec respiration et micro-oscillation
                          CultureNarratorWidget(
                            size: 110,
                            name: 'Le Griot de la Mémoire',
                            subtitle: 'Gardien de la tradition orale malienne',
                            primaryColor: CultureTheme.accentOrange,
                            onTap: () {
                              ref
                                  .read(narrationCoordinatorProvider.notifier)
                                  .toggle(_narrationSpeech);
                            },
                          ),

                          const SizedBox(height: 18),

                          // Bloc de sous-titres narratifs synchronisés (STRICTEMENT SANS DÉGRADÉ)
                          Container(
                            constraints: const BoxConstraints(maxWidth: 380),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            decoration: BoxDecoration(
                              color: CultureTheme.darkSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: CultureTheme.darkBorder,
                                width: 1.2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.format_quote_rounded,
                                      size: 16,
                                      color: CultureTheme.accentOrange,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'PAROLES DU GRIOT',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                        color: CultureTheme.accentOrange,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '« Découvre les héros qui ont façonné le Mali, les contes des veillées et les monuments sacrés. Chaque découverte enrichira ton passeport culturel. »',
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    height: 1.45,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── PHASE 6 : BOUTON "COMMENCER L'EXPLORATION" ──────────────
                  FadeTransition(
                    opacity: _buttonFade,
                    child: AnimatedBuilder(
                      animation: _buttonPulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _buttonPulseScale.value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 360),
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _completeIntro,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CultureTheme.accentOrange,
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: Colors.black.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.explore_rounded,
                                size: 22,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Commencer l'exploration",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modèle interne pour les diapositives documentaires
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
