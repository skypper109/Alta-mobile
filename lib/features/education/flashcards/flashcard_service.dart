// ─── AlterniA — Service Flashcards Leitner (Répétition Espacée) ─────────────
// Gestion locale, persistance SharedPreferences, calcul des intervalles
// et synchronisation Store & Forward avec attribution des points XP.
library;

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/sync_queue_service.dart';
import '../../profile/gamification_notifier.dart';
import 'flashcard_model.dart';

class FlashcardDeckState {
  final List<Flashcard> cards;
  final bool isLoading;

  const FlashcardDeckState({
    this.cards = const [],
    this.isLoading = false,
  });

  List<Flashcard> get dueTodayCards => cards.where((c) => c.isDueToday).toList();
  List<Flashcard> get masteredCards => cards.where((c) => c.box >= 4).toList();
  List<Flashcard> get learningCards => cards.where((c) => c.box < 4).toList();

  int get totalCount => cards.length;
  int get dueCount => dueTodayCards.length;
  int get masteredCount => masteredCards.length;

  List<String> get availableSubjects {
    final subs = cards.map((c) => c.subject).toSet().toList();
    subs.sort();
    return subs;
  }

  FlashcardDeckState copyWith({
    List<Flashcard>? cards,
    bool? isLoading,
  }) {
    return FlashcardDeckState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FlashcardServiceNotifier extends StateNotifier<FlashcardDeckState> {
  FlashcardServiceNotifier(this._ref) : super(const FlashcardDeckState(isLoading: true)) {
    _initDeck();
  }

  final Ref _ref;
  static const _storageKey = 'alternia_leitner_flashcards_deck';
  final _logger = Logger();

  Future<void> _initDeck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);

      List<Flashcard> loadedCards = [];
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        loadedCards = decoded
            .map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (loadedCards.isEmpty) {
        // Préchargement de la banque certifiée officielle du Mali
        loadedCards = FlashcardBank.getInitialCards();
        await _saveDeck(loadedCards);
      }

      state = FlashcardDeckState(cards: loadedCards, isLoading: false);
    } catch (e) {
      _logger.e('[FlashcardService] Erreur d\'initialisation du deck : $e');
      state = FlashcardDeckState(
        cards: FlashcardBank.getInitialCards(),
        isLoading: false,
      );
    }
  }

  Future<void> _saveDeck(List<Flashcard> deck) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(deck.map((c) => c.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      _logger.w('[FlashcardService] Erreur de sauvegarde du deck : $e');
    }
  }

  /// Traitement d'une réponse selon l'algorithme Leitner :
  /// - rating == 1 (À revoir) : Boîte 1, révision demain (J+1)
  /// - rating == 2 (Bien) : Boîte maintenue/avancée, révision à J+3
  /// - rating == 3 (Maîtrisé) : Boîte +1, révision à J+7
  Future<void> reviewCard(Flashcard card, int rating) async {
    final now = DateTime.now();
    int newBox;
    Duration interval;

    switch (rating) {
      case 3: // Maîtrisé
        newBox = (card.box + 1).clamp(1, 5);
        interval = Duration(days: newBox == 5 ? 30 : (newBox == 4 ? 14 : 7));
        break;
      case 2: // Bien compris
        newBox = card.box.clamp(1, 4);
        interval = const Duration(days: 3);
        break;
      case 1: // À revoir
      default:
        newBox = 1;
        interval = const Duration(days: 1);
        break;
    }

    final updatedCard = card.copyWith(
      box: newBox,
      lastReviewedDate: now,
      nextReviewDate: now.add(interval),
      repetitionCount: card.repetitionCount + 1,
    );

    final updatedList = state.cards.map((c) {
      return c.id == card.id ? updatedCard : c;
    }).toList();

    state = state.copyWith(cards: updatedList);
    await _saveDeck(updatedList);

    // 1. Récompense immédiate de l'élève en XP (+15 XP)
    _ref.read(gamificationProvider.notifier).addFlashcardReward(
          xpGained: 15,
          subject: card.subject,
        );

    // 2. Enregistrement dans la file d'attente Store & Forward
    _ref.read(syncQueueProvider.notifier).enqueue(
      SyncEventType.flashcardReviewed,
      {
        'card_id': card.id,
        'subject': card.subject,
        'concept': card.concept,
        'rating': rating,
        'new_box': newBox,
        'xp_gained': 15,
      },
    );

    _logger.i('[Flashcard] Carte ${card.id} révisée (Rating: $rating, Nouvelle boîte: $newBox)');
  }

  /// Ajoute de nouvelles cartes générées par l'IA ou issues d'un cours
  Future<void> addCards(List<Flashcard> newCards) async {
    final merged = [...state.cards];
    for (final nc in newCards) {
      if (!merged.any((existing) => existing.id == nc.id)) {
        merged.add(nc);
      }
    }
    state = state.copyWith(cards: merged);
    await _saveDeck(merged);
  }
}

final flashcardDeckProvider =
    StateNotifierProvider<FlashcardServiceNotifier, FlashcardDeckState>((ref) {
  return FlashcardServiceNotifier(ref);
});
