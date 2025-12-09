// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'statistics_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlayerRating _$PlayerRatingFromJson(Map<String, dynamic> json) {
  return _PlayerRating.fromJson(json);
}

/// @nodoc
mixin _$PlayerRating {
  String get playerId => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;

  /// Serializes this PlayerRating to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlayerRating
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlayerRatingCopyWith<PlayerRating> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlayerRatingCopyWith<$Res> {
  factory $PlayerRatingCopyWith(
    PlayerRating value,
    $Res Function(PlayerRating) then,
  ) = _$PlayerRatingCopyWithImpl<$Res, PlayerRating>;
  @useResult
  $Res call({String playerId, double rating, String? displayName});
}

/// @nodoc
class _$PlayerRatingCopyWithImpl<$Res, $Val extends PlayerRating>
    implements $PlayerRatingCopyWith<$Res> {
  _$PlayerRatingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlayerRating
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? rating = null,
    Object? displayName = freezed,
  }) {
    return _then(
      _value.copyWith(
            playerId: null == playerId
                ? _value.playerId
                : playerId // ignore: cast_nullable_to_non_nullable
                      as String,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double,
            displayName: freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlayerRatingImplCopyWith<$Res>
    implements $PlayerRatingCopyWith<$Res> {
  factory _$$PlayerRatingImplCopyWith(
    _$PlayerRatingImpl value,
    $Res Function(_$PlayerRatingImpl) then,
  ) = __$$PlayerRatingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String playerId, double rating, String? displayName});
}

/// @nodoc
class __$$PlayerRatingImplCopyWithImpl<$Res>
    extends _$PlayerRatingCopyWithImpl<$Res, _$PlayerRatingImpl>
    implements _$$PlayerRatingImplCopyWith<$Res> {
  __$$PlayerRatingImplCopyWithImpl(
    _$PlayerRatingImpl _value,
    $Res Function(_$PlayerRatingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlayerRating
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? playerId = null,
    Object? rating = null,
    Object? displayName = freezed,
  }) {
    return _then(
      _$PlayerRatingImpl(
        playerId: null == playerId
            ? _value.playerId
            : playerId // ignore: cast_nullable_to_non_nullable
                  as String,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double,
        displayName: freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlayerRatingImpl extends _PlayerRating {
  const _$PlayerRatingImpl({
    required this.playerId,
    required this.rating,
    this.displayName,
  }) : super._();

  factory _$PlayerRatingImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlayerRatingImplFromJson(json);

  @override
  final String playerId;
  @override
  final double rating;
  @override
  final String? displayName;

  @override
  String toString() {
    return 'PlayerRating(playerId: $playerId, rating: $rating, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlayerRatingImpl &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, playerId, rating, displayName);

  /// Create a copy of PlayerRating
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlayerRatingImplCopyWith<_$PlayerRatingImpl> get copyWith =>
      __$$PlayerRatingImplCopyWithImpl<_$PlayerRatingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlayerRatingImplToJson(this);
  }
}

abstract class _PlayerRating extends PlayerRating {
  const factory _PlayerRating({
    required final String playerId,
    required final double rating,
    final String? displayName,
  }) = _$PlayerRatingImpl;
  const _PlayerRating._() : super._();

  factory _PlayerRating.fromJson(Map<String, dynamic> json) =
      _$PlayerRatingImpl.fromJson;

  @override
  String get playerId;
  @override
  double get rating;
  @override
  String? get displayName;

  /// Create a copy of PlayerRating
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlayerRatingImplCopyWith<_$PlayerRatingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EloResult _$EloResultFromJson(Map<String, dynamic> json) {
  return _EloResult.fromJson(json);
}

/// @nodoc
mixin _$EloResult {
  PlayerRating get teamAPlayer1 => throw _privateConstructorUsedError;
  PlayerRating get teamAPlayer2 => throw _privateConstructorUsedError;
  PlayerRating get teamBPlayer1 => throw _privateConstructorUsedError;
  PlayerRating get teamBPlayer2 => throw _privateConstructorUsedError;
  double get teamARating => throw _privateConstructorUsedError;
  double get teamBRating => throw _privateConstructorUsedError;
  double get teamAExpectedScore => throw _privateConstructorUsedError;
  double get teamBExpectedScore => throw _privateConstructorUsedError;
  double get ratingDelta => throw _privateConstructorUsedError;
  bool get teamAWon => throw _privateConstructorUsedError;

  /// Serializes this EloResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EloResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EloResultCopyWith<EloResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EloResultCopyWith<$Res> {
  factory $EloResultCopyWith(EloResult value, $Res Function(EloResult) then) =
      _$EloResultCopyWithImpl<$Res, EloResult>;
  @useResult
  $Res call({
    PlayerRating teamAPlayer1,
    PlayerRating teamAPlayer2,
    PlayerRating teamBPlayer1,
    PlayerRating teamBPlayer2,
    double teamARating,
    double teamBRating,
    double teamAExpectedScore,
    double teamBExpectedScore,
    double ratingDelta,
    bool teamAWon,
  });

  $PlayerRatingCopyWith<$Res> get teamAPlayer1;
  $PlayerRatingCopyWith<$Res> get teamAPlayer2;
  $PlayerRatingCopyWith<$Res> get teamBPlayer1;
  $PlayerRatingCopyWith<$Res> get teamBPlayer2;
}

/// @nodoc
class _$EloResultCopyWithImpl<$Res, $Val extends EloResult>
    implements $EloResultCopyWith<$Res> {
  _$EloResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EloResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamAPlayer1 = null,
    Object? teamAPlayer2 = null,
    Object? teamBPlayer1 = null,
    Object? teamBPlayer2 = null,
    Object? teamARating = null,
    Object? teamBRating = null,
    Object? teamAExpectedScore = null,
    Object? teamBExpectedScore = null,
    Object? ratingDelta = null,
    Object? teamAWon = null,
  }) {
    return _then(
      _value.copyWith(
            teamAPlayer1: null == teamAPlayer1
                ? _value.teamAPlayer1
                : teamAPlayer1 // ignore: cast_nullable_to_non_nullable
                      as PlayerRating,
            teamAPlayer2: null == teamAPlayer2
                ? _value.teamAPlayer2
                : teamAPlayer2 // ignore: cast_nullable_to_non_nullable
                      as PlayerRating,
            teamBPlayer1: null == teamBPlayer1
                ? _value.teamBPlayer1
                : teamBPlayer1 // ignore: cast_nullable_to_non_nullable
                      as PlayerRating,
            teamBPlayer2: null == teamBPlayer2
                ? _value.teamBPlayer2
                : teamBPlayer2 // ignore: cast_nullable_to_non_nullable
                      as PlayerRating,
            teamARating: null == teamARating
                ? _value.teamARating
                : teamARating // ignore: cast_nullable_to_non_nullable
                      as double,
            teamBRating: null == teamBRating
                ? _value.teamBRating
                : teamBRating // ignore: cast_nullable_to_non_nullable
                      as double,
            teamAExpectedScore: null == teamAExpectedScore
                ? _value.teamAExpectedScore
                : teamAExpectedScore // ignore: cast_nullable_to_non_nullable
                      as double,
            teamBExpectedScore: null == teamBExpectedScore
                ? _value.teamBExpectedScore
                : teamBExpectedScore // ignore: cast_nullable_to_non_nullable
                      as double,
            ratingDelta: null == ratingDelta
                ? _value.ratingDelta
                : ratingDelta // ignore: cast_nullable_to_non_nullable
                      as double,
            teamAWon: null == teamAWon
                ? _value.teamAWon
                : teamAWon // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of EloResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayerRatingCopyWith<$Res> get teamAPlayer1 {
    return $PlayerRatingCopyWith<$Res>(_value.teamAPlayer1, (value) {
      return _then(_value.copyWith(teamAPlayer1: value) as $Val);
    });
  }

  /// Create a copy of EloResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayerRatingCopyWith<$Res> get teamAPlayer2 {
    return $PlayerRatingCopyWith<$Res>(_value.teamAPlayer2, (value) {
      return _then(_value.copyWith(teamAPlayer2: value) as $Val);
    });
  }

  /// Create a copy of EloResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayerRatingCopyWith<$Res> get teamBPlayer1 {
    return $PlayerRatingCopyWith<$Res>(_value.teamBPlayer1, (value) {
      return _then(_value.copyWith(teamBPlayer1: value) as $Val);
    });
  }

  /// Create a copy of EloResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlayerRatingCopyWith<$Res> get teamBPlayer2 {
    return $PlayerRatingCopyWith<$Res>(_value.teamBPlayer2, (value) {
      return _then(_value.copyWith(teamBPlayer2: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EloResultImplCopyWith<$Res>
    implements $EloResultCopyWith<$Res> {
  factory _$$EloResultImplCopyWith(
    _$EloResultImpl value,
    $Res Function(_$EloResultImpl) then,
  ) = __$$EloResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    PlayerRating teamAPlayer1,
    PlayerRating teamAPlayer2,
    PlayerRating teamBPlayer1,
    PlayerRating teamBPlayer2,
    double teamARating,
    double teamBRating,
    double teamAExpectedScore,
    double teamBExpectedScore,
    double ratingDelta,
    bool teamAWon,
  });

  @override
  $PlayerRatingCopyWith<$Res> get teamAPlayer1;
  @override
  $PlayerRatingCopyWith<$Res> get teamAPlayer2;
  @override
  $PlayerRatingCopyWith<$Res> get teamBPlayer1;
  @override
  $PlayerRatingCopyWith<$Res> get teamBPlayer2;
}

/// @nodoc
class __$$EloResultImplCopyWithImpl<$Res>
    extends _$EloResultCopyWithImpl<$Res, _$EloResultImpl>
    implements _$$EloResultImplCopyWith<$Res> {
  __$$EloResultImplCopyWithImpl(
    _$EloResultImpl _value,
    $Res Function(_$EloResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EloResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? teamAPlayer1 = null,
    Object? teamAPlayer2 = null,
    Object? teamBPlayer1 = null,
    Object? teamBPlayer2 = null,
    Object? teamARating = null,
    Object? teamBRating = null,
    Object? teamAExpectedScore = null,
    Object? teamBExpectedScore = null,
    Object? ratingDelta = null,
    Object? teamAWon = null,
  }) {
    return _then(
      _$EloResultImpl(
        teamAPlayer1: null == teamAPlayer1
            ? _value.teamAPlayer1
            : teamAPlayer1 // ignore: cast_nullable_to_non_nullable
                  as PlayerRating,
        teamAPlayer2: null == teamAPlayer2
            ? _value.teamAPlayer2
            : teamAPlayer2 // ignore: cast_nullable_to_non_nullable
                  as PlayerRating,
        teamBPlayer1: null == teamBPlayer1
            ? _value.teamBPlayer1
            : teamBPlayer1 // ignore: cast_nullable_to_non_nullable
                  as PlayerRating,
        teamBPlayer2: null == teamBPlayer2
            ? _value.teamBPlayer2
            : teamBPlayer2 // ignore: cast_nullable_to_non_nullable
                  as PlayerRating,
        teamARating: null == teamARating
            ? _value.teamARating
            : teamARating // ignore: cast_nullable_to_non_nullable
                  as double,
        teamBRating: null == teamBRating
            ? _value.teamBRating
            : teamBRating // ignore: cast_nullable_to_non_nullable
                  as double,
        teamAExpectedScore: null == teamAExpectedScore
            ? _value.teamAExpectedScore
            : teamAExpectedScore // ignore: cast_nullable_to_non_nullable
                  as double,
        teamBExpectedScore: null == teamBExpectedScore
            ? _value.teamBExpectedScore
            : teamBExpectedScore // ignore: cast_nullable_to_non_nullable
                  as double,
        ratingDelta: null == ratingDelta
            ? _value.ratingDelta
            : ratingDelta // ignore: cast_nullable_to_non_nullable
                  as double,
        teamAWon: null == teamAWon
            ? _value.teamAWon
            : teamAWon // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EloResultImpl extends _EloResult {
  const _$EloResultImpl({
    required this.teamAPlayer1,
    required this.teamAPlayer2,
    required this.teamBPlayer1,
    required this.teamBPlayer2,
    required this.teamARating,
    required this.teamBRating,
    required this.teamAExpectedScore,
    required this.teamBExpectedScore,
    required this.ratingDelta,
    required this.teamAWon,
  }) : super._();

  factory _$EloResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$EloResultImplFromJson(json);

  @override
  final PlayerRating teamAPlayer1;
  @override
  final PlayerRating teamAPlayer2;
  @override
  final PlayerRating teamBPlayer1;
  @override
  final PlayerRating teamBPlayer2;
  @override
  final double teamARating;
  @override
  final double teamBRating;
  @override
  final double teamAExpectedScore;
  @override
  final double teamBExpectedScore;
  @override
  final double ratingDelta;
  @override
  final bool teamAWon;

  @override
  String toString() {
    return 'EloResult(teamAPlayer1: $teamAPlayer1, teamAPlayer2: $teamAPlayer2, teamBPlayer1: $teamBPlayer1, teamBPlayer2: $teamBPlayer2, teamARating: $teamARating, teamBRating: $teamBRating, teamAExpectedScore: $teamAExpectedScore, teamBExpectedScore: $teamBExpectedScore, ratingDelta: $ratingDelta, teamAWon: $teamAWon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EloResultImpl &&
            (identical(other.teamAPlayer1, teamAPlayer1) ||
                other.teamAPlayer1 == teamAPlayer1) &&
            (identical(other.teamAPlayer2, teamAPlayer2) ||
                other.teamAPlayer2 == teamAPlayer2) &&
            (identical(other.teamBPlayer1, teamBPlayer1) ||
                other.teamBPlayer1 == teamBPlayer1) &&
            (identical(other.teamBPlayer2, teamBPlayer2) ||
                other.teamBPlayer2 == teamBPlayer2) &&
            (identical(other.teamARating, teamARating) ||
                other.teamARating == teamARating) &&
            (identical(other.teamBRating, teamBRating) ||
                other.teamBRating == teamBRating) &&
            (identical(other.teamAExpectedScore, teamAExpectedScore) ||
                other.teamAExpectedScore == teamAExpectedScore) &&
            (identical(other.teamBExpectedScore, teamBExpectedScore) ||
                other.teamBExpectedScore == teamBExpectedScore) &&
            (identical(other.ratingDelta, ratingDelta) ||
                other.ratingDelta == ratingDelta) &&
            (identical(other.teamAWon, teamAWon) ||
                other.teamAWon == teamAWon));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    teamAPlayer1,
    teamAPlayer2,
    teamBPlayer1,
    teamBPlayer2,
    teamARating,
    teamBRating,
    teamAExpectedScore,
    teamBExpectedScore,
    ratingDelta,
    teamAWon,
  );

  /// Create a copy of EloResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EloResultImplCopyWith<_$EloResultImpl> get copyWith =>
      __$$EloResultImplCopyWithImpl<_$EloResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EloResultImplToJson(this);
  }
}

abstract class _EloResult extends EloResult {
  const factory _EloResult({
    required final PlayerRating teamAPlayer1,
    required final PlayerRating teamAPlayer2,
    required final PlayerRating teamBPlayer1,
    required final PlayerRating teamBPlayer2,
    required final double teamARating,
    required final double teamBRating,
    required final double teamAExpectedScore,
    required final double teamBExpectedScore,
    required final double ratingDelta,
    required final bool teamAWon,
  }) = _$EloResultImpl;
  const _EloResult._() : super._();

  factory _EloResult.fromJson(Map<String, dynamic> json) =
      _$EloResultImpl.fromJson;

  @override
  PlayerRating get teamAPlayer1;
  @override
  PlayerRating get teamAPlayer2;
  @override
  PlayerRating get teamBPlayer1;
  @override
  PlayerRating get teamBPlayer2;
  @override
  double get teamARating;
  @override
  double get teamBRating;
  @override
  double get teamAExpectedScore;
  @override
  double get teamBExpectedScore;
  @override
  double get ratingDelta;
  @override
  bool get teamAWon;

  /// Create a copy of EloResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EloResultImplCopyWith<_$EloResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeammateStats _$TeammateStatsFromJson(Map<String, dynamic> json) {
  return _TeammateStats.fromJson(json);
}

/// @nodoc
mixin _$TeammateStats {
  String get playerId => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  int get gamesPlayed => throw _privateConstructorUsedError;
  int get gamesWon => throw _privateConstructorUsedError;
  int get gamesLost => throw _privateConstructorUsedError;
  double get winRate => throw _privateConstructorUsedError;
  double get averageRatingChange => throw _privateConstructorUsedError;

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
    String playerId,
    String displayName,
    int gamesPlayed,
    int gamesWon,
    int gamesLost,
    double winRate,
    double averageRatingChange,
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
    Object? playerId = null,
    Object? displayName = null,
    Object? gamesPlayed = null,
    Object? gamesWon = null,
    Object? gamesLost = null,
    Object? winRate = null,
    Object? averageRatingChange = null,
  }) {
    return _then(
      _value.copyWith(
            playerId: null == playerId
                ? _value.playerId
                : playerId // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
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
            winRate: null == winRate
                ? _value.winRate
                : winRate // ignore: cast_nullable_to_non_nullable
                      as double,
            averageRatingChange: null == averageRatingChange
                ? _value.averageRatingChange
                : averageRatingChange // ignore: cast_nullable_to_non_nullable
                      as double,
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
    String playerId,
    String displayName,
    int gamesPlayed,
    int gamesWon,
    int gamesLost,
    double winRate,
    double averageRatingChange,
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
    Object? playerId = null,
    Object? displayName = null,
    Object? gamesPlayed = null,
    Object? gamesWon = null,
    Object? gamesLost = null,
    Object? winRate = null,
    Object? averageRatingChange = null,
  }) {
    return _then(
      _$TeammateStatsImpl(
        playerId: null == playerId
            ? _value.playerId
            : playerId // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
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
        winRate: null == winRate
            ? _value.winRate
            : winRate // ignore: cast_nullable_to_non_nullable
                  as double,
        averageRatingChange: null == averageRatingChange
            ? _value.averageRatingChange
            : averageRatingChange // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TeammateStatsImpl extends _TeammateStats {
  const _$TeammateStatsImpl({
    required this.playerId,
    required this.displayName,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.gamesLost,
    required this.winRate,
    required this.averageRatingChange,
  }) : super._();

  factory _$TeammateStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TeammateStatsImplFromJson(json);

  @override
  final String playerId;
  @override
  final String displayName;
  @override
  final int gamesPlayed;
  @override
  final int gamesWon;
  @override
  final int gamesLost;
  @override
  final double winRate;
  @override
  final double averageRatingChange;

  @override
  String toString() {
    return 'TeammateStats(playerId: $playerId, displayName: $displayName, gamesPlayed: $gamesPlayed, gamesWon: $gamesWon, gamesLost: $gamesLost, winRate: $winRate, averageRatingChange: $averageRatingChange)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeammateStatsImpl &&
            (identical(other.playerId, playerId) ||
                other.playerId == playerId) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.gamesPlayed, gamesPlayed) ||
                other.gamesPlayed == gamesPlayed) &&
            (identical(other.gamesWon, gamesWon) ||
                other.gamesWon == gamesWon) &&
            (identical(other.gamesLost, gamesLost) ||
                other.gamesLost == gamesLost) &&
            (identical(other.winRate, winRate) || other.winRate == winRate) &&
            (identical(other.averageRatingChange, averageRatingChange) ||
                other.averageRatingChange == averageRatingChange));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    playerId,
    displayName,
    gamesPlayed,
    gamesWon,
    gamesLost,
    winRate,
    averageRatingChange,
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
    required final String playerId,
    required final String displayName,
    required final int gamesPlayed,
    required final int gamesWon,
    required final int gamesLost,
    required final double winRate,
    required final double averageRatingChange,
  }) = _$TeammateStatsImpl;
  const _TeammateStats._() : super._();

  factory _TeammateStats.fromJson(Map<String, dynamic> json) =
      _$TeammateStatsImpl.fromJson;

  @override
  String get playerId;
  @override
  String get displayName;
  @override
  int get gamesPlayed;
  @override
  int get gamesWon;
  @override
  int get gamesLost;
  @override
  double get winRate;
  @override
  double get averageRatingChange;

  /// Create a copy of TeammateStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeammateStatsImplCopyWith<_$TeammateStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
