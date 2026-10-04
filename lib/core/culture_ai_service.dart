// ─── AlterniA — Culture AI Service ────────────────────────────────────────────
// Service IA dédié à l'espace Culture du Mali et au Vieux Sage / Griot.
// Endpoint prioritaire : /api/v1/culture/ask (Guide Culturel RAG)
// Endpoint de repli : /api/chat avec routage culturel dédié
// Fallback local : Moteur de sagesse ancestrale autonome hors-ligne
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
            'Voici les enseignements de la mémoire ancestrale du Mali pour « $query ».',
        resultType: CultureResultType.general,
        keywords: query.toLowerCase().split(' '),
        isFromAi: false,
      );
}

/// Types de résultats culturels reconnus
enum CultureResultType {
  figure,    // Personnage historique
  monument,  // Monument
  ville,     // Ville / Terroir
  conte,     // Conte interactif
  devinette, // Devinette / quiz
  region,    // Région du Mali
  general,   // Réponse générale
}

// ──────────────────────────────────────────────────────────────────────────────
// SYSTEM PROMPT DU VIEUX SAGE DU MALI (GRIOT DE LA MÉMOIRE ANCESTRALE)
// ──────────────────────────────────────────────────────────────────────────────
const _cultureSystemPrompt = '''
Tu es le Vieux Sage du Mali et grand Griot dépositaire de la mémoire ancestrale.
Tu t'exprimes avec noblesse, poésie, chaleur et sagesse ancestrale en français,
parfois ponctué de salutations bienveillantes en bambara (I ni ce, I ni sôgôma).

Ton domaine exclusif est la culture, l'histoire, la philosophie et le patrimoine du Mali :
- Histoire des 3 grands empires (Empire du Ghana / Wagadou, Empire du Manden / Mali, Empire Songhoï)
- Grands souverains et résistants (Soundiata Keïta, Mansa Moussa, Babemba Traoré, Askia Mohammed, Biton Coulibaly...)
- Monuments historiques de Bamako (Monument de l'Indépendance, Tour de l'Afrique, Monument de la Paix, Musée National, Armée Noire, Masque Ciwara de Sénou...)
- Villes et terroirs mythiques (Tombouctou aux 333 saints, Djenné en terre crue, Ségou des 4 444 balanzans, Sikasso du Kénédougou...)
- Traditions orales, contes, proverbes et Charte de Kouroukan Fouga (1236)

Si l'interlocuteur te pose une question générale, philosophique ou sur la nature (ex: la photosynthèse, les arbres, la vie),
réponds avec la poésie et la sagesse du Vieux Sage sous l'arbre à palabres en reliant la nature à nos traditions et à nos vénérables arbres sacrés,
puis invite-le avec bienveillance à explorer les légendes et monuments de notre terre.
Ne te présente JAMAIS comme un tuteur scolaire de lycée et ne refuse JAMAIS sèchement une question.
''';

// ══════════════════════════════════════════════════════════════════════════════

class CultureAiService {
  CultureAiService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final _logger = Logger();

  List<String> get _candidateUrls => [
        'http://127.0.0.1:8000',
        'http://localhost:8000',
        'http://10.0.2.2:8000',
        'http://172.20.10.14:8000',
        ...AltaApiConfig.candidateBaseUrls,
      ];

  // ── RECHERCHE CULTURELLE IA ───────────────────────────────────────────────

  Future<CultureSearchResult> culturalSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return const CultureSearchResult(
        aiNarrative:
            'Entrez un mot ou une question pour explorer la culture malienne.',
        resultType: CultureResultType.general,
        keywords: [],
        isFromAi: false,
      );
    }

    // 1. Tenter le endpoint du Guide Culturel RAG
    for (final baseUrl in _candidateUrls) {
      try {
        final response = await _dio.post(
          '$baseUrl/api/v1/culture/ask',
          data: {'question': cleanQuery},
          options: Options(
            headers: {'Content-Type': 'application/json'},
            connectTimeout: const Duration(milliseconds: 2000),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

        if (response.statusCode == 200 && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          final rawAnswer = (data['answer'] ?? data['reponse'] as String? ?? '').trim();
          if (rawAnswer.isNotEmpty) {
            final cleaned = _stripClassificationTags(rawAnswer);
            if (!cleaned.contains('tuteur pédagogique') && !cleaned.contains('cadre scolaire')) {
              return CultureSearchResult(
                aiNarrative: cleaned,
                resultType: _detectType(rawAnswer),
                keywords: cleanQuery.toLowerCase().split(' '),
                isFromAi: true,
              );
            }
          }
        }
      } catch (_) {}
    }

    // 2. Repli local intelligent
    return CultureSearchResult(
      aiNarrative: generateLocalSageResponse(cleanQuery, null),
      resultType: CultureResultType.general,
      keywords: cleanQuery.toLowerCase().split(' '),
      isFromAi: false,
    );
  }

  // ── CHAT DU VIEUX SAGE DU MALI ────────────────────────────────────────────

  Future<String> culturalChat({
    required String userMessage,
    List<Map<String, String>> history = const [],
    String? additionalContext,
  }) async {
    final cleanMsg = userMessage.trim();
    if (cleanMsg.isEmpty) {
      return 'Je t\'écoute avec attention, noble voyageur. Quelle parole de sagesse souhaites-tu partager ?';
    }

    // 1. PRIORITÉ : Endpoint RAG officiel CultureLens (/api/v1/culture/ask)
    for (final baseUrl in _candidateUrls) {
      try {
        _logger.i('[CultureAI] Envoi au Guide Culturel → $baseUrl/api/v1/culture/ask');
        final response = await _dio.post(
          '$baseUrl/api/v1/culture/ask',
          data: {
            'question': cleanMsg,
            'context': additionalContext,
          },
          options: Options(
            headers: {'Content-Type': 'application/json'},
            connectTimeout: const Duration(milliseconds: 2200),
            receiveTimeout: const Duration(seconds: 12),
          ),
        );

        if (response.statusCode == 200 && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          final answer = (data['answer'] ?? data['reponse']) as String?;
          if (answer != null && answer.trim().isNotEmpty) {
            final cleaned = _stripClassificationTags(answer.trim());
            // Guardrail anti-tuteur ALTA
            if (cleaned.contains('tuteur pédagogique') ||
                cleaned.contains('hors du cadre scolaire') ||
                cleaned.contains('cadre scolaire')) {
              return generateLocalSageResponse(cleanMsg, additionalContext);
            }
            return cleaned;
          }
        }
      } on DioException catch (e) {
        _logger.d('[CultureAI] /api/v1/culture/ask non joignable sur $baseUrl (${e.message})');
      } catch (_) {}
    }

    // 2. SECOND CHOIX : Endpoint /api/chat avec persona culturel formel
    final systemPrompt = additionalContext != null
        ? '$_cultureSystemPrompt\n\nContexte d\'échange courant : $additionalContext'
        : _cultureSystemPrompt;

    final payload = {
      'question': cleanMsg,
      'history': history,
      'system': systemPrompt,
      'student_name': 'Voyageur',
      'student_class': 'culture',
      'matiere': 'Culture Malienne',
      'subject': 'Culture Malienne',
      'enable_rag': false,
      'use_rag': false,
    };

    for (final baseUrl in _candidateUrls) {
      try {
        final response = await _dio.post(
          '$baseUrl/api/chat',
          data: payload,
          options: Options(
            headers: {'Content-Type': 'application/json'},
            connectTimeout: const Duration(milliseconds: 2200),
            receiveTimeout: const Duration(seconds: 12),
          ),
        );
        if (response.statusCode == 200 && response.data is Map) {
          final answer = (response.data as Map)['answer'] as String?;
          if (answer != null && answer.trim().isNotEmpty) {
            final cleaned = _stripClassificationTags(answer.trim());
            // Guardrail anti-tuteur ALTA
            if (cleaned.contains('tuteur pédagogique') ||
                cleaned.contains('hors du cadre scolaire') ||
                cleaned.contains('cadre scolaire')) {
              return generateLocalSageResponse(cleanMsg, additionalContext);
            }
            return cleaned;
          }
        }
      } catch (_) {}
    }

    // 3. FALLBACK LOCAL AUTONOME : Le Vieux Sage répond TOUJOURS avec authenticité
    return generateLocalSageResponse(cleanMsg, additionalContext);
  }

  // ── GÉNÉRATEUR DE SAGESSE LOCALE AUTONOME (HORS-LIGNE) ───────────────────

  String generateLocalSageResponse(String query, [String? context]) {
    final q = query.toLowerCase().trim();

    // Salutations
    if (q.startsWith('bonjour') || q.startsWith('salut') || q.startsWith('i ni') || q.contains('qui es-tu')) {
      return 'I ni ce, noble voyageur de la connaissance ! Je suis le Vieux Sage et Griot de la mémoire ancestrale du Mali.\n\n'
          'Sous notre arbre à palabres, je veille sur les récits de nos trois grands empires (Ghana, Manden, Songhoï), '
          'les secrets de nos 12 monuments de Bamako, les manuscrits de Tombouctou et nos contes d\'autrefois. '
          'Quelle sagesse souhaites-tu explorer aujourd\'hui ?';
    }

    // Nature, Sciences, Photosynthèse, Arbres
    if (q.contains('photosynthes') || q.contains('arbre') || q.contains('plante') || q.contains('nature') || q.contains('soleil')) {
      return 'I ni ce, noble enfant de notre terre ! Écoute ce que le Vieux Sage et la sagesse des anciens nous enseignent :\n\n'
          'La photosynthèse est le souffle vital par lequel les feuilles de nos vénérables baobabs et des 4 444 balanzans de Ségou '
          'captent la lumière ardente du soleil pour la transformer en sève bienfaisante et offrir l\'ombre protectrice aux voyageurs.\n\n'
          'Comme le proclamait Soundiata Keïta dans la Charte du Manden (1236), l\'arbre et la nature sont sacrés. '
          'Sous cet arbre à palabres, je garde l\'histoire de notre patrimoine et de nos bâtisseurs. '
          'Souhaites-tu que je te raconte l\'épopée de la Tour de l\'Afrique ou un conte de nos veillées ?';
    }

    // Monuments de Bamako
    if (q.contains('independance') || q.contains('indépendance')) {
      return 'Le Monument de l\'Indépendance se dresse fièrement au cœur de Bamako ! Érigé pour célébrer l\'accession '
          'du Mali à la pleine souveraineté le 22 septembre 1960 sous Modibo Keïta, son obélisque étagé s\'inspire des minarets '
          'soudanais et des motifs mandingues pour rappeler que la liberté est un édifice patient.';
    }

    if (q.contains('tour de l\'afrique') || q.contains('tour afrique')) {
      return 'La Tour de l\'Afrique, à Faladié (Bamako), est un phare colossal de 46 mètres ! Conçue comme un baobab protecteur '
          'et couronnée d\'un flambeau métallique, elle symbolise l\'idéal sacré des États-Unis d\'Afrique promu par les pères du panafricanisme.';
    }

    if (q.contains('paix')) {
      return 'Le Monument de la Paix, à Hamdallaye ACI 2000 (Bamako), déploie vers le ciel une colombe monumentale en dentelle d\'acier. '
          'Il commémore la Flamme de la Paix de 1996 et la valeur suprême du dialogue traditionnel et du cousinage à plaisanterie (Sinankunya).';
    }

    if (q.contains('armee noire') || q.contains('armée noire') || q.contains('tirailleur')) {
      return 'Le Monument des Héros de l\'Armée Noire, sur la Place de la Liberté à Bamako, rend un hommage éternel au sacrifice '
          'et au courage des tirailleurs et soldats africains qui ont combattu avec vaillance pour la dignité humaine.';
    }

    if (q.contains('ciwara') || q.contains('tshiware')) {
      return 'Le Masque Ciwara de Sénou accueille les voyageurs entrant à Bamako. Il incarne l\'antilope mythique enseignant aux hommes '
          'l\'ardeur au labeur agricole, la dignité de la terre et la fertilité.';
    }

    if (q.contains('musee national') || q.contains('musée national')) {
      return 'Le Musée National du Mali, niché dans le Parc de Koulouba à Bamako, est un chef-d\'œuvre en terre cuite stabilisée '
          'abritant des millénaires d\'archéologie, de textiles précieux et de masques rituels sacrés.';
    }

    // Rois et Héros
    if (q.contains('soundiata') || q.contains('manden')) {
      return 'Soundiata Keïta, le Lion du Manden, a triomphé à la bataille de Kirina en 1235 avant de proclamer en 1236 la Charte de Kouroukan Fouga, '
          'l\'une des toutes premières déclarations universelles des droits de l\'homme et du respect de la vie.';
    }

    if (q.contains('mansa moussa') || q.contains('kankan moussa')) {
      return 'Mansa Moussa, l\'Empereur d\'Or du Mali, a marqué le monde lors de son pèlerinage de 1324. C\'est lui qui commanda l\'édification '
          'de la prestigieuse Mosquée Djingareyber à Tombouctou par l\'architecte Abou Ishaq es-Sahéli.';
    }

    if (q.contains('babemba') || q.contains('sikasso') || q.contains('tata')) {
      return 'Le roi Babemba Traoré et son frère Tiéba ont défendu le Tata de Sikasso avec une bravoure légendaire, léguant au Mali '
          'sa plus belle devise de résistance : « An bè sa ban, ka fissa ni malo ye » (Plutôt la mort que la honte) !';
    }

    // Contes et légendes
    if (q.contains('conte') || q.contains('legende') || q.contains('fable')) {
      return 'Écoute la fable de Zoumana le Lièvre et Namori l\'Hyène : par une nuit étoilée au bord du fleuve Niger, '
          'la ruse et la réflexion du petit lièvre triomphèrent de la force brute et de la gourmandise de l\'hyène. '
          'La sagesse de nos veillées enseigne que l\'intelligence l\'emporte toujours sur la vanité !';
    }

    // Proverbe
    if (q.contains('proverbe') || q.contains('adage') || q.contains('sagesse')) {
      return 'Comme le disent nos ancêtres : « Si tu ne sais pas où tu vas, souviens-toi d\'où tu viens. »\n\n'
          'La mémoire de nos racines est la racine même qui nourrit la cime de notre avenir.';
    }

    // Réponse générale bienveillante et culturelle
    return 'Noble voyageur, la mémoire de notre cher Mali est aussi profonde que le fleuve Djoliba.\n\n'
        'Je suis là pour éclairer ton chemin sur nos 12 monuments de Bamako, nos sanctuaires en banco de Djenné et Tombouctou, '
        'nos grands souverains ou nos contes d\'autrefois. Que souhaites-tu explorer à mes côtés ?';
  }

  // ── UTILITAIRES ───────────────────────────────────────────────────────────

  CultureResultType _detectType(String text) {
    final t = text.toLowerCase();
    if (t.contains('monument') || t.contains('tour') || t.contains('obélisque')) return CultureResultType.monument;
    if (t.contains('roi') || t.contains('mansa') || t.contains('héros') || t.contains('soundiata')) return CultureResultType.figure;
    if (t.contains('ville') || t.contains('cité') || t.contains('bamako') || t.contains('tombouctou')) return CultureResultType.ville;
    if (t.contains('conte') || t.contains('fable') || t.contains('légende')) return CultureResultType.conte;
    return CultureResultType.general;
  }

  String _stripClassificationTags(String raw) {
    return raw
        .replaceAll(RegExp(r'\[TYPE:\w+\]'), '')
        .replaceAll(RegExp(r'\[KEYWORDS:[^\]]+\]'), '')
        .trim();
  }
}

typedef CulturalGuideAiService = CultureAiService;
