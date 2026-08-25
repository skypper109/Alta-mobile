import 'cultural_discovery.dart';
import 'heritage_item.dart';
import 'mali_region.dart';
import 'region_testimony.dart';
import 'regional_challenge.dart';

/// Agrégat complet des données d'immersion d'une région
class RegionDetailData {
  final MaliRegion region;
  final String accrocheEditoriale;
  final String heroImageUrl;
  final List<CulturalDiscovery> discoveries;
  final List<RegionTestimony> testimonies;
  final List<HeritageItem> heritages;
  final RegionalChallenge challenge;
  final List<String> neighborRegionIds;

  const RegionDetailData({
    required this.region,
    required this.accrocheEditoriale,
    required this.heroImageUrl,
    required this.discoveries,
    required this.testimonies,
    required this.heritages,
    required this.challenge,
    required this.neighborRegionIds,
  });
}
