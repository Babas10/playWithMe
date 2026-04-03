// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_deletion_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AccountDeletionEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() deleteRequested,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? deleteRequested,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? deleteRequested,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AccountDeletionRequested value) deleteRequested,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AccountDeletionRequested value)? deleteRequested,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AccountDeletionRequested value)? deleteRequested,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountDeletionEventCopyWith<$Res> {
  factory $AccountDeletionEventCopyWith(
    AccountDeletionEvent value,
    $Res Function(AccountDeletionEvent) then,
  ) = _$AccountDeletionEventCopyWithImpl<$Res, AccountDeletionEvent>;
}

/// @nodoc
class _$AccountDeletionEventCopyWithImpl<
  $Res,
  $Val extends AccountDeletionEvent
>
    implements $AccountDeletionEventCopyWith<$Res> {
  _$AccountDeletionEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AccountDeletionEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$AccountDeletionRequestedImplCopyWith<$Res> {
  factory _$$AccountDeletionRequestedImplCopyWith(
    _$AccountDeletionRequestedImpl value,
    $Res Function(_$AccountDeletionRequestedImpl) then,
  ) = __$$AccountDeletionRequestedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AccountDeletionRequestedImplCopyWithImpl<$Res>
    extends
        _$AccountDeletionEventCopyWithImpl<$Res, _$AccountDeletionRequestedImpl>
    implements _$$AccountDeletionRequestedImplCopyWith<$Res> {
  __$$AccountDeletionRequestedImplCopyWithImpl(
    _$AccountDeletionRequestedImpl _value,
    $Res Function(_$AccountDeletionRequestedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AccountDeletionEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$AccountDeletionRequestedImpl implements AccountDeletionRequested {
  const _$AccountDeletionRequestedImpl();

  @override
  String toString() {
    return 'AccountDeletionEvent.deleteRequested()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountDeletionRequestedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() deleteRequested,
  }) {
    return deleteRequested();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? deleteRequested,
  }) {
    return deleteRequested?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? deleteRequested,
    required TResult orElse(),
  }) {
    if (deleteRequested != null) {
      return deleteRequested();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AccountDeletionRequested value) deleteRequested,
  }) {
    return deleteRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AccountDeletionRequested value)? deleteRequested,
  }) {
    return deleteRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AccountDeletionRequested value)? deleteRequested,
    required TResult orElse(),
  }) {
    if (deleteRequested != null) {
      return deleteRequested(this);
    }
    return orElse();
  }
}

abstract class AccountDeletionRequested implements AccountDeletionEvent {
  const factory AccountDeletionRequested() = _$AccountDeletionRequestedImpl;
}
