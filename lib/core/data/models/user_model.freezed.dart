// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get uid => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  bool get isEmailVerified => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastSignInAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isAnonymous =>
      throw _privateConstructorUsedError; // Extended fields for full user profile
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  List<String> get groupIds => throw _privateConstructorUsedError;
  List<String> get gameIds =>
      throw _privateConstructorUsedError; // Social graph cache fields (Story 11.6)
  List<String> get friendIds => throw _privateConstructorUsedError;
  int get friendCount => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get friendsLastUpdated => throw _privateConstructorUsedError; // User preferences
  bool get notificationsEnabled => throw _privateConstructorUsedError;
  bool get emailNotifications => throw _privateConstructorUsedError;
  bool get pushNotifications =>
      throw _privateConstructorUsedError; // Privacy settings
  UserPrivacyLevel get privacyLevel => throw _privateConstructorUsedError;
  bool get showEmail => throw _privateConstructorUsedError;
  bool get showPhoneNumber => throw _privateConstructorUsedError; // Stats
  int get gamesPlayed => throw _privateConstructorUsedError;
  int get gamesWon => throw _privateConstructorUsedError;
  int get gamesLost => throw _privateConstructorUsedError;
  int get totalScore => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  List<String> get recentGameIds => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastGameDate => throw _privateConstructorUsedError;
  Map<String, dynamic> get teammateStats =>
      throw _privateConstructorUsedError; // ELO Rating fields (Story 14.5.3)
  double get eloRating => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get eloLastUpdated => throw _privateConstructorUsedError;
  double get eloPeak => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get eloPeakDate => throw _privateConstructorUsedError;
  int get eloGamesPlayed =>
      throw _privateConstructorUsedError; // Nemesis/Rival tracking (Story 301.8)
  NemesisRecord? get nemesis =>
      throw _privateConstructorUsedError; // Best Win tracking (Story 301.6)
  BestWinRecord? get bestWin =>
      throw _privateConstructorUsedError; // Point Stats tracking (Story 301.7)
  PointStats? get pointStats =>
      throw _privateConstructorUsedError; // Role-Based Performance tracking (Story 301.9)
  RoleBasedStats? get roleBasedStats => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    String uid,
    String email,
    String? displayName,
    String? photoUrl,
    bool isEmailVerified,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? lastSignInAt,
    @TimestampConverter() DateTime? updatedAt,
    bool isAnonymous,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? location,
    String? bio,
    List<String> groupIds,
    List<String> gameIds,
    List<String> friendIds,
    int friendCount,
    @TimestampConverter() DateTime? friendsLastUpdated,
    bool notificationsEnabled,
    bool emailNotifications,
    bool pushNotifications,
    UserPrivacyLevel privacyLevel,
    bool showEmail,
    bool showPhoneNumber,
    int gamesPlayed,
    int gamesWon,
    int gamesLost,
    int totalScore,
    int currentStreak,
    List<String> recentGameIds,
    @TimestampConverter() DateTime? lastGameDate,
    Map<String, dynamic> teammateStats,
    double eloRating,
    @TimestampConverter() DateTime? eloLastUpdated,
    double eloPeak,
    @TimestampConverter() DateTime? eloPeakDate,
    int eloGamesPlayed,
    NemesisRecord? nemesis,
    BestWinRecord? bestWin,
    PointStats? pointStats,
    RoleBasedStats? roleBasedStats,
  });

  $NemesisRecordCopyWith<$Res>? get nemesis;
  $BestWinRecordCopyWith<$Res>? get bestWin;
  $PointStatsCopyWith<$Res>? get pointStats;
  $RoleBasedStatsCopyWith<$Res>? get roleBasedStats;
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? isEmailVerified = null,
    Object? createdAt = freezed,
    Object? lastSignInAt = freezed,
    Object? updatedAt = freezed,
    Object? isAnonymous = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? phoneNumber = freezed,
    Object? dateOfBirth = freezed,
    Object? location = freezed,
    Object? bio = freezed,
    Object? groupIds = null,
    Object? gameIds = null,
    Object? friendIds = null,
    Object? friendCount = null,
    Object? friendsLastUpdated = freezed,
    Object? notificationsEnabled = null,
    Object? emailNotifications = null,
    Object? pushNotifications = null,
    Object? privacyLevel = null,
    Object? showEmail = null,
    Object? showPhoneNumber = null,
    Object? gamesPlayed = null,
    Object? gamesWon = null,
    Object? gamesLost = null,
    Object? totalScore = null,
    Object? currentStreak = null,
    Object? recentGameIds = null,
    Object? lastGameDate = freezed,
    Object? teammateStats = null,
    Object? eloRating = null,
    Object? eloLastUpdated = freezed,
    Object? eloPeak = null,
    Object? eloPeakDate = freezed,
    Object? eloGamesPlayed = null,
    Object? nemesis = freezed,
    Object? bestWin = freezed,
    Object? pointStats = freezed,
    Object? roleBasedStats = freezed,
  }) {
    return _then(
      _value.copyWith(
            uid: null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            isEmailVerified: null == isEmailVerified
                ? _value.isEmailVerified
                : isEmailVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastSignInAt: freezed == lastSignInAt
                ? _value.lastSignInAt
                : lastSignInAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isAnonymous: null == isAnonymous
                ? _value.isAnonymous
                : isAnonymous // ignore: cast_nullable_to_non_nullable
                      as bool,
            firstName: freezed == firstName
                ? _value.firstName
                : firstName // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastName: freezed == lastName
                ? _value.lastName
                : lastName // ignore: cast_nullable_to_non_nullable
                      as String?,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateOfBirth: freezed == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            groupIds: null == groupIds
                ? _value.groupIds
                : groupIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            gameIds: null == gameIds
                ? _value.gameIds
                : gameIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            friendIds: null == friendIds
                ? _value.friendIds
                : friendIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            friendCount: null == friendCount
                ? _value.friendCount
                : friendCount // ignore: cast_nullable_to_non_nullable
                      as int,
            friendsLastUpdated: freezed == friendsLastUpdated
                ? _value.friendsLastUpdated
                : friendsLastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            notificationsEnabled: null == notificationsEnabled
                ? _value.notificationsEnabled
                : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            emailNotifications: null == emailNotifications
                ? _value.emailNotifications
                : emailNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            pushNotifications: null == pushNotifications
                ? _value.pushNotifications
                : pushNotifications // ignore: cast_nullable_to_non_nullable
                      as bool,
            privacyLevel: null == privacyLevel
                ? _value.privacyLevel
                : privacyLevel // ignore: cast_nullable_to_non_nullable
                      as UserPrivacyLevel,
            showEmail: null == showEmail
                ? _value.showEmail
                : showEmail // ignore: cast_nullable_to_non_nullable
                      as bool,
            showPhoneNumber: null == showPhoneNumber
                ? _value.showPhoneNumber
                : showPhoneNumber // ignore: cast_nullable_to_non_nullable
                      as bool,
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
            totalScore: null == totalScore
                ? _value.totalScore
                : totalScore // ignore: cast_nullable_to_non_nullable
                      as int,
            currentStreak: null == currentStreak
                ? _value.currentStreak
                : currentStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            recentGameIds: null == recentGameIds
                ? _value.recentGameIds
                : recentGameIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            lastGameDate: freezed == lastGameDate
                ? _value.lastGameDate
                : lastGameDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            teammateStats: null == teammateStats
                ? _value.teammateStats
                : teammateStats // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            eloRating: null == eloRating
                ? _value.eloRating
                : eloRating // ignore: cast_nullable_to_non_nullable
                      as double,
            eloLastUpdated: freezed == eloLastUpdated
                ? _value.eloLastUpdated
                : eloLastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            eloPeak: null == eloPeak
                ? _value.eloPeak
                : eloPeak // ignore: cast_nullable_to_non_nullable
                      as double,
            eloPeakDate: freezed == eloPeakDate
                ? _value.eloPeakDate
                : eloPeakDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            eloGamesPlayed: null == eloGamesPlayed
                ? _value.eloGamesPlayed
                : eloGamesPlayed // ignore: cast_nullable_to_non_nullable
                      as int,
            nemesis: freezed == nemesis
                ? _value.nemesis
                : nemesis // ignore: cast_nullable_to_non_nullable
                      as NemesisRecord?,
            bestWin: freezed == bestWin
                ? _value.bestWin
                : bestWin // ignore: cast_nullable_to_non_nullable
                      as BestWinRecord?,
            pointStats: freezed == pointStats
                ? _value.pointStats
                : pointStats // ignore: cast_nullable_to_non_nullable
                      as PointStats?,
            roleBasedStats: freezed == roleBasedStats
                ? _value.roleBasedStats
                : roleBasedStats // ignore: cast_nullable_to_non_nullable
                      as RoleBasedStats?,
          )
          as $Val,
    );
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NemesisRecordCopyWith<$Res>? get nemesis {
    if (_value.nemesis == null) {
      return null;
    }

    return $NemesisRecordCopyWith<$Res>(_value.nemesis!, (value) {
      return _then(_value.copyWith(nemesis: value) as $Val);
    });
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BestWinRecordCopyWith<$Res>? get bestWin {
    if (_value.bestWin == null) {
      return null;
    }

    return $BestWinRecordCopyWith<$Res>(_value.bestWin!, (value) {
      return _then(_value.copyWith(bestWin: value) as $Val);
    });
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PointStatsCopyWith<$Res>? get pointStats {
    if (_value.pointStats == null) {
      return null;
    }

    return $PointStatsCopyWith<$Res>(_value.pointStats!, (value) {
      return _then(_value.copyWith(pointStats: value) as $Val);
    });
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RoleBasedStatsCopyWith<$Res>? get roleBasedStats {
    if (_value.roleBasedStats == null) {
      return null;
    }

    return $RoleBasedStatsCopyWith<$Res>(_value.roleBasedStats!, (value) {
      return _then(_value.copyWith(roleBasedStats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String uid,
    String email,
    String? displayName,
    String? photoUrl,
    bool isEmailVerified,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? lastSignInAt,
    @TimestampConverter() DateTime? updatedAt,
    bool isAnonymous,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? location,
    String? bio,
    List<String> groupIds,
    List<String> gameIds,
    List<String> friendIds,
    int friendCount,
    @TimestampConverter() DateTime? friendsLastUpdated,
    bool notificationsEnabled,
    bool emailNotifications,
    bool pushNotifications,
    UserPrivacyLevel privacyLevel,
    bool showEmail,
    bool showPhoneNumber,
    int gamesPlayed,
    int gamesWon,
    int gamesLost,
    int totalScore,
    int currentStreak,
    List<String> recentGameIds,
    @TimestampConverter() DateTime? lastGameDate,
    Map<String, dynamic> teammateStats,
    double eloRating,
    @TimestampConverter() DateTime? eloLastUpdated,
    double eloPeak,
    @TimestampConverter() DateTime? eloPeakDate,
    int eloGamesPlayed,
    NemesisRecord? nemesis,
    BestWinRecord? bestWin,
    PointStats? pointStats,
    RoleBasedStats? roleBasedStats,
  });

  @override
  $NemesisRecordCopyWith<$Res>? get nemesis;
  @override
  $BestWinRecordCopyWith<$Res>? get bestWin;
  @override
  $PointStatsCopyWith<$Res>? get pointStats;
  @override
  $RoleBasedStatsCopyWith<$Res>? get roleBasedStats;
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? isEmailVerified = null,
    Object? createdAt = freezed,
    Object? lastSignInAt = freezed,
    Object? updatedAt = freezed,
    Object? isAnonymous = null,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? phoneNumber = freezed,
    Object? dateOfBirth = freezed,
    Object? location = freezed,
    Object? bio = freezed,
    Object? groupIds = null,
    Object? gameIds = null,
    Object? friendIds = null,
    Object? friendCount = null,
    Object? friendsLastUpdated = freezed,
    Object? notificationsEnabled = null,
    Object? emailNotifications = null,
    Object? pushNotifications = null,
    Object? privacyLevel = null,
    Object? showEmail = null,
    Object? showPhoneNumber = null,
    Object? gamesPlayed = null,
    Object? gamesWon = null,
    Object? gamesLost = null,
    Object? totalScore = null,
    Object? currentStreak = null,
    Object? recentGameIds = null,
    Object? lastGameDate = freezed,
    Object? teammateStats = null,
    Object? eloRating = null,
    Object? eloLastUpdated = freezed,
    Object? eloPeak = null,
    Object? eloPeakDate = freezed,
    Object? eloGamesPlayed = null,
    Object? nemesis = freezed,
    Object? bestWin = freezed,
    Object? pointStats = freezed,
    Object? roleBasedStats = freezed,
  }) {
    return _then(
      _$UserModelImpl(
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        isEmailVerified: null == isEmailVerified
            ? _value.isEmailVerified
            : isEmailVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastSignInAt: freezed == lastSignInAt
            ? _value.lastSignInAt
            : lastSignInAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isAnonymous: null == isAnonymous
            ? _value.isAnonymous
            : isAnonymous // ignore: cast_nullable_to_non_nullable
                  as bool,
        firstName: freezed == firstName
            ? _value.firstName
            : firstName // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastName: freezed == lastName
            ? _value.lastName
            : lastName // ignore: cast_nullable_to_non_nullable
                  as String?,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateOfBirth: freezed == dateOfBirth
            ? _value.dateOfBirth
            : dateOfBirth // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        groupIds: null == groupIds
            ? _value._groupIds
            : groupIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        gameIds: null == gameIds
            ? _value._gameIds
            : gameIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        friendIds: null == friendIds
            ? _value._friendIds
            : friendIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        friendCount: null == friendCount
            ? _value.friendCount
            : friendCount // ignore: cast_nullable_to_non_nullable
                  as int,
        friendsLastUpdated: freezed == friendsLastUpdated
            ? _value.friendsLastUpdated
            : friendsLastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        notificationsEnabled: null == notificationsEnabled
            ? _value.notificationsEnabled
            : notificationsEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        emailNotifications: null == emailNotifications
            ? _value.emailNotifications
            : emailNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        pushNotifications: null == pushNotifications
            ? _value.pushNotifications
            : pushNotifications // ignore: cast_nullable_to_non_nullable
                  as bool,
        privacyLevel: null == privacyLevel
            ? _value.privacyLevel
            : privacyLevel // ignore: cast_nullable_to_non_nullable
                  as UserPrivacyLevel,
        showEmail: null == showEmail
            ? _value.showEmail
            : showEmail // ignore: cast_nullable_to_non_nullable
                  as bool,
        showPhoneNumber: null == showPhoneNumber
            ? _value.showPhoneNumber
            : showPhoneNumber // ignore: cast_nullable_to_non_nullable
                  as bool,
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
        totalScore: null == totalScore
            ? _value.totalScore
            : totalScore // ignore: cast_nullable_to_non_nullable
                  as int,
        currentStreak: null == currentStreak
            ? _value.currentStreak
            : currentStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        recentGameIds: null == recentGameIds
            ? _value._recentGameIds
            : recentGameIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        lastGameDate: freezed == lastGameDate
            ? _value.lastGameDate
            : lastGameDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        teammateStats: null == teammateStats
            ? _value._teammateStats
            : teammateStats // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        eloRating: null == eloRating
            ? _value.eloRating
            : eloRating // ignore: cast_nullable_to_non_nullable
                  as double,
        eloLastUpdated: freezed == eloLastUpdated
            ? _value.eloLastUpdated
            : eloLastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        eloPeak: null == eloPeak
            ? _value.eloPeak
            : eloPeak // ignore: cast_nullable_to_non_nullable
                  as double,
        eloPeakDate: freezed == eloPeakDate
            ? _value.eloPeakDate
            : eloPeakDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        eloGamesPlayed: null == eloGamesPlayed
            ? _value.eloGamesPlayed
            : eloGamesPlayed // ignore: cast_nullable_to_non_nullable
                  as int,
        nemesis: freezed == nemesis
            ? _value.nemesis
            : nemesis // ignore: cast_nullable_to_non_nullable
                  as NemesisRecord?,
        bestWin: freezed == bestWin
            ? _value.bestWin
            : bestWin // ignore: cast_nullable_to_non_nullable
                  as BestWinRecord?,
        pointStats: freezed == pointStats
            ? _value.pointStats
            : pointStats // ignore: cast_nullable_to_non_nullable
                  as PointStats?,
        roleBasedStats: freezed == roleBasedStats
            ? _value.roleBasedStats
            : roleBasedStats // ignore: cast_nullable_to_non_nullable
                  as RoleBasedStats?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.isEmailVerified,
    @TimestampConverter() this.createdAt,
    @TimestampConverter() this.lastSignInAt,
    @TimestampConverter() this.updatedAt,
    required this.isAnonymous,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.dateOfBirth,
    this.location,
    this.bio,
    final List<String> groupIds = const [],
    final List<String> gameIds = const [],
    final List<String> friendIds = const [],
    this.friendCount = 0,
    @TimestampConverter() this.friendsLastUpdated,
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.privacyLevel = UserPrivacyLevel.public,
    this.showEmail = true,
    this.showPhoneNumber = true,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.totalScore = 0,
    this.currentStreak = 0,
    final List<String> recentGameIds = const [],
    @TimestampConverter() this.lastGameDate,
    final Map<String, dynamic> teammateStats = const {},
    this.eloRating = 1600.0,
    @TimestampConverter() this.eloLastUpdated,
    this.eloPeak = 1600.0,
    @TimestampConverter() this.eloPeakDate,
    this.eloGamesPlayed = 0,
    this.nemesis,
    this.bestWin,
    this.pointStats,
    this.roleBasedStats,
  }) : _groupIds = groupIds,
       _gameIds = gameIds,
       _friendIds = friendIds,
       _recentGameIds = recentGameIds,
       _teammateStats = teammateStats,
       super._();

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String uid;
  @override
  final String email;
  @override
  final String? displayName;
  @override
  final String? photoUrl;
  @override
  final bool isEmailVerified;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? lastSignInAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;
  @override
  final bool isAnonymous;
  // Extended fields for full user profile
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? phoneNumber;
  @override
  final DateTime? dateOfBirth;
  @override
  final String? location;
  @override
  final String? bio;
  final List<String> _groupIds;
  @override
  @JsonKey()
  List<String> get groupIds {
    if (_groupIds is EqualUnmodifiableListView) return _groupIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groupIds);
  }

  final List<String> _gameIds;
  @override
  @JsonKey()
  List<String> get gameIds {
    if (_gameIds is EqualUnmodifiableListView) return _gameIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gameIds);
  }

  // Social graph cache fields (Story 11.6)
  final List<String> _friendIds;
  // Social graph cache fields (Story 11.6)
  @override
  @JsonKey()
  List<String> get friendIds {
    if (_friendIds is EqualUnmodifiableListView) return _friendIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_friendIds);
  }

  @override
  @JsonKey()
  final int friendCount;
  @override
  @TimestampConverter()
  final DateTime? friendsLastUpdated;
  // User preferences
  @override
  @JsonKey()
  final bool notificationsEnabled;
  @override
  @JsonKey()
  final bool emailNotifications;
  @override
  @JsonKey()
  final bool pushNotifications;
  // Privacy settings
  @override
  @JsonKey()
  final UserPrivacyLevel privacyLevel;
  @override
  @JsonKey()
  final bool showEmail;
  @override
  @JsonKey()
  final bool showPhoneNumber;
  // Stats
  @override
  @JsonKey()
  final int gamesPlayed;
  @override
  @JsonKey()
  final int gamesWon;
  @override
  @JsonKey()
  final int gamesLost;
  @override
  @JsonKey()
  final int totalScore;
  @override
  @JsonKey()
  final int currentStreak;
  final List<String> _recentGameIds;
  @override
  @JsonKey()
  List<String> get recentGameIds {
    if (_recentGameIds is EqualUnmodifiableListView) return _recentGameIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentGameIds);
  }

  @override
  @TimestampConverter()
  final DateTime? lastGameDate;
  final Map<String, dynamic> _teammateStats;
  @override
  @JsonKey()
  Map<String, dynamic> get teammateStats {
    if (_teammateStats is EqualUnmodifiableMapView) return _teammateStats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_teammateStats);
  }

  // ELO Rating fields (Story 14.5.3)
  @override
  @JsonKey()
  final double eloRating;
  @override
  @TimestampConverter()
  final DateTime? eloLastUpdated;
  @override
  @JsonKey()
  final double eloPeak;
  @override
  @TimestampConverter()
  final DateTime? eloPeakDate;
  @override
  @JsonKey()
  final int eloGamesPlayed;
  // Nemesis/Rival tracking (Story 301.8)
  @override
  final NemesisRecord? nemesis;
  // Best Win tracking (Story 301.6)
  @override
  final BestWinRecord? bestWin;
  // Point Stats tracking (Story 301.7)
  @override
  final PointStats? pointStats;
  // Role-Based Performance tracking (Story 301.9)
  @override
  final RoleBasedStats? roleBasedStats;

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, isEmailVerified: $isEmailVerified, createdAt: $createdAt, lastSignInAt: $lastSignInAt, updatedAt: $updatedAt, isAnonymous: $isAnonymous, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, dateOfBirth: $dateOfBirth, location: $location, bio: $bio, groupIds: $groupIds, gameIds: $gameIds, friendIds: $friendIds, friendCount: $friendCount, friendsLastUpdated: $friendsLastUpdated, notificationsEnabled: $notificationsEnabled, emailNotifications: $emailNotifications, pushNotifications: $pushNotifications, privacyLevel: $privacyLevel, showEmail: $showEmail, showPhoneNumber: $showPhoneNumber, gamesPlayed: $gamesPlayed, gamesWon: $gamesWon, gamesLost: $gamesLost, totalScore: $totalScore, currentStreak: $currentStreak, recentGameIds: $recentGameIds, lastGameDate: $lastGameDate, teammateStats: $teammateStats, eloRating: $eloRating, eloLastUpdated: $eloLastUpdated, eloPeak: $eloPeak, eloPeakDate: $eloPeakDate, eloGamesPlayed: $eloGamesPlayed, nemesis: $nemesis, bestWin: $bestWin, pointStats: $pointStats, roleBasedStats: $roleBasedStats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.isEmailVerified, isEmailVerified) ||
                other.isEmailVerified == isEmailVerified) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastSignInAt, lastSignInAt) ||
                other.lastSignInAt == lastSignInAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isAnonymous, isAnonymous) ||
                other.isAnonymous == isAnonymous) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            const DeepCollectionEquality().equals(other._groupIds, _groupIds) &&
            const DeepCollectionEquality().equals(other._gameIds, _gameIds) &&
            const DeepCollectionEquality().equals(
              other._friendIds,
              _friendIds,
            ) &&
            (identical(other.friendCount, friendCount) ||
                other.friendCount == friendCount) &&
            (identical(other.friendsLastUpdated, friendsLastUpdated) ||
                other.friendsLastUpdated == friendsLastUpdated) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            (identical(other.emailNotifications, emailNotifications) ||
                other.emailNotifications == emailNotifications) &&
            (identical(other.pushNotifications, pushNotifications) ||
                other.pushNotifications == pushNotifications) &&
            (identical(other.privacyLevel, privacyLevel) ||
                other.privacyLevel == privacyLevel) &&
            (identical(other.showEmail, showEmail) ||
                other.showEmail == showEmail) &&
            (identical(other.showPhoneNumber, showPhoneNumber) ||
                other.showPhoneNumber == showPhoneNumber) &&
            (identical(other.gamesPlayed, gamesPlayed) ||
                other.gamesPlayed == gamesPlayed) &&
            (identical(other.gamesWon, gamesWon) ||
                other.gamesWon == gamesWon) &&
            (identical(other.gamesLost, gamesLost) ||
                other.gamesLost == gamesLost) &&
            (identical(other.totalScore, totalScore) ||
                other.totalScore == totalScore) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            const DeepCollectionEquality().equals(
              other._recentGameIds,
              _recentGameIds,
            ) &&
            (identical(other.lastGameDate, lastGameDate) ||
                other.lastGameDate == lastGameDate) &&
            const DeepCollectionEquality().equals(
              other._teammateStats,
              _teammateStats,
            ) &&
            (identical(other.eloRating, eloRating) ||
                other.eloRating == eloRating) &&
            (identical(other.eloLastUpdated, eloLastUpdated) ||
                other.eloLastUpdated == eloLastUpdated) &&
            (identical(other.eloPeak, eloPeak) || other.eloPeak == eloPeak) &&
            (identical(other.eloPeakDate, eloPeakDate) ||
                other.eloPeakDate == eloPeakDate) &&
            (identical(other.eloGamesPlayed, eloGamesPlayed) ||
                other.eloGamesPlayed == eloGamesPlayed) &&
            (identical(other.nemesis, nemesis) || other.nemesis == nemesis) &&
            (identical(other.bestWin, bestWin) || other.bestWin == bestWin) &&
            (identical(other.pointStats, pointStats) ||
                other.pointStats == pointStats) &&
            (identical(other.roleBasedStats, roleBasedStats) ||
                other.roleBasedStats == roleBasedStats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    uid,
    email,
    displayName,
    photoUrl,
    isEmailVerified,
    createdAt,
    lastSignInAt,
    updatedAt,
    isAnonymous,
    firstName,
    lastName,
    phoneNumber,
    dateOfBirth,
    location,
    bio,
    const DeepCollectionEquality().hash(_groupIds),
    const DeepCollectionEquality().hash(_gameIds),
    const DeepCollectionEquality().hash(_friendIds),
    friendCount,
    friendsLastUpdated,
    notificationsEnabled,
    emailNotifications,
    pushNotifications,
    privacyLevel,
    showEmail,
    showPhoneNumber,
    gamesPlayed,
    gamesWon,
    gamesLost,
    totalScore,
    currentStreak,
    const DeepCollectionEquality().hash(_recentGameIds),
    lastGameDate,
    const DeepCollectionEquality().hash(_teammateStats),
    eloRating,
    eloLastUpdated,
    eloPeak,
    eloPeakDate,
    eloGamesPlayed,
    nemesis,
    bestWin,
    pointStats,
    roleBasedStats,
  ]);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel extends UserModel {
  const factory _UserModel({
    required final String uid,
    required final String email,
    final String? displayName,
    final String? photoUrl,
    required final bool isEmailVerified,
    @TimestampConverter() final DateTime? createdAt,
    @TimestampConverter() final DateTime? lastSignInAt,
    @TimestampConverter() final DateTime? updatedAt,
    required final bool isAnonymous,
    final String? firstName,
    final String? lastName,
    final String? phoneNumber,
    final DateTime? dateOfBirth,
    final String? location,
    final String? bio,
    final List<String> groupIds,
    final List<String> gameIds,
    final List<String> friendIds,
    final int friendCount,
    @TimestampConverter() final DateTime? friendsLastUpdated,
    final bool notificationsEnabled,
    final bool emailNotifications,
    final bool pushNotifications,
    final UserPrivacyLevel privacyLevel,
    final bool showEmail,
    final bool showPhoneNumber,
    final int gamesPlayed,
    final int gamesWon,
    final int gamesLost,
    final int totalScore,
    final int currentStreak,
    final List<String> recentGameIds,
    @TimestampConverter() final DateTime? lastGameDate,
    final Map<String, dynamic> teammateStats,
    final double eloRating,
    @TimestampConverter() final DateTime? eloLastUpdated,
    final double eloPeak,
    @TimestampConverter() final DateTime? eloPeakDate,
    final int eloGamesPlayed,
    final NemesisRecord? nemesis,
    final BestWinRecord? bestWin,
    final PointStats? pointStats,
    final RoleBasedStats? roleBasedStats,
  }) = _$UserModelImpl;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get uid;
  @override
  String get email;
  @override
  String? get displayName;
  @override
  String? get photoUrl;
  @override
  bool get isEmailVerified;
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  @TimestampConverter()
  DateTime? get lastSignInAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;
  @override
  bool get isAnonymous; // Extended fields for full user profile
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String? get phoneNumber;
  @override
  DateTime? get dateOfBirth;
  @override
  String? get location;
  @override
  String? get bio;
  @override
  List<String> get groupIds;
  @override
  List<String> get gameIds; // Social graph cache fields (Story 11.6)
  @override
  List<String> get friendIds;
  @override
  int get friendCount;
  @override
  @TimestampConverter()
  DateTime? get friendsLastUpdated; // User preferences
  @override
  bool get notificationsEnabled;
  @override
  bool get emailNotifications;
  @override
  bool get pushNotifications; // Privacy settings
  @override
  UserPrivacyLevel get privacyLevel;
  @override
  bool get showEmail;
  @override
  bool get showPhoneNumber; // Stats
  @override
  int get gamesPlayed;
  @override
  int get gamesWon;
  @override
  int get gamesLost;
  @override
  int get totalScore;
  @override
  int get currentStreak;
  @override
  List<String> get recentGameIds;
  @override
  @TimestampConverter()
  DateTime? get lastGameDate;
  @override
  Map<String, dynamic> get teammateStats; // ELO Rating fields (Story 14.5.3)
  @override
  double get eloRating;
  @override
  @TimestampConverter()
  DateTime? get eloLastUpdated;
  @override
  double get eloPeak;
  @override
  @TimestampConverter()
  DateTime? get eloPeakDate;
  @override
  int get eloGamesPlayed; // Nemesis/Rival tracking (Story 301.8)
  @override
  NemesisRecord? get nemesis; // Best Win tracking (Story 301.6)
  @override
  BestWinRecord? get bestWin; // Point Stats tracking (Story 301.7)
  @override
  PointStats? get pointStats; // Role-Based Performance tracking (Story 301.9)
  @override
  RoleBasedStats? get roleBasedStats;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NemesisRecord _$NemesisRecordFromJson(Map<String, dynamic> json) {
  return _NemesisRecord.fromJson(json);
}

/// @nodoc
mixin _$NemesisRecord {
  /// Opponent user ID
  String get opponentId => throw _privateConstructorUsedError;

  /// Opponent display name (cached for quick display)
  String get opponentName => throw _privateConstructorUsedError;

  /// Total games lost against this opponent
  int get gamesLost => throw _privateConstructorUsedError;

  /// Total games won against this opponent
  int get gamesWon => throw _privateConstructorUsedError;

  /// Total games played against this opponent (gamesWon + gamesLost)
  int get gamesPlayed => throw _privateConstructorUsedError;

  /// Win rate as percentage (0-100)
  double get winRate => throw _privateConstructorUsedError;

  /// Serializes this NemesisRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NemesisRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NemesisRecordCopyWith<NemesisRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NemesisRecordCopyWith<$Res> {
  factory $NemesisRecordCopyWith(
    NemesisRecord value,
    $Res Function(NemesisRecord) then,
  ) = _$NemesisRecordCopyWithImpl<$Res, NemesisRecord>;
  @useResult
  $Res call({
    String opponentId,
    String opponentName,
    int gamesLost,
    int gamesWon,
    int gamesPlayed,
    double winRate,
  });
}

/// @nodoc
class _$NemesisRecordCopyWithImpl<$Res, $Val extends NemesisRecord>
    implements $NemesisRecordCopyWith<$Res> {
  _$NemesisRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NemesisRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? opponentId = null,
    Object? opponentName = null,
    Object? gamesLost = null,
    Object? gamesWon = null,
    Object? gamesPlayed = null,
    Object? winRate = null,
  }) {
    return _then(
      _value.copyWith(
            opponentId: null == opponentId
                ? _value.opponentId
                : opponentId // ignore: cast_nullable_to_non_nullable
                      as String,
            opponentName: null == opponentName
                ? _value.opponentName
                : opponentName // ignore: cast_nullable_to_non_nullable
                      as String,
            gamesLost: null == gamesLost
                ? _value.gamesLost
                : gamesLost // ignore: cast_nullable_to_non_nullable
                      as int,
            gamesWon: null == gamesWon
                ? _value.gamesWon
                : gamesWon // ignore: cast_nullable_to_non_nullable
                      as int,
            gamesPlayed: null == gamesPlayed
                ? _value.gamesPlayed
                : gamesPlayed // ignore: cast_nullable_to_non_nullable
                      as int,
            winRate: null == winRate
                ? _value.winRate
                : winRate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NemesisRecordImplCopyWith<$Res>
    implements $NemesisRecordCopyWith<$Res> {
  factory _$$NemesisRecordImplCopyWith(
    _$NemesisRecordImpl value,
    $Res Function(_$NemesisRecordImpl) then,
  ) = __$$NemesisRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String opponentId,
    String opponentName,
    int gamesLost,
    int gamesWon,
    int gamesPlayed,
    double winRate,
  });
}

/// @nodoc
class __$$NemesisRecordImplCopyWithImpl<$Res>
    extends _$NemesisRecordCopyWithImpl<$Res, _$NemesisRecordImpl>
    implements _$$NemesisRecordImplCopyWith<$Res> {
  __$$NemesisRecordImplCopyWithImpl(
    _$NemesisRecordImpl _value,
    $Res Function(_$NemesisRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NemesisRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? opponentId = null,
    Object? opponentName = null,
    Object? gamesLost = null,
    Object? gamesWon = null,
    Object? gamesPlayed = null,
    Object? winRate = null,
  }) {
    return _then(
      _$NemesisRecordImpl(
        opponentId: null == opponentId
            ? _value.opponentId
            : opponentId // ignore: cast_nullable_to_non_nullable
                  as String,
        opponentName: null == opponentName
            ? _value.opponentName
            : opponentName // ignore: cast_nullable_to_non_nullable
                  as String,
        gamesLost: null == gamesLost
            ? _value.gamesLost
            : gamesLost // ignore: cast_nullable_to_non_nullable
                  as int,
        gamesWon: null == gamesWon
            ? _value.gamesWon
            : gamesWon // ignore: cast_nullable_to_non_nullable
                  as int,
        gamesPlayed: null == gamesPlayed
            ? _value.gamesPlayed
            : gamesPlayed // ignore: cast_nullable_to_non_nullable
                  as int,
        winRate: null == winRate
            ? _value.winRate
            : winRate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NemesisRecordImpl extends _NemesisRecord {
  const _$NemesisRecordImpl({
    required this.opponentId,
    required this.opponentName,
    required this.gamesLost,
    required this.gamesWon,
    required this.gamesPlayed,
    required this.winRate,
  }) : super._();

  factory _$NemesisRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$NemesisRecordImplFromJson(json);

  /// Opponent user ID
  @override
  final String opponentId;

  /// Opponent display name (cached for quick display)
  @override
  final String opponentName;

  /// Total games lost against this opponent
  @override
  final int gamesLost;

  /// Total games won against this opponent
  @override
  final int gamesWon;

  /// Total games played against this opponent (gamesWon + gamesLost)
  @override
  final int gamesPlayed;

  /// Win rate as percentage (0-100)
  @override
  final double winRate;

  @override
  String toString() {
    return 'NemesisRecord(opponentId: $opponentId, opponentName: $opponentName, gamesLost: $gamesLost, gamesWon: $gamesWon, gamesPlayed: $gamesPlayed, winRate: $winRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NemesisRecordImpl &&
            (identical(other.opponentId, opponentId) ||
                other.opponentId == opponentId) &&
            (identical(other.opponentName, opponentName) ||
                other.opponentName == opponentName) &&
            (identical(other.gamesLost, gamesLost) ||
                other.gamesLost == gamesLost) &&
            (identical(other.gamesWon, gamesWon) ||
                other.gamesWon == gamesWon) &&
            (identical(other.gamesPlayed, gamesPlayed) ||
                other.gamesPlayed == gamesPlayed) &&
            (identical(other.winRate, winRate) || other.winRate == winRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    opponentId,
    opponentName,
    gamesLost,
    gamesWon,
    gamesPlayed,
    winRate,
  );

  /// Create a copy of NemesisRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NemesisRecordImplCopyWith<_$NemesisRecordImpl> get copyWith =>
      __$$NemesisRecordImplCopyWithImpl<_$NemesisRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NemesisRecordImplToJson(this);
  }
}

abstract class _NemesisRecord extends NemesisRecord {
  const factory _NemesisRecord({
    required final String opponentId,
    required final String opponentName,
    required final int gamesLost,
    required final int gamesWon,
    required final int gamesPlayed,
    required final double winRate,
  }) = _$NemesisRecordImpl;
  const _NemesisRecord._() : super._();

  factory _NemesisRecord.fromJson(Map<String, dynamic> json) =
      _$NemesisRecordImpl.fromJson;

  /// Opponent user ID
  @override
  String get opponentId;

  /// Opponent display name (cached for quick display)
  @override
  String get opponentName;

  /// Total games lost against this opponent
  @override
  int get gamesLost;

  /// Total games won against this opponent
  @override
  int get gamesWon;

  /// Total games played against this opponent (gamesWon + gamesLost)
  @override
  int get gamesPlayed;

  /// Win rate as percentage (0-100)
  @override
  double get winRate;

  /// Create a copy of NemesisRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NemesisRecordImplCopyWith<_$NemesisRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BestWinRecord _$BestWinRecordFromJson(Map<String, dynamic> json) {
  return _BestWinRecord.fromJson(json);
}

/// @nodoc
mixin _$BestWinRecord {
  /// Game ID where this best win occurred
  String get gameId => throw _privateConstructorUsedError;

  /// Combined opponent team ELO at time of game
  double get opponentTeamElo => throw _privateConstructorUsedError;

  /// Average opponent team ELO at time of game
  double get opponentTeamAvgElo => throw _privateConstructorUsedError;

  /// ELO gained from this specific win
  double get eloGained => throw _privateConstructorUsedError;

  /// Date when this win occurred
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime get date => throw _privateConstructorUsedError;

  /// Game title or description for display
  String get gameTitle => throw _privateConstructorUsedError;

  /// Opponent team member names (cached for display, joined with " & ")
  /// Example: "Alice & Bob" or "John Doe & Jane Smith"
  /// Falls back to email if displayName is not available
  String? get opponentNames => throw _privateConstructorUsedError;

  /// Serializes this BestWinRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BestWinRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BestWinRecordCopyWith<BestWinRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BestWinRecordCopyWith<$Res> {
  factory $BestWinRecordCopyWith(
    BestWinRecord value,
    $Res Function(BestWinRecord) then,
  ) = _$BestWinRecordCopyWithImpl<$Res, BestWinRecord>;
  @useResult
  $Res call({
    String gameId,
    double opponentTeamElo,
    double opponentTeamAvgElo,
    double eloGained,
    @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson) DateTime date,
    String gameTitle,
    String? opponentNames,
  });
}

/// @nodoc
class _$BestWinRecordCopyWithImpl<$Res, $Val extends BestWinRecord>
    implements $BestWinRecordCopyWith<$Res> {
  _$BestWinRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BestWinRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? opponentTeamElo = null,
    Object? opponentTeamAvgElo = null,
    Object? eloGained = null,
    Object? date = null,
    Object? gameTitle = null,
    Object? opponentNames = freezed,
  }) {
    return _then(
      _value.copyWith(
            gameId: null == gameId
                ? _value.gameId
                : gameId // ignore: cast_nullable_to_non_nullable
                      as String,
            opponentTeamElo: null == opponentTeamElo
                ? _value.opponentTeamElo
                : opponentTeamElo // ignore: cast_nullable_to_non_nullable
                      as double,
            opponentTeamAvgElo: null == opponentTeamAvgElo
                ? _value.opponentTeamAvgElo
                : opponentTeamAvgElo // ignore: cast_nullable_to_non_nullable
                      as double,
            eloGained: null == eloGained
                ? _value.eloGained
                : eloGained // ignore: cast_nullable_to_non_nullable
                      as double,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            gameTitle: null == gameTitle
                ? _value.gameTitle
                : gameTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            opponentNames: freezed == opponentNames
                ? _value.opponentNames
                : opponentNames // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BestWinRecordImplCopyWith<$Res>
    implements $BestWinRecordCopyWith<$Res> {
  factory _$$BestWinRecordImplCopyWith(
    _$BestWinRecordImpl value,
    $Res Function(_$BestWinRecordImpl) then,
  ) = __$$BestWinRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String gameId,
    double opponentTeamElo,
    double opponentTeamAvgElo,
    double eloGained,
    @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson) DateTime date,
    String gameTitle,
    String? opponentNames,
  });
}

/// @nodoc
class __$$BestWinRecordImplCopyWithImpl<$Res>
    extends _$BestWinRecordCopyWithImpl<$Res, _$BestWinRecordImpl>
    implements _$$BestWinRecordImplCopyWith<$Res> {
  __$$BestWinRecordImplCopyWithImpl(
    _$BestWinRecordImpl _value,
    $Res Function(_$BestWinRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BestWinRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? gameId = null,
    Object? opponentTeamElo = null,
    Object? opponentTeamAvgElo = null,
    Object? eloGained = null,
    Object? date = null,
    Object? gameTitle = null,
    Object? opponentNames = freezed,
  }) {
    return _then(
      _$BestWinRecordImpl(
        gameId: null == gameId
            ? _value.gameId
            : gameId // ignore: cast_nullable_to_non_nullable
                  as String,
        opponentTeamElo: null == opponentTeamElo
            ? _value.opponentTeamElo
            : opponentTeamElo // ignore: cast_nullable_to_non_nullable
                  as double,
        opponentTeamAvgElo: null == opponentTeamAvgElo
            ? _value.opponentTeamAvgElo
            : opponentTeamAvgElo // ignore: cast_nullable_to_non_nullable
                  as double,
        eloGained: null == eloGained
            ? _value.eloGained
            : eloGained // ignore: cast_nullable_to_non_nullable
                  as double,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        gameTitle: null == gameTitle
            ? _value.gameTitle
            : gameTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        opponentNames: freezed == opponentNames
            ? _value.opponentNames
            : opponentNames // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BestWinRecordImpl extends _BestWinRecord {
  const _$BestWinRecordImpl({
    required this.gameId,
    required this.opponentTeamElo,
    required this.opponentTeamAvgElo,
    required this.eloGained,
    @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson) required this.date,
    required this.gameTitle,
    this.opponentNames,
  }) : super._();

  factory _$BestWinRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$BestWinRecordImplFromJson(json);

  /// Game ID where this best win occurred
  @override
  final String gameId;

  /// Combined opponent team ELO at time of game
  @override
  final double opponentTeamElo;

  /// Average opponent team ELO at time of game
  @override
  final double opponentTeamAvgElo;

  /// ELO gained from this specific win
  @override
  final double eloGained;

  /// Date when this win occurred
  @override
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime date;

  /// Game title or description for display
  @override
  final String gameTitle;

  /// Opponent team member names (cached for display, joined with " & ")
  /// Example: "Alice & Bob" or "John Doe & Jane Smith"
  /// Falls back to email if displayName is not available
  @override
  final String? opponentNames;

  @override
  String toString() {
    return 'BestWinRecord(gameId: $gameId, opponentTeamElo: $opponentTeamElo, opponentTeamAvgElo: $opponentTeamAvgElo, eloGained: $eloGained, date: $date, gameTitle: $gameTitle, opponentNames: $opponentNames)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BestWinRecordImpl &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.opponentTeamElo, opponentTeamElo) ||
                other.opponentTeamElo == opponentTeamElo) &&
            (identical(other.opponentTeamAvgElo, opponentTeamAvgElo) ||
                other.opponentTeamAvgElo == opponentTeamAvgElo) &&
            (identical(other.eloGained, eloGained) ||
                other.eloGained == eloGained) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.gameTitle, gameTitle) ||
                other.gameTitle == gameTitle) &&
            (identical(other.opponentNames, opponentNames) ||
                other.opponentNames == opponentNames));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    gameId,
    opponentTeamElo,
    opponentTeamAvgElo,
    eloGained,
    date,
    gameTitle,
    opponentNames,
  );

  /// Create a copy of BestWinRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BestWinRecordImplCopyWith<_$BestWinRecordImpl> get copyWith =>
      __$$BestWinRecordImplCopyWithImpl<_$BestWinRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BestWinRecordImplToJson(this);
  }
}

abstract class _BestWinRecord extends BestWinRecord {
  const factory _BestWinRecord({
    required final String gameId,
    required final double opponentTeamElo,
    required final double opponentTeamAvgElo,
    required final double eloGained,
    @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
    required final DateTime date,
    required final String gameTitle,
    final String? opponentNames,
  }) = _$BestWinRecordImpl;
  const _BestWinRecord._() : super._();

  factory _BestWinRecord.fromJson(Map<String, dynamic> json) =
      _$BestWinRecordImpl.fromJson;

  /// Game ID where this best win occurred
  @override
  String get gameId;

  /// Combined opponent team ELO at time of game
  @override
  double get opponentTeamElo;

  /// Average opponent team ELO at time of game
  @override
  double get opponentTeamAvgElo;

  /// ELO gained from this specific win
  @override
  double get eloGained;

  /// Date when this win occurred
  @override
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  DateTime get date;

  /// Game title or description for display
  @override
  String get gameTitle;

  /// Opponent team member names (cached for display, joined with " & ")
  /// Example: "Alice & Bob" or "John Doe & Jane Smith"
  /// Falls back to email if displayName is not available
  @override
  String? get opponentNames;

  /// Create a copy of BestWinRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BestWinRecordImplCopyWith<_$BestWinRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PointStats _$PointStatsFromJson(Map<String, dynamic> json) {
  return _PointStats.fromJson(json);
}

/// @nodoc
mixin _$PointStats {
  /// Sum of point differentials in winning sets (always positive)
  int get totalDiffInWinningSets => throw _privateConstructorUsedError;

  /// Number of sets won by player's team
  int get winningSetsCount => throw _privateConstructorUsedError;

  /// Sum of point differentials in losing sets (always negative)
  int get totalDiffInLosingSets => throw _privateConstructorUsedError;

  /// Number of sets lost by player's team
  int get losingSetsCount => throw _privateConstructorUsedError;

  /// Serializes this PointStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PointStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PointStatsCopyWith<PointStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PointStatsCopyWith<$Res> {
  factory $PointStatsCopyWith(
    PointStats value,
    $Res Function(PointStats) then,
  ) = _$PointStatsCopyWithImpl<$Res, PointStats>;
  @useResult
  $Res call({
    int totalDiffInWinningSets,
    int winningSetsCount,
    int totalDiffInLosingSets,
    int losingSetsCount,
  });
}

/// @nodoc
class _$PointStatsCopyWithImpl<$Res, $Val extends PointStats>
    implements $PointStatsCopyWith<$Res> {
  _$PointStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PointStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDiffInWinningSets = null,
    Object? winningSetsCount = null,
    Object? totalDiffInLosingSets = null,
    Object? losingSetsCount = null,
  }) {
    return _then(
      _value.copyWith(
            totalDiffInWinningSets: null == totalDiffInWinningSets
                ? _value.totalDiffInWinningSets
                : totalDiffInWinningSets // ignore: cast_nullable_to_non_nullable
                      as int,
            winningSetsCount: null == winningSetsCount
                ? _value.winningSetsCount
                : winningSetsCount // ignore: cast_nullable_to_non_nullable
                      as int,
            totalDiffInLosingSets: null == totalDiffInLosingSets
                ? _value.totalDiffInLosingSets
                : totalDiffInLosingSets // ignore: cast_nullable_to_non_nullable
                      as int,
            losingSetsCount: null == losingSetsCount
                ? _value.losingSetsCount
                : losingSetsCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PointStatsImplCopyWith<$Res>
    implements $PointStatsCopyWith<$Res> {
  factory _$$PointStatsImplCopyWith(
    _$PointStatsImpl value,
    $Res Function(_$PointStatsImpl) then,
  ) = __$$PointStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalDiffInWinningSets,
    int winningSetsCount,
    int totalDiffInLosingSets,
    int losingSetsCount,
  });
}

/// @nodoc
class __$$PointStatsImplCopyWithImpl<$Res>
    extends _$PointStatsCopyWithImpl<$Res, _$PointStatsImpl>
    implements _$$PointStatsImplCopyWith<$Res> {
  __$$PointStatsImplCopyWithImpl(
    _$PointStatsImpl _value,
    $Res Function(_$PointStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PointStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalDiffInWinningSets = null,
    Object? winningSetsCount = null,
    Object? totalDiffInLosingSets = null,
    Object? losingSetsCount = null,
  }) {
    return _then(
      _$PointStatsImpl(
        totalDiffInWinningSets: null == totalDiffInWinningSets
            ? _value.totalDiffInWinningSets
            : totalDiffInWinningSets // ignore: cast_nullable_to_non_nullable
                  as int,
        winningSetsCount: null == winningSetsCount
            ? _value.winningSetsCount
            : winningSetsCount // ignore: cast_nullable_to_non_nullable
                  as int,
        totalDiffInLosingSets: null == totalDiffInLosingSets
            ? _value.totalDiffInLosingSets
            : totalDiffInLosingSets // ignore: cast_nullable_to_non_nullable
                  as int,
        losingSetsCount: null == losingSetsCount
            ? _value.losingSetsCount
            : losingSetsCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PointStatsImpl extends _PointStats {
  const _$PointStatsImpl({
    this.totalDiffInWinningSets = 0,
    this.winningSetsCount = 0,
    this.totalDiffInLosingSets = 0,
    this.losingSetsCount = 0,
  }) : super._();

  factory _$PointStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PointStatsImplFromJson(json);

  /// Sum of point differentials in winning sets (always positive)
  @override
  @JsonKey()
  final int totalDiffInWinningSets;

  /// Number of sets won by player's team
  @override
  @JsonKey()
  final int winningSetsCount;

  /// Sum of point differentials in losing sets (always negative)
  @override
  @JsonKey()
  final int totalDiffInLosingSets;

  /// Number of sets lost by player's team
  @override
  @JsonKey()
  final int losingSetsCount;

  @override
  String toString() {
    return 'PointStats(totalDiffInWinningSets: $totalDiffInWinningSets, winningSetsCount: $winningSetsCount, totalDiffInLosingSets: $totalDiffInLosingSets, losingSetsCount: $losingSetsCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PointStatsImpl &&
            (identical(other.totalDiffInWinningSets, totalDiffInWinningSets) ||
                other.totalDiffInWinningSets == totalDiffInWinningSets) &&
            (identical(other.winningSetsCount, winningSetsCount) ||
                other.winningSetsCount == winningSetsCount) &&
            (identical(other.totalDiffInLosingSets, totalDiffInLosingSets) ||
                other.totalDiffInLosingSets == totalDiffInLosingSets) &&
            (identical(other.losingSetsCount, losingSetsCount) ||
                other.losingSetsCount == losingSetsCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalDiffInWinningSets,
    winningSetsCount,
    totalDiffInLosingSets,
    losingSetsCount,
  );

  /// Create a copy of PointStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PointStatsImplCopyWith<_$PointStatsImpl> get copyWith =>
      __$$PointStatsImplCopyWithImpl<_$PointStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PointStatsImplToJson(this);
  }
}

abstract class _PointStats extends PointStats {
  const factory _PointStats({
    final int totalDiffInWinningSets,
    final int winningSetsCount,
    final int totalDiffInLosingSets,
    final int losingSetsCount,
  }) = _$PointStatsImpl;
  const _PointStats._() : super._();

  factory _PointStats.fromJson(Map<String, dynamic> json) =
      _$PointStatsImpl.fromJson;

  /// Sum of point differentials in winning sets (always positive)
  @override
  int get totalDiffInWinningSets;

  /// Number of sets won by player's team
  @override
  int get winningSetsCount;

  /// Sum of point differentials in losing sets (always negative)
  @override
  int get totalDiffInLosingSets;

  /// Number of sets lost by player's team
  @override
  int get losingSetsCount;

  /// Create a copy of PointStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PointStatsImplCopyWith<_$PointStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RoleStats _$RoleStatsFromJson(Map<String, dynamic> json) {
  return _RoleStats.fromJson(json);
}

/// @nodoc
mixin _$RoleStats {
  /// Number of games played in this role
  int get games => throw _privateConstructorUsedError;

  /// Number of games won in this role
  int get wins => throw _privateConstructorUsedError;

  /// Win rate as decimal (0.0 - 1.0)
  double get winRate => throw _privateConstructorUsedError;

  /// Serializes this RoleStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoleStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoleStatsCopyWith<RoleStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoleStatsCopyWith<$Res> {
  factory $RoleStatsCopyWith(RoleStats value, $Res Function(RoleStats) then) =
      _$RoleStatsCopyWithImpl<$Res, RoleStats>;
  @useResult
  $Res call({int games, int wins, double winRate});
}

/// @nodoc
class _$RoleStatsCopyWithImpl<$Res, $Val extends RoleStats>
    implements $RoleStatsCopyWith<$Res> {
  _$RoleStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoleStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? games = null,
    Object? wins = null,
    Object? winRate = null,
  }) {
    return _then(
      _value.copyWith(
            games: null == games
                ? _value.games
                : games // ignore: cast_nullable_to_non_nullable
                      as int,
            wins: null == wins
                ? _value.wins
                : wins // ignore: cast_nullable_to_non_nullable
                      as int,
            winRate: null == winRate
                ? _value.winRate
                : winRate // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RoleStatsImplCopyWith<$Res>
    implements $RoleStatsCopyWith<$Res> {
  factory _$$RoleStatsImplCopyWith(
    _$RoleStatsImpl value,
    $Res Function(_$RoleStatsImpl) then,
  ) = __$$RoleStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int games, int wins, double winRate});
}

/// @nodoc
class __$$RoleStatsImplCopyWithImpl<$Res>
    extends _$RoleStatsCopyWithImpl<$Res, _$RoleStatsImpl>
    implements _$$RoleStatsImplCopyWith<$Res> {
  __$$RoleStatsImplCopyWithImpl(
    _$RoleStatsImpl _value,
    $Res Function(_$RoleStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RoleStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? games = null,
    Object? wins = null,
    Object? winRate = null,
  }) {
    return _then(
      _$RoleStatsImpl(
        games: null == games
            ? _value.games
            : games // ignore: cast_nullable_to_non_nullable
                  as int,
        wins: null == wins
            ? _value.wins
            : wins // ignore: cast_nullable_to_non_nullable
                  as int,
        winRate: null == winRate
            ? _value.winRate
            : winRate // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RoleStatsImpl extends _RoleStats {
  const _$RoleStatsImpl({this.games = 0, this.wins = 0, this.winRate = 0.0})
    : super._();

  factory _$RoleStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoleStatsImplFromJson(json);

  /// Number of games played in this role
  @override
  @JsonKey()
  final int games;

  /// Number of games won in this role
  @override
  @JsonKey()
  final int wins;

  /// Win rate as decimal (0.0 - 1.0)
  @override
  @JsonKey()
  final double winRate;

  @override
  String toString() {
    return 'RoleStats(games: $games, wins: $wins, winRate: $winRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoleStatsImpl &&
            (identical(other.games, games) || other.games == games) &&
            (identical(other.wins, wins) || other.wins == wins) &&
            (identical(other.winRate, winRate) || other.winRate == winRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, games, wins, winRate);

  /// Create a copy of RoleStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoleStatsImplCopyWith<_$RoleStatsImpl> get copyWith =>
      __$$RoleStatsImplCopyWithImpl<_$RoleStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoleStatsImplToJson(this);
  }
}

abstract class _RoleStats extends RoleStats {
  const factory _RoleStats({
    final int games,
    final int wins,
    final double winRate,
  }) = _$RoleStatsImpl;
  const _RoleStats._() : super._();

  factory _RoleStats.fromJson(Map<String, dynamic> json) =
      _$RoleStatsImpl.fromJson;

  /// Number of games played in this role
  @override
  int get games;

  /// Number of games won in this role
  @override
  int get wins;

  /// Win rate as decimal (0.0 - 1.0)
  @override
  double get winRate;

  /// Create a copy of RoleStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoleStatsImplCopyWith<_$RoleStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RoleBasedStats _$RoleBasedStatsFromJson(Map<String, dynamic> json) {
  return _RoleBasedStats.fromJson(json);
}

/// @nodoc
mixin _$RoleBasedStats {
  /// Stats when player is lowest ELO on their team (playing with stronger teammates)
  RoleStats get weakLink => throw _privateConstructorUsedError;

  /// Stats when player is highest ELO on their team (leading/carrying the team)
  RoleStats get carry => throw _privateConstructorUsedError;

  /// Stats when player is middle ELO or tied (balanced team composition)
  RoleStats get balanced => throw _privateConstructorUsedError;

  /// Serializes this RoleBasedStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoleBasedStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoleBasedStatsCopyWith<RoleBasedStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoleBasedStatsCopyWith<$Res> {
  factory $RoleBasedStatsCopyWith(
    RoleBasedStats value,
    $Res Function(RoleBasedStats) then,
  ) = _$RoleBasedStatsCopyWithImpl<$Res, RoleBasedStats>;
  @useResult
  $Res call({RoleStats weakLink, RoleStats carry, RoleStats balanced});

  $RoleStatsCopyWith<$Res> get weakLink;
  $RoleStatsCopyWith<$Res> get carry;
  $RoleStatsCopyWith<$Res> get balanced;
}

/// @nodoc
class _$RoleBasedStatsCopyWithImpl<$Res, $Val extends RoleBasedStats>
    implements $RoleBasedStatsCopyWith<$Res> {
  _$RoleBasedStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoleBasedStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weakLink = null,
    Object? carry = null,
    Object? balanced = null,
  }) {
    return _then(
      _value.copyWith(
            weakLink: null == weakLink
                ? _value.weakLink
                : weakLink // ignore: cast_nullable_to_non_nullable
                      as RoleStats,
            carry: null == carry
                ? _value.carry
                : carry // ignore: cast_nullable_to_non_nullable
                      as RoleStats,
            balanced: null == balanced
                ? _value.balanced
                : balanced // ignore: cast_nullable_to_non_nullable
                      as RoleStats,
          )
          as $Val,
    );
  }

  /// Create a copy of RoleBasedStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RoleStatsCopyWith<$Res> get weakLink {
    return $RoleStatsCopyWith<$Res>(_value.weakLink, (value) {
      return _then(_value.copyWith(weakLink: value) as $Val);
    });
  }

  /// Create a copy of RoleBasedStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RoleStatsCopyWith<$Res> get carry {
    return $RoleStatsCopyWith<$Res>(_value.carry, (value) {
      return _then(_value.copyWith(carry: value) as $Val);
    });
  }

  /// Create a copy of RoleBasedStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RoleStatsCopyWith<$Res> get balanced {
    return $RoleStatsCopyWith<$Res>(_value.balanced, (value) {
      return _then(_value.copyWith(balanced: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RoleBasedStatsImplCopyWith<$Res>
    implements $RoleBasedStatsCopyWith<$Res> {
  factory _$$RoleBasedStatsImplCopyWith(
    _$RoleBasedStatsImpl value,
    $Res Function(_$RoleBasedStatsImpl) then,
  ) = __$$RoleBasedStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({RoleStats weakLink, RoleStats carry, RoleStats balanced});

  @override
  $RoleStatsCopyWith<$Res> get weakLink;
  @override
  $RoleStatsCopyWith<$Res> get carry;
  @override
  $RoleStatsCopyWith<$Res> get balanced;
}

/// @nodoc
class __$$RoleBasedStatsImplCopyWithImpl<$Res>
    extends _$RoleBasedStatsCopyWithImpl<$Res, _$RoleBasedStatsImpl>
    implements _$$RoleBasedStatsImplCopyWith<$Res> {
  __$$RoleBasedStatsImplCopyWithImpl(
    _$RoleBasedStatsImpl _value,
    $Res Function(_$RoleBasedStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RoleBasedStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weakLink = null,
    Object? carry = null,
    Object? balanced = null,
  }) {
    return _then(
      _$RoleBasedStatsImpl(
        weakLink: null == weakLink
            ? _value.weakLink
            : weakLink // ignore: cast_nullable_to_non_nullable
                  as RoleStats,
        carry: null == carry
            ? _value.carry
            : carry // ignore: cast_nullable_to_non_nullable
                  as RoleStats,
        balanced: null == balanced
            ? _value.balanced
            : balanced // ignore: cast_nullable_to_non_nullable
                  as RoleStats,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RoleBasedStatsImpl extends _RoleBasedStats {
  const _$RoleBasedStatsImpl({
    this.weakLink = const RoleStats(),
    this.carry = const RoleStats(),
    this.balanced = const RoleStats(),
  }) : super._();

  factory _$RoleBasedStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoleBasedStatsImplFromJson(json);

  /// Stats when player is lowest ELO on their team (playing with stronger teammates)
  @override
  @JsonKey()
  final RoleStats weakLink;

  /// Stats when player is highest ELO on their team (leading/carrying the team)
  @override
  @JsonKey()
  final RoleStats carry;

  /// Stats when player is middle ELO or tied (balanced team composition)
  @override
  @JsonKey()
  final RoleStats balanced;

  @override
  String toString() {
    return 'RoleBasedStats(weakLink: $weakLink, carry: $carry, balanced: $balanced)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoleBasedStatsImpl &&
            (identical(other.weakLink, weakLink) ||
                other.weakLink == weakLink) &&
            (identical(other.carry, carry) || other.carry == carry) &&
            (identical(other.balanced, balanced) ||
                other.balanced == balanced));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, weakLink, carry, balanced);

  /// Create a copy of RoleBasedStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoleBasedStatsImplCopyWith<_$RoleBasedStatsImpl> get copyWith =>
      __$$RoleBasedStatsImplCopyWithImpl<_$RoleBasedStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RoleBasedStatsImplToJson(this);
  }
}

abstract class _RoleBasedStats extends RoleBasedStats {
  const factory _RoleBasedStats({
    final RoleStats weakLink,
    final RoleStats carry,
    final RoleStats balanced,
  }) = _$RoleBasedStatsImpl;
  const _RoleBasedStats._() : super._();

  factory _RoleBasedStats.fromJson(Map<String, dynamic> json) =
      _$RoleBasedStatsImpl.fromJson;

  /// Stats when player is lowest ELO on their team (playing with stronger teammates)
  @override
  RoleStats get weakLink;

  /// Stats when player is highest ELO on their team (leading/carrying the team)
  @override
  RoleStats get carry;

  /// Stats when player is middle ELO or tied (balanced team composition)
  @override
  RoleStats get balanced;

  /// Create a copy of RoleBasedStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoleBasedStatsImplCopyWith<_$RoleBasedStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
