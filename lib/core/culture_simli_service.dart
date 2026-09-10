import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'constants.dart';

class CultureSimliService {
  CultureSimliService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final _logger = Logger();

  List<String> get _candidateUrls => AltaApiConfig.candidateBaseUrls;

  /// Face ID du Vieux Sage par défaut
  final String defaultFaceId = 'c295e3a2-ed11-48d5-a1bd-ff42ac7eac73';
  /// Voix académique/sage par défaut
  final String defaultVoice = 'henri';

  /// Demande au backend de générer une vidéo LivePortrait pour le Vieux Sage
  Future<String?> generateSageVideo({
    required String text,
    String? subject,
  }) async {
    for (final baseUrl in _candidateUrls) {
      try {
        _logger.i('[CultureSimli] Génération vidéo pour "$text"');
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
            return "'\$baseUrl\${data['video_url']}'";
          }
        }
      } catch (e) {
        _logger.w('[CultureSimli] Échec sur \$baseUrl : \$e');
      }
    }
    return null;
  }
}
