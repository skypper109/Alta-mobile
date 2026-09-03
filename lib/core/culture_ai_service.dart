// ─── AlterniA — Culture AI Service ────────────────────────────────────────────
// Service IA dédié à l'espace Culture du Mali.
// ARCHITECTURE : Séparé volontairement de GeminiService (éducation pédagogique).
// Endpoint actuel : /api/chat (même backend) avec system prompt culturel spécialisé.
// FUTUR : Ce service accueillera l'avatar culturel dédié avec son propre endpoint
//         /api/culture/chat et /api/avatars/culture — aucune modification majeure requise.
library;

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'constants.dart';

// ══════════════════════════════════════════════════════════════════════════════
// CULTURE AI SERVICE — Moteur de Recherche & Guide Culturel Mali
// ══════════════════════════════════════════════════════════════════════════════

/// Résultat d'une recherche culturelle IA
class CultureSearchResult {
  final String aiNarrative;
  final CultureResultType resultType;
  final List<String> keywords;
  final bool isFromAi;

  const CultureSearchResult({
    required this.aiNarrative,
    required this.resultType,
    required this.keywords,
    this.isFromAi = true,
  });

  factory CultureSearchResult.fallback(String query) => CultureSearchResult(
        aiNarrative:
            'Connexion au serveur AlternIA indisponible. Voici les résultats locaux pour « $query ».',
        resultType: CultureResultType.general,
        keywords: query.toLowerCase().split(' '),
        isFromAi: false,
      );
}

/// Types de résultats culturels reconnus
enum CultureResultType {
  figure,     // Personnage historique
  monument,   // Monument
  ville,      // Ville / Terroir
  conte,      // Conte interactif
  devinette,  // Devinette N'Da / quiz
  region,     // Région du Mali
  general,    // Réponse générale
}

// ──────────────────────────────────────────────────────────────────────────────
// SYSTEM PROMPT CULTUREL SPÉCIALISÉ MALI
// FUTUR AVATAR : Ce prompt sera remplacé par le contexte d'un avatar culturel
// dédié (voix, personnalité de griot numérique, endpoint /api/culture/chat).
// ──────────────────────────────────────────────────────────────────────────────
const _cultureSystemPrompt = '''
Tu es le Guide Culturel AlterniA, expert de la civilisation malienne et de l'Afrique de l'Ouest.
Tu réponds UNIQUEMENT en français, avec précision et poésie sur les sujets suivants :
- Histoire des empires du Mali (Ghana, Mali Manden, Songhoï)
- Personnages historiques (Soundiata Keïta, Mansa Moussa, Askia Mohammed, Babemba Traoré…)
- Villes et terroirs (Tombouctou, Djenné, Ségou, Bandiagara, Gao, Sikasso, Kayes…)
- Monuments et patrimoine UNESCO du Mali
- Contes et fables mandingues, bambara, peul, dogon, touareg
- Devinettes traditionnelles (N'Da malien)
- Traditions orales, griots, musique et artisanat
- Les 19 régions du Mali et leurs cultures spécifiques

CLASSIFICATION OBLIGATOIRE : Commence TOUJOURS ta réponse par une ligne de classification :
[TYPE:figure] | [TYPE:monument] | [TYPE:ville] | [TYPE:conte] | [TYPE:devinette] | [TYPE:region] | [TYPE:general]

Puis donne une réponse riche, précise et engageante de 3 à 6 phrases maximum.
MOTS-CLÉS : Termine par une ligne : [KEYWORDS:mot1,mot2,mot3]
''';

// ══════════════════════════════════════════════════════════════════════════════

class CultureAiService {
  CultureAiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final _logger = Logger();

  List<String> get _candidateUrls => AltaApiConfig.candidateBaseUrls;

  // ── MÉTHODE PRINCIPALE : Recherche Culturelle IA ──────────────────────────

  Future<CultureSearchResult> culturalSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return CultureSearchResult(
        aiNarrative: 'Entrez un mot ou une question pour explorer la culture malienne.',
        resultType: CultureResultType.general,
        keywords: [],
        isFromAi: false,
      );
    }

    final payload = {
      'question': cleanQuery,
      'history': <Map<String, String>>[],
      'system': _cultureSystemPrompt,
      'student_name': 'Explorateur',
      'student_class': 'culture',
      'matiere': 'Culture Malienne',
      'use_rag': false,
    };

    for (final baseUrl in _candidateUrls) {
      try {
        _logger.i('[CultureAI] Recherche → $baseUrl/api/chat : "$cleanQuery"');
        final response = await _dio.post(
          '$baseUrl/api/chat',
          data: payload,
          options: Options(
            headers: {'Content-Type': 'application/json'},
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 20),
          ),
        );

        if (response.statusCode == 200 && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          final rawAnswer = (data['answer'] as String? ?? '').trim();
          if (rawAnswer.isNotEmpty) {
            return _parseAiResponse(rawAnswer, cleanQuery);
          }
        }
      } on DioException catch (e) {
        _logger.w('[CultureAI] Serveur hors-ligne $baseUrl : ${e.message}');
      } catch (_) {
        _logger.w('[CultureAI] Erreur inattendue sur $baseUrl');
      }
    }

    return CultureSearchResult.fallback(cleanQuery);
  }

  // ── MÉTHODE CHAT GUIDE CULTUREL (FUTUR AVATAR) ────────────────────────────

  Future<String> culturalChat({
    required String userMessage,
    List<Map<String, String>> history = const [],
    String? additionalContext,
  }) async {
    final systemPrompt = additionalContext != null
        ? '$_cultureSystemPrompt\n\nContexte additionnel : $additionalContext'
        : _cultureSystemPrompt;

    final payload = {
      'question': userMessage,
      'history': history,
      'system': systemPrompt,
      'student_name': 'Explorateur',
      'student_class': 'culture',
      'matiere': 'Culture Malienne',
      'use_rag': false,
    };

    for (final baseUrl in _candidateUrls) {
      try {
        final response = await _dio.post(
          '$baseUrl/api/chat',
          data: payload,
          options: Options(
            headers: {'Content-Type': 'application/json'},
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
        if (response.statusCode == 200 && response.data is Map) {
          final answer = (response.data as Map)['answer'] as String?;
          if (answer != null && answer.trim().isNotEmpty) {
            return _stripClassificationTags(answer.trim());
          }
        }
      } catch (_) {}
    }
    return 'Le guide culturel AlterniA est momentanément indisponible. Réessayez dans un instant.';
  }

  // ── PARSEUR DE RÉPONSE ────────────────────────────────────────────────────

  CultureSearchResult _parseAiResponse(String raw, String query) {
    CultureResultType type = CultureResultType.general;
    List<String> keywords = query.toLowerCase().split(' ');

    final typeMatch = RegExp(r'\[TYPE:(\w+)\]').firstMatch(raw);
    if (typeMatch != null) {
      type = _parseType(typeMatch.group(1) ?? '');
    }

    final kwMatch = RegExp(r'\[KEYWORDS:([^\]]+)\]').firstMatch(raw);
    if (kwMatch != null) {
      keywords = kwMatch.group(1)?.split(',').map((k) => k.trim().toLowerCase()).toList()
          ?? keywords;
    }

    String narrative = raw
        .replaceAll(RegExp(r'\[TYPE:\w+\]'), '')
        .replaceAll(RegExp(r'\[KEYWORDS:[^\]]+\]'), '')
        .trim();

    if (narrative.isEmpty) {
      narrative = 'Découvrez les trésors culturels du Mali liés à « \$query ».';
    }

    return CultureSearchResult(
      aiNarrative: narrative,
      resultType: type,
      keywords: keywords,
      isFromAi: true,
    );
  }

  CultureResultType _parseType(String raw) {
    switch (raw.toLowerCase()) {
      case 'figure':   return CultureResultType.figure;
      case 'monument': return CultureResultType.monument;
      case 'ville':    return CultureResultType.ville;
      case 'conte':    return CultureResultType.conte;
      case 'devinette':return CultureResultType.devinette;
      case 'region':   return CultureResultType.region;
      default:         return CultureResultType.general;
    }
  }

  String _stripClassificationTags(String raw) {
    return raw
        .replaceAll(RegExp(r'\[TYPE:\w+\]'), '')
        .replaceAll(RegExp(r'\[KEYWORDS:[^\]]+\]'), '')
        .trim();
  }
}

typedef CulturalGuideAiService = CultureAiService;
