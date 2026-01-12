// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_feedback_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TrainingFeedbackModel _$TrainingFeedbackModelFromJson(
  Map<String, dynamic> json,
) {
  return _TrainingFeedbackModel.fromJson(json);
}

/// @nodoc
mixin _$TrainingFeedbackModel {
  String get id => throw _privateConstructorUsedError;
  String get trainingSessionId => throw _privateConstructorUsedError;

  /// Exercises quality rating (1-5)
  int get exercisesQuality => throw _privateConstructorUsedError;

  /// Training intensity rating (1-5)
  int get trainingIntensity => throw _privateConstructorUsedError;

  /// Coaching clarity rating (1-5)
  int get coachingClarity => throw _privateConstructorUsedError;

  /// Optional written feedback
  String? get comment => throw _privateConstructorUsedError;

  /// Hash of participant ID to prevent duplicates without exposing identity
  /// Hash is SHA-256 of: trainingSessionId + userId + salt
  String get participantHash => throw _privateConstructorUsedError;

  /// Timestamp when feedback was submitted
  @TimestampConverter()
  DateTime get submittedAt => throw _privateConstructorUsedError;

  /// Serializes this TrainingFeedbackModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainingFeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainingFeedbackModelCopyWith<TrainingFeedbackModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingFeedbackModelCopyWith<$Res> {
  factory $TrainingFeedbackModelCopyWith(
    TrainingFeedbackModel value,
    $Res Function(TrainingFeedbackModel) then,
  ) = _$TrainingFeedbackModelCopyWithImpl<$Res, TrainingFeedbackModel>;
  @useResult
  $Res call({
    String id,
    String trainingSessionId,
    int exercisesQuality,
    int trainingIntensity,
    int coachingClarity,
    String? comment,
    String participantHash,
    @TimestampConverter() DateTime submittedAt,
  });
}

/// @nodoc
class _$TrainingFeedbackModelCopyWithImpl<
  $Res,
  $Val extends TrainingFeedbackModel
>
    implements $TrainingFeedbackModelCopyWith<$Res> {
  _$TrainingFeedbackModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainingFeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trainingSessionId = null,
    Object? exercisesQuality = null,
    Object? trainingIntensity = null,
    Object? coachingClarity = null,
    Object? comment = freezed,
    Object? participantHash = null,
    Object? submittedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            trainingSessionId: null == trainingSessionId
                ? _value.trainingSessionId
                : trainingSessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            exercisesQuality: null == exercisesQuality
                ? _value.exercisesQuality
                : exercisesQuality // ignore: cast_nullable_to_non_nullable
                      as int,
            trainingIntensity: null == trainingIntensity
                ? _value.trainingIntensity
                : trainingIntensity // ignore: cast_nullable_to_non_nullable
                      as int,
            coachingClarity: null == coachingClarity
                ? _value.coachingClarity
                : coachingClarity // ignore: cast_nullable_to_non_nullable
                      as int,
            comment: freezed == comment
                ? _value.comment
                : comment // ignore: cast_nullable_to_non_nullable
                      as String?,
            participantHash: null == participantHash
                ? _value.participantHash
                : participantHash // ignore: cast_nullable_to_non_nullable
                      as String,
            submittedAt: null == submittedAt
                ? _value.submittedAt
                : submittedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TrainingFeedbackModelImplCopyWith<$Res>
    implements $TrainingFeedbackModelCopyWith<$Res> {
  factory _$$TrainingFeedbackModelImplCopyWith(
    _$TrainingFeedbackModelImpl value,
    $Res Function(_$TrainingFeedbackModelImpl) then,
  ) = __$$TrainingFeedbackModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String trainingSessionId,
    int exercisesQuality,
    int trainingIntensity,
    int coachingClarity,
    String? comment,
    String participantHash,
    @TimestampConverter() DateTime submittedAt,
  });
}

/// @nodoc
class __$$TrainingFeedbackModelImplCopyWithImpl<$Res>
    extends
        _$TrainingFeedbackModelCopyWithImpl<$Res, _$TrainingFeedbackModelImpl>
    implements _$$TrainingFeedbackModelImplCopyWith<$Res> {
  __$$TrainingFeedbackModelImplCopyWithImpl(
    _$TrainingFeedbackModelImpl _value,
    $Res Function(_$TrainingFeedbackModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainingFeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trainingSessionId = null,
    Object? exercisesQuality = null,
    Object? trainingIntensity = null,
    Object? coachingClarity = null,
    Object? comment = freezed,
    Object? participantHash = null,
    Object? submittedAt = null,
  }) {
    return _then(
      _$TrainingFeedbackModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        trainingSessionId: null == trainingSessionId
            ? _value.trainingSessionId
            : trainingSessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        exercisesQuality: null == exercisesQuality
            ? _value.exercisesQuality
            : exercisesQuality // ignore: cast_nullable_to_non_nullable
                  as int,
        trainingIntensity: null == trainingIntensity
            ? _value.trainingIntensity
            : trainingIntensity // ignore: cast_nullable_to_non_nullable
                  as int,
        coachingClarity: null == coachingClarity
            ? _value.coachingClarity
            : coachingClarity // ignore: cast_nullable_to_non_nullable
                  as int,
        comment: freezed == comment
            ? _value.comment
            : comment // ignore: cast_nullable_to_non_nullable
                  as String?,
        participantHash: null == participantHash
            ? _value.participantHash
            : participantHash // ignore: cast_nullable_to_non_nullable
                  as String,
        submittedAt: null == submittedAt
            ? _value.submittedAt
            : submittedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingFeedbackModelImpl extends _TrainingFeedbackModel {
  const _$TrainingFeedbackModelImpl({
    required this.id,
    required this.trainingSessionId,
    required this.exercisesQuality,
    required this.trainingIntensity,
    required this.coachingClarity,
    this.comment,
    required this.participantHash,
    @TimestampConverter() required this.submittedAt,
  }) : super._();

  factory _$TrainingFeedbackModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingFeedbackModelImplFromJson(json);

  @override
  final String id;
  @override
  final String trainingSessionId;

  /// Exercises quality rating (1-5)
  @override
  final int exercisesQuality;

  /// Training intensity rating (1-5)
  @override
  final int trainingIntensity;

  /// Coaching clarity rating (1-5)
  @override
  final int coachingClarity;

  /// Optional written feedback
  @override
  final String? comment;

  /// Hash of participant ID to prevent duplicates without exposing identity
  /// Hash is SHA-256 of: trainingSessionId + userId + salt
  @override
  final String participantHash;

  /// Timestamp when feedback was submitted
  @override
  @TimestampConverter()
  final DateTime submittedAt;

  @override
  String toString() {
    return 'TrainingFeedbackModel(id: $id, trainingSessionId: $trainingSessionId, exercisesQuality: $exercisesQuality, trainingIntensity: $trainingIntensity, coachingClarity: $coachingClarity, comment: $comment, participantHash: $participantHash, submittedAt: $submittedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingFeedbackModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.trainingSessionId, trainingSessionId) ||
                other.trainingSessionId == trainingSessionId) &&
            (identical(other.exercisesQuality, exercisesQuality) ||
                other.exercisesQuality == exercisesQuality) &&
            (identical(other.trainingIntensity, trainingIntensity) ||
                other.trainingIntensity == trainingIntensity) &&
            (identical(other.coachingClarity, coachingClarity) ||
                other.coachingClarity == coachingClarity) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.participantHash, participantHash) ||
                other.participantHash == participantHash) &&
            (identical(other.submittedAt, submittedAt) ||
                other.submittedAt == submittedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    trainingSessionId,
    exercisesQuality,
    trainingIntensity,
    coachingClarity,
    comment,
    participantHash,
    submittedAt,
  );

  /// Create a copy of TrainingFeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingFeedbackModelImplCopyWith<_$TrainingFeedbackModelImpl>
  get copyWith =>
      __$$TrainingFeedbackModelImplCopyWithImpl<_$TrainingFeedbackModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingFeedbackModelImplToJson(this);
  }
}

abstract class _TrainingFeedbackModel extends TrainingFeedbackModel {
  const factory _TrainingFeedbackModel({
    required final String id,
    required final String trainingSessionId,
    required final int exercisesQuality,
    required final int trainingIntensity,
    required final int coachingClarity,
    final String? comment,
    required final String participantHash,
    @TimestampConverter() required final DateTime submittedAt,
  }) = _$TrainingFeedbackModelImpl;
  const _TrainingFeedbackModel._() : super._();

  factory _TrainingFeedbackModel.fromJson(Map<String, dynamic> json) =
      _$TrainingFeedbackModelImpl.fromJson;

  @override
  String get id;
  @override
  String get trainingSessionId;

  /// Exercises quality rating (1-5)
  @override
  int get exercisesQuality;

  /// Training intensity rating (1-5)
  @override
  int get trainingIntensity;

  /// Coaching clarity rating (1-5)
  @override
  int get coachingClarity;

  /// Optional written feedback
  @override
  String? get comment;

  /// Hash of participant ID to prevent duplicates without exposing identity
  /// Hash is SHA-256 of: trainingSessionId + userId + salt
  @override
  String get participantHash;

  /// Timestamp when feedback was submitted
  @override
  @TimestampConverter()
  DateTime get submittedAt;

  /// Create a copy of TrainingFeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainingFeedbackModelImplCopyWith<_$TrainingFeedbackModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
