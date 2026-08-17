// ─── AlterniA — Core: Backend AI Service (Programme Scolaire Malien) ─────────
// Connecté directement au serveur local AlternIA (LLM Qwen 2.5 + RAG 1573 Chunks Maliens).
library;

import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import 'malian_school_system.dart';

// ══════════════════════════════════════════════════════════════════════════════
// ALTERNIA BACKEND SERVICE — Tuteur Pédagogique Intelligent Malien
// ══════════════════════════════════════════════════════════════════════════════

class GeminiService {
  GeminiService({Dio? dio, String? customBaseUrl})
      : _dio = dio ?? Dio(),
        _customBaseUrl = customBaseUrl;

  final Dio _dio;
  final String? _customBaseUrl;
  final _logger = Logger();

  /// URLs candidates selon la plateforme d'exécution
  List<String> get _candidateBaseUrls {
    final custom = _customBaseUrl;
    if (custom != null && custom.isNotEmpty) {
      return [custom];
    }
    if (kIsWeb) {
      return ['http://127.0.0.1:8000', 'http://localhost:8000'];
    }
    try {
      if (Platform.isAndroid) {
        return [
          'http://10.0.2.2:8000',      // Émulateur Android
          'http://127.0.0.1:8000',
          'http://192.168.4.1:8000',   // Hotspot Boîtier AlternIA
          'http://192.168.1.100:8000',
        ];
      }
    } catch (_) {}
    return [
      'http://127.0.0.1:8000',        // iOS Simulator / macOS / Linux Desktop
      'http://localhost:8000',
      'http://192.168.4.1:8000',
    ];
  }

  /// Construit les instructions système (conservé pour compatibilité)
  static String buildTeacherSystemInstruction({
    String name = 'Élève',
    String studentClassId = 'tse',
  }) {
    final cls = classById(studentClassId);
    final classLabel = cls?.label ?? studentClassId;
    return 'Tu es AlterniA, le professeur particulier IA pour $classLabel du programme scolaire malien.';
  }

  /// Prompt Socratique (conservé pour compatibilité)
  static const String socraticSystemInstruction = '''
Tu es AlterniA, le tuteur socratique de correction d'exercices du programme malien.
''';

  /// Envoie un message au backend AlternIA avec l'historique de conversation
  Future<String> generateTeacherChatResponse(
    List<Map<String, String>> historyMessages, {
    String? customInstruction,
    String studentName = 'Élève',
    String studentClass = 'tse',
  }) async {
    // 1. Extraire la dernière question de l'élève
    String question = '';
    for (int i = historyMessages.length - 1; i >= 0; i--) {
      if (historyMessages[i]['role'] == 'user') {
        question = historyMessages[i]['text'] ?? '';
        break;
      }
    }

    if (question.trim().isEmpty && historyMessages.isNotEmpty) {
      question = historyMessages.last['text'] ?? '';
    }

    if (question.trim().isEmpty) {
      return 'Pose-moi une question sur le programme malien pour que je puisse t\'aider !';
    }

    // 2. Mapper l'historique pour le backend
    final formattedHistory = historyMessages.map((msg) {
      return {
        'role': msg['role'] == 'user' ? 'user' : 'assistant',
        'text': msg['text'] ?? '',
      };
    }).toList();

    final payload = {
      'question': question.trim(),
      'student_class': studentClass,
      'student_name': studentName,
      'history': formattedHistory,
      'enable_rag': true,
    };

    // 3. Essayer les URLs du backend
    for (final baseUrl in _candidateBaseUrls) {
      try {
        _logger.i('[AlterniA] Envoi ($studentClass) → $baseUrl/api/chat...');

        final response = await _dio.post(
          '$baseUrl/api/chat',
          data: payload,
          options: Options(
            headers: {'Content-Type': 'application/json'},
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 45),
          ),
        );

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          final answer = data['answer'] as String?;
          if (answer != null && answer.trim().isNotEmpty) {
            _logger.i('[AlterniA] Réponse reçue avec succès du serveur AlternIA !');
            
            final followup = data['followup_question'] as String?;
            final shouldAskFollowup = data['should_ask_followup'] as bool? ?? false;
            
            if (shouldAskFollowup && followup != null && followup.isNotEmpty && !answer.contains(followup)) {
              return '${answer.trim()}\n\n💡 **Conseil AlternIA :** $followup';
            }
            return answer.trim();
          }
        }
      } on DioException catch (dioErr) {
        _logger.w('[AlterniA] Serveur non joignable sur $baseUrl : ${dioErr.message}');
      } catch (e) {
        _logger.w('[AlterniA] Erreur sur $baseUrl : $e');
      }
    }

    _logger.w('[AlterniA] Le serveur local AlternIA est injoignable.');
    return '⚠️ **Serveur AlternIA Hors-Ligne**\n\nImpossible de joindre le moteur pédagogique AlternIA sur le réseau local.\n\nVérifie que le serveur Backend AlternIA est bien démarré (`uvicorn backend.src.main:app`).';
  }

  /// Alias de rétrocompatibilité pour appel direct
  Future<String> generateTeacherResponse(
    String userPrompt, {
    String? customInstruction,
    String studentName = 'Élève',
    String studentClass = 'Terminale',
  }) async {
    return generateTeacherChatResponse(
      [
        {'role': 'user', 'text': userPrompt}
      ],
      customInstruction: customInstruction,
      studentName: studentName,
      studentClass: studentClass,
    );
  }

  /// Alias de rétrocompatibilité pour dialogue socratique
  Future<String> generateSocraticResponse(String userPrompt) =>
      generateTeacherResponse(
        userPrompt,
        customInstruction: socraticSystemInstruction,
      );
}

// Alias officiel
typedef AlterniaBackendService = GeminiService;
