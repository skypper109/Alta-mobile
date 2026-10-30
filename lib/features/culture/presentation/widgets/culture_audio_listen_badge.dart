import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/immersive.dart';

/// Badge / Bouton interactif d'écoute audio culturelle (Voix du Griot)
/// Permet à l'utilisateur d'écouter au lieu de seulement lire.
/// STRICTEMENT SANS DÉGRADÉS selon la charte UX/UI Alta-mobile.
class CultureAudioListenBadge extends ConsumerStatefulWidget {
  final String contentId;
  final String speechText;
  final String label;
  final bool compact;
  final Color? activeColor;
  final VoidCallback? onPlayStarted;

  const CultureAudioListenBadge({
    super.key,
    required this.contentId,
    required this.speechText,
    this.label = 'Écouter',
    this.compact = false,
    this.activeColor,
    this.onPlayStarted,
  });

  @override
  ConsumerState<CultureAudioListenBadge> createState() =>
      _CultureAudioListenBadgeState();
}

class _CultureAudioListenBadgeState extends ConsumerState<CultureAudioListenBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  void _onTap() {
    CulturalHaptics.audioToggle();
    final coordinator = ref.read(narrationCoordinatorProvider.notifier);
    final snapshot = ref.read(narrationCoordinatorProvider);

    final isCurrentlyActive = snapshot.isSpeaking &&
        snapshot.activeContentId == widget.contentId;

    if (isCurrentlyActive) {
      coordinator.stop();
    } else {
      widget.onPlayStarted?.call();
      coordinator.speak(
        widget.speechText,
        contentId: widget.contentId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(narrationCoordinatorProvider);
    final isPlayingThis = snapshot.isSpeaking &&
        snapshot.activeContentId == widget.contentId;

    if (isPlayingThis && !_waveController.isAnimating) {
      _waveController.repeat(reverse: true);
    } else if (!isPlayingThis && _waveController.isAnimating) {
      _waveController.stop();
      _waveController.reset();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.activeColor ?? CultureTheme.accentOrange;

    if (widget.compact) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: _onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isPlayingThis
                  ? accent
                  : accent.withValues(alpha: isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPlayingThis
                    ? accent
                    : accent.withValues(alpha: isDark ? 0.60 : 0.45),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isPlayingThis ? accent : Colors.black)
                      .withValues(alpha: isPlayingThis ? 0.35 : (isDark ? 0.25 : 0.06)),
                  blurRadius: isPlayingThis ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPlayingThis)
                  _buildAnimatedWaves(color: Colors.white, height: 13)
                else
                  Icon(
                    Icons.volume_up_rounded,
                    size: 15,
                    color: accent,
                  ),
                const SizedBox(width: 6),
                Text(
                  isPlayingThis ? 'Pause' : widget.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                    color: isPlayingThis
                        ? Colors.white
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isPlayingThis
                ? accent
                : accent.withValues(alpha: isDark ? 0.22 : 0.14),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isPlayingThis
                  ? accent
                  : accent.withValues(alpha: isDark ? 0.65 : 0.50),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: (isPlayingThis ? accent : Colors.black)
                    .withValues(alpha: isPlayingThis ? 0.40 : (isDark ? 0.30 : 0.08)),
                blurRadius: isPlayingThis ? 10 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isPlayingThis
                      ? Colors.white.withValues(alpha: 0.25)
                      : accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: isPlayingThis
                    ? _buildAnimatedWaves(color: Colors.white, height: 16)
                    : Icon(
                        Icons.headphones_rounded,
                        size: 17,
                        color: accent,
                      ),
              ),
              const SizedBox(width: 8),
              Text(
                isPlayingThis ? 'Arrêter l\'écoute' : widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                  color: isPlayingThis
                      ? Colors.white
                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedWaves({required Color color, double height = 14}) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        final t = _waveController.value;
        final h1 = (0.35 + 0.65 * (math.sin(t * math.pi) * 0.5 + 0.5)) * height;
        final h2 = (0.35 + 0.65 * (math.sin((t + 0.3) * math.pi) * 0.5 + 0.5)) * height;
        final h3 = (0.35 + 0.65 * (math.sin((t + 0.6) * math.pi) * 0.5 + 0.5)) * height;
        final h4 = (0.35 + 0.65 * (math.sin((t + 0.85) * math.pi) * 0.5 + 0.5)) * height;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBar(color, h1.clamp(3.0, height)),
            const SizedBox(width: 2),
            _buildBar(color, h2.clamp(3.0, height)),
            const SizedBox(width: 2),
            _buildBar(color, h3.clamp(3.0, height)),
            const SizedBox(width: 2),
            _buildBar(color, h4.clamp(3.0, height)),
          ],
        );
      },
    );
  }

  Widget _buildBar(Color color, double barHeight) {
    return Container(
      width: 2.2,
      height: barHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
