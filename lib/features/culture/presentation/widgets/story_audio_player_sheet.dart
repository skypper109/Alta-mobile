import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/culture_story_models.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/controllers/narration_coordinator.dart';

/// Modal d'écoute audio immersif de la veillée de conte (Voix du Griot & Scènes)
/// Permet à l'utilisateur de vivre le conte à l'oral avec suivi de scènes et égaliseur
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI Alta-mobile.
class StoryAudioPlayerSheet extends ConsumerStatefulWidget {
  final InteractiveStory story;

  const StoryAudioPlayerSheet({super.key, required this.story});

  static Future<void> show(BuildContext context, InteractiveStory story) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StoryAudioPlayerSheet(story: story),
    );
  }

  @override
  ConsumerState<StoryAudioPlayerSheet> createState() =>
      _StoryAudioPlayerSheetState();
}

class _StoryAudioPlayerSheetState extends ConsumerState<StoryAudioPlayerSheet>
    with SingleTickerProviderStateMixin {
  int _currentSceneIndex = 0;
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Démarrage automatique de la narration du conte
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCurrentSceneNarration();
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _startCurrentSceneNarration() {
    if (widget.story.scenes.isEmpty) return;
    final scene = widget.story.scenes[_currentSceneIndex];
    final textToSpeak = _currentSceneIndex == 0
        ? '${widget.story.title}. Récit raconté par ${widget.story.narrator}. ${scene.title}. ${scene.narrativeText}'
        : 'Scène ${_currentSceneIndex + 1} : ${scene.title}. ${scene.narrativeText}';

    ref.read(narrationCoordinatorProvider.notifier).speak(
          textToSpeak,
          contentId: '${widget.story.id}_scene_$_currentSceneIndex',
          onComplete: () {
            if (!mounted) return;
            if (_currentSceneIndex < widget.story.scenes.length - 1) {
              setState(() {
                _currentSceneIndex++;
              });
              _startCurrentSceneNarration();
            }
          },
        );
  }

  void _togglePlayPause() {
    HapticFeedback.mediumImpact();
    final coordinator = ref.read(narrationCoordinatorProvider.notifier);
    final snapshot = ref.read(narrationCoordinatorProvider);

    if (snapshot.isSpeaking) {
      coordinator.stop();
    } else {
      _startCurrentSceneNarration();
    }
  }

  void _nextScene() {
    HapticFeedback.lightImpact();
    if (_currentSceneIndex < widget.story.scenes.length - 1) {
      setState(() {
        _currentSceneIndex++;
      });
      _startCurrentSceneNarration();
    }
  }

  void _prevScene() {
    HapticFeedback.lightImpact();
    if (_currentSceneIndex > 0) {
      setState(() {
        _currentSceneIndex--;
      });
      _startCurrentSceneNarration();
    }
  }

  void _changeSpeed(double speed) {
    HapticFeedback.selectionClick();
    ref.read(narrationCoordinatorProvider.notifier).setSpeechRate(speed);
  }

  @override
  Widget build(BuildContext context) {
    final narration = ref.watch(narrationCoordinatorProvider);
    final isPlaying = narration.isSpeaking;

    if (isPlaying && !_waveController.isAnimating) {
      _waveController.repeat(reverse: true);
    } else if (!isPlaying && _waveController.isAnimating) {
      _waveController.stop();
      _waveController.reset();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderCol =
        isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    final scenes = widget.story.scenes;
    final currentScene =
        scenes.isNotEmpty ? scenes[_currentSceneIndex] : null;

    final progress = scenes.isNotEmpty
        ? (_currentSceneIndex + 1) / scenes.length
        : 0.0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        MediaQuery.paddingOf(context).bottom + 20,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: borderCol, width: 1.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Poignée supérieure
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: subtitleColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // En-tête avec vignette du conte et Griot
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.35),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.asset(
                    widget.story.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color:
                          CultureTheme.accentOrange.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            CultureTheme.accentOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'VEILLÉE ORALE • ${widget.story.regionName.toUpperCase()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: CultureTheme.accentOrange,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.story.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Voix : ${widget.story.narrator}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton fermer
              IconButton(
                onPressed: () {
                  ref.read(narrationCoordinatorProvider.notifier).stop();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close_rounded, size: 20),
                color: subtitleColor,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Cadre de scène en cours de lecture
          if (currentScene != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? CultureTheme.darkSurfaceAlt
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isPlaying
                      ? CultureTheme.accentOrange.withValues(alpha: 0.4)
                      : borderCol,
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: CultureTheme.accentOrange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'SCÈNE ${_currentSceneIndex + 1}/${scenes.length}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            currentScene.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: titleColor,
                            ),
                          ),
                        ],
                      ),
                      // Égaliseur audio en direct
                      if (isPlaying)
                        _buildAnimatedEqualizer(
                          color: CultureTheme.accentOrange,
                          height: 14,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentScene.narrativeText,
                    style: GoogleFonts.merriweather(
                      fontSize: 12,
                      height: 1.5,
                      color: isDark
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF334155),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Barre de progression par étapes/scènes
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: isDark
                      ? CultureTheme.darkSurfaceAlt
                      : const Color(0xFFE2E8F0),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    CultureTheme.accentOrange,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scène ${_currentSceneIndex + 1} sur ${scenes.length}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: subtitleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Durée estimée : ${widget.story.audioDuration}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: subtitleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Commandes de lecture de veillée
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Scène précédente
              IconButton(
                iconSize: 28,
                color: _currentSceneIndex > 0
                    ? titleColor
                    : subtitleColor.withValues(alpha: 0.3),
                icon: const Icon(Icons.skip_previous_rounded),
                onPressed: _currentSceneIndex > 0 ? _prevScene : null,
              ),
              const SizedBox(width: 14),

              // Bouton Play / Pause principal
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: CultureTheme.accentOrange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: CultureTheme.accentOrange
                            .withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Scène suivante
              IconButton(
                iconSize: 28,
                color: _currentSceneIndex < scenes.length - 1
                    ? titleColor
                    : subtitleColor.withValues(alpha: 0.3),
                icon: const Icon(Icons.skip_next_rounded),
                onPressed: _currentSceneIndex < scenes.length - 1
                    ? _nextScene
                    : null,
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Sélecteur de rythme de parole du Griot
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Rythme du Griot :',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: subtitleColor,
                ),
              ),
              const SizedBox(width: 8),
              _buildSpeedChip(label: '0.75x (Posé)', rate: 0.40, currentRate: narration.speechRate),
              const SizedBox(width: 6),
              _buildSpeedChip(label: '1.0x (Normal)', rate: 0.48, currentRate: narration.speechRate),
              const SizedBox(width: 6),
              _buildSpeedChip(label: '1.25x (Vif)', rate: 0.58, currentRate: narration.speechRate),
            ],
          ),

          const SizedBox(height: 14),

          // Sagesse & Morale du conte
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? CultureTheme.darkSurfaceAlt
                  : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CultureTheme.accentOrange.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: CultureTheme.accentOrange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.story.moral,
                    style: GoogleFonts.merriweather(
                      fontSize: 10.5,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white70 : const Color(0xFF9A3412),
                      height: 1.35,
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

  Widget _buildSpeedChip({
    required String label,
    required double rate,
    required double currentRate,
  }) {
    final isSelected = (currentRate - rate).abs() < 0.04;
    return GestureDetector(
      onTap: () => _changeSpeed(rate),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
        decoration: BoxDecoration(
          color: isSelected
              ? CultureTheme.accentOrange
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? CultureTheme.accentOrange
                : const Color(0xFF94A3B8).withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedEqualizer({required Color color, double height = 14}) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        final t = _waveController.value;
        final h1 = (0.35 + 0.65 * t) * height;
        final h2 = (0.9 - 0.5 * t) * height;
        final h3 = (0.4 + 0.6 * ((t + 0.4) % 1.0)) * height;
        final h4 = (0.8 - 0.6 * ((t + 0.7) % 1.0)) * height;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _bar(color, h1),
            const SizedBox(width: 2),
            _bar(color, h2),
            const SizedBox(width: 2),
            _bar(color, h3),
            const SizedBox(width: 2),
            _bar(color, h4),
          ],
        );
      },
    );
  }

  Widget _bar(Color color, double h) {
    return Container(
      width: 2.5,
      height: h.clamp(3.0, 16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}
