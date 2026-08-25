import 'package:flutter/material.dart';

/// Modèle représentant un élément à découvrir dans la région
/// (lieu, savoir-faire, personnage, événement, tradition)
class CulturalDiscovery {
  final String id;
  final String titre;
  final String categorie; // 'Artisanat', 'Tradition', 'Nature', 'Histoire', 'Figure', 'Événement'
  final String description;
  final String? imageUrl;
  final String tag;
  final IconData icone;
  final String? lieu;
  final bool isFeatured; // Si true → grande carte éditoriale en tête de section

  const CulturalDiscovery({
    required this.id,
    required this.titre,
    required this.categorie,
    required this.description,
    this.imageUrl,
    required this.tag,
    required this.icone,
    this.lieu,
    this.isFeatured = false,
  });

  factory CulturalDiscovery.fromJson(Map<String, dynamic> json) {
    return CulturalDiscovery(
      id: json['id'] as String,
      titre: json['titre'] as String,
      categorie: json['categorie'] as String? ?? 'Découverte',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      tag: json['tag'] as String? ?? '',
      icone: Icons.explore_rounded,
      lieu: json['lieu'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'categorie': categorie,
      'description': description,
      'image_url': imageUrl,
      'tag': tag,
      'lieu': lieu,
      'is_featured': isFeatured,
    };
  }
}
