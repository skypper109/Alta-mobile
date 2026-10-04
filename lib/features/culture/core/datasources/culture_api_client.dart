import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants.dart';
import '../../scanner/models/monument_scan_models.dart';

/// Client HTTP pour interagir avec le backend CultureLens (FastAPI / ALTA Box)
class CultureApiClient {
  final Dio _dio;
  final Logger _logger;
  String _activeBaseUrl = AltaApiConfig.serverBaseUrl;

  bool _isResolving = false;

  CultureApiClient({Dio? dio, Logger? logger})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 3),
                receiveTimeout: const Duration(seconds: 4),
                validateStatus: (status) => status != null && status < 600,
              ),
            ),
        _logger = logger ?? Logger() {
    // Vérification asynchrone des serveurs disponibles (local et cloud)
    resolveActiveUrl();
  }

  String get activeBaseUrl => _activeBaseUrl;

  /// Tente de résoudre l'URL active la plus réactive parmi les candidates
  Future<String> resolveActiveUrl() async {
    if (_isResolving) return _activeBaseUrl;
    _isResolving = true;
    try {
      for (final url in AltaApiConfig.candidateBaseUrls) {
        try {
          final res = await _dio.get(
            '$url/api/v1/culture/health',
            options: Options(
              sendTimeout: const Duration(milliseconds: 1500),
              receiveTimeout: const Duration(milliseconds: 1500),
              responseType: ResponseType.json,
            ),
          );
          if (res.statusCode == 200 &&
              res.data is Map &&
              ((res.data as Map)['status'] == 'online' ||
                  (res.data as Map).containsKey('totalMonuments') ||
                  (res.data as Map)['service'] != null)) {
            _activeBaseUrl = url;
            _logger.i('✅ Serveur CultureLens connecté sur : $url');
            return url;
          }
        } catch (_) {
          // Continue vers la suivante si inaccessible
        }
      }
    } finally {
      _isResolving = false;
    }
    return _activeBaseUrl;
  }

  /// Récupère la liste des monuments depuis la base de données
  Future<List<MonumentScanTarget>> fetchMonuments({String? ville, String? regionId, String? query}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (ville != null) queryParams['ville'] = ville;
      if (regionId != null) queryParams['region_id'] = regionId;
      if (query != null) queryParams['q'] = query;

      final res = await _dio.get(
        '$_activeBaseUrl/api/v1/culture/monuments',
        queryParameters: queryParams,
      );

      if (res.statusCode == 200 && res.data is List) {
        return (res.data as List)
            .whereType<Map<String, dynamic>>()
            .map((json) => MonumentScanTarget.fromJson(json))
            .toList();
      }
    } catch (_) {
      _logger.d('CultureApiClient.fetchMonuments -> utilisation du cache local');
    }
    return [];
  }

  /// Envoie une requête d'identification visuelle ou géospatiale
  Future<MonumentScanResult?> identifyMonument({
    String? imageName,
    String? imageBase64,
    List<String>? keywords,
    double? latitude,
    double? longitude,
    String? hintId,
  }) async {
    try {
      final payload = {
        'image_name': imageName,
        if (imageBase64 != null) 'image_base64': imageBase64,
        'keywords': keywords,
        'latitude': latitude,
        'longitude': longitude,
        'hint_id': hintId,
      };

      final res = await _dio.post(
        '$_activeBaseUrl/api/v1/culture/identify',
        data: payload,
      );

      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final data = res.data as Map<String, dynamic>;
        if (data['success'] == true && data['target'] != null) {
          return MonumentScanResult.fromJson(data);
        }
      }
    } on DioException catch (dioErr) {
      final code = dioErr.response?.statusCode;
      _logger.d('CultureApiClient.identifyMonument : distant non joignable ($code) — passage au mode hors ligne');
    } catch (e) {
      _logger.d('CultureApiClient.identifyMonument fallback : $e');
    }
    return null;
  }

  /// Pose une question au Guide Culturel IA (RAG)
  Future<Map<String, dynamic>?> askGuide({
    required String question,
    String? monumentId,
    String? regionId,
  }) async {
    try {
      final payload = {
        'question': question,
        'monument_id': monumentId,
        'region_id': regionId,
      };

      final res = await _dio.post(
        '$_activeBaseUrl/api/v1/culture/ask',
        data: payload,
      );

      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
    } catch (e) {
      _logger.w('CultureApiClient.askGuide : $e');
    }
    return null;
  }

  /// Récupère les packs hors ligne disponibles
  Future<List<Map<String, dynamic>>> fetchPacks() async {
    try {
      final res = await _dio.get('$_activeBaseUrl/api/v1/culture/packs');
      if (res.statusCode == 200 && res.data is List) {
        return (res.data as List).whereType<Map<String, dynamic>>().toList();
      }
    } catch (e) {
      _logger.w('CultureApiClient.fetchPacks : $e');
    }
    return [];
  }

  /// Télécharge le bundle d'un pack hors ligne
  Future<Map<String, dynamic>?> downloadPackBundle(String packId) async {
    try {
      final res = await _dio.get('$_activeBaseUrl/api/v1/culture/packs/$packId/download');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
    } catch (e) {
      _logger.w('CultureApiClient.downloadPackBundle : $e');
    }
    return null;
  }

  /// Enregistre une découverte / favori sur le serveur
  Future<bool> recordDiscovery({
    required String monumentId,
    String? studentId,
    double confidence = 0.98,
    bool isFavorite = false,
    String? notes,
  }) async {
    try {
      final payload = {
        'monument_id': monumentId,
        'apprenant_id': studentId,
        'confidence': confidence,
        'is_favorite': isFavorite,
        'notes': notes,
      };

      final res = await _dio.post(
        '$_activeBaseUrl/api/v1/culture/discoveries',
        data: payload,
      );
      return res.statusCode == 200;
    } on DioException catch (dioErr) {
      _logger.d('CultureApiClient.recordDiscovery conservé localement (${dioErr.response?.statusCode ?? "hors-ligne"})');
      return false;
    } catch (e) {
      _logger.d('CultureApiClient.recordDiscovery : $e');
      return false;
    }
  }

  /// Récupère les découvertes
  Future<List<Map<String, dynamic>>> fetchDiscoveries({String? studentId}) async {
    try {
      final res = await _dio.get(
        '$_activeBaseUrl/api/v1/culture/discoveries',
        queryParameters: studentId != null ? {'apprenant_id': studentId} : null,
      );
      if (res.statusCode == 200 && res.data is List) {
        return (res.data as List).whereType<Map<String, dynamic>>().toList();
      }
    } catch (e) {
      _logger.w('CultureApiClient.fetchDiscoveries : $e');
    }
    return [];
  }

  /// Récupère la fiche détaillée d'un monument
  Future<Map<String, dynamic>?> fetchMonumentDetail(String monumentId) async {
    try {
      final res = await _dio.get('$_activeBaseUrl/api/v1/culture/monuments/$monumentId');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
    } catch (e) {
      _logger.d('CultureApiClient.fetchMonumentDetail fallback : $e');
    }
    return null;
  }

  /// Récupère la liste des personnages historiques
  Future<List<Map<String, dynamic>>> fetchFigures() async {
    try {
      final res = await _dio.get('$_activeBaseUrl/api/v1/culture/figures');
      if (res.statusCode == 200 && res.data is List) {
        return (res.data as List).whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {
      _logger.d('CultureApiClient.fetchFigures -> utilisation du cache local');
    }
    return [];
  }

  /// Récupère la fiche détaillée d'un personnage historique
  Future<Map<String, dynamic>?> fetchFigureDetail(String figureId) async {
    try {
      final res = await _dio.get('$_activeBaseUrl/api/v1/culture/figures/$figureId');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
    } catch (_) {
      _logger.d('CultureApiClient.fetchFigureDetail -> utilisation du cache local');
    }
    return null;
  }

  /// Récupère la liste des terroirs et cités historiques
  Future<List<Map<String, dynamic>>> fetchPlaces() async {
    try {
      final res = await _dio.get('$_activeBaseUrl/api/v1/culture/places');
      if (res.statusCode == 200 && res.data is List) {
        return (res.data as List).whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {
      _logger.d('CultureApiClient.fetchPlaces -> utilisation du cache local');
    }
    return [];
  }

  /// Récupère la fiche détaillée d'une ville ou terroir historique
  Future<Map<String, dynamic>?> fetchPlaceDetail(String placeId) async {
    try {
      final res = await _dio.get('$_activeBaseUrl/api/v1/culture/places/$placeId');
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
    } catch (_) {
      _logger.d('CultureApiClient.fetchPlaceDetail -> utilisation du cache local');
    }
    return null;
  }

  /// Récupère les contes
  Future<List<Map<String, dynamic>>> fetchStories() async {
    try {
      final res = await _dio.get('$_activeBaseUrl/api/v1/culture/stories');
      if (res.statusCode == 200 && res.data is List) {
        return (res.data as List).whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {
      _logger.d('CultureApiClient.fetchStories -> utilisation du cache local');
    }
    return [];
  }

  /// Récupère les proverbes et énigmes
  Future<List<Map<String, dynamic>>> fetchProverbs() async {
    try {
      final res = await _dio.get('$_activeBaseUrl/api/v1/culture/proverbs');
      if (res.statusCode == 200 && res.data is List) {
        return (res.data as List).whereType<Map<String, dynamic>>().toList();
      }
    } catch (_) {
      _logger.d('CultureApiClient.fetchProverbs -> utilisation du cache local');
    }
    return [];
  }
}
