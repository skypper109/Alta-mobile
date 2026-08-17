// ─── DetAI — Feature: Exercise — Entities ────────────────────────────────────
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_entity.freezed.dart';
part 'exercise_entity.g.dart';

// ══════════════════════════════════════════════════════════════════════════════
// HINT ENTITY — Indice socratique progressif
// ══════════════════════════════════════════════════════════════════════════════

/// Un indice fourni par le moteur RAG du boîtier.
/// IMPORTANT : ne jamais contenir la solution directe.
@freezed
abstract class HintEntity with _$HintEntity {
  const factory HintEntity({
    /// Numéro de l'indice (1 = premier indice, le plus vague).
    required int index,

    /// Texte de l'indice (question socratique ou piste de réflexion).
    required String content,

    /// Indique si cet indice est de type "question" ou "observation".
    @Default(HintType.question) HintType type,

    /// Indique si l'indice vient d'être reçu (pour animation d'entrée).
    @Default(false) bool isNew,
  }) = _HintEntity;

  factory HintEntity.fromJson(Map<String, dynamic> json) =>
      _$HintEntityFromJson(json);
}

/// Type d'indice socratique.
enum HintType {
  /// Question ouverte guidant la réflexion.
  question,

  /// Observation sur l'énoncé ou la démarche.
  observation,

  /// Rappel d'un théorème ou d'une propriété.
  reminder,
}

// ══════════════════════════════════════════════════════════════════════════════
// EXERCISE ENTITY — Exercice scanné
// ══════════════════════════════════════════════════════════════════════════════

/// Matière scolaire.
enum SchoolSubject {
  maths,
  physique,
  svt,
  francais,
  philosophie,
  histoire,
  anglais,
  autre;

  String get label => switch (this) {
    SchoolSubject.maths       => 'Mathématiques',
    SchoolSubject.physique     => 'Physique-Chimie',
    SchoolSubject.svt          => 'SVT',
    SchoolSubject.francais     => 'Français',
    SchoolSubject.philosophie  => 'Philosophie',
    SchoolSubject.histoire     => 'Histoire-Géo',
    SchoolSubject.anglais      => 'Anglais',
    SchoolSubject.autre        => 'Autre',
  };
}

/// Niveau scolaire.
enum SchoolLevel { seconde, premiere, terminale }

extension SchoolLevelX on SchoolLevel {
  String get label => switch (this) {
    SchoolLevel.seconde   => 'Seconde',
    SchoolLevel.premiere  => 'Première',
    SchoolLevel.terminale => 'Terminale',
  };
}

/// Entité représentant un exercice scanné et ses indices.
@freezed
abstract class ExerciseEntity with _$ExerciseEntity {
  const factory ExerciseEntity({
    /// Identifiant unique de l'exercice.
    required String id,

    /// Chemin local de l'image capturée.
    required String imagePath,

    /// Matière détectée (ou choisie par l'élève).
    @Default(SchoolSubject.autre) SchoolSubject subject,

    /// Niveau scolaire (si détecté ou sélectionné).
    SchoolLevel? level,

    /// Indices progressifs reçus du moteur RAG.
    @Default([]) List<HintEntity> hints,

    /// Statut de l'analyse.
    @Default(ExerciseStatus.idle) ExerciseStatus status,

    /// Erreur éventuelle.
    String? error,

    /// Horodatage de la capture.
    DateTime? capturedAt,
  }) = _ExerciseEntity;

  factory ExerciseEntity.fromJson(Map<String, dynamic> json) =>
      _$ExerciseEntityFromJson(json);
}

/// Statut du traitement d'un exercice.
enum ExerciseStatus {
  /// Prêt à scanner.
  idle,

  /// Capture en cours (caméra ouverte).
  capturing,

  /// Recadrage / traitement de l'image.
  processing,

  /// En attente de réponse du moteur RAG.
  waitingHints,

  /// Indices reçus et affichés.
  hintsReceived,

  /// Erreur pendant le traitement.
  error,
}
