import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../datasources/mock_mali_regions.dart';
import '../datasources/mock_region_detail_data.dart';
import '../models/mali_region.dart';
import '../models/region_detail_data.dart';

/// Interface du Repository Culture (compatible pour le futur backend FastAPI)
abstract class CultureRepository {
  Future<List<MaliRegion>> getRegions();
  Future<MaliRegion?> getRegionById(String id);
  Future<RegionDetailData?> getRegionDetailData(String regionId);
}

/// Implémentation locale / mock du Repository
class MockCultureRepository implements CultureRepository {
  const MockCultureRepository();

  @override
  Future<List<MaliRegion>> getRegions() async {
    // Simule une micro-latence réseau réaliste
    await Future.delayed(const Duration(milliseconds: 250));
    return MockMaliRegions.regions;
  }

  @override
  Future<MaliRegion?> getRegionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return MockMaliRegions.regions.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<RegionDetailData?> getRegionDetailData(String regionId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    try {
      final region = MockMaliRegions.regions.firstWhere((r) => r.id == regionId);
      return MockRegionDetailData.getDetailForRegion(region);
    } catch (_) {
      return null;
    }
  }
}

/// Provider Riverpod pour le Repository Culture
final cultureRepositoryProvider = Provider<CultureRepository>((ref) {
  return const MockCultureRepository();
});
