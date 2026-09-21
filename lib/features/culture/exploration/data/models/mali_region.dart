import 'package:flutter/material.dart';

/// Modèle de données représentant une région administrative et culturelle du Mali
class MaliRegion {
  final String id;
  final String nom;
  final String code;
  final String surnom;
  final String chefLieu;
  final String descriptionCourte;
  final String descriptionComplete;
  final List<String> pointsForts;
  final List<String> symbolesEtTraditions;
  final Color couleurAccent;
  final IconData icone;
  final String? imageAsset;
  final String superficie;
  final String population;
  final Offset centreRelatif; // Coordonnées relatives (0.0 -> 1.0) sur la carte pour centrage & labels

  const MaliRegion({
    required this.id,
    required this.nom,
    required this.code,
    required this.surnom,
    required this.chefLieu,
    required this.descriptionCourte,
    required this.descriptionComplete,
    required this.pointsForts,
    required this.symbolesEtTraditions,
    required this.couleurAccent,
    required this.icone,
    this.imageAsset,
    required this.superficie,
    required this.population,
    required this.centreRelatif,
  });

  /// Factory pour sérialisation depuis une API FastAPI JSON
  factory MaliRegion.fromJson(Map<String, dynamic> json) {
    return MaliRegion(
      id: json['id'] as String,
      nom: json['nom'] as String,
      code: json['code'] as String? ?? '',
      surnom: json['surnom'] as String? ?? '',
      chefLieu: json['chef_lieu'] as String? ?? '',
      descriptionCourte: json['description_courte'] as String? ?? '',
      descriptionComplete: json['description_complete'] as String? ?? '',
      pointsForts: (json['points_forts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      symbolesEtTraditions: (json['symboles_traditions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      couleurAccent: Color(
        int.tryParse(json['couleur_hex']?.toString().replaceFirst('#', '0xFF') ?? '') ??
            0xFFC67C2E,
      ),
      icone: Icons.explore_rounded,
      imageAsset: json['image_url'] as String?,
      superficie: json['superficie'] as String? ?? '',
      population: json['population'] as String? ?? '',
      centreRelatif: Offset(
        (json['centre_x'] as num?)?.toDouble() ?? 0.5,
        (json['centre_y'] as num?)?.toDouble() ?? 0.5,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'code': code,
      'surnom': surnom,
      'chef_lieu': chefLieu,
      'description_courte': descriptionCourte,
      'description_complete': descriptionComplete,
      'points_forts': pointsForts,
      'symboles_traditions': symbolesEtTraditions,
      'couleur_hex': '#${couleurAccent.toARGB32().toRadixString(16).substring(2)}',
      'superficie': superficie,
      'population': population,
      'centre_x': centreRelatif.dx,
      'centre_y': centreRelatif.dy,
    };
  }

  MaliRegion copyWith({
    String? id,
    String? nom,
    String? code,
    String? surnom,
    String? chefLieu,
    String? descriptionCourte,
    String? descriptionComplete,
    List<String>? pointsForts,
    List<String>? symbolesEtTraditions,
    Color? couleurAccent,
    IconData? icone,
    String? imageAsset,
    String? superficie,
    String? population,
    Offset? centreRelatif,
  }) {
    return MaliRegion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      code: code ?? this.code,
      surnom: surnom ?? this.surnom,
      chefLieu: chefLieu ?? this.chefLieu,
      descriptionCourte: descriptionCourte ?? this.descriptionCourte,
      descriptionComplete: descriptionComplete ?? this.descriptionComplete,
      pointsForts: pointsForts ?? this.pointsForts,
      symbolesEtTraditions: symbolesEtTraditions ?? this.symbolesEtTraditions,
      couleurAccent: couleurAccent ?? this.couleurAccent,
      icone: icone ?? this.icone,
      imageAsset: imageAsset ?? this.imageAsset,
      superficie: superficie ?? this.superficie,
      population: population ?? this.population,
      centreRelatif: centreRelatif ?? this.centreRelatif,
    );
  }
}
