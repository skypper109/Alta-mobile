import 'package:flutter/material.dart';

/// Modèle pour les cartes et entrées culturelles de l'Étape 1
class CultureItem {
  final String id;
  final String title;
  final String subtitle;
  final String category; // 'accueil', 'decouvrir', 'contes', 'defis'
  final String subCategory; // 'personnages', 'villes', 'monuments', 'contes_interactifs', 'devinettes'
  final String description;
  final String? regionId;
  final String regionName;
  final String tag;
  final IconData icon;
  final String? imageUrl;
  final bool isFeatured;
  final String info; // ex: 'Lecture : 4 min', 'Niveau : Facile', '10 Devinettes'

  const CultureItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.subCategory,
    required this.description,
    this.regionId,
    required this.regionName,
    required this.tag,
    required this.icon,
    this.imageUrl,
    this.isFeatured = false,
    this.info = 'Découverte',
  });

  bool matchesRegion(String? selectedRegionId) {
    if (selectedRegionId == null || selectedRegionId.isEmpty || selectedRegionId == 'all') {
      return true;
    }
    if (regionId == null || regionId == 'all') {
      return true;
    }
    return regionId == selectedRegionId;
  }
}
