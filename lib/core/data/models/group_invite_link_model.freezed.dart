// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_invite_link_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GroupInviteLinkModel _$GroupInviteLinkModelFromJson(Map<String, dynamic> json) {
  return _GroupInviteLinkModel.fromJson(json);
}

/// @nodoc
mixin _$GroupInviteLinkModel {
  String get id => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  @RequiredTimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get expiresAt => throw _privateConstructorUsedError;
  bool get revoked => throw _privateConstructorUsedError;
  int? get usageLimit => throw _privateConstructorUsedError;
  int get usageCount => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String get inviteType => throw _privateConstructorUsedError;

  /// Serializes this GroupInviteLinkModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupInviteLinkModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupInviteLinkModelCopyWith<GroupInviteLinkModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupInviteLinkModelCopyWith<$Res> {
  factory $GroupInviteLinkModelCopyWith(
    GroupInviteLinkModel value,
    $Res Function(GroupInviteLinkModel) then,
  ) = _$GroupInviteLinkModelCopyWithImpl<$Res, GroupInviteLinkModel>;
  @useResult
  $Res call({
    String id,
    String token,
    String createdBy,
    @RequiredTimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime? expiresAt,
    bool revoked,
    int? usageLimit,
    int usageCount,
    String groupId,
    String inviteType,
  });
}

/// @nodoc
class _$GroupInviteLinkModelCopyWithImpl<
  $Res,
  $Val extends GroupInviteLinkModel
>
    implements $GroupInviteLinkModelCopyWith<$Res> {
  _$GroupInviteLinkModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupInviteLinkModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? token = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? expiresAt = freezed,
    Object? revoked = null,
    Object? usageLimit = freezed,
    Object? usageCount = null,
    Object? groupId = null,
    Object? inviteType = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            token: null == token
                ? _value.token
                : token // ignore: cast_nullable_to_non_nullable
                      as String,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            revoked: null == revoked
                ? _value.revoked
                : revoked // ignore: cast_nullable_to_non_nullable
                      as bool,
            usageLimit: freezed == usageLimit
                ? _value.usageLimit
                : usageLimit // ignore: cast_nullable_to_non_nullable
                      as int?,
            usageCount: null == usageCount
                ? _value.usageCount
                : usageCount // ignore: cast_nullable_to_non_nullable
                      as int,
            groupId: null == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                      as String,
            inviteType: null == inviteType
                ? _value.inviteType
                : inviteType // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GroupInviteLinkModelImplCopyWith<$Res>
    implements $GroupInviteLinkModelCopyWith<$Res> {
  factory _$$GroupInviteLinkModelImplCopyWith(
    _$GroupInviteLinkModelImpl value,
    $Res Function(_$GroupInviteLinkModelImpl) then,
  ) = __$$GroupInviteLinkModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String token,
    String createdBy,
    @RequiredTimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime? expiresAt,
    bool revoked,
    int? usageLimit,
    int usageCount,
    String groupId,
    String inviteType,
  });
}

/// @nodoc
class __$$GroupInviteLinkModelImplCopyWithImpl<$Res>
    extends _$GroupInviteLinkModelCopyWithImpl<$Res, _$GroupInviteLinkModelImpl>
    implements _$$GroupInviteLinkModelImplCopyWith<$Res> {
  __$$GroupInviteLinkModelImplCopyWithImpl(
    _$GroupInviteLinkModelImpl _value,
    $Res Function(_$GroupInviteLinkModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupInviteLinkModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? token = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? expiresAt = freezed,
    Object? revoked = null,
    Object? usageLimit = freezed,
    Object? usageCount = null,
    Object? groupId = null,
    Object? inviteType = null,
  }) {
    return _then(
      _$GroupInviteLinkModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        token: null == token
            ? _value.token
            : token // ignore: cast_nullable_to_non_nullable
                  as String,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        revoked: null == revoked
            ? _value.revoked
            : revoked // ignore: cast_nullable_to_non_nullable
                  as bool,
        usageLimit: freezed == usageLimit
            ? _value.usageLimit
            : usageLimit // ignore: cast_nullable_to_non_nullable
                  as int?,
        usageCount: null == usageCount
            ? _value.usageCount
            : usageCount // ignore: cast_nullable_to_non_nullable
                  as int,
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String,
        inviteType: null == inviteType
            ? _value.inviteType
            : inviteType // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupInviteLinkModelImpl extends _GroupInviteLinkModel {
  const _$GroupInviteLinkModelImpl({
    required this.id,
    required this.token,
    required this.createdBy,
    @RequiredTimestampConverter() required this.createdAt,
    @TimestampConverter() this.expiresAt,
    this.revoked = false,
    this.usageLimit,
    this.usageCount = 0,
    required this.groupId,
    this.inviteType = 'group_link',
  }) : super._();

  factory _$GroupInviteLinkModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupInviteLinkModelImplFromJson(json);

  @override
  final String id;
  @override
  final String token;
  @override
  final String createdBy;
  @override
  @RequiredTimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime? expiresAt;
  @override
  @JsonKey()
  final bool revoked;
  @override
  final int? usageLimit;
  @override
  @JsonKey()
  final int usageCount;
  @override
  final String groupId;
  @override
  @JsonKey()
  final String inviteType;

  @override
  String toString() {
    return 'GroupInviteLinkModel(id: $id, token: $token, createdBy: $createdBy, createdAt: $createdAt, expiresAt: $expiresAt, revoked: $revoked, usageLimit: $usageLimit, usageCount: $usageCount, groupId: $groupId, inviteType: $inviteType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupInviteLinkModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.revoked, revoked) || other.revoked == revoked) &&
            (identical(other.usageLimit, usageLimit) ||
                other.usageLimit == usageLimit) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.inviteType, inviteType) ||
                other.inviteType == inviteType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    token,
    createdBy,
    createdAt,
    expiresAt,
    revoked,
    usageLimit,
    usageCount,
    groupId,
    inviteType,
  );

  /// Create a copy of GroupInviteLinkModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupInviteLinkModelImplCopyWith<_$GroupInviteLinkModelImpl>
  get copyWith =>
      __$$GroupInviteLinkModelImplCopyWithImpl<_$GroupInviteLinkModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupInviteLinkModelImplToJson(this);
  }
}

abstract class _GroupInviteLinkModel extends GroupInviteLinkModel {
  const factory _GroupInviteLinkModel({
    required final String id,
    required final String token,
    required final String createdBy,
    @RequiredTimestampConverter() required final DateTime createdAt,
    @TimestampConverter() final DateTime? expiresAt,
    final bool revoked,
    final int? usageLimit,
    final int usageCount,
    required final String groupId,
    final String inviteType,
  }) = _$GroupInviteLinkModelImpl;
  const _GroupInviteLinkModel._() : super._();

  factory _GroupInviteLinkModel.fromJson(Map<String, dynamic> json) =
      _$GroupInviteLinkModelImpl.fromJson;

  @override
  String get id;
  @override
  String get token;
  @override
  String get createdBy;
  @override
  @RequiredTimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime? get expiresAt;
  @override
  bool get revoked;
  @override
  int? get usageLimit;
  @override
  int get usageCount;
  @override
  String get groupId;
  @override
  String get inviteType;

  /// Create a copy of GroupInviteLinkModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupInviteLinkModelImplCopyWith<_$GroupInviteLinkModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
