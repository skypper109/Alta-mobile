import 'package:flutter/material.dart';

/// Devinette traditionnelle malienne (« N'Da ! »)
class TraditionalRiddle {
  final String id;
  final String formulaIntro; // Ex: "« N'Da ! » — « N'Da n'sira ! »"
  final String riddleText; // L'énigme posée
  final List<String> hints; // 3 indices progressifs
  final List<String> options; // Choix possibles
  final String correctAnswer; // La bonne réponse
  final String culturalExplanation; // Explication & transmission des aînés
  final String? proverb; // Proverbe ou maxime associé
  final String? regionId; // Filtre régional (null pour Tout le Mali)
  final String regionName;
  final String category; // 'Éléments de la Nature', 'Objets Sacrés', 'Sagesse'
  final String difficulty; // 'Initié', 'Apprenti', 'Maître Dozo'
  final int xpReward;
  final String? photoUrl;

  const TraditionalRiddle({
    required this.id,
    this.formulaIntro = "« N'Da ! » — « N'Da n'sira ! »",
    required this.riddleText,
    required this.hints,
    required this.options,
    required this.correctAnswer,
    required this.culturalExplanation,
    this.proverb,
    this.regionId,
    required this.regionName,
    required this.category,
    this.difficulty = 'Initié',
    this.xpReward = 50,
    this.photoUrl,
  });

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

/// Question de quiz culturel à choix multiples
class CultureQuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String category;
  final String? regionId;
  final String regionName;
  final int xp;

  const CultureQuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.category,
    this.regionId,
    required this.regionName,
    this.xp = 30,
  });

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

/// Quête / Mission découverte du patrimoine
class DiscoveryMission {
  final String id;
  final String title;
  final String description;
  final String actionRoute;
  final String category;
  final int xp;
  final IconData icon;
  final bool isCompleted;

  const DiscoveryMission({
    required this.id,
    required this.title,
    required this.description,
    required this.actionRoute,
    required this.category,
    required this.xp,
    this.icon = Icons.explore_rounded,
    this.isCompleted = false,
  });
}

/// Profil de progression ludique du joueur
class ChallengeUserProfile {
  final int level;
  final String rankTitle; // Ex: 'Initié du Manden'
  final int totalXp;
  final int riddlesSolved;
  final int quizzesCompleted;
  final int dailyStreak;

  const ChallengeUserProfile({
    this.level = 2,
    this.rankTitle = 'Initié du Manden',
    this.totalXp = 380,
    this.riddlesSolved = 7,
    this.quizzesCompleted = 4,
    this.dailyStreak = 3,
  });
}
