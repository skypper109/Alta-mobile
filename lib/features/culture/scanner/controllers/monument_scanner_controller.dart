import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/controllers/culture_passport_controller.dart';
import '../../core/models/culture_passport_models.dart';
import '../../immersive/controllers/narration_coordinator.dart';
import '../../immersive/services/cultural_haptics.dart';
import '../models/monument_scan_models.dart';
import '../services/monument_scanner_service.dart';

import '../../core/datasources/culture_repository.dart';

/// Provider d'instance du service de scan
final monumentScannerServiceProvider = Provider<MonumentScannerService>((ref) {
  final repository = ref.watch(cultureRepositoryProvider);
  return MonumentScannerService(repository: repository);
});


/// Provider d'état du Scanner IA de Monuments
final monumentScannerControllerProvider =
    StateNotifierProvider<MonumentScannerController, ScannerState>((ref) {
  final service = ref.watch(monumentScannerServiceProvider);
  return MonumentScannerController(ref, service);
});

/// Contrôleur Riverpod pour le Scanner IA de Lieux & Monuments
class MonumentScannerController extends StateNotifier<ScannerState> {
  final Ref _ref;
  final MonumentScannerService _service;

  MonumentScannerController(this._ref, this._service)
      : super(const ScannerState());

  /// Lancement de la capture via l'appareil photo
  Future<void> captureWithCamera() async {
    HapticFeedback.heavyImpact();
    state = state.copyWith(
      status: ScannerStatus.capturing,
      currentStepMessage: 'Ouverture de l\'objectif...',
      clearError: true,
    );

    final path = await _service.captureFromCamera();
    if (path == null) {
      state = state.copyWith(
        status: ScannerStatus.idle,
        currentStepMessage: 'Pointez la caméra vers un monument ou un site',
      );
      return;
    }

    await _processImagePath(path);
  }

  /// Sélection d'une photo depuis la galerie
  Future<void> pickFromGallery() async {
    HapticFeedback.selectionClick();
    state = state.copyWith(
      status: ScannerStatus.capturing,
      currentStepMessage: 'Sélection d\'une image...',
      clearError: true,
    );

    final path = await _service.pickFromGallery();
    if (path == null) {
      state = state.copyWith(
        status: ScannerStatus.idle,
        currentStepMessage: 'Pointez la caméra vers un monument ou un site',
      );
      return;
    }

    await _processImagePath(path);
  }

  /// Démonstration directe / Simulation de cible (idéal pour jury & offline)
  Future<void> scanDemoTarget(MonumentScanTarget target) async {
    HapticFeedback.mediumImpact();
    state = state.copyWith(
      status: ScannerStatus.analyzing,
      selectedImagePath: target.photoUrl,
      activeDemoTargetId: target.id,
      progress: 0.1,
      currentStepMessage: 'Scan de la cible « ${target.name} »...',
      clearResult: true,
      clearError: true,
    );

    try {
      final result = await _service.analyzeDemoTarget(
        target: target,
        onProgress: (stepMessage, progress) {
          state = state.copyWith(
            currentStepMessage: stepMessage,
            progress: progress,
          );
        },
      );

      _onRecognitionSuccess(result);
    } catch (e) {
      state = state.copyWith(
        status: ScannerStatus.error,
        errorMessage: 'Échec de l\'analyse du monument : $e',
      );
    }
  }

  /// Traitement du chemin d'image sélectionné
  Future<void> _processImagePath(String imagePath) async {
    state = state.copyWith(
      status: ScannerStatus.analyzing,
      selectedImagePath: imagePath,
      progress: 0.15,
      currentStepMessage: 'Initialisation de l\'analyse...',
      clearResult: true,
      clearError: true,
    );

    try {
      final result = await _service.analyzeImage(
        imagePath: imagePath,
        onProgress: (stepMessage, progress) {
          state = state.copyWith(
            currentStepMessage: stepMessage,
            progress: progress,
          );
        },
      );

      _onRecognitionSuccess(result);
    } catch (e) {
      state = state.copyWith(
        status: ScannerStatus.error,
        errorMessage: 'Erreur lors du traitement visuel : $e',
      );
    }
  }

  /// Traitement après reconnaissance réussie
  void _onRecognitionSuccess(MonumentScanResult result) {
    CulturalHaptics.celebration();

    state = state.copyWith(
      status: ScannerStatus.recognized,
      result: result,
      progress: 1.0,
      currentStepMessage: 'Monument identifié : ${result.target.name}',
    );

    // Enregistrement automatique au Passeport Culturel de l'utilisateur
    _ref.read(culturePassportProvider.notifier).recordDiscovery(
          id: result.target.id,
          type: PassportItemType.monument,
          title: result.target.name,
          subtitle: result.target.subtitle,
          regionId: result.target.regionId,
          regionName: result.target.regionName,
          photoUrl: result.target.photoUrl,
          tag: result.target.tag,
          culturalQuote:
              '« Trésor patrimonial reconnu et ajouté à votre carnet de découverte. »',
          targetRoute: result.target.routePath,
          isMilestone: true,
          milestoneLabel: 'Monument découvert',
          xpEarned: result.target.xpEarned,
        );
  }

  /// Bascule de la lecture audio (Griot Numérique)
  Future<void> toggleAudioNarration() async {
    final result = state.result;
    if (result == null) return;

    final coordinator = _ref.read(narrationCoordinatorProvider.notifier);
    final isPlaying = state.isAudioPlaying;

    if (isPlaying) {
      await coordinator.stop();
      state = state.copyWith(isAudioPlaying: false);
    } else {
      HapticFeedback.lightImpact();
      state = state.copyWith(isAudioPlaying: true);

      await coordinator.speak(
        result.target.audioNarrationText,
        contentId: result.target.id,
        onComplete: () {
          state = state.copyWith(isAudioPlaying: false);
        },
      );
    }
  }

  /// Arrêter la narration
  Future<void> stopAudioNarration() async {
    if (state.isAudioPlaying) {
      await _ref.read(narrationCoordinatorProvider.notifier).stop();
      state = state.copyWith(isAudioPlaying: false);
    }
  }

  /// Bascule du flash
  void toggleFlash() {
    HapticFeedback.selectionClick();
    state = state.copyWith(isFlashOn: !state.isFlashOn);
  }

  /// Réinitialisation pour un nouveau scan
  void reset() {
    stopAudioNarration();
    HapticFeedback.selectionClick();
    state = const ScannerState();
  }
}
