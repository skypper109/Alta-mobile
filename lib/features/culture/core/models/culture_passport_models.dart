import 'package:flutter/material.dart';

/// Types d'éléments culturels pouvant être inscrits au Passeport
enum PassportItemType {
  personnage,
  monument,
  ville,
  region,
  conte,
  defi;

  String get label {
    switch (this) {
      case PassportItemType.personnage:
        return 'Grande Figure';
      case PassportItemType.monument:
        return 'Monument Historique';
      case PassportItemType.ville:
        return 'Cité & Village';
      case PassportItemType.region:
        return 'Terre & Région';
      case PassportItemType.conte:
        return 'Conte & Sagesse';
      case PassportItemType.defi:
        return 'Défi Relevé';
    }
  }

  IconData get icon {
    switch (this) {
      case PassportItemType.personnage:
        return Icons.person_rounded;
      case PassportItemType.monument:
        return Icons.account_balance_rounded;
      case PassportItemType.ville:
        return Icons.location_city_rounded;
      case PassportItemType.region:
        return Icons.map_rounded;
      case PassportItemType.conte:
        return Icons.auto_stories_rounded;
      case PassportItemType.defi:
        return Icons.military_tech_rounded;
    }
  }
}

/// Entrée individuelle estampillée dans le Passeport Culturel
class PassportEntry {
  final String id;
  final PassportItemType type;
  final String title;
  final String subtitle;
  final String? regionId;
  final String regionName;
  final String photoUrl;
  final String tag;
  final DateTime discoveredAt;
  final String? culturalQuote;
  final bool isMilestone;
  final String? milestoneLabel;
  final String targetRoute;

  const PassportEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    this.regionId,
    required this.regionName,
    required this.photoUrl,
    required this.tag,
    required this.discoveredAt,
    this.culturalQuote,
    this.isMilestone = false,
    this.milestoneLabel,
    required this.targetRoute,
  });

  PassportEntry copyWith({
    String? id,
    PassportItemType? type,
    String? title,
    String? subtitle,
    String? regionId,
    String? regionName,
    String? photoUrl,
    String? tag,
    DateTime? discoveredAt,
    String? culturalQuote,
    bool? isMilestone,
    String? milestoneLabel,
    String? targetRoute,
  }) {
    return PassportEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      regionId: regionId ?? this.regionId,
      regionName: regionName ?? this.regionName,
      photoUrl: photoUrl ?? this.photoUrl,
      tag: tag ?? this.tag,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      culturalQuote: culturalQuote ?? this.culturalQuote,
      isMilestone: isMilestone ?? this.isMilestone,
      milestoneLabel: milestoneLabel ?? this.milestoneLabel,
      targetRoute: targetRoute ?? this.targetRoute,
    );
  }
}

/// Sceau culturel honorifique / Distinction de voyageur (sans points XP)
class CulturalDistinction {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color sealColor;
  final bool isUnlocked;
  final String requirementText;
  final DateTime? unlockedAt;

  const CulturalDistinction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.sealColor,
    required this.isUnlocked,
    required this.requirementText,
    this.unlockedAt,
  });
}

/// État global du Passeport de l'utilisateur
class PassportState {
  final String travelerName;
  final String passportNumber;
  final DateTime issuedAt;
  final List<PassportEntry> entries;
  final List<String> exploredRegionIds;
  final PassportEntry? featuredDiscoveryOfTheDay;

  const PassportState({
    required this.travelerName,
    required this.passportNumber,
    required this.issuedAt,
    required this.entries,
    required this.exploredRegionIds,
    this.featuredDiscoveryOfTheDay,
  });

  // Filtres par type
  List<PassportEntry> get figures =>
      entries.where((e) => e.type == PassportItemType.personnage).toList();

  List<PassportEntry> get monuments =>
      entries.where((e) => e.type == PassportItemType.monument).toList();

  List<PassportEntry> get villes =>
      entries.where((e) => e.type == PassportItemType.ville).toList();

  List<PassportEntry> get contes =>
      entries.where((e) => e.type == PassportItemType.conte).toList();

  List<PassportEntry> get defis =>
      entries.where((e) => e.type == PassportItemType.defi).toList();

  List<PassportEntry> get milestones =>
      entries.where((e) => e.isMilestone).toList();

  int get totalDiscoveries => entries.length;

  bool isDiscovered(PassportItemType type, String id) {
    return entries.any((e) => e.type == type && e.id == id);
  }
}
