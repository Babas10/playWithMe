// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rating_history_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RatingHistoryEntry _$RatingHistoryEntryFromJson(Map<String, dynamic> json) {
  return _RatingHistoryEntry.fromJson(json);
}

/// @nodoc
mixin _$RatingHistoryEntry {
  /// Auto-generated document ID from Firestore
  String get entryId => throw _privateConstructorUsedError;

  /// Reference to the game that caused this rating change
  String get gameId => throw _privateConstructorUsedError;

  /// Rating before the game
  double get oldRating => throw _privateConstructorUsedError;

  /// Rating after the game
  double get newRating => throw _privateConstructorUsedError;

  /// Rating change (positive or negative)
  double get ratingChange => throw _privateConstructorUsedError;

  /// Display string for opponent team (e.g., "Player A & Player B")
  String get opponentTeam => throw _privateConstructorUsedError;

  /// Whether the player's team won
  bool get won => throw _privateConstructorUsedError;

  /// When this rating update was recorded
  @RequiredTimestampConverter()
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this RatingHistoryEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RatingHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RatingHistoryEntryCopyWith<RatingHistoryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RatingHistoryEntryCopyWith<$Res> {
  factory $RatingHistoryEntryCopyWith(
    RatingHistoryEntry value,
    $Res Function(RatingHistoryEntry) then,
  ) = _$RatingHistoryEntryCopyWithImpl<$Res, RatingHistoryEntry>;
  @useResult
  $Res call({
    String entryId,
    String gameId,
    double oldRating,
    double newRating,
    double ratingChange,
    String opponentTeam,
    bool won,
    @RequiredTimestampConverter() DateTime timestamp,
  });
}

/// @nodoc
class _$RatingHistoryEntryCopyWithImpl<$Res, $Val extends RatingHistoryEntry>
    implements $RatingHistoryEntryCopyWith<$Res> {
  _$RatingHistoryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RatingHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entryId = null,
    Object? gameId = null,
    Object? oldRating = null,
    Object? newRating = null,
    Object? ratingChange = null,
    Object? opponentTeam = null,
    Object? won = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            entryId: null == entryId
                ? _value.entryId
                : entryId // ignore: cast_nullable_to_non_nullable
                      as String,
            gameId: null == gameId
                ? _value.gameId
                : gameId // ignore: cast_nullable_to_non_nullable
                      as String,
            oldRating: null == oldRating
                ? _value.oldRating
                : oldRating // ignore: cast_nullable_to_non_nullable
                      as double,
            newRating: null == newRating
                ? _value.newRating
                : newRating // ignore: cast_nullable_to_non_nullable
                      as double,
            ratingChange: null == ratingChange
                ? _value.ratingChange
                : ratingChange // ignore: cast_nullable_to_non_nullable
                      as double,
            opponentTeam: null == opponentTeam
                ? _value.opponentTeam
                : opponentTeam // ignore: cast_nullable_to_non_nullable
                      as String,
            won: null == won
                ? _value.won
                : won // ignore: cast_nullable_to_non_nullable
                      as bool,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RatingHistoryEntryImplCopyWith<$Res>
    implements $RatingHistoryEntryCopyWith<$Res> {
  factory _$$RatingHistoryEntryImplCopyWith(
    _$RatingHistoryEntryImpl value,
    $Res Function(_$RatingHistoryEntryImpl) then,
  ) = __$$RatingHistoryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String entryId,
    String gameId,
    double oldRating,
    double newRating,
    double ratingChange,
    String opponentTeam,
    bool won,
    @RequiredTimestampConverter() DateTime timestamp,
  });
}

/// @nodoc
class __$$RatingHistoryEntryImplCopyWithImpl<$Res>
    extends _$RatingHistoryEntryCopyWithImpl<$Res, _$RatingHistoryEntryImpl>
    implements _$$RatingHistoryEntryImplCopyWith<$Res> {
  __$$RatingHistoryEntryImplCopyWithImpl(
    _$RatingHistoryEntryImpl _value,
    $Res Function(_$RatingHistoryEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RatingHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entryId = null,
    Object? gameId = null,
    Object? oldRating = null,
    Object? newRating = null,
    Object? ratingChange = null,
    Object? opponentTeam = null,
    Object? won = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$RatingHistoryEntryImpl(
        entryId: null == entryId
            ? _value.entryId
            : entryId // ignore: cast_nullable_to_non_nullable
                  as String,
        gameId: null == gameId
            ? _value.gameId
            : gameId // ignore: cast_nullable_to_non_nullable
                  as String,
        oldRating: null == oldRating
            ? _value.oldRating
            : oldRating // ignore: cast_nullable_to_non_nullable
                  as double,
        newRating: null == newRating
            ? _value.newRating
            : newRating // ignore: cast_nullable_to_non_nullable
                  as double,
        ratingChange: null == ratingChange
            ? _value.ratingChange
            : ratingChange // ignore: cast_nullable_to_non_nullable
                  as double,
        opponentTeam: null == opponentTeam
            ? _value.opponentTeam
            : opponentTeam // ignore: cast_nullable_to_non_nullable
                  as String,
        won: null == won
            ? _value.won
            : won // ignore: cast_nullable_to_non_nullable
                  as bool,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RatingHistoryEntryImpl extends _RatingHistoryEntry {
  const _$RatingHistoryEntryImpl({
    required this.entryId,
    required this.gameId,
    required this.oldRating,
    required this.newRating,
    required this.ratingChange,
    required this.opponentTeam,
    required this.won,
    @RequiredTimestampConverter() required this.timestamp,
  }) : super._();

  factory _$RatingHistoryEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RatingHistoryEntryImplFromJson(json);

  /// Auto-generated document ID from Firestore
  @override
  final String entryId;

  /// Reference to the game that caused this rating change
  @override
  final String gameId;

  /// Rating before the game
  @override
  final double oldRating;

  /// Rating after the game
  @override
  final double newRating;

  /// Rating change (positive or negative)
  @override
  final double ratingChange;

  /// Display string for opponent team (e.g., "Player A & Player B")
  @override
  final String opponentTeam;

  /// Whether the player's team won
  @override
  final bool won;

  /// When this rating update was recorded
  @override
  @RequiredTimestampConverter()
  final DateTime timestamp;

  @override
  String toString() {
    return 'RatingHistoryEntry(entryId: $entryId, gameId: $gameId, oldRating: $oldRating, newRating: $newRating, ratingChange: $ratingChange, opponentTeam: $opponentTeam, won: $won, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RatingHistoryEntryImpl &&
            (identical(other.entryId, entryId) || other.entryId == entryId) &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.oldRating, oldRating) ||
                other.oldRating == oldRating) &&
            (identical(other.newRating, newRating) ||
                other.newRating == newRating) &&
            (identical(other.ratingChange, ratingChange) ||
                other.ratingChange == ratingChange) &&
            (identical(other.opponentTeam, opponentTeam) ||
                other.opponentTeam == opponentTeam) &&
            (identical(other.won, won) || other.won == won) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    entryId,
    gameId,
    oldRating,
    newRating,
    ratingChange,
    opponentTeam,
    won,
    timestamp,
  );

  /// Create a copy of RatingHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RatingHistoryEntryImplCopyWith<_$RatingHistoryEntryImpl> get copyWith =>
      __$$RatingHistoryEntryImplCopyWithImpl<_$RatingHistoryEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RatingHistoryEntryImplToJson(this);
  }
}

abstract class _RatingHistoryEntry extends RatingHistoryEntry {
  const factory _RatingHistoryEntry({
    required final String entryId,
    required final String gameId,
    required final double oldRating,
    required final double newRating,
    required final double ratingChange,
    required final String opponentTeam,
    required final bool won,
    @RequiredTimestampConverter() required final DateTime timestamp,
  }) = _$RatingHistoryEntryImpl;
  const _RatingHistoryEntry._() : super._();

  factory _RatingHistoryEntry.fromJson(Map<String, dynamic> json) =
      _$RatingHistoryEntryImpl.fromJson;

  /// Auto-generated document ID from Firestore
  @override
  String get entryId;

  /// Reference to the game that caused this rating change
  @override
  String get gameId;

  /// Rating before the game
  @override
  double get oldRating;

  /// Rating after the game
  @override
  double get newRating;

  /// Rating change (positive or negative)
  @override
  double get ratingChange;

  /// Display string for opponent team (e.g., "Player A & Player B")
  @override
  String get opponentTeam;

  /// Whether the player's team won
  @override
  bool get won;

  /// When this rating update was recorded
  @override
  @RequiredTimestampConverter()
  DateTime get timestamp;

  /// Create a copy of RatingHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RatingHistoryEntryImplCopyWith<_$RatingHistoryEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
