import 'package:alternia/features/culture/exploration/data/datasources/mock_mali_regions.dart';
import 'package:alternia/features/culture/exploration/data/models/mali_region.dart';
import 'package:alternia/features/culture/exploration/data/models/region_geo_path.dart';
import 'package:alternia/features/culture/exploration/data/repositories/culture_repository.dart';
import 'package:alternia/features/culture/exploration/presentation/controllers/culture_exploration_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Culture Module - Étape 1 Tests', () {
    test('MockCultureRepository returns 11 regions of Mali', () async {
      const repository = MockCultureRepository();
      final regions = await repository.getRegions();

      expect(regions.length, equals(11));
      expect(regions.map((r) => r.id), containsAll([
        'kayes',
        'koulikoro',
        'sikasso',
        'segou',
        'mopti',
        'tombouctou',
        'gao',
        'kidal',
        'taoudenit',
        'menaka',
        'bamako',
      ]));
    });

    test('MaliGeoRegistry contains geometry for all 11 regions', () {
      final geoRegionIds = MaliGeoRegistry.all.map((g) => g.regionId).toSet();
      final mockRegionIds = MockMaliRegions.regions.map((r) => r.id).toSet();

      expect(geoRegionIds, equals(mockRegionIds));
      for (final geo in MaliGeoRegistry.all) {
        final path = geo.toPath(const Size(1000, 1000));
        expect(path, isNotNull);
        expect(geo.points.length, greaterThanOrEqualTo(3));
      }
    });

    test('MaliRegion serialization and deserialization works correctly', () {
      final region = MockMaliRegions.regions.firstWhere((r) => r.id == 'sikasso');
      final json = region.toJson();

      expect(json['id'], equals('sikasso'));
      expect(json['nom'], equals('Sikasso'));
      expect(json['chef_lieu'], equals('Sikasso'));

      final fromJson = MaliRegion.fromJson(json);
      expect(fromJson.id, equals(region.id));
      expect(fromJson.nom, equals(region.nom));
      expect(fromJson.pointsForts, equals(region.pointsForts));
    });

    test('CultureExplorationNotifier handles region selection and toggle', () async {
      const repository = MockCultureRepository();
      final notifier = CultureExplorationNotifier(repository);

      // Wait for initial load
      await Future.delayed(const Duration(milliseconds: 300));
      expect(notifier.state.regions.length, equals(11));
      expect(notifier.state.selectedRegion, isNull);

      // Select 'tombouctou'
      notifier.selectRegion('tombouctou');
      expect(notifier.state.selectedRegion?.id, equals('tombouctou'));

      // Toggle selection (tapping the same unselects)
      notifier.selectRegion('tombouctou');
      expect(notifier.state.selectedRegion, isNull);

      // Select 'mopti'
      notifier.selectRegion('mopti');
      expect(notifier.state.selectedRegion?.id, equals('mopti'));

      // Clear selection
      notifier.clearSelection();
      expect(notifier.state.selectedRegion, isNull);
    });
  });
}
