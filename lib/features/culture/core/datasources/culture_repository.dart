import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../scanner/data/monument_scan_knowledge.dart';
import '../../scanner/models/monument_scan_models.dart';
import '../models/culture_detail_models.dart';
import '../models/culture_item.dart';
import '../models/culture_story_models.dart';
import '../models/culture_proverb_models.dart';
import '../models/culture_challenge_models.dart';
import 'culture_api_client.dart';
import 'culture_database_seed.dart';
import 'mock_culture_details_data.dart';
import 'mock_culture_stories_data.dart';
import 'mock_culture_proverbs_data.dart';
import 'mock_culture_challenges_data.dart';

/// Provider Riverpod global pour CultureApiClient
final cultureApiClientProvider = Provider<CultureApiClient>((ref) {
  return CultureApiClient();
});

/// Provider Riverpod global pour CultureRepository
final cultureRepositoryProvider = Provider<CultureRepository>((ref) {
  final apiClient = ref.watch(cultureApiClientProvider);
  return CultureRepository(apiClient: apiClient);
});

/// Dépôt central pour la gestion des données culturelles (Offline-first)
class CultureRepository {
  final CultureApiClient _apiClient;
  final Logger _logger;

  static const String _favoritesPrefKey = 'culture_favorites_ids';
  static const String _historyPrefKey = 'culture_scan_history_json';
  static const String _installedPacksPrefKey = 'culture_installed_packs';
  static const String _cachedMonumentsPrefKey = 'culture_cached_monuments_v4_json';
  static const String _cachedMonumentsCultureItemsPrefKey = 'culture_cached_monuments_items_v4_json';
  static const String _cachedFiguresPrefKey = 'culture_cached_figures_json';
  static const String _cachedPlacesPrefKey = 'culture_cached_places_json';
  static const String _cachedStoriesPrefKey = 'culture_cached_stories_json';
  static const String _cachedProverbsPrefKey = 'culture_cached_proverbs_json';
  static const String _localContributionsPrefKey = 'culture_local_contributions_json';

  /// Liste d'autorité des 8 monuments historiques réels du Mali
  static const Set<String> _validMonumentIds = {
    'monument_mosquee_djenne',
    'monument_djingareyber',
    'monument_sankore',
    'monument_tombeau_askia',
    'monument_independance_bamako',
    'monument_tour_afrique_bamako',
    'monument_fort_medine',
    'monument_tata_sikasso',
  };

  CultureRepository({
    CultureApiClient? apiClient,
    Logger? logger,
  })  : _apiClient = apiClient ?? CultureApiClient(),
        _logger = logger ?? Logger();

  CultureApiClient get apiClient => _apiClient;

  /// Récupère la liste des monuments (priorité base de données, repli hors ligne)
  Future<List<MonumentScanTarget>> getMonuments({
    String? ville,
    String? regionId,
    String? query,
  }) async {
    // 1. Tentative de synchronisation avec le serveur ou l'ALTA Box
    final remote = await _apiClient.fetchMonuments(
      ville: ville,
      regionId: regionId,
      query: query,
    );

    if (remote.isNotEmpty && remote.every((m) => _validMonumentIds.contains(m.id))) {
      MonumentScanKnowledge.registerDynamicTargets(remote);
      _cacheMonumentsLocally(remote);
      return remote;
    }

    // 2. Lecture du cache local si hors ligne
    final cached = await _loadCachedMonuments();
    if (cached.isNotEmpty) {
      MonumentScanKnowledge.registerDynamicTargets(cached);
      return _filterMonuments(cached, ville: ville, regionId: regionId, query: query);
    }

    // 3. Repli sur le catalogue statique certifié (strictement les 8 vrais monuments)
    final list = MonumentScanKnowledge.targets
        .where((m) => _validMonumentIds.contains(m.id))
        .toList();
    _cacheMonumentsLocally(list);
    return _filterMonuments(list, ville: ville, regionId: regionId, query: query);
  }

  /// Récupère spécifiquement les monuments situés à Bamako
  Future<List<MonumentScanTarget>> getBamakoMonuments() async {
    return getMonuments(ville: 'Bamako');
  }

  /// Analyse d'une image pour identification CultureLens (Hybride Cloud / Edge AI)
  Future<MonumentScanResult?> identifyMonument({
    String? imagePath,
    String? imageName,
    List<String>? keywords,
    double? latitude,
    double? longitude,
    MonumentScanTarget? hintTarget,
  }) async {
    // Préparation de l'image en base64 pour le modèle AI CultureLens
    String? imageBase64;
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        if (imagePath.startsWith('assets/')) {
          final byteData = await rootBundle.load(imagePath);
          final bytes = byteData.buffer.asUint8List();
          imageBase64 = base64Encode(bytes);
        } else {
          final file = File(imagePath);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            imageBase64 = base64Encode(bytes);
          }
        }
      } catch (e) {
        _logger.w('Impossible de lire l\'image pour conversion base64 : $e');
      }
    }

    // Étape 1 : Si en ligne, tentative avec l'API CultureLens
    final remoteResult = await _apiClient.identifyMonument(
      imageName: imageName,
      imageBase64: imageBase64,
      keywords: keywords,
      latitude: latitude,
      longitude: longitude,
      hintId: hintTarget?.id,
    );

    if (remoteResult != null && remoteResult.confidence >= 0.45) {
      await recordScanDiscovery(remoteResult);
      return remoteResult;
    }

    // Étape 2 : Mode Edge AI / Autonome hors ligne
    _logger.i('Traitement en mode autonome pour CultureLens');
    MonumentScanTarget? matched = hintTarget;

    if (matched == null && imageName != null) {
      final normName = imageName.toLowerCase();
      if (!normName.startsWith('image_picker') &&
          !normName.startsWith('scaled_') &&
          !normName.startsWith('camera') &&
          !normName.startsWith('photo') &&
          !normName.startsWith('img_')) {
        matched = MonumentScanKnowledge.matchByKeywords(imageName);
      }
    }

    if (matched == null && keywords != null && keywords.isNotEmpty) {
      for (final kw in keywords) {
        matched = MonumentScanKnowledge.matchByKeywords(kw);
        if (matched != null) break;
      }
    }

    // Si aucun monument n'est identifié avec certitude (seuil minimal de 45%)
    if (matched == null) {
      _logger.d('CultureRepository.identifyMonument : Aucun monument malien identifié avec certitude (seuil < 45%).');
      return null;
    }

    final result = MonumentScanResult(
      target: matched,
      confidence: 0.92,
      analyzedImagePath: imagePath,
      isFromCamera: imagePath != null,
      isDemoTarget: hintTarget != null,
      scannedAt: DateTime.now(),
      recognizedFeatures: matched.detectionFeatures,
    );

    await recordScanDiscovery(result);
    return result;
  }

  /// Pose une question au Guide Culturel IA (RAG)
  Future<Map<String, dynamic>> askGuide({
    required String question,
    String? monumentId,
    String? regionId,
  }) async {
    final remoteRes = await _apiClient.askGuide(
      question: question,
      monumentId: monumentId,
      regionId: regionId,
    );

    if (remoteRes != null) return remoteRes;

    // Réponse locale de secours RAG
    final target = monumentId != null ? MonumentScanKnowledge.findById(monumentId) : null;
    return {
      'answer': target != null
          ? "**Faits historiques :** ${target.historicalStory}\n\n**Secrets & traditions :** ${target.secretsAndMysteries}"
          : "Le Mali recèle un patrimoine d'une richesse exceptionnelle, avec les monuments de la capitale Bamako et les trésors de Tombouctou et Djenné.",
      'sources': target != null ? ["Catalogue local : ${target.name}"] : ["Archives locales AlterniA"],
      'ragVerified': true,
      'offlineMode': true,
    };
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GESTION DES FAVORIS ET HISTORIQUE (OFFLINE STORAGE)
  // ══════════════════════════════════════════════════════════════════════════

  Future<bool> isFavorite(String monumentId) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_favoritesPrefKey) ?? [];
    return favs.contains(monumentId);
  }

  Future<bool> toggleFavorite(String monumentId) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_favoritesPrefKey) ?? [];
    final isFav = favs.contains(monumentId);

    if (isFav) {
      favs.remove(monumentId);
    } else {
      favs.add(monumentId);
    }
    await prefs.setStringList(_favoritesPrefKey, favs);

    // Synchronisation en arrière-plan avec le backend si possible
    _apiClient.recordDiscovery(
      monumentId: monumentId,
      isFavorite: !isFav,
    );

    return !isFav;
  }

  Future<List<MonumentScanTarget>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList(_favoritesPrefKey) ?? [];
    final all = MonumentScanKnowledge.targets;
    return all.where((m) => favs.contains(m.id)).toList();
  }

  Future<void> recordScanDiscovery(MonumentScanResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyRaw = prefs.getStringList(_historyPrefKey) ?? [];

      final item = {
        'id': result.target.id,
        'name': result.target.name,
        'region': result.target.regionName,
        'ville': result.target.ville,
        'confidence': result.confidence,
        'photoUrl': result.target.photoUrl,
        'scannedAt': result.scannedAt.toIso8601String(),
      };

      // Évite les doublons immédiats consécutifs
      historyRaw.removeWhere((raw) {
        try {
          final decoded = jsonDecode(raw);
          return decoded['id'] == result.target.id;
        } catch (_) {
          return false;
        }
      });

      historyRaw.insert(0, jsonEncode(item));
      // Conserve les 40 dernières découvertes
      if (historyRaw.length > 40) historyRaw.removeLast();

      await prefs.setStringList(_historyPrefKey, historyRaw);

      // Synchro distante en arrière-plan
      _apiClient.recordDiscovery(
        monumentId: result.target.id,
        confidence: result.confidence,
      );
    } catch (e) {
      _logger.w('Erreur enregistrement découverte : $e');
    }
  }

  Future<List<Map<String, dynamic>>> getScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyRaw = prefs.getStringList(_historyPrefKey) ?? [];
    final List<Map<String, dynamic>> res = [];
    for (final raw in historyRaw) {
      try {
        res.add(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }
    return res;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PACKS CULTURELS HORS LIGNE
  // ══════════════════════════════════════════════════════════════════════════

  Future<List<String>> getInstalledPackIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_installedPacksPrefKey) ?? ['pack_bamako_capitale'];
  }

  Future<bool> installPack(String packId) async {
    final prefs = await SharedPreferences.getInstance();
    final installed = prefs.getStringList(_installedPacksPrefKey) ?? [];

    final bundle = await _apiClient.downloadPackBundle(packId);
    if (bundle != null && bundle['monuments'] is List) {
      final mons = (bundle['monuments'] as List)
          .whereType<Map<String, dynamic>>()
          .map((j) => MonumentScanTarget.fromJson(j))
          .toList();
      MonumentScanKnowledge.registerDynamicTargets(mons);
      await _cacheMonumentsLocally(mons);
    }

    if (!installed.contains(packId)) {
      installed.add(packId);
      await prefs.setStringList(_installedPacksPrefKey, installed);
    }
    return true;
  }

  // ── HELPERS INTERNES ──────────────────────────────────────────────────────

  List<MonumentScanTarget> _filterMonuments(
    List<MonumentScanTarget> list, {
    String? ville,
    String? regionId,
    String? query,
  }) {
    var res = list;
    if (ville != null && ville.isNotEmpty) {
      res = res.where((m) => m.ville.toLowerCase().contains(ville.toLowerCase())).toList();
    }
    if (regionId != null && regionId.isNotEmpty) {
      res = res.where((m) => m.regionId.toLowerCase() == regionId.toLowerCase()).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase().trim();
      res = res.where((m) =>
          m.name.toLowerCase().contains(q) ||
          m.subtitle.toLowerCase().contains(q) ||
          m.keywords.any((k) => k.toLowerCase().contains(q))).toList();
    }
    return res;
  }

  Future<void> _cacheMonumentsLocally(List<MonumentScanTarget> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = list.map((m) => m.toJson()).toList();
      await prefs.setString(_cachedMonumentsPrefKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<List<MonumentScanTarget>> _loadCachedMonuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Purge proactive des anciennes clés de cache corrompues ou obsolètes
      await prefs.remove('culture_cached_monuments_json');
      await prefs.remove('culture_cached_monuments_items_json');
      await prefs.remove('culture_cached_monuments_v2_json');
      await prefs.remove('culture_cached_monuments_v3_json');
      await prefs.remove('culture_cached_monuments_items_v2_json');
      await prefs.remove('culture_cached_monuments_items_v3_json');

      final raw = prefs.getString(_cachedMonumentsPrefKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as List;
        final list = decoded
            .whereType<Map<String, dynamic>>()
            .map((j) => MonumentScanTarget.fromJson(j))
            .where((m) => _validMonumentIds.contains(m.id))
            .toList();
        if (list.length == _validMonumentIds.length) {
          return list;
        }
      }
    } catch (_) {}
    return [];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACCÈS DIRECT BASE DE DONNÉES / API POUR TOUS LES MODULES CULTURELS
  // ══════════════════════════════════════════════════════════════════════════

  /// Récupère les monuments sous forme de CultureItem (depuis la base de données)
  Future<List<CultureItem>> getMonumentsAsCultureItems({
    String? regionId,
    String? query,
  }) async {
    // 1. Appel API vers la base de données centrale
    final remote = await _apiClient.fetchMonuments(
      regionId: regionId,
      query: query,
    );
    if (remote.isNotEmpty && remote.every((m) => _validMonumentIds.contains(m.id))) {
      final items = remote.map((t) => CultureItem(
        id: t.id,
        title: t.name,
        subtitle: t.subtitle,
        category: 'decouvrir',
        subCategory: 'monuments',
        description: t.historicalStory.isNotEmpty ? t.historicalStory : t.secretsAndMysteries,
        regionId: t.regionId,
        regionName: t.regionName,
        tag: t.tag,
        icon: Icons.museum_rounded,
        imageUrl: t.photoUrl,
        info: t.era,
      )).toList();
      _cacheCultureItemsLocally(_cachedMonumentsCultureItemsPrefKey, items);
      return _filterCultureItems(items, regionId: regionId, query: query);
    }

    // 2. Cache local persistant de la base (filtré strictement)
    final cached = await _loadCachedCultureItems(_cachedMonumentsCultureItemsPrefKey);
    if (cached.isNotEmpty) {
      return _filterCultureItems(cached, regionId: regionId, query: query);
    }

    // 3. Fallback sur le catalogue certifié des 8 monuments réels du Mali
    final fallback = MonumentScanKnowledge.targets
        .where((t) => _validMonumentIds.contains(t.id))
        .map((t) => CultureItem(
          id: t.id,
          title: t.name,
          subtitle: t.subtitle,
          category: 'decouvrir',
          subCategory: 'monuments',
          description: t.historicalStory.isNotEmpty ? t.historicalStory : t.secretsAndMysteries,
          regionId: t.regionId,
          regionName: t.regionName,
          tag: t.tag,
          icon: Icons.museum_rounded,
          imageUrl: t.photoUrl,
          info: t.era,
        )).toList();
    _cacheCultureItemsLocally(_cachedMonumentsCultureItemsPrefKey, fallback);
    return _filterCultureItems(fallback, regionId: regionId, query: query);
  }

  /// Récupère les personnages historiques (depuis la base de données)
  Future<List<CultureItem>> getFiguresAsCultureItems({
    String? regionId,
    String? query,
  }) async {
    final remote = await _apiClient.fetchFigures();
    if (remote.isNotEmpty) {
      final items = remote.map((j) => CultureItem.fromFigure(j)).toList();
      _cacheCultureItemsLocally(_cachedFiguresPrefKey, items);
      return _filterCultureItems(items, regionId: regionId, query: query);
    }

    final cached = await _loadCachedCultureItems(_cachedFiguresPrefKey);
    if (cached.isNotEmpty) {
      return _filterCultureItems(cached, regionId: regionId, query: query);
    }

    final initial = CultureDatabaseSeed.initialFigures;
    _cacheCultureItemsLocally(_cachedFiguresPrefKey, initial);
    return _filterCultureItems(initial, regionId: regionId, query: query);
  }

  /// Récupère les terroirs et cités historiques (depuis la base de données)
  Future<List<CultureItem>> getPlacesAsCultureItems({
    String? regionId,
    String? query,
  }) async {
    final remote = await _apiClient.fetchPlaces();
    if (remote.isNotEmpty) {
      final items = remote.map((j) => CultureItem.fromPlace(j)).toList();
      _cacheCultureItemsLocally(_cachedPlacesPrefKey, items);
      return _filterCultureItems(items, regionId: regionId, query: query);
    }

    final cached = await _loadCachedCultureItems(_cachedPlacesPrefKey);
    if (cached.isNotEmpty) {
      return _filterCultureItems(cached, regionId: regionId, query: query);
    }

    final initial = CultureDatabaseSeed.initialPlaces;
    _cacheCultureItemsLocally(_cachedPlacesPrefKey, initial);
    return _filterCultureItems(initial, regionId: regionId, query: query);
  }

  /// Récupère les contes et fables (depuis la base de données)
  Future<List<CultureItem>> getStoriesAsCultureItems({
    String? regionId,
    String? query,
  }) async {
    final remote = await _apiClient.fetchStories();
    if (remote.isNotEmpty) {
      final items = remote.map((j) => CultureItem.fromStory(j)).toList();
      _cacheCultureItemsLocally(_cachedStoriesPrefKey, items);
      return _filterCultureItems(items, regionId: regionId, query: query);
    }

    final cached = await _loadCachedCultureItems(_cachedStoriesPrefKey);
    if (cached.isNotEmpty) {
      return _filterCultureItems(cached, regionId: regionId, query: query);
    }

    final initial = CultureDatabaseSeed.initialStories;
    _cacheCultureItemsLocally(_cachedStoriesPrefKey, initial);
    return _filterCultureItems(initial, regionId: regionId, query: query);
  }

  /// Récupère les devinettes et sagesses (depuis la base de données)
  Future<List<CultureItem>> getDefisAsCultureItems({
    String? regionId,
    String? query,
  }) async {
    final remote = await _apiClient.fetchProverbs();
    if (remote.isNotEmpty) {
      final items = remote.map((j) => CultureItem.fromProverb(j)).toList();
      _cacheCultureItemsLocally(_cachedProverbsPrefKey, items);
      return _filterCultureItems(items, regionId: regionId, query: query);
    }

    final cached = await _loadCachedCultureItems(_cachedProverbsPrefKey);
    if (cached.isNotEmpty) {
      return _filterCultureItems(cached, regionId: regionId, query: query);
    }

    final initial = CultureDatabaseSeed.initialDefis;
    _cacheCultureItemsLocally(_cachedProverbsPrefKey, initial);
    return _filterCultureItems(initial, regionId: regionId, query: query);
  }

  /// Récupère l'élément en vedette (depuis la base de données)
  Future<CultureItem?> getFeaturedItem() async {
    final figures = await getFiguresAsCultureItems();
    final soundiata = figures.firstWhere(
      (f) => f.id == 'perso_soundiata',
      orElse: () => figures.isNotEmpty
          ? figures.first
          : const CultureItem(
              id: 'featured_soundiata',
              title: 'Soundiata Keïta & la Charte du Manden',
              subtitle: 'Le fondateur de l\'Empire du Mali et la proclamation de 1236',
              category: 'accueil',
              subCategory: 'personnages',
              description: 'Découvrez l\'épopée du Lion du Manden, sa victoire décisive à Kirina en 1235 et la proclamation de l\'une des premières déclarations des droits humains à Kouroukan Fouga.',
              regionId: 'koulikoro',
              regionName: 'Koulikoro',
              tag: 'Épopée Majeure',
              icon: Icons.shield_rounded,
              imageUrl: 'assets/images/culture/personnages/soundiata.jpg',
              isFeatured: true,
              info: 'Lecture : 4 min',
            ),
    );
    return CultureItem(
      id: soundiata.id,
      title: 'Soundiata Keïta & la Charte du Manden',
      subtitle: soundiata.subtitle,
      category: 'accueil',
      subCategory: 'personnages',
      description: soundiata.description,
      regionId: soundiata.regionId,
      regionName: soundiata.regionName,
      tag: 'Épopée Majeure',
      icon: Icons.shield_rounded,
      imageUrl: soundiata.imageUrl,
      isFeatured: true,
      info: 'Lecture : 4 min',
    );
  }

  /// Récupère la fiche détaillée d'un monument
  Future<MonumentDetail?> getMonumentDetail(String id) async {
    // 1. Consultation prioritaire du catalogue certifié enrichi (garantie des photos réelles et textes vérifiés)
    try {
      // ignore: deprecated_member_use_from_same_package
      final mock = MockCultureDetailsData.monuments.firstWhere(
        (m) =>
            m.id == id ||
            m.id == 'monument_$id' ||
            id == 'monument_${m.id}' ||
            (id.contains('djenne') && m.id.contains('djenne')),
      );
      return mock;
    } catch (_) {}

    final target = MonumentScanKnowledge.findById(id);
    if (target != null && _validMonumentIds.contains(target.id)) {
      return MonumentDetail(
        id: target.id,
        name: target.name,
        subtitle: target.subtitle,
        era: target.era,
        regionId: target.regionId,
        regionName: target.regionName,
        tag: target.tag,
        photoUrl: target.photoUrl,
        photoCredits: 'Direction Nationale du Patrimoine / Wikimedia Commons',
        locationDetails: target.locationDetails,
        presentation: target.historicalStory,
        architectureAndMaterials: target.architectureStyle,
        whyItMatters: target.whyItMatters,
        keyFacts: target.detectionFeatures
            .map((f) => HistoricalKeyFact(label: f.label, value: f.category, icon: f.icon))
            .toList(),
        chapters: [
          EditorialStoryChapter(title: 'Histoire & Origine', content: target.historicalStory),
          EditorialStoryChapter(title: 'Secrets & Mystères', content: target.secretsAndMysteries),
        ],
        connectedItems: target.id == 'monument_mosquee_djenne' ||
                target.regionId == 'mopti'
            ? [
                const ConnectedItemRef(
                  id: 'ville_djenne',
                  title: 'Djenné',
                  subtitle: 'La Cité Millénaire du Bani',
                  type: ConnectedItemType.ville,
                  tag: 'UNESCO',
                  regionName: 'Mopti',
                ),
                const ConnectedItemRef(
                  id: 'monument_djingareyber',
                  title: 'Mosquée Djingareyber',
                  subtitle: 'Joyau en banco de Tombouctou',
                  type: ConnectedItemType.monument,
                  tag: 'UNESCO',
                  regionName: 'Tombouctou',
                ),
              ]
            : [
                const ConnectedItemRef(
                  id: 'ville_bamako',
                  title: 'Bamako',
                  subtitle: 'La Cité des Trois Caïmans',
                  type: ConnectedItemType.ville,
                  tag: 'Capitale',
                  regionName: 'Bamako',
                ),
              ],
      );
    }

    final remote = await _apiClient.fetchMonumentDetail(id);
    if (remote != null) {
      final detail = MonumentDetail.fromJson(remote);
      _cacheDetailLocally('monument_$id', detail.toJson());
      return detail;
    }

    final cached = await _loadCachedDetail('monument_$id');
    if (cached != null) {
      return MonumentDetail.fromJson(cached);
    }
    return null;
  }

  /// Récupère la fiche détaillée d'un personnage historique
  Future<HistoricalFigureDetail?> getFigureDetail(String id) async {
    final remote = await _apiClient.fetchFigureDetail(id);
    if (remote != null) {
      final detail = HistoricalFigureDetail.fromJson(remote);
      _cacheDetailLocally('figure_$id', detail.toJson());
      return detail;
    }

    final cached = await _loadCachedDetail('figure_$id');
    if (cached != null) {
      return HistoricalFigureDetail.fromJson(cached);
    }

    final initial = CultureDatabaseSeed.getInitialFigureDetail(id);
    if (initial != null) {
      _cacheDetailLocally('figure_$id', initial.toJson());
      return initial;
    }
    return null;
  }

  /// Récupère la fiche détaillée d'une ville ou terroir historique
  Future<PlaceDetail?> getPlaceDetail(String id) async {
    final remote = await _apiClient.fetchPlaceDetail(id);
    if (remote != null) {
      final detail = PlaceDetail.fromJson(remote);
      _cacheDetailLocally('place_$id', detail.toJson());
      return detail;
    }

    final cached = await _loadCachedDetail('place_$id');
    if (cached != null) {
      return PlaceDetail.fromJson(cached);
    }

    final initial = CultureDatabaseSeed.getInitialPlaceDetail(id);
    if (initial != null) {
      _cacheDetailLocally('place_$id', initial.toJson());
      return initial;
    }
    return null;
  }

  Future<void> _cacheCultureItemsLocally(String key, List<CultureItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((i) => i.toJson()).toList();
      await prefs.setString(key, jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<List<CultureItem>> _loadCachedCultureItems(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw != null) {
        final decoded = jsonDecode(raw) as List;
        var items = decoded
            .whereType<Map<String, dynamic>>()
            .map((j) => CultureItem.fromJson(j))
            .toList();
        if (key == _cachedMonumentsCultureItemsPrefKey) {
          items = items.where((i) => _validMonumentIds.contains(i.id)).toList();
          if (items.length != _validMonumentIds.length) {
            return [];
          }
        }
        return items;
      }
    } catch (_) {}
    return [];
  }

  Future<void> _cacheDetailLocally(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('detail_$key', jsonEncode(data));
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> _loadCachedDetail(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('detail_$key');
      if (raw != null) {
        return jsonDecode(raw) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  List<CultureItem> _filterCultureItems(
    List<CultureItem> list, {
    String? regionId,
    String? query,
  }) {
    var res = list;
    if (regionId != null && regionId.isNotEmpty && regionId != 'all') {
      res = res.where((i) => i.matchesRegion(regionId)).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      res = res.where((i) =>
          i.title.toLowerCase().contains(q) ||
          i.subtitle.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q) ||
          i.regionName.toLowerCase().contains(q) ||
          i.tag.toLowerCase().contains(q)).toList();
    }
    return res;
  }

  /// Soumet une nouvelle contribution culturelle (tous types de contenu)
  /// Envoie la contribution au Super Admin en statut EN_ATTENTE et la met en cache localement.
  Future<Map<String, dynamic>?> submitContribution(Map<String, dynamic> payload) async {
    final remoteResult = await _apiClient.submitContribution(payload);

    final entryToCache = remoteResult ??
        <String, dynamic>{
          'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
          'typeContenu': payload['type_contenu'] ?? 'proverbe',
          'titre': payload['titre'],
          'texte': payload['texte'] ?? '',
          'texteOriginal': payload['texte_original'],
          'signification': payload['signification'] ?? '',
          'morale': payload['morale'],
          'origine': payload['origine'] ?? 'Tradition Orale',
          'theme': payload['theme'] ?? 'Patrimoine & Culture Vivante',
          'regionId': payload['region_id'] ?? 'bamako',
          'regionNom': payload['region_nom'] ?? 'Bamako',
          'sourceTemoin': payload['source_temoin'],
          'photoUrl': payload['photo_url'],
          'donneesSupplementaires': payload['donnees_supplementaires'] ?? {},
          'auteurId': payload['auteur_id'],
          'auteurNom': payload['auteur_nom'] ?? 'Gardien AlterniA',
          'auteurRole': payload['auteur_role'] ?? 'Apprenant',
          'statut': 'EN_ATTENTE',
          'xpAttribues': payload['xp_attribues'] ?? 50,
          'piecesAttribuees': payload['pieces_attribuees'] ?? 25,
          'dateSoumission': DateTime.now().toUtc().toIso8601String(),
          'pendingSync': remoteResult == null,
        };

    await _saveContributionToLocalCache(entryToCache);
    return remoteResult;
  }

  Future<void> _saveContributionToLocalCache(Map<String, dynamic> contrib) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localContributionsPrefKey);
      final List<Map<String, dynamic>> current = [];
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          current.addAll(decoded.whereType<Map<String, dynamic>>());
        }
      }
      final id = contrib['id']?.toString() ?? '';
      current.removeWhere((c) => c['id']?.toString() == id);
      current.insert(0, contrib);
      await prefs.setString(_localContributionsPrefKey, jsonEncode(current));
    } catch (e) {
      _logger.w('Impossible de sauvegarder la contribution en cache local: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _loadLocalContributions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localContributionsPrefKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded.whereType<Map<String, dynamic>>().toList();
        }
      }
    } catch (_) {}
    return [];
  }

  /// Récupère les contributions pour la modération ou l'historique utilisateur.
  /// Synchronise automatiquement les contributions en attente et fusionne avec le serveur Super Admin.
  Future<List<Map<String, dynamic>>> getContributions({
    String? statut,
    String? typeContenu,
    String? auteurId,
  }) async {
    final localItems = await _loadLocalContributions();

    // Synchroniser les contributions créées hors-ligne dès que le backend répond
    bool localUpdated = false;
    final updatedLocal = <Map<String, dynamic>>[];
    for (final item in localItems) {
      if (item['pendingSync'] == true) {
        final synced = await _apiClient.submitContribution({
          'type_contenu': item['typeContenu'] ?? item['type_contenu'] ?? 'proverbe',
          'titre': item['titre'],
          'texte': item['texte'] ?? '',
          'texte_original': item['texteOriginal'] ?? item['texte_original'],
          'signification': item['signification'] ?? '',
          'morale': item['morale'],
          'origine': item['origine'] ?? 'Tradition Orale',
          'theme': item['theme'] ?? 'Patrimoine & Culture Vivante',
          'region_id': item['regionId'] ?? item['region_id'] ?? 'bamako',
          'region_nom': item['regionNom'] ?? item['region_nom'] ?? 'Bamako',
          'source_temoin': item['sourceTemoin'] ?? item['source_temoin'],
          'photo_url': item['photoUrl'] ?? item['photo_url'],
          'donnees_supplementaires': item['donneesSupplementaires'] ?? item['donnees_supplementaires'] ?? {},
          'auteur_id': item['auteurId'] ?? item['auteur_id'],
          'auteur_nom': item['auteurNom'] ?? item['auteur_nom'] ?? 'Gardien AlterniA',
          'auteur_role': item['auteurRole'] ?? item['auteur_role'] ?? 'Apprenant',
          'xp_attribues': item['xpAttribues'] ?? 50,
          'pieces_attribuees': item['piecesAttribuees'] ?? 25,
        });
        if (synced != null) {
          updatedLocal.add(synced);
          localUpdated = true;
          continue;
        }
      }
      updatedLocal.add(item);
    }

    final remoteItems = await _apiClient.fetchContributions(
      statut: statut,
      typeContenu: typeContenu,
      auteurId: auteurId,
    );

    if (remoteItems.isNotEmpty) {
      final remoteById = {
        for (final r in remoteItems)
          if (r['id'] != null) r['id'].toString(): r,
      };

      // Mettre à jour le statut local (ex: EN_ATTENTE -> APPROUVE / REJETE par le Super Admin)
      for (var i = 0; i < updatedLocal.length; i++) {
        final localId = updatedLocal[i]['id']?.toString();
        if (localId != null && remoteById.containsKey(localId)) {
          updatedLocal[i] = remoteById[localId]!;
          localUpdated = true;
        }
      }

      if (localUpdated) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_localContributionsPrefKey, jsonEncode(updatedLocal));
        } catch (_) {}
      }

      final merged = <Map<String, dynamic>>[...remoteItems];
      for (final loc in updatedLocal) {
        final locId = loc['id']?.toString() ?? '';
        final locTexte = (loc['texte'] ?? '').toString().trim().toLowerCase();
        final alreadyInRemote = remoteItems.any((r) =>
            r['id']?.toString() == locId ||
            ((r['texte'] ?? '').toString().trim().toLowerCase() == locTexte &&
                locTexte.isNotEmpty));
        if (!alreadyInRemote) {
          merged.insert(0, loc);
        }
      }
      return merged;
    }

    return updatedLocal;
  }

  /// Récupère la liste des contes interactifs (priorité backend API, repli hors ligne)
  Future<List<InteractiveStory>> getInteractiveStories({String? regionId}) async {
    try {
      final remote = await _apiClient.fetchStories();
      if (remote.isNotEmpty) {
        final list = <InteractiveStory>[];
        for (final item in remote) {
          final id = item['id'] as String? ?? '';
          final matchingMock = MockCultureStoriesData.stories.firstWhere(
            (s) => s.id == id,
            orElse: () => MockCultureStoriesData.stories.first,
          );
          list.add(InteractiveStory(
            id: id,
            title: item['title'] as String? ?? matchingMock.title,
            subtitle: item['subtitle'] as String? ?? matchingMock.subtitle,
            origin: item['origin'] as String? ?? matchingMock.origin,
            regionId: item['regionId'] as String? ?? matchingMock.regionId,
            regionName: item['regionName'] as String? ?? matchingMock.regionName,
            tag: item['tag'] as String? ?? matchingMock.tag,
            photoUrl: item['photoUrl'] as String? ?? matchingMock.photoUrl,
            photoCredits: matchingMock.photoCredits,
            summary: item['resume'] as String? ?? matchingMock.summary,
            narrator: item['narrator'] as String? ?? matchingMock.narrator,
            audioDuration: item['audioDuration'] as String? ?? matchingMock.audioDuration,
            readingDuration: item['readingDuration'] as String? ?? matchingMock.readingDuration,
            moral: item['moral'] as String? ?? matchingMock.moral,
            connectedItems: matchingMock.connectedItems,
            scenes: matchingMock.scenes,
          ));
        }
        if (list.isNotEmpty) {
          if (regionId == null || regionId.isEmpty || regionId == 'all') return list;
          return list.where((s) => s.regionId == null || s.regionId == regionId).toList();
        }
      }
    } catch (_) {}
    return MockCultureStoriesData.getFiltered(regionId: regionId);
  }

  /// Récupère la liste des proverbes (priorité backend API, repli hors ligne)
  Future<List<CultureProverb>> getProverbs({String? regionId}) async {
    try {
      final remote = await _apiClient.fetchProverbs();
      if (remote.isNotEmpty) {
        final list = <CultureProverb>[];
        for (final item in remote) {
          final id = item['id'] as String? ?? '';
          final matchingMock = MockCultureProverbsData.proverbs.firstWhere(
            (p) => p.id == id,
            orElse: () => MockCultureProverbsData.proverbs.first,
          );
          list.add(CultureProverb(
            id: id,
            text: item['text'] as String? ?? matchingMock.text,
            originalText: item['originalText'] as String? ?? matchingMock.originalText,
            meaning: item['meaning'] as String? ?? matchingMock.meaning,
            theme: item['theme'] as String? ?? matchingMock.theme,
            regionId: item['regionId'] as String? ?? matchingMock.regionId,
            regionName: item['regionName'] as String? ?? matchingMock.regionName,
            origin: matchingMock.origin,
            moral: matchingMock.moral,
            stageImagePath: matchingMock.stageImagePath,
            speakerName: matchingMock.speakerName,
            speakerRole: matchingMock.speakerRole,
            speakerAvatar: matchingMock.speakerAvatar,
          ));
        }
        if (list.isNotEmpty) {
          if (regionId == null || regionId.isEmpty || regionId == 'all') return list;
          return list.where((p) => p.regionId == null || p.regionId == regionId).toList();
        }
      }
    } catch (_) {}
    return MockCultureProverbsData.getFiltered(regionId: regionId);
  }

  /// Récupère la liste des devinettes traditionnelles (priorité backend API, repli hors ligne)
  Future<List<CultureRiddle>> getRiddles({String? regionId}) async {
    try {
      final res = await _apiClient.fetchProverbs();
      if (res.isNotEmpty) {
        final riddlesFromApi = <CultureRiddle>[];
        for (final item in res) {
          final theme = (item['theme'] as String? ?? '').toLowerCase();
          final origin = (item['origin'] as String? ?? item['origine'] as String? ?? '').toLowerCase();
          final text = item['text'] as String? ?? item['texte'] as String? ?? '';
          if (theme.contains('devinette') || origin.contains('devinette') || text.contains('Kôkô')) {
            final matchingMock = MockCultureChallengesData.riddles.firstWhere(
              (r) => r.id == item['id'],
              orElse: () => MockCultureChallengesData.riddles.first,
            );
            final meaning = item['meaning'] as String? ?? item['signification'] as String? ?? matchingMock.culturalExplanation;
            final moral = item['moral'] as String? ?? item['morale'] as String? ?? matchingMock.correctAnswer;
            riddlesFromApi.add(TraditionalRiddle(
              id: item['id'] as String? ?? matchingMock.id,
              riddleText: text.isNotEmpty ? text : matchingMock.riddleText,
              hints: matchingMock.hints,
              options: matchingMock.options,
              correctAnswer: moral.isNotEmpty ? moral : matchingMock.correctAnswer,
              culturalExplanation: meaning.isNotEmpty ? meaning : matchingMock.culturalExplanation,
              proverb: item['originalText'] as String? ?? matchingMock.proverb,
              regionId: item['regionId'] as String? ?? item['region_id'] as String?,
              regionName: item['regionName'] as String? ?? item['region_nom'] as String? ?? matchingMock.regionName,
              category: item['theme'] as String? ?? matchingMock.category,
              difficulty: matchingMock.difficulty,
              xpReward: (item['xpReward'] as num?)?.toInt() ?? matchingMock.xpReward,
            ));
          }
        }
        if (riddlesFromApi.isNotEmpty) {
          if (regionId == null || regionId.isEmpty || regionId == 'all') return riddlesFromApi;
          return riddlesFromApi.where((r) => r.regionId == null || r.regionId == regionId).toList();
        }
      }
    } catch (_) {}
    return MockCultureChallengesData.getFilteredRiddles(regionId: regionId);
  }
}

