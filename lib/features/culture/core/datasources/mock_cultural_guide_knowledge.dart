import 'package:flutter/material.dart';
import '../models/cultural_guide_models.dart';

/// Base de connaissances et moteur de dialogue contextuel du Guide Culturel IA
abstract final class MockCulturalGuideKnowledge {
  /// Génère les suggestions automatiques adaptées au contexte
  static List<GuideSuggestion> getSuggestionsForContext(CulturalGuideContext context) {
    switch (context.contentType) {
      case CulturalContentType.monument:
        return [
          GuideSuggestion(
            id: 'monument_importance',
            questionText: 'Pourquoi ce monument est-il si emblématique ?',
            icon: Icons.star_rounded,
          ),
          GuideSuggestion(
            id: 'monument_history',
            questionText: 'Qui l\'a construit et à quelle époque ?',
            icon: Icons.history_edu_rounded,
          ),
          GuideSuggestion(
            id: 'monument_secrets',
            questionText: 'Quels secrets d\'architecture cache ce lieu ?',
            icon: Icons.architecture_rounded,
          ),
          GuideSuggestion(
            id: 'monument_connected',
            questionText: 'Quels personnages historiques y sont liés ?',
            icon: Icons.people_outline_rounded,
          ),
        ];

      case CulturalContentType.personnage:
        return [
          GuideSuggestion(
            id: 'perso_exploits',
            questionText: 'Quels sont ses plus grands accomplissements ?',
            icon: Icons.military_tech_rounded,
          ),
          GuideSuggestion(
            id: 'perso_legacy',
            questionText: 'Quel est son héritage dans le Mali d\'aujourd\'hui ?',
            icon: Icons.auto_awesome_rounded,
          ),
          GuideSuggestion(
            id: 'perso_charte',
            questionText: 'Quel était son serment ou sa maxime de vie ?',
            icon: Icons.gavel_rounded,
          ),
          GuideSuggestion(
            id: 'perso_monuments',
            questionText: 'Quels monuments ou cités portent son empreinte ?',
            icon: Icons.account_balance_rounded,
          ),
        ];

      case CulturalContentType.ville:
        return [
          GuideSuggestion(
            id: 'ville_secrets',
            questionText: 'Que rend cette cité unique au Mali ?',
            icon: Icons.location_city_rounded,
          ),
          GuideSuggestion(
            id: 'ville_traditions',
            questionText: 'Quelles sont les traditions vivantes de cette ville ?',
            icon: Icons.festival_rounded,
          ),
          GuideSuggestion(
            id: 'ville_contes',
            questionText: 'Quels récits ou contes sont nés dans ce terroir ?',
            icon: Icons.auto_stories_rounded,
          ),
        ];

      case CulturalContentType.conte:
        return [
          GuideSuggestion(
            id: 'conte_moral',
            questionText: 'Quelle est la leçon de sagesse profonde de ce conte ?',
            icon: Icons.psychology_rounded,
          ),
          GuideSuggestion(
            id: 'conte_origin',
            questionText: 'D\'où provient cette légende et qui la transmet ?',
            icon: Icons.record_voice_over_rounded,
          ),
          GuideSuggestion(
            id: 'conte_variants',
            questionText: 'Existe-t-il d\'autres fables similaires dans le Sahel ?',
            icon: Icons.library_books_rounded,
          ),
        ];

      case CulturalContentType.defi:
        return [
          GuideSuggestion(
            id: 'defi_explanation',
            questionText: 'Explique-moi la symbolique de cette devinette.',
            icon: Icons.lightbulb_rounded,
          ),
          GuideSuggestion(
            id: 'defi_nda_origin',
            questionText: 'Pourquoi dit-on « N\'Da ! » avant une devinette ?',
            icon: Icons.chat_bubble_outline_rounded,
          ),
          GuideSuggestion(
            id: 'defi_proverbe',
            questionText: 'Quel proverbe des anciens complète cette énigme ?',
            icon: Icons.format_quote_rounded,
          ),
        ];

      case CulturalContentType.region:
        return [
          GuideSuggestion(
            id: 'region_must_see',
            questionText: 'Que dois-je absolument découvrir dans cette région ?',
            icon: Icons.explore_rounded,
          ),
          GuideSuggestion(
            id: 'region_heroes',
            questionText: 'Quels grands personnages sont nés sur ce terroir ?',
            icon: Icons.person_pin_rounded,
          ),
          GuideSuggestion(
            id: 'region_contes',
            questionText: 'Quels contes et veillées sont typiques d\'ici ?',
            icon: Icons.auto_stories_rounded,
          ),
          GuideSuggestion(
            id: 'region_defi',
            questionText: 'Quel défi culturel me recommandez-vous ici ?',
            icon: Icons.quiz_rounded,
          ),
        ];

      case CulturalContentType.general:
        return [
          GuideSuggestion(
            id: 'gen_reco',
            questionText: 'Que me recommandez-vous d\'explorer aujourd\'hui ?',
            icon: Icons.recommend_rounded,
          ),
          GuideSuggestion(
            id: 'gen_empires',
            questionText: 'Raconte-moi l\'épopée des 3 grands Empires du Mali.',
            icon: Icons.castle_rounded,
          ),
          GuideSuggestion(
            id: 'gen_charte',
            questionText: 'Qu\'est-ce que la Charte de Kouroukan Fouga (1236) ?',
            icon: Icons.menu_book_rounded,
          ),
          GuideSuggestion(
            id: 'gen_griot',
            questionText: 'Quel est le rôle sacré des Griots (Djélis) ?',
            icon: Icons.music_note_rounded,
          ),
        ];
    }
  }

  /// Message d'accueil personnalisé du Guide IA selon le contexte
  static GuideMessage getWelcomeMessage(CulturalGuideContext context) {
    String welcomeText;
    switch (context.contentType) {
      case CulturalContentType.monument:
        welcomeText =
            'I ni ce ! Je suis votre guide pour le monument « ${context.contentTitle} » (${context.regionName}). '
            'Posez-moi vos questions sur son architecture en terre, son histoire séculaire ou les événements qui s\'y sont déroulés.';
        break;

      case CulturalContentType.personnage:
        welcomeText =
            'I ni ce ! Parlons de « ${context.contentTitle} », figure majeure du patrimoine de ${context.regionName}. '
            'Je peux vous éclairer sur ses batailles, sa gouvernance ou son serment de justice.';
        break;

      case CulturalContentType.ville:
        welcomeText =
            'Bienvenue à « ${context.contentTitle} ». '
            'Cette cité regorge de légendes fluviales, de savoirs ancestraux et d\'édifices historiques. Que souhaitez-vous percer comme mystère ?';
        break;

      case CulturalContentType.conte:
        welcomeText =
            'I ni sogoma ! Ce conte « ${context.contentTitle} » porte en lui la sagesse orale des veillées. '
            'Je peux vous expliquer la morale cachée, les métaphores des animaux ou son origine mandingue.';
        break;

      case CulturalContentType.defi:
        welcomeText =
            '« N\'Da ! » Les devinettes et énigmes traditionnelles sont l\'école de la vivacité d\'esprit au Mali. '
            'Que voulez-vous savoir sur les symboles et maximes de ce défi ?';
        break;

      case CulturalContentType.region:
        welcomeText =
            'Vous explorez le terroir de « ${context.contentTitle} » (${context.subtitle ?? 'Mali'}). '
            'Je peux vous guider vers ses monuments classés, ses héros fondateurs et ses contes au bord de l\'eau.';
        break;

      case CulturalContentType.general:
        welcomeText =
            'I ni ce ! Je suis votre Guide Culturel Alternia. '
            'Je vous accompagne à travers l\'histoire, les monuments, les souverains, les contes et les mystères du Mali. Que souhaitez-vous découvrir ?';
        break;
    }

    return GuideMessage(
      id: 'msg_welcome',
      text: welcomeText,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  /// Fournit une réponse contextualisée et experte
  static GuideMessage answerQuestion({
    required String question,
    required CulturalGuideContext context,
  }) {
    final q = question.toLowerCase();

    // ── MONUMENTS ───────────────────────────────────────────────────────────
    if (context.contentType == CulturalContentType.monument) {
      if (q.contains('pourquoi') || q.contains('emblématique') || q.contains('célèbre')) {
        return GuideMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              '« ${context.contentTitle} » est un chef-d\'œuvre du génie architectural malien. '
              'Construit selon la tradition séculaire du banco (terre crue mêlée de paille et de balle de riz), '
              'ce monument régule naturellement la température et témoigne de la symbiose parfaite entre l\'homme et son environnement. '
              'Chaque année, sa rénovation rassemble toute la communauté lors d\'une grande fête populaire.',
          isUser: false,
          timestamp: DateTime.now(),
          action: const GuideConnectedAction(
            label: 'Consulter la fiche détaillée',
            targetRoute: '/culture/monuments',
          ),
        );
      } else if (q.contains('qui') || q.contains('époque') || q.contains('histoire')) {
        return GuideMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'Ce monument prend racine aux grandes heures des royaumes sahéliens. '
              'Bâti sous l\'impulsion des bâtisseurs traditionnels et des maîtres maçons (les Barey), '
              'il a résisté aux intempéries et aux siècles grâce au savoir-faire transmis de père en fils.',
          isUser: false,
          timestamp: DateTime.now(),
        );
      }
    }

    // ── PERSONNAGES ─────────────────────────────────────────────────────────
    if (context.contentType == CulturalContentType.personnage) {
      if (q.contains('accomplissement') || q.contains('exploits') || q.contains('qui')) {
        return GuideMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              '« ${context.contentTitle} » a profondément marqué l\'histoire de l\'Afrique de l\'Ouest. '
              'Stratège visionnaire, il a su unifier les provinces rivales, instaurer la concorde civile par la Charte de 1236 et protéger les routes commerciales du Djoliba. '
              'Les griots Geseru et Kouyaté continuent de chanter ses louanges.',
          isUser: false,
          timestamp: DateTime.now(),
          action: const GuideConnectedAction(
            label: 'Découvrir le conte de Soundiata',
            targetRoute: '/culture/conte/conte_lievre_hyene',
          ),
        );
      }
    }

    // ── RÉGIONS ─────────────────────────────────────────────────────────────
    if (context.contentType == CulturalContentType.region) {
      if (q.contains('découvrir') || q.contains('must') || q.contains('ici')) {
        return GuideMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'La région de ${context.contentTitle} est réputée pour ses trésors vivants ! '
              'Je vous conseille de débuter par son monument historique emblématique, puis d\'écouter le conte traditionnel lié aux veillées locales.',
          isUser: false,
          timestamp: DateTime.now(),
          action: GuideConnectedAction(
            label: 'Voir la carte du Mali',
            targetRoute: '/culture/map',
          ),
        );
      }
    }

    // ── CONTES ──────────────────────────────────────────────────────────────
    if (context.contentType == CulturalContentType.conte) {
      if (q.contains('morale') || q.contains('sagesse') || q.contains('message')) {
        return GuideMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'Dans ce conte, la morale nous enseigne que la ruse réfléchie et le respect des lois coutumières '
              'l\'emportent toujours sur la brutalité et la cupidité. '
              'Chez les Mandingues, les animaux symbolisent les travers et les vertus des hommes.',
          isUser: false,
          timestamp: DateTime.now(),
        );
      }
    }

    // ── DÉFIS ───────────────────────────────────────────────────────────────
    if (context.contentType == CulturalContentType.defi) {
      if (q.contains("n'da") || q.contains('pourquoi') || q.contains('formule')) {
        return GuideMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text:
              'La formule rituelle « N\'Da ! » (qui signifie littéralement « J\'ai posé mon énigme ») appelle la réponse de l\'assemblée : « N\'Da n\'sira ! » (« Que ta parole trouve son chemin ! »). '
              'C\'est le signal d\'ouverture de la joute intellectuelle entre les jeunes et les aînés.',
          isUser: false,
          timestamp: DateTime.now(),
        );
      }
    }

    // ── RÉPONSE UNIVERSELLE AVEC MAILLAGE PATRIMONIAL ───────────────────────
    return GuideMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          'Excellente question sur « ${context.contentTitle} » ! '
          'Dans la tradition culturelle du Mali, cet élément est intimement lié à l\'histoire de ${context.regionName}, '
          'où l\'harmonie entre les peuples, les fleuves et les bâtisseurs de mémoire constitue le socle de l\'identité nationale.',
      isUser: false,
      timestamp: DateTime.now(),
      action: const GuideConnectedAction(
        label: 'Tester un défi culturel',
        targetRoute: '/culture/defis',
      ),
    );
  }
}
