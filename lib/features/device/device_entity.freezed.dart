// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceEntity {
  /// Identifiant unique (dérivé de l'adresse MAC ou de l'IP).
  String get id;

  /// Nom d'affichage du boîtier (ex: "DetAI-Classroom-01").
  String get name;

  /// Adresse IP locale du boîtier.
  String get ipAddress;

  /// Port WebSocket du boîtier (default: 8080).
  int get port;

  /// Force du signal Wi-Fi (RSSI, entre -100 dBm et 0 dBm).
  /// -1 si non disponible.
  int get signalStrength;

  /// Indique si la connexion WebSocket est active.
  bool get isConnected;

  /// Horodatage de la dernière détection.
  DateTime? get lastSeen;

  /// Version du firmware du boîtier (si disponible).
  String? get firmwareVersion;

  /// Create a copy of DeviceEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DeviceEntityCopyWith<DeviceEntity> get copyWith =>
      _$DeviceEntityCopyWithImpl<DeviceEntity>(
          this as DeviceEntity, _$identity);

  /// Serializes this DeviceEntity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DeviceEntity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.signalStrength, signalStrength) ||
                other.signalStrength == signalStrength) &&
            (identical(other.isConnected, isConnected) ||
                other.isConnected == isConnected) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.firmwareVersion, firmwareVersion) ||
                other.firmwareVersion == firmwareVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, ipAddress, port,
      signalStrength, isConnected, lastSeen, firmwareVersion);

  @override
  String toString() {
    return 'DeviceEntity(id: $id, name: $name, ipAddress: $ipAddress, port: $port, signalStrength: $signalStrength, isConnected: $isConnected, lastSeen: $lastSeen, firmwareVersion: $firmwareVersion)';
  }
}

/// @nodoc
abstract mixin class $DeviceEntityCopyWith<$Res> {
  factory $DeviceEntityCopyWith(
          DeviceEntity value, $Res Function(DeviceEntity) _then) =
      _$DeviceEntityCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String ipAddress,
      int port,
      int signalStrength,
      bool isConnected,
      DateTime? lastSeen,
      String? firmwareVersion});
}

/// @nodoc
class _$DeviceEntityCopyWithImpl<$Res> implements $DeviceEntityCopyWith<$Res> {
  _$DeviceEntityCopyWithImpl(this._self, this._then);

  final DeviceEntity _self;
  final $Res Function(DeviceEntity) _then;

  /// Create a copy of DeviceEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ipAddress = null,
    Object? port = null,
    Object? signalStrength = null,
    Object? isConnected = null,
    Object? lastSeen = freezed,
    Object? firmwareVersion = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ipAddress: null == ipAddress
          ? _self.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String,
      port: null == port
          ? _self.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      signalStrength: null == signalStrength
          ? _self.signalStrength
          : signalStrength // ignore: cast_nullable_to_non_nullable
              as int,
      isConnected: null == isConnected
          ? _self.isConnected
          : isConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSeen: freezed == lastSeen
          ? _self.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      firmwareVersion: freezed == firmwareVersion
          ? _self.firmwareVersion
          : firmwareVersion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [DeviceEntity].
extension DeviceEntityPatterns on DeviceEntity {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DeviceEntity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeviceEntity() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DeviceEntity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceEntity():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DeviceEntity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceEntity() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String ipAddress,
            int port,
            int signalStrength,
            bool isConnected,
            DateTime? lastSeen,
            String? firmwareVersion)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DeviceEntity() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.ipAddress,
            _that.port,
            _that.signalStrength,
            _that.isConnected,
            _that.lastSeen,
            _that.firmwareVersion);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            String ipAddress,
            int port,
            int signalStrength,
            bool isConnected,
            DateTime? lastSeen,
            String? firmwareVersion)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceEntity():
        return $default(
            _that.id,
            _that.name,
            _that.ipAddress,
            _that.port,
            _that.signalStrength,
            _that.isConnected,
            _that.lastSeen,
            _that.firmwareVersion);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String name,
            String ipAddress,
            int port,
            int signalStrength,
            bool isConnected,
            DateTime? lastSeen,
            String? firmwareVersion)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DeviceEntity() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.ipAddress,
            _that.port,
            _that.signalStrength,
            _that.isConnected,
            _that.lastSeen,
            _that.firmwareVersion);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DeviceEntity implements DeviceEntity {
  const _DeviceEntity(
      {required this.id,
      required this.name,
      required this.ipAddress,
      this.port = 8080,
      this.signalStrength = -1,
      this.isConnected = false,
      this.lastSeen,
      this.firmwareVersion});
  factory _DeviceEntity.fromJson(Map<String, dynamic> json) =>
      _$DeviceEntityFromJson(json);

  /// Identifiant unique (dérivé de l'adresse MAC ou de l'IP).
  @override
  final String id;

  /// Nom d'affichage du boîtier (ex: "DetAI-Classroom-01").
  @override
  final String name;

  /// Adresse IP locale du boîtier.
  @override
  final String ipAddress;

  /// Port WebSocket du boîtier (default: 8080).
  @override
  @JsonKey()
  final int port;

  /// Force du signal Wi-Fi (RSSI, entre -100 dBm et 0 dBm).
  /// -1 si non disponible.
  @override
  @JsonKey()
  final int signalStrength;

  /// Indique si la connexion WebSocket est active.
  @override
  @JsonKey()
  final bool isConnected;

  /// Horodatage de la dernière détection.
  @override
  final DateTime? lastSeen;

  /// Version du firmware du boîtier (si disponible).
  @override
  final String? firmwareVersion;

  /// Create a copy of DeviceEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeviceEntityCopyWith<_DeviceEntity> get copyWith =>
      __$DeviceEntityCopyWithImpl<_DeviceEntity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DeviceEntityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DeviceEntity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.signalStrength, signalStrength) ||
                other.signalStrength == signalStrength) &&
            (identical(other.isConnected, isConnected) ||
                other.isConnected == isConnected) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.firmwareVersion, firmwareVersion) ||
                other.firmwareVersion == firmwareVersion));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, ipAddress, port,
      signalStrength, isConnected, lastSeen, firmwareVersion);

  @override
  String toString() {
    return 'DeviceEntity(id: $id, name: $name, ipAddress: $ipAddress, port: $port, signalStrength: $signalStrength, isConnected: $isConnected, lastSeen: $lastSeen, firmwareVersion: $firmwareVersion)';
  }
}

/// @nodoc
abstract mixin class _$DeviceEntityCopyWith<$Res>
    implements $DeviceEntityCopyWith<$Res> {
  factory _$DeviceEntityCopyWith(
          _DeviceEntity value, $Res Function(_DeviceEntity) _then) =
      __$DeviceEntityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String ipAddress,
      int port,
      int signalStrength,
      bool isConnected,
      DateTime? lastSeen,
      String? firmwareVersion});
}

/// @nodoc
class __$DeviceEntityCopyWithImpl<$Res>
    implements _$DeviceEntityCopyWith<$Res> {
  __$DeviceEntityCopyWithImpl(this._self, this._then);

  final _DeviceEntity _self;
  final $Res Function(_DeviceEntity) _then;

  /// Create a copy of DeviceEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ipAddress = null,
    Object? port = null,
    Object? signalStrength = null,
    Object? isConnected = null,
    Object? lastSeen = freezed,
    Object? firmwareVersion = freezed,
  }) {
    return _then(_DeviceEntity(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      ipAddress: null == ipAddress
          ? _self.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String,
      port: null == port
          ? _self.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      signalStrength: null == signalStrength
          ? _self.signalStrength
          : signalStrength // ignore: cast_nullable_to_non_nullable
              as int,
      isConnected: null == isConnected
          ? _self.isConnected
          : isConnected // ignore: cast_nullable_to_non_nullable
              as bool,
      lastSeen: freezed == lastSeen
          ? _self.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      firmwareVersion: freezed == firmwareVersion
          ? _self.firmwareVersion
          : firmwareVersion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
