import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
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
  late FlutterTts _flutterTts;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;

  // Progression simulée
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

    _initTts();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('fr-FR');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentSeconds = _totalSeconds;
        });
        _waveController.stop();
        _progressTimer?.cancel();
      }
    });

    _flutterTts.setErrorHandler((_) {
      if (mounted) {
        setState(() => _isPlaying = false);
        _waveController.stop();
        _progressTimer?.cancel();
      }
    });

    // Lancer automatiquement la lecture
    _togglePlay();
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _waveController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _togglePlay() async {
    HapticFeedback.mediumImpact();
    if (_isPlaying) {
      await _flutterTts.pause();
      _progressTimer?.cancel();
      _waveController.stop();
      setState(() => _isPlaying = false);
    } else {
      setState(() => _isPlaying = true);
      _waveController.repeat(reverse: true);

      // Lancer la voix TTS du script
      await _flutterTts.setSpeechRate(_playbackSpeed * 0.5);
      await _flutterTts.speak(widget.podcast.fullScript);

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
    if (_isPlaying) {
      _flutterTts.setSpeechRate(_playbackSpeed * 0.5);
    }
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPri = isDark ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: textPri, size: 30),
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
                color: widget.podcast.accentColor,
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
            icon: const Icon(Icons.share_rounded, size: 20),
            color: textPri,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lien du podcast copié pour tes camarades !')),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                children: [
                  // ── 1. POCHETTE HOLOGRAPHIQUE DU COURS ─────────────────────
                  Center(
                    child: Container(
                      width: 230,
                      height: 230,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.podcast.accentColor,
                            widget.podcast.accentColor.withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: widget.podcast.accentColor.withValues(alpha: 0.35),
                            blurRadius: 28,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Cercle orbital
                          Container(
                            width: 170,
                            height: 170,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 2,
                              ),
                            ),
                          ),
                          Icon(
                            widget.podcast.icon,
                            size: 90,
                            color: Colors.white,
                          ),
                          Positioned(
                            bottom: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(14),
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

                  // ── 2. TITRE & NARRATEUR ──────────────────────────────────
                  Text(
                    widget.podcast.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textPri,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mic_rounded, size: 16, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Text(
                        widget.podcast.narrator,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── 3. VAGUELETTES AUDIO ANIMÉES ──────────────────────────
                  SizedBox(
                    height: 36,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(24, (i) {
                        return AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, _) {
                            final factor = _isPlaying
                                ? ((i % 5 + 1) * 0.2 * _waveController.value) + 0.2
                                : 0.15;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2.5),
                              width: 3.5,
                              height: 36 * factor,
                              decoration: BoxDecoration(
                                color: _isPlaying
                                    ? widget.podcast.accentColor
                                    : (isDark ? Colors.white24 : Colors.black26),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── 4. BARRE DE PROGRESSION & TIMERS ──────────────────────
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      activeTrackColor: widget.podcast.accentColor,
                      inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
                      thumbColor: widget.podcast.accentColor,
                    ),
                    child: Slider(
                      value: _currentSeconds.toDouble().clamp(0.0, _totalSeconds.toDouble()),
                      max: _totalSeconds.toDouble(),
                      onChanged: (val) {
                        setState(() {
                          _currentSeconds = val.toInt();
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(_currentSeconds),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        Text(
                          _formatTime(_totalSeconds - _currentSeconds),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── 5. TOUCHES DE CONTRÔLE MULTIMÉDIA ─────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Vitesse
                      TextButton(
                        onPressed: _cycleSpeed,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          backgroundColor: isDark ? const Color(0xFF1E2844) : const Color(0xFFE2E8F0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          '${_playbackSpeed}x',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: widget.podcast.accentColor,
                          ),
                        ),
                      ),

                      // -10s
                      IconButton(
                        icon: const Icon(Icons.replay_10_rounded, size: 32),
                        color: textPri,
                        onPressed: () => _seekBy(-10),
                      ),

                      // Play / Pause Principal
                      GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [widget.podcast.accentColor, AppColors.accent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.podcast.accentColor.withValues(alpha: 0.4),
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      // +10s
                      IconButton(
                        icon: const Icon(Icons.forward_10_rounded, size: 32),
                        color: textPri,
                        onPressed: () => _seekBy(10),
                      ),

                      // Mode Sotrama Hors-ligne
                      IconButton(
                        icon: const Icon(Icons.download_done_rounded, size: 24),
                        color: Colors.greenAccent,
                        tooltip: 'Disponible hors-ligne',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Ce cours est enregistré et lisible sans internet !')),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── 6. FICHE MÉMO & POINTS CLÉS DU COURS ──────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF141D33) : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark ? const Color(0xFF233256) : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: AppColors.secondary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Les Points Clés pour le Bac',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textPri,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...widget.podcast.keyTakeaways.map((takeaway) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('• ', style: TextStyle(color: AppColors.secondary, fontSize: 16)),
                                Expanded(
                                  child: Text(
                                    takeaway,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
