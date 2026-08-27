import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/culture_story_models.dart';
import '../../core/theme/culture_theme.dart';

/// Modal d'écoute audio d'une veillée de conte (Voix du Griot & Ambiance)
class StoryAudioPlayerSheet extends StatefulWidget {
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
  State<StoryAudioPlayerSheet> createState() => _StoryAudioPlayerSheetState();
}

class _StoryAudioPlayerSheetState extends State<StoryAudioPlayerSheet> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  double _playbackPosition = 0.25; // Simule une position de lecture initiale
  final double _speechRate = 0.5;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('fr-FR');
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setPitch(0.95); // Voix légèrement plus posée et chaleureuse

      _flutterTts.setCompletionHandler(() {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _playbackPosition = 1.0;
          });
        }
      });
    } catch (_) {
      // Fallback gracieux si TTS indisponible
    }
  }

  Future<void> _togglePlayPause() async {
    HapticFeedback.mediumImpact();
    if (_isPlaying) {
      await _flutterTts.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      final textToSpeak =
          '${widget.story.title}. Par ${widget.story.narrator}. ${widget.story.summary} '
          '${widget.story.scenes.map((s) => s.narrativeText).join(' ')}';
      await _flutterTts.speak(textToSpeak);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? CultureTheme.darkSurface : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderCol = isDark ? CultureTheme.darkBorder : CultureTheme.lightBorder;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        14,
        24,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: borderCol)),
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
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: subtitleColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),

          // En-tête avec vignette du conte
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.asset(
                    widget.story.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: CultureTheme.rougeKoulikoro,
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
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'RÉCIT DU GRIOT • ${widget.story.regionName.toUpperCase()}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: CultureTheme.rougeKoulikoro,
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
                      widget.story.narrator,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: CultureTheme.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Barre de progression de la veillée
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: CultureTheme.rougeKoulikoro,
                  inactiveTrackColor: CultureTheme.rougeKoulikoro.withValues(alpha: 0.15),
                  thumbColor: CultureTheme.rougeKoulikoro,
                ),
                child: Slider(
                  value: _playbackPosition,
                  onChanged: (val) {
                    setState(() => _playbackPosition = val);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '02:15',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: subtitleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.story.audioDuration,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: subtitleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Commandes de lecture de veillée
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Recul 10s
              IconButton(
                iconSize: 32,
                color: titleColor,
                icon: const Icon(Icons.replay_10_rounded),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _playbackPosition = (_playbackPosition - 0.1).clamp(0.0, 1.0);
                  });
                },
              ),
              const SizedBox(width: 20),

              // Bouton Play / Pause principal
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: CultureTheme.rougeKoulikoro,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Avance 10s
              IconButton(
                iconSize: 32,
                color: titleColor,
                icon: const Icon(Icons.forward_10_rounded),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _playbackPosition = (_playbackPosition + 0.1).clamp(0.0, 1.0);
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Ambiance culturelle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? CultureTheme.darkSurfaceAlt : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: CultureTheme.rougeKoulikoro.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.music_note_rounded,
                  size: 14,
                  color: CultureTheme.rougeKoulikoro,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ambiance Kora & Récit traditionnel Mandingue',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF9A3412),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
