import 'package:flutter/material.dart';

/// Trait ou signature architecturale détectée par l'IA de vision
class ScanDetectionFeature {
  final String label;
  final double confidence; // De 0.0 à 1.0
  final String category; // ex: 'Matériau', 'Structure', 'Datation'
  final IconData icon;

  const ScanDetectionFeature({
    required this.label,
    required this.confidence,
    required this.category,
    this.icon = Icons.verified_rounded,
  });

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';
}

/// Définition complète d'un monument ou lieu malien reconnaissable par le Scanner IA
class MonumentScanTarget {
  final String id;
  final String name;
  final String subtitle;
  final String regionId;
  final String regionName;
  final String era;
  final String architectureStyle;
  final String locationDetails;
  final String photoUrl;
  final String tag;
  final List<String> keywords;
  final List<ScanDetectionFeature> detectionFeatures;
  final String secretsAndMysteries;
  final String historicalStory;
  final String audioNarrationText;
  final String whyItMatters;
  final String routePath;
  final double latitude;
  final double longitude;
  final String unlockedBadge;
  final int xpEarned;

  const MonumentScanTarget({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.regionId,
    required this.regionName,
    required this.era,
    required this.architectureStyle,
    required this.locationDetails,
    required this.photoUrl,
    required this.tag,
    required this.keywords,
    required this.detectionFeatures,
    required this.secretsAndMysteries,
    required this.historicalStory,
    required this.audioNarrationText,
    required this.whyItMatters,
    required this.routePath,
    required this.latitude,
    required this.longitude,
    required this.unlockedBadge,
    this.xpEarned = 50,
  });
}

/// Résultat d'une analyse d'image par le Scanner IA
class MonumentScanResult {
  final MonumentScanTarget target;
  final double confidence; // ex: 0.984
  final String? analyzedImagePath;
  final bool isFromCamera;
  final bool isDemoTarget;
  final DateTime scannedAt;
  final List<ScanDetectionFeature> recognizedFeatures;
  final double? estimatedDistanceKm;

  const MonumentScanResult({
    required this.target,
    required this.confidence,
    this.analyzedImagePath,
    this.isFromCamera = false,
    this.isDemoTarget = false,
    required this.scannedAt,
    required this.recognizedFeatures,
    this.estimatedDistanceKm,
  });

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';
}

/// États du cycle de vie du Scanner IA
enum ScannerStatus {
  idle,
  capturing,
  analyzing,
  recognized,
  unrecognized,
  error,
}

/// État réactif du contrôleur de Scanner
class ScannerState {
  final ScannerStatus status;
  final String currentStepMessage;
  final double progress; // 0.0 à 1.0
  final String? selectedImagePath;
  final MonumentScanResult? result;
  final String? errorMessage;
  final bool isFlashOn;
  final bool isAudioPlaying;
  final String? activeDemoTargetId;

  const ScannerState({
    this.status = ScannerStatus.idle,
    this.currentStepMessage = 'Pointez la caméra vers un monument ou un site',
    this.progress = 0.0,
    this.selectedImagePath,
    this.result,
    this.errorMessage,
    this.isFlashOn = false,
    this.isAudioPlaying = false,
    this.activeDemoTargetId,
  });

  bool get isIdle => status == ScannerStatus.idle;
  bool get isAnalyzing => status == ScannerStatus.analyzing;
  bool get isRecognized => status == ScannerStatus.recognized;
  bool get isUnrecognized => status == ScannerStatus.unrecognized;
  bool get hasError => status == ScannerStatus.error;

  ScannerState copyWith({
    ScannerStatus? status,
    String? currentStepMessage,
    double? progress,
    String? selectedImagePath,
    bool clearSelectedImage = false,
    MonumentScanResult? result,
    bool clearResult = false,
    String? errorMessage,
    bool clearError = false,
    bool? isFlashOn,
    bool? isAudioPlaying,
    String? activeDemoTargetId,
    bool clearDemoTarget = false,
  }) {
    return ScannerState(
      status: status ?? this.status,
      currentStepMessage: currentStepMessage ?? this.currentStepMessage,
      progress: progress ?? this.progress,
      selectedImagePath: clearSelectedImage
          ? null
          : (selectedImagePath ?? this.selectedImagePath),
      result: clearResult ? null : (result ?? this.result),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isAudioPlaying: isAudioPlaying ?? this.isAudioPlaying,
      activeDemoTargetId: clearDemoTarget
          ? null
          : (activeDemoTargetId ?? this.activeDemoTargetId),
    );
  }
}
