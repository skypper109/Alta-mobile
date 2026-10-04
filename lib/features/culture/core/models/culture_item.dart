import 'package:flutter/material.dart';

/// Modèle pour les cartes et entrées culturelles
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

  static IconData iconFromName(String? name, {String? subCategory}) {
    if (name != null) {
      switch (name) {
        case 'shield_rounded':
          return Icons.shield_rounded;
        case 'person_rounded':
          return Icons.person_rounded;
        case 'account_balance_rounded':
          return Icons.account_balance_rounded;
        case 'security_rounded':
          return Icons.security_rounded;
        case 'history_edu_rounded':
          return Icons.history_edu_rounded;
        case 'military_tech_rounded':
          return Icons.military_tech_rounded;
        case 'location_city_rounded':
          return Icons.location_city_rounded;
        case 'nature_people_rounded':
          return Icons.nature_people_rounded;
        case 'terrain_rounded':
          return Icons.terrain_rounded;
        case 'menu_book_rounded':
          return Icons.menu_book_rounded;
        case 'park_rounded':
          return Icons.park_rounded;
        case 'flag_rounded':
          return Icons.flag_rounded;
        case 'apartment_rounded':
          return Icons.apartment_rounded;
        case 'flutter_dash_rounded':
          return Icons.flutter_dash_rounded;
        case 'museum_rounded':
          return Icons.museum_rounded;
        case 'pets_rounded':
          return Icons.pets_rounded;
        case 'theater_comedy_rounded':
          return Icons.theater_comedy_rounded;
        case 'local_fire_department_rounded':
          return Icons.local_fire_department_rounded;
        case 'public_rounded':
          return Icons.public_rounded;
        case 'church_rounded':
          return Icons.church_rounded;
        case 'mosque_rounded':
          return Icons.mosque_rounded;
        case 'woman_rounded':
          return Icons.woman_rounded;
        case 'stars_rounded':
          return Icons.stars_rounded;
        case 'emoji_flags_rounded':
          return Icons.emoji_flags_rounded;
        case 'castle_rounded':
          return Icons.castle_rounded;
        case 'architecture_rounded':
          return Icons.architecture_rounded;
        case 'domain_rounded':
          return Icons.domain_rounded;
        case 'school_rounded':
          return Icons.school_rounded;
        case 'fort_rounded':
          return Icons.fort_rounded;
        case 'palette_rounded':
          return Icons.palette_rounded;
        case 'auto_stories_rounded':
          return Icons.auto_stories_rounded;
        case 'psychology_alt_rounded':
          return Icons.psychology_alt_rounded;
        case 'quiz_rounded':
          return Icons.quiz_rounded;
        case 'lightbulb_rounded':
          return Icons.lightbulb_rounded;
      }
    }
    switch (subCategory) {
      case 'personnages':
        return Icons.person_rounded;
      case 'villes':
        return Icons.location_city_rounded;
      case 'monuments':
        return Icons.museum_rounded;
      case 'contes_interactifs':
        return Icons.auto_stories_rounded;
      case 'devinettes':
        return Icons.quiz_rounded;
      default:
        return Icons.explore_rounded;
    }
  }

  static String iconToName(IconData icon) {
    if (icon == Icons.person_rounded) return 'person_rounded';
    if (icon == Icons.location_city_rounded) return 'location_city_rounded';
    if (icon == Icons.museum_rounded) return 'museum_rounded';
    if (icon == Icons.auto_stories_rounded) return 'auto_stories_rounded';
    if (icon == Icons.quiz_rounded) return 'quiz_rounded';
    if (icon == Icons.shield_rounded) return 'shield_rounded';
    if (icon == Icons.church_rounded) return 'church_rounded';
    if (icon == Icons.mosque_rounded) return 'mosque_rounded';
    if (icon == Icons.castle_rounded) return 'castle_rounded';
    if (icon == Icons.terrain_rounded) return 'terrain_rounded';
    if (icon == Icons.park_rounded) return 'park_rounded';
    if (icon == Icons.flutter_dash_rounded) return 'flutter_dash_rounded';
    if (icon == Icons.pets_rounded) return 'pets_rounded';
    if (icon == Icons.theater_comedy_rounded) return 'theater_comedy_rounded';
    return 'explore_rounded';
  }

  factory CultureItem.fromMonument(Map<String, dynamic> json) {
    final id = json['id'] ?? '';
    final name = json['name'] ?? json['nom'] ?? '';
    final subtitle = json['subtitle'] ?? json['sous_titre'] ?? '';
    final desc = json['historicalStory'] ?? json['recit_historique'] ?? json['presentation'] ?? json['whyItMatters'] ?? '';
    final regId = json['regionId'] ?? json['region_id'];
    final regName = json['regionName'] ?? json['region_nom'] ?? 'Mali';
    final tag = json['tag'] ?? 'Monument';
    final photo = json['photoUrl'] ?? json['photo_url'];
    final era = json['era'] ?? json['epoque'] ?? 'Monument National';

    return CultureItem(
      id: id,
      title: name,
      subtitle: subtitle,
      category: 'decouvrir',
      subCategory: 'monuments',
      description: desc,
      regionId: regId,
      regionName: regName,
      tag: tag,
      icon: iconFromName(null, subCategory: 'monuments'),
      imageUrl: photo,
      info: era,
    );
  }

  factory CultureItem.fromFigure(Map<String, dynamic> json) {
    final id = json['id'] ?? '';
    final name = json['name'] ?? json['nom'] ?? '';
    final subtitle = json['titleHonorifique'] ?? json['titre_honorifique'] ?? '';
    final desc = json['resume'] ?? '';
    final regId = json['regionId'] ?? json['region_id'];
    final regName = json['regionName'] ?? json['region_nom'] ?? 'Mali';
    final tag = json['tag'] ?? 'Mansa';
    final photo = json['photoUrl'] ?? json['photo_url'];
    final period = json['period'] ?? json['periode'] ?? '';

    return CultureItem(
      id: id,
      title: name,
      subtitle: subtitle,
      category: 'decouvrir',
      subCategory: 'personnages',
      description: desc,
      regionId: regId,
      regionName: regName,
      tag: tag,
      icon: iconFromName(null, subCategory: 'personnages'),
      imageUrl: photo,
      info: period,
    );
  }

  factory CultureItem.fromPlace(Map<String, dynamic> json) {
    final id = json['id'] ?? '';
    final name = json['name'] ?? json['nom'] ?? '';
    final subtitle = json['subtitle'] ?? json['sous_titre'] ?? '';
    final desc = json['resume'] ?? '';
    final regId = json['regionId'] ?? json['region_id'];
    final regName = json['regionName'] ?? json['region_nom'] ?? 'Mali';
    final tag = json['tag'] ?? 'Cité';
    final photo = json['photoUrl'] ?? json['photo_url'];
    final fondation = json['fondation'] ?? 'Cité Historique';

    return CultureItem(
      id: id,
      title: name,
      subtitle: subtitle,
      category: 'decouvrir',
      subCategory: 'villes',
      description: desc,
      regionId: regId,
      regionName: regName,
      tag: tag,
      icon: iconFromName(null, subCategory: 'villes'),
      imageUrl: photo,
      info: fondation,
    );
  }

  factory CultureItem.fromStory(Map<String, dynamic> json) {
    final id = json['id'] ?? '';
    final title = json['title'] ?? json['titre'] ?? '';
    final subtitle = json['subtitle'] ?? json['sous_titre'] ?? '';
    final desc = json['resume'] ?? '';
    final regId = json['regionId'] ?? json['region_id'];
    final regName = json['regionName'] ?? json['region_nom'] ?? 'Tout le Mali';
    final tag = json['tag'] ?? 'Conte Interactif';
    final photo = json['photoUrl'] ?? json['photo_url'];
    final reading = json['readingDuration'] ?? json['duree_lecture'] ?? 'Lecture : 5 min';

    return CultureItem(
      id: id,
      title: title,
      subtitle: subtitle,
      category: 'contes',
      subCategory: 'contes_interactifs',
      description: desc,
      regionId: regId,
      regionName: regName,
      tag: tag,
      icon: iconFromName(null, subCategory: 'contes_interactifs'),
      imageUrl: photo,
      info: reading,
    );
  }

  factory CultureItem.fromProverb(Map<String, dynamic> json) {
    final id = json['id'] ?? '';
    final text = json['text'] ?? json['texte'] ?? '';
    final theme = json['theme'] ?? 'Sagesse';
    final sign = json['signification'] ?? '';
    final regId = json['regionId'] ?? json['region_id'];
    final regName = json['regionName'] ?? json['region_nom'] ?? 'Tout le Mali';

    return CultureItem(
      id: id,
      title: text,
      subtitle: sign,
      category: 'defis',
      subCategory: 'devinettes',
      description: sign,
      regionId: regId,
      regionName: regName,
      tag: theme,
      icon: iconFromName(null, subCategory: 'devinettes'),
      imageUrl: null,
      info: 'Sagesse & Réflexion',
    );
  }

  factory CultureItem.fromJson(Map<String, dynamic> json) {
    return CultureItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      category: json['category'] ?? 'decouvrir',
      subCategory: json['subCategory'] ?? 'monuments',
      description: json['description'] ?? '',
      regionId: json['regionId'],
      regionName: json['regionName'] ?? 'Mali',
      tag: json['tag'] ?? '',
      icon: iconFromName(json['iconName'], subCategory: json['subCategory']),
      imageUrl: json['imageUrl'],
      isFeatured: json['isFeatured'] ?? false,
      info: json['info'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'category': category,
    'subCategory': subCategory,
    'description': description,
    'regionId': regionId,
    'regionName': regionName,
    'tag': tag,
    'iconName': iconToName(icon),
    'imageUrl': imageUrl,
    'isFeatured': isFeatured,
    'info': info,
  };
}
