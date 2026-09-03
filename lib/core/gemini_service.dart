// ─── AlterniA — Core: Backend AI Service (Programme Scolaire Malien) ─────────
// Connecté directement au serveur local AlternIA (LLM Qwen 2.5 + RAG 1573 Chunks Maliens).
library;

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'constants.dart';
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
    return AltaApiConfig.candidateBaseUrls;
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

  /// Envoie un message au backend AlternIA avec l'historique et la matière sélectionnée
  Future<String> generateTeacherChatResponse(
    List<Map<String, String>> historyMessages, {
    String? customInstruction,
    String? subject,
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

    final payload = <String, dynamic>{
      'question': question.trim(),
      'student_class': studentClass,
      'student_name': studentName,
      'history': formattedHistory,
      'enable_rag': true,
    };
    if (subject != null && subject.trim().isNotEmpty && subject.toLowerCase() != 'toutes') {
      payload['subject'] = subject.trim();
    }

    // 3. Essayer les URLs du backend
    for (final baseUrl in _candidateBaseUrls) {
      try {
        _logger.i('[AlterniA] Envoi ($studentClass - ${subject ?? 'général'}) → $baseUrl/api/chat...');

        final response = await _dio.post(
          '$baseUrl/api/chat',
          data: payload,
          options: Options(
            headers: {'Content-Type': 'application/json'},
            connectTimeout: const Duration(seconds: 6),
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

  /// Vérifie si un code de compte premium est valide côté backend
  Future<Map<String, dynamic>> verifyPremiumCode(String code) async {
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) {
      return {'valide': false, 'message': 'Le code ne peut pas être vide.'};
    }

    for (final baseUrl in _candidateBaseUrls) {
      try {
        final response = await _dio.post(
          '$baseUrl/api/auth/verifier-code-premium',
          data: {'code': cleanCode},
          options: Options(
            headers: {'Content-Type': 'application/json'},
            connectTimeout: const Duration(seconds: 4),
            receiveTimeout: const Duration(seconds: 8),
          ),
        );

        if (response.statusCode == 200 && response.data is Map) {
          return Map<String, dynamic>.from(response.data as Map);
        }
      } catch (_) {}
    }

    // Fallback de vérification hors-ligne si serveur déconnecté mais code officiel reconnu
    final upper = cleanCode.toUpperCase();
    final isLocalMaster = upper == 'ALTERNIA-PREMIUM-2026' ||
        upper == 'SIMLI-LIVE-2026' ||
        upper == 'ML-BKO-0042' ||
        upper == 'ALT-BOX-2026-001' ||
        upper == 'VIP-MALI-2026' ||
        upper == 'PREMIUM2026';

    if (isLocalMaster) {
      return {
        'valide': true,
        'message': 'Code premium validé (mode hors-ligne vérifié)',
        'code': upper,
        'plan': 'AlterniA Live Pro',
        'simli_enabled': true,
      };
    }

    return {
      'valide': false,
      'message': 'Code premium non reconnu par le serveur AlternIA.',
    };
  }

  /// Génère une vidéo de l'avatar Simli pour une question ou phrase
  Future<String?> generateSimliAvatarVideo({
    required String text,
    String? subject,
    String? voice,
  }) async {
    for (final baseUrl in _candidateBaseUrls) {
      try {
        final response = await _dio.post(
          '$baseUrl/api/avatars/generate-video',
          data: {
            'question': text,
            'phrase': text,
            'matiere': subject ?? 'Général',
            'voice': voice ?? 'vivienne',
          },
          options: Options(
            connectTimeout: const Duration(seconds: 6),
            receiveTimeout: const Duration(seconds: 60),
          ),
        );

        if (response.statusCode == 200 && response.data is Map) {
          final data = response.data as Map;
          final videoUrl = data['video_url'] as String?;
          if (videoUrl != null && videoUrl.isNotEmpty) {
            return videoUrl.startsWith('http') ? videoUrl : '$baseUrl$videoUrl';
          }
        }
      } catch (_) {}
    }
    return null;
  }

  /// Alias de rétrocompatibilité pour appel direct
  Future<String> generateTeacherResponse(
    String userPrompt, {
    String? customInstruction,
    String? subject,
    String studentName = 'Élève',
    String studentClass = 'Terminale',
  }) async {
    return generateTeacherChatResponse(
      [
        {'role': 'user', 'text': userPrompt}
      ],
      customInstruction: customInstruction,
      subject: subject,
      studentName: studentName,
      studentClass: studentClass,
    );
  }

  /// Alias de rétrocompatibilité pour dialogue socratique
  Future<String> generateSocraticResponse(String userPrompt, {String? subject}) =>
      generateTeacherResponse(
        userPrompt,
        customInstruction: socraticSystemInstruction,
        subject: subject,
      );
}

// Alias officiel
typedef AlterniaBackendService = GeminiService;
