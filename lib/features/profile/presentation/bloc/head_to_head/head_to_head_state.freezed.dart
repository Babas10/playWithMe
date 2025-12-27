// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'head_to_head_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HeadToHeadState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(HeadToHeadStats stats) loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(HeadToHeadStats stats)? loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(HeadToHeadStats stats)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HeadToHeadInitial value) initial,
    required TResult Function(HeadToHeadLoading value) loading,
    required TResult Function(HeadToHeadLoaded value) loaded,
    required TResult Function(HeadToHeadError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HeadToHeadInitial value)? initial,
    TResult? Function(HeadToHeadLoading value)? loading,
    TResult? Function(HeadToHeadLoaded value)? loaded,
    TResult? Function(HeadToHeadError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HeadToHeadInitial value)? initial,
    TResult Function(HeadToHeadLoading value)? loading,
    TResult Function(HeadToHeadLoaded value)? loaded,
    TResult Function(HeadToHeadError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HeadToHeadStateCopyWith<$Res> {
  factory $HeadToHeadStateCopyWith(
    HeadToHeadState value,
    $Res Function(HeadToHeadState) then,
  ) = _$HeadToHeadStateCopyWithImpl<$Res, HeadToHeadState>;
}

/// @nodoc
class _$HeadToHeadStateCopyWithImpl<$Res, $Val extends HeadToHeadState>
    implements $HeadToHeadStateCopyWith<$Res> {
  _$HeadToHeadStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HeadToHeadState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$HeadToHeadInitialImplCopyWith<$Res> {
  factory _$$HeadToHeadInitialImplCopyWith(
    _$HeadToHeadInitialImpl value,
    $Res Function(_$HeadToHeadInitialImpl) then,
  ) = __$$HeadToHeadInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$HeadToHeadInitialImplCopyWithImpl<$Res>
    extends _$HeadToHeadStateCopyWithImpl<$Res, _$HeadToHeadInitialImpl>
    implements _$$HeadToHeadInitialImplCopyWith<$Res> {
  __$$HeadToHeadInitialImplCopyWithImpl(
    _$HeadToHeadInitialImpl _value,
    $Res Function(_$HeadToHeadInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HeadToHeadState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$HeadToHeadInitialImpl implements HeadToHeadInitial {
  const _$HeadToHeadInitialImpl();

  @override
  String toString() {
    return 'HeadToHeadState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$HeadToHeadInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(HeadToHeadStats stats) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(HeadToHeadStats stats)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(HeadToHeadStats stats)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HeadToHeadInitial value) initial,
    required TResult Function(HeadToHeadLoading value) loading,
    required TResult Function(HeadToHeadLoaded value) loaded,
    required TResult Function(HeadToHeadError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HeadToHeadInitial value)? initial,
    TResult? Function(HeadToHeadLoading value)? loading,
    TResult? Function(HeadToHeadLoaded value)? loaded,
    TResult? Function(HeadToHeadError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HeadToHeadInitial value)? initial,
    TResult Function(HeadToHeadLoading value)? loading,
    TResult Function(HeadToHeadLoaded value)? loaded,
    TResult Function(HeadToHeadError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class HeadToHeadInitial implements HeadToHeadState {
  const factory HeadToHeadInitial() = _$HeadToHeadInitialImpl;
}

/// @nodoc
abstract class _$$HeadToHeadLoadingImplCopyWith<$Res> {
  factory _$$HeadToHeadLoadingImplCopyWith(
    _$HeadToHeadLoadingImpl value,
    $Res Function(_$HeadToHeadLoadingImpl) then,
  ) = __$$HeadToHeadLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$HeadToHeadLoadingImplCopyWithImpl<$Res>
    extends _$HeadToHeadStateCopyWithImpl<$Res, _$HeadToHeadLoadingImpl>
    implements _$$HeadToHeadLoadingImplCopyWith<$Res> {
  __$$HeadToHeadLoadingImplCopyWithImpl(
    _$HeadToHeadLoadingImpl _value,
    $Res Function(_$HeadToHeadLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HeadToHeadState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$HeadToHeadLoadingImpl implements HeadToHeadLoading {
  const _$HeadToHeadLoadingImpl();

  @override
  String toString() {
    return 'HeadToHeadState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$HeadToHeadLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(HeadToHeadStats stats) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(HeadToHeadStats stats)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(HeadToHeadStats stats)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HeadToHeadInitial value) initial,
    required TResult Function(HeadToHeadLoading value) loading,
    required TResult Function(HeadToHeadLoaded value) loaded,
    required TResult Function(HeadToHeadError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HeadToHeadInitial value)? initial,
    TResult? Function(HeadToHeadLoading value)? loading,
    TResult? Function(HeadToHeadLoaded value)? loaded,
    TResult? Function(HeadToHeadError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HeadToHeadInitial value)? initial,
    TResult Function(HeadToHeadLoading value)? loading,
    TResult Function(HeadToHeadLoaded value)? loaded,
    TResult Function(HeadToHeadError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class HeadToHeadLoading implements HeadToHeadState {
  const factory HeadToHeadLoading() = _$HeadToHeadLoadingImpl;
}

/// @nodoc
abstract class _$$HeadToHeadLoadedImplCopyWith<$Res> {
  factory _$$HeadToHeadLoadedImplCopyWith(
    _$HeadToHeadLoadedImpl value,
    $Res Function(_$HeadToHeadLoadedImpl) then,
  ) = __$$HeadToHeadLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({HeadToHeadStats stats});

  $HeadToHeadStatsCopyWith<$Res> get stats;
}

/// @nodoc
class __$$HeadToHeadLoadedImplCopyWithImpl<$Res>
    extends _$HeadToHeadStateCopyWithImpl<$Res, _$HeadToHeadLoadedImpl>
    implements _$$HeadToHeadLoadedImplCopyWith<$Res> {
  __$$HeadToHeadLoadedImplCopyWithImpl(
    _$HeadToHeadLoadedImpl _value,
    $Res Function(_$HeadToHeadLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HeadToHeadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? stats = null}) {
    return _then(
      _$HeadToHeadLoadedImpl(
        stats: null == stats
            ? _value.stats
            : stats // ignore: cast_nullable_to_non_nullable
                  as HeadToHeadStats,
      ),
    );
  }

  /// Create a copy of HeadToHeadState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HeadToHeadStatsCopyWith<$Res> get stats {
    return $HeadToHeadStatsCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value));
    });
  }
}

/// @nodoc

class _$HeadToHeadLoadedImpl implements HeadToHeadLoaded {
  const _$HeadToHeadLoadedImpl({required this.stats});

  @override
  final HeadToHeadStats stats;

  @override
  String toString() {
    return 'HeadToHeadState.loaded(stats: $stats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HeadToHeadLoadedImpl &&
            (identical(other.stats, stats) || other.stats == stats));
  }

  @override
  int get hashCode => Object.hash(runtimeType, stats);

  /// Create a copy of HeadToHeadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HeadToHeadLoadedImplCopyWith<_$HeadToHeadLoadedImpl> get copyWith =>
      __$$HeadToHeadLoadedImplCopyWithImpl<_$HeadToHeadLoadedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(HeadToHeadStats stats) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(stats);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(HeadToHeadStats stats)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(stats);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(HeadToHeadStats stats)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(stats);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HeadToHeadInitial value) initial,
    required TResult Function(HeadToHeadLoading value) loading,
    required TResult Function(HeadToHeadLoaded value) loaded,
    required TResult Function(HeadToHeadError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HeadToHeadInitial value)? initial,
    TResult? Function(HeadToHeadLoading value)? loading,
    TResult? Function(HeadToHeadLoaded value)? loaded,
    TResult? Function(HeadToHeadError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HeadToHeadInitial value)? initial,
    TResult Function(HeadToHeadLoading value)? loading,
    TResult Function(HeadToHeadLoaded value)? loaded,
    TResult Function(HeadToHeadError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class HeadToHeadLoaded implements HeadToHeadState {
  const factory HeadToHeadLoaded({required final HeadToHeadStats stats}) =
      _$HeadToHeadLoadedImpl;

  HeadToHeadStats get stats;

  /// Create a copy of HeadToHeadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HeadToHeadLoadedImplCopyWith<_$HeadToHeadLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$HeadToHeadErrorImplCopyWith<$Res> {
  factory _$$HeadToHeadErrorImplCopyWith(
    _$HeadToHeadErrorImpl value,
    $Res Function(_$HeadToHeadErrorImpl) then,
  ) = __$$HeadToHeadErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$HeadToHeadErrorImplCopyWithImpl<$Res>
    extends _$HeadToHeadStateCopyWithImpl<$Res, _$HeadToHeadErrorImpl>
    implements _$$HeadToHeadErrorImplCopyWith<$Res> {
  __$$HeadToHeadErrorImplCopyWithImpl(
    _$HeadToHeadErrorImpl _value,
    $Res Function(_$HeadToHeadErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HeadToHeadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$HeadToHeadErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$HeadToHeadErrorImpl implements HeadToHeadError {
  const _$HeadToHeadErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'HeadToHeadState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HeadToHeadErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of HeadToHeadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HeadToHeadErrorImplCopyWith<_$HeadToHeadErrorImpl> get copyWith =>
      __$$HeadToHeadErrorImplCopyWithImpl<_$HeadToHeadErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(HeadToHeadStats stats) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(HeadToHeadStats stats)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(HeadToHeadStats stats)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(HeadToHeadInitial value) initial,
    required TResult Function(HeadToHeadLoading value) loading,
    required TResult Function(HeadToHeadLoaded value) loaded,
    required TResult Function(HeadToHeadError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(HeadToHeadInitial value)? initial,
    TResult? Function(HeadToHeadLoading value)? loading,
    TResult? Function(HeadToHeadLoaded value)? loaded,
    TResult? Function(HeadToHeadError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(HeadToHeadInitial value)? initial,
    TResult Function(HeadToHeadLoading value)? loading,
    TResult Function(HeadToHeadLoaded value)? loaded,
    TResult Function(HeadToHeadError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class HeadToHeadError implements HeadToHeadState {
  const factory HeadToHeadError({required final String message}) =
      _$HeadToHeadErrorImpl;

  String get message;

  /// Create a copy of HeadToHeadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HeadToHeadErrorImplCopyWith<_$HeadToHeadErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
