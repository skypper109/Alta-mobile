// ─── DetAI — Gestion des erreurs (fpdart) ───────────────────────────────────
// Hiérarchie de Failures typées + alias Either pour usage dans l'app.
library;

import 'package:fpdart/fpdart.dart';

// ══════════════════════════════════════════════════════════════════════════════
// FAILURES — Classe de base et sous-types
// ══════════════════════════════════════════════════════════════════════════════

/// Classe de base scellée pour toutes les erreurs métier.
/// Utiliser [DetResult<T>] à la place de [Future<T>] pour propager les erreurs
/// de manière typée sans exceptions implicites.
sealed class DetFailure {
  const DetFailure({required this.message});

  /// Message lisible par l'utilisateur (en français).
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

// ── Réseau ────────────────────────────────────────────────────────────────────

/// Erreur réseau générale (pas de connexion, timeout, DNS…).
final class NetworkFailure extends DetFailure {
  const NetworkFailure({super.message = 'Erreur réseau. Vérifiez votre connexion.'});
}

/// Erreur de serveur HTTP (4xx / 5xx).
final class ServerFailure extends DetFailure {
  const ServerFailure({required super.message, this.statusCode});
  final int? statusCode;
}

// ── WebSocket ─────────────────────────────────────────────────────────────────

/// Connexion WebSocket perdue ou impossible à établir.
final class WebSocketFailure extends DetFailure {
  const WebSocketFailure({
    super.message = 'Connexion au boîtier perdue.',
    this.closeCode,
  });
  final int? closeCode;
}

// ── Device ────────────────────────────────────────────────────────────────────

/// Boîtier DetAI introuvable sur le réseau local.
final class DeviceNotFoundFailure extends DetFailure {
  const DeviceNotFoundFailure({
    super.message = 'Boîtier DetAI introuvable sur ce réseau.',
  });
}

/// Connexion au boîtier refusée ou timeout.
final class DeviceConnectionFailure extends DetFailure {
  const DeviceConnectionFailure({
    super.message = 'Impossible de se connecter au boîtier.',
  });
}

// ── Exercice ──────────────────────────────────────────────────────────────────

/// Erreur lors de la capture photo.
final class CameraFailure extends DetFailure {
  const CameraFailure({super.message = 'Erreur lors de la prise de photo.'});
}

/// Erreur lors de l'analyse RAG de l'exercice.
final class RagFailure extends DetFailure {
  const RagFailure({super.message = 'Erreur d\'analyse de l\'exercice.'});
}

// ── Stockage local ────────────────────────────────────────────────────────────

/// Erreur de lecture/écriture dans le stockage local (Hive).
final class StorageFailure extends DetFailure {
  const StorageFailure({super.message = 'Erreur de stockage local.'});
}

// ── Permission ────────────────────────────────────────────────────────────────

/// Permission système refusée (caméra, réseau…).
final class PermissionFailure extends DetFailure {
  const PermissionFailure({super.message = 'Permission refusée.'});
}

// ── Générique ─────────────────────────────────────────────────────────────────

/// Erreur inattendue non catégorisée.
final class UnexpectedFailure extends DetFailure {
  const UnexpectedFailure({super.message = 'Une erreur inattendue est survenue.'});
}

// ══════════════════════════════════════════════════════════════════════════════
// ALIASES
// ══════════════════════════════════════════════════════════════════════════════

/// Alias principal : résultat typé utilisé dans tous les repositories et usecases.
/// Usage : `DetResult<List<DeviceEntity>>` plutôt que `Either<DetFailure, List<DeviceEntity>>`.
typedef DetResult<T> = Either<DetFailure, T>;

/// Alias pour un résultat sans valeur de retour (void-like).
typedef DetVoidResult = Either<DetFailure, Unit>;

// ══════════════════════════════════════════════════════════════════════════════
// EXTENSIONS UTILITAIRES
// ══════════════════════════════════════════════════════════════════════════════

extension DetResultX<T> on DetResult<T> {
  /// Retourne la valeur ou null si c'est un Left (Failure).
  T? getOrNull() => fold((_) => null, (v) => v);

  /// Retourne true si c'est un succès (Right).
  bool get isSuccess => isRight();

  /// Retourne true si c'est une erreur (Left).
  bool get isFailure => isLeft();

  /// Retourne le Failure ou null.
  DetFailure? get failureOrNull => fold((f) => f, (_) => null);
}

/// Helper pour convertir une exception en [DetFailure] générique.
DetFailure mapExceptionToFailure(Object error) {
  return switch (error) {
    final DetFailure f => f,
    _ => UnexpectedFailure(message: error.toString()),
  };
}
