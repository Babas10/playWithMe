// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'firebase_project_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FirebaseProjectInfo _$FirebaseProjectInfoFromJson(Map<String, dynamic> json) {
  return _FirebaseProjectInfo.fromJson(json);
}

/// @nodoc
mixin _$FirebaseProjectInfo {
  String get environment => throw _privateConstructorUsedError;
  String get expectedProjectId => throw _privateConstructorUsedError;
  String? get actualProjectId => throw _privateConstructorUsedError;
  FirebaseProjectStatus get status => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  bool get matchesExpected => throw _privateConstructorUsedError;

  /// Serializes this FirebaseProjectInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FirebaseProjectInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FirebaseProjectInfoCopyWith<FirebaseProjectInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirebaseProjectInfoCopyWith<$Res> {
  factory $FirebaseProjectInfoCopyWith(
    FirebaseProjectInfo value,
    $Res Function(FirebaseProjectInfo) then,
  ) = _$FirebaseProjectInfoCopyWithImpl<$Res, FirebaseProjectInfo>;
  @useResult
  $Res call({
    String environment,
    String expectedProjectId,
    String? actualProjectId,
    FirebaseProjectStatus status,
    DateTime? createdAt,
    bool matchesExpected,
  });
}

/// @nodoc
class _$FirebaseProjectInfoCopyWithImpl<$Res, $Val extends FirebaseProjectInfo>
    implements $FirebaseProjectInfoCopyWith<$Res> {
  _$FirebaseProjectInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FirebaseProjectInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? environment = null,
    Object? expectedProjectId = null,
    Object? actualProjectId = freezed,
    Object? status = null,
    Object? createdAt = freezed,
    Object? matchesExpected = null,
  }) {
    return _then(
      _value.copyWith(
            environment: null == environment
                ? _value.environment
                : environment // ignore: cast_nullable_to_non_nullable
                      as String,
            expectedProjectId: null == expectedProjectId
                ? _value.expectedProjectId
                : expectedProjectId // ignore: cast_nullable_to_non_nullable
                      as String,
            actualProjectId: freezed == actualProjectId
                ? _value.actualProjectId
                : actualProjectId // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as FirebaseProjectStatus,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            matchesExpected: null == matchesExpected
                ? _value.matchesExpected
                : matchesExpected // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FirebaseProjectInfoImplCopyWith<$Res>
    implements $FirebaseProjectInfoCopyWith<$Res> {
  factory _$$FirebaseProjectInfoImplCopyWith(
    _$FirebaseProjectInfoImpl value,
    $Res Function(_$FirebaseProjectInfoImpl) then,
  ) = __$$FirebaseProjectInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String environment,
    String expectedProjectId,
    String? actualProjectId,
    FirebaseProjectStatus status,
    DateTime? createdAt,
    bool matchesExpected,
  });
}

/// @nodoc
class __$$FirebaseProjectInfoImplCopyWithImpl<$Res>
    extends _$FirebaseProjectInfoCopyWithImpl<$Res, _$FirebaseProjectInfoImpl>
    implements _$$FirebaseProjectInfoImplCopyWith<$Res> {
  __$$FirebaseProjectInfoImplCopyWithImpl(
    _$FirebaseProjectInfoImpl _value,
    $Res Function(_$FirebaseProjectInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FirebaseProjectInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? environment = null,
    Object? expectedProjectId = null,
    Object? actualProjectId = freezed,
    Object? status = null,
    Object? createdAt = freezed,
    Object? matchesExpected = null,
  }) {
    return _then(
      _$FirebaseProjectInfoImpl(
        environment: null == environment
            ? _value.environment
            : environment // ignore: cast_nullable_to_non_nullable
                  as String,
        expectedProjectId: null == expectedProjectId
            ? _value.expectedProjectId
            : expectedProjectId // ignore: cast_nullable_to_non_nullable
                  as String,
        actualProjectId: freezed == actualProjectId
            ? _value.actualProjectId
            : actualProjectId // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as FirebaseProjectStatus,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        matchesExpected: null == matchesExpected
            ? _value.matchesExpected
            : matchesExpected // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FirebaseProjectInfoImpl implements _FirebaseProjectInfo {
  const _$FirebaseProjectInfoImpl({
    required this.environment,
    required this.expectedProjectId,
    this.actualProjectId,
    required this.status,
    this.createdAt,
    this.matchesExpected = false,
  });

  factory _$FirebaseProjectInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$FirebaseProjectInfoImplFromJson(json);

  @override
  final String environment;
  @override
  final String expectedProjectId;
  @override
  final String? actualProjectId;
  @override
  final FirebaseProjectStatus status;
  @override
  final DateTime? createdAt;
  @override
  @JsonKey()
  final bool matchesExpected;

  @override
  String toString() {
    return 'FirebaseProjectInfo(environment: $environment, expectedProjectId: $expectedProjectId, actualProjectId: $actualProjectId, status: $status, createdAt: $createdAt, matchesExpected: $matchesExpected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirebaseProjectInfoImpl &&
            (identical(other.environment, environment) ||
                other.environment == environment) &&
            (identical(other.expectedProjectId, expectedProjectId) ||
                other.expectedProjectId == expectedProjectId) &&
            (identical(other.actualProjectId, actualProjectId) ||
                other.actualProjectId == actualProjectId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.matchesExpected, matchesExpected) ||
                other.matchesExpected == matchesExpected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    environment,
    expectedProjectId,
    actualProjectId,
    status,
    createdAt,
    matchesExpected,
  );

  /// Create a copy of FirebaseProjectInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirebaseProjectInfoImplCopyWith<_$FirebaseProjectInfoImpl> get copyWith =>
      __$$FirebaseProjectInfoImplCopyWithImpl<_$FirebaseProjectInfoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FirebaseProjectInfoImplToJson(this);
  }
}

abstract class _FirebaseProjectInfo implements FirebaseProjectInfo {
  const factory _FirebaseProjectInfo({
    required final String environment,
    required final String expectedProjectId,
    final String? actualProjectId,
    required final FirebaseProjectStatus status,
    final DateTime? createdAt,
    final bool matchesExpected,
  }) = _$FirebaseProjectInfoImpl;

  factory _FirebaseProjectInfo.fromJson(Map<String, dynamic> json) =
      _$FirebaseProjectInfoImpl.fromJson;

  @override
  String get environment;
  @override
  String get expectedProjectId;
  @override
  String? get actualProjectId;
  @override
  FirebaseProjectStatus get status;
  @override
  DateTime? get createdAt;
  @override
  bool get matchesExpected;

  /// Create a copy of FirebaseProjectInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirebaseProjectInfoImplCopyWith<_$FirebaseProjectInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FirebaseProjectTracker _$FirebaseProjectTrackerFromJson(
  Map<String, dynamic> json,
) {
  return _FirebaseProjectTracker.fromJson(json);
}

/// @nodoc
mixin _$FirebaseProjectTracker {
  String get storyVersion => throw _privateConstructorUsedError;
  DateTime get trackedAt => throw _privateConstructorUsedError;
  List<FirebaseProjectInfo> get projects => throw _privateConstructorUsedError;

  /// Serializes this FirebaseProjectTracker to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FirebaseProjectTracker
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FirebaseProjectTrackerCopyWith<FirebaseProjectTracker> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FirebaseProjectTrackerCopyWith<$Res> {
  factory $FirebaseProjectTrackerCopyWith(
    FirebaseProjectTracker value,
    $Res Function(FirebaseProjectTracker) then,
  ) = _$FirebaseProjectTrackerCopyWithImpl<$Res, FirebaseProjectTracker>;
  @useResult
  $Res call({
    String storyVersion,
    DateTime trackedAt,
    List<FirebaseProjectInfo> projects,
  });
}

/// @nodoc
class _$FirebaseProjectTrackerCopyWithImpl<
  $Res,
  $Val extends FirebaseProjectTracker
>
    implements $FirebaseProjectTrackerCopyWith<$Res> {
  _$FirebaseProjectTrackerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FirebaseProjectTracker
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? storyVersion = null,
    Object? trackedAt = null,
    Object? projects = null,
  }) {
    return _then(
      _value.copyWith(
            storyVersion: null == storyVersion
                ? _value.storyVersion
                : storyVersion // ignore: cast_nullable_to_non_nullable
                      as String,
            trackedAt: null == trackedAt
                ? _value.trackedAt
                : trackedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            projects: null == projects
                ? _value.projects
                : projects // ignore: cast_nullable_to_non_nullable
                      as List<FirebaseProjectInfo>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FirebaseProjectTrackerImplCopyWith<$Res>
    implements $FirebaseProjectTrackerCopyWith<$Res> {
  factory _$$FirebaseProjectTrackerImplCopyWith(
    _$FirebaseProjectTrackerImpl value,
    $Res Function(_$FirebaseProjectTrackerImpl) then,
  ) = __$$FirebaseProjectTrackerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String storyVersion,
    DateTime trackedAt,
    List<FirebaseProjectInfo> projects,
  });
}

/// @nodoc
class __$$FirebaseProjectTrackerImplCopyWithImpl<$Res>
    extends
        _$FirebaseProjectTrackerCopyWithImpl<$Res, _$FirebaseProjectTrackerImpl>
    implements _$$FirebaseProjectTrackerImplCopyWith<$Res> {
  __$$FirebaseProjectTrackerImplCopyWithImpl(
    _$FirebaseProjectTrackerImpl _value,
    $Res Function(_$FirebaseProjectTrackerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FirebaseProjectTracker
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? storyVersion = null,
    Object? trackedAt = null,
    Object? projects = null,
  }) {
    return _then(
      _$FirebaseProjectTrackerImpl(
        storyVersion: null == storyVersion
            ? _value.storyVersion
            : storyVersion // ignore: cast_nullable_to_non_nullable
                  as String,
        trackedAt: null == trackedAt
            ? _value.trackedAt
            : trackedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        projects: null == projects
            ? _value._projects
            : projects // ignore: cast_nullable_to_non_nullable
                  as List<FirebaseProjectInfo>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FirebaseProjectTrackerImpl implements _FirebaseProjectTracker {
  const _$FirebaseProjectTrackerImpl({
    required this.storyVersion,
    required this.trackedAt,
    required final List<FirebaseProjectInfo> projects,
  }) : _projects = projects;

  factory _$FirebaseProjectTrackerImpl.fromJson(Map<String, dynamic> json) =>
      _$$FirebaseProjectTrackerImplFromJson(json);

  @override
  final String storyVersion;
  @override
  final DateTime trackedAt;
  final List<FirebaseProjectInfo> _projects;
  @override
  List<FirebaseProjectInfo> get projects {
    if (_projects is EqualUnmodifiableListView) return _projects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_projects);
  }

  @override
  String toString() {
    return 'FirebaseProjectTracker(storyVersion: $storyVersion, trackedAt: $trackedAt, projects: $projects)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FirebaseProjectTrackerImpl &&
            (identical(other.storyVersion, storyVersion) ||
                other.storyVersion == storyVersion) &&
            (identical(other.trackedAt, trackedAt) ||
                other.trackedAt == trackedAt) &&
            const DeepCollectionEquality().equals(other._projects, _projects));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    storyVersion,
    trackedAt,
    const DeepCollectionEquality().hash(_projects),
  );

  /// Create a copy of FirebaseProjectTracker
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FirebaseProjectTrackerImplCopyWith<_$FirebaseProjectTrackerImpl>
  get copyWith =>
      __$$FirebaseProjectTrackerImplCopyWithImpl<_$FirebaseProjectTrackerImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FirebaseProjectTrackerImplToJson(this);
  }
}

abstract class _FirebaseProjectTracker implements FirebaseProjectTracker {
  const factory _FirebaseProjectTracker({
    required final String storyVersion,
    required final DateTime trackedAt,
    required final List<FirebaseProjectInfo> projects,
  }) = _$FirebaseProjectTrackerImpl;

  factory _FirebaseProjectTracker.fromJson(Map<String, dynamic> json) =
      _$FirebaseProjectTrackerImpl.fromJson;

  @override
  String get storyVersion;
  @override
  DateTime get trackedAt;
  @override
  List<FirebaseProjectInfo> get projects;

  /// Create a copy of FirebaseProjectTracker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FirebaseProjectTrackerImplCopyWith<_$FirebaseProjectTrackerImpl>
  get copyWith => throw _privateConstructorUsedError;
}
