// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'teammate_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TeammateStats _$TeammateStatsFromJson(Map<String, dynamic> json) {
  return _TeammateStats.fromJson(json);
}

/// @nodoc
mixin _$TeammateStats {
  /// The teammate's user ID
  String get userId => throw _privateConstructorUsedError;

  /// Total games played together
  int get gamesPlayed => throw _privateConstructorUsedError;

  /// Games won together
  int get gamesWon => throw _privateConstructorUsedError;

  /// Games lost together
  int get gamesLost => throw _privateConstructorUsedError;

  /// Total points scored when playing together
  int get pointsScored => throw _privateConstructorUsedError;

  /// Total points allowed when playing together
  int get pointsAllowed => throw _privateConstructorUsedError;

  /// ELO rating change when playing together (cumulative)
  double get eloChange => throw _privateConstructorUsedError;

  /// Recent game results (up to 10 most recent)
  List<RecentGameResult> get recentGames => throw _privateConstructorUsedError;

  /// When these stats were last updated
  @TimestampConverter()
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this TeammateStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeammateStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeammateStatsCopyWith<TeammateStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeammateStatsCopyWith<$Res> {
  factory $TeammateStatsCopyWith(
    TeammateStats value,
    $Res Function(TeammateStats) then,
  ) = _$TeammateStatsCopyWithImpl<$Res, TeammateStats>;
  @useResult
  $Res call({
    String userId,
    int gamesPlayed,
    int gamesWon,
    int gamesLost,
    int pointsScored,
    int pointsAllowed,
    double eloChange,
    List<RecentGameResult> recentGames,
    @TimestampConverter() DateTime? lastUpdated,
  });
}

/// @nodoc
class _$TeammateStatsCopyWithImpl<$Res, $Val extends TeammateStats>
    implements $TeammateStatsCopyWith<$Res> {
  _$TeammateStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeammateStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? gamesPlayed = null,
    Object? gamesWon = null,
    Object? gamesLost = null,
    Object? pointsScored = null,
    Object? pointsAllowed = null,
    Object? eloChange = null,
    Object? recentGames = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            gamesPlayed: null == gamesPlayed
                ? _value.gamesPlayed
                : gamesPlayed // ignore: cast_nullable_to_non_nullable
                      as int,
            gamesWon: null == gamesWon
                ? _value.gamesWon
                : gamesWon // ignore: cast_nullable_to_non_nullable
                      as int,
            gamesLost: null == gamesLost
                ? _value.gamesLost
                : gamesLost // ignore: cast_nullable_to_non_nullable
                      as int,
            pointsScored: null == pointsScored
                ? _value.pointsScored
                : pointsScored // ignore: cast_nullable_to_non_nullable
                      as int,
            pointsAllowed: null == pointsAllowed
                ? _value.pointsAllowed
                : pointsAllowed // ignore: cast_nullable_to_non_nullable
                      as int,
            eloChange: null == eloChange
                ? _value.eloChange
                : eloChange // ignore: cast_nullable_to_non_nullable
                      as double,
            recentGames: null == recentGames
                ? _value.recentGames
                : recentGames // ignore: cast_nullable_to_non_nullable
                      as List<RecentGameResult>,
            lastUpdated: freezed == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TeammateStatsImplCopyWith<$Res>
    implements $TeammateStatsCopyWith<$Res> {
  factory _$$TeammateStatsImplCopyWith(
    _$TeammateStatsImpl value,
    $Res Function(_$TeammateStatsImpl) then,
  ) = __$$TeammateStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    int gamesPlayed,
    int gamesWon,
    int gamesLost,
    int pointsScored,
    int pointsAllowed,
    double eloChange,
    List<RecentGameResult> recentGames,
    @TimestampConverter() DateTime? lastUpdated,
  });
}

/// @nodoc
class __$$TeammateStatsImplCopyWithImpl<$Res>
    extends _$TeammateStatsCopyWithImpl<$Res, _$TeammateStatsImpl>
    implements _$$TeammateStatsImplCopyWith<$Res> {
  __$$TeammateStatsImplCopyWithImpl(
    _$TeammateStatsImpl _value,
    $Res Function(_$TeammateStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TeammateStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? gamesPlayed = null,
    Object? gamesWon = null,
    Object? gamesLost = null,
    Object? pointsScored = null,
    Object? pointsAllowed = null,
    Object? eloChange = null,
    Object? recentGames = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _$TeammateStatsImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        gamesPlayed: null == gamesPlayed
            ? _value.gamesPlayed
            : gamesPlayed // ignore: cast_nullable_to_non_nullable
                  as int,
        gamesWon: null == gamesWon
            ? _value.gamesWon
            : gamesWon // ignore: cast_nullable_to_non_nullable
                  as int,
        gamesLost: null == gamesLost
            ? _value.gamesLost
            : gamesLost // ignore: cast_nullable_to_non_nullable
                  as int,
        pointsScored: null == pointsScored
            ? _value.pointsScored
            : pointsScored // ignore: cast_nullable_to_non_nullable
                  as int,
        pointsAllowed: null == pointsAllowed
            ? _value.pointsAllowed
            : pointsAllowed // ignore: cast_nullable_to_non_nullable
                  as int,
        eloChange: null == eloChange
            ? _value.eloChange
            : eloChange // ignore: cast_nullable_to_non_nullable
                  as double,
        recentGames: null == recentGames
            ? _value._recentGames
            : recentGames // ignore: cast_nullable_to_non_nullable
                  as List<RecentGameResult>,
        lastUpdated: freezed == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeammateStatsImpl extends _TeammateStats {
  const _$TeammateStatsImpl({
    required this.userId,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.gamesLost,
    this.pointsScored = 0,
    this.pointsAllowed = 0,
    this.eloChange = 0.0,
    final List<RecentGameResult> recentGames = const [],
    @TimestampConverter() this.lastUpdated,
  }) : _recentGames = recentGames,
       super._();

  factory _$TeammateStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeammateStatsImplFromJson(json);

  /// The teammate's user ID
  @override
  final String userId;

  /// Total games played together
  @override
  final int gamesPlayed;

  /// Games won together
  @override
  final int gamesWon;

  /// Games lost together
  @override
  final int gamesLost;

  /// Total points scored when playing together
  @override
  @JsonKey()
  final int pointsScored;

  /// Total points allowed when playing together
  @override
  @JsonKey()
  final int pointsAllowed;

  /// ELO rating change when playing together (cumulative)
  @override
  @JsonKey()
  final double eloChange;

  /// Recent game results (up to 10 most recent)
  final List<RecentGameResult> _recentGames;

  /// Recent game results (up to 10 most recent)
  @override
  @JsonKey()
  List<RecentGameResult> get recentGames {
    if (_recentGames is EqualUnmodifiableListView) return _recentGames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentGames);
  }

  /// When these stats were last updated
  @override
  @TimestampConverter()
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'TeammateStats(userId: $userId, gamesPlayed: $gamesPlayed, gamesWon: $gamesWon, gamesLost: $gamesLost, pointsScored: $pointsScored, pointsAllowed: $pointsAllowed, eloChange: $eloChange, recentGames: $recentGames, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeammateStatsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.gamesPlayed, gamesPlayed) ||
                other.gamesPlayed == gamesPlayed) &&
            (identical(other.gamesWon, gamesWon) ||
                other.gamesWon == gamesWon) &&
            (identical(other.gamesLost, gamesLost) ||
                other.gamesLost == gamesLost) &&
            (identical(other.pointsScored, pointsScored) ||
                other.pointsScored == pointsScored) &&
            (identical(other.pointsAllowed, pointsAllowed) ||
                other.pointsAllowed == pointsAllowed) &&
            (identical(other.eloChange, eloChange) ||
                other.eloChange == eloChange) &&
            const DeepCollectionEquality().equals(
              other._recentGames,
              _recentGames,
            ) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    gamesPlayed,
    gamesWon,
    gamesLost,
    pointsScored,
    pointsAllowed,
    eloChange,
    const DeepCollectionEquality().hash(_recentGames),
    lastUpdated,
  );

  /// Create a copy of TeammateStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeammateStatsImplCopyWith<_$TeammateStatsImpl> get copyWith =>
      __$$TeammateStatsImplCopyWithImpl<_$TeammateStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeammateStatsImplToJson(this);
  }
}

abstract class _TeammateStats extends TeammateStats {
  const factory _TeammateStats({
    required final String userId,
    required final int gamesPlayed,
    required final int gamesWon,
    required final int gamesLost,
    final int pointsScored,
    final int pointsAllowed,
    final double eloChange,
    final List<RecentGameResult> recentGames,
    @TimestampConverter() final DateTime? lastUpdated,
  }) = _$TeammateStatsImpl;
  const _TeammateStats._() : super._();

  factory _TeammateStats.fromJson(Map<String, dynamic> json) =
      _$TeammateStatsImpl.fromJson;

  /// The teammate's user ID
  @override
  String get userId;

  /// Total games played together
  @override
  int get gamesPlayed;

  /// Games won together
  @override
  int get gamesWon;

  /// Games lost together
  @override
  int get gamesLost;

  /// Total points scored when playing together
  @override
  int get pointsScored;

  /// Total points allowed when playing together
  @override
  int get pointsAllowed;

  /// ELO rating change when playing together (cumulative)
  @override
  double get eloChange;

  /// Recent game results (up to 10 most recent)
  @override
  List<RecentGameResult> get recentGames;

  /// When these stats were last updated
  @override
  @TimestampConverter()
  DateTime? get lastUpdated;

  /// Create a copy of TeammateStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeammateStatsImplCopyWith<_$TeammateStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecentGameResult _$RecentGameResultFromJson(Map<String, dynamic> json) {
  return _RecentGameResult.fromJson(json);
}

/// @nodoc
mixin _$RecentGameResult {
  /// Reference to the game
  String get gameId => throw _privateConstructorUsedError;

  /// Whether the team won
  bool get won => throw _privateConstructorUsedError;

  /// Points scored by the team
  int get pointsScored => throw _privateConstructorUsedError;

  /// Points scored by opponents
  int get pointsAllowed => throw _privateConstructorUsedError;

  /// ELO change from this game
  double get eloChange => throw _privateConstructorUsedError;

  /// When the game was played
  @RequiredTimestampConverter()
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this RecentGameResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecentGameResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecentGameResultCopyWith<RecentGameResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecentGameResultCopyWith<$Res> {
  factory $RecentGameResultCopyWith(
    RecentGameResult value,
    $Res Function(RecentGameResult) then,
  ) = _$RecentGameResultCopyWithImpl<$Res, RecentGameResult>;
  @useResult
  $Res call({
    String gameId,
    bool won,
    int pointsScored,
    int pointsAllowed,
    double eloChange,
    @RequiredTimestampConverter() DateTime timestamp,
  });
}

/// @nodoc
class _$RecentGameResultCopyWithImpl<$Res, $Val extends RecentGameResult>
    implements $RecentGameResultCopyWith<$Res> {
  _$RecentGameResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecentGameResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? won = null,
    Object? pointsScored = null,
    Object? pointsAllowed = null,
    Object? eloChange = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            gameId: null == gameId
                ? _value.gameId
                : gameId // ignore: cast_nullable_to_non_nullable
                      as String,
            won: null == won
                ? _value.won
                : won // ignore: cast_nullable_to_non_nullable
                      as bool,
            pointsScored: null == pointsScored
                ? _value.pointsScored
                : pointsScored // ignore: cast_nullable_to_non_nullable
                      as int,
            pointsAllowed: null == pointsAllowed
                ? _value.pointsAllowed
                : pointsAllowed // ignore: cast_nullable_to_non_nullable
                      as int,
            eloChange: null == eloChange
                ? _value.eloChange
                : eloChange // ignore: cast_nullable_to_non_nullable
                      as double,
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
abstract class _$$RecentGameResultImplCopyWith<$Res>
    implements $RecentGameResultCopyWith<$Res> {
  factory _$$RecentGameResultImplCopyWith(
    _$RecentGameResultImpl value,
    $Res Function(_$RecentGameResultImpl) then,
  ) = __$$RecentGameResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String gameId,
    bool won,
    int pointsScored,
    int pointsAllowed,
    double eloChange,
    @RequiredTimestampConverter() DateTime timestamp,
  });
}

/// @nodoc
class __$$RecentGameResultImplCopyWithImpl<$Res>
    extends _$RecentGameResultCopyWithImpl<$Res, _$RecentGameResultImpl>
    implements _$$RecentGameResultImplCopyWith<$Res> {
  __$$RecentGameResultImplCopyWithImpl(
    _$RecentGameResultImpl _value,
    $Res Function(_$RecentGameResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecentGameResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? won = null,
    Object? pointsScored = null,
    Object? pointsAllowed = null,
    Object? eloChange = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$RecentGameResultImpl(
        gameId: null == gameId
            ? _value.gameId
            : gameId // ignore: cast_nullable_to_non_nullable
                  as String,
        won: null == won
            ? _value.won
            : won // ignore: cast_nullable_to_non_nullable
                  as bool,
        pointsScored: null == pointsScored
            ? _value.pointsScored
            : pointsScored // ignore: cast_nullable_to_non_nullable
                  as int,
        pointsAllowed: null == pointsAllowed
            ? _value.pointsAllowed
            : pointsAllowed // ignore: cast_nullable_to_non_nullable
                  as int,
        eloChange: null == eloChange
            ? _value.eloChange
            : eloChange // ignore: cast_nullable_to_non_nullable
                  as double,
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
class _$RecentGameResultImpl extends _RecentGameResult {
  const _$RecentGameResultImpl({
    required this.gameId,
    required this.won,
    required this.pointsScored,
    required this.pointsAllowed,
    required this.eloChange,
    @RequiredTimestampConverter() required this.timestamp,
  }) : super._();

  factory _$RecentGameResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecentGameResultImplFromJson(json);

  /// Reference to the game
  @override
  final String gameId;

  /// Whether the team won
  @override
  final bool won;

  /// Points scored by the team
  @override
  final int pointsScored;

  /// Points scored by opponents
  @override
  final int pointsAllowed;

  /// ELO change from this game
  @override
  final double eloChange;

  /// When the game was played
  @override
  @RequiredTimestampConverter()
  final DateTime timestamp;

  @override
  String toString() {
    return 'RecentGameResult(gameId: $gameId, won: $won, pointsScored: $pointsScored, pointsAllowed: $pointsAllowed, eloChange: $eloChange, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecentGameResultImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.won, won) || other.won == won) &&
            (identical(other.pointsScored, pointsScored) ||
                other.pointsScored == pointsScored) &&
            (identical(other.pointsAllowed, pointsAllowed) ||
                other.pointsAllowed == pointsAllowed) &&
            (identical(other.eloChange, eloChange) ||
                other.eloChange == eloChange) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    gameId,
    won,
    pointsScored,
    pointsAllowed,
    eloChange,
    timestamp,
  );

  /// Create a copy of RecentGameResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecentGameResultImplCopyWith<_$RecentGameResultImpl> get copyWith =>
      __$$RecentGameResultImplCopyWithImpl<_$RecentGameResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecentGameResultImplToJson(this);
  }
}

abstract class _RecentGameResult extends RecentGameResult {
  const factory _RecentGameResult({
    required final String gameId,
    required final bool won,
    required final int pointsScored,
    required final int pointsAllowed,
    required final double eloChange,
    @RequiredTimestampConverter() required final DateTime timestamp,
  }) = _$RecentGameResultImpl;
  const _RecentGameResult._() : super._();

  factory _RecentGameResult.fromJson(Map<String, dynamic> json) =
      _$RecentGameResultImpl.fromJson;

  /// Reference to the game
  @override
  String get gameId;

  /// Whether the team won
  @override
  bool get won;

  /// Points scored by the team
  @override
  int get pointsScored;

  /// Points scored by opponents
  @override
  int get pointsAllowed;

  /// ELO change from this game
  @override
  double get eloChange;

  /// When the game was played
  @override
  @RequiredTimestampConverter()
  DateTime get timestamp;

  /// Create a copy of RecentGameResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecentGameResultImplCopyWith<_$RecentGameResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
