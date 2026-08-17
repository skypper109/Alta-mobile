// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SessionMessage {
  /// Identifiant unique du message.
  String get id;

  /// Contenu textuel du message.
  String get content;

  /// Locuteur du message (élève ou IA).
  Speaker get speaker;

  /// Horodatage du message.
  DateTime get timestamp;

  /// Indique si le message est en cours de transcription (partiel).
  bool get isPartial;

  /// Create a copy of SessionMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SessionMessageCopyWith<SessionMessage> get copyWith =>
      _$SessionMessageCopyWithImpl<SessionMessage>(
          this as SessionMessage, _$identity);

  /// Serializes this SessionMessage to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SessionMessage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.speaker, speaker) || other.speaker == speaker) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isPartial, isPartial) ||
                other.isPartial == isPartial));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, content, speaker, timestamp, isPartial);

  @override
  String toString() {
    return 'SessionMessage(id: $id, content: $content, speaker: $speaker, timestamp: $timestamp, isPartial: $isPartial)';
  }
}

/// @nodoc
abstract mixin class $SessionMessageCopyWith<$Res> {
  factory $SessionMessageCopyWith(
          SessionMessage value, $Res Function(SessionMessage) _then) =
      _$SessionMessageCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String content,
      Speaker speaker,
      DateTime timestamp,
      bool isPartial});
}

/// @nodoc
class _$SessionMessageCopyWithImpl<$Res>
    implements $SessionMessageCopyWith<$Res> {
  _$SessionMessageCopyWithImpl(this._self, this._then);

  final SessionMessage _self;
  final $Res Function(SessionMessage) _then;

  /// Create a copy of SessionMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? speaker = null,
    Object? timestamp = null,
    Object? isPartial = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      speaker: null == speaker
          ? _self.speaker
          : speaker // ignore: cast_nullable_to_non_nullable
              as Speaker,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isPartial: null == isPartial
          ? _self.isPartial
          : isPartial // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [SessionMessage].
extension SessionMessagePatterns on SessionMessage {
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
    TResult Function(_SessionMessage value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SessionMessage() when $default != null:
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
    TResult Function(_SessionMessage value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SessionMessage():
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
    TResult? Function(_SessionMessage value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SessionMessage() when $default != null:
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
    TResult Function(String id, String content, Speaker speaker,
            DateTime timestamp, bool isPartial)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SessionMessage() when $default != null:
        return $default(_that.id, _that.content, _that.speaker, _that.timestamp,
            _that.isPartial);
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
    TResult Function(String id, String content, Speaker speaker,
            DateTime timestamp, bool isPartial)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SessionMessage():
        return $default(_that.id, _that.content, _that.speaker, _that.timestamp,
            _that.isPartial);
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
    TResult? Function(String id, String content, Speaker speaker,
            DateTime timestamp, bool isPartial)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SessionMessage() when $default != null:
        return $default(_that.id, _that.content, _that.speaker, _that.timestamp,
            _that.isPartial);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SessionMessage implements SessionMessage {
  const _SessionMessage(
      {required this.id,
      required this.content,
      required this.speaker,
      required this.timestamp,
      this.isPartial = false});
  factory _SessionMessage.fromJson(Map<String, dynamic> json) =>
      _$SessionMessageFromJson(json);

  /// Identifiant unique du message.
  @override
  final String id;

  /// Contenu textuel du message.
  @override
  final String content;

  /// Locuteur du message (élève ou IA).
  @override
  final Speaker speaker;

  /// Horodatage du message.
  @override
  final DateTime timestamp;

  /// Indique si le message est en cours de transcription (partiel).
  @override
  @JsonKey()
  final bool isPartial;

  /// Create a copy of SessionMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SessionMessageCopyWith<_SessionMessage> get copyWith =>
      __$SessionMessageCopyWithImpl<_SessionMessage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SessionMessageToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SessionMessage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.speaker, speaker) || other.speaker == speaker) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isPartial, isPartial) ||
                other.isPartial == isPartial));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, content, speaker, timestamp, isPartial);

  @override
  String toString() {
    return 'SessionMessage(id: $id, content: $content, speaker: $speaker, timestamp: $timestamp, isPartial: $isPartial)';
  }
}

/// @nodoc
abstract mixin class _$SessionMessageCopyWith<$Res>
    implements $SessionMessageCopyWith<$Res> {
  factory _$SessionMessageCopyWith(
          _SessionMessage value, $Res Function(_SessionMessage) _then) =
      __$SessionMessageCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String content,
      Speaker speaker,
      DateTime timestamp,
      bool isPartial});
}

/// @nodoc
class __$SessionMessageCopyWithImpl<$Res>
    implements _$SessionMessageCopyWith<$Res> {
  __$SessionMessageCopyWithImpl(this._self, this._then);

  final _SessionMessage _self;
  final $Res Function(_SessionMessage) _then;

  /// Create a copy of SessionMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? speaker = null,
    Object? timestamp = null,
    Object? isPartial = null,
  }) {
    return _then(_SessionMessage(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      speaker: null == speaker
          ? _self.speaker
          : speaker // ignore: cast_nullable_to_non_nullable
              as Speaker,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isPartial: null == isPartial
          ? _self.isPartial
          : isPartial // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$WsEvent {
  WsEventType get type;
  Map<String, dynamic> get payload;
  DateTime get receivedAt;

  /// Create a copy of WsEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $WsEventCopyWith<WsEvent> get copyWith =>
      _$WsEventCopyWithImpl<WsEvent>(this as WsEvent, _$identity);

  /// Serializes this WsEvent to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is WsEvent &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other.payload, payload) &&
            (identical(other.receivedAt, receivedAt) ||
                other.receivedAt == receivedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type,
      const DeepCollectionEquality().hash(payload), receivedAt);

  @override
  String toString() {
    return 'WsEvent(type: $type, payload: $payload, receivedAt: $receivedAt)';
  }
}

/// @nodoc
abstract mixin class $WsEventCopyWith<$Res> {
  factory $WsEventCopyWith(WsEvent value, $Res Function(WsEvent) _then) =
      _$WsEventCopyWithImpl;
  @useResult
  $Res call(
      {WsEventType type, Map<String, dynamic> payload, DateTime receivedAt});
}

/// @nodoc
class _$WsEventCopyWithImpl<$Res> implements $WsEventCopyWith<$Res> {
  _$WsEventCopyWithImpl(this._self, this._then);

  final WsEvent _self;
  final $Res Function(WsEvent) _then;

  /// Create a copy of WsEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? payload = null,
    Object? receivedAt = null,
  }) {
    return _then(_self.copyWith(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as WsEventType,
      payload: null == payload
          ? _self.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      receivedAt: null == receivedAt
          ? _self.receivedAt
          : receivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// Adds pattern-matching-related methods to [WsEvent].
extension WsEventPatterns on WsEvent {
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
    TResult Function(_WsEvent value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WsEvent() when $default != null:
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
    TResult Function(_WsEvent value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WsEvent():
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
    TResult? Function(_WsEvent value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WsEvent() when $default != null:
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
    TResult Function(WsEventType type, Map<String, dynamic> payload,
            DateTime receivedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _WsEvent() when $default != null:
        return $default(_that.type, _that.payload, _that.receivedAt);
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
            WsEventType type, Map<String, dynamic> payload, DateTime receivedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WsEvent():
        return $default(_that.type, _that.payload, _that.receivedAt);
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
    TResult? Function(WsEventType type, Map<String, dynamic> payload,
            DateTime receivedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _WsEvent() when $default != null:
        return $default(_that.type, _that.payload, _that.receivedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _WsEvent implements WsEvent {
  const _WsEvent(
      {required this.type,
      required final Map<String, dynamic> payload,
      required this.receivedAt})
      : _payload = payload;
  factory _WsEvent.fromJson(Map<String, dynamic> json) =>
      _$WsEventFromJson(json);

  @override
  final WsEventType type;
  final Map<String, dynamic> _payload;
  @override
  Map<String, dynamic> get payload {
    if (_payload is EqualUnmodifiableMapView) return _payload;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_payload);
  }

  @override
  final DateTime receivedAt;

  /// Create a copy of WsEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$WsEventCopyWith<_WsEvent> get copyWith =>
      __$WsEventCopyWithImpl<_WsEvent>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$WsEventToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _WsEvent &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._payload, _payload) &&
            (identical(other.receivedAt, receivedAt) ||
                other.receivedAt == receivedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type,
      const DeepCollectionEquality().hash(_payload), receivedAt);

  @override
  String toString() {
    return 'WsEvent(type: $type, payload: $payload, receivedAt: $receivedAt)';
  }
}

/// @nodoc
abstract mixin class _$WsEventCopyWith<$Res> implements $WsEventCopyWith<$Res> {
  factory _$WsEventCopyWith(_WsEvent value, $Res Function(_WsEvent) _then) =
      __$WsEventCopyWithImpl;
  @override
  @useResult
  $Res call(
      {WsEventType type, Map<String, dynamic> payload, DateTime receivedAt});
}

/// @nodoc
class __$WsEventCopyWithImpl<$Res> implements _$WsEventCopyWith<$Res> {
  __$WsEventCopyWithImpl(this._self, this._then);

  final _WsEvent _self;
  final $Res Function(_WsEvent) _then;

  /// Create a copy of WsEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? type = null,
    Object? payload = null,
    Object? receivedAt = null,
  }) {
    return _then(_WsEvent(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as WsEventType,
      payload: null == payload
          ? _self._payload
          : payload // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      receivedAt: null == receivedAt
          ? _self.receivedAt
          : receivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

// dart format on
