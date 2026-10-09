// ─── AlterniA — Service de Génération et Quotas Podcasts ──────────────────────
// Gestion de la génération de cours audio avec l'IA pédagogique,
// persistance locale hors-ligne et contrôle du quota gratuit (2 max sans boîtier/Pro).
library;

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import 'podcast_model.dart';

class PodcastService {
  PodcastService._();
  static final PodcastService instance = PodcastService._();

  final _logger = Logger();
  static const int maxFreeGenerations = 2;
  static const String _keyGenCount = 'alternia_podcast_generations_count';
  static const String _keyCustomPodcasts = 'alternia_custom_podcasts_list';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  /// Récupère le nombre de podcasts générés par l'utilisateur
  Future<int> getGenerationsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyGenCount) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Incrémente le compteur de génération
  Future<void> incrementGenerationsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(_keyGenCount) ?? 0;
      await prefs.setInt(_keyGenCount, current + 1);
    } catch (_) {}
  }

  /// Vérifie si l'utilisateur possède la version Pro ou un boîtier connecté
  Future<bool> isUserPro({bool isDeviceConnected = false}) async {
    if (isDeviceConnected) return true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPremium = prefs.getBool('alternia_premium_unlocked') ?? false;
      final code = prefs.getString('alternia_premium_code');
      return isPremium && code != null && code.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Vérifie si l'utilisateur peut générer un podcast
  Future<bool> canGeneratePodcast({bool isDeviceConnected = false}) async {
    final isPro = await isUserPro(isDeviceConnected: isDeviceConnected);
    if (isPro) return true;
    final count = await getGenerationsCount();
    return count < maxFreeGenerations;
  }

  /// Charge tous les podcasts personnalisés enregistrés localement
  Future<List<RevisionPodcast>> loadCustomPodcasts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonListStr = prefs.getString(_keyCustomPodcasts);
      if (jsonListStr == null || jsonListStr.isEmpty) return [];
      final List<dynamic> decoded = jsonDecode(jsonListStr) as List<dynamic>;
      return decoded
          .map((item) => RevisionPodcast.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Enregistre un nouveau podcast dans le catalogue local
  Future<void> saveCustomPodcast(RevisionPodcast podcast) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await loadCustomPodcasts();
      existing.removeWhere((p) => p.id == podcast.id);
      existing.insert(0, podcast);
      final jsonList = existing.map((p) => p.toJson()).toList();
      await prefs.setString(_keyCustomPodcasts, jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Supprime un podcast personnalisé
  Future<void> deleteCustomPodcast(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await loadCustomPodcasts();
      existing.removeWhere((p) => p.id == id);
      final jsonList = existing.map((p) => p.toJson()).toList();
      await prefs.setString(_keyCustomPodcasts, jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Génère un nouveau podcast pédagogique par l'IA
  Future<RevisionPodcast> generatePodcast({
    required String subject,
    required String topic,
    required String classLevel,
    String? studentName,
    int durationMinutes = 6,
  }) async {
    // 1. Détection rapide de l'URL active du backend AlternIA
    String? activeUrl;
    for (final base in AltaApiConfig.candidateBaseUrls) {
      try {
        final check = await _dio.get(
          '$base/api/health',
          options: Options(
            connectTimeout: const Duration(milliseconds: 2500),
            receiveTimeout: const Duration(milliseconds: 2500),
          ),
        );
        if (check.statusCode == 200 &&
            check.data is Map &&
            check.data['status'] == 'healthy') {
          activeUrl = base;
          break;
        }
      } catch (_) {}
    }

    if (activeUrl != null) {
      try {
        final response = await _dio.post(
          '$activeUrl/api/education/podcast/generate',
          data: {
            'subject': subject,
            'topic': topic,
            'class_level': classLevel,
            'duration_minutes': durationMinutes,
            'student_name': studentName ?? 'Élève',
          },
          options: Options(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 50),
          ),
        );

        if (response.statusCode == 200 && response.data is Map) {
          final data = Map<String, dynamic>.from(response.data as Map);
          final podcast = RevisionPodcast.fromJson(data);
          await saveCustomPodcast(podcast);
          await incrementGenerationsCount();
          return podcast;
        }
      } catch (e) {
        _logger.w('[PodcastService] Erreur appel API IA backend : $e');
      }
    }

    // 2. Moteur local intelligent adapté au programme malien (si hors-ligne)
    final fallbackPodcast = _generateLocalPodcast(
      subject: subject,
      topic: topic,
      classLevel: classLevel,
      durationMinutes: durationMinutes,
    );

    await saveCustomPodcast(fallbackPodcast);
    await incrementGenerationsCount();
    return fallbackPodcast;
  }

  /// Générateur didactique local si hors-ligne (strictement contextualisé à la matière)
  RevisionPodcast _generateLocalPodcast({
    required String subject,
    required String topic,
    required String classLevel,
    required int durationMinutes,
  }) {
    final id = 'local_pod_${DateTime.now().millisecondsSinceEpoch}';
    final subLower = subject.toLowerCase();

    String fullScript;
    List<PodcastChapter> chapters;
    List<String> takeaways;

    if (subLower.contains('litt') || subLower.contains('fran')) {
      chapters = [
        PodcastChapter(
            title: 'Introduction & Problématique : $topic',
            timestampSeconds: 0),
        const PodcastChapter(
            title: 'Analyse Littéraire & Figures de Style',
            timestampSeconds: 90),
        const PodcastChapter(
            title: 'Méthodologie du Commentaire & Dissertation',
            timestampSeconds: 210),
        const PodcastChapter(
            title: 'Conseils de Rédaction pour l\'Examen',
            timestampSeconds: 310),
      ];
      takeaways = [
        'Dégager la vision de l\'auteur et la portée philosophique de $topic.',
        'Repérer et analyser les figures de style et procédés d\'écriture.',
        'Structurer l\'argumentation littéraire avec des citations précises.',
        'Soigner impérativement l\'expression écrite et la syntaxe pour le Bac.',
      ];
      fullScript = '''
Bonjour et bienvenue dans ton podcast audio de révision AlternIA !
Mets tes écouteurs et installe-toi confortablement. Aujourd'hui, nous explorons ensemble un chapitre essentiel de $subject pour ta classe de $classLevel : $topic.

Dans le système éducatif malien, la réussite en littérature et expression française repose sur la finesse de l'analyse textuelle et la rigueur de l'argumentation. Ne te contente jamais de résumer l'intrigue d'une œuvre.

Premièrement, pour la dissertation ou le commentaire composé, définis les termes du sujet, dégage la problématique centrale de l'auteur et annonce un plan équilibré en deux ou trois parties.

Deuxièmement, appuie chaque idée sur des citations textuelles analysées avec soin : identifie les figures de style, le registre de langue et les effets de sens recherchés par l'auteur.

Soigne ta copie avec des transitions fluides et une écriture soignée. Garde confiance en tes capacités et prépare-toi à décrocher la mention !
''';
    } else if (subLower.contains('hist') || subLower.contains('géo')) {
      chapters = [
        PodcastChapter(
            title: 'Contexte Historique : $topic', timestampSeconds: 0),
        const PodcastChapter(
            title: 'Causes & Dynamiques Majeures', timestampSeconds: 90),
        const PodcastChapter(
            title: 'Conséquences & Impact pour le Mali', timestampSeconds: 210),
        const PodcastChapter(
            title: 'Méthode d\'Examen en Histoire-Géo', timestampSeconds: 310),
      ];
      takeaways = [
        'Maîtriser les dates et repères chronologiques essentiels de $topic.',
        'Expliquer les causes politiques, économiques et sociales sous-jacentes.',
        'Illustrer chaque argument par des faits historiques ou données géographiques avérées.',
        'Rédiger une conclusion synthétique ouvrant sur les perspectives actuelles.',
      ];
      fullScript = '''
Bonjour et bienvenue dans ton podcast audio de révision AlternIA !
Mets tes écouteurs et installe-toi confortablement. Aujourd'hui, nous abordons un chapitre clé d'Histoire-Géographie pour ta classe de $classLevel : $topic.

Pour les examens officiels au Mali, la réussite exige de dépasser la simple récitation. Il faut mettre en lumière les causes, les tournants décisifs et les conséquences durables des événements.

Premièrement, situe précisément les faits dans le temps et dans l'espace. Utilise un vocabulaire historique et géographique rigoureux.

Deuxièmement, structure ton argumentation en reliant chaque fait à une explication causale claire. Illustre chaque partie par des repères concrets du programme officiel malien.

Révise régulièrement les cartes et chronologies avec AlternIA et bon courage pour tes examens !
''';
    } else if (subLower.contains('socio') || subLower.contains('social')) {
      chapters = [
        PodcastChapter(
            title: 'Notions & Cadre Sociologique : $topic',
            timestampSeconds: 0),
        const PodcastChapter(
            title: 'Théories Fondatrices & Auteurs Clés',
            timestampSeconds: 90),
        const PodcastChapter(
            title: 'Application aux Réalités du Mali',
            timestampSeconds: 210),
        const PodcastChapter(
            title: 'Méthodologie de la Dissertation au Bac',
            timestampSeconds: 310),
      ];
      takeaways = [
        'Traiter les faits sociaux comme des choses objectives (Durkheim).',
        'Comprendre les processus de socialisation et les mutations statutaires.',
        'Relier les théories aux transformations familiales et urbaines du Mali.',
        'Rédiger une argumentation neutre et exempte de préjugés.',
      ];
      fullScript = '''
Bonjour et bienvenue dans ton podcast audio de révision AlternIA !
Aujourd'hui en Sociologie Générale, nous approfondissons un thème incontournable de $subject pour ta classe de $classLevel : $topic.

La sociologie nous apprend à regarder au-delà des évidences du quotidien. Elle étudie les régularités collectives, les normes intériorisées et les rapports sociaux.

Pour réussir ton épreuve du Bac : commence par définir rigoureusement le concept central, cite les sociologues de référence (Durkheim, Weber, Bourdieu), puis illustre chaque thèse par des dynamiques observables dans la société malienne contemporaine.
''';
    } else if (subLower.contains('droit') || subLower.contains('institut') || subLower.contains('jurid')) {
      chapters = [
        PodcastChapter(
            title: 'Cadre Juridique & Définitions : $topic',
            timestampSeconds: 0),
        const PodcastChapter(
            title: 'Hiérarchie des Normes & Constitution',
            timestampSeconds: 90),
        const PodcastChapter(
            title: 'Fonctionnement des Institutions Publiques',
            timestampSeconds: 210),
        const PodcastChapter(
            title: 'Méthode du Cas Pratique & Syllogisme',
            timestampSeconds: 310),
      ];
      takeaways = [
        'Identifier la norme juridique applicable et sa place dans la hiérarchie.',
        'Comprendre le principe républicain de la séparation des pouvoirs.',
        'Employer le lexique juridique exact requis par les correcteurs.',
        'Appliquer le syllogisme juridique pour résoudre chaque question.',
      ];
      fullScript = '''
Bonjour et bienvenue dans ta session audio AlternIA de Droit et Institutions pour la classe de $classLevel.
Aujourd'hui, nous abordons les principes essentiels régissant : $topic.

Dans un État de droit, la Constitution est la norme suprême qui encadre l'action publique et garantit les libertés citoyennes. Chaque règle de droit tire sa force de la pyramide des normes.

Le jour de l'examen : qualifie juridiquement les faits, énonce la règle de droit applicable avec précision, et applique le syllogisme sans précipitation.
''';
    } else if (subLower.contains('polit')) {
      chapters = [
        PodcastChapter(
            title: 'Enjeux Politiques & Problématique : $topic',
            timestampSeconds: 0),
        const PodcastChapter(
            title: 'L\'État, le Pouvoir & la Démocratie',
            timestampSeconds: 90),
        const PodcastChapter(
            title: 'Souveraineté & Intégration Sahélienne (AES)',
            timestampSeconds: 210),
        const PodcastChapter(
            title: 'Conseils pour l\'Épreuve du Bac',
            timestampSeconds: 310),
      ];
      takeaways = [
        'Analyser les mécanismes du pouvoir et de la légitimité de l\'État.',
        'Comprendre le rôle des partis et la participation des citoyens.',
        'Mobiliser les enjeux contemporains de l\'Alliance des États du Sahel.',
        'Développer une réflexion critique et documentée sur les institutions.',
      ];
      fullScript = '''
Bonjour et bienvenue dans ton podcast de Science Politique AlternIA ($classLevel).
Aujourd'hui, nous analysons ensemble un enjeu central : $topic.

La science politique décrypte la conquête et l'exercice de l'autorité publique. Selon Max Weber, l'État incarne le monopole de la violence physique légitime.

Dans le contexte actuel de notre pays et du Sahel, l'affirmation de la souveraineté nationale et la solidarité au sein de l'AES ouvrent de nouvelles perspectives géopolitiques majeures. Retiens bien ces repères pour enrichir tes devoirs !
''';
    } else if (subLower.contains('philo')) {
      chapters = [
        PodcastChapter(
            title: 'Problématique Philosophique : $topic',
            timestampSeconds: 0),
        const PodcastChapter(
            title: 'Thèse & Examen Critique',
            timestampSeconds: 90),
        const PodcastChapter(
            title: 'Antithèse & Confrontation d\'Auteurs',
            timestampSeconds: 210),
        const PodcastChapter(
            title: 'Synthèse & Démarche Dialectique',
            timestampSeconds: 310),
      ];
      takeaways = [
        'Dégager le problème philosophique sous-jacent de $topic.',
        'Convoquer les grands philosophes au service de sa propre réflexion.',
        'Articuler les notions de liberté, de conscience et de justice.',
        'Construire un plan dialectique progressif et rigoureux.',
      ];
      fullScript = '''
Bonjour et bienvenue dans ton podcast de Philosophie pour la classe de $classLevel.
Aujourd'hui, nous réfléchissons ensemble sur : $topic.

Philosopher ne consiste pas à réciter des opinions, mais à interroger le sens profond des concepts. Face à ton sujet de dissertation, cherche toujours le paradoxe initial.

Construis ton plan dialectique en examinant d'abord la thèse commune, en lui opposant ses limites ou ses contradictions, puis en proposant un dépassement équilibré.
''';
    } else if (subLower.contains('éco') || subLower.contains('eco') || subLower.contains('ses')) {
      chapters = [
        PodcastChapter(
            title: 'Concepts & Définitions Économiques : $topic',
            timestampSeconds: 0),
        const PodcastChapter(
            title: 'Agrégats, Marché & Mécanismes de Prix',
            timestampSeconds: 90),
        const PodcastChapter(
            title: 'L\'Économie au Mali et dans l\'UEMOA',
            timestampSeconds: 210),
        const PodcastChapter(
            title: 'Méthodologie d\'Analyse Économique au Bac',
            timestampSeconds: 310),
      ];
      takeaways = [
        'Définir rigoureusement les notions de PIB, de croissance et d\'inflation.',
        'Comprendre les politiques monétaires de la BCEAO dans la zone UEMOA.',
        'Souligner l\'importance de l\'agriculture et du secteur informel au Mali.',
        'Exploiter les graphiques et données chiffrées avec précision.',
      ];
      fullScript = '''
Bonjour et bienvenue dans ton podcast d'Économie AlternIA pour ta classe de $classLevel.
Aujourd'hui, nous décryptons ensemble : $topic.

L'économie étudie la production, la répartition et la consommation des richesses. Pour réussir ton épreuve : maîtrise les définitions clés comme le PIB, la productivité et la politique monétaire.

Relie toujours les concepts théoriques à l'environnement économique du Mali : la campagne cotonnière, l'or, les transferts de fonds et la vitalité du secteur informel.
''';
    } else if (subLower.contains('svt') || subLower.contains('biol')) {
      chapters = [
        PodcastChapter(
            title: 'Phénomènes & Mécanismes : $topic', timestampSeconds: 0),
        const PodcastChapter(
            title: 'Démarche Scientifique & Observations',
            timestampSeconds: 90),
        const PodcastChapter(
            title: 'Schémas Fonctionnels Légendés', timestampSeconds: 210),
        const PodcastChapter(
            title: 'Conseils pour l\'Épreuve du Bac', timestampSeconds: 310),
      ];
      takeaways = [
        'Comprendre les mécanismes biologiques et géologiques de $topic.',
        'Appliquer la démarche scientifique : constat, savoir, déduction.',
        'Soigner les schémas légendés avec un titre complet souligné.',
        'Utiliser le lexique biologique exact requis au programme.',
      ];
      fullScript = '''
Bonjour et bienvenue dans ton cours de sciences naturelles AlternIA !
Aujourd'hui, nous décodons ensemble un chapitre essentiel de $subject pour ta classe de $classLevel : $topic.

En SVT au Mali, les correcteurs évaluent ta rigueur scientifique. Chaque réponse doit suivre la démarche déductive : « Je constate que », « Or je sais d'après le cours que », « Donc j'en déduis que ».

Premièrement, distingue bien une observation objective d'une interprétation théorique.

Deuxièmement, pour les schémas de biologie ou de géologie, utilise toujours des flèches nettes, respecte les proportions et donne un titre complet souligné.

Persévère dans tes révisions régulières avec AlternIA et vise l'excellence !
''';
    } else {
      chapters = [
        PodcastChapter(
            title: 'Définitions & Principes Clés : $topic',
            timestampSeconds: 0),
        const PodcastChapter(
            title: 'Formules et Théorèmes Fondamentaux', timestampSeconds: 90),
        const PodcastChapter(
            title: 'Méthodologie et Résolution d\'Exercices',
            timestampSeconds: 210),
        const PodcastChapter(
            title: 'Pièges Fréquents & Réflexes d\'Examen',
            timestampSeconds: 310),
      ];
      takeaways = [
        'Définir rigoureusement les concepts fondamentaux de $topic.',
        'Appliquer les formules clés en précisant les hypothèses de départ.',
        'Justifier chaque étape de calcul ou de raisonnement sur sa copie.',
        'Encadrer les conclusions et résultats avec leurs unités appropriées.',
      ];
      fullScript = '''
Bonjour et bienvenue dans ton podcast audio de révision AlternIA !
Mets tes écouteurs et installe-toi confortablement. Aujourd'hui, nous nous concentrons sur $topic en $subject pour la classe de $classLevel.

Pour exceller aux examens nationaux maliens, la clé réside dans la maîtrise des définitions de base, la rigueur logique et l'application soignée des propriétés fondamentales.

Premièrement, lis toujours l'énoncé attentivement : isole les données, pose clairement tes hypothèses, puis cite la formule ou le théorème correspondant avant de développer tes calculs.

Deuxièmement, justifie chaque étape sans précipitation et vérifie toujours la cohérence de tes résultats finaux.

Garde confiance en tes capacités, révise régulièrement avec la voix AlternIA et prépare-toi au succès !
''';
    }

    return RevisionPodcast(
      id: id,
      title: '$topic : Les Clés du Cours',
      subject: subject,
      classLevel: classLevel,
      durationMinutes: durationMinutes,
      summary:
          'Synthèse audio didactique sur $topic ($subject) pour la classe de $classLevel au Mali.',
      narrator: 'Professeur IA (AlternIA)',
      chapters: chapters,
      keyTakeaways: takeaways,
      fullScript: fullScript,
      icon: RevisionPodcast.iconForSubject(subject),
      accentColor: RevisionPodcast.colorForSubject(subject),
      isCustomGenerated: true,
    );
  }
}
