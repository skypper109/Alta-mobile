import 'package:alternia/features/culture/core/controllers/culture_passport_controller.dart';
import 'package:alternia/features/culture/core/models/culture_passport_models.dart';
import 'package:alternia/features/culture/exploration/data/datasources/mock_mali_regions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Culture Module - Region & Passport Tests', () {
    test('MockMaliRegions supplies rich data for all 11 regions of Mali', () {
      for (final region in MockMaliRegions.regions) {
        expect(region.id, isNotEmpty);
        expect(region.nom, isNotEmpty);
        expect(region.chefLieu, isNotEmpty);
        expect(region.descriptionCourte, isNotEmpty);
        expect(region.pointsForts, isNotEmpty);
      }
    });

    test('CulturePassportNotifier records discovery correctly', () {
      final notifier = CulturePassportNotifier();
      final initialCount = notifier.state.entries.length;

      expect(initialCount, greaterThan(0));

      final recorded = notifier.recordDiscovery(
        id: 'perso_nouveau_test',
        type: PassportItemType.personnage,
        title: 'Nouvelle Figure Test',
        subtitle: 'Héros Test',
        regionId: 'koulikoro',
        regionName: 'Koulikoro',
        photoUrl: 'assets/images/culture/personnages/soundiata.jpg',
        tag: 'Épopée',
        culturalQuote: 'L\'homme qui conquit sa propre destinée',
        targetRoute: '/culture/personnage/perso_nouveau_test',
      );

      expect(recorded, isTrue);
      expect(notifier.state.entries.length, equals(initialCount + 1));

      // Duplication prevention: recording again returns false
      final recordedAgain = notifier.recordDiscovery(
        id: 'perso_nouveau_test',
        type: PassportItemType.personnage,
        title: 'Nouvelle Figure Test',
        subtitle: 'Héros Test',
        regionId: 'koulikoro',
        regionName: 'Koulikoro',
        photoUrl: 'assets/images/culture/personnages/soundiata.jpg',
        tag: 'Épopée',
        culturalQuote: 'L\'homme qui conquit sa propre destinée',
        targetRoute: '/culture/personnage/perso_nouveau_test',
      );

      expect(recordedAgain, isFalse);
      expect(notifier.state.entries.length, equals(initialCount + 1));
    });
  });
}
