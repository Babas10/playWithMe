// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'email_verification_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$EmailVerificationState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DateTime? verifiedAt) verified,
    required TResult Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )
    pending,
    required TResult Function(String message, String? email, bool? wasVerified)
    error,
    required TResult Function(
      String email,
      DateTime sentAt,
      int resendCooldownSeconds,
    )
    emailSent,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DateTime? verifiedAt)? verified,
    TResult? Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )?
    pending,
    TResult? Function(String message, String? email, bool? wasVerified)? error,
    TResult? Function(String email, DateTime sentAt, int resendCooldownSeconds)?
    emailSent,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DateTime? verifiedAt)? verified,
    TResult Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )?
    pending,
    TResult Function(String message, String? email, bool? wasVerified)? error,
    TResult Function(String email, DateTime sentAt, int resendCooldownSeconds)?
    emailSent,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmailVerificationInitial value) initial,
    required TResult Function(EmailVerificationLoading value) loading,
    required TResult Function(EmailVerificationVerified value) verified,
    required TResult Function(EmailVerificationPending value) pending,
    required TResult Function(EmailVerificationError value) error,
    required TResult Function(EmailVerificationEmailSent value) emailSent,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmailVerificationInitial value)? initial,
    TResult? Function(EmailVerificationLoading value)? loading,
    TResult? Function(EmailVerificationVerified value)? verified,
    TResult? Function(EmailVerificationPending value)? pending,
    TResult? Function(EmailVerificationError value)? error,
    TResult? Function(EmailVerificationEmailSent value)? emailSent,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmailVerificationInitial value)? initial,
    TResult Function(EmailVerificationLoading value)? loading,
    TResult Function(EmailVerificationVerified value)? verified,
    TResult Function(EmailVerificationPending value)? pending,
    TResult Function(EmailVerificationError value)? error,
    TResult Function(EmailVerificationEmailSent value)? emailSent,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmailVerificationStateCopyWith<$Res> {
  factory $EmailVerificationStateCopyWith(
    EmailVerificationState value,
    $Res Function(EmailVerificationState) then,
  ) = _$EmailVerificationStateCopyWithImpl<$Res, EmailVerificationState>;
}

/// @nodoc
class _$EmailVerificationStateCopyWithImpl<
  $Res,
  $Val extends EmailVerificationState
>
    implements $EmailVerificationStateCopyWith<$Res> {
  _$EmailVerificationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmailVerificationState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$EmailVerificationInitialImplCopyWith<$Res> {
  factory _$$EmailVerificationInitialImplCopyWith(
    _$EmailVerificationInitialImpl value,
    $Res Function(_$EmailVerificationInitialImpl) then,
  ) = __$$EmailVerificationInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EmailVerificationInitialImplCopyWithImpl<$Res>
    extends
        _$EmailVerificationStateCopyWithImpl<
          $Res,
          _$EmailVerificationInitialImpl
        >
    implements _$$EmailVerificationInitialImplCopyWith<$Res> {
  __$$EmailVerificationInitialImplCopyWithImpl(
    _$EmailVerificationInitialImpl _value,
    $Res Function(_$EmailVerificationInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmailVerificationState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$EmailVerificationInitialImpl implements EmailVerificationInitial {
  const _$EmailVerificationInitialImpl();

  @override
  String toString() {
    return 'EmailVerificationState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailVerificationInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DateTime? verifiedAt) verified,
    required TResult Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )
    pending,
    required TResult Function(String message, String? email, bool? wasVerified)
    error,
    required TResult Function(
      String email,
      DateTime sentAt,
      int resendCooldownSeconds,
    )
    emailSent,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DateTime? verifiedAt)? verified,
    TResult? Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )?
    pending,
    TResult? Function(String message, String? email, bool? wasVerified)? error,
    TResult? Function(String email, DateTime sentAt, int resendCooldownSeconds)?
    emailSent,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DateTime? verifiedAt)? verified,
    TResult Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )?
    pending,
    TResult Function(String message, String? email, bool? wasVerified)? error,
    TResult Function(String email, DateTime sentAt, int resendCooldownSeconds)?
    emailSent,
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
    required TResult Function(EmailVerificationInitial value) initial,
    required TResult Function(EmailVerificationLoading value) loading,
    required TResult Function(EmailVerificationVerified value) verified,
    required TResult Function(EmailVerificationPending value) pending,
    required TResult Function(EmailVerificationError value) error,
    required TResult Function(EmailVerificationEmailSent value) emailSent,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmailVerificationInitial value)? initial,
    TResult? Function(EmailVerificationLoading value)? loading,
    TResult? Function(EmailVerificationVerified value)? verified,
    TResult? Function(EmailVerificationPending value)? pending,
    TResult? Function(EmailVerificationError value)? error,
    TResult? Function(EmailVerificationEmailSent value)? emailSent,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmailVerificationInitial value)? initial,
    TResult Function(EmailVerificationLoading value)? loading,
    TResult Function(EmailVerificationVerified value)? verified,
    TResult Function(EmailVerificationPending value)? pending,
    TResult Function(EmailVerificationError value)? error,
    TResult Function(EmailVerificationEmailSent value)? emailSent,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class EmailVerificationInitial implements EmailVerificationState {
  const factory EmailVerificationInitial() = _$EmailVerificationInitialImpl;
}

/// @nodoc
abstract class _$$EmailVerificationLoadingImplCopyWith<$Res> {
  factory _$$EmailVerificationLoadingImplCopyWith(
    _$EmailVerificationLoadingImpl value,
    $Res Function(_$EmailVerificationLoadingImpl) then,
  ) = __$$EmailVerificationLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EmailVerificationLoadingImplCopyWithImpl<$Res>
    extends
        _$EmailVerificationStateCopyWithImpl<
          $Res,
          _$EmailVerificationLoadingImpl
        >
    implements _$$EmailVerificationLoadingImplCopyWith<$Res> {
  __$$EmailVerificationLoadingImplCopyWithImpl(
    _$EmailVerificationLoadingImpl _value,
    $Res Function(_$EmailVerificationLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmailVerificationState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$EmailVerificationLoadingImpl implements EmailVerificationLoading {
  const _$EmailVerificationLoadingImpl();

  @override
  String toString() {
    return 'EmailVerificationState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailVerificationLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DateTime? verifiedAt) verified,
    required TResult Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )
    pending,
    required TResult Function(String message, String? email, bool? wasVerified)
    error,
    required TResult Function(
      String email,
      DateTime sentAt,
      int resendCooldownSeconds,
    )
    emailSent,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DateTime? verifiedAt)? verified,
    TResult? Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )?
    pending,
    TResult? Function(String message, String? email, bool? wasVerified)? error,
    TResult? Function(String email, DateTime sentAt, int resendCooldownSeconds)?
    emailSent,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DateTime? verifiedAt)? verified,
    TResult Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )?
    pending,
    TResult Function(String message, String? email, bool? wasVerified)? error,
    TResult Function(String email, DateTime sentAt, int resendCooldownSeconds)?
    emailSent,
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
    required TResult Function(EmailVerificationInitial value) initial,
    required TResult Function(EmailVerificationLoading value) loading,
    required TResult Function(EmailVerificationVerified value) verified,
    required TResult Function(EmailVerificationPending value) pending,
    required TResult Function(EmailVerificationError value) error,
    required TResult Function(EmailVerificationEmailSent value) emailSent,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmailVerificationInitial value)? initial,
    TResult? Function(EmailVerificationLoading value)? loading,
    TResult? Function(EmailVerificationVerified value)? verified,
    TResult? Function(EmailVerificationPending value)? pending,
    TResult? Function(EmailVerificationError value)? error,
    TResult? Function(EmailVerificationEmailSent value)? emailSent,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmailVerificationInitial value)? initial,
    TResult Function(EmailVerificationLoading value)? loading,
    TResult Function(EmailVerificationVerified value)? verified,
    TResult Function(EmailVerificationPending value)? pending,
    TResult Function(EmailVerificationError value)? error,
    TResult Function(EmailVerificationEmailSent value)? emailSent,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class EmailVerificationLoading implements EmailVerificationState {
  const factory EmailVerificationLoading() = _$EmailVerificationLoadingImpl;
}

/// @nodoc
abstract class _$$EmailVerificationVerifiedImplCopyWith<$Res> {
  factory _$$EmailVerificationVerifiedImplCopyWith(
    _$EmailVerificationVerifiedImpl value,
    $Res Function(_$EmailVerificationVerifiedImpl) then,
  ) = __$$EmailVerificationVerifiedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({DateTime? verifiedAt});
}

/// @nodoc
class __$$EmailVerificationVerifiedImplCopyWithImpl<$Res>
    extends
        _$EmailVerificationStateCopyWithImpl<
          $Res,
          _$EmailVerificationVerifiedImpl
        >
    implements _$$EmailVerificationVerifiedImplCopyWith<$Res> {
  __$$EmailVerificationVerifiedImplCopyWithImpl(
    _$EmailVerificationVerifiedImpl _value,
    $Res Function(_$EmailVerificationVerifiedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmailVerificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? verifiedAt = freezed}) {
    return _then(
      _$EmailVerificationVerifiedImpl(
        verifiedAt: freezed == verifiedAt
            ? _value.verifiedAt
            : verifiedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$EmailVerificationVerifiedImpl implements EmailVerificationVerified {
  const _$EmailVerificationVerifiedImpl({required this.verifiedAt});

  @override
  final DateTime? verifiedAt;

  @override
  String toString() {
    return 'EmailVerificationState.verified(verifiedAt: $verifiedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailVerificationVerifiedImpl &&
            (identical(other.verifiedAt, verifiedAt) ||
                other.verifiedAt == verifiedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, verifiedAt);

  /// Create a copy of EmailVerificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmailVerificationVerifiedImplCopyWith<_$EmailVerificationVerifiedImpl>
  get copyWith =>
      __$$EmailVerificationVerifiedImplCopyWithImpl<
        _$EmailVerificationVerifiedImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DateTime? verifiedAt) verified,
    required TResult Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )
    pending,
    required TResult Function(String message, String? email, bool? wasVerified)
    error,
    required TResult Function(
      String email,
      DateTime sentAt,
      int resendCooldownSeconds,
    )
    emailSent,
  }) {
    return verified(verifiedAt);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DateTime? verifiedAt)? verified,
    TResult? Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )?
    pending,
    TResult? Function(String message, String? email, bool? wasVerified)? error,
    TResult? Function(String email, DateTime sentAt, int resendCooldownSeconds)?
    emailSent,
  }) {
    return verified?.call(verifiedAt);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DateTime? verifiedAt)? verified,
    TResult Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )?
    pending,
    TResult Function(String message, String? email, bool? wasVerified)? error,
    TResult Function(String email, DateTime sentAt, int resendCooldownSeconds)?
    emailSent,
    required TResult orElse(),
  }) {
    if (verified != null) {
      return verified(verifiedAt);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmailVerificationInitial value) initial,
    required TResult Function(EmailVerificationLoading value) loading,
    required TResult Function(EmailVerificationVerified value) verified,
    required TResult Function(EmailVerificationPending value) pending,
    required TResult Function(EmailVerificationError value) error,
    required TResult Function(EmailVerificationEmailSent value) emailSent,
  }) {
    return verified(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmailVerificationInitial value)? initial,
    TResult? Function(EmailVerificationLoading value)? loading,
    TResult? Function(EmailVerificationVerified value)? verified,
    TResult? Function(EmailVerificationPending value)? pending,
    TResult? Function(EmailVerificationError value)? error,
    TResult? Function(EmailVerificationEmailSent value)? emailSent,
  }) {
    return verified?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmailVerificationInitial value)? initial,
    TResult Function(EmailVerificationLoading value)? loading,
    TResult Function(EmailVerificationVerified value)? verified,
    TResult Function(EmailVerificationPending value)? pending,
    TResult Function(EmailVerificationError value)? error,
    TResult Function(EmailVerificationEmailSent value)? emailSent,
    required TResult orElse(),
  }) {
    if (verified != null) {
      return verified(this);
    }
    return orElse();
  }
}

abstract class EmailVerificationVerified implements EmailVerificationState {
  const factory EmailVerificationVerified({
    required final DateTime? verifiedAt,
  }) = _$EmailVerificationVerifiedImpl;

  DateTime? get verifiedAt;

  /// Create a copy of EmailVerificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmailVerificationVerifiedImplCopyWith<_$EmailVerificationVerifiedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EmailVerificationPendingImplCopyWith<$Res> {
  factory _$$EmailVerificationPendingImplCopyWith(
    _$EmailVerificationPendingImpl value,
    $Res Function(_$EmailVerificationPendingImpl) then,
  ) = __$$EmailVerificationPendingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String email,
    bool emailSent,
    DateTime? lastSentAt,
    int resendCooldownSeconds,
  });
}

/// @nodoc
class __$$EmailVerificationPendingImplCopyWithImpl<$Res>
    extends
        _$EmailVerificationStateCopyWithImpl<
          $Res,
          _$EmailVerificationPendingImpl
        >
    implements _$$EmailVerificationPendingImplCopyWith<$Res> {
  __$$EmailVerificationPendingImplCopyWithImpl(
    _$EmailVerificationPendingImpl _value,
    $Res Function(_$EmailVerificationPendingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmailVerificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? emailSent = null,
    Object? lastSentAt = freezed,
    Object? resendCooldownSeconds = null,
  }) {
    return _then(
      _$EmailVerificationPendingImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        emailSent: null == emailSent
            ? _value.emailSent
            : emailSent // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastSentAt: freezed == lastSentAt
            ? _value.lastSentAt
            : lastSentAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        resendCooldownSeconds: null == resendCooldownSeconds
            ? _value.resendCooldownSeconds
            : resendCooldownSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$EmailVerificationPendingImpl implements EmailVerificationPending {
  const _$EmailVerificationPendingImpl({
    required this.email,
    required this.emailSent,
    required this.lastSentAt,
    required this.resendCooldownSeconds,
  });

  @override
  final String email;
  @override
  final bool emailSent;
  @override
  final DateTime? lastSentAt;
  @override
  final int resendCooldownSeconds;

  @override
  String toString() {
    return 'EmailVerificationState.pending(email: $email, emailSent: $emailSent, lastSentAt: $lastSentAt, resendCooldownSeconds: $resendCooldownSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailVerificationPendingImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.emailSent, emailSent) ||
                other.emailSent == emailSent) &&
            (identical(other.lastSentAt, lastSentAt) ||
                other.lastSentAt == lastSentAt) &&
            (identical(other.resendCooldownSeconds, resendCooldownSeconds) ||
                other.resendCooldownSeconds == resendCooldownSeconds));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    email,
    emailSent,
    lastSentAt,
    resendCooldownSeconds,
  );

  /// Create a copy of EmailVerificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmailVerificationPendingImplCopyWith<_$EmailVerificationPendingImpl>
  get copyWith =>
      __$$EmailVerificationPendingImplCopyWithImpl<
        _$EmailVerificationPendingImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DateTime? verifiedAt) verified,
    required TResult Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )
    pending,
    required TResult Function(String message, String? email, bool? wasVerified)
    error,
    required TResult Function(
      String email,
      DateTime sentAt,
      int resendCooldownSeconds,
    )
    emailSent,
  }) {
    return pending(email, this.emailSent, lastSentAt, resendCooldownSeconds);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DateTime? verifiedAt)? verified,
    TResult? Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )?
    pending,
    TResult? Function(String message, String? email, bool? wasVerified)? error,
    TResult? Function(String email, DateTime sentAt, int resendCooldownSeconds)?
    emailSent,
  }) {
    return pending?.call(
      email,
      this.emailSent,
      lastSentAt,
      resendCooldownSeconds,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DateTime? verifiedAt)? verified,
    TResult Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )?
    pending,
    TResult Function(String message, String? email, bool? wasVerified)? error,
    TResult Function(String email, DateTime sentAt, int resendCooldownSeconds)?
    emailSent,
    required TResult orElse(),
  }) {
    if (pending != null) {
      return pending(email, this.emailSent, lastSentAt, resendCooldownSeconds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmailVerificationInitial value) initial,
    required TResult Function(EmailVerificationLoading value) loading,
    required TResult Function(EmailVerificationVerified value) verified,
    required TResult Function(EmailVerificationPending value) pending,
    required TResult Function(EmailVerificationError value) error,
    required TResult Function(EmailVerificationEmailSent value) emailSent,
  }) {
    return pending(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmailVerificationInitial value)? initial,
    TResult? Function(EmailVerificationLoading value)? loading,
    TResult? Function(EmailVerificationVerified value)? verified,
    TResult? Function(EmailVerificationPending value)? pending,
    TResult? Function(EmailVerificationError value)? error,
    TResult? Function(EmailVerificationEmailSent value)? emailSent,
  }) {
    return pending?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmailVerificationInitial value)? initial,
    TResult Function(EmailVerificationLoading value)? loading,
    TResult Function(EmailVerificationVerified value)? verified,
    TResult Function(EmailVerificationPending value)? pending,
    TResult Function(EmailVerificationError value)? error,
    TResult Function(EmailVerificationEmailSent value)? emailSent,
    required TResult orElse(),
  }) {
    if (pending != null) {
      return pending(this);
    }
    return orElse();
  }
}

abstract class EmailVerificationPending implements EmailVerificationState {
  const factory EmailVerificationPending({
    required final String email,
    required final bool emailSent,
    required final DateTime? lastSentAt,
    required final int resendCooldownSeconds,
  }) = _$EmailVerificationPendingImpl;

  String get email;
  bool get emailSent;
  DateTime? get lastSentAt;
  int get resendCooldownSeconds;

  /// Create a copy of EmailVerificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmailVerificationPendingImplCopyWith<_$EmailVerificationPendingImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EmailVerificationErrorImplCopyWith<$Res> {
  factory _$$EmailVerificationErrorImplCopyWith(
    _$EmailVerificationErrorImpl value,
    $Res Function(_$EmailVerificationErrorImpl) then,
  ) = __$$EmailVerificationErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, String? email, bool? wasVerified});
}

/// @nodoc
class __$$EmailVerificationErrorImplCopyWithImpl<$Res>
    extends
        _$EmailVerificationStateCopyWithImpl<$Res, _$EmailVerificationErrorImpl>
    implements _$$EmailVerificationErrorImplCopyWith<$Res> {
  __$$EmailVerificationErrorImplCopyWithImpl(
    _$EmailVerificationErrorImpl _value,
    $Res Function(_$EmailVerificationErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmailVerificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? email = freezed,
    Object? wasVerified = freezed,
  }) {
    return _then(
      _$EmailVerificationErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        wasVerified: freezed == wasVerified
            ? _value.wasVerified
            : wasVerified // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc

class _$EmailVerificationErrorImpl implements EmailVerificationError {
  const _$EmailVerificationErrorImpl({
    required this.message,
    this.email,
    this.wasVerified,
  });

  @override
  final String message;
  @override
  final String? email;
  @override
  final bool? wasVerified;

  @override
  String toString() {
    return 'EmailVerificationState.error(message: $message, email: $email, wasVerified: $wasVerified)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailVerificationErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.wasVerified, wasVerified) ||
                other.wasVerified == wasVerified));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, email, wasVerified);

  /// Create a copy of EmailVerificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmailVerificationErrorImplCopyWith<_$EmailVerificationErrorImpl>
  get copyWith =>
      __$$EmailVerificationErrorImplCopyWithImpl<_$EmailVerificationErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DateTime? verifiedAt) verified,
    required TResult Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )
    pending,
    required TResult Function(String message, String? email, bool? wasVerified)
    error,
    required TResult Function(
      String email,
      DateTime sentAt,
      int resendCooldownSeconds,
    )
    emailSent,
  }) {
    return error(message, email, wasVerified);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DateTime? verifiedAt)? verified,
    TResult? Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )?
    pending,
    TResult? Function(String message, String? email, bool? wasVerified)? error,
    TResult? Function(String email, DateTime sentAt, int resendCooldownSeconds)?
    emailSent,
  }) {
    return error?.call(message, email, wasVerified);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DateTime? verifiedAt)? verified,
    TResult Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )?
    pending,
    TResult Function(String message, String? email, bool? wasVerified)? error,
    TResult Function(String email, DateTime sentAt, int resendCooldownSeconds)?
    emailSent,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, email, wasVerified);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmailVerificationInitial value) initial,
    required TResult Function(EmailVerificationLoading value) loading,
    required TResult Function(EmailVerificationVerified value) verified,
    required TResult Function(EmailVerificationPending value) pending,
    required TResult Function(EmailVerificationError value) error,
    required TResult Function(EmailVerificationEmailSent value) emailSent,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmailVerificationInitial value)? initial,
    TResult? Function(EmailVerificationLoading value)? loading,
    TResult? Function(EmailVerificationVerified value)? verified,
    TResult? Function(EmailVerificationPending value)? pending,
    TResult? Function(EmailVerificationError value)? error,
    TResult? Function(EmailVerificationEmailSent value)? emailSent,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmailVerificationInitial value)? initial,
    TResult Function(EmailVerificationLoading value)? loading,
    TResult Function(EmailVerificationVerified value)? verified,
    TResult Function(EmailVerificationPending value)? pending,
    TResult Function(EmailVerificationError value)? error,
    TResult Function(EmailVerificationEmailSent value)? emailSent,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class EmailVerificationError implements EmailVerificationState {
  const factory EmailVerificationError({
    required final String message,
    final String? email,
    final bool? wasVerified,
  }) = _$EmailVerificationErrorImpl;

  String get message;
  String? get email;
  bool? get wasVerified;

  /// Create a copy of EmailVerificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmailVerificationErrorImplCopyWith<_$EmailVerificationErrorImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EmailVerificationEmailSentImplCopyWith<$Res> {
  factory _$$EmailVerificationEmailSentImplCopyWith(
    _$EmailVerificationEmailSentImpl value,
    $Res Function(_$EmailVerificationEmailSentImpl) then,
  ) = __$$EmailVerificationEmailSentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String email, DateTime sentAt, int resendCooldownSeconds});
}

/// @nodoc
class __$$EmailVerificationEmailSentImplCopyWithImpl<$Res>
    extends
        _$EmailVerificationStateCopyWithImpl<
          $Res,
          _$EmailVerificationEmailSentImpl
        >
    implements _$$EmailVerificationEmailSentImplCopyWith<$Res> {
  __$$EmailVerificationEmailSentImplCopyWithImpl(
    _$EmailVerificationEmailSentImpl _value,
    $Res Function(_$EmailVerificationEmailSentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EmailVerificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? sentAt = null,
    Object? resendCooldownSeconds = null,
  }) {
    return _then(
      _$EmailVerificationEmailSentImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        sentAt: null == sentAt
            ? _value.sentAt
            : sentAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        resendCooldownSeconds: null == resendCooldownSeconds
            ? _value.resendCooldownSeconds
            : resendCooldownSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$EmailVerificationEmailSentImpl implements EmailVerificationEmailSent {
  const _$EmailVerificationEmailSentImpl({
    required this.email,
    required this.sentAt,
    required this.resendCooldownSeconds,
  });

  @override
  final String email;
  @override
  final DateTime sentAt;
  @override
  final int resendCooldownSeconds;

  @override
  String toString() {
    return 'EmailVerificationState.emailSent(email: $email, sentAt: $sentAt, resendCooldownSeconds: $resendCooldownSeconds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailVerificationEmailSentImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt) &&
            (identical(other.resendCooldownSeconds, resendCooldownSeconds) ||
                other.resendCooldownSeconds == resendCooldownSeconds));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, email, sentAt, resendCooldownSeconds);

  /// Create a copy of EmailVerificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmailVerificationEmailSentImplCopyWith<_$EmailVerificationEmailSentImpl>
  get copyWith =>
      __$$EmailVerificationEmailSentImplCopyWithImpl<
        _$EmailVerificationEmailSentImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(DateTime? verifiedAt) verified,
    required TResult Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )
    pending,
    required TResult Function(String message, String? email, bool? wasVerified)
    error,
    required TResult Function(
      String email,
      DateTime sentAt,
      int resendCooldownSeconds,
    )
    emailSent,
  }) {
    return emailSent(email, sentAt, resendCooldownSeconds);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(DateTime? verifiedAt)? verified,
    TResult? Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )?
    pending,
    TResult? Function(String message, String? email, bool? wasVerified)? error,
    TResult? Function(String email, DateTime sentAt, int resendCooldownSeconds)?
    emailSent,
  }) {
    return emailSent?.call(email, sentAt, resendCooldownSeconds);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(DateTime? verifiedAt)? verified,
    TResult Function(
      String email,
      bool emailSent,
      DateTime? lastSentAt,
      int resendCooldownSeconds,
    )?
    pending,
    TResult Function(String message, String? email, bool? wasVerified)? error,
    TResult Function(String email, DateTime sentAt, int resendCooldownSeconds)?
    emailSent,
    required TResult orElse(),
  }) {
    if (emailSent != null) {
      return emailSent(email, sentAt, resendCooldownSeconds);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EmailVerificationInitial value) initial,
    required TResult Function(EmailVerificationLoading value) loading,
    required TResult Function(EmailVerificationVerified value) verified,
    required TResult Function(EmailVerificationPending value) pending,
    required TResult Function(EmailVerificationError value) error,
    required TResult Function(EmailVerificationEmailSent value) emailSent,
  }) {
    return emailSent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EmailVerificationInitial value)? initial,
    TResult? Function(EmailVerificationLoading value)? loading,
    TResult? Function(EmailVerificationVerified value)? verified,
    TResult? Function(EmailVerificationPending value)? pending,
    TResult? Function(EmailVerificationError value)? error,
    TResult? Function(EmailVerificationEmailSent value)? emailSent,
  }) {
    return emailSent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EmailVerificationInitial value)? initial,
    TResult Function(EmailVerificationLoading value)? loading,
    TResult Function(EmailVerificationVerified value)? verified,
    TResult Function(EmailVerificationPending value)? pending,
    TResult Function(EmailVerificationError value)? error,
    TResult Function(EmailVerificationEmailSent value)? emailSent,
    required TResult orElse(),
  }) {
    if (emailSent != null) {
      return emailSent(this);
    }
    return orElse();
  }
}

abstract class EmailVerificationEmailSent implements EmailVerificationState {
  const factory EmailVerificationEmailSent({
    required final String email,
    required final DateTime sentAt,
    required final int resendCooldownSeconds,
  }) = _$EmailVerificationEmailSentImpl;

  String get email;
  DateTime get sentAt;
  int get resendCooldownSeconds;

  /// Create a copy of EmailVerificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmailVerificationEmailSentImplCopyWith<_$EmailVerificationEmailSentImpl>
  get copyWith => throw _privateConstructorUsedError;
}
