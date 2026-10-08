import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'constants.dart';

class CultureAlternIAService {
  CultureAlternIAService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final _logger = Logger();

  List<String> get candidateUrls => AltaApiConfig.candidateBaseUrls;

  /// Face ID Simli officiel du Vieux Sage (Griot Ancestral)
  static const String simliSageFaceId = 'c295e3a2-ed11-48d5-a1bd-ff42ac7eac73';
  static const String simliTeacherFaceId = 'bb1212ec-2cc5-4ca0-ad32-4a4427600345';

  final String defaultFaceId = simliSageFaceId;

  /// Voix académique / sage par défaut (Griot Henri / Vivienne)
  final String defaultVoice = 'henri';

  /// Chemin de l'image photoréaliste locale du Vieux Sage (visage officiel Simli)
  static const String defaultSageImagePath = 'assets/images/culture/griot_sage.jpg';

  // ── Cache de connectivité pour réactivité immédiate sans freeze ────────────
  static String? _cachedActiveBaseUrl;
  static DateTime? _lastHealthCheckTime;
  static bool _lastHealthStatus = false;

  /// Teste rapidement si le serveur backend est joignable (timeout 1.5s)
  Future<String?> getActiveBaseUrlFast() async {
    final now = DateTime.now();
    if (_cachedActiveBaseUrl != null &&
        _lastHealthCheckTime != null &&
        now.difference(_lastHealthCheckTime!).inSeconds < 30 &&
        _lastHealthStatus) {
      return _cachedActiveBaseUrl;
    }

    // Tester en priorité le cache ou l'URL officielle
    final priorityUrls = [
      if (_cachedActiveBaseUrl != null) _cachedActiveBaseUrl!,
      AltaApiConfig.serverBaseUrl,
      'http://127.0.0.1:8000',
      'http://10.0.2.2:8000',
      'http://172.20.10.14:8000',
    ];

    for (final baseUrl in priorityUrls) {
      try {
        final res = await _dio.get(
          '$baseUrl/api/health',
          options: Options(
            connectTimeout: const Duration(milliseconds: 1500),
            receiveTimeout: const Duration(milliseconds: 1500),
          ),
        );
        if (res.statusCode == 200) {
          _cachedActiveBaseUrl = baseUrl;
          _lastHealthCheckTime = now;
          _lastHealthStatus = true;
          return baseUrl;
        }
      } catch (_) {}
    }

    _lastHealthCheckTime = now;
    _lastHealthStatus = false;
    return null;
  }

  /// Teste la connectivité avec le serveur backend
  Future<bool> checkServerHealth() async {
    final url = await getActiveBaseUrlFast();
    return url != null;
  }

  /// Demande au backend de générer une vidéo LivePortrait/Simli pour le Vieux Sage
  /// Retourne null immédiatement si le backend n'est pas lancé, sans bloquer le téléphone.
  Future<String?> generateSageVideo({
    required String text,
    String? subject,
  }) async {
    final activeUrl = await getActiveBaseUrlFast();
    if (activeUrl == null) {
      _logger.d('[CultureAlternIA] Backend hors-ligne : passage en mode avatar local immédiat.');
      return null;
    }

    try {
      _logger.i('[AlternIA] Requête vidéo sur $activeUrl pour "$text"');
      final response = await _dio.post(
        '$activeUrl/api/avatars/generate-video',
        data: {
          'question': text,
          'phrase': text,
          'matiere': subject ?? 'Culture Malienne',
          'voice': defaultVoice,
          'faceId': defaultFaceId,
        },
        options: Options(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 18),
        ),
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        if (data['status'] == 'success' && data['video_url'] != null) {
          final rawUrl = data['video_url'].toString();
          return rawUrl.startsWith('http') ? rawUrl : '$activeUrl$rawUrl';
        }
      }
    } catch (e) {
      _logger.w('[CultureAlternIA] Échec génération vidéo sur $activeUrl : $e');
    }

    return null;
  }
}
