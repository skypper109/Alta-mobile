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

  factory ScanDetectionFeature.fromJson(Map<String, dynamic> json) {
    IconData resolvedIcon = Icons.verified_rounded;
    final iconName = (json['icon'] ?? '').toString();
    if (iconName.contains('layers')) {
      resolvedIcon = Icons.layers_rounded;
    } else if (iconName.contains('grain')) {
      resolvedIcon = Icons.grain_rounded;
    } else if (iconName.contains('architecture')) {
      resolvedIcon = Icons.architecture_rounded;
    } else if (iconName.contains('brightness') || iconName.contains('sun')) {
      resolvedIcon = Icons.brightness_high_rounded;
    } else if (iconName.contains('shield') || iconName.contains('security')) {
      resolvedIcon = Icons.shield_rounded;
    } else if (iconName.contains('nature') || iconName.contains('park')) {
      resolvedIcon = Icons.nature_rounded;
    } else if (iconName.contains('water')) {
      resolvedIcon = Icons.water_rounded;
    } else if (iconName.contains('flight')) {
      resolvedIcon = Icons.flight_takeoff_rounded;
    } else if (iconName.contains('history')) {
      resolvedIcon = Icons.history_edu_rounded;
    }

    return ScanDetectionFeature(
      label: json['label'] ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.95,
      category: json['category'] ?? 'Architecture',
      icon: resolvedIcon,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'confidence': confidence,
    'category': category,
  };
}

/// Définition complète d'un monument ou lieu malien reconnaissable par le Scanner IA
class MonumentScanTarget {
  final String id;
  final String name;
  final String subtitle;
  final String regionId;
  final String regionName;
  final String ville;
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
  final String? modele3dUrl;
  final bool arAvailable;
  final String validationStatus;
  final List<String> galleryPhotos;

  const MonumentScanTarget({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.regionId,
    required this.regionName,
    this.ville = 'Bamako',
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
    this.modele3dUrl,
    this.arAvailable = false,
    this.validationStatus = 'Patrimoine vérifié',
    this.galleryPhotos = const [],
  });

  factory MonumentScanTarget.fromJson(Map<String, dynamic> json) {
    final rawKeywords = json['keywords'] ?? json['mots_cles'] ?? [];
    final rawFeatures = json['detectionFeatures'] ?? json['caracteristiques_detection'] ?? [];

    List<String> keywordsList = [];
    if (rawKeywords is List) {
      keywordsList = rawKeywords.map((e) => e.toString()).toList();
    }

    List<ScanDetectionFeature> featuresList = [];
    if (rawFeatures is List) {
      featuresList = rawFeatures
          .whereType<Map<String, dynamic>>()
          .map((f) => ScanDetectionFeature.fromJson(f))
          .toList();
    }

    return MonumentScanTarget(
      id: json['id'] ?? '',
      name: json['name'] ?? json['nom'] ?? '',
      subtitle: json['subtitle'] ?? json['sous_titre'] ?? '',
      regionId: json['regionId'] ?? json['region_id'] ?? 'bamako',
      regionName: json['regionName'] ?? json['region_nom'] ?? 'Bamako',
      ville: json['ville'] ?? 'Bamako',
      era: json['era'] ?? json['epoque'] ?? '',
      architectureStyle: json['architectureStyle'] ?? json['style_architectural'] ?? '',
      locationDetails: json['locationDetails'] ?? json['details_localisation'] ?? '',
      photoUrl: json['photoUrl'] ?? json['photo_url'] ?? 'assets/images/culture/monuments/mosquee_djenne.jpg',
      tag: json['tag'] ?? 'Monument National',
      keywords: keywordsList,
      detectionFeatures: featuresList,
      secretsAndMysteries: json['secretsAndMysteries'] ?? json['secrets_et_mysteres'] ?? '',
      historicalStory: json['historicalStory'] ?? json['recit_historique'] ?? '',
      audioNarrationText: json['audioNarrationText'] ?? json['narration_audio_texte'] ?? '',
      whyItMatters: json['whyItMatters'] ?? json['pourquoi_ce_lieu_compte'] ?? '',
      routePath: json['routePath'] ?? json['route_path'] ?? '/culture/monuments',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 12.6392,
      longitude: (json['longitude'] as num?)?.toDouble() ?? -8.0029,
      unlockedBadge: json['unlockedBadge'] ?? json['badge_debloque'] ?? 'Pionnier du Patrimoine',
      xpEarned: (json['xpEarned'] ?? json['xp_recompense'] as num?)?.toInt() ?? 50,
      modele3dUrl: json['modele3dUrl'] ?? json['modele_3d_url'],
      arAvailable: json['arAvailable'] ?? json['ar_disponible'] ?? false,
      validationStatus: json['validationStatus'] ?? json['statut_validation'] ?? 'Patrimoine vérifié',
      galleryPhotos: (json['galleryPhotos'] ?? json['realPhotos'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subtitle': subtitle,
    'regionId': regionId,
    'regionName': regionName,
    'ville': ville,
    'era': era,
    'architectureStyle': architectureStyle,
    'locationDetails': locationDetails,
    'photoUrl': photoUrl,
    'galleryPhotos': galleryPhotos,
    'tag': tag,
    'keywords': keywords,
    'detectionFeatures': detectionFeatures.map((f) => f.toJson()).toList(),
    'secretsAndMysteries': secretsAndMysteries,
    'historicalStory': historicalStory,
    'audioNarrationText': audioNarrationText,
    'whyItMatters': whyItMatters,
    'routePath': routePath,
    'latitude': latitude,
    'longitude': longitude,
    'unlockedBadge': unlockedBadge,
    'xpEarned': xpEarned,
    'modele3dUrl': modele3dUrl,
    'arAvailable': arAvailable,
    'validationStatus': validationStatus,
  };
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

  factory MonumentScanResult.fromJson(Map<String, dynamic> json) {
    final targetMap = json['target'] as Map<String, dynamic>? ?? {};
    final target = MonumentScanTarget.fromJson(targetMap);
    final rawFeatures = json['recognizedFeatures'] as List? ?? target.detectionFeatures;

    return MonumentScanResult(
      target: target,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.95,
      analyzedImagePath: json['analyzedImagePath'],
      isFromCamera: json['isFromCamera'] ?? false,
      isDemoTarget: json['isDemoTarget'] ?? false,
      scannedAt: json['scannedAt'] != null ? DateTime.tryParse(json['scannedAt']) ?? DateTime.now() : DateTime.now(),
      recognizedFeatures: rawFeatures is List<ScanDetectionFeature>
          ? rawFeatures
          : rawFeatures.whereType<Map<String, dynamic>>().map((f) => ScanDetectionFeature.fromJson(f)).toList(),
      estimatedDistanceKm: (json['estimatedDistanceKm'] as num?)?.toDouble(),
    );
  }
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
