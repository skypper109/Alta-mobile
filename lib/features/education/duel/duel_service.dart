// ─── AlterniA — Service Arène de Duel Scolaire ─────────────────────────────
// Gestion des questions réelles générées par l'IA, des salons avec code PIN,
// du matchmaking instantané Mali et des scores en direct.
library;

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../core/constants.dart';
import 'duel_model.dart';

class DuelService {
  DuelService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final _logger = Logger();

  String? _cachedActiveBaseUrl;
  DateTime? _lastHealthCheckTime;

  /// Vérifie rapidement la connectivité avec le serveur AlternIA
  Future<String?> getActiveBaseUrlFast() async {
    final now = DateTime.now();
    if (_lastHealthCheckTime != null &&
        _cachedActiveBaseUrl != null &&
        now.difference(_lastHealthCheckTime!) < const Duration(seconds: 10)) {
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

  /// Récupère des questions de duel réelles :
  /// - Si connecté : Générées en direct par l'IA AlternIA (ZÉRO MOCK)
  /// - Si hors-ligne : Issue de la banque certifiée locale
  Future<List<DuelQuestion>> fetchQuestions({
    required String subject,
    required String classLevel,
    int count = 5,
  }) async {
    final activeUrl = await getActiveBaseUrlFast();

    if (activeUrl != null) {
      try {
        _logger.i('[DuelService] Requête questions IA en direct ($count questions) → $activeUrl/api/duel/generate');
        final response = await _dio.post(
          '$activeUrl/api/duel/generate',
          data: {
            'subject': subject,
            'class_level': classLevel,
            'count': count,
          },
          options: Options(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 35),
          ),
        );

        if (response.statusCode == 200 && response.data is List) {
          final list = (response.data as List)
              .map((item) => DuelQuestion.fromJson(item as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) {
            return list;
          }
        }
      } catch (e) {
        _logger.w('[DuelService] Erreur lors de la génération IA, bascule sur la banque certifiée : $e');
      }
    } else {
      _logger.d('[DuelService] Hors-ligne : utilisation de la banque locale sécurisée.');
    }

    // Hors-ligne ou échec réseau : banque officielle
    final localQuestions = DuelBank.getQuestionsForSubject(
      subject,
      level: classLevel,
      count: count,
    );
    return localQuestions.map((q) => DuelQuestion(
      id: q.id,
      subject: q.subject,
      classLevel: q.classLevel,
      questionText: q.questionText,
      options: q.options,
      correctOptionIndex: q.correctOptionIndex,
      explanation: q.explanation,
      tip: q.tip,
      source: 'banque_locale',
    )).toList();
  }

  /// Crée un salon de duel 1v1 avec Code de Validation (PIN)
  Future<Map<String, dynamic>?> createRoom({
    required String creatorName,
    required String classLevel,
    required String subject,
    int count = 5,
  }) async {
    final activeUrl = await getActiveBaseUrlFast();
    if (activeUrl == null) return null;

    try {
      final res = await _dio.post(
        '$activeUrl/api/duel/create-room',
        data: {
          'creator_name': creatorName,
          'class_level': classLevel,
          'subject': subject,
          'count': count,
        },
        options: Options(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 35),
        ),
      );

      if (res.statusCode == 200 && res.data is Map) {
        return Map<String, dynamic>.from(res.data as Map);
      }
    } catch (e) {
      _logger.e('[DuelService] Impossible de créer la salle : $e');
    }
    return null;
  }

  /// Rejoint un salon de duel avec le Code de Validation
  Future<Map<String, dynamic>?> joinRoom({
    required String roomCode,
    required String playerName,
  }) async {
    final activeUrl = await getActiveBaseUrlFast();
    if (activeUrl == null) return null;

    try {
      final res = await _dio.post(
        '$activeUrl/api/duel/join-room',
        data: {
          'room_code': roomCode.trim().toUpperCase(),
          'player_name': playerName,
        },
        options: Options(connectTimeout: const Duration(seconds: 6)),
      );

      if (res.statusCode == 200 && res.data is Map) {
        return Map<String, dynamic>.from(res.data as Map);
      }
    } catch (e) {
      _logger.e('[DuelService] Erreur validation code salon : $e');
    }
    return null;
  }

  /// Consulte l'état de la salle en direct (statut, adversaire, scores)
  Future<Map<String, dynamic>?> getRoomStatus(String roomCode) async {
    final activeUrl = await getActiveBaseUrlFast();
    if (activeUrl == null) return null;

    try {
      final res = await _dio.get(
        '$activeUrl/api/duel/room/${roomCode.trim().toUpperCase()}',
        options: Options(connectTimeout: const Duration(seconds: 3)),
      );

      if (res.statusCode == 200 && res.data is Map) {
        return Map<String, dynamic>.from(res.data as Map);
      }
    } catch (_) {}
    return null;
  }

  /// Met à jour le score du joueur dans la salle
  Future<void> updateScore({
    required String roomCode,
    required String playerName,
    required int score,
    required int questionIndex,
  }) async {
    final activeUrl = await getActiveBaseUrlFast();
    if (activeUrl == null) return;

    try {
      await _dio.post(
        '$activeUrl/api/duel/room/${roomCode.trim().toUpperCase()}/score',
        data: {
          'room_code': roomCode,
          'player_name': playerName,
          'score': score,
          'question_index': questionIndex,
        },
        options: Options(connectTimeout: const Duration(seconds: 2)),
      );
    } catch (_) {}
  }

  /// Matchmaking national instantané par classe dans tout le Mali
  Future<Map<String, dynamic>?> matchmakeMali({
    required String playerName,
    required String classLevel,
    required String subject,
    int count = 5,
  }) async {
    final activeUrl = await getActiveBaseUrlFast();
    if (activeUrl == null) return null;

    try {
      final res = await _dio.post(
        '$activeUrl/api/duel/matchmake',
        data: {
          'player_name': playerName,
          'class_level': classLevel,
          'subject': subject,
          'count': count,
        },
        options: Options(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 35),
        ),
      );

      if (res.statusCode == 200 && res.data is Map) {
        return Map<String, dynamic>.from(res.data as Map);
      }
    } catch (e) {
      _logger.e('[DuelService] Erreur matchmaking Mali : $e');
    }
    return null;
  }

  /// Récupère le classement scolaire national réel depuis la base de données backend alta_db
  Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    final activeUrl = await getActiveBaseUrlFast();
    if (activeUrl != null) {
      try {
        final res = await _dio.get(
          '$activeUrl/api/duel/leaderboard',
          options: Options(
            connectTimeout: const Duration(seconds: 4),
            receiveTimeout: const Duration(seconds: 8),
          ),
        );
        if (res.statusCode == 200 && res.data is List) {
          return List<Map<String, dynamic>>.from(
            (res.data as List).map((e) => Map<String, dynamic>.from(e as Map)),
          );
        }
      } catch (e) {
        _logger.w('[DuelService] Erreur récupération classement : $e');
      }
    }
    return [];
  }
}

final duelServiceProvider = DuelService();

