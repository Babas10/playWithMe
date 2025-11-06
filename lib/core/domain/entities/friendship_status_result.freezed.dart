// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friendship_status_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FriendshipStatusResult _$FriendshipStatusResultFromJson(
  Map<String, dynamic> json,
) {
  return _FriendshipStatusResult.fromJson(json);
}

/// @nodoc
mixin _$FriendshipStatusResult {
  bool get isFriend => throw _privateConstructorUsedError;
  bool get hasPendingRequest => throw _privateConstructorUsedError;
  String? get requestDirection =>
      throw _privateConstructorUsedError; // 'sent' | 'received'
  String? get friendshipId => throw _privateConstructorUsedError;

  /// Serializes this FriendshipStatusResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FriendshipStatusResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FriendshipStatusResultCopyWith<FriendshipStatusResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendshipStatusResultCopyWith<$Res> {
  factory $FriendshipStatusResultCopyWith(
    FriendshipStatusResult value,
    $Res Function(FriendshipStatusResult) then,
  ) = _$FriendshipStatusResultCopyWithImpl<$Res, FriendshipStatusResult>;
  @useResult
  $Res call({
    bool isFriend,
    bool hasPendingRequest,
    String? requestDirection,
    String? friendshipId,
  });
}

/// @nodoc
class _$FriendshipStatusResultCopyWithImpl<
  $Res,
  $Val extends FriendshipStatusResult
>
    implements $FriendshipStatusResultCopyWith<$Res> {
  _$FriendshipStatusResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendshipStatusResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isFriend = null,
    Object? hasPendingRequest = null,
    Object? requestDirection = freezed,
    Object? friendshipId = freezed,
  }) {
    return _then(
      _value.copyWith(
            isFriend: null == isFriend
                ? _value.isFriend
                : isFriend // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasPendingRequest: null == hasPendingRequest
                ? _value.hasPendingRequest
                : hasPendingRequest // ignore: cast_nullable_to_non_nullable
                      as bool,
            requestDirection: freezed == requestDirection
                ? _value.requestDirection
                : requestDirection // ignore: cast_nullable_to_non_nullable
                      as String?,
            friendshipId: freezed == friendshipId
                ? _value.friendshipId
                : friendshipId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FriendshipStatusResultImplCopyWith<$Res>
    implements $FriendshipStatusResultCopyWith<$Res> {
  factory _$$FriendshipStatusResultImplCopyWith(
    _$FriendshipStatusResultImpl value,
    $Res Function(_$FriendshipStatusResultImpl) then,
  ) = __$$FriendshipStatusResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isFriend,
    bool hasPendingRequest,
    String? requestDirection,
    String? friendshipId,
  });
}

/// @nodoc
class __$$FriendshipStatusResultImplCopyWithImpl<$Res>
    extends
        _$FriendshipStatusResultCopyWithImpl<$Res, _$FriendshipStatusResultImpl>
    implements _$$FriendshipStatusResultImplCopyWith<$Res> {
  __$$FriendshipStatusResultImplCopyWithImpl(
    _$FriendshipStatusResultImpl _value,
    $Res Function(_$FriendshipStatusResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendshipStatusResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isFriend = null,
    Object? hasPendingRequest = null,
    Object? requestDirection = freezed,
    Object? friendshipId = freezed,
  }) {
    return _then(
      _$FriendshipStatusResultImpl(
        isFriend: null == isFriend
            ? _value.isFriend
            : isFriend // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasPendingRequest: null == hasPendingRequest
            ? _value.hasPendingRequest
            : hasPendingRequest // ignore: cast_nullable_to_non_nullable
                  as bool,
        requestDirection: freezed == requestDirection
            ? _value.requestDirection
            : requestDirection // ignore: cast_nullable_to_non_nullable
                  as String?,
        friendshipId: freezed == friendshipId
            ? _value.friendshipId
            : friendshipId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FriendshipStatusResultImpl implements _FriendshipStatusResult {
  const _$FriendshipStatusResultImpl({
    required this.isFriend,
    required this.hasPendingRequest,
    this.requestDirection,
    this.friendshipId,
  });

  factory _$FriendshipStatusResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$FriendshipStatusResultImplFromJson(json);

  @override
  final bool isFriend;
  @override
  final bool hasPendingRequest;
  @override
  final String? requestDirection;
  // 'sent' | 'received'
  @override
  final String? friendshipId;

  @override
  String toString() {
    return 'FriendshipStatusResult(isFriend: $isFriend, hasPendingRequest: $hasPendingRequest, requestDirection: $requestDirection, friendshipId: $friendshipId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendshipStatusResultImpl &&
            (identical(other.isFriend, isFriend) ||
                other.isFriend == isFriend) &&
            (identical(other.hasPendingRequest, hasPendingRequest) ||
                other.hasPendingRequest == hasPendingRequest) &&
            (identical(other.requestDirection, requestDirection) ||
                other.requestDirection == requestDirection) &&
            (identical(other.friendshipId, friendshipId) ||
                other.friendshipId == friendshipId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isFriend,
    hasPendingRequest,
    requestDirection,
    friendshipId,
  );

  /// Create a copy of FriendshipStatusResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendshipStatusResultImplCopyWith<_$FriendshipStatusResultImpl>
  get copyWith =>
      __$$FriendshipStatusResultImplCopyWithImpl<_$FriendshipStatusResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FriendshipStatusResultImplToJson(this);
  }
}

abstract class _FriendshipStatusResult implements FriendshipStatusResult {
  const factory _FriendshipStatusResult({
    required final bool isFriend,
    required final bool hasPendingRequest,
    final String? requestDirection,
    final String? friendshipId,
  }) = _$FriendshipStatusResultImpl;

  factory _FriendshipStatusResult.fromJson(Map<String, dynamic> json) =
      _$FriendshipStatusResultImpl.fromJson;

  @override
  bool get isFriend;
  @override
  bool get hasPendingRequest;
  @override
  String? get requestDirection; // 'sent' | 'received'
  @override
  String? get friendshipId;

  /// Create a copy of FriendshipStatusResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendshipStatusResultImplCopyWith<_$FriendshipStatusResultImpl>
  get copyWith => throw _privateConstructorUsedError;
}
