// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'invitation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InvitationModel _$InvitationModelFromJson(Map<String, dynamic> json) {
  return _InvitationModel.fromJson(json);
}

/// @nodoc
mixin _$InvitationModel {
  String get id => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String get groupName => throw _privateConstructorUsedError;
  String get invitedBy => throw _privateConstructorUsedError;
  String get inviterName => throw _privateConstructorUsedError;
  String get invitedUserId => throw _privateConstructorUsedError;
  InvitationStatus get status => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get respondedAt => throw _privateConstructorUsedError;

  /// Serializes this InvitationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InvitationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InvitationModelCopyWith<InvitationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InvitationModelCopyWith<$Res> {
  factory $InvitationModelCopyWith(
    InvitationModel value,
    $Res Function(InvitationModel) then,
  ) = _$InvitationModelCopyWithImpl<$Res, InvitationModel>;
  @useResult
  $Res call({
    String id,
    String groupId,
    String groupName,
    String invitedBy,
    String inviterName,
    String invitedUserId,
    InvitationStatus status,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime? respondedAt,
  });
}

/// @nodoc
class _$InvitationModelCopyWithImpl<$Res, $Val extends InvitationModel>
    implements $InvitationModelCopyWith<$Res> {
  _$InvitationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InvitationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? groupName = null,
    Object? invitedBy = null,
    Object? inviterName = null,
    Object? invitedUserId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? respondedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            groupId: null == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                      as String,
            groupName: null == groupName
                ? _value.groupName
                : groupName // ignore: cast_nullable_to_non_nullable
                      as String,
            invitedBy: null == invitedBy
                ? _value.invitedBy
                : invitedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            inviterName: null == inviterName
                ? _value.inviterName
                : inviterName // ignore: cast_nullable_to_non_nullable
                      as String,
            invitedUserId: null == invitedUserId
                ? _value.invitedUserId
                : invitedUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as InvitationStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            respondedAt: freezed == respondedAt
                ? _value.respondedAt
                : respondedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InvitationModelImplCopyWith<$Res>
    implements $InvitationModelCopyWith<$Res> {
  factory _$$InvitationModelImplCopyWith(
    _$InvitationModelImpl value,
    $Res Function(_$InvitationModelImpl) then,
  ) = __$$InvitationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String groupId,
    String groupName,
    String invitedBy,
    String inviterName,
    String invitedUserId,
    InvitationStatus status,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime? respondedAt,
  });
}

/// @nodoc
class __$$InvitationModelImplCopyWithImpl<$Res>
    extends _$InvitationModelCopyWithImpl<$Res, _$InvitationModelImpl>
    implements _$$InvitationModelImplCopyWith<$Res> {
  __$$InvitationModelImplCopyWithImpl(
    _$InvitationModelImpl _value,
    $Res Function(_$InvitationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InvitationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? groupName = null,
    Object? invitedBy = null,
    Object? inviterName = null,
    Object? invitedUserId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? respondedAt = freezed,
  }) {
    return _then(
      _$InvitationModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String,
        groupName: null == groupName
            ? _value.groupName
            : groupName // ignore: cast_nullable_to_non_nullable
                  as String,
        invitedBy: null == invitedBy
            ? _value.invitedBy
            : invitedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        inviterName: null == inviterName
            ? _value.inviterName
            : inviterName // ignore: cast_nullable_to_non_nullable
                  as String,
        invitedUserId: null == invitedUserId
            ? _value.invitedUserId
            : invitedUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as InvitationStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        respondedAt: freezed == respondedAt
            ? _value.respondedAt
            : respondedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InvitationModelImpl extends _InvitationModel {
  const _$InvitationModelImpl({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.invitedBy,
    required this.inviterName,
    required this.invitedUserId,
    this.status = InvitationStatus.pending,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() this.respondedAt,
  }) : super._();

  factory _$InvitationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InvitationModelImplFromJson(json);

  @override
  final String id;
  @override
  final String groupId;
  @override
  final String groupName;
  @override
  final String invitedBy;
  @override
  final String inviterName;
  @override
  final String invitedUserId;
  @override
  @JsonKey()
  final InvitationStatus status;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime? respondedAt;

  @override
  String toString() {
    return 'InvitationModel(id: $id, groupId: $groupId, groupName: $groupName, invitedBy: $invitedBy, inviterName: $inviterName, invitedUserId: $invitedUserId, status: $status, createdAt: $createdAt, respondedAt: $respondedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvitationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.invitedBy, invitedBy) ||
                other.invitedBy == invitedBy) &&
            (identical(other.inviterName, inviterName) ||
                other.inviterName == inviterName) &&
            (identical(other.invitedUserId, invitedUserId) ||
                other.invitedUserId == invitedUserId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.respondedAt, respondedAt) ||
                other.respondedAt == respondedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    groupId,
    groupName,
    invitedBy,
    inviterName,
    invitedUserId,
    status,
    createdAt,
    respondedAt,
  );

  /// Create a copy of InvitationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvitationModelImplCopyWith<_$InvitationModelImpl> get copyWith =>
      __$$InvitationModelImplCopyWithImpl<_$InvitationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InvitationModelImplToJson(this);
  }
}

abstract class _InvitationModel extends InvitationModel {
  const factory _InvitationModel({
    required final String id,
    required final String groupId,
    required final String groupName,
    required final String invitedBy,
    required final String inviterName,
    required final String invitedUserId,
    final InvitationStatus status,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() final DateTime? respondedAt,
  }) = _$InvitationModelImpl;
  const _InvitationModel._() : super._();

  factory _InvitationModel.fromJson(Map<String, dynamic> json) =
      _$InvitationModelImpl.fromJson;

  @override
  String get id;
  @override
  String get groupId;
  @override
  String get groupName;
  @override
  String get invitedBy;
  @override
  String get inviterName;
  @override
  String get invitedUserId;
  @override
  InvitationStatus get status;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime? get respondedAt;

  /// Create a copy of InvitationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvitationModelImplCopyWith<_$InvitationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
