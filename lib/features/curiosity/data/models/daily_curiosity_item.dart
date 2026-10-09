import 'package:flutter/material.dart';

/// Défi éclair interactif de 20 secondes
class CuriosityChallenge {
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final int xpReward;

  const CuriosityChallenge({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    this.xpReward = 50,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctOptionIndex': correctOptionIndex,
        'explanation': explanation,
        'xpReward': xpReward,
      };

  factory CuriosityChallenge.fromJson(Map<String, dynamic> json) =>
      CuriosityChallenge(
        question: json['question'] as String? ?? '',
        options: (json['options'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        correctOptionIndex: json['correctOptionIndex'] as int? ?? 0,
        explanation: json['explanation'] as String? ?? '',
        xpReward: json['xpReward'] as int? ?? 50,
      );
}

/// Carte collector virtuelle débloquée après avoir réussi le défi
class CollectorCardBadge {
  final String cardTitle;
  final String rarity; // "Légendaire", "Épique", "Rare", "Historique"
  final String cardNumber; // Ex: "01 / 30"
  final Color accentColor;

  const CollectorCardBadge({
    required this.cardTitle,
    required this.rarity,
    required this.cardNumber,
    this.accentColor = const Color(0xFFF59E0B),
  });
}

/// Modèle d'une Pépite Quotidienne de Curiosité (30 secondes de découverte + 20s de défi)
class DailyCuriosityItem {
  final String id;
  final int dayNumber;
  final String hookTitle;
  final String category;
  final String readTime;
  final String storySnippet;
  final String fullStory;
  final String audioNarrationText;
  final String imageUrl;
  final String imageCredits;
  final String tomorrowTeaser;
  final CuriosityChallenge challenge;
  final CollectorCardBadge collectorCard;

  const DailyCuriosityItem({
    required this.id,
    required this.dayNumber,
    required this.hookTitle,
    required this.category,
    required this.readTime,
    required this.storySnippet,
    required this.fullStory,
    required this.audioNarrationText,
    required this.imageUrl,
    required this.imageCredits,
    required this.tomorrowTeaser,
    required this.challenge,
    required this.collectorCard,
  });
}
