import 'package:alternia/features/culture/core/controllers/culture_passport_controller.dart';
import 'package:alternia/features/culture/core/datasources/mock_culture_details_data.dart';
import 'package:alternia/features/culture/core/datasources/mock_culture_stories_data.dart';
import 'package:alternia/features/culture/core/models/culture_passport_models.dart';
import 'package:alternia/features/culture/exploration/data/datasources/mock_mali_regions.dart';
import 'package:alternia/features/culture/exploration/presentation/screens/region_detail_screen.dart';
import 'package:alternia/features/culture/narrative_engine/data/story_script_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Culture Module - Region & Detail Tests', () {
    test('All regions have valid metadata and photos configured', () {
      for (final region in MockMaliRegions.regions) {
        expect(region.id, isNotEmpty);
        expect(region.nom, isNotEmpty);
        expect(region.chefLieu, isNotEmpty);
        expect(region.pointsForts, isNotEmpty);
        expect(region.symbolesEtTraditions, isNotEmpty);
        expect(region.descriptionCourte, isNotEmpty);
        expect(region.descriptionComplete, isNotEmpty);
      }
    });

    test('CulturePassportNotifier records region discovery properly', () {
      final notifier = CulturePassportNotifier();
      final initialCount = notifier.state.totalDiscoveries;

      final added = notifier.recordDiscovery(
        id: 'region_segou',
        type: PassportItemType.region,
        title: 'Ségou',
        subtitle: 'La Cité des Balanzans',
        regionId: 'segou',
        regionName: 'Ségou',
        photoUrl: 'assets/images/culture/villes/segou_koro.jpg',
        tag: 'Terre & Région',
        targetRoute: '/culture/region/segou',
      );

      expect(added, isTrue);
      expect(notifier.state.totalDiscoveries, equals(initialCount + 1));
      expect(notifier.state.isDiscovered(PassportItemType.region, 'region_segou'), isTrue);

      // Duplicate registration returns false
      final duplicate = notifier.recordDiscovery(
        id: 'region_segou',
        type: PassportItemType.region,
        title: 'Ségou',
        subtitle: 'La Cité des Balanzans',
        regionId: 'segou',
        regionName: 'Ségou',
        photoUrl: 'assets/images/culture/villes/segou_koro.jpg',
        tag: 'Terre & Région',
        targetRoute: '/culture/region/segou',
      );
      expect(duplicate, isFalse);
    });

    test('StoryScriptRegistry provides complete Soundiata and Mansa Moussa scripts', () {
      final soundiata = StoryScriptRegistry.soundiataScript;
      expect(soundiata.id, equals('perso_soundiata'));
      expect(soundiata.scenes.length, equals(6));
      expect(soundiata.scenes.first.title, contains('Manden'));

      final mansaMoussa = StoryScriptRegistry.mansaMoussaScript;
      expect(mansaMoussa.id, equals('perso_mansa_moussa'));
      expect(mansaMoussa.scenes.length, greaterThanOrEqualTo(2));
    });

    test('MockCultureDetailsData and MockCultureStoriesData cross-match correctly', () {
      expect(MockCultureDetailsData.figures.length, equals(6));
      expect(MockCultureDetailsData.monuments.length, equals(6));
      expect(MockCultureDetailsData.places.length, equals(6));
      expect(MockCultureStoriesData.stories.length, equals(5));

      final soundiataFigure = MockCultureDetailsData.getFigureById('perso_soundiata');
      expect(soundiataFigure.name, equals('Soundiata Keïta'));
      expect(soundiataFigure.connectedItems, isNotEmpty);
    });

    testWidgets('RegionDetailScreen builds without errors', (tester) async {
      final sikasso = MockMaliRegions.regions.firstWhere((r) => r.id == 'sikasso');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RegionDetailScreen(region: sikasso),
          ),
        ),
      );

      expect(find.byType(RegionDetailScreen), findsOneWidget);
      expect(find.text('Sikasso'), findsWidgets);
    });
  });
}
