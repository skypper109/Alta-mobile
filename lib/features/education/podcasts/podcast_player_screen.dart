// ─── AlterniA — Lecteur Audio de Podcast de Révision (TTS Vivienne Intégré) ───
// Synthèse vocale haute fidélité Vivienne (moteur embarqué de l'application),
// design sobre conforme à la charte officielle AlterniA, zéro dégradé, zéro sticker.
library;

import 'dart:async';
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
    // Utilisation directe du moteur TTS Vivienne officiel de l'application
    await VivienneTtsService.instance.stop();
    setState(() => _isPlaying = true);
    _waveController.repeat(reverse: true);

    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_currentSeconds < _totalSeconds) {
        setState(() {
          _currentSeconds++;
        });
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
          setState(() {
            _currentSeconds++;
          });
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
    setState(() {
      _playbackSpeed = speeds[nextIndex];
    });
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
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);
    final textSec = isDark ? Colors.white70 : const Color(0xFF475569);

    final progress = _totalSeconds > 0
        ? (_currentSeconds / _totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.keyboard_arrow_down_rounded, color: textPri, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              'PODCAST DE RÉVISION',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: AltaColors.secondary,
              ),
            ),
            Text(
              widget.podcast.subject,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: textPri,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            color: textPri,
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  // ── 1. CARTE VISUELLE DU COURS (DESIGN SOBRE SOLIDE) ─────────
                  Center(
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AltaColors.primary, width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            widget.podcast.icon,
                            size: 84,
                            color: AltaColors.primary,
                          ),
                          Positioned(
                            bottom: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AltaColors.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                widget.podcast.classLevel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
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

                  const SizedBox(height: 24),

                  // ── 2. TITRE DU COURS ET NARRATEUR VIVIENNE ────────────────
                  Text(
                    widget.podcast.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: textPri,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.record_voice_over_rounded,
                          size: 14, color: AltaColors.secondary),
                      const SizedBox(width: 6),
                      Text(
                        'Voix AlternIA',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AltaColors.secondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── 3. LECTURE AUDIO & ONDES EN LIGNE ─────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderCol),
                    ),
                    child: Column(
                      children: [
                        // Slider de progression
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            activeTrackColor: AltaColors.primary,
                            inactiveTrackColor: isDark
                                ? AltaColors.borderDark
                                : AltaColors.borderLight,
                            thumbColor: AltaColors.accent,
                          ),
                          child: Slider(
                            value: progress,
                            onChanged: (val) {
                              setState(() {
                                _currentSeconds = (val * _totalSeconds).toInt();
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatTime(_currentSeconds),
                                style: GoogleFonts.spaceMono(
                                  fontSize: 11,
                                  color: textSec,
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

                        const SizedBox(height: 12),

                        // Contrôles principaux
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Bouton vitesse
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
                                ),
                                child: Text(
                                  '${_playbackSpeed}x',
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textPri,
                                  ),
                                ),
                              ),
                            ),

                            // Reculer 15s
                            IconButton(
                              icon:
                                  const Icon(Icons.replay_10_rounded, size: 28),
                              color: textPri,
                              onPressed: () => _seekBy(-10),
                            ),

                            // Play / Pause central
                            GestureDetector(
                              onTap: _togglePlay,
                              child: Container(
                                width: 58,
                                height: 58,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AltaColors.primary,
                                ),
                                child: Icon(
                                  _isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 34,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            // Avancer 15s
                            IconButton(
                              icon: const Icon(Icons.forward_10_rounded,
                                  size: 28),
                              color: textPri,
                              onPressed: () => _seekBy(10),
                            ),

                            // Répétition
                            IconButton(
                              icon:
                                  const Icon(Icons.volume_up_rounded, size: 22),
                              color: textSec,
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── 4. SCRIPT PÉDAGOGIQUE DU COURS ─────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderCol),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.description_outlined,
                                size: 18, color: AltaColors.secondary),
                            const SizedBox(width: 8),
                            Text(
                              'Transcription du Cours',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: textPri,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.podcast.fullScript,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            height: 1.55,
                            color: textSec,
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
    );
  }
}
