// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_ranking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserRanking _$UserRankingFromJson(Map<String, dynamic> json) {
  return _UserRanking.fromJson(json);
}

/// @nodoc
mixin _$UserRanking {
  /// User's position in global rankings (1 = highest rated)
  int get globalRank => throw _privateConstructorUsedError;

  /// Total number of users with ELO ratings
  int get totalUsers => throw _privateConstructorUsedError;

  /// Percentile (0-100, where 100 = top performer)
  double get percentile => throw _privateConstructorUsedError;

  /// User's position among friends (nullable if no friends)
  int? get friendsRank => throw _privateConstructorUsedError;

  /// Total number of friends with ELO ratings (nullable if no friends)
  int? get totalFriends => throw _privateConstructorUsedError;

  /// When this ranking was calculated
  @RequiredTimestampConverter()
  DateTime get calculatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserRanking to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserRanking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserRankingCopyWith<UserRanking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserRankingCopyWith<$Res> {
  factory $UserRankingCopyWith(
    UserRanking value,
    $Res Function(UserRanking) then,
  ) = _$UserRankingCopyWithImpl<$Res, UserRanking>;
  @useResult
  $Res call({
    int globalRank,
    int totalUsers,
    double percentile,
    int? friendsRank,
    int? totalFriends,
    @RequiredTimestampConverter() DateTime calculatedAt,
  });
}

/// @nodoc
class _$UserRankingCopyWithImpl<$Res, $Val extends UserRanking>
    implements $UserRankingCopyWith<$Res> {
  _$UserRankingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserRanking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? globalRank = null,
    Object? totalUsers = null,
    Object? percentile = null,
    Object? friendsRank = freezed,
    Object? totalFriends = freezed,
    Object? calculatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            globalRank: null == globalRank
                ? _value.globalRank
                : globalRank // ignore: cast_nullable_to_non_nullable
                      as int,
            totalUsers: null == totalUsers
                ? _value.totalUsers
                : totalUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            percentile: null == percentile
                ? _value.percentile
                : percentile // ignore: cast_nullable_to_non_nullable
                      as double,
            friendsRank: freezed == friendsRank
                ? _value.friendsRank
                : friendsRank // ignore: cast_nullable_to_non_nullable
                      as int?,
            totalFriends: freezed == totalFriends
                ? _value.totalFriends
                : totalFriends // ignore: cast_nullable_to_non_nullable
                      as int?,
            calculatedAt: null == calculatedAt
                ? _value.calculatedAt
                : calculatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserRankingImplCopyWith<$Res>
    implements $UserRankingCopyWith<$Res> {
  factory _$$UserRankingImplCopyWith(
    _$UserRankingImpl value,
    $Res Function(_$UserRankingImpl) then,
  ) = __$$UserRankingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int globalRank,
    int totalUsers,
    double percentile,
    int? friendsRank,
    int? totalFriends,
    @RequiredTimestampConverter() DateTime calculatedAt,
  });
}

/// @nodoc
class __$$UserRankingImplCopyWithImpl<$Res>
    extends _$UserRankingCopyWithImpl<$Res, _$UserRankingImpl>
    implements _$$UserRankingImplCopyWith<$Res> {
  __$$UserRankingImplCopyWithImpl(
    _$UserRankingImpl _value,
    $Res Function(_$UserRankingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserRanking
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? globalRank = null,
    Object? totalUsers = null,
    Object? percentile = null,
    Object? friendsRank = freezed,
    Object? totalFriends = freezed,
    Object? calculatedAt = null,
  }) {
    return _then(
      _$UserRankingImpl(
        globalRank: null == globalRank
            ? _value.globalRank
            : globalRank // ignore: cast_nullable_to_non_nullable
                  as int,
        totalUsers: null == totalUsers
            ? _value.totalUsers
            : totalUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        percentile: null == percentile
            ? _value.percentile
            : percentile // ignore: cast_nullable_to_non_nullable
                  as double,
        friendsRank: freezed == friendsRank
            ? _value.friendsRank
            : friendsRank // ignore: cast_nullable_to_non_nullable
                  as int?,
        totalFriends: freezed == totalFriends
            ? _value.totalFriends
            : totalFriends // ignore: cast_nullable_to_non_nullable
                  as int?,
        calculatedAt: null == calculatedAt
            ? _value.calculatedAt
            : calculatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserRankingImpl extends _UserRanking {
  const _$UserRankingImpl({
    required this.globalRank,
    required this.totalUsers,
    required this.percentile,
    this.friendsRank,
    this.totalFriends,
    @RequiredTimestampConverter() required this.calculatedAt,
  }) : super._();

  factory _$UserRankingImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserRankingImplFromJson(json);

  /// User's position in global rankings (1 = highest rated)
  @override
  final int globalRank;

  /// Total number of users with ELO ratings
  @override
  final int totalUsers;

  /// Percentile (0-100, where 100 = top performer)
  @override
  final double percentile;

  /// User's position among friends (nullable if no friends)
  @override
  final int? friendsRank;

  /// Total number of friends with ELO ratings (nullable if no friends)
  @override
  final int? totalFriends;

  /// When this ranking was calculated
  @override
  @RequiredTimestampConverter()
  final DateTime calculatedAt;

  @override
  String toString() {
    return 'UserRanking(globalRank: $globalRank, totalUsers: $totalUsers, percentile: $percentile, friendsRank: $friendsRank, totalFriends: $totalFriends, calculatedAt: $calculatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserRankingImpl &&
            (identical(other.globalRank, globalRank) ||
                other.globalRank == globalRank) &&
            (identical(other.totalUsers, totalUsers) ||
                other.totalUsers == totalUsers) &&
            (identical(other.percentile, percentile) ||
                other.percentile == percentile) &&
            (identical(other.friendsRank, friendsRank) ||
                other.friendsRank == friendsRank) &&
            (identical(other.totalFriends, totalFriends) ||
                other.totalFriends == totalFriends) &&
            (identical(other.calculatedAt, calculatedAt) ||
                other.calculatedAt == calculatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    globalRank,
    totalUsers,
    percentile,
    friendsRank,
    totalFriends,
    calculatedAt,
  );

  /// Create a copy of UserRanking
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserRankingImplCopyWith<_$UserRankingImpl> get copyWith =>
      __$$UserRankingImplCopyWithImpl<_$UserRankingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserRankingImplToJson(this);
  }
}

abstract class _UserRanking extends UserRanking {
  const factory _UserRanking({
    required final int globalRank,
    required final int totalUsers,
    required final double percentile,
    final int? friendsRank,
    final int? totalFriends,
    @RequiredTimestampConverter() required final DateTime calculatedAt,
  }) = _$UserRankingImpl;
  const _UserRanking._() : super._();

  factory _UserRanking.fromJson(Map<String, dynamic> json) =
      _$UserRankingImpl.fromJson;

  /// User's position in global rankings (1 = highest rated)
  @override
  int get globalRank;

  /// Total number of users with ELO ratings
  @override
  int get totalUsers;

  /// Percentile (0-100, where 100 = top performer)
  @override
  double get percentile;

  /// User's position among friends (nullable if no friends)
  @override
  int? get friendsRank;

  /// Total number of friends with ELO ratings (nullable if no friends)
  @override
  int? get totalFriends;

  /// When this ranking was calculated
  @override
  @RequiredTimestampConverter()
  DateTime get calculatedAt;

  /// Create a copy of UserRanking
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserRankingImplCopyWith<_$UserRankingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
