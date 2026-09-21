import 'package:alternia/features/culture/exploration/data/datasources/mock_mali_regions.dart';
import 'package:alternia/features/culture/exploration/data/datasources/mock_region_detail_data.dart';
import 'package:alternia/features/culture/exploration/data/repositories/culture_repository.dart';
import 'package:alternia/features/culture/exploration/presentation/controllers/region_detail_controller.dart';
import 'package:alternia/features/culture/exploration/presentation/screens/region_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Culture Module - Étape 2 Tests (RegionDetail)', () {
    test('MockRegionDetailData supplies rich data for all 11 regions of Mali', () {
      for (final region in MockMaliRegions.regions) {
        final detail = MockRegionDetailData.getDetailForRegion(region);

        expect(detail.region.id, equals(region.id));
        expect(detail.accrocheEditoriale, isNotEmpty);
        expect(detail.discoveries, isNotEmpty);
        expect(detail.testimonies, isNotEmpty);
        expect(detail.heritages, isNotEmpty);
        expect(detail.challenge.titre, isNotEmpty);
        expect(detail.challenge.xpPoints, greaterThan(0));
        expect(detail.neighborRegionIds, isNotEmpty);
      }
    });

    test('CultureRepository.getRegionDetailData returns data properly', () async {
      const repository = MockCultureRepository();
      final detail = await repository.getRegionDetailData('segou');

      expect(detail, isNotNull);
      expect(detail!.region.nom, equals('Ségou'));
      expect(detail.discoveries.length, greaterThanOrEqualTo(2));
      expect(detail.testimonies.first.conteur, contains('Coulibaly'));
    });

    test('RegionDetailNotifier handles bookmark and audio toggle', () async {
      const repository = MockCultureRepository();
      final notifier = RegionDetailNotifier(repository, 'sikasso');

      await Future.delayed(const Duration(milliseconds: 250));

      expect(notifier.state.detailAsync.hasValue, isTrue);
      expect(notifier.state.isBookmarked, isFalse);

      // Bookmark toggle
      notifier.toggleBookmark();
      expect(notifier.state.isBookmarked, isTrue);
      notifier.toggleBookmark();
      expect(notifier.state.isBookmarked, isFalse);

      // Audio toggle
      notifier.toggleAudio('testimony_sikasso_1');
      expect(notifier.state.isAudioPlaying, isTrue);
      expect(notifier.state.currentlyPlayingTestimonyId, equals('testimony_sikasso_1'));

      // Pause audio
      notifier.toggleAudio('testimony_sikasso_1');
      expect(notifier.state.isAudioPlaying, isFalse);

      // Stop audio
      notifier.stopAudio();
      expect(notifier.state.currentlyPlayingTestimonyId, isNull);
    });

    testWidgets('RegionDetailScreen renders all editorial sections', (tester) async {
      tester.view.physicalSize = const Size(1080, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final region = MockMaliRegions.regions.firstWhere((r) => r.id == 'tombouctou');

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RegionDetailScreen(region: region),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Titre de la région
      expect(find.text('Tombouctou'), findsWidgets);

      // Surnom & Données géographiques
      expect(find.text(region.surnom), findsWidgets);
      expect(find.text('CHEF-LIEU'), findsOneWidget);
      expect(find.text('SUPERFICIE'), findsOneWidget);
      expect(find.text('POPULATION'), findsOneWidget);

      // Sections éditoriales
      expect(find.text('Histoire & Mémoire du Terroir'), findsOneWidget);
      expect(find.text('POINTS FORTS & TRADITIONS'), findsOneWidget);
    });
  });
}
