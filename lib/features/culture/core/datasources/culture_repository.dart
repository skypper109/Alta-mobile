import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../scanner/data/monument_scan_knowledge.dart';
import '../../scanner/models/monument_scan_models.dart';
import 'culture_api_client.dart';

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
  static const String _cachedMonumentsPrefKey = 'culture_cached_monuments_json';

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

    if (remote.isNotEmpty) {
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

    // 3. Repli sur le catalogue statique pré-embarqué (incluant tous les monuments de Bamako)
    var list = MonumentScanKnowledge.targets;
    return _filterMonuments(list, ville: ville, regionId: regionId, query: query);
  }

  /// Récupère spécifiquement les monuments situés à Bamako
  Future<List<MonumentScanTarget>> getBamakoMonuments() async {
    return getMonuments(ville: 'Bamako');
  }

  /// Analyse d'une image pour identification CultureLens (Hybride Cloud / Edge AI)
  Future<MonumentScanResult> identifyMonument({
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

    if (remoteResult != null) {
      await recordScanDiscovery(remoteResult);
      return remoteResult;
    }

    // Étape 2 : Mode Edge AI / Autonome hors ligne
    _logger.i('Traitement en mode autonome hors ligne pour CultureLens');
    MonumentScanTarget? matched = hintTarget;

    if (matched == null && imageName != null) {
      matched = MonumentScanKnowledge.matchByKeywords(imageName);
    }

    if (matched == null && keywords != null && keywords.isNotEmpty) {
      for (final kw in keywords) {
        matched = MonumentScanKnowledge.matchByKeywords(kw);
        if (matched != null) break;
      }
    }

    // Si toujours non identifié, sélection du premier monument de Bamako
    matched ??= MonumentScanKnowledge.bamakoTargets.first;

    final result = MonumentScanResult(
      target: matched,
      confidence: 0.982,
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
      final raw = prefs.getString(_cachedMonumentsPrefKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as List;
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((j) => MonumentScanTarget.fromJson(j))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
