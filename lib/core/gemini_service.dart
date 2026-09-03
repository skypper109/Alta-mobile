// ─── AlterniA — Core: Backend AI Service (Programme Scolaire Malien) ─────────
// Connecté directement au serveur local AlternIA (LLM Qwen 2.5 + RAG 1573 Chunks Maliens).
library;

import 'dart:typed_data';
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

  /// Prompt Pédagogique (conservé pour compatibilité)
  static const String socraticSystemInstruction = '''
Tu es AlterniA, le tuteur pédagogique de correction d'exercices du programme malien.
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

    final cleanName = studentName.trim().isNotEmpty ? studentName.trim() : 'Élève';
    final nameInstruction = 'IMPORTANT : Adresse-toi directement à l\'élève en utilisant souvent son prénom ou nom "$cleanName" de façon bienveillante, naturelle, pédagogique et encourageante dans tes explications.';

    final payload = <String, dynamic>{
      'question': question.trim(),
      'student_class': studentClass,
      'student_name': cleanName,
      'history': formattedHistory,
      'enable_rag': true,
      'custom_instruction': '${customInstruction ?? ''}\n$nameInstruction'.trim(),
      'system_instruction': nameInstruction,
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

    _logger.w('[AlterniA] Aucun serveur n\'a pu répondre parmi les URLs testées.');
    return "Je n'ai pas pu me connecter au moteur pédagogique AlterniA. Vérifiez la connexion de votre boîtier ou serveur.";
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

  /// Récupère le flux audio de synthèse vocale généré par le serveur AlternIA (/api/tts)
  Future<Uint8List?> fetchBackendTtsAudio({
    required String text,
    String voice = 'vivienne',
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return null;

    for (final baseUrl in _candidateBaseUrls) {
      try {
        _logger.i('[AlterniA TTS] Requête synthèse vocale ($voice) → $baseUrl/api/tts');
        final response = await _dio.post(
          '$baseUrl/api/tts',
          data: {
            'text': cleanText,
            'voice': voice,
          },
          options: Options(
            responseType: ResponseType.bytes,
            connectTimeout: const Duration(seconds: 4),
            receiveTimeout: const Duration(seconds: 25),
          ),
        );

        if (response.statusCode == 200 && response.data != null) {
          final bytes = response.data;
          if (bytes is Uint8List) return bytes;
          if (bytes is List<int>) return Uint8List.fromList(bytes);
        }
      } catch (e) {
        _logger.w('[AlterniA TTS] Échec sur $baseUrl : $e');
      }
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
  Future<String> generateSocraticResponse(
    String userPrompt, {
    String? subject,
    String studentName = 'Élève',
    String studentClass = 'Terminale',
  }) =>
      generateTeacherResponse(
        userPrompt,
        customInstruction: socraticSystemInstruction,
        subject: subject,
        studentName: studentName,
        studentClass: studentClass,
      );
}

// Alias officiel
typedef AlterniaBackendService = GeminiService;
