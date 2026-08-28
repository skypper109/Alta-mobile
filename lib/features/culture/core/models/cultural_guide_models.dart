import 'package:flutter/material.dart';

/// Type de contenu culturel actuellement consulté
enum CulturalContentType {
  personnage,
  monument,
  ville,
  conte,
  defi,
  region,
  passeport,
  general,
}

/// Contexte transmis au Guide Culturel IA
class CulturalGuideContext {
  final CulturalContentType contentType;
  final String? contentId;
  final String contentTitle;
  final String? subtitle;
  final String? regionId;
  final String regionName;
  final String? photoUrl;
  final String? tag;

  const CulturalGuideContext({
    this.contentType = CulturalContentType.general,
    this.contentId,
    this.contentTitle = 'Découverte du Mali',
    this.subtitle,
    this.regionId,
    this.regionName = 'Tout le Mali',
    this.photoUrl,
    this.tag,
  });

  /// Contexte général par défaut (accueil Culture)
  static const CulturalGuideContext general = CulturalGuideContext();
}

/// Suggestion de question contextualisée
class GuideSuggestion {
  final String id;
  final String questionText;
  final IconData icon;

  const GuideSuggestion({
    required this.id,
    required this.questionText,
    this.icon = Icons.help_outline_rounded,
  });
}

/// Action patrimoniale connectée proposée par le guide dans sa réponse
class GuideConnectedAction {
  final String label;
  final String targetRoute;
  final IconData icon;

  const GuideConnectedAction({
    required this.label,
    required this.targetRoute,
    this.icon = Icons.arrow_forward_rounded,
  });
}

/// Message de dialogue dans la conversation avec le Guide Culturel
class GuideMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final GuideConnectedAction? action;

  const GuideMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.action,
  });
}
