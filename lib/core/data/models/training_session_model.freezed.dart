// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TrainingSessionModel _$TrainingSessionModelFromJson(Map<String, dynamic> json) {
  return _TrainingSessionModel.fromJson(json);
}

/// @nodoc
mixin _$TrainingSessionModel {
  String get id => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  GameLocation get location => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get startTime => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get endTime => throw _privateConstructorUsedError;
  int get minParticipants => throw _privateConstructorUsedError;
  int get maxParticipants => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError; // Recurrence support (for Story 15.2 - future enhancement)
  String? get recurrenceRule =>
      throw _privateConstructorUsedError; // Session status
  TrainingStatus get status =>
      throw _privateConstructorUsedError; // Participant tracking
  List<String> get participantIds =>
      throw _privateConstructorUsedError; // Session notes
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this TrainingSessionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainingSessionModelCopyWith<TrainingSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingSessionModelCopyWith<$Res> {
  factory $TrainingSessionModelCopyWith(
    TrainingSessionModel value,
    $Res Function(TrainingSessionModel) then,
  ) = _$TrainingSessionModelCopyWithImpl<$Res, TrainingSessionModel>;
  @useResult
  $Res call({
    String id,
    String groupId,
    String title,
    String? description,
    GameLocation location,
    @TimestampConverter() DateTime startTime,
    @TimestampConverter() DateTime endTime,
    int minParticipants,
    int maxParticipants,
    String createdBy,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
    String? recurrenceRule,
    TrainingStatus status,
    List<String> participantIds,
    String? notes,
  });

  $GameLocationCopyWith<$Res> get location;
}

/// @nodoc
class _$TrainingSessionModelCopyWithImpl<
  $Res,
  $Val extends TrainingSessionModel
>
    implements $TrainingSessionModelCopyWith<$Res> {
  _$TrainingSessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? title = null,
    Object? description = freezed,
    Object? location = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? minParticipants = null,
    Object? maxParticipants = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? recurrenceRule = freezed,
    Object? status = null,
    Object? participantIds = null,
    Object? notes = freezed,
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
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as GameLocation,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            minParticipants: null == minParticipants
                ? _value.minParticipants
                : minParticipants // ignore: cast_nullable_to_non_nullable
                      as int,
            maxParticipants: null == maxParticipants
                ? _value.maxParticipants
                : maxParticipants // ignore: cast_nullable_to_non_nullable
                      as int,
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
            recurrenceRule: freezed == recurrenceRule
                ? _value.recurrenceRule
                : recurrenceRule // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as TrainingStatus,
            participantIds: null == participantIds
                ? _value.participantIds
                : participantIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of TrainingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GameLocationCopyWith<$Res> get location {
    return $GameLocationCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrainingSessionModelImplCopyWith<$Res>
    implements $TrainingSessionModelCopyWith<$Res> {
  factory _$$TrainingSessionModelImplCopyWith(
    _$TrainingSessionModelImpl value,
    $Res Function(_$TrainingSessionModelImpl) then,
  ) = __$$TrainingSessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String groupId,
    String title,
    String? description,
    GameLocation location,
    @TimestampConverter() DateTime startTime,
    @TimestampConverter() DateTime endTime,
    int minParticipants,
    int maxParticipants,
    String createdBy,
    @TimestampConverter() DateTime createdAt,
    @TimestampConverter() DateTime? updatedAt,
    String? recurrenceRule,
    TrainingStatus status,
    List<String> participantIds,
    String? notes,
  });

  @override
  $GameLocationCopyWith<$Res> get location;
}

/// @nodoc
class __$$TrainingSessionModelImplCopyWithImpl<$Res>
    extends _$TrainingSessionModelCopyWithImpl<$Res, _$TrainingSessionModelImpl>
    implements _$$TrainingSessionModelImplCopyWith<$Res> {
  __$$TrainingSessionModelImplCopyWithImpl(
    _$TrainingSessionModelImpl _value,
    $Res Function(_$TrainingSessionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? title = null,
    Object? description = freezed,
    Object? location = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? minParticipants = null,
    Object? maxParticipants = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? recurrenceRule = freezed,
    Object? status = null,
    Object? participantIds = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$TrainingSessionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as GameLocation,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        minParticipants: null == minParticipants
            ? _value.minParticipants
            : minParticipants // ignore: cast_nullable_to_non_nullable
                  as int,
        maxParticipants: null == maxParticipants
            ? _value.maxParticipants
            : maxParticipants // ignore: cast_nullable_to_non_nullable
                  as int,
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
        recurrenceRule: freezed == recurrenceRule
            ? _value.recurrenceRule
            : recurrenceRule // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as TrainingStatus,
        participantIds: null == participantIds
            ? _value._participantIds
            : participantIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainingSessionModelImpl extends _TrainingSessionModel {
  const _$TrainingSessionModelImpl({
    required this.id,
    required this.groupId,
    required this.title,
    this.description,
    required this.location,
    @TimestampConverter() required this.startTime,
    @TimestampConverter() required this.endTime,
    required this.minParticipants,
    required this.maxParticipants,
    required this.createdBy,
    @TimestampConverter() required this.createdAt,
    @TimestampConverter() this.updatedAt,
    this.recurrenceRule,
    this.status = TrainingStatus.scheduled,
    final List<String> participantIds = const [],
    this.notes,
  }) : _participantIds = participantIds,
       super._();

  factory _$TrainingSessionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingSessionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String groupId;
  @override
  final String title;
  @override
  final String? description;
  @override
  final GameLocation location;
  @override
  @TimestampConverter()
  final DateTime startTime;
  @override
  @TimestampConverter()
  final DateTime endTime;
  @override
  final int minParticipants;
  @override
  final int maxParticipants;
  @override
  final String createdBy;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;
  // Recurrence support (for Story 15.2 - future enhancement)
  @override
  final String? recurrenceRule;
  // Session status
  @override
  @JsonKey()
  final TrainingStatus status;
  // Participant tracking
  final List<String> _participantIds;
  // Participant tracking
  @override
  @JsonKey()
  List<String> get participantIds {
    if (_participantIds is EqualUnmodifiableListView) return _participantIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantIds);
  }

  // Session notes
  @override
  final String? notes;

  @override
  String toString() {
    return 'TrainingSessionModel(id: $id, groupId: $groupId, title: $title, description: $description, location: $location, startTime: $startTime, endTime: $endTime, minParticipants: $minParticipants, maxParticipants: $maxParticipants, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, recurrenceRule: $recurrenceRule, status: $status, participantIds: $participantIds, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingSessionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.minParticipants, minParticipants) ||
                other.minParticipants == minParticipants) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.recurrenceRule, recurrenceRule) ||
                other.recurrenceRule == recurrenceRule) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._participantIds,
              _participantIds,
            ) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    groupId,
    title,
    description,
    location,
    startTime,
    endTime,
    minParticipants,
    maxParticipants,
    createdBy,
    createdAt,
    updatedAt,
    recurrenceRule,
    status,
    const DeepCollectionEquality().hash(_participantIds),
    notes,
  );

  /// Create a copy of TrainingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingSessionModelImplCopyWith<_$TrainingSessionModelImpl>
  get copyWith =>
      __$$TrainingSessionModelImplCopyWithImpl<_$TrainingSessionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingSessionModelImplToJson(this);
  }
}

abstract class _TrainingSessionModel extends TrainingSessionModel {
  const factory _TrainingSessionModel({
    required final String id,
    required final String groupId,
    required final String title,
    final String? description,
    required final GameLocation location,
    @TimestampConverter() required final DateTime startTime,
    @TimestampConverter() required final DateTime endTime,
    required final int minParticipants,
    required final int maxParticipants,
    required final String createdBy,
    @TimestampConverter() required final DateTime createdAt,
    @TimestampConverter() final DateTime? updatedAt,
    final String? recurrenceRule,
    final TrainingStatus status,
    final List<String> participantIds,
    final String? notes,
  }) = _$TrainingSessionModelImpl;
  const _TrainingSessionModel._() : super._();

  factory _TrainingSessionModel.fromJson(Map<String, dynamic> json) =
      _$TrainingSessionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get groupId;
  @override
  String get title;
  @override
  String? get description;
  @override
  GameLocation get location;
  @override
  @TimestampConverter()
  DateTime get startTime;
  @override
  @TimestampConverter()
  DateTime get endTime;
  @override
  int get minParticipants;
  @override
  int get maxParticipants;
  @override
  String get createdBy;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt; // Recurrence support (for Story 15.2 - future enhancement)
  @override
  String? get recurrenceRule; // Session status
  @override
  TrainingStatus get status; // Participant tracking
  @override
  List<String> get participantIds; // Session notes
  @override
  String? get notes;

  /// Create a copy of TrainingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainingSessionModelImplCopyWith<_$TrainingSessionModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
