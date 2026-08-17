// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeviceEntity _$DeviceEntityFromJson(Map<String, dynamic> json) =>
    _DeviceEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      ipAddress: json['ipAddress'] as String,
      port: (json['port'] as num?)?.toInt() ?? 8080,
      signalStrength: (json['signalStrength'] as num?)?.toInt() ?? -1,
      isConnected: json['isConnected'] as bool? ?? false,
      lastSeen: json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
      firmwareVersion: json['firmwareVersion'] as String?,
    );

Map<String, dynamic> _$DeviceEntityToJson(_DeviceEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ipAddress': instance.ipAddress,
      'port': instance.port,
      'signalStrength': instance.signalStrength,
      'isConnected': instance.isConnected,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'firmwareVersion': instance.firmwareVersion,
    };
