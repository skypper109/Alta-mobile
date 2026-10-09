import 'package:flutter_test/flutter_test.dart';
import 'package:alternia/features/culture/core/datasources/historical_figure_sagas_data.dart';

void main() {
  group('Historical Figure Sagas - Épopées Cinématiques & Motion Design', () {
    test('Contient l\'ensemble des 6 grands personnages historiques du Mali', () {
      expect(HistoricalFigureSagas.sagas.length, equals(6));

      final expectedKeys = [
        'perso_soundiata',
        'perso_mansa_moussa',
        'perso_askia_mohammed',
        'perso_babemba',
        'perso_biton_coulibaly',
        'perso_modibo_keita',
      ];

      for (final key in expectedKeys) {
        expect(HistoricalFigureSagas.sagas.containsKey(key), isTrue,
            reason: 'La saga $key doit être présente dans HistoricalFigureSagas.sagas');
      }
    });

    test('getSaga() résout convenablement les identifiants et variantes textuelles', () {
      expect(HistoricalFigureSagas.getSaga('perso_soundiata').figureName, equals('Soundiata Keïta'));
      expect(HistoricalFigureSagas.getSaga('mansa_moussa').figureName, equals('Mansa Moussa'));
      expect(HistoricalFigureSagas.getSaga('askia').figureName, equals('Askia Mohammed'));
      expect(HistoricalFigureSagas.getSaga('babemba').figureName, equals('Babemba Traoré'));
      expect(HistoricalFigureSagas.getSaga('biton').figureName, equals('Biton Coulibaly'));
      expect(HistoricalFigureSagas.getSaga('modibo').figureName, equals('Modibo Keïta'));
      expect(HistoricalFigureSagas.getSaga(null).figureName, equals('Soundiata Keïta'));
    });

    test('Chaque personnage dispose de chapitres narratifs authentiques avec images vérifiées', () {
      for (final entry in HistoricalFigureSagas.sagas.entries) {
        final saga = entry.value;
        expect(saga.chapters.isNotEmpty, isTrue,
            reason: '${saga.figureName} doit avoir au moins un chapitre');
        expect(saga.landmarkArticles.isNotEmpty, isTrue,
            reason: '${saga.figureName} doit avoir des articles ou manifestes historiques');

        for (final chapter in saga.chapters) {
          expect(chapter.title.trim().isNotEmpty, isTrue);
          expect(chapter.kicker.trim().isNotEmpty, isTrue);
          expect(chapter.dateAndPlace.trim().isNotEmpty, isTrue);
          expect(chapter.fullNarrative.trim().isNotEmpty, isTrue);
          expect(chapter.kineticQuotes.isNotEmpty, isTrue);
          expect(chapter.mainImage.trim().startsWith('assets/images/culture/'), isTrue,
              reason: 'L\'image ${chapter.mainImage} doit pointer vers assets/images/culture/');
        }
      }
    });
  });
}
