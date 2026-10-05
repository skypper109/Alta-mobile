import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/culture_detail_models.dart';
import '../../immersive/controllers/narration_coordinator.dart';
import '../../immersive/services/cultural_haptics.dart';
import '../widgets/soundiata_living_book_view.dart';
import '../widgets/soundiata_interactive_elements.dart';
import '../widgets/soundiata_audio_elements.dart';

/// 🎬 ÉCRAN CINÉMATIQUE PLEIN ÉCRAN — LE LIVRE VIVANT DE SOUNDIATA KEÏTA
/// Expérience immersive 100% plein écran avec :
/// - Parallaxe continue frame-by-frame
/// - Personnages 2D animés au pixel du scroll (entrées gauche/droite)
/// - Tracé vectoriel animé de la Carte du Manden avec cités interactives cliquables
/// - Choc stylisé de Kirina avec tir interactif de la flèche d'ergot blanc
/// - Tiroir modal interactif de la Charte de Kouroukan Fouga (1236)
/// - Ambiance sonore contextuelle (Soundscapes mandingues)
/// - Mode Autoplay Ciné-Conteur avec synchronisation vocale et ondes dorées
class SoundiataCinematicBookScreen extends ConsumerStatefulWidget {
  final HistoricalFigureDetail? figure;

  const SoundiataCinematicBookScreen({
    super.key,
    this.figure,
  });

  @override
  ConsumerState<SoundiataCinematicBookScreen> createState() =>
      _SoundiataCinematicBookScreenState();
}

class _SoundiataCinematicBookScreenState
    extends ConsumerState<SoundiataCinematicBookScreen>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  int _currentPage = 0;
  double _pageOffset = 0.0;
  bool _isSpeaking = false;
  bool _isAutoplayEnabled = false;

  late final AnimationController _pulseController;
  late final AnimationController _dustController;

  // Contrôleurs pour l'interaction du Choc de Kirina (Acte VI)
  late final AnimationController _kirinaArrowController;
  late final AnimationController _kirinaShakeController;
  late final AnimationController _kirinaFlashController;
  bool _kirinaArrowFired = false;
  bool _kirinaSoumaoroDefeated = false;

  final List<SoundiataBookChapter> _chapters =
      SoundiataLivingBookView.getChapters();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageScroll);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _dustController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _kirinaArrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _kirinaShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _kirinaFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _kirinaArrowController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _triggerKirinaImpact();
      }
    });
  }

  void _onPageScroll() {
    if (!_pageController.hasClients) return;
    setState(() {
      _pageOffset = _pageController.page ?? 0.0;
      final int newPage = _pageOffset.round().clamp(0, _chapters.length - 1);
      if (newPage != _currentPage) {
        _currentPage = newPage;
        CulturalHaptics.tabSwitch();
        if (_isSpeaking || _isAutoplayEnabled) {
          _speakCurrentChapter();
        }
      }
    });
  }

  void _toggleNarration() {
    CulturalHaptics.audioToggle();
    final narration = ref.read(narrationCoordinatorProvider);
    if (narration.isSpeaking) {
      ref.read(narrationCoordinatorProvider.notifier).stop();
      setState(() {
        _isSpeaking = false;
        _isAutoplayEnabled = false;
      });
    } else {
      setState(() {
        _isSpeaking = true;
      });
      _speakCurrentChapter();
    }
  }

  void _toggleAutoplay() {
    CulturalHaptics.celebration();
    setState(() {
      _isAutoplayEnabled = !_isAutoplayEnabled;
    });
    if (_isAutoplayEnabled) {
      setState(() {
        _isSpeaking = true;
      });
      _speakCurrentChapter();
    } else {
      ref.read(narrationCoordinatorProvider.notifier).stop();
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  void _speakCurrentChapter() {
    final chapter = _chapters[_currentPage];
    final text =
        '${chapter.actName} : ${chapter.title}. ${chapter.location}, ${chapter.period}. ${chapter.narrative}. ${chapter.highlightQuote}';
    final contentId = 'soundiata_cinematic_chap_${chapter.number}';

    ref.read(narrationCoordinatorProvider.notifier).speak(
      text,
      contentId: contentId,
      onComplete: () {
        if (_isAutoplayEnabled && mounted && _currentPage < _chapters.length - 1) {
          _nextPage();
          Future.delayed(const Duration(milliseconds: 700), () {
            if (_isAutoplayEnabled && mounted) {
              _speakCurrentChapter();
            }
          });
        }
      },
    );
  }

  void _triggerKirinaImpact() {
    _kirinaFlashController.forward(from: 0.0);
    _kirinaShakeController.forward(from: 0.0);
    CulturalHaptics.celebration();
    setState(() {
      _kirinaSoumaoroDefeated = true;
    });
  }

  void _shootKirinaArrow() {
    if (_kirinaArrowController.isAnimating) return;
    CulturalHaptics.cardPress();
    setState(() {
      _kirinaArrowFired = true;
      _kirinaSoumaoroDefeated = false;
    });
    _kirinaArrowController.forward(from: 0.0);
  }

  void _resetKirinaBattle() {
    CulturalHaptics.tabSwitch();
    setState(() {
      _kirinaArrowFired = false;
      _kirinaSoumaoroDefeated = false;
    });
    _kirinaArrowController.reset();
    _kirinaShakeController.reset();
    _kirinaFlashController.reset();
  }

  void _showCityBottomSheet(MandeCity city) {
    CulturalHaptics.stamp();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => MandeCityDetailSheet(city: city, isDark: true),
    );
  }

  void _showCharterBottomSheet() {
    CulturalHaptics.stamp();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.78,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Color(0xFFF59E0B), width: 1.5),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: KouroukanCharterAccordion(isDark: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      ref.read(narrationCoordinatorProvider.notifier).stop();
    } catch (_) {}
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _pulseController.dispose();
    _dustController.dispose();
    _kirinaArrowController.dispose();
    _kirinaShakeController.dispose();
    _kirinaFlashController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _chapters.length - 1) {
      CulturalHaptics.tabSwitch();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      CulturalHaptics.tabSwitch();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final narration = ref.watch(narrationCoordinatorProvider);
    final isCurrentlySpeaking = narration.isSpeaking;
    final currentChapter = _chapters[_currentPage];
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: AnimatedBuilder(
        animation: _kirinaShakeController,
        builder: (context, child) {
          final shake = (1.0 - _kirinaShakeController.value) *
              math.sin(_kirinaShakeController.value * 28) *
              8.0;
          return Transform.translate(
            offset: Offset(shake, 0),
            child: child,
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. PAGES DU LIVRE EN PARALLAXE PLEIN ÉCRAN ──────────────────────
            PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                return _buildCinematicPage(
                  chapter: _chapters[index],
                  index: index,
                  pageOffset: _pageOffset,
                  isCurrentlySpeaking: isCurrentlySpeaking,
                );
              },
            ),

          // ── 2. BARRE SUPÉRIEURE FLOTTANTE ULTRA-DISCRÈTE ───────────────────
          Positioned(
            top: topPadding > 0 ? topPadding + 8 : 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Bouton Fermer le Plein Écran
                GestureDetector(
                  onTap: () {
                    CulturalHaptics.cardPress();
                    try {
                      ref.read(narrationCoordinatorProvider.notifier).stop();
                    } catch (_) {}
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Cartouche central de l'Acte
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E0E05).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${currentChapter.actName} • ${currentChapter.title.split('&').first.trim().toUpperCase()}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFF59E0B),
                                letterSpacing: 0.8,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Bouton Autoplay (Ciné-Conteur automatique)
                GestureDetector(
                  onTap: _toggleAutoplay,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                    decoration: BoxDecoration(
                      color: _isAutoplayEnabled
                          ? const Color(0xFFF59E0B)
                          : Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isAutoplayEnabled
                            ? const Color(0xFFD97706)
                            : Colors.white.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                      boxShadow: _isAutoplayEnabled
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 13,
                          color: _isAutoplayEnabled ? Colors.black : const Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Auto',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: _isAutoplayEnabled ? Colors.black : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Bouton Voix du Griot (Audio) avec Waveform animé
                GestureDetector(
                  onTap: _toggleNarration,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isCurrentlySpeaking
                          ? const Color(0xFFF59E0B)
                          : Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isCurrentlySpeaking
                            ? const Color(0xFFF59E0B)
                            : Colors.white.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isCurrentlySpeaking
                              ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCurrentlySpeaking
                              ? Icons.volume_up_rounded
                              : Icons.volume_mute_rounded,
                          color: isCurrentlySpeaking ? Colors.black : Colors.white,
                          size: 18,
                        ),
                        if (isCurrentlySpeaking) ...[
                          const SizedBox(width: 6),
                          const SoundiataWaveformVisualizer(
                            isPlaying: true,
                            activeColor: Colors.black,
                            barCount: 3,
                            maxHeight: 12,
                            barWidth: 2.2,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 3. CONTRÔLES FLOTTANTS EN BAS (SCRUBBER & NAVIGATION) ───────────
          Positioned(
            bottom: bottomPadding > 0 ? bottomPadding + 8 : 18,
            left: 20,
            right: 20,
            child: Row(
              children: [
                // Bouton Précédent
                if (_currentPage > 0)
                  GestureDetector(
                    onTap: _previousPage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 44),

                const Spacer(),

                // Indicateurs d'actes (Points lumineux)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_chapters.length, (idx) {
                      final isSelected = _currentPage == idx;
                      return GestureDetector(
                        onTap: () {
                          CulturalHaptics.tabSwitch();
                          _pageController.animateToPage(
                            idx,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3.5),
                          width: isSelected ? 22 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF59E0B)
                                : Colors.white30,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFF59E0B)
                                          .withValues(alpha: 0.6),
                                      blurRadius: 6,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const Spacer(),

                // Bouton Suivant
                if (_currentPage < _chapters.length - 1)
                  GestureDetector(
                    onTap: _nextPage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.black,
                        size: 26,
                      ),
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      CulturalHaptics.celebration();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_rounded,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Fin',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── FLASH D'IMPACT PLEIN ÉCRAN POUR LE CHOC DE KIRINA ──
          AnimatedBuilder(
            animation: _kirinaFlashController,
            builder: (context, _) {
              final opacity = (1.0 - _kirinaFlashController.value) * 0.75;
              if (opacity <= 0.01) return const SizedBox.shrink();
              return Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    color: Colors.white.withValues(alpha: opacity),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

  /// Construction d'une page plein écran avec parallaxe continue
  Widget _buildCinematicPage({
    required SoundiataBookChapter chapter,
    required int index,
    required double pageOffset,
    required bool isCurrentlySpeaking,
  }) {
    // Calcul de parallaxe continue en temps réel
    final double pageDelta = index - pageOffset;
    final double parallaxX = pageDelta * 60.0;
    final double charLeftSlide = pageDelta * -180.0;
    final double charRightSlide = pageDelta * 180.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── 1. FOND DE SCÈNE EN PARALLAXE ─────────────────────────────────────
        Transform.translate(
          offset: Offset(parallaxX, 0),
          child: Transform.scale(
            scale: 1.08,
            child: Image.asset(
              chapter.bgImage,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
        ),

        // ── 2. VOILE DE PROFONDEUR CINÉMA ────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.65),
                Colors.black.withValues(alpha: 0.2),
                Colors.black.withValues(alpha: 0.75),
                const Color(0xFF070B14).withValues(alpha: 0.98),
              ],
              stops: const [0.0, 0.35, 0.70, 1.0],
            ),
          ),
        ),

        // ── 3. COUCHE VECTORIELLE : CARTE DU MANDEN AVEC CITÉS CLIQUABLES ─────
        if (chapter.isMapScene) ...[
          Positioned.fill(
            child: CustomPaint(
              painter: _AnimatedTradeRoutesPainter(
                progress: _pulseController.value,
              ),
            ),
          ),
          // Hotspots cliquables sur la carte plein écran
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;
                return Stack(
                  children: MandeCity.cities.map((city) {
                    final posX = city.relativeOffset.dx * width;
                    final posY = city.relativeOffset.dy * (height * 0.48);

                    return Positioned(
                      left: posX - 22,
                      top: posY - 22,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _showCityBottomSheet(city),
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, _) {
                                  final scale =
                                      1.0 + (_pulseController.value * 0.7);
                                  final opacity =
                                      (1.0 - _pulseController.value * 0.6)
                                          .clamp(0.0, 1.0);
                                  return Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFFF59E0B)
                                              .withValues(alpha: opacity),
                                          width: 1.8,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFF59E0B),
                                  border: Border.all(
                                      color: Colors.black, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF59E0B)
                                          .withValues(alpha: 0.8),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: const Color(0xFFF59E0B)
                                          .withValues(alpha: 0.5),
                                      width: 0.7,
                                    ),
                                  ),
                                  child: Text(
                                    city.name.split(' ').first,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],

        // Couche de poussière dorée pour Kirina
        if (chapter.isBattleScene)
          Positioned.fill(
            child: CustomPaint(
              painter: _BattlefieldDustPainter(
                progress: _dustController.value,
              ),
            ),
          ),

        // ── 4. FLÈCHE BLANCHE VOLANTE EN PLEIN ÉCRAN (KIRINA 1235) ────────────
        if (chapter.isBattleScene && _kirinaArrowFired)
          Positioned(
            left: 0,
            right: 0,
            bottom: 300,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final arenaWidth = constraints.maxWidth;
                return AnimatedBuilder(
                  animation: _kirinaArrowController,
                  builder: (context, _) {
                    final t = _kirinaArrowController.value;
                    final startX = 70.0;
                    final targetX = arenaWidth - 85.0;
                    final currentX = startX + (targetX - startX) * t;
                    final arcY = -math.sin(t * math.pi) * 45.0;

                    return Transform.translate(
                      offset: Offset(currentX, arcY),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Transform.rotate(
                          angle: (0.15 - (t * 0.3)),
                          child: _buildFlyingArrow(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

        // ── 5. PERSONNAGES 2D ANIMÉS PAR LE SCROLL (GAUCHE & DROITE) ──────────
        // Personnage de gauche (Soundiata)
        if (chapter.leftCharImage != null)
          Positioned(
            left: 20 + charLeftSlide,
            bottom: 270,
            child: _buildCinematicCharacter(
              name: chapter.leftCharName ?? 'Soundiata',
              role: chapter.leftCharRole ?? 'Héros',
              imagePath: chapter.leftCharImage!,
              accentColor: const Color(0xFFF59E0B),
              isFacingRight: true,
            ),
          ),

        // Personnage de droite (Soumaoro / Alliés)
        if (chapter.rightCharImage != null)
          Positioned(
            right: 20 - charRightSlide,
            bottom: 270,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: (chapter.isBattleScene && _kirinaSoumaoroDefeated)
                  ? 0.35
                  : 1.0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 600),
                scale: (chapter.isBattleScene && _kirinaSoumaoroDefeated)
                    ? 0.85
                    : 1.0,
                child: _buildCinematicCharacter(
                  name: (chapter.isBattleScene && _kirinaSoumaoroDefeated)
                      ? 'Soumaoro (En fuite)'
                      : (chapter.rightCharName ?? 'Adversaire'),
                  role: (chapter.isBattleScene && _kirinaSoumaoroDefeated)
                      ? 'Roi-Sorcier Vaincu'
                      : (chapter.rightCharRole ?? 'Sosso'),
                  imagePath: chapter.rightCharImage!,
                  accentColor:
                      (chapter.isBattleScene && _kirinaSoumaoroDefeated)
                          ? Colors.grey
                          : const Color(0xFFEF4444),
                  isFacingRight: false,
                ),
              ),
            ),
          ),

        // ── 6. CARTOUCHE NARRATIF AU BAS DE L'ÉCRAN AVEC MICRO-INTERACTIONS ──
        Positioned(
          left: 18,
          right: 18,
          bottom: 78,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1322).withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: chapter.isBattleScene
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
                    : const Color(0xFFF59E0B).withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // En-tête : Acte + Période + Badge d'ambiance sonore
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            chapter.period,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SoundiataSoundscapeBadge(
                      chapterNumber: chapter.number,
                      isDark: true,
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Texte narratif
                Text(
                  chapter.narrative,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFE2E8F0),
                    height: 1.45,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Citation synchronisée avec l'audio en direct (Waveform + Glow)
                SoundiataSynchronizedQuote(
                  quote: chapter.highlightQuote,
                  isActivelySpeaking: isCurrentlySpeaking && _currentPage == index,
                  isDark: true,
                ),

                // ── DÉCLENCHEURS DE MICRO-INTERACTIONS TACTILES ───────────────

                // 1. Bouton Cités Caravanières pour la Carte (Acte III)
                if (chapter.isMapScene) ...[
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: MandeCity.cities.map((city) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => _showCityBottomSheet(city),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(city.icon,
                                      size: 11,
                                      color: const Color(0xFFF59E0B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    city.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                // 2. Décocher la flèche magique pour Kirina (Acte VI)
                if (chapter.isBattleScene) ...[
                  const SizedBox(height: 10),
                  if (!_kirinaSoumaoroDefeated)
                    GestureDetector(
                      onTap: _shootKirinaArrow,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_upward_rounded,
                              color: Colors.black,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Décocher la Flèche d\'Ergot Blanc !',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: const Color(0xFF10B981)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Color(0xFF10B981), size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Soumaoro est touché ! Le Sosso est vaincu.',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _resetKirinaBattle,
                          icon: const Icon(Icons.refresh_rounded,
                              color: Color(0xFFF59E0B), size: 18),
                          tooltip: 'Rejouer le tir',
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                ],

                // 3. Déployer les 5 Articles de la Charte (Acte VII)
                if (chapter.isCharterScene) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _showCharterBottomSheet,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              const Color(0xFFF59E0B).withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.account_balance_rounded,
                              color: Color(0xFFF59E0B), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Déployer les 5 Articles Fondateurs (UNESCO)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.open_in_full_rounded,
                              color: Color(0xFFF59E0B), size: 13),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlyingArrow() {
    return Container(
      width: 46,
      height: 18,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.transparent, Color(0xFFF59E0B), Colors.white],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.9),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCinematicCharacter({
    required String name,
    required String role,
    required String imagePath,
    required Color accentColor,
    required bool isFacingRight,
  }) {
    return Column(
      crossAxisAlignment:
          isFacingRight ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: accentColor,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.5),
                blurRadius: 16,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 10,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => Container(
                color: accentColor,
                child: const Icon(Icons.person_rounded, color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: isFacingRight
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                role,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Peintre vectoriel pour les routes et cités de la Carte Ancienne du Mandé (Section 3)
class _AnimatedTradeRoutesPainter extends CustomPainter {
  final double progress;

  _AnimatedTradeRoutesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.75)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cityGlowPaint = Paint()
      ..color =
          const Color(0xFFF59E0B).withValues(alpha: 0.35 + (progress * 0.3))
      ..style = PaintingStyle.fill;

    final cityCenterPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Coordonnées relatives des grandes cités du Manden
    final niani = Offset(size.width * 0.33, size.height * 0.68);
    final kangaba = Offset(size.width * 0.42, size.height * 0.54);
    final kirina = Offset(size.width * 0.52, size.height * 0.50);
    final djenne = Offset(size.width * 0.66, size.height * 0.56);
    final timbuktu = Offset(size.width * 0.68, size.height * 0.36);
    final gao = Offset(size.width * 0.82, size.height * 0.38);

    // Tracé des routes caravanières
    final path = Path()
      ..moveTo(niani.dx, niani.dy)
      ..lineTo(kangaba.dx, kangaba.dy)
      ..lineTo(kirina.dx, kirina.dy)
      ..lineTo(djenne.dx, djenne.dy)
      ..lineTo(timbuktu.dx, timbuktu.dy)
      ..lineTo(gao.dx, gao.dy);

    canvas.drawPath(path, routePaint);

    // Points lumineux des cités avec pulsation
    final cities = [niani, kangaba, kirina, djenne, timbuktu, gao];
    for (final city in cities) {
      canvas.drawCircle(city, 7.0 + (progress * 3.0), cityGlowPaint);
      canvas.drawCircle(city, 3.0, cityCenterPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedTradeRoutesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Peintre de poussière dorée et étincelles de la Bataille de Kirina (Section 6)
class _BattlefieldDustPainter extends CustomPainter {
  final double progress;

  _BattlefieldDustPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = math.Random(42);
    final dustPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 28; i++) {
      final baseX = rand.nextDouble() * size.width;
      final baseY = rand.nextDouble() * size.height;
      final speed = 0.5 + rand.nextDouble();
      final currentY = (baseY - (progress * speed * size.height)) % size.height;
      final currentX = baseX + (math.sin(progress * 2 * math.pi + i) * 12);
      final radius = 1.0 + (rand.nextDouble() * 2.2);

      dustPaint.color = const Color(0xFFF59E0B).withValues(
        alpha: 0.15 + (rand.nextDouble() * 0.4),
      );

      canvas.drawCircle(Offset(currentX, currentY), radius, dustPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BattlefieldDustPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
