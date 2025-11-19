// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend_request_count_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FriendRequestCountEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) startListening,
    required TResult Function() stopListening,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? startListening,
    TResult? Function()? stopListening,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? startListening,
    TResult Function()? stopListening,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendRequestCountStartListening value)
    startListening,
    required TResult Function(FriendRequestCountStopListening value)
    stopListening,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendRequestCountStartListening value)? startListening,
    TResult? Function(FriendRequestCountStopListening value)? stopListening,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendRequestCountStartListening value)? startListening,
    TResult Function(FriendRequestCountStopListening value)? stopListening,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendRequestCountEventCopyWith<$Res> {
  factory $FriendRequestCountEventCopyWith(
    FriendRequestCountEvent value,
    $Res Function(FriendRequestCountEvent) then,
  ) = _$FriendRequestCountEventCopyWithImpl<$Res, FriendRequestCountEvent>;
}

/// @nodoc
class _$FriendRequestCountEventCopyWithImpl<
  $Res,
  $Val extends FriendRequestCountEvent
>
    implements $FriendRequestCountEventCopyWith<$Res> {
  _$FriendRequestCountEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendRequestCountEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$FriendRequestCountStartListeningImplCopyWith<$Res> {
  factory _$$FriendRequestCountStartListeningImplCopyWith(
    _$FriendRequestCountStartListeningImpl value,
    $Res Function(_$FriendRequestCountStartListeningImpl) then,
  ) = __$$FriendRequestCountStartListeningImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String userId});
}

/// @nodoc
class __$$FriendRequestCountStartListeningImplCopyWithImpl<$Res>
    extends
        _$FriendRequestCountEventCopyWithImpl<
          $Res,
          _$FriendRequestCountStartListeningImpl
        >
    implements _$$FriendRequestCountStartListeningImplCopyWith<$Res> {
  __$$FriendRequestCountStartListeningImplCopyWithImpl(
    _$FriendRequestCountStartListeningImpl _value,
    $Res Function(_$FriendRequestCountStartListeningImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendRequestCountEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null}) {
    return _then(
      _$FriendRequestCountStartListeningImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FriendRequestCountStartListeningImpl
    implements FriendRequestCountStartListening {
  const _$FriendRequestCountStartListeningImpl({required this.userId});

  @override
  final String userId;

  @override
  String toString() {
    return 'FriendRequestCountEvent.startListening(userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendRequestCountStartListeningImpl &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId);

  /// Create a copy of FriendRequestCountEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendRequestCountStartListeningImplCopyWith<
    _$FriendRequestCountStartListeningImpl
  >
  get copyWith =>
      __$$FriendRequestCountStartListeningImplCopyWithImpl<
        _$FriendRequestCountStartListeningImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) startListening,
    required TResult Function() stopListening,
  }) {
    return startListening(userId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? startListening,
    TResult? Function()? stopListening,
  }) {
    return startListening?.call(userId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? startListening,
    TResult Function()? stopListening,
    required TResult orElse(),
  }) {
    if (startListening != null) {
      return startListening(userId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendRequestCountStartListening value)
    startListening,
    required TResult Function(FriendRequestCountStopListening value)
    stopListening,
  }) {
    return startListening(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendRequestCountStartListening value)? startListening,
    TResult? Function(FriendRequestCountStopListening value)? stopListening,
  }) {
    return startListening?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendRequestCountStartListening value)? startListening,
    TResult Function(FriendRequestCountStopListening value)? stopListening,
    required TResult orElse(),
  }) {
    if (startListening != null) {
      return startListening(this);
    }
    return orElse();
  }
}

abstract class FriendRequestCountStartListening
    implements FriendRequestCountEvent {
  const factory FriendRequestCountStartListening({
    required final String userId,
  }) = _$FriendRequestCountStartListeningImpl;

  String get userId;

  /// Create a copy of FriendRequestCountEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendRequestCountStartListeningImplCopyWith<
    _$FriendRequestCountStartListeningImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FriendRequestCountStopListeningImplCopyWith<$Res> {
  factory _$$FriendRequestCountStopListeningImplCopyWith(
    _$FriendRequestCountStopListeningImpl value,
    $Res Function(_$FriendRequestCountStopListeningImpl) then,
  ) = __$$FriendRequestCountStopListeningImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FriendRequestCountStopListeningImplCopyWithImpl<$Res>
    extends
        _$FriendRequestCountEventCopyWithImpl<
          $Res,
          _$FriendRequestCountStopListeningImpl
        >
    implements _$$FriendRequestCountStopListeningImplCopyWith<$Res> {
  __$$FriendRequestCountStopListeningImplCopyWithImpl(
    _$FriendRequestCountStopListeningImpl _value,
    $Res Function(_$FriendRequestCountStopListeningImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendRequestCountEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FriendRequestCountStopListeningImpl
    implements FriendRequestCountStopListening {
  const _$FriendRequestCountStopListeningImpl();

  @override
  String toString() {
    return 'FriendRequestCountEvent.stopListening()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendRequestCountStopListeningImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId) startListening,
    required TResult Function() stopListening,
  }) {
    return stopListening();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId)? startListening,
    TResult? Function()? stopListening,
  }) {
    return stopListening?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId)? startListening,
    TResult Function()? stopListening,
    required TResult orElse(),
  }) {
    if (stopListening != null) {
      return stopListening();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendRequestCountStartListening value)
    startListening,
    required TResult Function(FriendRequestCountStopListening value)
    stopListening,
  }) {
    return stopListening(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendRequestCountStartListening value)? startListening,
    TResult? Function(FriendRequestCountStopListening value)? stopListening,
  }) {
    return stopListening?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendRequestCountStartListening value)? startListening,
    TResult Function(FriendRequestCountStopListening value)? stopListening,
    required TResult orElse(),
  }) {
    if (stopListening != null) {
      return stopListening(this);
    }
    return orElse();
  }
}

abstract class FriendRequestCountStopListening
    implements FriendRequestCountEvent {
  const factory FriendRequestCountStopListening() =
      _$FriendRequestCountStopListeningImpl;
}
