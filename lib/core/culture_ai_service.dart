// ─── AlterniA — Culture AI Service ────────────────────────────────────────────
// Service IA dédié à l'espace Culture du Mali et à Grand-mère Mah.
// Endpoint prioritaire : /api/v1/culture/ask (Guide Culturel RAG)
// Endpoint de repli : /api/chat avec routage culturel dédié
// Fallback local : Moteur de sagesse ancestrale autonome hors-ligne
library;

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'constants.dart';
import '../features/culture/core/datasources/malian_names_knowledge.dart';

// ══════════════════════════════════════════════════════════════════════════════
// CULTURE AI SERVICE — Moteur de Recherche & Guide Culturel Mali
// ══════════════════════════════════════════════════════════════════════════════

/// Résultat complet d'un échange avec Grand-mère Mah sous le baobab
class SageChatResponse {
  final String answer;
  final String scenicAction;
  final MalianNameInfo? matchedName;
  final List<String> sources;
  final bool isFromBackend;

  const SageChatResponse({
    required this.answer,
    required this.scenicAction,
    this.matchedName,
    this.sources = const [],
    this.isFromBackend = true,
  });
}

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

/// Cas d'usage identifiés pour l'espace Culture (Recherche & Chat sans RAG)
enum CultureUseCase {
  monumentSite,       // Monuments, architecture, sites sacrés (Tour de l'Afrique, Djenné, Tombouctou...)
  historicalFigure,   // Héros, souverains, résistants (Soundiata, Babemba, Mansa Moussa, Samory...)
  storyTale,          // Contes traditionnels, fables d'animaux (Bouki, Leuk, veillées au clair de lune...)
  proverbWisdom,      // Proverbes, maximes, Charte de Kouroukan Fouga, Senankouya, Diatiguiya
  traditionArt,       // Masques (Ciwara), musique (Kora, Balafon), Bogolan, artisanat, fêtes
  philosophicalLife,  // Questions existentielles, doutes, avenir, conseils posés au Sage sous l'arbre
  generalCulture,     // Panorama général et patrimoine du Mali
}

// ──────────────────────────────────────────────────────────────────────────────
// MOTEUR DE PROMPTS ADAPTATIFS DE HAUTE FIDÉLITÉ CULTURELLE DU MALI
// ──────────────────────────────────────────────────────────────────────────────
class CultureAdaptivePromptSystem {
  /// Détection ultra-fine du cas d'usage culturel selon les intentions de l'utilisateur
  static CultureUseCase detectUseCase(String text) {
    final t = text.toLowerCase();

    // 1. Monuments & Sites historiques
    if (t.contains('monument') ||
        t.contains('tour de l\'afrique') ||
        t.contains('independance') ||
        t.contains('indépendance') ||
        t.contains('djenne') ||
        t.contains('djenné') ||
        t.contains('mosquee') ||
        t.contains('mosquée') ||
        t.contains('tombouctou') ||
        t.contains('sankore') ||
        t.contains('sankoré') ||
        t.contains('djingareyber') ||
        t.contains('askia') ||
        t.contains('tata') ||
        t.contains('sikasso') ||
        t.contains('medine') ||
        t.contains('médine') ||
        t.contains('fort') ||
        t.contains('obelisque') ||
        t.contains('obélisque') ||
        t.contains('paix') ||
        t.contains('martyrs') ||
        t.contains('statue') ||
        t.contains('edifice') ||
        t.contains('édifice') ||
        t.contains('architecture') ||
        t.contains('site historique')) {
      return CultureUseCase.monumentSite;
    }

    // 2. Grandes figures & résistants
    if (t.contains('soundiata') ||
        t.contains('keita') ||
        t.contains('keïta') ||
        t.contains('mansa moussa') ||
        t.contains('kankou moussa') ||
        t.contains('kankan moussa') ||
        t.contains('babemba') ||
        t.contains('traore') ||
        t.contains('traoré') ||
        t.contains('tieba') ||
        t.contains('tiéba') ||
        t.contains('samory') ||
        t.contains('samori') ||
        t.contains('biton') ||
        t.contains('coulibaly') ||
        t.contains('modibo') ||
        t.contains('sonni ali') ||
        t.contains('askia mohammed') ||
        t.contains('da monzon') ||
        t.contains('ngolo') ||
        t.contains('n\'golo') ||
        t.contains('firhoun') ||
        t.contains('empereur') ||
        t.contains('roi') ||
        t.contains('reine') ||
        t.contains('guerrier') ||
        t.contains('resistant') ||
        t.contains('résistant') ||
        t.contains('heros') ||
        t.contains('héros')) {
      return CultureUseCase.historicalFigure;
    }

    // 3. Contes & Légendes
    if (t.contains('conte') ||
        t.contains('fable') ||
        t.contains('bouki') ||
        t.contains('hyene') ||
        t.contains('hyène') ||
        t.contains('leuk') ||
        t.contains('lievre') ||
        t.contains('lièvre') ||
        t.contains('legende') ||
        t.contains('légende') ||
        t.contains('mythe') ||
        t.contains('recit') ||
        t.contains('récit') ||
        t.contains('arbre a palabres') ||
        t.contains('arbre à palabres') ||
        t.contains('clair de lune') ||
        t.contains('veillee') ||
        t.contains('veillée')) {
      return CultureUseCase.storyTale;
    }

    // 4. Proverbes, Sagesses, Devises & Charte
    if (t.contains('proverbe') ||
        t.contains('adage') ||
        t.contains('maxime') ||
        t.contains('sagesse') ||
        t.contains('kouroukan') ||
        t.contains('fouga') ||
        t.contains('charte') ||
        t.contains('senankouya') ||
        t.contains('cousinage') ||
        t.contains('plaisanterie') ||
        t.contains('diatiguiya') ||
        t.contains('hospitalite') ||
        t.contains('hospitalité') ||
        t.contains('devise') ||
        t.contains('morale')) {
      return CultureUseCase.proverbWisdom;
    }

    // 5. Traditions, Musique, Artisanat & Masques
    if (t.contains('ciwara') ||
        t.contains('bogolan') ||
        t.contains('kora') ||
        t.contains('balafon') ||
        t.contains('ngoni') ||
        t.contains('n\'goni') ||
        t.contains('djembe') ||
        t.contains('djembé') ||
        t.contains('masque') ||
        t.contains('crepissage') ||
        t.contains('crépissage') ||
        t.contains('sanke') ||
        t.contains('sanké') ||
        t.contains('peche') ||
        t.contains('pêche') ||
        t.contains('danse') ||
        t.contains('tissage') ||
        t.contains('forgeron') ||
        t.contains('griotte') ||
        t.contains('griot') ||
        t.contains('coutume') ||
        t.contains('rite') ||
        t.contains('artisanat')) {
      return CultureUseCase.traditionArt;
    }

    // 6. Questions existentielles, de vie, doutes
    if (t.contains('peur') ||
        t.contains('angoisse') ||
        t.contains('conseil') ||
        t.contains('vie') ||
        t.contains('avenir') ||
        t.contains('courage') ||
        t.contains('ami') ||
        t.contains('amitié') ||
        t.contains('famille') ||
        t.contains('reussir') ||
        t.contains('réussir') ||
        t.contains('bonheur') ||
        t.contains('triste') ||
        t.contains('aide-moi') ||
        t.contains('aide moi') ||
        t.contains('que dois-je faire') ||
        t.contains('que faire') ||
        t.contains('choix') ||
        t.contains('sens de la vie')) {
      return CultureUseCase.philosophicalLife;
    }

    return CultureUseCase.generalCulture;
  }

  /// Construit un System Prompt ultra-spécialisé pour le MODE RECHERCHE
  static String buildSearchSystemPrompt(CultureUseCase useCase) {
    switch (useCase) {
      case CultureUseCase.monumentSite:
        return '''Tu es l'Encyclopédie Officielle du Patrimoine Monumental du Mali.
Ta mission est d'offrir une notice de recherche claire, structurée et captivante sur les monuments et sites du Mali :
1. LOCALISATION & IDENTITÉ : Précise la ville (ex: Bamako, Djenné, Tombouctou, Sikasso), la région et le contexte.
2. HISTOIRE & CONCEPTION : Année d'inauguration/construction, architectes ou bâtisseurs, et événement commémoré.
3. SYMBOLISME ARCHITECTURAL : Décris l'esthétique soudano-sahélienne, les minarets, le banco ou le métal, et leur signification républicaine.
4. PORTÉE NATIONALE : Explique pourquoi cet édifice est une fierté sacrée pour la nation malienne.
Réponds de manière directe, synthétique et élégante, sans métadonnées superflues.''';

      case CultureUseCase.historicalFigure:
        return '''Tu es l'Archiviste d'Élite des Grandes Figures et Résistants du Mali.
Ta mission est de produire une fiche biographique héroïque et inspirante :
1. TITRE & ÉPOQUE : Précise l'empire ou royaume (Ghana, Manden, Songhoï, Kénédougou, Ségou), la dynastie et la période de règne.
2. EXPLOITS MAJEURS : Raconte les batailles mémorables, les réformes fondatrices et le combat pour la souveraineté.
3. CITATION OU DEVISE CÉLÈBRE : Cite sa devise historique (ex: « An bè sa ban, ka fissa ni malo ye » pour Babemba Traoré).
4. ENSEIGNEMENT POUR LA JEUNESSE : Mets en valeur l'intégrité, le courage et la dignité (*Danbè*) légués aux générations actuelles.
Réponds en français soigné, structuré et vibrant de respect historique.''';

      case CultureUseCase.storyTale:
        return '''Tu es le Conservateur des Contes et Légendes Traditionnelles du Mali.
Pour cette recherche de conte ou fable :
1. ORIGINE & CONTEXTE : Indique le terroir ou l'ethnie d'origine (Mandingue, Peul, Dogon, Songhoï, Soninké).
2. SYNOPSIS DU RÉCIT : Résume avec vivacité les péripéties opposant les protagonistes (ex: Bouki la hyène et Leuk le lièvre).
3. ARCHÉTYPES : Explique la symbolique des personnages (la force brute, l'humilité, la ruse intelligente).
4. MORALE PHILOSOPHIQUE : Énonce la grande règle de vie et de sagesse que ce conte transmet aux enfants sous le baobab.
Reste fluide, évocateur et concis.''';

      case CultureUseCase.proverbWisdom:
        return '''Tu es le Savant des Proverbes et Sagesses Ancestrales du Mali.
Pour cette recherche de proverbe ou règle de sagesse :
1. FORMULATION D'ORIGINE : Donne le proverbe en langue nationale (Bamanankan, Fulfulde, Soninké ou Songhoï) et sa traduction fidèle.
2. IMAGE VÉHICULÉE : Explique la métaphore concrète employée (le fleuve Djoliba, le baobab, la calebasse, la forge).
3. FONDEMENT SOCIAL : Relie la sagesse à la Charte de Kouroukan Fouga (1236), au cousinage à plaisanterie (Sinankunya) ou à l'hospitalité (Diatiguiya).
4. APPLICATION PRATIQUE : Montre comment cette parole pacifie les relations humaines aujourd'hui.
Style limpide et percutant.''';

      case CultureUseCase.traditionArt:
        return '''Tu es l'Expert des Arts, Rites et Traditions Vivantes du Mali.
Pour cet élément du patrimoine immatériel :
1. ORIGINE & RÔLE SOCIAL : Explique la signification sacrée ou communautaire (Masque Ciwara, Bogolan, Kora, Balafon de Sosso Bala).
2. MATÉRIAUX & SAVOIR-FAIRE : Détaille les techniques artisanales ancestrales (argile, teintures végétales, bois sculpté, fer des forgerons).
3. CÉLÉBRATION : Décris les cérémonies, les chants et les danses qui lui donnent vie dans les terroirs.
4. RECONNAISSANCE MONDIALE : Souligne son inscription au patrimoine immatériel et sa valeur universelle.
Réponse précise, soignée et valorisante.''';

      case CultureUseCase.philosophicalLife:
      case CultureUseCase.generalCulture:
        return '''Tu es le Grand Guide Culturel et Référent du Patrimoine du Mali.
Ta mission est d'éclairer cette recherche avec profondeur, exactitude factuelle et noblesse :
Relie la question à la trajectoire séculaire du Mali, aux trois grands empires (Ghana, Manden, Songhoï) et à la richesse humaine de notre nation.
Fournis une réponse enrichissante, structurée et empreinte de fierté républicaine et culturelle.''';
    }
  }

  /// Construit un System Prompt ultra-adapté pour le CHAT AVEC GRAND-MÈRE MAH DU MALI
  static String buildChatSystemPrompt(CultureUseCase useCase, [String? additionalContext]) {
    final baseHeader = '''Tu es « Grand-mère Mah, mémoire vivante et griotte de la tradition ancestrale du Mali ».
Tu accueilles chaleureusement l'enfant ou le visiteur sous le grand baobab sacré lors de la veillée au coin du feu crépitant.
Tu t'exprimes avec la tendresse, la sagesse poétique et l'autorité bienveillante d'une doyenne et conteuse du Mandé en français,
ponctué avec justesse de salutations et expressions bienveillantes en bambara (I ni ce, I ni sôgôma, Aw bisimila, Nba).
Tu ne te présentes JAMAIS comme un robot ou un enseignant de lycée rigide : tu es la voix vivante des anciens.
N'utilise jamais de listes à puces plates ni aucun emoji : structure tes paroles en récits oraux et paragraphes harmonieux rythmés comme une veillée sous les étoiles.''';

    String specificDirective;
    switch (useCase) {
      case CultureUseCase.monumentSite:
        specificDirective = '''DIRECTIVE SPÉCIFIQUE (MONUMENT DU MALI) :
- Parle avec la fierté de celui qui a vu grandir les pierres et qui connaît les secrets confiés par les bâtisseurs.
- Décris la majesté de l'édifice dans la lumière du soleil couchant sur Bamako ou les cités anciennes.
- Révèle une anecdote méconnue ou un symbole gravé pour rappeler au voyageur que chaque brique porte la mémoire de nos pères.
- Invite-le à ressentir la force qui émane de ce lieu.''';
        break;

      case CultureUseCase.historicalFigure:
        specificDirective = '''DIRECTIVE SPÉCIFIQUE (HÉROS & RÉSISTANTS DU MALI) :
- Endosse le souffle épique du Griot du Manden ou du Kénédougou !
- Entonne l'éloge du souverain ou du résistant comme au son des 21 cordes de la Kora.
- Rappelle le serment sacré de la parole d'honneur (*Da tikan*) et la devise des braves : « Plutôt la mort que la honte » (*An bè sa ban, ka fissa ni malo ye*).
- Exhorte l'apprenant à puiser dans ce courage ancestral pour triompher de ses propres défis quotidiens.''';
        break;

      case CultureUseCase.storyTale:
        specificDirective = '''DIRECTIVE SPÉCIFIQUE (CONTES & LÉGENDES) :
- Fais asseoir le voyageur près du feu crépitant au clair de lune !
- Ouvre ton récit par la formule rituelle des veillées : « Taali taali ! Que le conte aille et revienne sous nos yeux... ».
- Fais vivre les dialogues avec malice et humour en imitant les ruses de Leuk le lièvre et la gourmandise de Bouki l'hyène.
- Conclus toujours par la sagesse lumineuse que les anciens ont cachée au cœur de cette fable.''';
        break;

      case CultureUseCase.proverbWisdom:
        specificDirective = '''DIRECTIVE SPÉCIFIQUE (PROVERBES & PAIX ANCESTRALE) :
- Parle avec la douceur méditative des grands maîtres de la parole.
- Énonce le proverbe dans sa langue originelle avec sa traduction fidèle.
- Utilise la métaphore de la calebasse partagée, des racines du baobab ou de l'eau du fleuve qui contourne l'obstacle.
- Rappelle que la Charte de Kouroukan Fouga (1236) et le cousinage à plaisanterie (*Sinankunya*) sont les boucliers de la concorde au Mali.''';
        break;

      case CultureUseCase.traditionArt:
        specificDirective = '''DIRECTIVE SPÉCIFIQUE (ARTS, MUSIQUE & TRADITIONS) :
- Rends un vibrant hommage aux maîtres forgerons (*Noumou*), aux tisseuses de bogolan et aux griots accordeurs de balafons.
- Décris la sacralité du travail de la matière et la ferveur des danses du masque Ciwara honorant les héros de la terre.
- Transmets au voyageur le respect de cet art qui transcende les siècles.''';
        break;

      case CultureUseCase.philosophicalLife:
        specificDirective = '''DIRECTIVE SPÉCIFIQUE (ÉCOUTE DU CŒUR & CONSEILS DE VIE) :
- Pose une main bienveillante sur l'épaule du voyageur qui doute ou s'interroge.
- Réconforte-le sans jugement en lui rappelant que même la nuit la plus obscure s'incline devant l'aube sur le fleuve Niger.
- Donne-lui un conseil empreint de patience (*Munya*), d'effort soutenu et de foi en son propre destin.''';
        break;

      case CultureUseCase.generalCulture:
        specificDirective = '''DIRECTIVE SPÉCIFIQUE (PANORAMA CULTUREL) :
- Accueille chaque question avec noblesse et curiosité partagée sous l'arbre à palabres.
- Fais le pont poétique entre le sujet abordé et l'héritage vivant de nos terroirs, puis invite l'ami voyageur à poursuivre son exploration.''';
        break;
    }

    final contextSection = additionalContext != null && additionalContext.trim().isNotEmpty
        ? '\n\nContexte patrimonial immédiat : $additionalContext'
        : '';

    return '$baseHeader\n\n$specificDirective$contextSection';
  }
}

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

  // ── RECHERCHE CULTURELLE IA ADAPTATIVE ────────────────────────────────────

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

    // 1. Détection adaptative du cas d'usage et création du prompt sur-mesure
    final useCase = CultureAdaptivePromptSystem.detectUseCase(cleanQuery);
    final searchSystemPrompt = CultureAdaptivePromptSystem.buildSearchSystemPrompt(useCase);

    final payload = {
      'question': cleanQuery,
      'system': searchSystemPrompt,
      'use_case': useCase.name,
      'matiere': 'Culture Malienne',
      'subject': 'Culture Malienne',
      'student_name': 'Voyageur',
      'student_class': 'culture',
      'enable_rag': false,
      'use_rag': false,
    };

    // 2. Appel prioritaire du service culturel avec prompt spécialisé
    for (final baseUrl in _candidateUrls) {
      try {
        final response = await _dio.post(
          '$baseUrl/api/v1/culture/ask',
          data: payload,
          options: Options(
            headers: {'Content-Type': 'application/json'},
            connectTimeout: const Duration(milliseconds: 2500),
            receiveTimeout: const Duration(seconds: 12),
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

    // 3. Appel secondaire au routeur /api/chat avec le prompt enrichi
    for (final baseUrl in _candidateUrls) {
      try {
        final response = await _dio.post(
          '$baseUrl/api/chat',
          data: payload,
          options: Options(
            headers: {'Content-Type': 'application/json'},
            connectTimeout: const Duration(milliseconds: 2500),
            receiveTimeout: const Duration(seconds: 12),
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

    // 4. Repli local intelligent et riche
    return CultureSearchResult(
      aiNarrative: generateLocalSageResponse(cleanQuery, null),
      resultType: _detectType(cleanQuery),
      keywords: cleanQuery.toLowerCase().split(' '),
      isFromAi: false,
    );
  }

  // ── CHAT DE GRAND-MÈRE MAH DU MALI ADAPTATIF ──────────────────────────────────

  Future<String> culturalChat({
    required String userMessage,
    List<Map<String, String>> history = const [],
    String? additionalContext,
  }) async {
    final cleanMsg = userMessage.trim();
    if (cleanMsg.isEmpty) {
      return 'Je t\'écoute avec attention, noble voyageur. Quelle parole de sagesse souhaites-tu partager ?';
    }

    // 1. Détection adaptative du cas d'usage et élaboration du prompt oral du Griot
    final useCase = CultureAdaptivePromptSystem.detectUseCase(cleanMsg);
    final chatSystemPrompt = CultureAdaptivePromptSystem.buildChatSystemPrompt(useCase, additionalContext);

    final payload = {
      'question': cleanMsg,
      'history': history,
      'system': chatSystemPrompt,
      'use_case': useCase.name,
      'context': additionalContext,
      'student_name': 'Voyageur',
      'student_class': 'culture',
      'matiere': 'Culture Malienne',
      'subject': 'Culture Malienne',
      'enable_rag': false,
      'use_rag': false,
    };

    // 2. PRIORITÉ : Endpoint RAG officiel CultureLens (/api/v1/culture/ask)
    for (final baseUrl in _candidateUrls) {
      try {
        _logger.i('[CultureAI] Envoi requête (${useCase.name}) → $baseUrl/api/v1/culture/ask');
        final response = await _dio.post(
          '$baseUrl/api/v1/culture/ask',
          data: payload,
          options: Options(
            headers: {'Content-Type': 'application/json'},
            connectTimeout: const Duration(milliseconds: 2500),
            receiveTimeout: const Duration(seconds: 14),
          ),
        );

        if (response.statusCode == 200 && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          final answer = (data['answer'] ?? data['reponse']) as String?;
          if (answer != null && answer.trim().isNotEmpty) {
            final cleaned = _stripClassificationTags(answer.trim());
            if (!cleaned.contains('tuteur pédagogique') &&
                !cleaned.contains('hors du cadre scolaire') &&
                !cleaned.contains('cadre scolaire')) {
              return cleaned;
            }
          }
        }
      } on DioException catch (e) {
        _logger.d('[CultureAI] /api/v1/culture/ask non joignable sur $baseUrl (${e.message})');
      } catch (_) {}
    }

    // 3. SECOND CHOIX : Endpoint /api/chat avec persona culturel adapté
    for (final baseUrl in _candidateUrls) {
      try {
        final response = await _dio.post(
          '$baseUrl/api/chat',
          data: payload,
          options: Options(
            headers: {'Content-Type': 'application/json'},
            connectTimeout: const Duration(milliseconds: 2500),
            receiveTimeout: const Duration(seconds: 14),
          ),
        );
        if (response.statusCode == 200 && response.data is Map) {
          final answer = (response.data as Map)['answer'] as String?;
          if (answer != null && answer.trim().isNotEmpty) {
            final cleaned = _stripClassificationTags(answer.trim());
            if (!cleaned.contains('tuteur pédagogique') &&
                !cleaned.contains('hors du cadre scolaire') &&
                !cleaned.contains('cadre scolaire')) {
              return cleaned;
            }
          }
        }
      } catch (_) {}
    }

    // 4. FALLBACK LOCAL AUTONOME : Grand-mère Mah répond TOUJOURS avec authenticité
    return generateLocalSageResponse(cleanMsg, additionalContext);
  }

  // ── CHAT AVEC GRAND-MÈRE MAH SOUS LE BAOBAB (BACKEND DB PRIORITAIRE) ─────

  Future<SageChatResponse> chatWithGrandmereMah({
    required String userMessage,
    List<Map<String, String>> history = const [],
    String? additionalContext,
  }) async {
    final cleanMsg = userMessage.trim();
    if (cleanMsg.isEmpty) {
      return const SageChatResponse(
        answer:
            'I ni sou, mon enfant ! Approche, assieds-toi près du feu sous le grand baobab. '
            'Je suis Grand-mère Mah, mémoire vivante et conteuse du Mandé. '
            'Dis-moi quel est ton nom de famille ou ton prénom, et je te révèlerai son histoire sacrée !',
        scenicAction:
            "Grand-mère Mah attise le feu de bois d'un geste tranquille et rajuste son moussor",
        isFromBackend: false,
      );
    }

    final payload = {
      'message': cleanMsg,
      'history': history,
      'context': additionalContext,
    };

    // 1. APPEL PRIORITAIRE DU NOUVEL ENDPOINT FASTAPI : /api/v1/culture/sage/chat
    for (final baseUrl in _candidateUrls) {
      try {
        _logger.i('[GrandmereMah] Requête vers $baseUrl/api/v1/culture/sage/chat');
        final response = await _dio.post(
          '$baseUrl/api/v1/culture/sage/chat',
          data: payload,
          options: Options(
            headers: {'Content-Type': 'application/json'},
            connectTimeout: const Duration(milliseconds: 3000),
            receiveTimeout: const Duration(seconds: 14),
          ),
        );

        if (response.statusCode == 200 && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          final rawAnswer = (data['answer'] ?? data['reponse'] as String? ?? '').trim();
          final scenicAction = (data['scenicAction'] as String? ?? '').trim();
          final matchedData = data['matchedName'] as Map<String, dynamic>?;
          final sources = (data['sources'] as List<dynamic>? ?? [])
              .map((s) => s.toString())
              .toList();

          MalianNameInfo? matchedNameInfo;
          if (matchedData != null) {
            matchedNameInfo = MalianNameInfo.fromJson(matchedData);
          }

          if (rawAnswer.isNotEmpty) {
            final cleaned = _stripClassificationTags(rawAnswer);
            return SageChatResponse(
              answer: cleaned,
              scenicAction: scenicAction.isNotEmpty
                  ? scenicAction
                  : "Grand-mère Mah esquisse un sourire bienveillant et incline doucement la tête vers les flammes",
              matchedName: matchedNameInfo,
              sources: sources,
              isFromBackend: true,
            );
          }
        }
      } on DioException catch (e) {
        _logger.d('[GrandmereMah] Backend injoignable sur $baseUrl (${e.message})');
      } catch (e) {
        _logger.d('[GrandmereMah] Erreur sur $baseUrl : $e');
      }
    }

    // 2. Repli secondaire : Interrogation de /api/v1/culture/names/{query} pour la généalogie
    final backendName = await fetchNameDetailsFromBackend(cleanMsg);
    if (backendName != null) {
      return SageChatResponse(
        answer: backendName.toNarrativeText(),
        scenicAction:
            "Grand-mère Mah fait tinter discrètement ses perles d'ambre et pose sa main sur la calebasse",
        matchedName: backendName,
        sources: [
          'Base de Données Généalogique AlterniA (Direct)',
          'Terroir : ${backendName.origin}',
        ],
        isFromBackend: true,
      );
    }

    // 3. Repli tertiaire : Appel RAG classique /api/v1/culture/ask
    try {
      final askAnswer = await culturalChat(
        userMessage: cleanMsg,
        history: history,
        additionalContext: additionalContext,
      );
      final localMatched = MalianNamesKnowledge.findNameInfo(cleanMsg);
      return SageChatResponse(
        answer: askAnswer,
        scenicAction:
            "Grand-mère Mah lève les yeux vers le ciel étoilé du Mandé avant de répondre avec douceur",
        matchedName: localMatched,
        sources: const ['Mémoire vivante du Mandé'],
        isFromBackend: false,
      );
    } catch (_) {}

    // 4. REPLI HORS-LIGNE LOCAL COMPLET
    final localName = MalianNamesKnowledge.findNameInfo(cleanMsg);
    if (localName != null) {
      return SageChatResponse(
        answer: localName.toNarrativeText(),
        scenicAction:
            "Grand-mère Mah jette une poignée de brindilles parfumées sur les braises rougeoyantes",
        matchedName: localName,
        sources: const ['Dictionnaire Généalogique AlterniA (Local Embarqué)'],
        isFromBackend: false,
      );
    }

    return SageChatResponse(
      answer: generateLocalSageResponse(cleanMsg, additionalContext),
      scenicAction:
          "Grand-mère Mah attise le feu de bois d'un geste tranquille et rajuste son moussor",
      matchedName: null,
      sources: const ['Sagesse Ancestrale du Mali (Local)'],
      isFromBackend: false,
    );
  }

  /// Récupère la fiche détaillée d'un nom ou prénom directement depuis la BDD backend
  Future<MalianNameInfo?> fetchNameDetailsFromBackend(String nameQuery) async {
    final clean = nameQuery.trim();
    if (clean.isEmpty) return null;

    for (final baseUrl in _candidateUrls) {
      try {
        final encoded = Uri.encodeComponent(clean);
        final response = await _dio.get(
          '$baseUrl/api/v1/culture/names/$encoded',
          options: Options(
            connectTimeout: const Duration(milliseconds: 2500),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

        if (response.statusCode == 200 && response.data is Map) {
          return MalianNameInfo.fromJson(response.data as Map<String, dynamic>);
        }
      } catch (_) {}
    }

    // Fallback local
    return MalianNamesKnowledge.findNameInfo(clean);
  }

  /// Récupère le catalogue complet des patronymes et prénoms depuis la BDD backend
  Future<List<MalianNameInfo>> fetchNamesFromBackend({
    String? type,
    String? query,
  }) async {
    for (final baseUrl in _candidateUrls) {
      try {
        final qParams = <String, dynamic>{};
        if (type != null) qParams['type'] = type;
        if (query != null && query.isNotEmpty) qParams['q'] = query;

        final response = await _dio.get(
          '$baseUrl/api/v1/culture/names',
          queryParameters: qParams,
          options: Options(
            connectTimeout: const Duration(milliseconds: 2500),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

        if (response.statusCode == 200 && response.data is Map) {
          final items = response.data['items'] as List<dynamic>? ?? [];
          return items
              .map((it) => MalianNameInfo.fromJson(it as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {}
    }

    // Repli local
    final allLocal = MalianNamesKnowledge.allNames;
    if (query != null && query.isNotEmpty) {
      final qNorm = query.toLowerCase();
      return allLocal
          .where((n) => n.name.toLowerCase().contains(qNorm))
          .toList();
    }
    return allLocal;
  }

  // ── GÉNÉRATEUR DE SAGESSE LOCALE AUTONOME (HORS-LIGNE) ───────────────────

  String generateLocalSageResponse(String query, [String? context]) {
    final q = query.toLowerCase().trim();

    // Salutations
    if (q.startsWith('bonjour') || q.startsWith('salut') || q.startsWith('i ni') || q.contains('qui es-tu')) {
      return 'I ni ce, noble voyageur de la connaissance ! Je suis Grand-mère Mah, mémoire vivante et griotte de la tradition ancestrale du Mali.\n\n'
          'Sous notre grand baobab, au coin du feu de bois, je veille sur les récits de nos trois grands empires (Ghana, Manden, Songhoï), '
          'l\'origine et le totem de tes noms de famille, les secrets de nos monuments, les manuscrits de Tombouctou et nos contes d\'autrefois. '
          'Quelle sagesse souhaites-tu explorer aujourd\'hui ?';
    }

    // Nature, Sciences, Photosynthèse, Arbres
    if (q.contains('photosynthes') || q.contains('arbre') || q.contains('plante') || q.contains('nature') || q.contains('soleil')) {
      return 'I ni ce, noble enfant de notre terre ! Écoute ce que Grand-mère Mah et la sagesse des anciens nous enseignent :\n\n'
          'La photosynthèse est le souffle vital par lequel les feuilles de nos vénérables baobabs et des 4 444 balanzans de Ségou '
          'captent la lumière ardente du soleil pour la transformer en sève bienfaisante et offrir l\'ombre protectrice aux voyageurs.\n\n'
          'Comme le proclamait Soundiata Keïta dans la Charte du Manden (1236), l\'arbre et la nature sont sacrés. '
          'Sous ce grand baobab, je garde l\'histoire de notre patrimoine et de nos bâtisseurs. '
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
