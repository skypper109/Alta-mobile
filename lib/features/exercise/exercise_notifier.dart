// ─── DetAI — Feature: Exercise — Notifier + Page ─────────────────────────────
library;

import 'package:alternia/features/device/device_entity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants.dart';
import '../../shared/widgets.dart';
import '../device/device_notifier.dart';
import 'exercise_entity.dart';
import 'exercise_repository.dart';

part 'exercise_notifier.g.dart';

// ══════════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ══════════════════════════════════════════════════════════════════════════════

@Riverpod(keepAlive: true)
ExerciseRepository exerciseRepository(Ref ref) {
  return ExerciseRepository(dio: Dio());
}

// ══════════════════════════════════════════════════════════════════════════════
// NOTIFIER
// ══════════════════════════════════════════════════════════════════════════════

@riverpod
class ExerciseNotifier extends _$ExerciseNotifier {
  @override
  ExerciseEntity build() => const ExerciseEntity(id: '', imagePath: '');

  /// Lance la capture photo.
  Future<void> captureExercise() async {
    state = state.copyWith(status: ExerciseStatus.capturing, error: null);

    final result = await ref.read(exerciseRepositoryProvider).capturePhoto();

    result.fold(
      (failure) => state = state.copyWith(
        status: ExerciseStatus.error,
        error: failure.message,
      ),
      (imagePath) => state = state.copyWith(
        imagePath: imagePath,
        status: ExerciseStatus.processing,
        capturedAt: DateTime.now(),
      ),
    );
  }

  /// Envoie l'image au boîtier et récupère les indices.
  Future<void> getHints() async {
    final device = ref.read(deviceNotifierProvider).connectedDevice;
    if (device == null) {
      state = state.copyWith(
        status: ExerciseStatus.error,
        error: 'Aucun boîtier connecté. Connectez-vous d\'abord.',
      );
      return;
    }

    state = state.copyWith(status: ExerciseStatus.waitingHints, error: null);

    final result = await ref.read(exerciseRepositoryProvider).getHints(
          imagePath: state.imagePath,
          deviceBaseUrl: device.httpUrl,
          subject: state.subject,
          level: state.level,
        );

    result.fold(
      (failure) => state = state.copyWith(
        status: ExerciseStatus.error,
        error: failure.message,
      ),
      (hints) => state = state.copyWith(
        hints: hints,
        status: ExerciseStatus.hintsReceived,
      ),
    );
  }

  /// Change la matière sélectionnée.
  void setSubject(SchoolSubject subject) =>
      state = state.copyWith(subject: subject);

  /// Change le niveau scolaire.
  void setLevel(SchoolLevel? level) => state = state.copyWith(level: level);

  /// Réinitialise pour un nouvel exercice.
  void reset() => state = const ExerciseEntity(id: '', imagePath: '');
}

// ══════════════════════════════════════════════════════════════════════════════
// PAGE
// ══════════════════════════════════════════════════════════════════════════════

/// Écran du scanner d'exercice socratique.
class ExerciseScannerPage extends ConsumerWidget {
  const ExerciseScannerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = ref.watch(exerciseNotifierProvider);

    return Scaffold(
      backgroundColor: DetColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ─────────────────────────────────────────────────────
            _ExerciseAppBar(exercise: exercise, ref: ref),

            Expanded(
              child: switch (exercise.status) {
                ExerciseStatus.idle => _IdleView(ref: ref),
                ExerciseStatus.capturing => const _CaptureLoadingView(),
                ExerciseStatus.processing =>
                  _ImagePreviewView(exercise: exercise, ref: ref),
                ExerciseStatus.waitingHints =>
                  _WaitingHintsView(exercise: exercise),
                ExerciseStatus.hintsReceived =>
                  _HintsView(exercise: exercise, ref: ref),
                ExerciseStatus.error => DetErrorWidget(
                    message: exercise.error ?? DetStrings.errUnknown,
                    onRetry: () =>
                        ref.read(exerciseNotifierProvider.notifier).reset(),
                  ),
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── AppBar ─────────────────────────────────────────────────────────────────

class _ExerciseAppBar extends StatelessWidget {
  const _ExerciseAppBar({required this.exercise, required this.ref});
  final ExerciseEntity exercise;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: DetSizes.lg, vertical: DetSizes.md),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: DetColors.border, width: DetSizes.borderWidth)),
      ),
      child: Row(
        children: [
          const Expanded(
              child: Text(DetStrings.exerciseScan,
                  style: DetTextStyles.headingMd)),
          if (exercise.status != ExerciseStatus.idle)
            GestureDetector(
              onTap: () => ref.read(exerciseNotifierProvider.notifier).reset(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: DetSizes.md, vertical: DetSizes.xs),
                decoration: BoxDecoration(
                  color: DetColors.surface,
                  borderRadius: DetSizes.borderRadiusSm,
                  border: Border.all(
                      color: DetColors.border, width: DetSizes.borderWidth),
                ),
                child: Text('Nouveau',
                    style: DetTextStyles.labelSm
                        .copyWith(color: DetColors.textSecondary)),
              ),
            ),
        ],
      ),
    );
  }
}

// ── État initial ────────────────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  const _IdleView({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DetSizes.lg),
      child: Column(
        children: [
          const Spacer(),

          // Icône scanner
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: DetColors.surface,
              borderRadius: DetSizes.borderRadiusXl,
              border: Border.all(
                  color: DetColors.border, width: DetSizes.borderWidth),
            ),
            child: const Icon(
              Icons.document_scanner_rounded,
              size: 48,
              color: DetColors.accentGreen,
            ),
          ),

          const SizedBox(height: DetSizes.xxl),
          const Text('Scanner un exercice',
              style: DetTextStyles.headingMd, textAlign: TextAlign.center),
          const SizedBox(height: DetSizes.sm),
          Text(
            'Prenez une photo de votre feuille de devoir.\nL\'IA vous guidera par indices progressifs,\nsans jamais vous donner la réponse.',
            style:
                DetTextStyles.bodyMd.copyWith(color: DetColors.textSecondary),
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          DetButton(
            label: DetStrings.exerciseCapture,
            icon: Icons.camera_alt_rounded,
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(exerciseNotifierProvider.notifier).captureExercise();
            },
          ),

          const SizedBox(height: DetSizes.lg),
        ],
      ),
    );
  }
}

// ── Chargement capture ──────────────────────────────────────────────────────

class _CaptureLoadingView extends StatelessWidget {
  const _CaptureLoadingView();

  @override
  Widget build(BuildContext context) {
    return const DetLoading(message: 'Ouverture de la caméra…');
  }
}

// ── Aperçu image ─────────────────────────────────────────────────────────────

class _ImagePreviewView extends StatelessWidget {
  const _ImagePreviewView({required this.exercise, required this.ref});
  final ExerciseEntity exercise;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DetSizes.lg),
      child: Column(
        children: [
          // Aperçu photo
          Expanded(
            child: ClipRRect(
              borderRadius: DetSizes.borderRadiusLg,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: DetSizes.borderRadiusLg,
                  border: Border.all(
                      color: DetColors.border, width: DetSizes.borderWidth),
                ),
                clipBehavior: Clip.antiAlias,
                child: exercise.imagePath.isNotEmpty
                    ? Image.network(exercise.imagePath, fit: BoxFit.contain)
                    : const Center(
                        child: Icon(Icons.image,
                            size: 64, color: DetColors.textMuted)),
              ),
            ),
          ),

          const SizedBox(height: DetSizes.lg),
          DetButton(
            label: 'Analyser avec DetAI',
            icon: Icons.psychology_rounded,
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(exerciseNotifierProvider.notifier).getHints();
            },
          ),
          const SizedBox(height: DetSizes.sm),
          DetButton(
            label: 'Reprendre',
            variant: DetButtonVariant.ghost,
            onPressed: () =>
                ref.read(exerciseNotifierProvider.notifier).reset(),
          ),
        ],
      ),
    );
  }
}

// ── Attente RAG ─────────────────────────────────────────────────────────────

class _WaitingHintsView extends StatelessWidget {
  const _WaitingHintsView({required this.exercise});
  final ExerciseEntity exercise;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: DetColors.accentGreen),
        ),
        const SizedBox(height: DetSizes.lg),
        const Text('Analyse en cours…', style: DetTextStyles.headingSm),
        const SizedBox(height: DetSizes.sm),
        Text(
          'Le moteur RAG prépare vos indices socratiques.',
          style: DetTextStyles.bodySm,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Affichage des indices ────────────────────────────────────────────────────

class _HintsView extends StatelessWidget {
  const _HintsView({required this.exercise, required this.ref});
  final ExerciseEntity exercise;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(DetSizes.lg),
      children: [
        const DetSectionHeader(title: DetStrings.exerciseHints),
        const SizedBox(height: DetSizes.lg),
        ...exercise.hints.map((hint) => Padding(
              padding: const EdgeInsets.only(bottom: DetSizes.md),
              child: _HintBubble(hint: hint),
            )),
        const SizedBox(height: DetSizes.xxl),
        DetButton(
          label: 'Nouvel exercice',
          icon: Icons.add_rounded,
          variant: DetButtonVariant.outline,
          onPressed: () => ref.read(exerciseNotifierProvider.notifier).reset(),
        ),
      ],
    );
  }
}

// ── HintBubble ───────────────────────────────────────────────────────────────

class _HintBubble extends StatelessWidget {
  const _HintBubble({required this.hint});
  final HintEntity hint;

  IconData get _icon => switch (hint.type) {
        HintType.question => Icons.help_outline_rounded,
        HintType.observation => Icons.visibility_outlined,
        HintType.reminder => Icons.bookmark_outline_rounded,
      };

  Color get _color => switch (hint.type) {
        HintType.question => DetColors.accentGreen,
        HintType.observation => DetColors.info,
        HintType.reminder => DetColors.warning,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DetSizes.md),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.06),
        borderRadius: DetSizes.borderRadiusMd,
        border: Border.all(
            color: _color.withValues(alpha: 0.25), width: DetSizes.borderWidth),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numéro + icône
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.15),
                  borderRadius: DetSizes.borderRadiusSm,
                ),
                child: Center(
                  child: Text(
                    '${hint.index}',
                    style: DetTextStyles.labelSm
                        .copyWith(color: _color, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: DetSizes.xs),
              Icon(_icon, size: DetSizes.iconSm, color: _color),
            ],
          ),
          const SizedBox(width: DetSizes.md),

          // Contenu
          Expanded(
            child: Text(hint.content, style: DetTextStyles.codeMd),
          ),
        ],
      ),
    );
  }
}
