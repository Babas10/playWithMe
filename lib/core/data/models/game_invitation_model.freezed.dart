// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_invitation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GameInvitationModel _$GameInvitationModelFromJson(Map<String, dynamic> json) {
  return _GameInvitationModel.fromJson(json);
}

/// @nodoc
mixin _$GameInvitationModel {
  String get id => throw _privateConstructorUsedError;
  String get gameId => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String get inviteeId => throw _privateConstructorUsedError;
  String get inviterId => throw _privateConstructorUsedError;
  GameInvitationStatus get status => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError; // Optional: when the invitation expires (set to game scheduledAt by CF)
  @TimestampConverter()
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this GameInvitationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameInvitationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameInvitationModelCopyWith<GameInvitationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameInvitationModelCopyWith<$Res> {
  factory $GameInvitationModelCopyWith(
    GameInvitationModel value,
    $Res Function(GameInvitationModel) then,
  ) = _$GameInvitationModelCopyWithImpl<$Res, GameInvitationModel>;
  @useResult
  $Res call({
    String id,
    String gameId,
    String groupId,
    String inviteeId,
    String inviterId,
    GameInvitationStatus status,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime? expiresAt,
  });
}

/// @nodoc
class _$GameInvitationModelCopyWithImpl<$Res, $Val extends GameInvitationModel>
    implements $GameInvitationModelCopyWith<$Res> {
  _$GameInvitationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameInvitationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gameId = null,
    Object? groupId = null,
    Object? inviteeId = null,
    Object? inviterId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            gameId: null == gameId
                ? _value.gameId
                : gameId // ignore: cast_nullable_to_non_nullable
                      as String,
            groupId: null == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                      as String,
            inviteeId: null == inviteeId
                ? _value.inviteeId
                : inviteeId // ignore: cast_nullable_to_non_nullable
                      as String,
            inviterId: null == inviterId
                ? _value.inviterId
                : inviterId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as GameInvitationStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expiresAt: freezed == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameInvitationModelImplCopyWith<$Res>
    implements $GameInvitationModelCopyWith<$Res> {
  factory _$$GameInvitationModelImplCopyWith(
    _$GameInvitationModelImpl value,
    $Res Function(_$GameInvitationModelImpl) then,
  ) = __$$GameInvitationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String gameId,
    String groupId,
    String inviteeId,
    String inviterId,
    GameInvitationStatus status,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
    @TimestampConverter() DateTime? expiresAt,
  });
}

/// @nodoc
class __$$GameInvitationModelImplCopyWithImpl<$Res>
    extends _$GameInvitationModelCopyWithImpl<$Res, _$GameInvitationModelImpl>
    implements _$$GameInvitationModelImplCopyWith<$Res> {
  __$$GameInvitationModelImplCopyWithImpl(
    _$GameInvitationModelImpl _value,
    $Res Function(_$GameInvitationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameInvitationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? gameId = null,
    Object? groupId = null,
    Object? inviteeId = null,
    Object? inviterId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(
      _$GameInvitationModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        gameId: null == gameId
            ? _value.gameId
            : gameId // ignore: cast_nullable_to_non_nullable
                  as String,
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String,
        inviteeId: null == inviteeId
            ? _value.inviteeId
            : inviteeId // ignore: cast_nullable_to_non_nullable
                  as String,
        inviterId: null == inviterId
            ? _value.inviterId
            : inviterId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as GameInvitationStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expiresAt: freezed == expiresAt
            ? _value.expiresAt
            : expiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameInvitationModelImpl extends _GameInvitationModel {
  const _$GameInvitationModelImpl({
    required this.id,
    required this.gameId,
    required this.groupId,
    required this.inviteeId,
    required this.inviterId,
    this.status = GameInvitationStatus.pending,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() this.updatedAt,
    @TimestampConverter() this.expiresAt,
  }) : super._();

  factory _$GameInvitationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameInvitationModelImplFromJson(json);

  @override
  final String id;
  @override
  final String gameId;
  @override
  final String groupId;
  @override
  final String inviteeId;
  @override
  final String inviterId;
  @override
  @JsonKey()
  final GameInvitationStatus status;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;
  // Optional: when the invitation expires (set to game scheduledAt by CF)
  @override
  @TimestampConverter()
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'GameInvitationModel(id: $id, gameId: $gameId, groupId: $groupId, inviteeId: $inviteeId, inviterId: $inviterId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameInvitationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.gameId, gameId) || other.gameId == gameId) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.inviteeId, inviteeId) ||
                other.inviteeId == inviteeId) &&
            (identical(other.inviterId, inviterId) ||
                other.inviterId == inviterId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    gameId,
    groupId,
    inviteeId,
    inviterId,
    status,
    createdAt,
    updatedAt,
    expiresAt,
  );

  /// Create a copy of GameInvitationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameInvitationModelImplCopyWith<_$GameInvitationModelImpl> get copyWith =>
      __$$GameInvitationModelImplCopyWithImpl<_$GameInvitationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GameInvitationModelImplToJson(this);
  }
}

abstract class _GameInvitationModel extends GameInvitationModel {
  const factory _GameInvitationModel({
    required final String id,
    required final String gameId,
    required final String groupId,
    required final String inviteeId,
    required final String inviterId,
    final GameInvitationStatus status,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() final DateTime? updatedAt,
    @TimestampConverter() final DateTime? expiresAt,
  }) = _$GameInvitationModelImpl;
  const _GameInvitationModel._() : super._();

  factory _GameInvitationModel.fromJson(Map<String, dynamic> json) =
      _$GameInvitationModelImpl.fromJson;

  @override
  String get id;
  @override
  String get gameId;
  @override
  String get groupId;
  @override
  String get inviteeId;
  @override
  String get inviterId;
  @override
  GameInvitationStatus get status;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt; // Optional: when the invitation expires (set to game scheduledAt by CF)
  @override
  @TimestampConverter()
  DateTime? get expiresAt;

  /// Create a copy of GameInvitationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameInvitationModelImplCopyWith<_$GameInvitationModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
