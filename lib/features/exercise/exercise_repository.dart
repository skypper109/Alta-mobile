// ─── DetAI — Feature: Exercise — Repository ──────────────────────────────────
// Capture photo, recadrage et transmission au moteur RAG du boîtier.
library;

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

import '../../core/failures.dart';
import 'exercise_entity.dart';

// ══════════════════════════════════════════════════════════════════════════════
// INTERFACE (DOMAIN)
// ══════════════════════════════════════════════════════════════════════════════

abstract interface class IExerciseRepository {
  /// Ouvre la caméra et retourne le chemin de la photo prise.
  Future<DetResult<String>> capturePhoto();

  /// Envoie l'image au moteur RAG du boîtier et reçoit les indices.
  Future<DetResult<List<HintEntity>>> getHints({
    required String imagePath,
    required String deviceBaseUrl,
    SchoolSubject subject,
    SchoolLevel?  level,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// IMPLÉMENTATION (DATA)
// ══════════════════════════════════════════════════════════════════════════════

/// Implémentation du repository Exercise.
///
/// Protocole avec le boîtier :
/// POST `/api/rag/analyze` — multipart/form-data avec l'image
/// Réponse :
/// ```json
/// {
///   "hints": [
///     { "index": 1, "content": "Quelle est la définition de…?", "type": "question" },
///     { "index": 2, "content": "As-tu pensé au théorème…?", "type": "reminder" }
///   ]
/// }
/// ```
class ExerciseRepository implements IExerciseRepository {
  ExerciseRepository({required Dio dio}) : _dio = dio;

  final Dio        _dio;
  final _picker = ImagePicker();
  final _logger = Logger();

  // ── Capture photo ─────────────────────────────────────────────────────────

  @override
  Future<DetResult<String>> capturePhoto() async {
    try {
      final xFile = await _picker.pickImage(
        source:      ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (xFile == null) {
        return left(const CameraFailure(message: 'Capture annulée.'));
      }

      _logger.i('[Exercise] Photo capturée : ${xFile.path}');
      return right(xFile.path);
    } catch (e) {
      _logger.e('[Exercise] Erreur capture : $e');
      return left(const CameraFailure());
    }
  }

  // ── Envoi au moteur RAG ────────────────────────────────────────────────────

  @override
  Future<DetResult<List<HintEntity>>> getHints({
    required String imagePath,
    required String deviceBaseUrl,
    SchoolSubject subject = SchoolSubject.autre,
    SchoolLevel?  level,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image':   await MultipartFile.fromFile(imagePath, filename: 'exercise.jpg'),
        'subject': subject.name,
        if (level != null) 'level': level.name,
      });

      final response = await _dio.post(
        '$deviceBaseUrl/api/rag/analyze',
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        return left(const RagFailure());
      }

      final data  = response.data as Map<String, dynamic>;
      final hints = (data['hints'] as List<dynamic>? ?? [])
          .map((h) => _parseHint(h as Map<String, dynamic>))
          .toList();

      _logger.i('[Exercise] ${hints.length} indice(s) reçu(s)');
      return right(hints);
    } on DioException catch (e) {
      _logger.e('[Exercise] Erreur réseau RAG : $e');
      return left(NetworkFailure(message: e.message ?? 'Erreur réseau.'));
    } catch (e) {
      _logger.e('[Exercise] Erreur RAG : $e');
      return left(const RagFailure());
    }
  }

  /// Parse un objet hint JSON en [HintEntity].
  HintEntity _parseHint(Map<String, dynamic> data) {
    final typeStr = data['type'] as String? ?? 'question';
    final type    = switch (typeStr) {
      'observation' => HintType.observation,
      'reminder'    => HintType.reminder,
      _             => HintType.question,
    };

    return HintEntity(
      index:   (data['index'] as int?) ?? 1,
      content: data['content'] as String? ?? '',
      type:    type,
      isNew:   true,
    );
  }
}
