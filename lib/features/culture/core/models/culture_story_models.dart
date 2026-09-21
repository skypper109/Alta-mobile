import 'package:flutter/material.dart';
import 'culture_detail_models.dart';

/// Choix interactif proposé à l'utilisateur dans une scène
class StoryChoice {
  final String id;
  final String label; // Ex: 'A - Consulter l\'ancien sous le Toguna'
  final String description; // Ex: 'Vous écoutez le conseil des aînés avec respect.'
  final String nextSceneId;
  final String? trait; // Ex: 'Voie de la Sagesse', 'Voie de l\'Audace'
  final IconData icon;

  const StoryChoice({
    required this.id,
    required this.label,
    required this.description,
    required this.nextSceneId,
    this.trait,
    this.icon = Icons.auto_awesome_rounded,
  });
}

/// Étape narrative / Scène du conte interactif
class StoryScene {
  final String id;
  final int sceneNumber;
  final String title;
  final String narrativeText;
  final String? atmosphere; // Ex: 'Veillée étoilée au son de la Kora'
  final String? visualUrl;
  final String? audioSnippetText;
  final String? culturalInsight; // Insight culturel / proverbe / secret de tradition
  final bool isEpilogue;
  final List<StoryChoice> choices;

  const StoryScene({
    required this.id,
    required this.sceneNumber,
    required this.title,
    required this.narrativeText,
    this.atmosphere,
    this.visualUrl,
    this.audioSnippetText,
    this.culturalInsight,
    this.isEpilogue = false,
    this.choices = const [],
  });
}

/// Fiche complète d'un Conte Interactif malien
class InteractiveStory {
  final String id;
  final String title;
  final String subtitle;
  final String origin; // Ex: 'Tradition Mandingue', 'Royaume de Ségou'
  final String? regionId; // 'koulikoro', 'segou', 'kayes', 'tombouctou', 'mopti', null pour Tout le Mali
  final String regionName;
  final String tag; // 'Conte Initiatique', 'Fable Mandingue', 'Récit Mythique'
  final String photoUrl;
  final String photoCredits;
  final String summary;
  final String narrator; // Ex: 'Griot Mamadou Kouyaté'
  final String audioDuration; // Ex: '6 min 30'
  final String readingDuration; // Ex: '4 min'
  final bool isFeatured;
  final String moral; // Morale et enseignement traditionnel
  final List<ConnectedItemRef> connectedItems;
  final List<StoryScene> scenes;
  final double progress; // 0.0 à 1.0 pour reprise de lecture

  const InteractiveStory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.origin,
    this.regionId,
    required this.regionName,
    required this.tag,
    required this.photoUrl,
    required this.photoCredits,
    required this.summary,
    required this.narrator,
    required this.audioDuration,
    required this.readingDuration,
    this.isFeatured = false,
    required this.moral,
    this.connectedItems = const [],
    required this.scenes,
    this.progress = 0.0,
  });

  /// Trouve une scène par son ID
  StoryScene? getSceneById(String sceneId) {
    try {
      return scenes.firstWhere((s) => s.id == sceneId);
    } catch (_) {
      return scenes.isNotEmpty ? scenes.first : null;
    }
  }

  /// Scène initiale du conte
  StoryScene get initialScene => scenes.first;

  /// Vérifie si le conte correspond à un filtre régional
  bool matchesRegion(String? selectedRegionId) {
    if (selectedRegionId == null ||
        selectedRegionId.isEmpty ||
        selectedRegionId == 'all') {
      return true;
    }
    if (regionId == null || regionId == 'all') {
      return true;
    }
    return regionId == selectedRegionId;
  }
}
