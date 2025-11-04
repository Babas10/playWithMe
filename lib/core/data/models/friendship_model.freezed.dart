// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friendship_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FriendshipModel _$FriendshipModelFromJson(Map<String, dynamic> json) {
  return _FriendshipModel.fromJson(json);
}

/// @nodoc
mixin _$FriendshipModel {
  String get id => throw _privateConstructorUsedError;
  String get initiatorId => throw _privateConstructorUsedError;
  String get recipientId => throw _privateConstructorUsedError;
  FriendshipStatus get status => throw _privateConstructorUsedError;
  @RequiredTimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @RequiredTimestampConverter()
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get initiatorName => throw _privateConstructorUsedError;
  String get recipientName => throw _privateConstructorUsedError;

  /// Serializes this FriendshipModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FriendshipModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendshipModelCopyWith<FriendshipModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendshipModelCopyWith<$Res> {
  factory $FriendshipModelCopyWith(
    FriendshipModel value,
    $Res Function(FriendshipModel) then,
  ) = _$FriendshipModelCopyWithImpl<$Res, FriendshipModel>;
  @useResult
  $Res call({
    String id,
    String initiatorId,
    String recipientId,
    FriendshipStatus status,
    @RequiredTimestampConverter() DateTime createdAt,
    @RequiredTimestampConverter() DateTime updatedAt,
    String initiatorName,
    String recipientName,
  });
}

/// @nodoc
class _$FriendshipModelCopyWithImpl<$Res, $Val extends FriendshipModel>
    implements $FriendshipModelCopyWith<$Res> {
  _$FriendshipModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendshipModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initiatorId = null,
    Object? recipientId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? initiatorName = null,
    Object? recipientName = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            initiatorId: null == initiatorId
                ? _value.initiatorId
                : initiatorId // ignore: cast_nullable_to_non_nullable
                      as String,
            recipientId: null == recipientId
                ? _value.recipientId
                : recipientId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as FriendshipStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            initiatorName: null == initiatorName
                ? _value.initiatorName
                : initiatorName // ignore: cast_nullable_to_non_nullable
                      as String,
            recipientName: null == recipientName
                ? _value.recipientName
                : recipientName // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FriendshipModelImplCopyWith<$Res>
    implements $FriendshipModelCopyWith<$Res> {
  factory _$$FriendshipModelImplCopyWith(
    _$FriendshipModelImpl value,
    $Res Function(_$FriendshipModelImpl) then,
  ) = __$$FriendshipModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String initiatorId,
    String recipientId,
    FriendshipStatus status,
    @RequiredTimestampConverter() DateTime createdAt,
    @RequiredTimestampConverter() DateTime updatedAt,
    String initiatorName,
    String recipientName,
  });
}

/// @nodoc
class __$$FriendshipModelImplCopyWithImpl<$Res>
    extends _$FriendshipModelCopyWithImpl<$Res, _$FriendshipModelImpl>
    implements _$$FriendshipModelImplCopyWith<$Res> {
  __$$FriendshipModelImplCopyWithImpl(
    _$FriendshipModelImpl _value,
    $Res Function(_$FriendshipModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendshipModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? initiatorId = null,
    Object? recipientId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? initiatorName = null,
    Object? recipientName = null,
  }) {
    return _then(
      _$FriendshipModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        initiatorId: null == initiatorId
            ? _value.initiatorId
            : initiatorId // ignore: cast_nullable_to_non_nullable
                  as String,
        recipientId: null == recipientId
            ? _value.recipientId
            : recipientId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as FriendshipStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        initiatorName: null == initiatorName
            ? _value.initiatorName
            : initiatorName // ignore: cast_nullable_to_non_nullable
                  as String,
        recipientName: null == recipientName
            ? _value.recipientName
            : recipientName // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendshipModelImpl extends _FriendshipModel {
  const _$FriendshipModelImpl({
    required this.id,
    required this.initiatorId,
    required this.recipientId,
    required this.status,
    @RequiredTimestampConverter() required this.createdAt,
    @RequiredTimestampConverter() required this.updatedAt,
    required this.initiatorName,
    required this.recipientName,
  }) : super._();

  factory _$FriendshipModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendshipModelImplFromJson(json);

  @override
  final String id;
  @override
  final String initiatorId;
  @override
  final String recipientId;
  @override
  final FriendshipStatus status;
  @override
  @RequiredTimestampConverter()
  final DateTime createdAt;
  @override
  @RequiredTimestampConverter()
  final DateTime updatedAt;
  @override
  final String initiatorName;
  @override
  final String recipientName;

  @override
  String toString() {
    return 'FriendshipModel(id: $id, initiatorId: $initiatorId, recipientId: $recipientId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, initiatorName: $initiatorName, recipientName: $recipientName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendshipModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.initiatorId, initiatorId) ||
                other.initiatorId == initiatorId) &&
            (identical(other.recipientId, recipientId) ||
                other.recipientId == recipientId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.initiatorName, initiatorName) ||
                other.initiatorName == initiatorName) &&
            (identical(other.recipientName, recipientName) ||
                other.recipientName == recipientName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    initiatorId,
    recipientId,
    status,
    createdAt,
    updatedAt,
    initiatorName,
    recipientName,
  );

  /// Create a copy of FriendshipModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendshipModelImplCopyWith<_$FriendshipModelImpl> get copyWith =>
      __$$FriendshipModelImplCopyWithImpl<_$FriendshipModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendshipModelImplToJson(this);
  }
}

abstract class _FriendshipModel extends FriendshipModel {
  const factory _FriendshipModel({
    required final String id,
    required final String initiatorId,
    required final String recipientId,
    required final FriendshipStatus status,
    @RequiredTimestampConverter() required final DateTime createdAt,
    @RequiredTimestampConverter() required final DateTime updatedAt,
    required final String initiatorName,
    required final String recipientName,
  }) = _$FriendshipModelImpl;
  const _FriendshipModel._() : super._();

  factory _FriendshipModel.fromJson(Map<String, dynamic> json) =
      _$FriendshipModelImpl.fromJson;

  @override
  String get id;
  @override
  String get initiatorId;
  @override
  String get recipientId;
  @override
  FriendshipStatus get status;
  @override
  @RequiredTimestampConverter()
  DateTime get createdAt;
  @override
  @RequiredTimestampConverter()
  DateTime get updatedAt;
  @override
  String get initiatorName;
  @override
  String get recipientName;

  /// Create a copy of FriendshipModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendshipModelImplCopyWith<_$FriendshipModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
