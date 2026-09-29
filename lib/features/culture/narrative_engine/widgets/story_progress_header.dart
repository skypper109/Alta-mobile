import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../immersive/controllers/narration_coordinator.dart';
import '../../immersive/services/cultural_haptics.dart';

/// Barre supérieure segmentée de progression de l'expérience documentaire
class StoryProgressHeader extends ConsumerWidget {
  final int totalScenes;
  final int currentSceneIndex;
  final double currentSceneProgress;
  final bool isPaused;
  final VoidCallback onTogglePlayPause;

  const StoryProgressHeader({
    super.key,
    required this.totalScenes,
    required this.currentSceneIndex,
    required this.currentSceneProgress,
    required this.isPaused,
    required this.onTogglePlayPause,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final narrationSnapshot = ref.watch(narrationCoordinatorProvider);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── SEGMENTS DE PROGRESSION (LIVING STORY BARS) ─────────────────
            Row(
              children: List.generate(totalScenes, (index) {
                double fillRatio = 0.0;
                if (index < currentSceneIndex) {
                  fillRatio = 1.0;
                } else if (index == currentSceneIndex) {
                  fillRatio = currentSceneProgress.clamp(0.0, 1.0);
                }

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Container(
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: fillRatio,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1851F),
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF1851F).withValues(alpha: 0.6),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 12),

            // ── CONTRÔLES SUPÉRIEURS (FERMER, PAUSE, SON) ───────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton Quitter
                GestureDetector(
                  onTap: () {
                    CulturalHaptics.cardRelease();
                    context.pop();
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.55),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.20),
                      ),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                Row(
                  children: [
                    // Bouton Voix / Narration
                    GestureDetector(
                      onTap: () {
                        CulturalHaptics.audioToggle();
                        final coordinator = ref.read(narrationCoordinatorProvider.notifier);
                        if (narrationSnapshot.isSpeaking) {
                          coordinator.stop();
                        }
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: narrationSnapshot.isSpeaking
                              ? const Color(0xFFF1851F).withValues(alpha: 0.85)
                              : Colors.black.withValues(alpha: 0.55),
                          border: Border.all(
                            color: narrationSnapshot.isSpeaking
                                ? const Color(0xFFF1851F)
                                : Colors.white.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Icon(
                          narrationSnapshot.isSpeaking
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Bouton Pause / Reprendre
                    GestureDetector(
                      onTap: onTogglePlayPause,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.55),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Icon(
                          isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
