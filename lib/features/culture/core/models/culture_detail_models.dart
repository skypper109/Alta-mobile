import 'package:flutter/material.dart';

/// Type de contenu associé pour le maillage transversal
enum ConnectedItemType {
  personnage,
  monument,
  ville,
  region,
}

/// Référence vers un contenu culturel lié (maillage transversal)
class ConnectedItemRef {
  final String id;
  final String title;
  final String subtitle;
  final ConnectedItemType type;
  final String? imageUrl;
  final String tag;
  final String? regionName;
  final IconData icon;

  const ConnectedItemRef({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.imageUrl,
    required this.tag,
    this.regionName,
    this.icon = Icons.explore_rounded,
  });

  static ConnectedItemType _typeFromString(String? typeStr) {
    switch (typeStr) {
      case 'monument':
        return ConnectedItemType.monument;
      case 'ville':
        return ConnectedItemType.ville;
      case 'region':
        return ConnectedItemType.region;
      case 'personnage':
      default:
        return ConnectedItemType.personnage;
    }
  }

  factory ConnectedItemRef.fromJson(Map<String, dynamic> json) {
    return ConnectedItemRef(
      id: json['id'] ?? '',
      title: json['title'] ?? json['nom'] ?? '',
      subtitle: json['subtitle'] ?? json['sous_titre'] ?? '',
      type: _typeFromString(json['type']),
      imageUrl: json['imageUrl'] ?? json['photoUrl'] ?? json['photo_url'],
      tag: json['tag'] ?? 'Patrimoine',
      regionName: json['regionName'] ?? json['region_nom'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'type': type.name,
    'imageUrl': imageUrl,
    'tag': tag,
    'regionName': regionName,
  };

  String get routePath {
    switch (type) {
      case ConnectedItemType.personnage:
        return '/culture/personnage/$id';
      case ConnectedItemType.monument:
        return '/culture/monument/$id';
      case ConnectedItemType.ville:
        return '/culture/ville/$id';
      case ConnectedItemType.region:
        return '/culture/region/$id';
    }
  }
}

/// Fait marquant / repère historique
class HistoricalKeyFact {
  final String label;
  final String value;
  final IconData icon;

  const HistoricalKeyFact({
    required this.label,
    required this.value,
    this.icon = Icons.bookmark_border_rounded,
  });

  factory HistoricalKeyFact.fromJson(Map<String, dynamic> json) {
    return HistoricalKeyFact(
      label: json['label'] ?? '',
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'value': value,
  };
}

/// Section de récit éditorial
class EditorialStoryChapter {
  final String title;
  final String content;
  final String? quote;
  final String? quoteAuthor;

  const EditorialStoryChapter({
    required this.title,
    required this.content,
    this.quote,
    this.quoteAuthor,
  });

  factory EditorialStoryChapter.fromJson(Map<String, dynamic> json) {
    return EditorialStoryChapter(
      title: json['title'] ?? json['titre'] ?? '',
      content: json['content'] ?? json['contenu'] ?? '',
      quote: json['quote'] ?? json['citation'],
      quoteAuthor: json['quoteAuthor'] ?? json['auteur'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'quote': quote,
    'quoteAuthor': quoteAuthor,
  };
}

/// Fiche détaillée complète d'un Grand Personnage Historique
class HistoricalFigureDetail {
  final String id;
  final String name;
  final String titleHonorifique;
  final String period; // ex: '1190 – 1255'
  final String regionId;
  final String regionName;
  final String tag; // ex: 'Mansa du Mali'
  final String photoUrl;
  final String photoCredits;
  final String resume;
  final String? citationHistorique;
  final List<HistoricalKeyFact> keyFacts;
  final List<EditorialStoryChapter> chapters;
  final List<ConnectedItemRef> connectedItems;

  const HistoricalFigureDetail({
    required this.id,
    required this.name,
    required this.titleHonorifique,
    required this.period,
    required this.regionId,
    required this.regionName,
    required this.tag,
    required this.photoUrl,
    required this.photoCredits,
    required this.resume,
    this.citationHistorique,
    required this.keyFacts,
    required this.chapters,
    required this.connectedItems,
  });

  factory HistoricalFigureDetail.fromJson(Map<String, dynamic> json) {
    List<HistoricalKeyFact> facts = [];
    if (json['keyFacts'] is List) {
      facts = (json['keyFacts'] as List)
          .whereType<Map<String, dynamic>>()
          .map((f) => HistoricalKeyFact.fromJson(f))
          .toList();
    }

    List<EditorialStoryChapter> chaps = [];
    if (json['chapters'] is List) {
      chaps = (json['chapters'] as List)
          .whereType<Map<String, dynamic>>()
          .map((c) => EditorialStoryChapter.fromJson(c))
          .toList();
    }

    List<ConnectedItemRef> connected = [];
    if (json['connectedItems'] is List) {
      connected = (json['connectedItems'] as List)
          .whereType<Map<String, dynamic>>()
          .map((c) => ConnectedItemRef.fromJson(c))
          .toList();
    }

    return HistoricalFigureDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? json['nom'] ?? '',
      titleHonorifique: json['titleHonorifique'] ?? json['titre_honorifique'] ?? '',
      period: json['period'] ?? json['periode'] ?? '',
      regionId: json['regionId'] ?? json['region_id'] ?? 'mali',
      regionName: json['regionName'] ?? json['region_nom'] ?? 'Mali',
      tag: json['tag'] ?? 'Mansa',
      photoUrl: json['photoUrl'] ?? json['photo_url'] ?? '',
      photoCredits: json['photoCredits'] ?? json['photo_credits'] ?? 'Archives Nationales',
      resume: json['resume'] ?? '',
      citationHistorique: json['citationHistorique'] ?? json['citation_historique'],
      keyFacts: facts,
      chapters: chaps,
      connectedItems: connected,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'titleHonorifique': titleHonorifique,
    'period': period,
    'regionId': regionId,
    'regionName': regionName,
    'tag': tag,
    'photoUrl': photoUrl,
    'photoCredits': photoCredits,
    'resume': resume,
    'citationHistorique': citationHistorique,
    'keyFacts': keyFacts.map((k) => k.toJson()).toList(),
    'chapters': chapters.map((c) => c.toJson()).toList(),
    'connectedItems': connectedItems.map((c) => c.toJson()).toList(),
  };
}

/// Fiche détaillée complète d'un Monument Historique
class MonumentDetail {
  final String id;
  final String name;
  final String subtitle;
  final String era; // ex: 'Érigé en 1907 (fondations du XIIIe s.)'
  final String regionId;
  final String regionName;
  final String tag; // ex: 'Patrimoine Mondial UNESCO'
  final String photoUrl;
  final String photoCredits;
  final String locationDetails; // ex: 'Bord du fleuve Bani, Djenné'
  final String presentation;
  final String architectureAndMaterials;
  final String whyItMatters;
  final List<HistoricalKeyFact> keyFacts;
  final List<EditorialStoryChapter> chapters;
  final List<ConnectedItemRef> connectedItems;

  const MonumentDetail({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.era,
    required this.regionId,
    required this.regionName,
    required this.tag,
    required this.photoUrl,
    required this.photoCredits,
    required this.locationDetails,
    required this.presentation,
    required this.architectureAndMaterials,
    required this.whyItMatters,
    required this.keyFacts,
    required this.chapters,
    required this.connectedItems,
  });

  factory MonumentDetail.fromJson(Map<String, dynamic> json) {
    List<HistoricalKeyFact> facts = [];
    if (json['keyFacts'] is List) {
      facts = (json['keyFacts'] as List)
          .whereType<Map<String, dynamic>>()
          .map((f) => HistoricalKeyFact.fromJson(f))
          .toList();
    }

    List<EditorialStoryChapter> chaps = [];
    if (json['chapters'] is List) {
      chaps = (json['chapters'] as List)
          .whereType<Map<String, dynamic>>()
          .map((c) => EditorialStoryChapter.fromJson(c))
          .toList();
    }

    List<ConnectedItemRef> connected = [];
    if (json['connectedItems'] is List) {
      connected = (json['connectedItems'] as List)
          .whereType<Map<String, dynamic>>()
          .map((c) => ConnectedItemRef.fromJson(c))
          .toList();
    }

    return MonumentDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? json['nom'] ?? '',
      subtitle: json['subtitle'] ?? json['sous_titre'] ?? '',
      era: json['era'] ?? json['epoque'] ?? '',
      regionId: json['regionId'] ?? json['region_id'] ?? 'bamako',
      regionName: json['regionName'] ?? json['region_nom'] ?? 'Mali',
      tag: json['tag'] ?? 'Monument National',
      photoUrl: json['photoUrl'] ?? json['photo_url'] ?? '',
      photoCredits: json['photoCredits'] ?? json['photo_credits'] ?? 'Direction Nationale du Patrimoine',
      locationDetails: json['locationDetails'] ?? json['details_localisation'] ?? '',
      presentation: json['presentation'] ?? json['recit_historique'] ?? '',
      architectureAndMaterials: json['architectureAndMaterials'] ?? json['style_architectural'] ?? '',
      whyItMatters: json['whyItMatters'] ?? json['pourquoi_ce_lieu_compte'] ?? '',
      keyFacts: facts,
      chapters: chaps,
      connectedItems: connected,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subtitle': subtitle,
    'era': era,
    'regionId': regionId,
    'regionName': regionName,
    'tag': tag,
    'photoUrl': photoUrl,
    'photoCredits': photoCredits,
    'locationDetails': locationDetails,
    'presentation': presentation,
    'architectureAndMaterials': architectureAndMaterials,
    'whyItMatters': whyItMatters,
    'keyFacts': keyFacts.map((k) => k.toJson()).toList(),
    'chapters': chapters.map((c) => c.toJson()).toList(),
    'connectedItems': connectedItems.map((c) => c.toJson()).toList(),
  };
}

/// Fiche détaillée complète d'une Ville ou Village
class PlaceDetail {
  final String id;
  final String name;
  final String subtitle;
  final String regionId;
  final String regionName;
  final String tag; // ex: 'Cité Millénaire'
  final String photoUrl;
  final String photoCredits;
  final String fondation; // ex: 'Fondée au IXe siècle'
  final String resume;
  final String identiteCulturelle;
  final String traditionsAndPatrimoine;
  final List<HistoricalKeyFact> keyFacts;
  final List<EditorialStoryChapter> chapters;
  final List<ConnectedItemRef> connectedItems;

  const PlaceDetail({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.regionId,
    required this.regionName,
    required this.tag,
    required this.photoUrl,
    required this.photoCredits,
    required this.fondation,
    required this.resume,
    required this.identiteCulturelle,
    required this.traditionsAndPatrimoine,
    required this.keyFacts,
    required this.chapters,
    required this.connectedItems,
  });

  factory PlaceDetail.fromJson(Map<String, dynamic> json) {
    List<HistoricalKeyFact> facts = [];
    if (json['keyFacts'] is List) {
      facts = (json['keyFacts'] as List)
          .whereType<Map<String, dynamic>>()
          .map((f) => HistoricalKeyFact.fromJson(f))
          .toList();
    }

    List<EditorialStoryChapter> chaps = [];
    if (json['chapters'] is List) {
      chaps = (json['chapters'] as List)
          .whereType<Map<String, dynamic>>()
          .map((c) => EditorialStoryChapter.fromJson(c))
          .toList();
    }

    List<ConnectedItemRef> connected = [];
    if (json['connectedItems'] is List) {
      connected = (json['connectedItems'] as List)
          .whereType<Map<String, dynamic>>()
          .map((c) => ConnectedItemRef.fromJson(c))
          .toList();
    }

    return PlaceDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? json['nom'] ?? '',
      subtitle: json['subtitle'] ?? json['sous_titre'] ?? '',
      regionId: json['regionId'] ?? json['region_id'] ?? 'mopti',
      regionName: json['regionName'] ?? json['region_nom'] ?? 'Mali',
      tag: json['tag'] ?? 'Cité Historique',
      photoUrl: json['photoUrl'] ?? json['photo_url'] ?? '',
      photoCredits: json['photoCredits'] ?? json['photo_credits'] ?? 'Archives du Patrimoine',
      fondation: json['fondation'] ?? '',
      resume: json['resume'] ?? '',
      identiteCulturelle: json['identiteCulturelle'] ?? json['resume'] ?? '',
      traditionsAndPatrimoine: json['traditionsAndPatrimoine'] ?? '',
      keyFacts: facts,
      chapters: chaps,
      connectedItems: connected,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subtitle': subtitle,
    'regionId': regionId,
    'regionName': regionName,
    'tag': tag,
    'photoUrl': photoUrl,
    'photoCredits': photoCredits,
    'fondation': fondation,
    'resume': resume,
    'identiteCulturelle': identiteCulturelle,
    'traditionsAndPatrimoine': traditionsAndPatrimoine,
    'keyFacts': keyFacts.map((k) => k.toJson()).toList(),
    'chapters': chapters.map((c) => c.toJson()).toList(),
    'connectedItems': connectedItems.map((c) => c.toJson()).toList(),
  };
}
