// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'head_to_head_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HeadToHeadEvent {
  String get userId => throw _privateConstructorUsedError;
  String get opponentId => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId, String opponentId) loadHeadToHead,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId, String opponentId)? loadHeadToHead,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId, String opponentId)? loadHeadToHead,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadHeadToHead value) loadHeadToHead,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadHeadToHead value)? loadHeadToHead,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadHeadToHead value)? loadHeadToHead,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of HeadToHeadEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HeadToHeadEventCopyWith<HeadToHeadEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HeadToHeadEventCopyWith<$Res> {
  factory $HeadToHeadEventCopyWith(
    HeadToHeadEvent value,
    $Res Function(HeadToHeadEvent) then,
  ) = _$HeadToHeadEventCopyWithImpl<$Res, HeadToHeadEvent>;
  @useResult
  $Res call({String userId, String opponentId});
}

/// @nodoc
class _$HeadToHeadEventCopyWithImpl<$Res, $Val extends HeadToHeadEvent>
    implements $HeadToHeadEventCopyWith<$Res> {
  _$HeadToHeadEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HeadToHeadEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null, Object? opponentId = null}) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            opponentId: null == opponentId
                ? _value.opponentId
                : opponentId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoadHeadToHeadImplCopyWith<$Res>
    implements $HeadToHeadEventCopyWith<$Res> {
  factory _$$LoadHeadToHeadImplCopyWith(
    _$LoadHeadToHeadImpl value,
    $Res Function(_$LoadHeadToHeadImpl) then,
  ) = __$$LoadHeadToHeadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, String opponentId});
}

/// @nodoc
class __$$LoadHeadToHeadImplCopyWithImpl<$Res>
    extends _$HeadToHeadEventCopyWithImpl<$Res, _$LoadHeadToHeadImpl>
    implements _$$LoadHeadToHeadImplCopyWith<$Res> {
  __$$LoadHeadToHeadImplCopyWithImpl(
    _$LoadHeadToHeadImpl _value,
    $Res Function(_$LoadHeadToHeadImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HeadToHeadEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null, Object? opponentId = null}) {
    return _then(
      _$LoadHeadToHeadImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        opponentId: null == opponentId
            ? _value.opponentId
            : opponentId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$LoadHeadToHeadImpl implements LoadHeadToHead {
  const _$LoadHeadToHeadImpl({required this.userId, required this.opponentId});

  @override
  final String userId;
  @override
  final String opponentId;

  @override
  String toString() {
    return 'HeadToHeadEvent.loadHeadToHead(userId: $userId, opponentId: $opponentId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadHeadToHeadImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.opponentId, opponentId) ||
                other.opponentId == opponentId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId, opponentId);

  /// Create a copy of HeadToHeadEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadHeadToHeadImplCopyWith<_$LoadHeadToHeadImpl> get copyWith =>
      __$$LoadHeadToHeadImplCopyWithImpl<_$LoadHeadToHeadImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId, String opponentId) loadHeadToHead,
  }) {
    return loadHeadToHead(userId, opponentId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId, String opponentId)? loadHeadToHead,
  }) {
    return loadHeadToHead?.call(userId, opponentId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId, String opponentId)? loadHeadToHead,
    required TResult orElse(),
  }) {
    if (loadHeadToHead != null) {
      return loadHeadToHead(userId, opponentId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadHeadToHead value) loadHeadToHead,
  }) {
    return loadHeadToHead(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadHeadToHead value)? loadHeadToHead,
  }) {
    return loadHeadToHead?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadHeadToHead value)? loadHeadToHead,
    required TResult orElse(),
  }) {
    if (loadHeadToHead != null) {
      return loadHeadToHead(this);
    }
    return orElse();
  }
}

abstract class LoadHeadToHead implements HeadToHeadEvent {
  const factory LoadHeadToHead({
    required final String userId,
    required final String opponentId,
  }) = _$LoadHeadToHeadImpl;

  @override
  String get userId;
  @override
  String get opponentId;

  /// Create a copy of HeadToHeadEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadHeadToHeadImplCopyWith<_$LoadHeadToHeadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
