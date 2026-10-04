import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants.dart';
import '../../scanner/models/monument_scan_models.dart';

/// Client HTTP pour interagir avec le backend CultureLens (FastAPI / ALTA Box)
class CultureApiClient {
  final Dio _dio;
  final Logger _logger;
  String _activeBaseUrl = AltaApiConfig.serverBaseUrl;

  CultureApiClient({Dio? dio, Logger? logger})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 4),
                receiveTimeout: const Duration(seconds: 6),
              ),
            ),
        _logger = logger ?? Logger();

  String get activeBaseUrl => _activeBaseUrl;

  /// Tente de résoudre l'URL active la plus réactive parmi les candidates
  Future<String> resolveActiveUrl() async {
    for (final url in AltaApiConfig.candidateBaseUrls) {
      try {
        final res = await _dio.get('$url/api/v1/culture/health');
        if (res.statusCode == 200) {
          _activeBaseUrl = url;
          _logger.i('✅ Serveur CultureLens connecté sur : $url');
          return url;
        }
      } catch (_) {
        // Continue vers la suivante
      }
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
    } catch (e) {
      _logger.w('CultureApiClient.fetchMonuments fallback local : $e');
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
    } catch (e) {
      _logger.w('CultureApiClient.identifyMonument offline : $e');
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
    } catch (e) {
      _logger.w('CultureApiClient.recordDiscovery : $e');
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
}
