// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HintEntity _$HintEntityFromJson(Map<String, dynamic> json) => _HintEntity(
      index: (json['index'] as num).toInt(),
      content: json['content'] as String,
      type: $enumDecodeNullable(_$HintTypeEnumMap, json['type']) ??
          HintType.question,
      isNew: json['isNew'] as bool? ?? false,
    );

Map<String, dynamic> _$HintEntityToJson(_HintEntity instance) =>
    <String, dynamic>{
      'index': instance.index,
      'content': instance.content,
      'type': _$HintTypeEnumMap[instance.type]!,
      'isNew': instance.isNew,
    };

const _$HintTypeEnumMap = {
  HintType.question: 'question',
  HintType.observation: 'observation',
  HintType.reminder: 'reminder',
};

_ExerciseEntity _$ExerciseEntityFromJson(Map<String, dynamic> json) =>
    _ExerciseEntity(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      subject: $enumDecodeNullable(_$SchoolSubjectEnumMap, json['subject']) ??
          SchoolSubject.autre,
      level: $enumDecodeNullable(_$SchoolLevelEnumMap, json['level']),
      hints: (json['hints'] as List<dynamic>?)
              ?.map((e) => HintEntity.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      status: $enumDecodeNullable(_$ExerciseStatusEnumMap, json['status']) ??
          ExerciseStatus.idle,
      error: json['error'] as String?,
      capturedAt: json['capturedAt'] == null
          ? null
          : DateTime.parse(json['capturedAt'] as String),
    );

Map<String, dynamic> _$ExerciseEntityToJson(_ExerciseEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imagePath': instance.imagePath,
      'subject': _$SchoolSubjectEnumMap[instance.subject]!,
      'level': _$SchoolLevelEnumMap[instance.level],
      'hints': instance.hints,
      'status': _$ExerciseStatusEnumMap[instance.status]!,
      'error': instance.error,
      'capturedAt': instance.capturedAt?.toIso8601String(),
    };

const _$SchoolSubjectEnumMap = {
  SchoolSubject.maths: 'maths',
  SchoolSubject.physique: 'physique',
  SchoolSubject.svt: 'svt',
  SchoolSubject.francais: 'francais',
  SchoolSubject.philosophie: 'philosophie',
  SchoolSubject.histoire: 'histoire',
  SchoolSubject.anglais: 'anglais',
  SchoolSubject.autre: 'autre',
};

const _$SchoolLevelEnumMap = {
  SchoolLevel.seconde: 'seconde',
  SchoolLevel.premiere: 'premiere',
  SchoolLevel.terminale: 'terminale',
};

const _$ExerciseStatusEnumMap = {
  ExerciseStatus.idle: 'idle',
  ExerciseStatus.capturing: 'capturing',
  ExerciseStatus.processing: 'processing',
  ExerciseStatus.waitingHints: 'waitingHints',
  ExerciseStatus.hintsReceived: 'hintsReceived',
  ExerciseStatus.error: 'error',
};
