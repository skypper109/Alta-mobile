import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/vivienne_tts_service.dart';
import '../../core/datasources/historical_figure_sagas_data.dart';
import '../../core/models/culture_detail_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';

// Rétrocompatibilité : export des modèles et de la saga de Soundiata
export '../../core/datasources/historical_figure_sagas_data.dart';
final List<CharacterStoryChapter> kSoundiataFullStory =
    HistoricalFigureSagas.soundiata.chapters;

/// 🎬 EXPÉRIENCE CINÉMATIQUE CONTINUE — MOTION DESIGN VIDÉO PROFESSIONNEL
/// - AUCUNE COUPURE DU RÉCIT : L'histoire complète de chaque personnage est racontée de A à Z avec synchronisation vocale
/// - STRICTEMENT DANS LA CHARTE ALTERNIA : Or Mansa Moussa, Ocre Terre cuite, Sable Saharien, Bleu Nuit
/// - VRAIES IMAGES HISTORIQUES & VRAIS FAITS : Photoréalisme noble, faits avérés, monuments et décrets authentiques
/// - AFFICHAGE INTÉGRAL DU TEXTE : Panneau narratif dépliable et scrollable, aucune troncature par ellipsis
/// - ZÉRO DÉBORDEMENT PIXEL : En-tête responsive et fluide
/// - CONTRÔLES TOTAUX : Play/Pause, Recul -10s, Avance +10s, Tiroir du texte intégral de l'épopée
class SoundiataMotionDesignReelScreen extends ConsumerStatefulWidget {
  final String? figureId;
  final HistoricalFigureDetail? figure;

  const SoundiataMotionDesignReelScreen({
    super.key,
    this.figureId,
    this.figure,
  });

  @override
  ConsumerState<SoundiataMotionDesignReelScreen> createState() =>
      _SoundiataMotionDesignReelScreenState();
}

/// Écran universel de Motion Design Vidéo pour tous les personnages historiques
class CharacterMotionDesignReelScreen extends SoundiataMotionDesignReelScreen {
  const CharacterMotionDesignReelScreen({
    super.key,
    super.figureId,
    super.figure,
  });
}

class _SoundiataMotionDesignReelScreenState
    extends ConsumerState<SoundiataMotionDesignReelScreen>
    with TickerProviderStateMixin {
  // ── Animation Controllers ──────────────────────────────────────────────────
  late final AnimationController _cameraDriftController;
  late final AnimationController _particlesController;
  late final AnimationController _filmGrainController;
  late final AnimationController _lensFlareController;
  late final AnimationController _impactFlashController;
  late final AnimationController _screenShakeController;
  late final AnimationController _audioWaveController;

  // ── Saga active & Chapitres dynamiques ─────────────────────────────────────
  late final HistoricalFigureSaga _saga;
  late final List<CharacterStoryChapter> _chapters;
  late final double _totalDurationSeconds;

  // ── Timeline & Continuous Video Player State ──────────────────────────────
  int _currentChapterIndex = 0;
  bool _isPlaying = true;
  bool _isMuted = false;
  double _playbackSpeed = 1.0;

  // Temps continu en secondes au sein de toute l'épopée
  double _currentAbsoluteSeconds = 0.0;

  // Temps écoulé dans le chapitre courant
  double _chapterElapsedSeconds = 0.0;

  Timer? _playbackTicker;

  // Mode Duel / Antagoniste historique
  bool _showKirinaAntagonist = false;

  // Mode Déplié du Texte Narratif Intégral (lecture approfondie sans ellipsis)
  bool _isNarrativeExpanded = false;

  // Caméra tactile interactive 3D (tilt au doigt)
  double _tiltX = 0.0;
  double _tiltY = 0.0;
  Offset _panStart = Offset.zero;

  // Tiroir de lecture intégrale
  bool _showFullTranscriptDrawer = false;

  // Scroll controller pour le texte du récit
  final ScrollController _narrativeScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Résolution de la saga historique selon le personnage
    final targetId = widget.figureId ?? widget.figure?.id ?? 'perso_soundiata';
    _saga = HistoricalFigureSagas.getSaga(targetId);
    _chapters = _saga.chapters;

    // Calcul de la durée totale continue basée sur la durée de lecture réelle
    _totalDurationSeconds = _chapters
        .map((c) => c.readingDurationSeconds.toDouble())
        .reduce((a, b) => a + b);

    // 1. Dérive de caméra 2.5D continue (Ken Burns respiration noble)
    _cameraDriftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);

    // 2. Particules volumétriques 3D (poussière d'or du Sahel & braises ocres)
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    // 3. Grain argentique 35mm vivant
    _filmGrainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    // 4. Flare doré du soleil du Sahel balayant la lentille
    _lensFlareController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    // 5. Flash d'éclair & impact
    _impactFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // 6. Secousse de caméra (Screen Shake)
    _screenShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    // 7. Égaliseur audio vocal réactif
    _audioWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Démarrage de la lecture continue
    _startContinuousPlayback();
  }

  /// Démarre le moteur de lecture continue ininterrompu
  void _startContinuousPlayback() {
    _startPlaybackTicker();
    _playChapterNarration(_currentChapterIndex);
  }

  void _startPlaybackTicker() {
    _playbackTicker?.cancel();
    _playbackTicker =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isPlaying) return;

      setState(() {
        final step = 0.1 * _playbackSpeed;
        _currentAbsoluteSeconds += step;
        _chapterElapsedSeconds += step;

        final currentChapter = _chapters[_currentChapterIndex];
        final chapterTargetDuration =
            currentChapter.readingDurationSeconds.toDouble();

        // Si le mode muet est activé (lecture manuelle sans voix) ou si la durée maximale du chapitre est dépassée
        if (_isMuted && _chapterElapsedSeconds >= chapterTargetDuration) {
          _advanceToNextChapterAutomatically();
          return;
        }

        if (_currentAbsoluteSeconds >= _totalDurationSeconds) {
          _currentAbsoluteSeconds = _totalDurationSeconds;
          _isPlaying = false;
          _playbackTicker?.cancel();
        }
      });
    });
  }

  /// Avance automatiquement au chapitre suivant de manière fluide
  void _advanceToNextChapterAutomatically() {
    if (_currentChapterIndex < _chapters.length - 1) {
      final nextIndex = _currentChapterIndex + 1;
      _jumpToChapter(nextIndex);
    } else {
      setState(() {
        _isPlaying = false;
        _currentAbsoluteSeconds = _totalDurationSeconds;
      });
    }
  }

  double _getChapterStartSeconds(int index) {
    double accumulated = 0.0;
    for (int i = 0; i < index && i < _chapters.length; i++) {
      accumulated += _chapters[i].readingDurationSeconds;
    }
    return accumulated;
  }

  int _getChapterIndexAtSeconds(double seconds) {
    double accumulated = 0.0;
    for (int i = 0; i < _chapters.length; i++) {
      accumulated += _chapters[i].readingDurationSeconds;
      if (seconds <= accumulated) {
        return i;
      }
    }
    return _chapters.length - 1;
  }

  void _onChapterTransitioned(int newIndex) {
    _showKirinaAntagonist = false;
    _chapterElapsedSeconds = 0.0;

    // Réinitialiser le scroll du texte narratif
    if (_narrativeScrollController.hasClients) {
      _narrativeScrollController.jumpTo(0.0);
    }

    final curChapter = _chapters[newIndex];

    // Effet cinématique spécifique selon l'acte
    if (_saga.antagonistChapterId != null &&
        curChapter.id == _saga.antagonistChapterId) {
      _triggerKirinaImpact();
    } else if (curChapter.id == _saga.landmarkChapterId) {
      CulturalHaptics.celebration();
    } else {
      HapticFeedback.lightImpact();
    }

    _playChapterNarration(newIndex);
  }

  /// Raconte le chapitre de façon 100% complète sans aucune coupure prématurée
  void _playChapterNarration(int index) {
    if (_isMuted) return;

    try {
      final chapter = _chapters[index];
      VivienneTtsService.instance.stop();

      VivienneTtsService.instance.speak(
        chapter.fullNarrative,
        onComplete: () {
          // La synthèse vocale a lu l'INTÉGRALITÉ du chapitre sans coupure !
          // On attend un souffle cinématique de 1.2s avant de glisser au chapitre suivant
          if (mounted && _isPlaying && _currentChapterIndex == index) {
            Future.delayed(const Duration(milliseconds: 1200), () {
              if (mounted && _isPlaying && _currentChapterIndex == index) {
                _advanceToNextChapterAutomatically();
              }
            });
          }
        },
        onError: (_) {
          // Repli silencieux élégant
        },
      );
    } catch (_) {}
  }

  void _triggerKirinaImpact() {
    _impactFlashController.forward(from: 0.0);
    _screenShakeController.forward(from: 0.0);
    HapticFeedback.heavyImpact();
  }

  void _toggleKirinaDuelAntagonist() {
    if (_saga.antagonistChapterId == null ||
        _chapters[_currentChapterIndex].id != _saga.antagonistChapterId) {
      return;
    }
    setState(() {
      _showKirinaAntagonist = !_showKirinaAntagonist;
    });
    _triggerKirinaImpact();
  }

  void _openLandmarkCharterModal() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: BoxDecoration(
            color: CultureTheme.darkSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: _saga.primaryAccent.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Poignée de glissement
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _saga.primaryAccent.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // En-tête de la Charte / Décret
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _saga.primaryAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _saga.primaryAccent,
                          width: 1.2,
                        ),
                      ),
                      child: Icon(
                        Icons.gavel_rounded,
                        color: _saga.primaryAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _saga.landmarkModalTitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: CultureTheme.sable,
                            ),
                          ),
                          Text(
                            _saga.landmarkModalSubtitle,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _saga.primaryAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: CultureTheme.sable),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(color: CultureTheme.darkBorder, height: 1),

              // Liste des articles fondamentaux
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _saga.landmarkArticles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final art = _saga.landmarkArticles[idx];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: CultureTheme.darkBackground.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _saga.primaryAccent.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _saga.primaryAccent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'ARTICLE ${art.number}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: _saga.primaryAccent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  art.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: CultureTheme.sable,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            art.quote,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: _saga.primaryAccent,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            art.explanation,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              color: CultureTheme.sable.withValues(alpha: 0.85),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Contrôles de lecture vidéo continue ───────────────────────────────────

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _startPlaybackTicker();
      if (!_isMuted) {
        _playChapterNarration(_currentChapterIndex);
      }
    } else {
      VivienneTtsService.instance.stop();
    }
    HapticFeedback.selectionClick();
  }

  void _seekTo(double targetSeconds) {
    setState(() {
      _currentAbsoluteSeconds = targetSeconds.clamp(0.0, _totalDurationSeconds);
      final newIndex = _getChapterIndexAtSeconds(_currentAbsoluteSeconds);
      final chapterChanged = newIndex != _currentChapterIndex;
      _currentChapterIndex = newIndex;
      _chapterElapsedSeconds =
          _currentAbsoluteSeconds - _getChapterStartSeconds(newIndex);

      if (chapterChanged || _isPlaying) {
        _onChapterTransitioned(_currentChapterIndex);
      }
    });
    HapticFeedback.selectionClick();
  }

  void _seekRelative(double deltaSeconds) {
    _seekTo(_currentAbsoluteSeconds + deltaSeconds);
  }

  void _jumpToChapter(int index) {
    if (index >= 0 && index < _chapters.length) {
      final target = _getChapterStartSeconds(index) + 0.1;
      setState(() {
        _currentAbsoluteSeconds = target;
        _currentChapterIndex = index;
        _chapterElapsedSeconds = 0.0;
        _onChapterTransitioned(index);
      });
      HapticFeedback.selectionClick();
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    if (_isMuted) {
      VivienneTtsService.instance.stop();
    } else if (_isPlaying) {
      _playChapterNarration(_currentChapterIndex);
    }
    HapticFeedback.selectionClick();
  }

  void _cyclePlaybackSpeed() {
    setState(() {
      if (_playbackSpeed == 1.0) {
        _playbackSpeed = 0.75; // Rythme posé & solennel
      } else {
        _playbackSpeed = 1.0;
      }
    });
    HapticFeedback.selectionClick();
  }

  String _formatTime(double seconds) {
    final s = seconds.floor();
    final mins = s ~/ 60;
    final secs = s % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void deactivate() {
    _playbackTicker?.cancel();
    try {
      VivienneTtsService.instance.stop();
    } catch (_) {}
    super.deactivate();
  }

  @override
  void dispose() {
    _playbackTicker?.cancel();
    try {
      VivienneTtsService.instance.stop();
    } catch (_) {}
    _narrativeScrollController.dispose();
    _cameraDriftController.dispose();
    _particlesController.dispose();
    _filmGrainController.dispose();
    _lensFlareController.dispose();
    _impactFlashController.dispose();
    _screenShakeController.dispose();
    _audioWaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentChapter = _chapters[_currentChapterIndex];
    final size = MediaQuery.of(context).size;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        _playbackTicker?.cancel();
        VivienneTtsService.instance.stop();
      },
      child: Scaffold(
        backgroundColor: CultureTheme.darkBackground,
        body: GestureDetector(
          onTapDown: (details) {
            // Si le tiroir est ouvert, ne rien faire
            if (_showFullTranscriptDrawer) return;

            // Tap gauche = -10s, Tap droite = +10s, Tap centre = toggle pause
            final dx = details.localPosition.dx;
            final dy = details.localPosition.dy;

            // N'intercepter le tap que si on ne touche pas les boutons du dock en bas ni l'en-tête
            if (dy < size.height * 0.65 && dy > 110) {
              if (dx < size.width * 0.28) {
                _seekRelative(-10);
              } else if (dx > size.width * 0.72) {
                _seekRelative(10);
              } else {
                _togglePlayPause();
              }
            }
          },
          onPanStart: (details) {
            _panStart = details.localPosition;
          },
          onPanUpdate: (details) {
            final delta = details.localPosition - _panStart;
            setState(() {
              _tiltX = (delta.dy / size.height).clamp(-0.20, 0.20);
              _tiltY = (-delta.dx / size.width).clamp(-0.20, 0.20);
            });
          },
          onPanEnd: (_) {
            setState(() {
              _tiltX = 0.0;
              _tiltY = 0.0;
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── 1. PLAN DE FOND 9:16 PLEIN ÉCRAN : PHOTORÉALISME & KEN BURNS ──
              _buildFullBleedCanvas(currentChapter),

              // ── 2. PARTICULES VOLUMÉTRIQUES 3D : POUSSIÈRE D'OR DU SAHEL ───────
              _buildVolumetricParticlesLayer(),

              // ── 3. FLARE SOLAIRE ANAMORPHIQUE BALAYANT LA LENTILLE ────────────
              _buildAnamorphicFlareLayer(),

              // ── 4. GRAIN DE FILM 35mm RÉALISTE & TEXTURE CINÉMA ───────────────
              _buildFilmGrainLayer(),

              // ── 5. FLASH D'ÉCLAIR & IMPACT DE BATAILLE ────────────────────────
              _buildImpactFlashLayer(),

              // ── 6. DÉGRADÉ CINÉMATIQUE SOMBRE (PROTECTION DE LECTURE) ─────────
              _buildCinematicVignette(),

              // ── 7. TITRES CINÉMATIQUES & CITATIONS HISTORIQUES DU CHAPITRE ───
              _buildCinematicTypographyOverlay(currentChapter),

              // ── 8. BARRE SUPÉRIEURE ÉPURÉE ET RESPONSIVE SANS OVERFLOW ────────
              _buildTopHeaderControls(),

              // ── 9. DOCK VIDÉO CONTINU : NARRATION INTÉGRALE & SCRUBBER FLUIDE ─
              _buildContinuousVideoPlayerDock(currentChapter),

              // ── 10. MODAL / TIROIR DU TEXTE INTÉGRAL DE L'ÉPOPÉE ──────────────
              if (_showFullTranscriptDrawer) _buildFullTranscriptDrawer(),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // 1. CANVAS PLEIN ÉCRAN PHOTORÉALISTE 9:16 (FULL BLEED SANS BORDURES)
  // ══════════════════════════════════════════════════════════════════════════════

  Widget _buildFullBleedCanvas(SoundiataStoryChapter chapter) {
    final imagePath = (_showKirinaAntagonist && chapter.antagonistImage != null)
        ? chapter.antagonistImage!
        : chapter.mainImage;

    return AnimatedBuilder(
      animation: Listenable.merge([
        _cameraDriftController,
        _screenShakeController,
      ]),
      builder: (context, child) {
        final driftVal = _cameraDriftController.value;
        final scale = 1.05 + (driftVal * 0.08);
        final panX = math.sin(driftVal * math.pi) * 10.0;
        final panY = math.cos(driftVal * math.pi) * 8.0;

        // Secousse d'impact caméra
        double shakeX = 0.0;
        double shakeY = 0.0;
        if (_screenShakeController.isAnimating) {
          final shakeVal = math.sin(_screenShakeController.value * math.pi * 8);
          final damp = 1.0 - _screenShakeController.value;
          shakeX = shakeVal * 14.0 * damp;
          shakeY = math.cos(_screenShakeController.value * math.pi * 6) *
              10.0 *
              damp;
        }

        // Matrice de perspective 3D au doigt
        final perspectiveMatrix = Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateX(_tiltX)
          ..rotateY(_tiltY);

        return Transform(
          transform: perspectiveMatrix,
          alignment: Alignment.center,
          child: Transform.translate(
            offset: Offset(panX + shakeX, panY + shakeY),
            child: Transform.scale(
              scale: scale,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 700),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                child: Image.asset(
                  imagePath,
                  key: ValueKey<String>(imagePath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                  errorBuilder: (_, __, ___) => Container(
                    color: CultureTheme.darkSurface,
                    child: const Center(
                      child: Icon(
                        Icons.auto_stories_rounded,
                        color: CultureTheme.orPatrimoine,
                        size: 56,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // 2. EFFETS CINÉMATIQUES CONFORMES À LA CHARTE ALTERNIA
  // ══════════════════════════════════════════════════════════════════════════════

  Widget _buildFilmGrainLayer() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _filmGrainController,
          builder: (context, _) {
            return CustomPaint(
              painter: _FilmGrainPainter(
                timeTick: (_filmGrainController.value * 20).floor(),
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnamorphicFlareLayer() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _lensFlareController,
          builder: (context, _) {
            return CustomPaint(
              painter: _AnamorphicFlarePainter(
                progress: _lensFlareController.value,
                color: _saga.primaryAccent,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }

  Widget _buildVolumetricParticlesLayer() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _particlesController,
          builder: (context, _) {
            return CustomPaint(
              painter: _VolumetricEmberParticlesPainter(
                progress: _particlesController.value,
                goldColor: _saga.primaryAccent,
                ochreColor: _saga.secondaryAccent,
              ),
              size: Size.infinite,
            );
          },
        ),
      ),
    );
  }

  Widget _buildImpactFlashLayer() {
    return AnimatedBuilder(
      animation: _impactFlashController,
      builder: (context, _) {
        if (_impactFlashController.value <= 0.0) {
          return const SizedBox.shrink();
        }
        final flashAlpha = (1.0 - _impactFlashController.value) * 0.88;
        return IgnorePointer(
          child: Container(
            color: CultureTheme.sable.withValues(alpha: flashAlpha),
          ),
        );
      },
    );
  }

  Widget _buildCinematicVignette() {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.20, 0.45, 0.72, 1.0],
              colors: [
                CultureTheme.darkBackground.withValues(alpha: 0.90),
                CultureTheme.darkBackground.withValues(alpha: 0.35),
                Colors.transparent,
                CultureTheme.darkBackground.withValues(alpha: 0.75),
                CultureTheme.darkBackground.withValues(alpha: 0.98),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // 3. EN-TÊTE SUPÉRIEURE (100% RESPONSIVE SANS AUCUN DÉBORDEMENT RENDERFLEX)
  // ══════════════════════════════════════════════════════════════════════════════

  Widget _buildTopHeaderControls() {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 6,
      left: 14,
      right: 14,
      child: Row(
        children: [
          // Bouton Retour circulaire épuré
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              VivienneTtsService.instance.stop();
              context.pop();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: CultureTheme.darkSurface.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _saga.primaryAccent.withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: CultureTheme.sable,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Badge Titre de l'Épopée (avec Flexible pour absorber la largeur)
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: CultureTheme.darkSurface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _saga.primaryAccent.withValues(alpha: 0.35),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 13,
                    color: _saga.primaryAccent,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _saga.sagaTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: CultureTheme.sable,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Bouton Récit Complet (Transcrit complet de l'épopée)
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _showFullTranscriptDrawer = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: CultureTheme.darkSurface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.5),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 12,
                    color: CultureTheme.accentOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Récit',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: CultureTheme.sable,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Vitesse de lecture
          GestureDetector(
            onTap: _cyclePlaybackSpeed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
              decoration: BoxDecoration(
                color: CultureTheme.darkSurface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _playbackSpeed != 1.0
                      ? CultureTheme.orPatrimoine
                      : CultureTheme.darkBorder,
                  width: 1.0,
                ),
              ),
              child: Text(
                '${_playbackSpeed}x',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _playbackSpeed != 1.0
                      ? CultureTheme.orPatrimoine
                      : CultureTheme.sable,
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Mute / Voix Vivienne
          GestureDetector(
            onTap: _toggleMute,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: CultureTheme.darkSurface.withValues(alpha: 0.85),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isMuted
                      ? CultureTheme.darkBorder
                      : CultureTheme.orPatrimoine.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
              child: Icon(
                _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                size: 15,
                color: _isMuted
                    ? CultureTheme.textMutedDark
                    : CultureTheme.orPatrimoine,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // 4. TYPOGRAPHIE CINÉMATIQUE ET CITATION HÉROÏQUE
  // ══════════════════════════════════════════════════════════════════════════════

  Widget _buildCinematicTypographyOverlay(SoundiataStoryChapter chapter) {
    // Si le panneau de lecture intégrale est déplié, on allège la typographie haute
    final bottomOffset = _isNarrativeExpanded ? 245.0 : 190.0;

    return Positioned(
      left: 18,
      right: 18,
      bottom: bottomOffset,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ligne de repère chronologique & lieu
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 1,
                color: CultureTheme.orPatrimoine.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  color: CultureTheme.darkBackground.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: CultureTheme.orPatrimoine.withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  '${chapter.chapterNumber} • ${chapter.kicker}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: CultureTheme.orPatrimoine,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 1,
                color: CultureTheme.orPatrimoine.withValues(alpha: 0.5),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Titre Majeur du Chapitre en Or Pur AlterniA
          Text(
            chapter.title.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              color: CultureTheme.sable,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.9),
                  blurRadius: 16,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Cartouche de citation héroïque en verre sombre et bordure or
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: CultureTheme.darkSurface.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: CultureTheme.orPatrimoine.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  '« ${chapter.kineticQuotes.first} »',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: CultureTheme.sable,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),

          // Bouton duel / antagoniste dynamique selon le personnage
          if (_saga.antagonistChapterId != null &&
              chapter.id == _saga.antagonistChapterId &&
              chapter.antagonistImage != null) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _toggleKirinaDuelAntagonist,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4.5,
                ),
                decoration: BoxDecoration(
                  color: _showKirinaAntagonist
                      ? _saga.secondaryAccent.withValues(alpha: 0.35)
                      : CultureTheme.darkSurface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _saga.secondaryAccent,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swap_horiz_rounded,
                      size: 13,
                      color: _saga.secondaryAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showKirinaAntagonist
                          ? (_saga.antagonistPrimaryLabel ?? 'VOIR LE HÉROS')
                          : (_saga.antagonistSecondaryLabel ?? 'VOIR L\'ADVERSAIRE'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: CultureTheme.sable,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Bouton interactif Décret / Charte / Pacte Historique du personnage
          if (_saga.landmarkChapterId.isNotEmpty &&
              chapter.id == _saga.landmarkChapterId) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _openLandmarkCharterModal,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4.5,
                ),
                decoration: BoxDecoration(
                  color: _saga.primaryAccent.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _saga.primaryAccent,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.gavel_rounded,
                      size: 13,
                      color: _saga.primaryAccent,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _saga.landmarkModalButtonText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: CultureTheme.sable,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // 5. DOCK VIDÉO CONTINU : NARRATION COMPLÈTE SANS COUPURE NI ELLIPSIS
  // ══════════════════════════════════════════════════════════════════════════════

  Widget _buildContinuousVideoPlayerDock(SoundiataStoryChapter currentChapter) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final progressFactor =
        (_currentAbsoluteSeconds / _totalDurationSeconds).clamp(0.0, 1.0);

    return Positioned(
      left: 14,
      right: 14,
      bottom: bottomPadding > 0 ? bottomPadding + 4 : 10,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── PANNEAU DU RÉCIT INTÉGRAL (AUCUNE COUPURE, SCROLLABLE ET DÉPLIABLE)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                constraints: BoxConstraints(
                  maxHeight: _isNarrativeExpanded ? 130 : 64,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: CultureTheme.darkSurface.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: CultureTheme.orPatrimoine.withValues(alpha: 0.35),
                    width: 1.0,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barre d'état de narration et bascule mode déplié
                    Row(
                      children: [
                        _buildAudioWaveVisualizer(),
                        const SizedBox(width: 8),
                        Text(
                          _isMuted
                              ? 'Lecture Silencieuse'
                              : 'Narration Vocale',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: CultureTheme.orPatrimoine,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isNarrativeExpanded = !_isNarrativeExpanded;
                            });
                            HapticFeedback.selectionClick();
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isNarrativeExpanded
                                    ? 'Réduire'
                                    : 'Lire tout le texte',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: CultureTheme.accentOrange,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                _isNarrativeExpanded
                                    ? Icons.keyboard_arrow_down_rounded
                                    : Icons.keyboard_arrow_up_rounded,
                                size: 14,
                                color: CultureTheme.accentOrange,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // Corps du texte narratif complet (scrollable au doigt sans aucune coupure)
                    Expanded(
                      child: RawScrollbar(
                        controller: _narrativeScrollController,
                        thumbColor:
                            CultureTheme.orPatrimoine.withValues(alpha: 0.4),
                        radius: const Radius.circular(4),
                        thickness: 2.5,
                        child: SingleChildScrollView(
                          controller: _narrativeScrollController,
                          physics: const BouncingScrollPhysics(),
                          child: Text(
                            currentChapter.fullNarrative,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: CultureTheme.sable,
                              height: 1.45,
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

          const SizedBox(height: 8),

          // ── DOCK DES CONTRÔLES MÉDIA & SCRUBBER FLUIDE ──────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: CultureTheme.darkBackground.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: CultureTheme.darkBorder,
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Slider continu et progression
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Barre de fond continue
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: CultureTheme.darkSurfaceAlt,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Barre de progression remplie continue en Or Patrimoine
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progressFactor,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: CultureTheme.orPatrimoine,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: CultureTheme.orPatrimoine
                                  .withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Slider pour naviguer au toucher
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        thumbColor: CultureTheme.sable,
                        overlayColor:
                            CultureTheme.orPatrimoine.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: _currentAbsoluteSeconds,
                        min: 0.0,
                        max: _totalDurationSeconds,
                        onChanged: (val) {
                          _seekTo(val);
                        },
                      ),
                    ),
                  ],
                ),

                // Ligne du temps & titre du chapitre
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatTime(_currentAbsoluteSeconds),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: CultureTheme.orPatrimoine,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${currentChapter.chapterNumber} : ${currentChapter.title}',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: CultureTheme.sable.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      _formatTime(_totalDurationSeconds),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: CultureTheme.textMutedDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Boutons de navigation cinématiques : Chapitre Précédent, Recul 10s, Play/Pause, Avance 10s, Suivant
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Chapitre Précédent
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded),
                      color: CultureTheme.sable.withValues(alpha: 0.7),
                      iconSize: 22,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Chapitre précédent',
                      onPressed: () {
                        if (_currentChapterIndex > 0) {
                          _jumpToChapter(_currentChapterIndex - 1);
                        }
                      },
                    ),

                    // Recul de 10 secondes
                    IconButton(
                      icon: const Icon(Icons.replay_10_rounded),
                      color: CultureTheme.sable,
                      iconSize: 24,
                      visualDensity: VisualDensity.compact,
                      tooltip: '-10 secondes',
                      onPressed: () => _seekRelative(-10),
                    ),

                    const SizedBox(width: 10),

                    // Bouton Play / Pause avec aura Or & Orange AlterniA
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: CultureTheme.accentOrange,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: CultureTheme.accentOrange
                                  .withValues(alpha: 0.45),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 26,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Avance de 10 secondes
                    IconButton(
                      icon: const Icon(Icons.forward_10_rounded),
                      color: CultureTheme.sable,
                      iconSize: 24,
                      visualDensity: VisualDensity.compact,
                      tooltip: '+10 secondes',
                      onPressed: () => _seekRelative(10),
                    ),

                    // Chapitre Suivant
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded),
                      color: CultureTheme.sable.withValues(alpha: 0.7),
                      iconSize: 22,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Chapitre suivant',
                      onPressed: () {
                        if (_currentChapterIndex <
                            _chapters.length - 1) {
                          _jumpToChapter(_currentChapterIndex + 1);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioWaveVisualizer() {
    return AnimatedBuilder(
      animation: _audioWaveController,
      builder: (context, _) {
        final t = _audioWaveController.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(4, (i) {
            final barHeight = _isPlaying && !_isMuted
                ? 5.0 + (math.sin((t * math.pi * 2) + (i * 0.9)).abs() * 9.0)
                : 3.5;
            return Container(
              width: 2.5,
              height: barHeight,
              margin: const EdgeInsets.symmetric(horizontal: 1.2),
              decoration: BoxDecoration(
                color: _saga.primaryAccent,
                borderRadius: BorderRadius.circular(1.5),
              ),
            );
          }),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════════
  // 6. TIROIR MODAL DU RÉCIT INTÉGRAL DE L'ÉPOPÉE (TOUT EST DIT & CONFORME)
  // ══════════════════════════════════════════════════════════════════════════════

  Widget _buildFullTranscriptDrawer() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showFullTranscriptDrawer = false;
          });
        },
        child: Container(
          color: CultureTheme.darkBackground.withValues(alpha: 0.92),
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Empêcher la fermeture au tap sur le contenu
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: CultureTheme.darkSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _saga.primaryAccent.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _saga.primaryAccent.withValues(alpha: 0.25),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // En-tête du tiroir
                    Row(
                      children: [
                        Icon(
                          Icons.auto_stories_rounded,
                          color: _saga.primaryAccent,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_saga.sagaTitle} • Récit Intégral',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: CultureTheme.sable,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: CultureTheme.sable),
                          onPressed: () {
                            setState(() {
                              _showFullTranscriptDrawer = false;
                            });
                          },
                        ),
                      ],
                    ),

                    const Divider(
                      color: CultureTheme.darkBorder,
                      height: 18,
                    ),

                    // Liste scrollable des chapitres complets
                    Expanded(
                      child: ListView.separated(
                        itemCount: _chapters.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: CultureTheme.darkBorder,
                          height: 20,
                        ),
                        itemBuilder: (context, idx) {
                          final c = _chapters[idx];
                          final isCurrent = idx == _currentChapterIndex;

                          return GestureDetector(
                            onTap: () {
                              _jumpToChapter(idx);
                              setState(() {
                                _showFullTranscriptDrawer = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? _saga.primaryAccent
                                        .withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: isCurrent
                                    ? Border.all(
                                        color: _saga.primaryAccent,
                                        width: 1.0,
                                      )
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        c.chapterNumber,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w900,
                                          color: _saga.primaryAccent,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          c.title,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w800,
                                            color: CultureTheme.sable,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    c.fullNarrative,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w400,
                                      color: CultureTheme.sable
                                          .withValues(alpha: 0.9),
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PEINTRES SUR-MESURE HAUTE PERFORMANCE (CHARTE ALTERNIA STRICTE)
// ══════════════════════════════════════════════════════════════════════════════

class _FilmGrainPainter extends CustomPainter {
  final int timeTick;
  _FilmGrainPainter({required this.timeTick});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(timeTick);
    final paint = Paint()
      ..color = CultureTheme.sable.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    const grainCount = 120;
    for (int i = 0; i < grainCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.5 + (random.nextDouble() * 0.8);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FilmGrainPainter oldDelegate) {
    return oldDelegate.timeTick != timeTick;
  }
}

class _AnamorphicFlarePainter extends CustomPainter {
  final double progress;
  final Color color;

  _AnamorphicFlarePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final flareY = size.height * (0.35 + (progress * 0.20));
    final flareX = size.width * (0.15 + (progress * 0.70));

    final streakPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, flareY),
        Offset(size.width, flareY),
        [
          Colors.transparent,
          color.withValues(alpha: 0.14),
          CultureTheme.sable.withValues(alpha: 0.22),
          color.withValues(alpha: 0.14),
          Colors.transparent,
        ],
        [0.0, 0.35, 0.5, 0.65, 1.0],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawLine(Offset(0, flareY), Offset(size.width, flareY), streakPaint);

    final haloPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(flareX, flareY),
        65,
        [
          color.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      );
    canvas.drawCircle(Offset(flareX, flareY), 65, haloPaint);
  }

  @override
  bool shouldRepaint(covariant _AnamorphicFlarePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _VolumetricEmberParticlesPainter extends CustomPainter {
  final double progress;
  final Color goldColor;
  final Color ochreColor;

  _VolumetricEmberParticlesPainter({
    required this.progress,
    required this.goldColor,
    required this.ochreColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const particleCount = 24;
    final random = math.Random(77);

    for (int i = 0; i < particleCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final speed = 0.4 + (random.nextDouble() * 0.7);
      final radius = 0.9 + (random.nextDouble() * 2.2);

      final yOffset =
          ((progress * speed * size.height) + (i * 30)) % size.height;
      final y = size.height - yOffset;
      final x = baseX + (math.sin((progress * 4) + i) * 12);

      final alpha = (0.2 + (random.nextDouble() * 0.55)) *
          (1.0 - (y / size.height)).clamp(0.0, 1.0);

      final color = i % 2 == 0 ? goldColor : ochreColor;

      final paint = Paint()
        ..color = color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VolumetricEmberParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.goldColor != goldColor ||
        oldDelegate.ochreColor != ochreColor;
  }
}

/// 📜 Article de la Charte de Kouroukan Fouga (1236)
class CharterArticle {
  final int number;
  final String title;
  final String quote;
  final String explanation;
  final IconData icon;

  const CharterArticle({
    required this.number,
    required this.title,
    required this.quote,
    required this.explanation,
    required this.icon,
  });

  static const List<CharterArticle> fundamentalArticles = [
    CharterArticle(
      number: 5,
      title: 'Inviolabilité de la Vie Humaine',
      quote:
          '« Toute vie humaine est une vie. Une vie ne vaut ni plus ni moins qu\'une autre vie. Le tort fait à l\'un est un tort fait à tous. Nul ne doit humilier son semblable. »',
      explanation:
          'Consacrée dès 1236, cette loi sacrée abolit le meurtre arbitraire, protège l\'intégrité physique de tout individu et pose l\'égalité primordiale des êtres vivants, 550 ans avant les déclarations occidentales.',
      icon: Icons.favorite_rounded,
    ),
    CharterArticle(
      number: 7,
      title: 'La Sanankouya (Parenté à Plaisanterie)',
      quote:
          '« Il est institué entre clans alliés le pacte sacré de Sanankouya. L\'humour et la dérision amicale désarmeront la haine et interdiront à jamais l\'effusion de sang entre frères. »',
      explanation:
          'Un génie sociologique unique au monde : un pacte de médiation par la plaisanterie codifiée entre patronymes (ex: Keïta et Traoré, Coulibaly et Touré) qui désamorce tout conflit avant qu\'il n\'éclate.',
      icon: Icons.handshake_rounded,
    ),
    CharterArticle(
      number: 16,
      title: 'Protection et Dignité des Femmes',
      quote:
          '« Les femmes sont nos mères et la source sacrée de la paix sociale. Ne provoquez jamais leur colère et veillez à leur respect dans chaque concession. »',
      explanation:
          'La charte place la femme au sommet de l\'autorité morale et familiale, interdisant les violences domestiques et garantissant sa protection dans toute l\'étendue de l\'empire.',
      icon: Icons.shield_rounded,
    ),
    CharterArticle(
      number: 20,
      title: 'L\'Hospitalité Sacrée (Diya)',
      quote:
          '« L\'étranger qui entre dans votre village est sous la protection inviolable du Manden. Partagez avec lui le bol et le toit, nul ne doit être dépouillé de ses biens sur nos terres. »',
      explanation:
          'Fondement de la sécurité des routes commerciales et de l\'accueil universel, garantissant la libre circulation des marchands, voyageurs et érudits de toutes nations.',
      icon: Icons.home_work_rounded,
    ),
    CharterArticle(
      number: 37,
      title: 'Sauvegarde de la Nature & Forêts',
      quote:
          '« Ne mettez point le feu à la brousse sans discernement. Préservez les grands arbres, les bêtes sacrées et les cours d\'eau qui étanchent la soif de nos générations futures. »',
      explanation:
          'L\'une des toutes premières chartes écologiques de l\'histoire humaine, réglementant la coupe des arbres, les feux de brousse et protégeant la faune et les berges du fleuve Djoliba.',
      icon: Icons.forest_rounded,
    ),
  ];
}
