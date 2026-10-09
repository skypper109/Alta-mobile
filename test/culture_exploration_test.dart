import 'package:alternia/features/culture/exploration/data/datasources/mock_mali_regions.dart';
import 'package:alternia/features/culture/exploration/data/models/mali_region.dart';
import 'package:alternia/features/culture/exploration/data/models/region_geo_path.dart';
import 'package:alternia/features/culture/core/controllers/culture_filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Culture Module - Étape 1 Tests', () {
    test('MockMaliRegions contains all 11 regions of Mali', () {
      final regions = MockMaliRegions.regions;

      expect(regions.length, equals(11));
      expect(
          regions.map((r) => r.id),
          containsAll([
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

    test('MaliGeoRegistry contains geometry for interactive map regions', () {
      expect(MaliGeoRegistry.all, isNotEmpty);
      for (final geo in MaliGeoRegistry.all) {
        final path = geo.toPath(const Size(1000, 1000));
        expect(path, isNotNull);
        expect(geo.points.length, greaterThanOrEqualTo(3));
      }
    });

    test('MaliRegion serialization and deserialization works correctly', () {
      final region =
          MockMaliRegions.regions.firstWhere((r) => r.id == 'sikasso');
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

      notifier.selectRegionById('tombouctou');
      expect(notifier.state.activeRegion?.id, equals('tombouctou'));
      expect(notifier.state.hasActiveFilter, isTrue);

      notifier.clearFilter();
      expect(notifier.state.activeRegion, isNull);
      expect(notifier.state.hasActiveFilter, isFalse);
    });
  });
}
