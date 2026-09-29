import 'package:alternia/features/culture/core/controllers/culture_filter_controller.dart';
import 'package:alternia/features/culture/exploration/data/datasources/mock_mali_regions.dart';
import 'package:alternia/features/culture/exploration/data/models/mali_region.dart';
import 'package:alternia/features/culture/exploration/data/models/region_geo_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Culture Module - Exploration Tests', () {
    test('MockMaliRegions returns 11 regions of Mali', () {
      final regions = MockMaliRegions.regions;

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

    test('MaliGeoRegistry contains geometry for all 8 historical regions of the interactive map', () {
      final geoRegionIds = MaliGeoRegistry.all.map((g) => g.regionId).toSet();

      expect(geoRegionIds.length, equals(8));
      expect(geoRegionIds, containsAll([
        'tombouctou',
        'kidal',
        'gao',
        'mopti',
        'segou',
        'kayes',
        'koulikoro',
        'sikasso',
      ]));
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

    test('CultureFilterNotifier handles region selection and toggle', () {
      final notifier = CultureFilterNotifier();

      expect(notifier.state.activeRegion, isNull);
      expect(notifier.state.hasActiveFilter, isFalse);
      expect(notifier.state.displayName, equals('Tout le Mali'));

      // Select 'tombouctou' by ID
      notifier.selectRegionById('tombouctou');
      expect(notifier.state.activeRegionId, equals('tombouctou'));
      expect(notifier.state.displayName, equals('Tombouctou'));
      expect(notifier.state.hasActiveFilter, isTrue);

      // Select region object
      final mopti = MockMaliRegions.regions.firstWhere((r) => r.id == 'mopti');
      notifier.selectRegion(mopti);
      expect(notifier.state.activeRegionId, equals('mopti'));

      // Toggle selection (tapping the same unselects)
      notifier.toggleRegion(mopti);
      expect(notifier.state.activeRegion, isNull);
      expect(notifier.state.hasActiveFilter, isFalse);

      // Clear filter
      notifier.selectRegionById('kayes');
      expect(notifier.state.activeRegionId, equals('kayes'));
      notifier.clearFilter();
      expect(notifier.state.activeRegion, isNull);
    });
  });
}
