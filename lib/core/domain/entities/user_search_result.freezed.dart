// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UserSearchResult {
  UserEntity? get user => throw _privateConstructorUsedError;
  bool get isFriend => throw _privateConstructorUsedError;
  bool get hasPendingRequest => throw _privateConstructorUsedError;
  String? get requestDirection => throw _privateConstructorUsedError;

  /// Create a copy of UserSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserSearchResultCopyWith<UserSearchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserSearchResultCopyWith<$Res> {
  factory $UserSearchResultCopyWith(
    UserSearchResult value,
    $Res Function(UserSearchResult) then,
  ) = _$UserSearchResultCopyWithImpl<$Res, UserSearchResult>;
  @useResult
  $Res call({
    UserEntity? user,
    bool isFriend,
    bool hasPendingRequest,
    String? requestDirection,
  });

  $UserEntityCopyWith<$Res>? get user;
}

/// @nodoc
class _$UserSearchResultCopyWithImpl<$Res, $Val extends UserSearchResult>
    implements $UserSearchResultCopyWith<$Res> {
  _$UserSearchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? isFriend = null,
    Object? hasPendingRequest = null,
    Object? requestDirection = freezed,
  }) {
    return _then(
      _value.copyWith(
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as UserEntity?,
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
          )
          as $Val,
    );
  }

  /// Create a copy of UserSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserEntityCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserEntityCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserSearchResultImplCopyWith<$Res>
    implements $UserSearchResultCopyWith<$Res> {
  factory _$$UserSearchResultImplCopyWith(
    _$UserSearchResultImpl value,
    $Res Function(_$UserSearchResultImpl) then,
  ) = __$$UserSearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    UserEntity? user,
    bool isFriend,
    bool hasPendingRequest,
    String? requestDirection,
  });

  @override
  $UserEntityCopyWith<$Res>? get user;
}

/// @nodoc
class __$$UserSearchResultImplCopyWithImpl<$Res>
    extends _$UserSearchResultCopyWithImpl<$Res, _$UserSearchResultImpl>
    implements _$$UserSearchResultImplCopyWith<$Res> {
  __$$UserSearchResultImplCopyWithImpl(
    _$UserSearchResultImpl _value,
    $Res Function(_$UserSearchResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? isFriend = null,
    Object? hasPendingRequest = null,
    Object? requestDirection = freezed,
  }) {
    return _then(
      _$UserSearchResultImpl(
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as UserEntity?,
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
      ),
    );
  }
}

/// @nodoc

class _$UserSearchResultImpl implements _UserSearchResult {
  const _$UserSearchResultImpl({
    this.user,
    required this.isFriend,
    required this.hasPendingRequest,
    this.requestDirection,
  });

  @override
  final UserEntity? user;
  @override
  final bool isFriend;
  @override
  final bool hasPendingRequest;
  @override
  final String? requestDirection;

  @override
  String toString() {
    return 'UserSearchResult(user: $user, isFriend: $isFriend, hasPendingRequest: $hasPendingRequest, requestDirection: $requestDirection)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserSearchResultImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.isFriend, isFriend) ||
                other.isFriend == isFriend) &&
            (identical(other.hasPendingRequest, hasPendingRequest) ||
                other.hasPendingRequest == hasPendingRequest) &&
            (identical(other.requestDirection, requestDirection) ||
                other.requestDirection == requestDirection));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    user,
    isFriend,
    hasPendingRequest,
    requestDirection,
  );

  /// Create a copy of UserSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserSearchResultImplCopyWith<_$UserSearchResultImpl> get copyWith =>
      __$$UserSearchResultImplCopyWithImpl<_$UserSearchResultImpl>(
        this,
        _$identity,
      );
}

abstract class _UserSearchResult implements UserSearchResult {
  const factory _UserSearchResult({
    final UserEntity? user,
    required final bool isFriend,
    required final bool hasPendingRequest,
    final String? requestDirection,
  }) = _$UserSearchResultImpl;

  @override
  UserEntity? get user;
  @override
  bool get isFriend;
  @override
  bool get hasPendingRequest;
  @override
  String? get requestDirection;

  /// Create a copy of UserSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserSearchResultImplCopyWith<_$UserSearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
