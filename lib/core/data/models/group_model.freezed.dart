// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GroupModel _$GroupModelFromJson(Map<String, dynamic> json) {
  return _GroupModel.fromJson(json);
}

/// @nodoc
mixin _$GroupModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  List<String> get memberIds => throw _privateConstructorUsedError;
  List<String> get adminIds => throw _privateConstructorUsedError;
  List<String> get gameIds => throw _privateConstructorUsedError;
  GroupPrivacy get privacy => throw _privateConstructorUsedError;
  bool get requiresApproval => throw _privateConstructorUsedError;
  int get maxMembers => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError; // Group settings
  bool get allowMembersToCreateGames => throw _privateConstructorUsedError;
  bool get allowMembersToInviteOthers => throw _privateConstructorUsedError;
  bool get notifyMembersOfNewGames =>
      throw _privateConstructorUsedError; // Group stats
  int get totalGamesPlayed => throw _privateConstructorUsedError;
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  DateTime? get lastActivity => throw _privateConstructorUsedError;

  /// Serializes this GroupModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupModelCopyWith<GroupModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupModelCopyWith<$Res> {
  factory $GroupModelCopyWith(
    GroupModel value,
    $Res Function(GroupModel) then,
  ) = _$GroupModelCopyWithImpl<$Res, GroupModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    String? photoUrl,
    String createdBy,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime createdAt,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    DateTime? updatedAt,
    List<String> memberIds,
    List<String> adminIds,
    List<String> gameIds,
    GroupPrivacy privacy,
    bool requiresApproval,
    int maxMembers,
    String? location,
    bool allowMembersToCreateGames,
    bool allowMembersToInviteOthers,
    bool notifyMembersOfNewGames,
    int totalGamesPlayed,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    DateTime? lastActivity,
  });
}

/// @nodoc
class _$GroupModelCopyWithImpl<$Res, $Val extends GroupModel>
    implements $GroupModelCopyWith<$Res> {
  _$GroupModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? photoUrl = freezed,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? memberIds = null,
    Object? adminIds = null,
    Object? gameIds = null,
    Object? privacy = null,
    Object? requiresApproval = null,
    Object? maxMembers = null,
    Object? location = freezed,
    Object? allowMembersToCreateGames = null,
    Object? allowMembersToInviteOthers = null,
    Object? notifyMembersOfNewGames = null,
    Object? totalGamesPlayed = null,
    Object? lastActivity = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            memberIds: null == memberIds
                ? _value.memberIds
                : memberIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            adminIds: null == adminIds
                ? _value.adminIds
                : adminIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            gameIds: null == gameIds
                ? _value.gameIds
                : gameIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            privacy: null == privacy
                ? _value.privacy
                : privacy // ignore: cast_nullable_to_non_nullable
                      as GroupPrivacy,
            requiresApproval: null == requiresApproval
                ? _value.requiresApproval
                : requiresApproval // ignore: cast_nullable_to_non_nullable
                      as bool,
            maxMembers: null == maxMembers
                ? _value.maxMembers
                : maxMembers // ignore: cast_nullable_to_non_nullable
                      as int,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            allowMembersToCreateGames: null == allowMembersToCreateGames
                ? _value.allowMembersToCreateGames
                : allowMembersToCreateGames // ignore: cast_nullable_to_non_nullable
                      as bool,
            allowMembersToInviteOthers: null == allowMembersToInviteOthers
                ? _value.allowMembersToInviteOthers
                : allowMembersToInviteOthers // ignore: cast_nullable_to_non_nullable
                      as bool,
            notifyMembersOfNewGames: null == notifyMembersOfNewGames
                ? _value.notifyMembersOfNewGames
                : notifyMembersOfNewGames // ignore: cast_nullable_to_non_nullable
                      as bool,
            totalGamesPlayed: null == totalGamesPlayed
                ? _value.totalGamesPlayed
                : totalGamesPlayed // ignore: cast_nullable_to_non_nullable
                      as int,
            lastActivity: freezed == lastActivity
                ? _value.lastActivity
                : lastActivity // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GroupModelImplCopyWith<$Res>
    implements $GroupModelCopyWith<$Res> {
  factory _$$GroupModelImplCopyWith(
    _$GroupModelImpl value,
    $Res Function(_$GroupModelImpl) then,
  ) = __$$GroupModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? description,
    String? photoUrl,
    String createdBy,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    DateTime createdAt,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    DateTime? updatedAt,
    List<String> memberIds,
    List<String> adminIds,
    List<String> gameIds,
    GroupPrivacy privacy,
    bool requiresApproval,
    int maxMembers,
    String? location,
    bool allowMembersToCreateGames,
    bool allowMembersToInviteOthers,
    bool notifyMembersOfNewGames,
    int totalGamesPlayed,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    DateTime? lastActivity,
  });
}

/// @nodoc
class __$$GroupModelImplCopyWithImpl<$Res>
    extends _$GroupModelCopyWithImpl<$Res, _$GroupModelImpl>
    implements _$$GroupModelImplCopyWith<$Res> {
  __$$GroupModelImplCopyWithImpl(
    _$GroupModelImpl _value,
    $Res Function(_$GroupModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? photoUrl = freezed,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? memberIds = null,
    Object? adminIds = null,
    Object? gameIds = null,
    Object? privacy = null,
    Object? requiresApproval = null,
    Object? maxMembers = null,
    Object? location = freezed,
    Object? allowMembersToCreateGames = null,
    Object? allowMembersToInviteOthers = null,
    Object? notifyMembersOfNewGames = null,
    Object? totalGamesPlayed = null,
    Object? lastActivity = freezed,
  }) {
    return _then(
      _$GroupModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        memberIds: null == memberIds
            ? _value._memberIds
            : memberIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        adminIds: null == adminIds
            ? _value._adminIds
            : adminIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        gameIds: null == gameIds
            ? _value._gameIds
            : gameIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        privacy: null == privacy
            ? _value.privacy
            : privacy // ignore: cast_nullable_to_non_nullable
                  as GroupPrivacy,
        requiresApproval: null == requiresApproval
            ? _value.requiresApproval
            : requiresApproval // ignore: cast_nullable_to_non_nullable
                  as bool,
        maxMembers: null == maxMembers
            ? _value.maxMembers
            : maxMembers // ignore: cast_nullable_to_non_nullable
                  as int,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        allowMembersToCreateGames: null == allowMembersToCreateGames
            ? _value.allowMembersToCreateGames
            : allowMembersToCreateGames // ignore: cast_nullable_to_non_nullable
                  as bool,
        allowMembersToInviteOthers: null == allowMembersToInviteOthers
            ? _value.allowMembersToInviteOthers
            : allowMembersToInviteOthers // ignore: cast_nullable_to_non_nullable
                  as bool,
        notifyMembersOfNewGames: null == notifyMembersOfNewGames
            ? _value.notifyMembersOfNewGames
            : notifyMembersOfNewGames // ignore: cast_nullable_to_non_nullable
                  as bool,
        totalGamesPlayed: null == totalGamesPlayed
            ? _value.totalGamesPlayed
            : totalGamesPlayed // ignore: cast_nullable_to_non_nullable
                  as int,
        lastActivity: freezed == lastActivity
            ? _value.lastActivity
            : lastActivity // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupModelImpl extends _GroupModel {
  const _$GroupModelImpl({
    required this.id,
    required this.name,
    this.description,
    this.photoUrl,
    required this.createdBy,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required this.createdAt,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    this.updatedAt,
    final List<String> memberIds = const [],
    final List<String> adminIds = const [],
    final List<String> gameIds = const [],
    this.privacy = GroupPrivacy.private,
    this.requiresApproval = false,
    this.maxMembers = 20,
    this.location,
    this.allowMembersToCreateGames = true,
    this.allowMembersToInviteOthers = true,
    this.notifyMembersOfNewGames = true,
    this.totalGamesPlayed = 0,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    this.lastActivity,
  }) : _memberIds = memberIds,
       _adminIds = adminIds,
       _gameIds = gameIds,
       super._();

  factory _$GroupModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? photoUrl;
  @override
  final String createdBy;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  final DateTime createdAt;
  @override
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  final DateTime? updatedAt;
  final List<String> _memberIds;
  @override
  @JsonKey()
  List<String> get memberIds {
    if (_memberIds is EqualUnmodifiableListView) return _memberIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_memberIds);
  }

  final List<String> _adminIds;
  @override
  @JsonKey()
  List<String> get adminIds {
    if (_adminIds is EqualUnmodifiableListView) return _adminIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_adminIds);
  }

  final List<String> _gameIds;
  @override
  @JsonKey()
  List<String> get gameIds {
    if (_gameIds is EqualUnmodifiableListView) return _gameIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gameIds);
  }

  @override
  @JsonKey()
  final GroupPrivacy privacy;
  @override
  @JsonKey()
  final bool requiresApproval;
  @override
  @JsonKey()
  final int maxMembers;
  @override
  final String? location;
  // Group settings
  @override
  @JsonKey()
  final bool allowMembersToCreateGames;
  @override
  @JsonKey()
  final bool allowMembersToInviteOthers;
  @override
  @JsonKey()
  final bool notifyMembersOfNewGames;
  // Group stats
  @override
  @JsonKey()
  final int totalGamesPlayed;
  @override
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  final DateTime? lastActivity;

  @override
  String toString() {
    return 'GroupModel(id: $id, name: $name, description: $description, photoUrl: $photoUrl, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, memberIds: $memberIds, adminIds: $adminIds, gameIds: $gameIds, privacy: $privacy, requiresApproval: $requiresApproval, maxMembers: $maxMembers, location: $location, allowMembersToCreateGames: $allowMembersToCreateGames, allowMembersToInviteOthers: $allowMembersToInviteOthers, notifyMembersOfNewGames: $notifyMembersOfNewGames, totalGamesPlayed: $totalGamesPlayed, lastActivity: $lastActivity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(
              other._memberIds,
              _memberIds,
            ) &&
            const DeepCollectionEquality().equals(other._adminIds, _adminIds) &&
            const DeepCollectionEquality().equals(other._gameIds, _gameIds) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.requiresApproval, requiresApproval) ||
                other.requiresApproval == requiresApproval) &&
            (identical(other.maxMembers, maxMembers) ||
                other.maxMembers == maxMembers) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(
                  other.allowMembersToCreateGames,
                  allowMembersToCreateGames,
                ) ||
                other.allowMembersToCreateGames == allowMembersToCreateGames) &&
            (identical(
                  other.allowMembersToInviteOthers,
                  allowMembersToInviteOthers,
                ) ||
                other.allowMembersToInviteOthers ==
                    allowMembersToInviteOthers) &&
            (identical(
                  other.notifyMembersOfNewGames,
                  notifyMembersOfNewGames,
                ) ||
                other.notifyMembersOfNewGames == notifyMembersOfNewGames) &&
            (identical(other.totalGamesPlayed, totalGamesPlayed) ||
                other.totalGamesPlayed == totalGamesPlayed) &&
            (identical(other.lastActivity, lastActivity) ||
                other.lastActivity == lastActivity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    description,
    photoUrl,
    createdBy,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_memberIds),
    const DeepCollectionEquality().hash(_adminIds),
    const DeepCollectionEquality().hash(_gameIds),
    privacy,
    requiresApproval,
    maxMembers,
    location,
    allowMembersToCreateGames,
    allowMembersToInviteOthers,
    notifyMembersOfNewGames,
    totalGamesPlayed,
    lastActivity,
  ]);

  /// Create a copy of GroupModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupModelImplCopyWith<_$GroupModelImpl> get copyWith =>
      __$$GroupModelImplCopyWithImpl<_$GroupModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupModelImplToJson(this);
  }
}

abstract class _GroupModel extends GroupModel {
  const factory _GroupModel({
    required final String id,
    required final String name,
    final String? description,
    final String? photoUrl,
    required final String createdBy,
    @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
    required final DateTime createdAt,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    final DateTime? updatedAt,
    final List<String> memberIds,
    final List<String> adminIds,
    final List<String> gameIds,
    final GroupPrivacy privacy,
    final bool requiresApproval,
    final int maxMembers,
    final String? location,
    final bool allowMembersToCreateGames,
    final bool allowMembersToInviteOthers,
    final bool notifyMembersOfNewGames,
    final int totalGamesPlayed,
    @JsonKey(
      fromJson: _timestampFromJsonNullable,
      toJson: _timestampToJsonNullable,
    )
    final DateTime? lastActivity,
  }) = _$GroupModelImpl;
  const _GroupModel._() : super._();

  factory _GroupModel.fromJson(Map<String, dynamic> json) =
      _$GroupModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get photoUrl;
  @override
  String get createdBy;
  @override
  @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)
  DateTime get createdAt;
  @override
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  DateTime? get updatedAt;
  @override
  List<String> get memberIds;
  @override
  List<String> get adminIds;
  @override
  List<String> get gameIds;
  @override
  GroupPrivacy get privacy;
  @override
  bool get requiresApproval;
  @override
  int get maxMembers;
  @override
  String? get location; // Group settings
  @override
  bool get allowMembersToCreateGames;
  @override
  bool get allowMembersToInviteOthers;
  @override
  bool get notifyMembersOfNewGames; // Group stats
  @override
  int get totalGamesPlayed;
  @override
  @JsonKey(
    fromJson: _timestampFromJsonNullable,
    toJson: _timestampToJsonNullable,
  )
  DateTime? get lastActivity;

  /// Create a copy of GroupModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupModelImplCopyWith<_$GroupModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
