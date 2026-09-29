import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/culture_theme.dart';
import '../../immersive/services/cultural_haptics.dart';
import '../../immersive/widgets/cultural_royal_stamp_animation.dart';
import '../controllers/story_experience_controller.dart';
import '../data/story_script_registry.dart';
import '../models/story_experience_models.dart';
import '../widgets/animated_map_stage.dart';
import '../widgets/baah_story_actor_widget.dart';
import '../widgets/cinematic_stage_viewport.dart';
import '../widgets/kinetic_typography_overlay.dart';
import '../widgets/story_choice_overlay.dart';
import '../widgets/story_progress_header.dart';

/// Écran maître du moteur d'expériences narratives immersives
/// Transforme la découverte culturelle en un documentaire animé vivant à 60 FPS
class StoryExperienceMasterScreen extends ConsumerWidget {
  final String storyId;
  final StoryExperienceScript? scriptOverride;

  const StoryExperienceMasterScreen({
    super.key,
    required this.storyId,
    this.scriptOverride,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final script = scriptOverride ?? StoryScriptRegistry.getScriptForId(storyId);
    final state = ref.watch(storyExperienceProviderFamily(script));
    final controller = ref.read(storyExperienceProviderFamily(script).notifier);

    final scene = state.currentScene;
    final isPaused = state.status == PlaybackStatus.paused;
    final isCompleted = state.status == PlaybackStatus.completed;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. LE THÉÂTRE VISUEL CENTRAL (CARTE OU SCÈNE CINÉMATIQUE) ─────
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                child: KeyedSubtree(
                  key: ValueKey('stage_${scene.id}'),
                  child: scene.type == SceneType.animatedMap && scene.mapData != null
                      ? AnimatedMapStage(mapDirective: scene.mapData!)
                      : CinematicStageViewport(
                          scene: scene,
                          isPaused: isPaused,
                        ),
                ),
              ),
            ),

            // ── 2. ZONES DE NAVIGATION TACTILE (GAUCHE / DROITE) ──────────────
            if (!isCompleted && state.status != PlaybackStatus.waitingInteraction)
              Positioned.fill(
                child: Row(
                  children: [
                    // Recul (25% gauche)
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (state.hasPreviousScene) {
                            controller.previousScene();
                          }
                        },
                      ),
                    ),
                    // Avance (75% droite)
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          controller.nextScene();
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // ── 3. INCRUSTATION VIVANTE DE BAAH (TÉMOIN DE L'HISTOIRE) ────────
            if (scene.baah != null && !isCompleted)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !scene.baah!.requiresUserTap,
                  child: BaahStoryActorWidget(
                    baah: scene.baah!,
                    onTap: () {
                      controller.nextScene();
                    },
                  ),
                ),
              ),

            // ── 4. TYPOGRAPHIE CINÉMATIQUE OU CHOIX INTERACTIFS ───────────────
            if (!isCompleted)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: state.status == PlaybackStatus.waitingInteraction &&
                          scene.choices != null &&
                          scene.choices!.isNotEmpty
                      ? StoryChoiceOverlay(
                          key: ValueKey('choices_${scene.id}'),
                          choices: scene.choices!,
                          selectedId: state.selectedChoiceId,
                          onChoiceSelected: controller.selectChoice,
                        )
                      : KineticTypographyOverlay(
                          key: ValueKey('subtitles_${scene.id}'),
                          text: scene.narrativeText,
                          sceneTitle: scene.title,
                          culturalSecret: scene.culturalSecret,
                          progress: state.sceneProgress,
                        ),
                ),
              ),

            // ── 5. BARRE SUPÉRIEURE DE PROGRESSION & CONTRÔLES ────────────────
            if (!isCompleted)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: StoryProgressHeader(
                  totalScenes: script.totalScenes,
                  currentSceneIndex: state.currentSceneIndex,
                  currentSceneProgress: state.sceneProgress,
                  isPaused: isPaused,
                  onTogglePlayPause: controller.togglePlayPause,
                ),
              ),

            // ── 6. ÉCRAN DE CÉLÉBRATION ET D'ESTAMPILLES SOLENNELLES ──────────
            if (isCompleted)
              _buildEpilogueCelebration(context, script, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildEpilogueCelebration(
    BuildContext context,
    StoryExperienceScript script,
    StoryExperienceController controller,
  ) {
    return Container(
      color: const Color(0xFF0F172A).withValues(alpha: 0.96),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Sceau royal estampillé physiquement
              const CulturalRoyalStampAnimation(
                size: 96,
                label: 'MÉMOIRE GRAVÉE',
                color: CultureTheme.accentOrange,
              ),

              const SizedBox(height: 24),

              Text(
                'LÉGENDE ACCOMPLIE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: CultureTheme.accentOrange,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                script.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Votre voyage à travers cette épopée a été inscrit au grand Livre de votre Passeport Culturel.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: const Color(0xFF94A3B8),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              // Badge XP Sagesse
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: CultureTheme.accentOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CultureTheme.accentOrange.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.military_tech_rounded,
                      color: CultureTheme.accentOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+100 XP DE SAGESSE PATRIMONIALE',
                      style: GoogleFonts.plusJakartaSans(
                        color: CultureTheme.accentOrange,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        controller.replayStory();
                      },
                      icon: const Icon(Icons.replay_rounded, size: 18),
                      label: const Text('Revivre'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        CulturalHaptics.cardRelease();
                        context.pop();
                      },
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text('Terminer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CultureTheme.accentOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
