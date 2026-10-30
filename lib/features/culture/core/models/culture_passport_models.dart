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
  final int xpEarned;
  final int coinsEarned;

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
    this.xpEarned = 50,
    this.coinsEarned = 15,
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
    int? xpEarned,
    int? coinsEarned,
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
      xpEarned: xpEarned ?? this.xpEarned,
      coinsEarned: coinsEarned ?? this.coinsEarned,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'regionId': regionId,
      'regionName': regionName,
      'photoUrl': photoUrl,
      'tag': tag,
      'discoveredAt': discoveredAt.toIso8601String(),
      'culturalQuote': culturalQuote,
      'isMilestone': isMilestone,
      'milestoneLabel': milestoneLabel,
      'targetRoute': targetRoute,
      'xpEarned': xpEarned,
      'coinsEarned': coinsEarned,
    };
  }

  factory PassportEntry.fromJson(Map<String, dynamic> json) {
    return PassportEntry(
      id: json['id'] as String? ?? '',
      type: PassportItemType.values.firstWhere(
        (t) => t.name == (json['type'] as String?),
        orElse: () => PassportItemType.monument,
      ),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      regionId: json['regionId'] as String?,
      regionName: json['regionName'] as String? ?? 'Tout le Mali',
      photoUrl: json['photoUrl'] as String? ?? '',
      tag: json['tag'] as String? ?? '',
      discoveredAt: json['discoveredAt'] != null
          ? DateTime.tryParse(json['discoveredAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      culturalQuote: json['culturalQuote'] as String?,
      isMilestone: json['isMilestone'] as bool? ?? false,
      milestoneLabel: json['milestoneLabel'] as String?,
      targetRoute: json['targetRoute'] as String? ?? '',
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 50,
      coinsEarned: (json['coinsEarned'] as num?)?.toInt() ?? 15,
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
  final int bonusCultureXp;
  final int bonusCultureCoins;

  const PassportState({
    required this.travelerName,
    required this.passportNumber,
    required this.issuedAt,
    required this.entries,
    required this.exploredRegionIds,
    this.featuredDiscoveryOfTheDay,
    this.bonusCultureXp = 0,
    this.bonusCultureCoins = 0,
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

  // Calculs d'XP et Pièces de Sagesse (strictement réservés à l'espace Culture)
  int get totalXp => entries.fold<int>(bonusCultureXp, (sum, e) => sum + e.xpEarned);
  int get totalCoins => entries.fold<int>(bonusCultureCoins, (sum, e) => sum + e.coinsEarned);
  int get defisXp => defis.fold<int>(0, (sum, e) => sum + e.xpEarned);
  int get contesXp => contes.fold<int>(0, (sum, e) => sum + e.xpEarned);
  int get monumentsXp => monuments.fold<int>(0, (sum, e) => sum + e.xpEarned);
  int get figuresXp => figures.fold<int>(0, (sum, e) => sum + e.xpEarned);
  int get villesXp => villes.fold<int>(0, (sum, e) => sum + e.xpEarned);

  int get level {
    final xp = totalXp;
    if (xp < 250) return 1;
    if (xp < 600) return 2;
    if (xp < 1200) return 3;
    return 4;
  }

  int get rankLevel => level;

  String get rankTitle {
    switch (level) {
      case 1:
        return 'Apprenti du Sahel';
      case 2:
        return 'Initié du Manden';
      case 3:
        return 'Gardien des Savoirs';
      case 4:
      default:
        return 'Maître Dozo & Érudit';
    }
  }

  String get nextRankTitle {
    switch (level) {
      case 1:
        return 'Initié du Manden';
      case 2:
        return 'Gardien des Savoirs';
      case 3:
      case 4:
      default:
        return 'Maître Dozo & Érudit';
    }
  }

  int get nextRankXp {
    switch (level) {
      case 1:
        return 250;
      case 2:
        return 600;
      case 3:
        return 1200;
      case 4:
      default:
        return 2000;
    }
  }

  int get currentRankBaseXp {
    switch (level) {
      case 1:
        return 0;
      case 2:
        return 250;
      case 3:
        return 600;
      case 4:
      default:
        return 1200;
    }
  }

  double get rankProgress {
    final base = currentRankBaseXp;
    final target = nextRankXp;
    if (target <= base) return 1.0;
    return ((totalXp - base) / (target - base)).clamp(0.0, 1.0);
  }

  bool isDiscovered(PassportItemType type, String id) {
    return entries.any((e) => e.type == type && e.id == id);
  }
}
