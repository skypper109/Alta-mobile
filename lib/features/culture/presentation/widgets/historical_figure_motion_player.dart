import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/services/vivienne_tts_service.dart';
import '../../core/datasources/historical_figure_sagas_data.dart';
import '../../core/models/culture_detail_models.dart';
import '../../core/theme/culture_theme.dart';

/// Lecteur Épopée Motion Design intégré en 1ère position
/// Offre une expérience cinématique vivante avec :
/// - Scènes illustrées et drift caméra Ken Burns
/// - Particules volumétriques de poussière dorée du Sahel
/// - Balayage de flare solaire et texture argentique 35mm
/// - Narration vocale continue Vivienne synchronisée
/// - Contrôles de lecture (Play/Pause, Acte Précédent/Suivant, -10s, +10s, Muet)
/// - Bouton d'immersion plein écran (Reel 9:16)
/// - Accès direct au Mode Lecture approfondie
class HistoricalFigureMotionPlayer extends StatefulWidget {
  final HistoricalFigureDetail figure;
  final bool isDark;
  final VoidCallback? onReadingModeRequested;
  final ValueChanged<int>? onChapterChanged;
  final int initialChapterIndex;

  const HistoricalFigureMotionPlayer({
    super.key,
    required this.figure,
    required this.isDark,
    this.onReadingModeRequested,
    this.onChapterChanged,
    this.initialChapterIndex = 0,
  });

  @override
  State<HistoricalFigureMotionPlayer> createState() =>
      _HistoricalFigureMotionPlayerState();
}

class _HistoricalFigureMotionPlayerState
    extends State<HistoricalFigureMotionPlayer>
    with TickerProviderStateMixin {
  late final HistoricalFigureSaga _saga;
  late final List<CharacterStoryChapter> _chapters;
  late final double _totalDurationSeconds;

  late final AnimationController _cameraDriftController;
  late final AnimationController _particlesController;
  late final AnimationController _filmGrainController;
  late final AnimationController _lensFlareController;
  late final AnimationController _audioWaveController;

  int _currentChapterIndex = 0;
  bool _isPlaying = false;
  bool _isMuted = false;
  double _currentAbsoluteSeconds = 0.0;
  double _chapterElapsedSeconds = 0.0;
  Timer? _playbackTicker;

  @override
  void initState() {
    super.initState();
    _saga = HistoricalFigureSagas.getSaga(widget.figure.id);
    _chapters = _saga.chapters;

    _totalDurationSeconds = _chapters.isNotEmpty
        ? _chapters
            .map((c) => c.readingDurationSeconds.toDouble())
            .reduce((a, b) => a + b)
        : 60.0;

    _currentChapterIndex = widget.initialChapterIndex.clamp(
      0,
      math.max(0, _chapters.length - 1),
    );

    // 1. Dérive Ken Burns continue
    _cameraDriftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat(reverse: true);

    // 2. Particules volumétriques dorées
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // 3. Grain de film
    _filmGrainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat();

    // 4. Flare solaire anamorphique
    _lensFlareController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat(reverse: true);

    // 5. Visualiseur audio réactif
    _audioWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  void _startPlaybackTicker() {
    _playbackTicker?.cancel();
    _playbackTicker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_isPlaying || !mounted) return;

      setState(() {
        const step = 0.1;
        _currentAbsoluteSeconds += step;
        _chapterElapsedSeconds += step;

        final curChapter = _chapters[_currentChapterIndex];
        final maxDuration = curChapter.readingDurationSeconds.toDouble();

        if (_isMuted && _chapterElapsedSeconds >= maxDuration) {
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

  void _advanceToNextChapterAutomatically() {
    if (_currentChapterIndex < _chapters.length - 1) {
      _jumpToChapter(_currentChapterIndex + 1);
    } else {
      setState(() {
        _isPlaying = false;
        _currentAbsoluteSeconds = _totalDurationSeconds;
      });
      _playbackTicker?.cancel();
    }
  }

  double _getChapterStartSeconds(int index) {
    double accumulated = 0.0;
    for (int i = 0; i < index && i < _chapters.length; i++) {
      accumulated += _chapters[i].readingDurationSeconds;
    }
    return accumulated;
  }

  void _playChapterNarration(int index) {
    if (_isMuted || index >= _chapters.length) return;

    try {
      final chapter = _chapters[index];
      VivienneTtsService.instance.stop();

      VivienneTtsService.instance.speak(
        chapter.fullNarrative,
        onComplete: () {
          if (mounted && _isPlaying && _currentChapterIndex == index) {
            Future.delayed(const Duration(milliseconds: 1200), () {
              if (mounted && _isPlaying && _currentChapterIndex == index) {
                _advanceToNextChapterAutomatically();
              }
            });
          }
        },
      );
    } catch (_) {}
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _startPlaybackTicker();
      _playChapterNarration(_currentChapterIndex);
    } else {
      _playbackTicker?.cancel();
      VivienneTtsService.instance.stop();
    }
    HapticFeedback.selectionClick();
  }

  void _jumpToChapter(int index) {
    if (index >= 0 && index < _chapters.length) {
      final target = _getChapterStartSeconds(index) + 0.1;
      setState(() {
        _currentAbsoluteSeconds = target;
        _currentChapterIndex = index;
        _chapterElapsedSeconds = 0.0;
      });
      widget.onChapterChanged?.call(index);

      if (_isPlaying) {
        _playChapterNarration(index);
      }
      HapticFeedback.selectionClick();
    }
  }

  void _seekRelative(double delta) {
    final next = (_currentAbsoluteSeconds + delta).clamp(
      0.0,
      _totalDurationSeconds,
    );
    double accumulated = 0.0;
    int targetIndex = 0;
    for (int i = 0; i < _chapters.length; i++) {
      accumulated += _chapters[i].readingDurationSeconds;
      if (next <= accumulated) {
        targetIndex = i;
        break;
      }
    }

    setState(() {
      _currentAbsoluteSeconds = next;
      _currentChapterIndex = targetIndex;
      _chapterElapsedSeconds =
          next - _getChapterStartSeconds(targetIndex);
    });

    if (_isPlaying) {
      _playChapterNarration(_currentChapterIndex);
    }
    HapticFeedback.selectionClick();
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
    _cameraDriftController.dispose();
    _particlesController.dispose();
    _filmGrainController.dispose();
    _lensFlareController.dispose();
    _audioWaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chapters.isEmpty) return const SizedBox.shrink();

    final currentChapter = _chapters[_currentChapterIndex];
    final progressFactor =
        (_currentAbsoluteSeconds / _totalDurationSeconds).clamp(0.0, 1.0);
    final accent = _saga.primaryAccent;
    final secondary = _saga.secondaryAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: CultureTheme.darkSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent.withValues(alpha: 0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. ZONE VIDÉO CINÉMATIQUE (16:9 RESPONSIVE AVEC ANIMATIONS RÉELLES) ──
          AspectRatio(
            aspectRatio: 16 / 9.5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Layer A : Image de scène avec Ken Burns drift
                AnimatedBuilder(
                  animation: _cameraDriftController,
                  builder: (context, _) {
                    final drift = _cameraDriftController.value;
                    final scale = 1.05 + (drift * 0.08);
                    final panX = math.sin(drift * math.pi) * 8.0;
                    final panY = math.cos(drift * math.pi) * 6.0;

                    return Transform.translate(
                      offset: Offset(panX, panY),
                      child: Transform.scale(
                        scale: scale,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          child: Image.asset(
                            currentChapter.mainImage,
                            key: ValueKey<String>(currentChapter.mainImage),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            alignment: Alignment.center,
                            errorBuilder: (_, __, ___) => Container(
                              color: CultureTheme.darkSurface,
                              child: Center(
                                child: Icon(
                                  Icons.auto_stories_rounded,
                                  color: accent,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Layer B : Particules de poussière dorée
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _particlesController,
                      builder: (context, _) => CustomPaint(
                        painter: _VolumetricEmberParticlesPainter(
                          progress: _particlesController.value,
                          goldColor: CultureTheme.orPatrimoine,
                          ochreColor: secondary,
                        ),
                      ),
                    ),
                  ),
                ),

                // Layer C : Flare solaire anamorphique
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _lensFlareController,
                      builder: (context, _) => CustomPaint(
                        painter: _AnamorphicFlarePainter(
                          progress: _lensFlareController.value,
                          color: accent,
                        ),
                      ),
                    ),
                  ),
                ),

                // Layer D : Grain argentique 35mm
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _filmGrainController,
                      builder: (context, _) => CustomPaint(
                        painter: _FilmGrainPainter(
                          timeTick: (_filmGrainController.value * 20).floor(),
                        ),
                      ),
                    ),
                  ),
                ),

                // Layer E : Vignette dégradée pour protection de lecture
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.35, 0.70, 1.0],
                          colors: [
                            CultureTheme.darkBackground.withValues(alpha: 0.85),
                            Colors.transparent,
                            CultureTheme.darkBackground.withValues(alpha: 0.65),
                            CultureTheme.darkBackground.withValues(alpha: 0.95),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Layer F : Badge Chapitre en haut à gauche
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CultureTheme.darkSurface.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: secondary.withValues(alpha: 0.7),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          'ÉPOPÉE ANIMÉE • ${currentChapter.chapterNumber}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: secondary,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Bouton Immersion Plein Écran
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.heavyImpact();
                          VivienneTtsService.instance.stop();
                          context.push(
                            '/culture/personnage/${widget.figure.id}/reel',
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                CultureTheme.darkSurface.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.5),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fullscreen_rounded,
                                size: 14,
                                color: accent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Plein Écran',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: CultureTheme.sable,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Layer G : Bouton Play/Pause central avec ripple
                Center(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: secondary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: secondary.withValues(alpha: 0.5),
                            blurRadius: 18,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),

                // Layer H : Titre, date et fait historique au bas de la vidéo
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 10,
                            color: accent,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            currentChapter.dateAndPlace,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentChapter.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: CultureTheme.sable,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (currentChapter.historicalMetric != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              currentChapter.heraldicIcon ?? Icons.military_tech_rounded,
                              size: 11,
                              color: secondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                currentChapter.historicalMetric!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: CultureTheme.sable.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── 2. CONTRÔLES VIDÉO COMPLETS & SCRUBBER FLUIDE ─────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            color: CultureTheme.darkSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ligne de progression du temps et slider
                Row(
                  children: [
                    Text(
                      _formatTime(_currentAbsoluteSeconds),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: CultureTheme.sable.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Track de fond
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: CultureTheme.darkSurfaceAlt,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          // Barre de progression
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progressFactor,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(2),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(_totalDurationSeconds),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: CultureTheme.sable.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Barre des contrôles : Recul, Play/Pause, Avance, Muet, Visualiseur
                Row(
                  children: [
                    // Recul -10s
                    IconButton(
                      icon: const Icon(
                        Icons.replay_10_rounded,
                        color: CultureTheme.sable,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _seekRelative(-10),
                    ),
                    const SizedBox(width: 12),

                    // Acte Précédent
                    IconButton(
                      icon: Icon(
                        Icons.skip_previous_rounded,
                        color: _currentChapterIndex > 0
                            ? CultureTheme.sable
                            : CultureTheme.sable.withValues(alpha: 0.3),
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _currentChapterIndex > 0
                          ? () => _jumpToChapter(_currentChapterIndex - 1)
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // Play/Pause miniature
                    GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: secondary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: secondary, width: 1.0),
                        ),
                        child: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: secondary,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Acte Suivant
                    IconButton(
                      icon: Icon(
                        Icons.skip_next_rounded,
                        color: _currentChapterIndex < _chapters.length - 1
                            ? CultureTheme.sable
                            : CultureTheme.sable.withValues(alpha: 0.3),
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _currentChapterIndex < _chapters.length - 1
                          ? () => _jumpToChapter(_currentChapterIndex + 1)
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // Avance +10s
                    IconButton(
                      icon: const Icon(
                        Icons.forward_10_rounded,
                        color: CultureTheme.sable,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _seekRelative(10),
                    ),

                    const Spacer(),

                    // Égaliseur vocal et Mute toggle
                    GestureDetector(
                      onTap: _toggleMute,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4.5,
                        ),
                        decoration: BoxDecoration(
                          color: CultureTheme.darkSurfaceAlt,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isMuted
                                ? CultureTheme.darkBorder
                                : accent.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isMuted) ...[
                              _buildAudioWaveVisualizer(accent),
                              const SizedBox(width: 5),
                            ],
                            Icon(
                              _isMuted
                                  ? Icons.volume_off_rounded
                                  : Icons.volume_up_rounded,
                              size: 14,
                              color: _isMuted
                                  ? CultureTheme.sable.withValues(alpha: 0.5)
                                  : accent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Sélecteur horizontal rapide des Actes de l'Épopée
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: List.generate(_chapters.length, (idx) {
                      final isCurrent = idx == _currentChapterIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => _jumpToChapter(idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? secondary
                                  : CultureTheme.darkSurfaceAlt,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isCurrent
                                    ? secondary
                                    : CultureTheme.darkBorder,
                              ),
                            ),
                            child: Text(
                              'Acte ${idx + 1}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10.5,
                                fontWeight: isCurrent
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                                color: isCurrent
                                    ? Colors.white
                                    : CultureTheme.sable.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 14),

                // ── BOUTON MAJEUR D'ACCÈS AU RÉCIT DE LECTURE (SI L'UTILISATEUR VEUT LIRE) ──
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    VivienneTtsService.instance.stop();
                    setState(() {
                      _isPlaying = false;
                    });
                    _playbackTicker?.cancel();
                    widget.onReadingModeRequested?.call();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: CultureTheme.darkBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accent.withValues(alpha: 0.5),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          color: accent,
                          size: 17,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Lire le récit complet & Décrets (Mode Lecture)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: CultureTheme.sable,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_downward_rounded,
                          color: accent,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioWaveVisualizer(Color accentColor) {
    return AnimatedBuilder(
      animation: _audioWaveController,
      builder: (context, _) {
        final val = _audioWaveController.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildWaveBar(5 + (val * 7), accentColor),
            const SizedBox(width: 1.5),
            _buildWaveBar(11 - (val * 6), accentColor),
            const SizedBox(width: 1.5),
            _buildWaveBar(4 + (val * 8), accentColor),
          ],
        );
      },
    );
  }

  Widget _buildWaveBar(double h, Color col) {
    return Container(
      width: 2.2,
      height: h.clamp(3.0, 12.0),
      decoration: BoxDecoration(
        color: col,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PAINTERS CINÉMATIQUES CONFORMES À LA CHARTE ALTERNIA
// ══════════════════════════════════════════════════════════════════════════════

class _FilmGrainPainter extends CustomPainter {
  final int timeTick;
  _FilmGrainPainter({required this.timeTick});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(timeTick);
    final paint = Paint()
      ..color = CultureTheme.sable.withValues(alpha: 0.035)
      ..style = PaintingStyle.fill;

    const grainCount = 90;
    for (int i = 0; i < grainCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.5 + (random.nextDouble() * 0.7);
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
    final flareY = size.height * (0.35 + (progress * 0.25));
    final flareX = size.width * (0.15 + (progress * 0.70));

    final streakPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, flareY),
        Offset(size.width, flareY),
        [
          Colors.transparent,
          color.withValues(alpha: 0.15),
          CultureTheme.sable.withValues(alpha: 0.22),
          color.withValues(alpha: 0.15),
          Colors.transparent,
        ],
        [0.0, 0.35, 0.5, 0.65, 1.0],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(Offset(0, flareY), Offset(size.width, flareY), streakPaint);

    final haloPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(flareX, flareY),
        55,
        [
          color.withValues(alpha: 0.18),
          Colors.transparent,
        ],
      );
    canvas.drawCircle(Offset(flareX, flareY), 55, haloPaint);
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
    const particleCount = 20;
    final random = math.Random(55);

    for (int i = 0; i < particleCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.35 + (random.nextDouble() * 0.65);
      final radius = 0.8 + (random.nextDouble() * 1.5);
      final isGold = random.nextBool();

      final currentY = (baseY - (progress * speed * size.height)) % size.height;
      final currentX = baseX + (math.sin(progress * 2 * math.pi + i) * 6.0);
      final alpha = (0.2 + (math.sin(progress * math.pi + i) * 0.4)).clamp(0.0, 0.7);

      final paint = Paint()
        ..color = (isGold ? goldColor : ochreColor).withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(currentX, currentY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VolumetricEmberParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.goldColor != goldColor ||
        oldDelegate.ochreColor != ochreColor;
  }
}
