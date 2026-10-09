// ─── AlterniA — Service Flashcards Leitner (Connecté IA Backend & Offline) ──
// Gestion hybride : génération de vraies cartes par l'IA AlternIA quand connecté,
// persistance locale SharedPreferences, algorithme Leitner et Store & Forward.
library;

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import '../../../core/services/sync_queue_service.dart';
import '../../profile/gamification_notifier.dart';
import '../../profile/user_prefs_notifier.dart';
import 'flashcard_model.dart';

class FlashcardDeckState {
  final List<Flashcard> cards;
  final bool isLoading;
  final bool isGeneratingAi;

  const FlashcardDeckState({
    this.cards = const [],
    this.isLoading = false,
    this.isGeneratingAi = false,
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
    bool? isGeneratingAi,
  }) {
    return FlashcardDeckState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      isGeneratingAi: isGeneratingAi ?? this.isGeneratingAi,
    );
  }
}

class FlashcardServiceNotifier extends StateNotifier<FlashcardDeckState> {
  FlashcardServiceNotifier(this._ref) : super(const FlashcardDeckState(isLoading: true)) {
    _initDeck();
    _ref.listen<UserProfileState>(userPrefsProvider, (previous, next) {
      if (previous?.studentClassId != next.studentClassId && next.studentClassId.isNotEmpty) {
        _logger.i('[FlashcardService] Changement de classe détecté (${previous?.studentClassId} -> ${next.studentClassId}), rechargement...');
        reloadForClass(next.studentClassId);
      }
    });
  }

  final Ref _ref;
  String _storageKeyFor(String level) =>
      'alternia_leitner_flashcards_deck_${level.toLowerCase().trim()}';
  final _logger = Logger();
  final _dio = Dio();

  Future<void> _initDeck() async {
    try {
      final userPrefs = _ref.read(userPrefsProvider);
      final currentLevel = userPrefs.studentClassId.isNotEmpty ? userPrefs.studentClassId : '12eme';

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKeyFor(currentLevel));

      List<Flashcard> loadedCards = [];
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        loadedCards = decoded
            .map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Si le deck est vide ou ne correspond pas au niveau actif, charger la banque certifiée
      if (loadedCards.isEmpty || !loadedCards.any((c) => c.classLevel.toLowerCase() == currentLevel.toLowerCase())) {
        loadedCards = FlashcardBank.getInitialCards(level: currentLevel);
        await _saveDeck(loadedCards, currentLevel);
      }

      state = FlashcardDeckState(cards: loadedCards, isLoading: false);

      // Tentative d'enrichissement par l'IA réelle si le serveur est accessible
      unawaited(fetchAiFlashcardsFromBackend());
    } catch (e) {
      _logger.e('[FlashcardService] Erreur d\'initialisation du deck : $e');
      final currentLevel = _ref.read(userPrefsProvider).studentClassId;
      state = FlashcardDeckState(
        cards: FlashcardBank.getInitialCards(level: currentLevel),
        isLoading: false,
      );
    }
  }

  /// Réinitialise et recharge le deck pour une nouvelle classe
  Future<void> reloadForClass(String classLevel) async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKeyFor(classLevel));
      List<Flashcard> loadedCards = [];
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as List<dynamic>;
        loadedCards = decoded
            .map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      if (loadedCards.isEmpty || !loadedCards.any((c) => c.classLevel.toLowerCase() == classLevel.toLowerCase())) {
        loadedCards = FlashcardBank.getInitialCards(level: classLevel);
        await _saveDeck(loadedCards, classLevel);
      }

      state = FlashcardDeckState(cards: loadedCards, isLoading: false);
      unawaited(fetchAiFlashcardsFromBackend());
    } catch (e) {
      final cards = FlashcardBank.getInitialCards(level: classLevel);
      state = FlashcardDeckState(cards: cards, isLoading: false);
      await _saveDeck(cards, classLevel);
    }
  }

  Future<void> _saveDeck(List<Flashcard> deck, [String? classLevel]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final level = classLevel ?? _ref.read(userPrefsProvider).studentClassId;
      final key = _storageKeyFor(level.isNotEmpty ? level : '12eme');
      final encoded = jsonEncode(deck.map((c) => c.toJson()).toList());
      await prefs.setString(key, encoded);
    } catch (e) {
      _logger.w('[FlashcardService] Erreur de sauvegarde du deck : $e');
    }
  }

  String? _cachedActiveBaseUrl;
  DateTime? _lastHealthCheckTime;

  /// Vérifie rapidement la connectivité avec le serveur AlternIA
  Future<String?> _getActiveBaseUrlFast() async {
    final now = DateTime.now();
    if (_lastHealthCheckTime != null &&
        _cachedActiveBaseUrl != null &&
        now.difference(_lastHealthCheckTime!) < const Duration(seconds: 15)) {
      return _cachedActiveBaseUrl;
    }

    for (final baseUrl in AltaApiConfig.candidateBaseUrls) {
      try {
        final res = await _dio.get(
          '$baseUrl/api/health',
          options: Options(
            connectTimeout: const Duration(milliseconds: 2500),
            receiveTimeout: const Duration(milliseconds: 2500),
          ),
        );
        if (res.statusCode == 200 && res.data is Map && res.data['status'] == 'healthy') {
          _cachedActiveBaseUrl = baseUrl;
          _lastHealthCheckTime = now;
          return baseUrl;
        }
      } catch (_) {}
    }

    _lastHealthCheckTime = now;
    _cachedActiveBaseUrl = null;
    return null;
  }

  /// Appelle l'API IA backend pour générer de vraies cartes pédagogiques inédites
  Future<bool> fetchAiFlashcardsFromBackend({
    String? subject,
    String? topic,
    int count = 5,
  }) async {
    final userPrefs = _ref.read(userPrefsProvider);
    final targetSubject = subject ?? (userPrefs.subjects.isNotEmpty ? userPrefs.subjects.first : 'Mathématiques');
    final classLevel = userPrefs.studentClassId.isNotEmpty ? userPrefs.studentClassId : '12eme';

    state = state.copyWith(isGeneratingAi: true);

    try {
      final activeUrl = await _getActiveBaseUrlFast();
      final urlsToTry = activeUrl != null
          ? [activeUrl, ...AltaApiConfig.candidateBaseUrls.where((u) => u != activeUrl)]
          : AltaApiConfig.candidateBaseUrls;

      for (final baseUrl in urlsToTry) {
        try {
          _logger.i('[FlashcardService] Requête génération IA réelle → $baseUrl/api/education/flashcards/generate');
          final response = await _dio.post(
            '$baseUrl/api/education/flashcards/generate',
            data: {
              'subject': targetSubject,
              'class_level': classLevel,
              'topic': topic,
              'count': count,
            },
            options: Options(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 35),
            ),
          );

          if (response.statusCode == 200 && response.data is List) {
            final list = (response.data as List)
                .map((it) => Flashcard.fromJson(it as Map<String, dynamic>))
                .toList();

            if (list.isNotEmpty) {
              await addCards(list);
              _logger.i('[FlashcardService] ${list.length} vraies cartes IA ajoutées au deck !');
              return true;
            }
          }
        } catch (e) {
          _logger.d('[FlashcardService] Échec sur $baseUrl : $e');
        }
      }
    } finally {
      state = state.copyWith(isGeneratingAi: false);
    }
    return false;
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
