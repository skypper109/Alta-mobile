// ─── AlterniA — Lecteur Audio de Podcast de Révision (TTS Vivienne Intégré) ───
// Synthèse vocale haute fidélité Vivienne (moteur embarqué de l'application),
// design sobre conforme à la charte officielle AlterniA, zéro dégradé, zéro sticker.
library;

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants.dart';
import '../../../core/services/vivienne_tts_service.dart';
import 'podcast_model.dart';

class PodcastPlayerScreen extends StatefulWidget {
  const PodcastPlayerScreen({
    super.key,
    required this.podcast,
  });

  final RevisionPodcast podcast;

  @override
  State<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;

  int _currentSeconds = 0;
  late int _totalSeconds;
  Timer? _progressTimer;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.podcast.durationMinutes * 60;
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _startNarration();
  }

  Future<void> _startNarration() async {
    await VivienneTtsService.instance.stop();
    setState(() => _isPlaying = true);
    _waveController.repeat(reverse: true);

    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_currentSeconds < _totalSeconds) {
        setState(() => _currentSeconds++);
      } else {
        _progressTimer?.cancel();
        setState(() => _isPlaying = false);
        _waveController.stop();
      }
    });

    try {
      await VivienneTtsService.instance.speak(widget.podcast.fullScript);
    } catch (_) {}
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _waveController.dispose();
    VivienneTtsService.instance.stop();
    super.dispose();
  }

  void _togglePlay() async {
    HapticFeedback.mediumImpact();
    if (_isPlaying) {
      await VivienneTtsService.instance.stop();
      _progressTimer?.cancel();
      _waveController.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      _waveController.repeat(reverse: true);
      _progressTimer?.cancel();
      _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        if (_currentSeconds < _totalSeconds) {
          setState(() => _currentSeconds++);
        } else {
          _progressTimer?.cancel();
          setState(() => _isPlaying = false);
          _waveController.stop();
        }
      });
      try {
        await VivienneTtsService.instance.speak(widget.podcast.fullScript);
      } catch (_) {}
    }
  }

  void _seekBy(int seconds) {
    HapticFeedback.selectionClick();
    setState(() {
      _currentSeconds = (_currentSeconds + seconds).clamp(0, _totalSeconds);
    });
  }

  void _cycleSpeed() {
    HapticFeedback.selectionClick();
    final speeds = [0.8, 1.0, 1.25, 1.5];
    final nextIndex = (speeds.indexOf(_playbackSpeed) + 1) % speeds.length;
    setState(() => _playbackSpeed = speeds[nextIndex]);
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AltaColors.backgroundDark : AltaColors.backgroundLight;
    final cardBg = isDark ? AltaColors.surfaceDark : AltaColors.surfaceLight;
    final borderCol = isDark ? AltaColors.borderDark : AltaColors.borderLight;
    final textPri = isDark ? Colors.white : const Color(0xFF0D1525);
    final textSec = isDark ? Colors.white70 : const Color(0xFF475569);

    final progress = _totalSeconds > 0
        ? (_currentSeconds / _totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: bg,
      // ── APPBAR GRADIENT CHARTE ALTERNIA ────────────────────────────────────
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A2340), Color(0xFF253060)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.white70, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
          ),
          child: Text(
            widget.podcast.subject,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined,
                size: 20, color: Colors.white70),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Lien du cours copié dans le presse-papiers.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          children: [
            // ── 1. CARTE VISUELLE PREMIUM DU COURS ───────────────────────────
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: borderCol),
                    boxShadow: [
                      BoxShadow(
                        color: AltaColors.primary.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Accent strip top
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF314999),
                                Color(0xFF40BBCC),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Main icon
                      Center(
                        child: Icon(
                          widget.podcast.icon,
                          size: 80,
                          color: AltaColors.primary
                              .withValues(alpha: isDark ? 0.90 : 0.80),
                        ),
                      ),
                      // Animated wave bars (bottom) when playing
                      Positioned(
                        bottom: 14,
                        left: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _waveController,
                          builder: (_, __) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: List.generate(7, (i) {
                                final phase = (i / 6.0) * math.pi;
                                final height = _isPlaying
                                    ? 6.0 +
                                        10.0 *
                                            ((math.sin(_waveController.value *
                                                            math.pi +
                                                        phase) +
                                                    1) /
                                                2)
                                    : 4.0;
                                return Container(
                                  width: 4,
                                  height: height,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: i % 2 == 0
                                        ? AltaColors.secondary
                                        : AltaColors.primary,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                            );
                          },
                        ),
                      ),
                      // Classe badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: AltaColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.podcast.classLevel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ── 2. TITRE + VOIX ALTERNIA ──────────────────────────────────────
            Text(
              widget.podcast.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.3,
                letterSpacing: -0.3,
                color: textPri,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AltaColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AltaColors.secondary.withValues(alpha: 0.30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.record_voice_over_rounded,
                          size: 13, color: AltaColors.secondary),
                      const SizedBox(width: 5),
                      Text(
                        'Voix AlternIA · Vivienne',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AltaColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ── 3. LECTEUR AUDIO ──────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  children: [
                    // Accent strip top
                    Container(
                      height: 3,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF314999), Color(0xFF40BBCC)],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: Column(
                        children: [
                          // Slider de progression
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 5,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 7),
                              activeTrackColor: AltaColors.primary,
                              inactiveTrackColor: isDark
                                  ? AltaColors.borderDark
                                  : AltaColors.borderLight,
                              thumbColor: AltaColors.accent,
                              overlayColor:
                                  AltaColors.primary.withValues(alpha: 0.15),
                            ),
                            child: Slider(
                              value: progress,
                              onChanged: (val) {
                                setState(() {
                                  _currentSeconds =
                                      (val * _totalSeconds).toInt();
                                });
                              },
                            ),
                          ),

                          // Timestamps
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatTime(_currentSeconds),
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 11,
                                    color: AltaColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _formatTime(_totalSeconds),
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 11,
                                    color: textSec,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ── CONTRÔLES ────────────────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Badge vitesse
                              GestureDetector(
                                onTap: _cycleSpeed,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AltaColors.surfaceAltDark
                                        : AltaColors.surfaceAltLight,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AltaColors.primary
                                          .withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Text(
                                    '${_playbackSpeed}x',
                                    style: GoogleFonts.spaceMono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AltaColors.primary,
                                    ),
                                  ),
                                ),
                              ),

                              // Reculer 10s
                              GestureDetector(
                                onTap: () => _seekBy(-10),
                                child: Icon(
                                  Icons.replay_10_rounded,
                                  size: 30,
                                  color: textPri,
                                ),
                              ),

                              // Play / Pause central — plus grand, avec glow
                              GestureDetector(
                                onTap: _togglePlay,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AltaColors.primary,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AltaColors.primary
                                            .withValues(alpha: 0.35),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                ),
                              ),

                              // Avancer 10s
                              GestureDetector(
                                onTap: () => _seekBy(10),
                                child: Icon(
                                  Icons.forward_10_rounded,
                                  size: 30,
                                  color: textPri,
                                ),
                              ),

                              // Volume
                              Icon(
                                Icons.volume_up_rounded,
                                size: 24,
                                color: textSec,
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Barre de statut de lecture
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AltaColors.surfaceAltDark
                                  : AltaColors.surfaceAltLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isPlaying
                                        ? AltaColors.secondary
                                        : textSec,
                                  ),
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  _isPlaying
                                      ? 'Narration AlternIA en cours...'
                                      : 'En pause',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: _isPlaying
                                        ? AltaColors.secondary
                                        : textSec,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ── 4. TRANSCRIPTION DU COURS ─────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Accent strip top
                    Container(
                      height: 3,
                      decoration: const BoxDecoration(
                        color: AltaColors.secondary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header avec barre colorée
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AltaColors.secondary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'TRANSCRIPTION',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.7,
                                  color: textSec,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AltaColors.primary
                                      .withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${widget.podcast.durationMinutes} min',
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: AltaColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.podcast.fullScript,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              height: 1.6,
                              color: textSec,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
