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
}
