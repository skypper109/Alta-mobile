// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CompetencyEntry _$CompetencyEntryFromJson(Map<String, dynamic> json) =>
    _CompetencyEntry(
      name: json['name'] as String,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      sessionCount: (json['sessionCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$CompetencyEntryToJson(_CompetencyEntry instance) =>
    <String, dynamic>{
      'name': instance.name,
      'score': instance.score,
      'sessionCount': instance.sessionCount,
    };

_CompetencyRadar _$CompetencyRadarFromJson(Map<String, dynamic> json) =>
    _CompetencyRadar(
      subject: json['subject'] as String,
      entries: (json['entries'] as List<dynamic>?)
              ?.map((e) => CompetencyEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CompetencyRadarToJson(_CompetencyRadar instance) =>
    <String, dynamic>{
      'subject': instance.subject,
      'entries': instance.entries,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_ProgressEntry _$ProgressEntryFromJson(Map<String, dynamic> json) =>
    _ProgressEntry(
      id: json['id'] as String,
      subject: json['subject'] as String,
      date: DateTime.parse(json['date'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      hintsUsed: (json['hintsUsed'] as num?)?.toInt() ?? 0,
      progressScore: (json['progressScore'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ProgressEntryToJson(_ProgressEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'subject': instance.subject,
      'date': instance.date.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'hintsUsed': instance.hintsUsed,
      'progressScore': instance.progressScore,
      'notes': instance.notes,
    };
