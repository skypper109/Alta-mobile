// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CompetencyEntry {
  /// Nom de la compétence (ex: 'Algèbre', 'Analyse', 'Probabilités').
  String get name;

  /// Score normalisé entre 0.0 et 1.0.
  double get score;

  /// Nombre de sessions ayant contribué à ce score.
  int get sessionCount;

  /// Create a copy of CompetencyEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CompetencyEntryCopyWith<CompetencyEntry> get copyWith =>
      _$CompetencyEntryCopyWithImpl<CompetencyEntry>(
          this as CompetencyEntry, _$identity);

  /// Serializes this CompetencyEntry to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CompetencyEntry &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.sessionCount, sessionCount) ||
                other.sessionCount == sessionCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, score, sessionCount);

  @override
  String toString() {
    return 'CompetencyEntry(name: $name, score: $score, sessionCount: $sessionCount)';
  }
}

/// @nodoc
abstract mixin class $CompetencyEntryCopyWith<$Res> {
  factory $CompetencyEntryCopyWith(
          CompetencyEntry value, $Res Function(CompetencyEntry) _then) =
      _$CompetencyEntryCopyWithImpl;
  @useResult
  $Res call({String name, double score, int sessionCount});
}

/// @nodoc
class _$CompetencyEntryCopyWithImpl<$Res>
    implements $CompetencyEntryCopyWith<$Res> {
  _$CompetencyEntryCopyWithImpl(this._self, this._then);

  final CompetencyEntry _self;
  final $Res Function(CompetencyEntry) _then;

  /// Create a copy of CompetencyEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? score = null,
    Object? sessionCount = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      sessionCount: null == sessionCount
          ? _self.sessionCount
          : sessionCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [CompetencyEntry].
extension CompetencyEntryPatterns on CompetencyEntry {
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
    TResult Function(_CompetencyEntry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CompetencyEntry() when $default != null:
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
    TResult Function(_CompetencyEntry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompetencyEntry():
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
    TResult? Function(_CompetencyEntry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompetencyEntry() when $default != null:
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
    TResult Function(String name, double score, int sessionCount)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CompetencyEntry() when $default != null:
        return $default(_that.name, _that.score, _that.sessionCount);
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
    TResult Function(String name, double score, int sessionCount) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompetencyEntry():
        return $default(_that.name, _that.score, _that.sessionCount);
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
    TResult? Function(String name, double score, int sessionCount)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompetencyEntry() when $default != null:
        return $default(_that.name, _that.score, _that.sessionCount);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CompetencyEntry implements CompetencyEntry {
  const _CompetencyEntry(
      {required this.name, this.score = 0.0, this.sessionCount = 0});
  factory _CompetencyEntry.fromJson(Map<String, dynamic> json) =>
      _$CompetencyEntryFromJson(json);

  /// Nom de la compétence (ex: 'Algèbre', 'Analyse', 'Probabilités').
  @override
  final String name;

  /// Score normalisé entre 0.0 et 1.0.
  @override
  @JsonKey()
  final double score;

  /// Nombre de sessions ayant contribué à ce score.
  @override
  @JsonKey()
  final int sessionCount;

  /// Create a copy of CompetencyEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CompetencyEntryCopyWith<_CompetencyEntry> get copyWith =>
      __$CompetencyEntryCopyWithImpl<_CompetencyEntry>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CompetencyEntryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CompetencyEntry &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.sessionCount, sessionCount) ||
                other.sessionCount == sessionCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, score, sessionCount);

  @override
  String toString() {
    return 'CompetencyEntry(name: $name, score: $score, sessionCount: $sessionCount)';
  }
}

/// @nodoc
abstract mixin class _$CompetencyEntryCopyWith<$Res>
    implements $CompetencyEntryCopyWith<$Res> {
  factory _$CompetencyEntryCopyWith(
          _CompetencyEntry value, $Res Function(_CompetencyEntry) _then) =
      __$CompetencyEntryCopyWithImpl;
  @override
  @useResult
  $Res call({String name, double score, int sessionCount});
}

/// @nodoc
class __$CompetencyEntryCopyWithImpl<$Res>
    implements _$CompetencyEntryCopyWith<$Res> {
  __$CompetencyEntryCopyWithImpl(this._self, this._then);

  final _CompetencyEntry _self;
  final $Res Function(_CompetencyEntry) _then;

  /// Create a copy of CompetencyEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? score = null,
    Object? sessionCount = null,
  }) {
    return _then(_CompetencyEntry(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _self.score
          : score // ignore: cast_nullable_to_non_nullable
              as double,
      sessionCount: null == sessionCount
          ? _self.sessionCount
          : sessionCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
mixin _$CompetencyRadar {
  String get subject;
  List<CompetencyEntry> get entries;
  DateTime? get updatedAt;

  /// Create a copy of CompetencyRadar
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CompetencyRadarCopyWith<CompetencyRadar> get copyWith =>
      _$CompetencyRadarCopyWithImpl<CompetencyRadar>(
          this as CompetencyRadar, _$identity);

  /// Serializes this CompetencyRadar to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CompetencyRadar &&
            (identical(other.subject, subject) || other.subject == subject) &&
            const DeepCollectionEquality().equals(other.entries, entries) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, subject,
      const DeepCollectionEquality().hash(entries), updatedAt);

  @override
  String toString() {
    return 'CompetencyRadar(subject: $subject, entries: $entries, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $CompetencyRadarCopyWith<$Res> {
  factory $CompetencyRadarCopyWith(
          CompetencyRadar value, $Res Function(CompetencyRadar) _then) =
      _$CompetencyRadarCopyWithImpl;
  @useResult
  $Res call(
      {String subject, List<CompetencyEntry> entries, DateTime? updatedAt});
}

/// @nodoc
class _$CompetencyRadarCopyWithImpl<$Res>
    implements $CompetencyRadarCopyWith<$Res> {
  _$CompetencyRadarCopyWithImpl(this._self, this._then);

  final CompetencyRadar _self;
  final $Res Function(CompetencyRadar) _then;

  /// Create a copy of CompetencyRadar
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? subject = null,
    Object? entries = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      subject: null == subject
          ? _self.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      entries: null == entries
          ? _self.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<CompetencyEntry>,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [CompetencyRadar].
extension CompetencyRadarPatterns on CompetencyRadar {
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
    TResult Function(_CompetencyRadar value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CompetencyRadar() when $default != null:
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
    TResult Function(_CompetencyRadar value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompetencyRadar():
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
    TResult? Function(_CompetencyRadar value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompetencyRadar() when $default != null:
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
            String subject, List<CompetencyEntry> entries, DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CompetencyRadar() when $default != null:
        return $default(_that.subject, _that.entries, _that.updatedAt);
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
            String subject, List<CompetencyEntry> entries, DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompetencyRadar():
        return $default(_that.subject, _that.entries, _that.updatedAt);
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
            String subject, List<CompetencyEntry> entries, DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CompetencyRadar() when $default != null:
        return $default(_that.subject, _that.entries, _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CompetencyRadar implements CompetencyRadar {
  const _CompetencyRadar(
      {required this.subject,
      final List<CompetencyEntry> entries = const [],
      this.updatedAt})
      : _entries = entries;
  factory _CompetencyRadar.fromJson(Map<String, dynamic> json) =>
      _$CompetencyRadarFromJson(json);

  @override
  final String subject;
  final List<CompetencyEntry> _entries;
  @override
  @JsonKey()
  List<CompetencyEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  @override
  final DateTime? updatedAt;

  /// Create a copy of CompetencyRadar
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CompetencyRadarCopyWith<_CompetencyRadar> get copyWith =>
      __$CompetencyRadarCopyWithImpl<_CompetencyRadar>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CompetencyRadarToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CompetencyRadar &&
            (identical(other.subject, subject) || other.subject == subject) &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, subject,
      const DeepCollectionEquality().hash(_entries), updatedAt);

  @override
  String toString() {
    return 'CompetencyRadar(subject: $subject, entries: $entries, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$CompetencyRadarCopyWith<$Res>
    implements $CompetencyRadarCopyWith<$Res> {
  factory _$CompetencyRadarCopyWith(
          _CompetencyRadar value, $Res Function(_CompetencyRadar) _then) =
      __$CompetencyRadarCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String subject, List<CompetencyEntry> entries, DateTime? updatedAt});
}

/// @nodoc
class __$CompetencyRadarCopyWithImpl<$Res>
    implements _$CompetencyRadarCopyWith<$Res> {
  __$CompetencyRadarCopyWithImpl(this._self, this._then);

  final _CompetencyRadar _self;
  final $Res Function(_CompetencyRadar) _then;

  /// Create a copy of CompetencyRadar
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? subject = null,
    Object? entries = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_CompetencyRadar(
      subject: null == subject
          ? _self.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      entries: null == entries
          ? _self._entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<CompetencyEntry>,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
mixin _$ProgressEntry {
  String get id;
  String get subject;
  DateTime get date;
  int get durationMinutes;
  int get hintsUsed;
  double get progressScore;
  String? get notes;

  /// Create a copy of ProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProgressEntryCopyWith<ProgressEntry> get copyWith =>
      _$ProgressEntryCopyWithImpl<ProgressEntry>(
          this as ProgressEntry, _$identity);

  /// Serializes this ProgressEntry to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProgressEntry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.hintsUsed, hintsUsed) ||
                other.hintsUsed == hintsUsed) &&
            (identical(other.progressScore, progressScore) ||
                other.progressScore == progressScore) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, subject, date,
      durationMinutes, hintsUsed, progressScore, notes);

  @override
  String toString() {
    return 'ProgressEntry(id: $id, subject: $subject, date: $date, durationMinutes: $durationMinutes, hintsUsed: $hintsUsed, progressScore: $progressScore, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class $ProgressEntryCopyWith<$Res> {
  factory $ProgressEntryCopyWith(
          ProgressEntry value, $Res Function(ProgressEntry) _then) =
      _$ProgressEntryCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String subject,
      DateTime date,
      int durationMinutes,
      int hintsUsed,
      double progressScore,
      String? notes});
}

/// @nodoc
class _$ProgressEntryCopyWithImpl<$Res>
    implements $ProgressEntryCopyWith<$Res> {
  _$ProgressEntryCopyWithImpl(this._self, this._then);

  final ProgressEntry _self;
  final $Res Function(ProgressEntry) _then;

  /// Create a copy of ProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? date = null,
    Object? durationMinutes = null,
    Object? hintsUsed = null,
    Object? progressScore = null,
    Object? notes = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _self.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationMinutes: null == durationMinutes
          ? _self.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      hintsUsed: null == hintsUsed
          ? _self.hintsUsed
          : hintsUsed // ignore: cast_nullable_to_non_nullable
              as int,
      progressScore: null == progressScore
          ? _self.progressScore
          : progressScore // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ProgressEntry].
extension ProgressEntryPatterns on ProgressEntry {
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
    TResult Function(_ProgressEntry value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProgressEntry() when $default != null:
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
    TResult Function(_ProgressEntry value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProgressEntry():
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
    TResult? Function(_ProgressEntry value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProgressEntry() when $default != null:
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
            String subject,
            DateTime date,
            int durationMinutes,
            int hintsUsed,
            double progressScore,
            String? notes)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProgressEntry() when $default != null:
        return $default(
            _that.id,
            _that.subject,
            _that.date,
            _that.durationMinutes,
            _that.hintsUsed,
            _that.progressScore,
            _that.notes);
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
            String subject,
            DateTime date,
            int durationMinutes,
            int hintsUsed,
            double progressScore,
            String? notes)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProgressEntry():
        return $default(
            _that.id,
            _that.subject,
            _that.date,
            _that.durationMinutes,
            _that.hintsUsed,
            _that.progressScore,
            _that.notes);
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
            String subject,
            DateTime date,
            int durationMinutes,
            int hintsUsed,
            double progressScore,
            String? notes)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProgressEntry() when $default != null:
        return $default(
            _that.id,
            _that.subject,
            _that.date,
            _that.durationMinutes,
            _that.hintsUsed,
            _that.progressScore,
            _that.notes);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ProgressEntry implements ProgressEntry {
  const _ProgressEntry(
      {required this.id,
      required this.subject,
      required this.date,
      required this.durationMinutes,
      this.hintsUsed = 0,
      this.progressScore = 0.0,
      this.notes});
  factory _ProgressEntry.fromJson(Map<String, dynamic> json) =>
      _$ProgressEntryFromJson(json);

  @override
  final String id;
  @override
  final String subject;
  @override
  final DateTime date;
  @override
  final int durationMinutes;
  @override
  @JsonKey()
  final int hintsUsed;
  @override
  @JsonKey()
  final double progressScore;
  @override
  final String? notes;

  /// Create a copy of ProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProgressEntryCopyWith<_ProgressEntry> get copyWith =>
      __$ProgressEntryCopyWithImpl<_ProgressEntry>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProgressEntryToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProgressEntry &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.hintsUsed, hintsUsed) ||
                other.hintsUsed == hintsUsed) &&
            (identical(other.progressScore, progressScore) ||
                other.progressScore == progressScore) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, subject, date,
      durationMinutes, hintsUsed, progressScore, notes);

  @override
  String toString() {
    return 'ProgressEntry(id: $id, subject: $subject, date: $date, durationMinutes: $durationMinutes, hintsUsed: $hintsUsed, progressScore: $progressScore, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class _$ProgressEntryCopyWith<$Res>
    implements $ProgressEntryCopyWith<$Res> {
  factory _$ProgressEntryCopyWith(
          _ProgressEntry value, $Res Function(_ProgressEntry) _then) =
      __$ProgressEntryCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String subject,
      DateTime date,
      int durationMinutes,
      int hintsUsed,
      double progressScore,
      String? notes});
}

/// @nodoc
class __$ProgressEntryCopyWithImpl<$Res>
    implements _$ProgressEntryCopyWith<$Res> {
  __$ProgressEntryCopyWithImpl(this._self, this._then);

  final _ProgressEntry _self;
  final $Res Function(_ProgressEntry) _then;

  /// Create a copy of ProgressEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? date = null,
    Object? durationMinutes = null,
    Object? hintsUsed = null,
    Object? progressScore = null,
    Object? notes = freezed,
  }) {
    return _then(_ProgressEntry(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      subject: null == subject
          ? _self.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationMinutes: null == durationMinutes
          ? _self.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      hintsUsed: null == hintsUsed
          ? _self.hintsUsed
          : hintsUsed // ignore: cast_nullable_to_non_nullable
              as int,
      progressScore: null == progressScore
          ? _self.progressScore
          : progressScore // ignore: cast_nullable_to_non_nullable
              as double,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
