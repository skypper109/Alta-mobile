import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/culture_theme.dart';
import '../../immersive/controllers/narration_coordinator.dart';
import '../../immersive/services/cultural_haptics.dart';

// ══════════════════════════════════════════════════════════════════════════════
// 1. MODÈLE D'AMBIANCE SONORE (SOUNDSCAPE PATRIMONIAL)
// ══════════════════════════════════════════════════════════════════════════════

class SoundiataSoundscape {
  final int chapterNumber;
  final String name;
  final String instrument;
  final String atmosphere;
  final IconData icon;

  const SoundiataSoundscape({
    required this.chapterNumber,
    required this.name,
    required this.instrument,
    required this.atmosphere,
    required this.icon,
  });

  static const List<SoundiataSoundscape> soundscapes = [
    SoundiataSoundscape(
      chapterNumber: 1,
      name: 'Aube du Manden',
      instrument: 'Kora sacrée à 21 cordes',
      atmosphere: 'Brise matinale du Sankarani & chants d\'oiseaux',
      icon: Icons.wb_twilight_rounded,
    ),
    SoundiataSoundscape(
      chapterNumber: 2,
      name: 'Forge des Nounkou',
      instrument: 'Enclume des forgerons & tamani',
      atmosphere: 'Martèlement du fer rouge & souffle du Lion',
      icon: Icons.hardware_rounded,
    ),
    SoundiataSoundscape(
      chapterNumber: 3,
      name: 'Pistes Transsahariennes',
      instrument: 'Clochettes de chameaux & flûte peule',
      atmosphere: 'Vent du désert & méandres du Djoliba',
      icon: Icons.explore_rounded,
    ),
    SoundiataSoundscape(
      chapterNumber: 4,
      name: 'Cavalerie de Méma',
      instrument: 'Ngoni sahélien & tambours',
      atmosphere: 'Sabots au galop & serments de fraternité',
      icon: Icons.nature_people_rounded,
    ),
    SoundiataSoundscape(
      chapterNumber: 5,
      name: 'L\'Appel du Manden',
      instrument: 'Cors de chasse & trompes royales',
      atmosphere: 'Ralliement des tribus & cris de libération',
      icon: Icons.campaign_rounded,
    ),
    SoundiataSoundscape(
      chapterNumber: 6,
      name: 'Orage de Kirina',
      instrument: 'Dunduns de guerre & lames d\'acier',
      atmosphere: 'Poussière d\'or, tonnerre et choc suprême',
      icon: Icons.sports_kabaddi_rounded,
    ),
    SoundiataSoundscape(
      chapterNumber: 7,
      name: 'Kangaba la Sainte',
      instrument: 'Grand balafon de Kouroukan Fouga',
      atmosphere: 'Murmures sacrés sous l\'arbre & chants de paix',
      icon: Icons.park_rounded,
    ),
  ];

  static SoundiataSoundscape forChapter(int number) {
    return soundscapes.firstWhere(
      (s) => s.chapterNumber == number,
      orElse: () => soundscapes.first,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 2. VISUALISEUR D'ONDES AUDIO ANIMÉES (WAVEFORM EQUALIZER DORÉ)
// ══════════════════════════════════════════════════════════════════════════════

class SoundiataWaveformVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color activeColor;
  final int barCount;
  final double maxHeight;
  final double barWidth;

  const SoundiataWaveformVisualizer({
    super.key,
    required this.isPlaying,
    this.activeColor = const Color(0xFFF59E0B),
    this.barCount = 5,
    this.maxHeight = 18.0,
    this.barWidth = 3.0,
  });

  @override
  State<SoundiataWaveformVisualizer> createState() =>
      _SoundiataWaveformVisualizerState();
}

class _SoundiataWaveformVisualizerState
    extends State<SoundiataWaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    if (widget.isPlaying) {
      _animController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant SoundiataWaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_animController.isAnimating) {
      _animController.repeat(reverse: true);
    } else if (!widget.isPlaying && _animController.isAnimating) {
      _animController.stop();
      _animController.reset();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(widget.barCount, (i) {
            final phase = i * (math.pi / (widget.barCount * 0.7));
            final wave = widget.isPlaying
                ? 0.25 + 0.75 * math.sin(_animController.value * math.pi + phase).abs()
                : 0.2;
            final height = widget.maxHeight * wave;

            return Container(
              width: widget.barWidth,
              height: height.clamp(4.0, widget.maxHeight),
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: widget.activeColor.withValues(
                  alpha: widget.isPlaying ? (0.6 + (wave * 0.4)) : 0.35,
                ),
                borderRadius: BorderRadius.circular(widget.barWidth / 2),
                boxShadow: widget.isPlaying
                    ? [
                        BoxShadow(
                          color: widget.activeColor.withValues(alpha: 0.4),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 3. BADGE D'ATMOSPHÈRE SONORE CONTEXTUELLE
// ══════════════════════════════════════════════════════════════════════════════

class SoundiataSoundscapeBadge extends StatelessWidget {
  final int chapterNumber;
  final bool isDark;

  const SoundiataSoundscapeBadge({
    super.key,
    required this.chapterNumber,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final soundscape = SoundiataSoundscape.forChapter(chapterNumber);

    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141926) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
          width: 0.9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            soundscape.icon,
            size: 13,
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  soundscape.name.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFF59E0B),
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  soundscape.atmosphere,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 4. CITATION KARAOKÉ SYNCHRONISÉE AVEC L'ÉCOUTE
// ══════════════════════════════════════════════════════════════════════════════

class SoundiataSynchronizedQuote extends StatelessWidget {
  final String quote;
  final bool isActivelySpeaking;
  final bool isDark;

  const SoundiataSynchronizedQuote({
    super.key,
    required this.quote,
    required this.isActivelySpeaking,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActivelySpeaking
            ? const Color(0xFFF59E0B).withValues(alpha: 0.16)
            : const Color(0xFFF59E0B).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActivelySpeaking
              ? const Color(0xFFF59E0B)
              : const Color(0xFFF59E0B).withValues(alpha: 0.3),
          width: isActivelySpeaking ? 1.6 : 1.0,
        ),
        boxShadow: isActivelySpeaking
            ? [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isActivelySpeaking)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const SoundiataWaveformVisualizer(
                    isPlaying: true,
                    barCount: 4,
                    maxHeight: 12,
                    barWidth: 2.2,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'VOIX DU CONTEUR EN DIRECT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFF59E0B),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          Text(
            quote,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontStyle: FontStyle.italic,
              color: isDark
                  ? (isActivelySpeaking ? Colors.white : const Color(0xFFFCD34D))
                  : (isActivelySpeaking ? const Color(0xFF78350F) : const Color(0xFFB45309)),
              height: 1.45,
              fontWeight: isActivelySpeaking ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 5. CONTRÔLEUR AUDIO FLOTTANT (MASTER GRIOT AUDIO DOCK)
// ══════════════════════════════════════════════════════════════════════════════

class SoundiataMasterAudioBar extends ConsumerWidget {
  final int activeChapterIndex;
  final int totalChapters;
  final String activeChapterTitle;
  final bool isAutoplayEnabled;
  final VoidCallback onToggleAutoplay;
  final VoidCallback onTogglePlay;
  final VoidCallback onPreviousChapter;
  final VoidCallback onNextChapter;
  final bool isDark;

  const SoundiataMasterAudioBar({
    super.key,
    required this.activeChapterIndex,
    required this.totalChapters,
    required this.activeChapterTitle,
    required this.isAutoplayEnabled,
    required this.onToggleAutoplay,
    required this.onTogglePlay,
    required this.onPreviousChapter,
    required this.onNextChapter,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final narration = ref.watch(narrationCoordinatorProvider);
    final coordinator = ref.read(narrationCoordinatorProvider.notifier);
    final isPlaying = narration.isSpeaking;

    final soundscape = SoundiataSoundscape.forChapter(activeChapterIndex + 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPlaying
              ? const Color(0xFFF59E0B)
              : (isDark
                  ? CultureTheme.darkBorder
                  : CultureTheme.lightBorder),
          width: isPlaying ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isPlaying
                ? const Color(0xFFF59E0B).withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── BOUTON PLAY / PAUSE MAÎTRE ──
          GestureDetector(
            onTap: () {
              CulturalHaptics.audioToggle();
              onTogglePlay();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.black,
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 10),

          // ── INFOS DE LECTURE DU CHAPITRE ACTIF ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'ACTE ${activeChapterIndex + 1}/$totalChapters',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFF59E0B),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(width: 6),
                    SoundiataWaveformVisualizer(
                      isPlaying: isPlaying,
                      barCount: 4,
                      maxHeight: 10,
                      barWidth: 2.2,
                    ),
                  ],
                ),
                Text(
                  activeChapterTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  soundscape.atmosphere,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── SÉLECTEUR DE VITESSE (1.0x / 1.25x) ──
          GestureDetector(
            onTap: () {
              CulturalHaptics.cardPress();
              final currentRate = narration.speechRate;
              final newRate = currentRate < 0.55 ? 0.60 : 0.45;
              coordinator.setSpeechRate(newRate);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                narration.speechRate >= 0.55 ? '1.25x' : '1.0x',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // ── BOUTON AUTOPLAY (CINÉ-CONTEUR AUTOMATIQUE) ──
          GestureDetector(
            onTap: () {
              CulturalHaptics.cardPress();
              onToggleAutoplay();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isAutoplayEnabled
                    ? const Color(0xFFF59E0B)
                    : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isAutoplayEnabled
                      ? const Color(0xFFD97706)
                      : Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    size: 12,
                    color: isAutoplayEnabled ? Colors.black : const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Auto',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isAutoplayEnabled ? Colors.black : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
