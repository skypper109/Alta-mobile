// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionMessage _$SessionMessageFromJson(Map<String, dynamic> json) =>
    _SessionMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      speaker: $enumDecode(_$SpeakerEnumMap, json['speaker']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isPartial: json['isPartial'] as bool? ?? false,
    );

Map<String, dynamic> _$SessionMessageToJson(_SessionMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'speaker': _$SpeakerEnumMap[instance.speaker]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'isPartial': instance.isPartial,
    };

const _$SpeakerEnumMap = {
  Speaker.student: 'student',
  Speaker.ai: 'ai',
};

_WsEvent _$WsEventFromJson(Map<String, dynamic> json) => _WsEvent(
      type: $enumDecode(_$WsEventTypeEnumMap, json['type']),
      payload: json['payload'] as Map<String, dynamic>,
      receivedAt: DateTime.parse(json['receivedAt'] as String),
    );

Map<String, dynamic> _$WsEventToJson(_WsEvent instance) => <String, dynamic>{
      'type': _$WsEventTypeEnumMap[instance.type]!,
      'payload': instance.payload,
      'receivedAt': instance.receivedAt.toIso8601String(),
    };

const _$WsEventTypeEnumMap = {
  WsEventType.transcript: 'transcript',
  WsEventType.aiState: 'aiState',
  WsEventType.amplitude: 'amplitude',
  WsEventType.unknown: 'unknown',
};
