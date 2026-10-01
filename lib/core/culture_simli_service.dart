import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'constants.dart';

class CultureAlternIAService {
  CultureAlternIAService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final _logger = Logger();

  List<String> get _candidateUrls => AltaApiConfig.candidateBaseUrls;

  /// Face ID Simli officiel du Vieux Sage (Griot Ancestral)
  static const String simliSageFaceId = 'c295e3a2-ed11-48d5-a1bd-ff42ac7eac73';
  static const String simliTeacherFaceId = 'bb1212ec-2cc5-4ca0-ad32-4a4427600345';

  final String defaultFaceId = simliSageFaceId;

  /// Voix académique / sage par défaut (Griot Henri / Vivienne)
  final String defaultVoice = 'henri';

  /// Chemin de l'image photoréaliste locale du Vieux Sage (visage officiel Simli)
  static const String defaultSageImagePath = 'assets/images/culture/griot_sage.jpg';

  /// Teste la connectivité avec le serveur backend (api.alterniamali.com)
  Future<bool> checkServerHealth() async {
    for (final baseUrl in _candidateUrls) {
      try {
        final res = await _dio.get(
          '$baseUrl/api/health',
          options: Options(connectTimeout: const Duration(seconds: 3)),
        );
        if (res.statusCode == 200) return true;
      } catch (_) {}
    }
    return false;
  }

  /// Demande au backend de générer une vidéo LivePortrait pour le Vieux Sage
  Future<String?> generateSageVideo({
    required String text,
    String? subject,
  }) async {
    for (final baseUrl in _candidateUrls) {
      try {
        _logger.i('[AlternIA] Génération vidéo pour "$text"');
        final response = await _dio.post(
          '$baseUrl/api/avatars/generate-video',
          data: {
            'question': text,
            'phrase': text,
            'matiere': subject ?? 'Culture Malienne',
            'voice': defaultVoice,
            'faceId': defaultFaceId,
          },
          options: Options(
            connectTimeout: const Duration(seconds: 6),
            receiveTimeout: const Duration(seconds: 60),
          ),
        );

        if (response.statusCode == 200 && response.data is Map) {
          final data = response.data as Map<String, dynamic>;
          if (data['status'] == 'success' && data['video_url'] != null) {
            final rawUrl = data['video_url'].toString();
            return rawUrl.startsWith('http') ? rawUrl : '$baseUrl$rawUrl';
          }
        }
      } catch (e) {
        _logger.w('[CultureAlternIA] Échec sur $baseUrl : $e');
      }
    }
    return null;
  }
}
