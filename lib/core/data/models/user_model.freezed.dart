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
      throw _privateConstructorUsedError; // User preferences
  bool get notificationsEnabled => throw _privateConstructorUsedError;
  bool get emailNotifications => throw _privateConstructorUsedError;
  bool get pushNotifications =>
      throw _privateConstructorUsedError; // Privacy settings
  UserPrivacyLevel get privacyLevel => throw _privateConstructorUsedError;
  bool get showEmail => throw _privateConstructorUsedError;
  bool get showPhoneNumber => throw _privateConstructorUsedError; // Stats
  int get gamesPlayed => throw _privateConstructorUsedError;
  int get gamesWon => throw _privateConstructorUsedError;
  int get totalScore => throw _privateConstructorUsedError;

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
    bool notificationsEnabled,
    bool emailNotifications,
    bool pushNotifications,
    UserPrivacyLevel privacyLevel,
    bool showEmail,
    bool showPhoneNumber,
    int gamesPlayed,
    int gamesWon,
    int totalScore,
  });
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
    Object? notificationsEnabled = null,
    Object? emailNotifications = null,
    Object? pushNotifications = null,
    Object? privacyLevel = null,
    Object? showEmail = null,
    Object? showPhoneNumber = null,
    Object? gamesPlayed = null,
    Object? gamesWon = null,
    Object? totalScore = null,
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
            totalScore: null == totalScore
                ? _value.totalScore
                : totalScore // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
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
    bool notificationsEnabled,
    bool emailNotifications,
    bool pushNotifications,
    UserPrivacyLevel privacyLevel,
    bool showEmail,
    bool showPhoneNumber,
    int gamesPlayed,
    int gamesWon,
    int totalScore,
  });
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
    Object? notificationsEnabled = null,
    Object? emailNotifications = null,
    Object? pushNotifications = null,
    Object? privacyLevel = null,
    Object? showEmail = null,
    Object? showPhoneNumber = null,
    Object? gamesPlayed = null,
    Object? gamesWon = null,
    Object? totalScore = null,
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
        totalScore: null == totalScore
            ? _value.totalScore
            : totalScore // ignore: cast_nullable_to_non_nullable
                  as int,
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
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.privacyLevel = UserPrivacyLevel.public,
    this.showEmail = true,
    this.showPhoneNumber = true,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.totalScore = 0,
  }) : _groupIds = groupIds,
       _gameIds = gameIds,
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
  final int totalScore;

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, isEmailVerified: $isEmailVerified, createdAt: $createdAt, lastSignInAt: $lastSignInAt, updatedAt: $updatedAt, isAnonymous: $isAnonymous, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, dateOfBirth: $dateOfBirth, location: $location, bio: $bio, groupIds: $groupIds, gameIds: $gameIds, notificationsEnabled: $notificationsEnabled, emailNotifications: $emailNotifications, pushNotifications: $pushNotifications, privacyLevel: $privacyLevel, showEmail: $showEmail, showPhoneNumber: $showPhoneNumber, gamesPlayed: $gamesPlayed, gamesWon: $gamesWon, totalScore: $totalScore)';
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
            (identical(other.totalScore, totalScore) ||
                other.totalScore == totalScore));
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
    notificationsEnabled,
    emailNotifications,
    pushNotifications,
    privacyLevel,
    showEmail,
    showPhoneNumber,
    gamesPlayed,
    gamesWon,
    totalScore,
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
    final bool notificationsEnabled,
    final bool emailNotifications,
    final bool pushNotifications,
    final UserPrivacyLevel privacyLevel,
    final bool showEmail,
    final bool showPhoneNumber,
    final int gamesPlayed,
    final int gamesWon,
    final int totalScore,
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
  List<String> get gameIds; // User preferences
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
  int get totalScore;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
