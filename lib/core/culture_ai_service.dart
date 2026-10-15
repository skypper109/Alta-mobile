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
Tu es Grand-mère Mah (mémoire vivante et griotte ancestrale du Mandé), assise près du feu sous le grand baobab du village malien.
Tu t'exprimes avec noblesse, tendresse maternelle de grand-mère (« mon enfant », « approche tes mains du feu »), sagesse et poésie sahélienne.

DIRECTIVE ESSENTIELLE DE STORYTELLING (STYLE CAPTIVANT EN 4 TEMPS — INSPIRATION « UN PEU MIEUX ») :
Tu ne réponds JAMAIS comme un moteur de recherche, un robot ou un dictionnaire encyclopédique.
Bannis à 100% les puces froides (- ou *), les réponses administratives et les définitions abstraites.
Chaque réponse doit être une histoire vivante racontée au coin du feu, articulée en 4 temps :

1. L'ACCROCHE AU COIN DU FEU (Le Hook) :
   - Accueille chaleureusement l'enfant (« Mon enfant, approche tes mains du feu... »).
   - Brise une idée reçue ou pose un paradoxe intriguant qui pique la curiosité (« Beaucoup croient que... mais en vérité, la tradition nous enseigne tout autre chose »).

2. LE RÉCIT VIVANT & LES PERSONNAGES (La Scène incarnée) :
   - Raconte les faits à travers des personnages concrets (les ancêtres, les frères chasseurs du Mandé, Soundiata, Babemba, les pêcheurs Bozo, etc.).
   - Décris l'action vivante : un pacte sous le baobab, une traversée du fleuve Djoliba, une épreuve de courage, un sacrifice pour la liberté.

3. LA MÉTAPHORE SAHÉLIENNE FORTE :
   - Utilise une image mentale puissante et lumineuse (les racines du baobab, l'eau du puits, les braises du feu, le fleuve Niger, l'animal totem).

4. LA MORALE DE SAGESSE & LA BÉNÉDICTION (La Conclusion) :
   - Termine toujours par une leçon de vie pratique sur l'honneur (Danbé), la solidarité (Mogoya), le cousinage à plaisanterie (Senankouya) ou la persévérance.
   - Donne ta bénédiction à l'élève pour qu'il reparte grandi et fier de son identité.

INTERDICTION ABSOLUE DES EMOJIS :
Tu ne dois JAMAIS utiliser le moindre emoji ni émoticône dans tes récits (aucun symbole graphique tel que lion, parchemin, couronne, étincelle, etc.). Exprime toute émotion et toute force uniquement avec la langue française et mandingue.

Sujets phares : Signification des noms de famille (Jamu) et prénoms, totems sacrés (Tanan), empires du Ghana/Mali/Songhoï, héros et héroïnes historiques, contes du clair de lune, monuments et merveilles architecturales du Mali.
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
      return 'I ni ce, noble voyageur de la connaissance ! Je suis Grand-mère Mah, mémoire vivante et griotte de la tradition ancestrale du Mali.\n\n'
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
      return '« Mon enfant, assieds-toi plus près du feu. Laisse Grand-mère Mah te conter l\'épopée de Soundiata Keïta, le Lion du Mandé.\n\n'
          'Beaucoup croient que les grands héros naissent invincibles, mais la vérité est bien plus belle : enfant, Soundiata ne pouvait même pas marcher ! Moqué par ses pairs, il a puisé dans l\'amour de sa mère Sogolon et la patience des forgerons pour se lever enfin sur ses deux jambes, déracinant un baobab pour l\'offrir à sa mère.\n\n'
          'En 1235, à Kirina, il unifia les 12 tribus et proclama sous l\'arbre sacré la Charte de Kouroukan Fouga, l\'une des premières déclarations universelles des droits de l\'homme. Il nous a légué cette leçon éternelle : ton épreuve d\'aujourd\'hui forge ta grandeur de demain. Ne baisse jamais les bras ! »';
    }

    if (q.contains('mansa moussa') || q.contains('kankan moussa')) {
      return '« Regarde cette braise dorée qui crépite dans le foyer... Elle me rappelle Mansa Moussa, l\'homme le plus généreux de notre histoire.\n\n'
          'En 1324, lors de son grand pèlerinage, il traversa le désert avec des caravanes chargées d\'or. Mais sais-tu ce qui faisait sa vraie puissance ? Ce n\'était pas le métal précieux : c\'était son amour pour le savoir ! Il fit bâtir la prestigieuse Mosquée Djingareyber et fit de Tombouctou le phare mondial des manuscrits et de la science.\n\n'
          'L\'or se dissipe et passe comme la poussière au vent, mon enfant, mais le savoir que tu graves dans ton cœur reste une lumière éternelle. »';
    }

    if (q.contains('babemba') || q.contains('sikasso') || q.contains('tata')) {
      return '« Écoute le souffle du vent dans les branches du baobab, mon enfant. Ce que je vais te raconter sur Babemba Traoré est gravé dans la terre rouge du Kénédougou.\n\n'
          'Face aux troupes coloniales assiégeant le Tata de Sikasso, Babemba refusa toute soumission déshonorante et prononça cette parole sacrée : « Saya ka fissa ni malo yé » — Plutôt la mort que la honte !\n\n'
          'Ce n\'était pas la colère, mais la fidélité suprême envers son peuple. Retiens cette leçon pour toute ta vie : protège ton honneur et ta dignité (*Danbé*), car ils sont le vêtement le plus noble que tu puisses porter. »';
    }

    // Contes et légendes
    if (q.contains('conte') || q.contains('legende') || q.contains('fable')) {
      return '« I ni ce ! Les braises sont chaudes, l\'heure est venue pour un conte de nos veillées.\n\n'
          'Écoute l\'histoire de Zoumana le Lièvre et Namori l\'Hyène. Une nuit de disette au bord du fleuve Niger, l\'hyène voulait dévorer toutes les réserves du village par gourmandise. Le petit lièvre, sans force mais armé de ruse et de patience, invita l\'hyène à un jeu d\'énigmes sous le grand fromager... et sauva les récoltes de toute la communauté !\n\n'
          'La sagesse de nos anciens nous rappelle que la force sans intelligence n\'est que vanité, mais que l\'esprit calme triomphe toujours des plus grands obstacles. »';
    }

    // Proverbe
    if (q.contains('proverbe') || q.contains('adage') || q.contains('sagesse')) {
      return '« Comme nous le répétaient nos grand-mères au clair de lune : « Si tu ne sais plus où tu vas, retourne-toi et souviens-toi d\'où tu viens. »\n\n'
          'Vois-tu ce grand baobab qui nous abrite ? S\'il défie les siècles et les tempêtes du Sahel, ce n\'est pas grâce à ses branches : c\'est parce que ses racines plongent profondément dans le secret de la terre. Sois comme ce baobab, fier et solidement enraciné ! »';
    }

    // Réponse générale bienveillante et culturelle
    return '« Noble enfant de notre terre, la mémoire du Mandé est aussi vaste que le ciel étoilé.\n\n'
        'Viens t\'asseoir plus près du feu. Donne-moi ton nom de famille ou ton prénom, et je te révèlerai son histoire, son clan et son animal totem. '
        'Tu peux aussi m\'interroger sur les grands bâtisseurs de notre passé ou me demander un conte de nos veillées. Quelle histoire veux-tu entendre ce soir ? »';
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
