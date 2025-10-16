// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'email_verification_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$EmailVerificationEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkStatus,
    required TResult Function() sendVerificationEmail,
    required TResult Function() refreshStatus,
    required TResult Function() resetError,
    required TResult Function(bool isVerified, DateTime? verifiedAt)
    authStateChanged,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkStatus,
    TResult? Function()? sendVerificationEmail,
    TResult? Function()? refreshStatus,
    TResult? Function()? resetError,
    TResult? Function(bool isVerified, DateTime? verifiedAt)? authStateChanged,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkStatus,
    TResult Function()? sendVerificationEmail,
    TResult Function()? refreshStatus,
    TResult Function()? resetError,
    TResult Function(bool isVerified, DateTime? verifiedAt)? authStateChanged,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmailVerificationCheckStatus value) checkStatus,
    required TResult Function(EmailVerificationSendEmail value)
    sendVerificationEmail,
    required TResult Function(EmailVerificationRefreshStatus value)
    refreshStatus,
    required TResult Function(EmailVerificationResetError value) resetError,
    required TResult Function(EmailVerificationAuthStateChanged value)
    authStateChanged,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmailVerificationCheckStatus value)? checkStatus,
    TResult? Function(EmailVerificationSendEmail value)? sendVerificationEmail,
    TResult? Function(EmailVerificationRefreshStatus value)? refreshStatus,
    TResult? Function(EmailVerificationResetError value)? resetError,
    TResult? Function(EmailVerificationAuthStateChanged value)?
    authStateChanged,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmailVerificationCheckStatus value)? checkStatus,
    TResult Function(EmailVerificationSendEmail value)? sendVerificationEmail,
    TResult Function(EmailVerificationRefreshStatus value)? refreshStatus,
    TResult Function(EmailVerificationResetError value)? resetError,
    TResult Function(EmailVerificationAuthStateChanged value)? authStateChanged,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmailVerificationEventCopyWith<$Res> {
  factory $EmailVerificationEventCopyWith(
    EmailVerificationEvent value,
    $Res Function(EmailVerificationEvent) then,
  ) = _$EmailVerificationEventCopyWithImpl<$Res, EmailVerificationEvent>;
}

/// @nodoc
class _$EmailVerificationEventCopyWithImpl<
  $Res,
  $Val extends EmailVerificationEvent
>
    implements $EmailVerificationEventCopyWith<$Res> {
  _$EmailVerificationEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmailVerificationEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$EmailVerificationCheckStatusImplCopyWith<$Res> {
  factory _$$EmailVerificationCheckStatusImplCopyWith(
    _$EmailVerificationCheckStatusImpl value,
    $Res Function(_$EmailVerificationCheckStatusImpl) then,
  ) = __$$EmailVerificationCheckStatusImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EmailVerificationCheckStatusImplCopyWithImpl<$Res>
    extends
        _$EmailVerificationEventCopyWithImpl<
          $Res,
          _$EmailVerificationCheckStatusImpl
        >
    implements _$$EmailVerificationCheckStatusImplCopyWith<$Res> {
  __$$EmailVerificationCheckStatusImplCopyWithImpl(
    _$EmailVerificationCheckStatusImpl _value,
    $Res Function(_$EmailVerificationCheckStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmailVerificationEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$EmailVerificationCheckStatusImpl
    implements EmailVerificationCheckStatus {
  const _$EmailVerificationCheckStatusImpl();

  @override
  String toString() {
    return 'EmailVerificationEvent.checkStatus()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailVerificationCheckStatusImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkStatus,
    required TResult Function() sendVerificationEmail,
    required TResult Function() refreshStatus,
    required TResult Function() resetError,
    required TResult Function(bool isVerified, DateTime? verifiedAt)
    authStateChanged,
  }) {
    return checkStatus();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkStatus,
    TResult? Function()? sendVerificationEmail,
    TResult? Function()? refreshStatus,
    TResult? Function()? resetError,
    TResult? Function(bool isVerified, DateTime? verifiedAt)? authStateChanged,
  }) {
    return checkStatus?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkStatus,
    TResult Function()? sendVerificationEmail,
    TResult Function()? refreshStatus,
    TResult Function()? resetError,
    TResult Function(bool isVerified, DateTime? verifiedAt)? authStateChanged,
    required TResult orElse(),
  }) {
    if (checkStatus != null) {
      return checkStatus();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmailVerificationCheckStatus value) checkStatus,
    required TResult Function(EmailVerificationSendEmail value)
    sendVerificationEmail,
    required TResult Function(EmailVerificationRefreshStatus value)
    refreshStatus,
    required TResult Function(EmailVerificationResetError value) resetError,
    required TResult Function(EmailVerificationAuthStateChanged value)
    authStateChanged,
  }) {
    return checkStatus(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmailVerificationCheckStatus value)? checkStatus,
    TResult? Function(EmailVerificationSendEmail value)? sendVerificationEmail,
    TResult? Function(EmailVerificationRefreshStatus value)? refreshStatus,
    TResult? Function(EmailVerificationResetError value)? resetError,
    TResult? Function(EmailVerificationAuthStateChanged value)?
    authStateChanged,
  }) {
    return checkStatus?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmailVerificationCheckStatus value)? checkStatus,
    TResult Function(EmailVerificationSendEmail value)? sendVerificationEmail,
    TResult Function(EmailVerificationRefreshStatus value)? refreshStatus,
    TResult Function(EmailVerificationResetError value)? resetError,
    TResult Function(EmailVerificationAuthStateChanged value)? authStateChanged,
    required TResult orElse(),
  }) {
    if (checkStatus != null) {
      return checkStatus(this);
    }
    return orElse();
  }
}

abstract class EmailVerificationCheckStatus implements EmailVerificationEvent {
  const factory EmailVerificationCheckStatus() =
      _$EmailVerificationCheckStatusImpl;
}

/// @nodoc
abstract class _$$EmailVerificationSendEmailImplCopyWith<$Res> {
  factory _$$EmailVerificationSendEmailImplCopyWith(
    _$EmailVerificationSendEmailImpl value,
    $Res Function(_$EmailVerificationSendEmailImpl) then,
  ) = __$$EmailVerificationSendEmailImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EmailVerificationSendEmailImplCopyWithImpl<$Res>
    extends
        _$EmailVerificationEventCopyWithImpl<
          $Res,
          _$EmailVerificationSendEmailImpl
        >
    implements _$$EmailVerificationSendEmailImplCopyWith<$Res> {
  __$$EmailVerificationSendEmailImplCopyWithImpl(
    _$EmailVerificationSendEmailImpl _value,
    $Res Function(_$EmailVerificationSendEmailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmailVerificationEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$EmailVerificationSendEmailImpl implements EmailVerificationSendEmail {
  const _$EmailVerificationSendEmailImpl();

  @override
  String toString() {
    return 'EmailVerificationEvent.sendVerificationEmail()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailVerificationSendEmailImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkStatus,
    required TResult Function() sendVerificationEmail,
    required TResult Function() refreshStatus,
    required TResult Function() resetError,
    required TResult Function(bool isVerified, DateTime? verifiedAt)
    authStateChanged,
  }) {
    return sendVerificationEmail();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkStatus,
    TResult? Function()? sendVerificationEmail,
    TResult? Function()? refreshStatus,
    TResult? Function()? resetError,
    TResult? Function(bool isVerified, DateTime? verifiedAt)? authStateChanged,
  }) {
    return sendVerificationEmail?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkStatus,
    TResult Function()? sendVerificationEmail,
    TResult Function()? refreshStatus,
    TResult Function()? resetError,
    TResult Function(bool isVerified, DateTime? verifiedAt)? authStateChanged,
    required TResult orElse(),
  }) {
    if (sendVerificationEmail != null) {
      return sendVerificationEmail();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmailVerificationCheckStatus value) checkStatus,
    required TResult Function(EmailVerificationSendEmail value)
    sendVerificationEmail,
    required TResult Function(EmailVerificationRefreshStatus value)
    refreshStatus,
    required TResult Function(EmailVerificationResetError value) resetError,
    required TResult Function(EmailVerificationAuthStateChanged value)
    authStateChanged,
  }) {
    return sendVerificationEmail(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmailVerificationCheckStatus value)? checkStatus,
    TResult? Function(EmailVerificationSendEmail value)? sendVerificationEmail,
    TResult? Function(EmailVerificationRefreshStatus value)? refreshStatus,
    TResult? Function(EmailVerificationResetError value)? resetError,
    TResult? Function(EmailVerificationAuthStateChanged value)?
    authStateChanged,
  }) {
    return sendVerificationEmail?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmailVerificationCheckStatus value)? checkStatus,
    TResult Function(EmailVerificationSendEmail value)? sendVerificationEmail,
    TResult Function(EmailVerificationRefreshStatus value)? refreshStatus,
    TResult Function(EmailVerificationResetError value)? resetError,
    TResult Function(EmailVerificationAuthStateChanged value)? authStateChanged,
    required TResult orElse(),
  }) {
    if (sendVerificationEmail != null) {
      return sendVerificationEmail(this);
    }
    return orElse();
  }
}

abstract class EmailVerificationSendEmail implements EmailVerificationEvent {
  const factory EmailVerificationSendEmail() = _$EmailVerificationSendEmailImpl;
}

/// @nodoc
abstract class _$$EmailVerificationRefreshStatusImplCopyWith<$Res> {
  factory _$$EmailVerificationRefreshStatusImplCopyWith(
    _$EmailVerificationRefreshStatusImpl value,
    $Res Function(_$EmailVerificationRefreshStatusImpl) then,
  ) = __$$EmailVerificationRefreshStatusImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EmailVerificationRefreshStatusImplCopyWithImpl<$Res>
    extends
        _$EmailVerificationEventCopyWithImpl<
          $Res,
          _$EmailVerificationRefreshStatusImpl
        >
    implements _$$EmailVerificationRefreshStatusImplCopyWith<$Res> {
  __$$EmailVerificationRefreshStatusImplCopyWithImpl(
    _$EmailVerificationRefreshStatusImpl _value,
    $Res Function(_$EmailVerificationRefreshStatusImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmailVerificationEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$EmailVerificationRefreshStatusImpl
    implements EmailVerificationRefreshStatus {
  const _$EmailVerificationRefreshStatusImpl();

  @override
  String toString() {
    return 'EmailVerificationEvent.refreshStatus()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailVerificationRefreshStatusImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkStatus,
    required TResult Function() sendVerificationEmail,
    required TResult Function() refreshStatus,
    required TResult Function() resetError,
    required TResult Function(bool isVerified, DateTime? verifiedAt)
    authStateChanged,
  }) {
    return refreshStatus();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkStatus,
    TResult? Function()? sendVerificationEmail,
    TResult? Function()? refreshStatus,
    TResult? Function()? resetError,
    TResult? Function(bool isVerified, DateTime? verifiedAt)? authStateChanged,
  }) {
    return refreshStatus?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkStatus,
    TResult Function()? sendVerificationEmail,
    TResult Function()? refreshStatus,
    TResult Function()? resetError,
    TResult Function(bool isVerified, DateTime? verifiedAt)? authStateChanged,
    required TResult orElse(),
  }) {
    if (refreshStatus != null) {
      return refreshStatus();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmailVerificationCheckStatus value) checkStatus,
    required TResult Function(EmailVerificationSendEmail value)
    sendVerificationEmail,
    required TResult Function(EmailVerificationRefreshStatus value)
    refreshStatus,
    required TResult Function(EmailVerificationResetError value) resetError,
    required TResult Function(EmailVerificationAuthStateChanged value)
    authStateChanged,
  }) {
    return refreshStatus(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmailVerificationCheckStatus value)? checkStatus,
    TResult? Function(EmailVerificationSendEmail value)? sendVerificationEmail,
    TResult? Function(EmailVerificationRefreshStatus value)? refreshStatus,
    TResult? Function(EmailVerificationResetError value)? resetError,
    TResult? Function(EmailVerificationAuthStateChanged value)?
    authStateChanged,
  }) {
    return refreshStatus?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmailVerificationCheckStatus value)? checkStatus,
    TResult Function(EmailVerificationSendEmail value)? sendVerificationEmail,
    TResult Function(EmailVerificationRefreshStatus value)? refreshStatus,
    TResult Function(EmailVerificationResetError value)? resetError,
    TResult Function(EmailVerificationAuthStateChanged value)? authStateChanged,
    required TResult orElse(),
  }) {
    if (refreshStatus != null) {
      return refreshStatus(this);
    }
    return orElse();
  }
}

abstract class EmailVerificationRefreshStatus
    implements EmailVerificationEvent {
  const factory EmailVerificationRefreshStatus() =
      _$EmailVerificationRefreshStatusImpl;
}

/// @nodoc
abstract class _$$EmailVerificationResetErrorImplCopyWith<$Res> {
  factory _$$EmailVerificationResetErrorImplCopyWith(
    _$EmailVerificationResetErrorImpl value,
    $Res Function(_$EmailVerificationResetErrorImpl) then,
  ) = __$$EmailVerificationResetErrorImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EmailVerificationResetErrorImplCopyWithImpl<$Res>
    extends
        _$EmailVerificationEventCopyWithImpl<
          $Res,
          _$EmailVerificationResetErrorImpl
        >
    implements _$$EmailVerificationResetErrorImplCopyWith<$Res> {
  __$$EmailVerificationResetErrorImplCopyWithImpl(
    _$EmailVerificationResetErrorImpl _value,
    $Res Function(_$EmailVerificationResetErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmailVerificationEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$EmailVerificationResetErrorImpl implements EmailVerificationResetError {
  const _$EmailVerificationResetErrorImpl();

  @override
  String toString() {
    return 'EmailVerificationEvent.resetError()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailVerificationResetErrorImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkStatus,
    required TResult Function() sendVerificationEmail,
    required TResult Function() refreshStatus,
    required TResult Function() resetError,
    required TResult Function(bool isVerified, DateTime? verifiedAt)
    authStateChanged,
  }) {
    return resetError();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkStatus,
    TResult? Function()? sendVerificationEmail,
    TResult? Function()? refreshStatus,
    TResult? Function()? resetError,
    TResult? Function(bool isVerified, DateTime? verifiedAt)? authStateChanged,
  }) {
    return resetError?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkStatus,
    TResult Function()? sendVerificationEmail,
    TResult Function()? refreshStatus,
    TResult Function()? resetError,
    TResult Function(bool isVerified, DateTime? verifiedAt)? authStateChanged,
    required TResult orElse(),
  }) {
    if (resetError != null) {
      return resetError();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmailVerificationCheckStatus value) checkStatus,
    required TResult Function(EmailVerificationSendEmail value)
    sendVerificationEmail,
    required TResult Function(EmailVerificationRefreshStatus value)
    refreshStatus,
    required TResult Function(EmailVerificationResetError value) resetError,
    required TResult Function(EmailVerificationAuthStateChanged value)
    authStateChanged,
  }) {
    return resetError(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmailVerificationCheckStatus value)? checkStatus,
    TResult? Function(EmailVerificationSendEmail value)? sendVerificationEmail,
    TResult? Function(EmailVerificationRefreshStatus value)? refreshStatus,
    TResult? Function(EmailVerificationResetError value)? resetError,
    TResult? Function(EmailVerificationAuthStateChanged value)?
    authStateChanged,
  }) {
    return resetError?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmailVerificationCheckStatus value)? checkStatus,
    TResult Function(EmailVerificationSendEmail value)? sendVerificationEmail,
    TResult Function(EmailVerificationRefreshStatus value)? refreshStatus,
    TResult Function(EmailVerificationResetError value)? resetError,
    TResult Function(EmailVerificationAuthStateChanged value)? authStateChanged,
    required TResult orElse(),
  }) {
    if (resetError != null) {
      return resetError(this);
    }
    return orElse();
  }
}

abstract class EmailVerificationResetError implements EmailVerificationEvent {
  const factory EmailVerificationResetError() =
      _$EmailVerificationResetErrorImpl;
}

/// @nodoc
abstract class _$$EmailVerificationAuthStateChangedImplCopyWith<$Res> {
  factory _$$EmailVerificationAuthStateChangedImplCopyWith(
    _$EmailVerificationAuthStateChangedImpl value,
    $Res Function(_$EmailVerificationAuthStateChangedImpl) then,
  ) = __$$EmailVerificationAuthStateChangedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({bool isVerified, DateTime? verifiedAt});
}

/// @nodoc
class __$$EmailVerificationAuthStateChangedImplCopyWithImpl<$Res>
    extends
        _$EmailVerificationEventCopyWithImpl<
          $Res,
          _$EmailVerificationAuthStateChangedImpl
        >
    implements _$$EmailVerificationAuthStateChangedImplCopyWith<$Res> {
  __$$EmailVerificationAuthStateChangedImplCopyWithImpl(
    _$EmailVerificationAuthStateChangedImpl _value,
    $Res Function(_$EmailVerificationAuthStateChangedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmailVerificationEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? isVerified = null, Object? verifiedAt = freezed}) {
    return _then(
      _$EmailVerificationAuthStateChangedImpl(
        isVerified: null == isVerified
            ? _value.isVerified
            : isVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
        verifiedAt: freezed == verifiedAt
            ? _value.verifiedAt
            : verifiedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$EmailVerificationAuthStateChangedImpl
    implements EmailVerificationAuthStateChanged {
  const _$EmailVerificationAuthStateChangedImpl({
    required this.isVerified,
    this.verifiedAt,
  });

  @override
  final bool isVerified;
  @override
  final DateTime? verifiedAt;

  @override
  String toString() {
    return 'EmailVerificationEvent.authStateChanged(isVerified: $isVerified, verifiedAt: $verifiedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailVerificationAuthStateChangedImpl &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.verifiedAt, verifiedAt) ||
                other.verifiedAt == verifiedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isVerified, verifiedAt);

  /// Create a copy of EmailVerificationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmailVerificationAuthStateChangedImplCopyWith<
    _$EmailVerificationAuthStateChangedImpl
  >
  get copyWith =>
      __$$EmailVerificationAuthStateChangedImplCopyWithImpl<
        _$EmailVerificationAuthStateChangedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() checkStatus,
    required TResult Function() sendVerificationEmail,
    required TResult Function() refreshStatus,
    required TResult Function() resetError,
    required TResult Function(bool isVerified, DateTime? verifiedAt)
    authStateChanged,
  }) {
    return authStateChanged(isVerified, verifiedAt);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? checkStatus,
    TResult? Function()? sendVerificationEmail,
    TResult? Function()? refreshStatus,
    TResult? Function()? resetError,
    TResult? Function(bool isVerified, DateTime? verifiedAt)? authStateChanged,
  }) {
    return authStateChanged?.call(isVerified, verifiedAt);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? checkStatus,
    TResult Function()? sendVerificationEmail,
    TResult Function()? refreshStatus,
    TResult Function()? resetError,
    TResult Function(bool isVerified, DateTime? verifiedAt)? authStateChanged,
    required TResult orElse(),
  }) {
    if (authStateChanged != null) {
      return authStateChanged(isVerified, verifiedAt);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmailVerificationCheckStatus value) checkStatus,
    required TResult Function(EmailVerificationSendEmail value)
    sendVerificationEmail,
    required TResult Function(EmailVerificationRefreshStatus value)
    refreshStatus,
    required TResult Function(EmailVerificationResetError value) resetError,
    required TResult Function(EmailVerificationAuthStateChanged value)
    authStateChanged,
  }) {
    return authStateChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmailVerificationCheckStatus value)? checkStatus,
    TResult? Function(EmailVerificationSendEmail value)? sendVerificationEmail,
    TResult? Function(EmailVerificationRefreshStatus value)? refreshStatus,
    TResult? Function(EmailVerificationResetError value)? resetError,
    TResult? Function(EmailVerificationAuthStateChanged value)?
    authStateChanged,
  }) {
    return authStateChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmailVerificationCheckStatus value)? checkStatus,
    TResult Function(EmailVerificationSendEmail value)? sendVerificationEmail,
    TResult Function(EmailVerificationRefreshStatus value)? refreshStatus,
    TResult Function(EmailVerificationResetError value)? resetError,
    TResult Function(EmailVerificationAuthStateChanged value)? authStateChanged,
    required TResult orElse(),
  }) {
    if (authStateChanged != null) {
      return authStateChanged(this);
    }
    return orElse();
  }
}

abstract class EmailVerificationAuthStateChanged
    implements EmailVerificationEvent {
  const factory EmailVerificationAuthStateChanged({
    required final bool isVerified,
    final DateTime? verifiedAt,
  }) = _$EmailVerificationAuthStateChangedImpl;

  bool get isVerified;
  DateTime? get verifiedAt;

  /// Create a copy of EmailVerificationEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmailVerificationAuthStateChangedImplCopyWith<
    _$EmailVerificationAuthStateChangedImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
