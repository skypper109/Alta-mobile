// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HintEntity {
  /// Numéro de l'indice (1 = premier indice, le plus vague).
  int get index;

  /// Texte de l'indice (question socratique ou piste de réflexion).
  String get content;

  /// Indique si cet indice est de type "question" ou "observation".
  HintType get type;

  /// Indique si l'indice vient d'être reçu (pour animation d'entrée).
  bool get isNew;

  /// Create a copy of HintEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HintEntityCopyWith<HintEntity> get copyWith =>
      _$HintEntityCopyWithImpl<HintEntity>(this as HintEntity, _$identity);

  /// Serializes this HintEntity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HintEntity &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isNew, isNew) || other.isNew == isNew));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, index, content, type, isNew);

  @override
  String toString() {
    return 'HintEntity(index: $index, content: $content, type: $type, isNew: $isNew)';
  }
}

/// @nodoc
abstract mixin class $HintEntityCopyWith<$Res> {
  factory $HintEntityCopyWith(
          HintEntity value, $Res Function(HintEntity) _then) =
      _$HintEntityCopyWithImpl;
  @useResult
  $Res call({int index, String content, HintType type, bool isNew});
}

/// @nodoc
class _$HintEntityCopyWithImpl<$Res> implements $HintEntityCopyWith<$Res> {
  _$HintEntityCopyWithImpl(this._self, this._then);

  final HintEntity _self;
  final $Res Function(HintEntity) _then;

  /// Create a copy of HintEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? content = null,
    Object? type = null,
    Object? isNew = null,
  }) {
    return _then(_self.copyWith(
      index: null == index
          ? _self.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as HintType,
      isNew: null == isNew
          ? _self.isNew
          : isNew // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [HintEntity].
extension HintEntityPatterns on HintEntity {
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
    TResult Function(_HintEntity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HintEntity() when $default != null:
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
    TResult Function(_HintEntity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HintEntity():
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
    TResult? Function(_HintEntity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HintEntity() when $default != null:
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
    TResult Function(int index, String content, HintType type, bool isNew)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HintEntity() when $default != null:
        return $default(_that.index, _that.content, _that.type, _that.isNew);
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
    TResult Function(int index, String content, HintType type, bool isNew)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HintEntity():
        return $default(_that.index, _that.content, _that.type, _that.isNew);
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
    TResult? Function(int index, String content, HintType type, bool isNew)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HintEntity() when $default != null:
        return $default(_that.index, _that.content, _that.type, _that.isNew);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _HintEntity implements HintEntity {
  const _HintEntity(
      {required this.index,
      required this.content,
      this.type = HintType.question,
      this.isNew = false});
  factory _HintEntity.fromJson(Map<String, dynamic> json) =>
      _$HintEntityFromJson(json);

  /// Numéro de l'indice (1 = premier indice, le plus vague).
  @override
  final int index;

  /// Texte de l'indice (question socratique ou piste de réflexion).
  @override
  final String content;

  /// Indique si cet indice est de type "question" ou "observation".
  @override
  @JsonKey()
  final HintType type;

  /// Indique si l'indice vient d'être reçu (pour animation d'entrée).
  @override
  @JsonKey()
  final bool isNew;

  /// Create a copy of HintEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HintEntityCopyWith<_HintEntity> get copyWith =>
      __$HintEntityCopyWithImpl<_HintEntity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HintEntityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HintEntity &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isNew, isNew) || other.isNew == isNew));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, index, content, type, isNew);

  @override
  String toString() {
    return 'HintEntity(index: $index, content: $content, type: $type, isNew: $isNew)';
  }
}

/// @nodoc
abstract mixin class _$HintEntityCopyWith<$Res>
    implements $HintEntityCopyWith<$Res> {
  factory _$HintEntityCopyWith(
          _HintEntity value, $Res Function(_HintEntity) _then) =
      __$HintEntityCopyWithImpl;
  @override
  @useResult
  $Res call({int index, String content, HintType type, bool isNew});
}

/// @nodoc
class __$HintEntityCopyWithImpl<$Res> implements _$HintEntityCopyWith<$Res> {
  __$HintEntityCopyWithImpl(this._self, this._then);

  final _HintEntity _self;
  final $Res Function(_HintEntity) _then;

  /// Create a copy of HintEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? index = null,
    Object? content = null,
    Object? type = null,
    Object? isNew = null,
  }) {
    return _then(_HintEntity(
      index: null == index
          ? _self.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as HintType,
      isNew: null == isNew
          ? _self.isNew
          : isNew // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$ExerciseEntity {
  /// Identifiant unique de l'exercice.
  String get id;

  /// Chemin local de l'image capturée.
  String get imagePath;

  /// Matière détectée (ou choisie par l'élève).
  SchoolSubject get subject;

  /// Niveau scolaire (si détecté ou sélectionné).
  SchoolLevel? get level;

  /// Indices progressifs reçus du moteur RAG.
  List<HintEntity> get hints;

  /// Statut de l'analyse.
  ExerciseStatus get status;

  /// Erreur éventuelle.
  String? get error;

  /// Horodatage de la capture.
  DateTime? get capturedAt;

  /// Create a copy of ExerciseEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExerciseEntityCopyWith<ExerciseEntity> get copyWith =>
      _$ExerciseEntityCopyWithImpl<ExerciseEntity>(
          this as ExerciseEntity, _$identity);

  /// Serializes this ExerciseEntity to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExerciseEntity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.level, level) || other.level == level) &&
            const DeepCollectionEquality().equals(other.hints, hints) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.capturedAt, capturedAt) ||
                other.capturedAt == capturedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, imagePath, subject, level,
      const DeepCollectionEquality().hash(hints), status, error, capturedAt);

  @override
  String toString() {
    return 'ExerciseEntity(id: $id, imagePath: $imagePath, subject: $subject, level: $level, hints: $hints, status: $status, error: $error, capturedAt: $capturedAt)';
  }
}

/// @nodoc
abstract mixin class $ExerciseEntityCopyWith<$Res> {
  factory $ExerciseEntityCopyWith(
          ExerciseEntity value, $Res Function(ExerciseEntity) _then) =
      _$ExerciseEntityCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String imagePath,
      SchoolSubject subject,
      SchoolLevel? level,
      List<HintEntity> hints,
      ExerciseStatus status,
      String? error,
      DateTime? capturedAt});
}

/// @nodoc
class _$ExerciseEntityCopyWithImpl<$Res>
    implements $ExerciseEntityCopyWith<$Res> {
  _$ExerciseEntityCopyWithImpl(this._self, this._then);

  final ExerciseEntity _self;
  final $Res Function(ExerciseEntity) _then;

  /// Create a copy of ExerciseEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? imagePath = null,
    Object? subject = null,
    Object? level = freezed,
    Object? hints = null,
    Object? status = null,
    Object? error = freezed,
    Object? capturedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imagePath: null == imagePath
          ? _self.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _self.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as SchoolSubject,
      level: freezed == level
          ? _self.level
          : level // ignore: cast_nullable_to_non_nullable
              as SchoolLevel?,
      hints: null == hints
          ? _self.hints
          : hints // ignore: cast_nullable_to_non_nullable
              as List<HintEntity>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as ExerciseStatus,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      capturedAt: freezed == capturedAt
          ? _self.capturedAt
          : capturedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ExerciseEntity].
extension ExerciseEntityPatterns on ExerciseEntity {
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
    TResult Function(_ExerciseEntity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExerciseEntity() when $default != null:
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
    TResult Function(_ExerciseEntity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseEntity():
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
    TResult? Function(_ExerciseEntity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseEntity() when $default != null:
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
            String imagePath,
            SchoolSubject subject,
            SchoolLevel? level,
            List<HintEntity> hints,
            ExerciseStatus status,
            String? error,
            DateTime? capturedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ExerciseEntity() when $default != null:
        return $default(_that.id, _that.imagePath, _that.subject, _that.level,
            _that.hints, _that.status, _that.error, _that.capturedAt);
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
            String imagePath,
            SchoolSubject subject,
            SchoolLevel? level,
            List<HintEntity> hints,
            ExerciseStatus status,
            String? error,
            DateTime? capturedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseEntity():
        return $default(_that.id, _that.imagePath, _that.subject, _that.level,
            _that.hints, _that.status, _that.error, _that.capturedAt);
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
            String imagePath,
            SchoolSubject subject,
            SchoolLevel? level,
            List<HintEntity> hints,
            ExerciseStatus status,
            String? error,
            DateTime? capturedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ExerciseEntity() when $default != null:
        return $default(_that.id, _that.imagePath, _that.subject, _that.level,
            _that.hints, _that.status, _that.error, _that.capturedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ExerciseEntity implements ExerciseEntity {
  const _ExerciseEntity(
      {required this.id,
      required this.imagePath,
      this.subject = SchoolSubject.autre,
      this.level,
      final List<HintEntity> hints = const [],
      this.status = ExerciseStatus.idle,
      this.error,
      this.capturedAt})
      : _hints = hints;
  factory _ExerciseEntity.fromJson(Map<String, dynamic> json) =>
      _$ExerciseEntityFromJson(json);

  /// Identifiant unique de l'exercice.
  @override
  final String id;

  /// Chemin local de l'image capturée.
  @override
  final String imagePath;

  /// Matière détectée (ou choisie par l'élève).
  @override
  @JsonKey()
  final SchoolSubject subject;

  /// Niveau scolaire (si détecté ou sélectionné).
  @override
  final SchoolLevel? level;

  /// Indices progressifs reçus du moteur RAG.
  final List<HintEntity> _hints;

  /// Indices progressifs reçus du moteur RAG.
  @override
  @JsonKey()
  List<HintEntity> get hints {
    if (_hints is EqualUnmodifiableListView) return _hints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hints);
  }

  /// Statut de l'analyse.
  @override
  @JsonKey()
  final ExerciseStatus status;

  /// Erreur éventuelle.
  @override
  final String? error;

  /// Horodatage de la capture.
  @override
  final DateTime? capturedAt;

  /// Create a copy of ExerciseEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExerciseEntityCopyWith<_ExerciseEntity> get copyWith =>
      __$ExerciseEntityCopyWithImpl<_ExerciseEntity>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ExerciseEntityToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExerciseEntity &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.level, level) || other.level == level) &&
            const DeepCollectionEquality().equals(other._hints, _hints) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.capturedAt, capturedAt) ||
                other.capturedAt == capturedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, imagePath, subject, level,
      const DeepCollectionEquality().hash(_hints), status, error, capturedAt);

  @override
  String toString() {
    return 'ExerciseEntity(id: $id, imagePath: $imagePath, subject: $subject, level: $level, hints: $hints, status: $status, error: $error, capturedAt: $capturedAt)';
  }
}

/// @nodoc
abstract mixin class _$ExerciseEntityCopyWith<$Res>
    implements $ExerciseEntityCopyWith<$Res> {
  factory _$ExerciseEntityCopyWith(
          _ExerciseEntity value, $Res Function(_ExerciseEntity) _then) =
      __$ExerciseEntityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String imagePath,
      SchoolSubject subject,
      SchoolLevel? level,
      List<HintEntity> hints,
      ExerciseStatus status,
      String? error,
      DateTime? capturedAt});
}

/// @nodoc
class __$ExerciseEntityCopyWithImpl<$Res>
    implements _$ExerciseEntityCopyWith<$Res> {
  __$ExerciseEntityCopyWithImpl(this._self, this._then);

  final _ExerciseEntity _self;
  final $Res Function(_ExerciseEntity) _then;

  /// Create a copy of ExerciseEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? imagePath = null,
    Object? subject = null,
    Object? level = freezed,
    Object? hints = null,
    Object? status = null,
    Object? error = freezed,
    Object? capturedAt = freezed,
  }) {
    return _then(_ExerciseEntity(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      imagePath: null == imagePath
          ? _self.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _self.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as SchoolSubject,
      level: freezed == level
          ? _self.level
          : level // ignore: cast_nullable_to_non_nullable
              as SchoolLevel?,
      hints: null == hints
          ? _self._hints
          : hints // ignore: cast_nullable_to_non_nullable
              as List<HintEntity>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as ExerciseStatus,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      capturedAt: freezed == capturedAt
          ? _self.capturedAt
          : capturedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
