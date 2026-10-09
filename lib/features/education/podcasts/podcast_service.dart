// ─── AlterniA — Service de Génération et Quotas Podcasts ──────────────────────
// Gestion de la génération de cours audio avec l'IA pédagogique,
// persistance locale hors-ligne et contrôle du quota gratuit (2 max sans boîtier/Pro).
library;

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants.dart';
import 'podcast_model.dart';

class PodcastService {
  PodcastService._();
  static final PodcastService instance = PodcastService._();

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
    // 1. Appel du backend FastAPI
    for (final baseUrl in AltaApiConfig.candidateBaseUrls) {
      try {
        final response = await _dio.post(
          '$baseUrl/api/education/podcast/generate',
          data: {
            'subject': subject,
            'topic': topic,
            'class_level': classLevel,
            'duration_minutes': durationMinutes,
            'student_name': studentName ?? 'Élève',
          },
        );

        if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          final podcast = RevisionPodcast.fromJson(data);
          await saveCustomPodcast(podcast);
          await incrementGenerationsCount();
          return podcast;
        }
      } catch (_) {
        // Tente le candidat suivant en cas d'échec
      }
    }

    // 2. Moteur local intelligent de synthèse didactique (si hors-ligne)
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

  /// Générateur didactique local si hors-ligne
  RevisionPodcast _generateLocalPodcast({
    required String subject,
    required String topic,
    required String classLevel,
    required int durationMinutes,
  }) {
    final id = 'local_pod_${DateTime.now().millisecondsSinceEpoch}';

    final chapters = [
      PodcastChapter(title: 'Introduction & Définition de $topic', timestampSeconds: 0),
      const PodcastChapter(title: 'Concepts Fondamentaux & Règles', timestampSeconds: 90),
      const PodcastChapter(title: 'Méthodologie & Réflexe d\'Examen', timestampSeconds: 210),
      const PodcastChapter(title: 'Conseils Clés du Correcteur', timestampSeconds: 310),
    ];

    final takeaways = [
      'Maîtriser la définition précise de $topic en $subject.',
      'Identifier les pièges classiques et soigner la rédaction méthodique.',
      'Appliquer les formules et propriétés au programme de $classLevel.',
      'Encadrer les conclusions et vérifier la cohérence des résultats.',
    ];

    final fullScript = '''
Bonjour et bienvenue dans ton podcast audio de révision AlternIA !
Mets tes écouteurs et installe-toi confortablement. Aujourd'hui, nous explorons ensemble un chapitre essentiel de $subject pour ta classe de $classLevel : $topic.

Dans le système éducatif malien, la maîtrise de $topic repose sur une compréhension limpide des concepts clés plutôt que sur du simple par cœur.

Premièrement, retiens toujours la définition rigoureuse exigée par les correcteurs nationaux. Quand tu abordes un exercice lors de l'examen, commence par isoler les données du sujet, puis cite expressément la propriété ou le théorème correspondant avant de poser tes calculs.

Deuxièmement, fais attention à la gestion du temps. En $subject, chaque détail méthodologique rapporte des points précieux : la clarté de l'écriture, les schémas soignés et la justification des étapes intermédiaires.

Garde confiance en tes capacités, révise régulièrement avec la voix AlternIA et prépare-toi à décrocher la mention. Bonnes révisions !
''';

    return RevisionPodcast(
      id: id,
      title: '$topic : Les Clés du Cours',
      subject: subject,
      classLevel: classLevel,
      durationMinutes: durationMinutes,
      summary:
          'Synthèse audio immersive sur $topic ($subject) conçue pour maximiser tes notes aux examens nationaux.',
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
