import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/controllers/culture_passport_controller.dart';
import '../../core/models/culture_passport_models.dart';
import '../../immersive/controllers/narration_coordinator.dart';
import '../../immersive/services/cultural_haptics.dart';
import '../models/story_experience_models.dart';

/// États de lecture du moteur narratif
enum PlaybackStatus {
  buffering,
  playing,
  waitingInteraction,
  transitioning,
  paused,
  completed,
}

/// État réactif du lecteur d'histoire
class StoryEngineState {
  final StoryExperienceScript script;
  final int currentSceneIndex;
  final PlaybackStatus status;
  final double sceneProgress;
  final bool isAudioPlaying;
  final bool isBaahSpeaking;
  final String? selectedChoiceId;
  final List<int> visitedSceneIndices;
  final bool hasStampedPassport;

  const StoryEngineState({
    required this.script,
    this.currentSceneIndex = 0,
    this.status = PlaybackStatus.playing,
    this.sceneProgress = 0.0,
    this.isAudioPlaying = false,
    this.isBaahSpeaking = false,
    this.selectedChoiceId,
    this.visitedSceneIndices = const [0],
    this.hasStampedPassport = false,
  });

  StorySceneModel get currentScene => script.scenes[currentSceneIndex];
  bool get hasNextScene => currentSceneIndex < script.scenes.length - 1;
  bool get hasPreviousScene => currentSceneIndex > 0;
  bool get isEpilogue => currentScene.type == SceneType.epilogueStamp || !hasNextScene;

  double get overallProgress {
    if (script.scenes.isEmpty) return 0.0;
    return (currentSceneIndex + 1) / script.scenes.length;
  }

  StoryEngineState copyWith({
    StoryExperienceScript? script,
    int? currentSceneIndex,
    PlaybackStatus? status,
    double? sceneProgress,
    bool? isAudioPlaying,
    bool? isBaahSpeaking,
    String? selectedChoiceId,
    bool clearChoice = false,
    List<int>? visitedSceneIndices,
    bool? hasStampedPassport,
  }) {
    return StoryEngineState(
      script: script ?? this.script,
      currentSceneIndex: currentSceneIndex ?? this.currentSceneIndex,
      status: status ?? this.status,
      sceneProgress: sceneProgress ?? this.sceneProgress,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
      isBaahSpeaking: isBaahSpeaking ?? this.isBaahSpeaking,
      selectedChoiceId: clearChoice ? null : (selectedChoiceId ?? this.selectedChoiceId),
      visitedSceneIndices: visitedSceneIndices ?? this.visitedSceneIndices,
      hasStampedPassport: hasStampedPassport ?? this.hasStampedPassport,
    );
  }
}

/// Contrôleur maître du moteur d'expériences narratives
class StoryExperienceController extends StateNotifier<StoryEngineState> {
  final Ref _ref;
  Timer? _sceneTimer;
  Timer? _progressTicker;

  StoryExperienceController(this._ref, StoryExperienceScript script)
      : super(StoryEngineState(script: script)) {
    _startScene(0);
  }

  /// Démarre une scène avec lancements synchronisés
  void _startScene(int index) {
    _cancelTimers();

    final scene = state.script.scenes[index];
    final updatedVisited = List<int>.from(state.visitedSceneIndices);
    if (!updatedVisited.contains(index)) {
      updatedVisited.add(index);
    }

    state = state.copyWith(
      currentSceneIndex: index,
      status: PlaybackStatus.playing,
      sceneProgress: 0.0,
      isBaahSpeaking: scene.baah != null,
      clearChoice: true,
      visitedSceneIndices: updatedVisited,
    );

    // Déclenchement de la narration vocale (voix du Griot / narrateur)
    final textToSpeak = scene.spokenAudioText ?? scene.narrativeText;
    final contentId = '${state.script.id}_scene_$index';

    _ref.read(narrationCoordinatorProvider.notifier).speak(
          textToSpeak,
          contentId: contentId,
          onComplete: () {
            if (mounted && scene.choices != null && scene.choices!.isNotEmpty) {
              state = state.copyWith(status: PlaybackStatus.waitingInteraction);
            }
          },
        );

    // Démarrage du suivi temporel de la scène
    _startProgressTicker(scene.estimatedDuration);

    // Enregistrement au passeport si on atteint l'épilogue
    if (scene.type == SceneType.epilogueStamp || index == state.script.scenes.length - 1) {
      _recordPassportDiscovery();
    }
  }

  void _startProgressTicker(Duration duration) {
    const tickInterval = Duration(milliseconds: 100);
    final totalTicks = duration.inMilliseconds / tickInterval.inMilliseconds;
    int currentTick = 0;

    _progressTicker = Timer.periodic(tickInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (state.status == PlaybackStatus.paused ||
          state.status == PlaybackStatus.waitingInteraction) {
        return;
      }

      currentTick++;
      final progress = (currentTick / totalTicks).clamp(0.0, 1.0);
      state = state.copyWith(sceneProgress: progress);

      if (progress >= 1.0) {
        timer.cancel();
        // Si la scène a des choix interactifs, on passe en attente
        if (state.currentScene.choices != null &&
            state.currentScene.choices!.isNotEmpty) {
          state = state.copyWith(status: PlaybackStatus.waitingInteraction);
        }
      }
    });
  }

  /// Avancer à la scène suivante
  void nextScene() {
    if (state.status == PlaybackStatus.waitingInteraction &&
        state.selectedChoiceId == null) {
      // Attend que l'élève choisisse une option
      return;
    }

    if (!state.hasNextScene) {
      completeStory();
      return;
    }

    CulturalHaptics.cardRelease();
    state = state.copyWith(status: PlaybackStatus.transitioning);

    Future.delayed(const Duration(milliseconds: 380), () {
      if (!mounted) return;
      _startScene(state.currentSceneIndex + 1);
    });
  }

  /// Revenir à la scène précédente
  void previousScene() {
    if (!state.hasPreviousScene) return;

    CulturalHaptics.cardRelease();
    state = state.copyWith(status: PlaybackStatus.transitioning);

    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _startScene(state.currentSceneIndex - 1);
    });
  }

  /// Sauter directement à une scène donnée
  void jumpToScene(int index) {
    if (index < 0 || index >= state.script.scenes.length) return;
    _startScene(index);
  }

  /// Sélection d'un choix interactif
  void selectChoice(StoryInteractiveOption choice) {
    CulturalHaptics.stamp();
    state = state.copyWith(selectedChoiceId: choice.id);

    // Brève temporisation pour laisser l'élève ressentir la sélection
    Future.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      if (choice.targetSceneIndex != null) {
        jumpToScene(choice.targetSceneIndex!);
      } else {
        nextScene();
      }
    });
  }

  /// Basculer lecture / pause
  void togglePlayPause() {
    CulturalHaptics.audioToggle();
    if (state.status == PlaybackStatus.paused) {
      state = state.copyWith(status: PlaybackStatus.playing);
    } else if (state.status == PlaybackStatus.playing) {
      state = state.copyWith(status: PlaybackStatus.paused);
      _ref.read(narrationCoordinatorProvider.notifier).stop();
    }
  }

  /// Relancer toute l'histoire depuis le début
  void replayStory() {
    CulturalHaptics.cardPress();
    _startScene(0);
  }

  void completeStory() {
    state = state.copyWith(status: PlaybackStatus.completed);
    CulturalHaptics.celebration();
    _recordPassportDiscovery();
  }

  void _recordPassportDiscovery() {
    if (state.hasStampedPassport) return;
    state = state.copyWith(hasStampedPassport: true);

    try {
      _ref.read(culturePassportProvider.notifier).recordDiscovery(
            id: state.script.id,
            type: _mapCategoryToPassportType(state.script.category),
            title: state.script.title,
            subtitle: state.script.subtitle,
            regionId: state.script.regionId,
            regionName: state.script.regionName,
            photoUrl: 'assets/images/culture/personnages/soundiata.jpg',
            tag: state.script.category,
            culturalQuote: '« La grandeur d\'un homme réside dans la mémoire vivante de son peuple. »',
            targetRoute: '/culture/story-experience/${state.script.id}',
            xpEarned: 100, // Découverte d'une histoire immersive complète
          );
    } catch (e) {
      debugPrint('[StoryExperienceController] Enregistrement passeport : $e');
    }
  }

  PassportItemType _mapCategoryToPassportType(String cat) {
    switch (cat.toLowerCase()) {
      case 'grandes figures':
      case 'personnage':
        return PassportItemType.personnage;
      case 'monuments':
        return PassportItemType.monument;
      case 'villes':
        return PassportItemType.ville;
      default:
        return PassportItemType.conte;
    }
  }

  void _cancelTimers() {
    _sceneTimer?.cancel();
    _progressTicker?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    _ref.read(narrationCoordinatorProvider.notifier).stop();
    super.dispose();
  }
}

/// Provider paramétré créant un contrôleur dédié pour un script donné
final storyExperienceProviderFamily = StateNotifierProvider.autoDispose
    .family<StoryExperienceController, StoryEngineState, StoryExperienceScript>(
  (ref, script) => StoryExperienceController(ref, script),
);
