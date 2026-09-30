import 'package:flutter/material.dart';

/// Modèle pour les proverbes et maximes traditionnels du Mali
class CultureProverb {
  final String id;
  final String text; // Texte traduit en français
  final String? originalText; // Texte original (Bambara, Songhaï, Peul, Dogon, etc.)
  final String meaning; // Explication profonde et transmission des aînés
  final String? moral; // Enseignement clé condensé
  final String origin; // Tradition culturelle (ex: Tradition Bamanan du Manden)
  final String theme; // Thématique (ex: Humilité, Solidarité, Respect)
  final String? regionId; // Id de la région pour le filtrage
  final String regionName; // Nom de la région (ex: Manden, Ségou, Pays Dogon)
  final int xpReward; // Récompense XP de lecture/découverte
  final String stageImagePath; // Image de fond scénique (savane, baobab, fleuve...)
  final String speakerName; // Nom du sage ou griot transmetteur
  final String speakerRole; // Rôle (Griot, Doyen de village, Mère veilleuse...)
  final String speakerAvatar; // Photo de l'orateur/sage
  final Color accentColor;

  const CultureProverb({
    required this.id,
    required this.text,
    this.originalText,
    required this.meaning,
    this.moral,
    required this.origin,
    required this.theme,
    this.regionId,
    required this.regionName,
    this.xpReward = 40,
    this.stageImagePath = 'assets/images/culture/contes/manden_baobab_stage.jpg',
    this.speakerName = 'Le Sage du Baobab',
    this.speakerRole = 'Doyen des Terroirs',
    this.speakerAvatar = 'assets/images/culture/contes/sage_baobab.jpg',
    this.accentColor = const Color(0xFFF1851F),
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
