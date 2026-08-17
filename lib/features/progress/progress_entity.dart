// ─── DetAI — Feature: Progress — Entities ────────────────────────────────────
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress_entity.freezed.dart';
part 'progress_entity.g.dart';

// ══════════════════════════════════════════════════════════════════════════════
// COMPETENCY ENTRY — Score par compétence
// ══════════════════════════════════════════════════════════════════════════════

/// Score d'une compétence dans une matière donnée.
@freezed
abstract class CompetencyEntry with _$CompetencyEntry {
  const factory CompetencyEntry({
    /// Nom de la compétence (ex: 'Algèbre', 'Analyse', 'Probabilités').
    required String name,

    /// Score normalisé entre 0.0 et 1.0.
    @Default(0.0) double score,

    /// Nombre de sessions ayant contribué à ce score.
    @Default(0) int sessionCount,
  }) = _CompetencyEntry;

  factory CompetencyEntry.fromJson(Map<String, dynamic> json) =>
      _$CompetencyEntryFromJson(json);
}

// ══════════════════════════════════════════════════════════════════════════════
// COMPETENCY RADAR — Profil radar par matière
// ══════════════════════════════════════════════════════════════════════════════

/// Profil de compétences pour une matière (données du graphique radar).
@freezed
abstract class CompetencyRadar with _$CompetencyRadar {
  const factory CompetencyRadar({
    required String subject,
    @Default([]) List<CompetencyEntry> entries,
    DateTime? updatedAt,
  }) = _CompetencyRadar;

  factory CompetencyRadar.fromJson(Map<String, dynamic> json) =>
      _$CompetencyRadarFromJson(json);
}

// ══════════════════════════════════════════════════════════════════════════════
// PROGRESS ENTRY — Entrée d'historique
// ══════════════════════════════════════════════════════════════════════════════

/// Entrée d'historique d'une session pédagogique.
@freezed
abstract class ProgressEntry with _$ProgressEntry {
  const factory ProgressEntry({
    required String id,
    required String subject,
    required DateTime date,
    required int     durationMinutes,
    @Default(0)      int hintsUsed,
    @Default(0.0)    double progressScore,
    String?          notes,
  }) = _ProgressEntry;

  factory ProgressEntry.fromJson(Map<String, dynamic> json) =>
      _$ProgressEntryFromJson(json);
}

// ══════════════════════════════════════════════════════════════════════════════
// DONNÉES DE DÉMONSTRATION
// ══════════════════════════════════════════════════════════════════════════════

/// Données de démo pour tester le graphique radar sans boîtier.
final List<CompetencyRadar> demoRadarData = [
  const CompetencyRadar(
    subject: 'Mathématiques',
    entries: [
      CompetencyEntry(name: 'Algèbre',         score: 0.72),
      CompetencyEntry(name: 'Analyse',          score: 0.58),
      CompetencyEntry(name: 'Probabilités',     score: 0.81),
      CompetencyEntry(name: 'Géométrie',        score: 0.65),
      CompetencyEntry(name: 'Logique',          score: 0.77),
    ],
  ),
  const CompetencyRadar(
    subject: 'Physique-Chimie',
    entries: [
      CompetencyEntry(name: 'Mécanique',        score: 0.60),
      CompetencyEntry(name: 'Électricité',       score: 0.55),
      CompetencyEntry(name: 'Thermodynamique',  score: 0.70),
      CompetencyEntry(name: 'Chimie organique', score: 0.45),
      CompetencyEntry(name: 'Optique',          score: 0.80),
    ],
  ),
];
