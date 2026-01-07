// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_session_participant_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TrainingSessionParticipantModel _$TrainingSessionParticipantModelFromJson(
  Map<String, dynamic> json,
) {
  return _TrainingSessionParticipantModel.fromJson(json);
}

/// @nodoc
mixin _$TrainingSessionParticipantModel {
  /// User ID of the participant
  String get userId => throw _privateConstructorUsedError;

  /// When the user joined the training session
  @TimestampConverter()
  DateTime get joinedAt => throw _privateConstructorUsedError;

  /// Participant status
  ParticipantStatus get status => throw _privateConstructorUsedError;

  /// Serializes this TrainingSessionParticipantModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainingSessionParticipantModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainingSessionParticipantModelCopyWith<TrainingSessionParticipantModel>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingSessionParticipantModelCopyWith<$Res> {
  factory $TrainingSessionParticipantModelCopyWith(
    TrainingSessionParticipantModel value,
    $Res Function(TrainingSessionParticipantModel) then,
  ) =
      _$TrainingSessionParticipantModelCopyWithImpl<
        $Res,
        TrainingSessionParticipantModel
      >;
  @useResult
  $Res call({
    String userId,
    @TimestampConverter() DateTime joinedAt,
    ParticipantStatus status,
  });
}

/// @nodoc
class _$TrainingSessionParticipantModelCopyWithImpl<
  $Res,
  $Val extends TrainingSessionParticipantModel
>
    implements $TrainingSessionParticipantModelCopyWith<$Res> {
  _$TrainingSessionParticipantModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainingSessionParticipantModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? joinedAt = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            joinedAt: null == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as ParticipantStatus,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainingSessionParticipantModelImplCopyWith<$Res>
    implements $TrainingSessionParticipantModelCopyWith<$Res> {
  factory _$$TrainingSessionParticipantModelImplCopyWith(
    _$TrainingSessionParticipantModelImpl value,
    $Res Function(_$TrainingSessionParticipantModelImpl) then,
  ) = __$$TrainingSessionParticipantModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    @TimestampConverter() DateTime joinedAt,
    ParticipantStatus status,
  });
}

/// @nodoc
class __$$TrainingSessionParticipantModelImplCopyWithImpl<$Res>
    extends
        _$TrainingSessionParticipantModelCopyWithImpl<
          $Res,
          _$TrainingSessionParticipantModelImpl
        >
    implements _$$TrainingSessionParticipantModelImplCopyWith<$Res> {
  __$$TrainingSessionParticipantModelImplCopyWithImpl(
    _$TrainingSessionParticipantModelImpl _value,
    $Res Function(_$TrainingSessionParticipantModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainingSessionParticipantModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? joinedAt = null,
    Object? status = null,
  }) {
    return _then(
      _$TrainingSessionParticipantModelImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        joinedAt: null == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as ParticipantStatus,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingSessionParticipantModelImpl
    extends _TrainingSessionParticipantModel {
  const _$TrainingSessionParticipantModelImpl({
    required this.userId,
    @TimestampConverter() required this.joinedAt,
    this.status = ParticipantStatus.joined,
  }) : super._();

  factory _$TrainingSessionParticipantModelImpl.fromJson(
    Map<String, dynamic> json,
  ) => _$$TrainingSessionParticipantModelImplFromJson(json);

  /// User ID of the participant
  @override
  final String userId;

  /// When the user joined the training session
  @override
  @TimestampConverter()
  final DateTime joinedAt;

  /// Participant status
  @override
  @JsonKey()
  final ParticipantStatus status;

  @override
  String toString() {
    return 'TrainingSessionParticipantModel(userId: $userId, joinedAt: $joinedAt, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingSessionParticipantModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, joinedAt, status);

  /// Create a copy of TrainingSessionParticipantModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingSessionParticipantModelImplCopyWith<
    _$TrainingSessionParticipantModelImpl
  >
  get copyWith =>
      __$$TrainingSessionParticipantModelImplCopyWithImpl<
        _$TrainingSessionParticipantModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingSessionParticipantModelImplToJson(this);
  }
}

abstract class _TrainingSessionParticipantModel
    extends TrainingSessionParticipantModel {
  const factory _TrainingSessionParticipantModel({
    required final String userId,
    @TimestampConverter() required final DateTime joinedAt,
    final ParticipantStatus status,
  }) = _$TrainingSessionParticipantModelImpl;
  const _TrainingSessionParticipantModel._() : super._();

  factory _TrainingSessionParticipantModel.fromJson(Map<String, dynamic> json) =
      _$TrainingSessionParticipantModelImpl.fromJson;

  /// User ID of the participant
  @override
  String get userId;

  /// When the user joined the training session
  @override
  @TimestampConverter()
  DateTime get joinedAt;

  /// Participant status
  @override
  ParticipantStatus get status;

  /// Create a copy of TrainingSessionParticipantModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainingSessionParticipantModelImplCopyWith<
    _$TrainingSessionParticipantModelImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
