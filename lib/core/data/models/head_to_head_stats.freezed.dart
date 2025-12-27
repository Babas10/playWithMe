// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'head_to_head_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HeadToHeadStats _$HeadToHeadStatsFromJson(Map<String, dynamic> json) {
  return _HeadToHeadStats.fromJson(json);
}

/// @nodoc
mixin _$HeadToHeadStats {
  /// Primary user ID (the user viewing these stats)
  String get userId => throw _privateConstructorUsedError;

  /// Opponent user ID
  String get opponentId => throw _privateConstructorUsedError;

  /// Opponent's display name (cached for performance and privacy)
  String? get opponentName => throw _privateConstructorUsedError;

  /// Opponent's email (cached for performance and privacy)
  String? get opponentEmail => throw _privateConstructorUsedError;

  /// Opponent's photo URL (cached for performance and privacy)
  String? get opponentPhotoUrl => throw _privateConstructorUsedError;

  /// Total games played against this opponent
  int get gamesPlayed => throw _privateConstructorUsedError;

  /// Games won against this opponent
  int get gamesWon => throw _privateConstructorUsedError;

  /// Games lost against this opponent
  int get gamesLost => throw _privateConstructorUsedError;

  /// Total points scored against this opponent
  int get pointsScored => throw _privateConstructorUsedError;

  /// Total points allowed against this opponent
  int get pointsAllowed => throw _privateConstructorUsedError;

  /// Net ELO change from games against this opponent
  double get eloChange => throw _privateConstructorUsedError;

  /// Largest point margin victory
  int get largestVictoryMargin => throw _privateConstructorUsedError;

  /// Largest point margin defeat
  int get largestDefeatMargin => throw _privateConstructorUsedError;

  /// Recent matchup results (up to 10 most recent)
  List<HeadToHeadGameResult> get recentMatchups =>
      throw _privateConstructorUsedError;

  /// When these stats were last updated
  @TimestampConverter()
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this HeadToHeadStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HeadToHeadStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HeadToHeadStatsCopyWith<HeadToHeadStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HeadToHeadStatsCopyWith<$Res> {
  factory $HeadToHeadStatsCopyWith(
    HeadToHeadStats value,
    $Res Function(HeadToHeadStats) then,
  ) = _$HeadToHeadStatsCopyWithImpl<$Res, HeadToHeadStats>;
  @useResult
  $Res call({
    String userId,
    String opponentId,
    String? opponentName,
    String? opponentEmail,
    String? opponentPhotoUrl,
    int gamesPlayed,
    int gamesWon,
    int gamesLost,
    int pointsScored,
    int pointsAllowed,
    double eloChange,
    int largestVictoryMargin,
    int largestDefeatMargin,
    List<HeadToHeadGameResult> recentMatchups,
    @TimestampConverter() DateTime? lastUpdated,
  });
}

/// @nodoc
class _$HeadToHeadStatsCopyWithImpl<$Res, $Val extends HeadToHeadStats>
    implements $HeadToHeadStatsCopyWith<$Res> {
  _$HeadToHeadStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HeadToHeadStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? opponentId = null,
    Object? opponentName = freezed,
    Object? opponentEmail = freezed,
    Object? opponentPhotoUrl = freezed,
    Object? gamesPlayed = null,
    Object? gamesWon = null,
    Object? gamesLost = null,
    Object? pointsScored = null,
    Object? pointsAllowed = null,
    Object? eloChange = null,
    Object? largestVictoryMargin = null,
    Object? largestDefeatMargin = null,
    Object? recentMatchups = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            opponentId: null == opponentId
                ? _value.opponentId
                : opponentId // ignore: cast_nullable_to_non_nullable
                      as String,
            opponentName: freezed == opponentName
                ? _value.opponentName
                : opponentName // ignore: cast_nullable_to_non_nullable
                      as String?,
            opponentEmail: freezed == opponentEmail
                ? _value.opponentEmail
                : opponentEmail // ignore: cast_nullable_to_non_nullable
                      as String?,
            opponentPhotoUrl: freezed == opponentPhotoUrl
                ? _value.opponentPhotoUrl
                : opponentPhotoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
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
            largestVictoryMargin: null == largestVictoryMargin
                ? _value.largestVictoryMargin
                : largestVictoryMargin // ignore: cast_nullable_to_non_nullable
                      as int,
            largestDefeatMargin: null == largestDefeatMargin
                ? _value.largestDefeatMargin
                : largestDefeatMargin // ignore: cast_nullable_to_non_nullable
                      as int,
            recentMatchups: null == recentMatchups
                ? _value.recentMatchups
                : recentMatchups // ignore: cast_nullable_to_non_nullable
                      as List<HeadToHeadGameResult>,
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
abstract class _$$HeadToHeadStatsImplCopyWith<$Res>
    implements $HeadToHeadStatsCopyWith<$Res> {
  factory _$$HeadToHeadStatsImplCopyWith(
    _$HeadToHeadStatsImpl value,
    $Res Function(_$HeadToHeadStatsImpl) then,
  ) = __$$HeadToHeadStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String opponentId,
    String? opponentName,
    String? opponentEmail,
    String? opponentPhotoUrl,
    int gamesPlayed,
    int gamesWon,
    int gamesLost,
    int pointsScored,
    int pointsAllowed,
    double eloChange,
    int largestVictoryMargin,
    int largestDefeatMargin,
    List<HeadToHeadGameResult> recentMatchups,
    @TimestampConverter() DateTime? lastUpdated,
  });
}

/// @nodoc
class __$$HeadToHeadStatsImplCopyWithImpl<$Res>
    extends _$HeadToHeadStatsCopyWithImpl<$Res, _$HeadToHeadStatsImpl>
    implements _$$HeadToHeadStatsImplCopyWith<$Res> {
  __$$HeadToHeadStatsImplCopyWithImpl(
    _$HeadToHeadStatsImpl _value,
    $Res Function(_$HeadToHeadStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HeadToHeadStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? opponentId = null,
    Object? opponentName = freezed,
    Object? opponentEmail = freezed,
    Object? opponentPhotoUrl = freezed,
    Object? gamesPlayed = null,
    Object? gamesWon = null,
    Object? gamesLost = null,
    Object? pointsScored = null,
    Object? pointsAllowed = null,
    Object? eloChange = null,
    Object? largestVictoryMargin = null,
    Object? largestDefeatMargin = null,
    Object? recentMatchups = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _$HeadToHeadStatsImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        opponentId: null == opponentId
            ? _value.opponentId
            : opponentId // ignore: cast_nullable_to_non_nullable
                  as String,
        opponentName: freezed == opponentName
            ? _value.opponentName
            : opponentName // ignore: cast_nullable_to_non_nullable
                  as String?,
        opponentEmail: freezed == opponentEmail
            ? _value.opponentEmail
            : opponentEmail // ignore: cast_nullable_to_non_nullable
                  as String?,
        opponentPhotoUrl: freezed == opponentPhotoUrl
            ? _value.opponentPhotoUrl
            : opponentPhotoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
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
        largestVictoryMargin: null == largestVictoryMargin
            ? _value.largestVictoryMargin
            : largestVictoryMargin // ignore: cast_nullable_to_non_nullable
                  as int,
        largestDefeatMargin: null == largestDefeatMargin
            ? _value.largestDefeatMargin
            : largestDefeatMargin // ignore: cast_nullable_to_non_nullable
                  as int,
        recentMatchups: null == recentMatchups
            ? _value._recentMatchups
            : recentMatchups // ignore: cast_nullable_to_non_nullable
                  as List<HeadToHeadGameResult>,
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
class _$HeadToHeadStatsImpl extends _HeadToHeadStats {
  const _$HeadToHeadStatsImpl({
    required this.userId,
    required this.opponentId,
    this.opponentName,
    this.opponentEmail,
    this.opponentPhotoUrl,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.gamesLost,
    this.pointsScored = 0,
    this.pointsAllowed = 0,
    this.eloChange = 0.0,
    this.largestVictoryMargin = 0,
    this.largestDefeatMargin = 0,
    final List<HeadToHeadGameResult> recentMatchups = const [],
    @TimestampConverter() this.lastUpdated,
  }) : _recentMatchups = recentMatchups,
       super._();

  factory _$HeadToHeadStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$HeadToHeadStatsImplFromJson(json);

  /// Primary user ID (the user viewing these stats)
  @override
  final String userId;

  /// Opponent user ID
  @override
  final String opponentId;

  /// Opponent's display name (cached for performance and privacy)
  @override
  final String? opponentName;

  /// Opponent's email (cached for performance and privacy)
  @override
  final String? opponentEmail;

  /// Opponent's photo URL (cached for performance and privacy)
  @override
  final String? opponentPhotoUrl;

  /// Total games played against this opponent
  @override
  final int gamesPlayed;

  /// Games won against this opponent
  @override
  final int gamesWon;

  /// Games lost against this opponent
  @override
  final int gamesLost;

  /// Total points scored against this opponent
  @override
  @JsonKey()
  final int pointsScored;

  /// Total points allowed against this opponent
  @override
  @JsonKey()
  final int pointsAllowed;

  /// Net ELO change from games against this opponent
  @override
  @JsonKey()
  final double eloChange;

  /// Largest point margin victory
  @override
  @JsonKey()
  final int largestVictoryMargin;

  /// Largest point margin defeat
  @override
  @JsonKey()
  final int largestDefeatMargin;

  /// Recent matchup results (up to 10 most recent)
  final List<HeadToHeadGameResult> _recentMatchups;

  /// Recent matchup results (up to 10 most recent)
  @override
  @JsonKey()
  List<HeadToHeadGameResult> get recentMatchups {
    if (_recentMatchups is EqualUnmodifiableListView) return _recentMatchups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentMatchups);
  }

  /// When these stats were last updated
  @override
  @TimestampConverter()
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'HeadToHeadStats(userId: $userId, opponentId: $opponentId, opponentName: $opponentName, opponentEmail: $opponentEmail, opponentPhotoUrl: $opponentPhotoUrl, gamesPlayed: $gamesPlayed, gamesWon: $gamesWon, gamesLost: $gamesLost, pointsScored: $pointsScored, pointsAllowed: $pointsAllowed, eloChange: $eloChange, largestVictoryMargin: $largestVictoryMargin, largestDefeatMargin: $largestDefeatMargin, recentMatchups: $recentMatchups, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HeadToHeadStatsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.opponentId, opponentId) ||
                other.opponentId == opponentId) &&
            (identical(other.opponentName, opponentName) ||
                other.opponentName == opponentName) &&
            (identical(other.opponentEmail, opponentEmail) ||
                other.opponentEmail == opponentEmail) &&
            (identical(other.opponentPhotoUrl, opponentPhotoUrl) ||
                other.opponentPhotoUrl == opponentPhotoUrl) &&
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
            (identical(other.largestVictoryMargin, largestVictoryMargin) ||
                other.largestVictoryMargin == largestVictoryMargin) &&
            (identical(other.largestDefeatMargin, largestDefeatMargin) ||
                other.largestDefeatMargin == largestDefeatMargin) &&
            const DeepCollectionEquality().equals(
              other._recentMatchups,
              _recentMatchups,
            ) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    opponentId,
    opponentName,
    opponentEmail,
    opponentPhotoUrl,
    gamesPlayed,
    gamesWon,
    gamesLost,
    pointsScored,
    pointsAllowed,
    eloChange,
    largestVictoryMargin,
    largestDefeatMargin,
    const DeepCollectionEquality().hash(_recentMatchups),
    lastUpdated,
  );

  /// Create a copy of HeadToHeadStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HeadToHeadStatsImplCopyWith<_$HeadToHeadStatsImpl> get copyWith =>
      __$$HeadToHeadStatsImplCopyWithImpl<_$HeadToHeadStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HeadToHeadStatsImplToJson(this);
  }
}

abstract class _HeadToHeadStats extends HeadToHeadStats {
  const factory _HeadToHeadStats({
    required final String userId,
    required final String opponentId,
    final String? opponentName,
    final String? opponentEmail,
    final String? opponentPhotoUrl,
    required final int gamesPlayed,
    required final int gamesWon,
    required final int gamesLost,
    final int pointsScored,
    final int pointsAllowed,
    final double eloChange,
    final int largestVictoryMargin,
    final int largestDefeatMargin,
    final List<HeadToHeadGameResult> recentMatchups,
    @TimestampConverter() final DateTime? lastUpdated,
  }) = _$HeadToHeadStatsImpl;
  const _HeadToHeadStats._() : super._();

  factory _HeadToHeadStats.fromJson(Map<String, dynamic> json) =
      _$HeadToHeadStatsImpl.fromJson;

  /// Primary user ID (the user viewing these stats)
  @override
  String get userId;

  /// Opponent user ID
  @override
  String get opponentId;

  /// Opponent's display name (cached for performance and privacy)
  @override
  String? get opponentName;

  /// Opponent's email (cached for performance and privacy)
  @override
  String? get opponentEmail;

  /// Opponent's photo URL (cached for performance and privacy)
  @override
  String? get opponentPhotoUrl;

  /// Total games played against this opponent
  @override
  int get gamesPlayed;

  /// Games won against this opponent
  @override
  int get gamesWon;

  /// Games lost against this opponent
  @override
  int get gamesLost;

  /// Total points scored against this opponent
  @override
  int get pointsScored;

  /// Total points allowed against this opponent
  @override
  int get pointsAllowed;

  /// Net ELO change from games against this opponent
  @override
  double get eloChange;

  /// Largest point margin victory
  @override
  int get largestVictoryMargin;

  /// Largest point margin defeat
  @override
  int get largestDefeatMargin;

  /// Recent matchup results (up to 10 most recent)
  @override
  List<HeadToHeadGameResult> get recentMatchups;

  /// When these stats were last updated
  @override
  @TimestampConverter()
  DateTime? get lastUpdated;

  /// Create a copy of HeadToHeadStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HeadToHeadStatsImplCopyWith<_$HeadToHeadStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HeadToHeadGameResult _$HeadToHeadGameResultFromJson(Map<String, dynamic> json) {
  return _HeadToHeadGameResult.fromJson(json);
}

/// @nodoc
mixin _$HeadToHeadGameResult {
  /// Reference to the game
  String get gameId => throw _privateConstructorUsedError;

  /// Whether the primary user won
  bool get won => throw _privateConstructorUsedError;

  /// Points scored by user's team
  int get pointsScored => throw _privateConstructorUsedError;

  /// Points scored by opponent's team
  int get pointsAllowed => throw _privateConstructorUsedError;

  /// ELO change from this game
  double get eloChange => throw _privateConstructorUsedError;

  /// Partner who played with the user (if any)
  String? get partnerId => throw _privateConstructorUsedError;

  /// Partner who played with the opponent (if any)
  String? get opponentPartnerId => throw _privateConstructorUsedError;

  /// When the game was played
  @RequiredTimestampConverter()
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this HeadToHeadGameResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HeadToHeadGameResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HeadToHeadGameResultCopyWith<HeadToHeadGameResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HeadToHeadGameResultCopyWith<$Res> {
  factory $HeadToHeadGameResultCopyWith(
    HeadToHeadGameResult value,
    $Res Function(HeadToHeadGameResult) then,
  ) = _$HeadToHeadGameResultCopyWithImpl<$Res, HeadToHeadGameResult>;
  @useResult
  $Res call({
    String gameId,
    bool won,
    int pointsScored,
    int pointsAllowed,
    double eloChange,
    String? partnerId,
    String? opponentPartnerId,
    @RequiredTimestampConverter() DateTime timestamp,
  });
}

/// @nodoc
class _$HeadToHeadGameResultCopyWithImpl<
  $Res,
  $Val extends HeadToHeadGameResult
>
    implements $HeadToHeadGameResultCopyWith<$Res> {
  _$HeadToHeadGameResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HeadToHeadGameResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? won = null,
    Object? pointsScored = null,
    Object? pointsAllowed = null,
    Object? eloChange = null,
    Object? partnerId = freezed,
    Object? opponentPartnerId = freezed,
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
            partnerId: freezed == partnerId
                ? _value.partnerId
                : partnerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            opponentPartnerId: freezed == opponentPartnerId
                ? _value.opponentPartnerId
                : opponentPartnerId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$HeadToHeadGameResultImplCopyWith<$Res>
    implements $HeadToHeadGameResultCopyWith<$Res> {
  factory _$$HeadToHeadGameResultImplCopyWith(
    _$HeadToHeadGameResultImpl value,
    $Res Function(_$HeadToHeadGameResultImpl) then,
  ) = __$$HeadToHeadGameResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String gameId,
    bool won,
    int pointsScored,
    int pointsAllowed,
    double eloChange,
    String? partnerId,
    String? opponentPartnerId,
    @RequiredTimestampConverter() DateTime timestamp,
  });
}

/// @nodoc
class __$$HeadToHeadGameResultImplCopyWithImpl<$Res>
    extends _$HeadToHeadGameResultCopyWithImpl<$Res, _$HeadToHeadGameResultImpl>
    implements _$$HeadToHeadGameResultImplCopyWith<$Res> {
  __$$HeadToHeadGameResultImplCopyWithImpl(
    _$HeadToHeadGameResultImpl _value,
    $Res Function(_$HeadToHeadGameResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HeadToHeadGameResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? won = null,
    Object? pointsScored = null,
    Object? pointsAllowed = null,
    Object? eloChange = null,
    Object? partnerId = freezed,
    Object? opponentPartnerId = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _$HeadToHeadGameResultImpl(
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
        partnerId: freezed == partnerId
            ? _value.partnerId
            : partnerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        opponentPartnerId: freezed == opponentPartnerId
            ? _value.opponentPartnerId
            : opponentPartnerId // ignore: cast_nullable_to_non_nullable
                  as String?,
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
class _$HeadToHeadGameResultImpl extends _HeadToHeadGameResult {
  const _$HeadToHeadGameResultImpl({
    required this.gameId,
    required this.won,
    required this.pointsScored,
    required this.pointsAllowed,
    required this.eloChange,
    this.partnerId,
    this.opponentPartnerId,
    @RequiredTimestampConverter() required this.timestamp,
  }) : super._();

  factory _$HeadToHeadGameResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$HeadToHeadGameResultImplFromJson(json);

  /// Reference to the game
  @override
  final String gameId;

  /// Whether the primary user won
  @override
  final bool won;

  /// Points scored by user's team
  @override
  final int pointsScored;

  /// Points scored by opponent's team
  @override
  final int pointsAllowed;

  /// ELO change from this game
  @override
  final double eloChange;

  /// Partner who played with the user (if any)
  @override
  final String? partnerId;

  /// Partner who played with the opponent (if any)
  @override
  final String? opponentPartnerId;

  /// When the game was played
  @override
  @RequiredTimestampConverter()
  final DateTime timestamp;

  @override
  String toString() {
    return 'HeadToHeadGameResult(gameId: $gameId, won: $won, pointsScored: $pointsScored, pointsAllowed: $pointsAllowed, eloChange: $eloChange, partnerId: $partnerId, opponentPartnerId: $opponentPartnerId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HeadToHeadGameResultImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.won, won) || other.won == won) &&
            (identical(other.pointsScored, pointsScored) ||
                other.pointsScored == pointsScored) &&
            (identical(other.pointsAllowed, pointsAllowed) ||
                other.pointsAllowed == pointsAllowed) &&
            (identical(other.eloChange, eloChange) ||
                other.eloChange == eloChange) &&
            (identical(other.partnerId, partnerId) ||
                other.partnerId == partnerId) &&
            (identical(other.opponentPartnerId, opponentPartnerId) ||
                other.opponentPartnerId == opponentPartnerId) &&
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
    partnerId,
    opponentPartnerId,
    timestamp,
  );

  /// Create a copy of HeadToHeadGameResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HeadToHeadGameResultImplCopyWith<_$HeadToHeadGameResultImpl>
  get copyWith =>
      __$$HeadToHeadGameResultImplCopyWithImpl<_$HeadToHeadGameResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HeadToHeadGameResultImplToJson(this);
  }
}

abstract class _HeadToHeadGameResult extends HeadToHeadGameResult {
  const factory _HeadToHeadGameResult({
    required final String gameId,
    required final bool won,
    required final int pointsScored,
    required final int pointsAllowed,
    required final double eloChange,
    final String? partnerId,
    final String? opponentPartnerId,
    @RequiredTimestampConverter() required final DateTime timestamp,
  }) = _$HeadToHeadGameResultImpl;
  const _HeadToHeadGameResult._() : super._();

  factory _HeadToHeadGameResult.fromJson(Map<String, dynamic> json) =
      _$HeadToHeadGameResultImpl.fromJson;

  /// Reference to the game
  @override
  String get gameId;

  /// Whether the primary user won
  @override
  bool get won;

  /// Points scored by user's team
  @override
  int get pointsScored;

  /// Points scored by opponent's team
  @override
  int get pointsAllowed;

  /// ELO change from this game
  @override
  double get eloChange;

  /// Partner who played with the user (if any)
  @override
  String? get partnerId;

  /// Partner who played with the opponent (if any)
  @override
  String? get opponentPartnerId;

  /// When the game was played
  @override
  @RequiredTimestampConverter()
  DateTime get timestamp;

  /// Create a copy of HeadToHeadGameResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HeadToHeadGameResultImplCopyWith<_$HeadToHeadGameResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}
