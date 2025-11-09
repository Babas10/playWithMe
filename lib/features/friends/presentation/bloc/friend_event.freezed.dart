// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FriendEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadRequested,
    required TResult Function(String targetUserId) requestSent,
    required TResult Function(String friendshipId) requestAccepted,
    required TResult Function(String friendshipId) requestDeclined,
    required TResult Function(String friendshipId) requestCancelled,
    required TResult Function(String friendshipId) removed,
    required TResult Function(String email) searchRequested,
    required TResult Function() searchCleared,
    required TResult Function(String userId) statusChecked,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadRequested,
    TResult? Function(String targetUserId)? requestSent,
    TResult? Function(String friendshipId)? requestAccepted,
    TResult? Function(String friendshipId)? requestDeclined,
    TResult? Function(String friendshipId)? requestCancelled,
    TResult? Function(String friendshipId)? removed,
    TResult? Function(String email)? searchRequested,
    TResult? Function()? searchCleared,
    TResult? Function(String userId)? statusChecked,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadRequested,
    TResult Function(String targetUserId)? requestSent,
    TResult Function(String friendshipId)? requestAccepted,
    TResult Function(String friendshipId)? requestDeclined,
    TResult Function(String friendshipId)? requestCancelled,
    TResult Function(String friendshipId)? removed,
    TResult Function(String email)? searchRequested,
    TResult Function()? searchCleared,
    TResult Function(String userId)? statusChecked,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendLoadRequested value) loadRequested,
    required TResult Function(FriendRequestSent value) requestSent,
    required TResult Function(FriendRequestAccepted value) requestAccepted,
    required TResult Function(FriendRequestDeclined value) requestDeclined,
    required TResult Function(FriendRequestCancelled value) requestCancelled,
    required TResult Function(FriendRemoved value) removed,
    required TResult Function(FriendSearchRequested value) searchRequested,
    required TResult Function(FriendSearchCleared value) searchCleared,
    required TResult Function(FriendStatusChecked value) statusChecked,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendLoadRequested value)? loadRequested,
    TResult? Function(FriendRequestSent value)? requestSent,
    TResult? Function(FriendRequestAccepted value)? requestAccepted,
    TResult? Function(FriendRequestDeclined value)? requestDeclined,
    TResult? Function(FriendRequestCancelled value)? requestCancelled,
    TResult? Function(FriendRemoved value)? removed,
    TResult? Function(FriendSearchRequested value)? searchRequested,
    TResult? Function(FriendSearchCleared value)? searchCleared,
    TResult? Function(FriendStatusChecked value)? statusChecked,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendLoadRequested value)? loadRequested,
    TResult Function(FriendRequestSent value)? requestSent,
    TResult Function(FriendRequestAccepted value)? requestAccepted,
    TResult Function(FriendRequestDeclined value)? requestDeclined,
    TResult Function(FriendRequestCancelled value)? requestCancelled,
    TResult Function(FriendRemoved value)? removed,
    TResult Function(FriendSearchRequested value)? searchRequested,
    TResult Function(FriendSearchCleared value)? searchCleared,
    TResult Function(FriendStatusChecked value)? statusChecked,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendEventCopyWith<$Res> {
  factory $FriendEventCopyWith(
    FriendEvent value,
    $Res Function(FriendEvent) then,
  ) = _$FriendEventCopyWithImpl<$Res, FriendEvent>;
}

/// @nodoc
class _$FriendEventCopyWithImpl<$Res, $Val extends FriendEvent>
    implements $FriendEventCopyWith<$Res> {
  _$FriendEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$FriendLoadRequestedImplCopyWith<$Res> {
  factory _$$FriendLoadRequestedImplCopyWith(
    _$FriendLoadRequestedImpl value,
    $Res Function(_$FriendLoadRequestedImpl) then,
  ) = __$$FriendLoadRequestedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FriendLoadRequestedImplCopyWithImpl<$Res>
    extends _$FriendEventCopyWithImpl<$Res, _$FriendLoadRequestedImpl>
    implements _$$FriendLoadRequestedImplCopyWith<$Res> {
  __$$FriendLoadRequestedImplCopyWithImpl(
    _$FriendLoadRequestedImpl _value,
    $Res Function(_$FriendLoadRequestedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FriendLoadRequestedImpl implements FriendLoadRequested {
  const _$FriendLoadRequestedImpl();

  @override
  String toString() {
    return 'FriendEvent.loadRequested()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendLoadRequestedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadRequested,
    required TResult Function(String targetUserId) requestSent,
    required TResult Function(String friendshipId) requestAccepted,
    required TResult Function(String friendshipId) requestDeclined,
    required TResult Function(String friendshipId) requestCancelled,
    required TResult Function(String friendshipId) removed,
    required TResult Function(String email) searchRequested,
    required TResult Function() searchCleared,
    required TResult Function(String userId) statusChecked,
  }) {
    return loadRequested();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadRequested,
    TResult? Function(String targetUserId)? requestSent,
    TResult? Function(String friendshipId)? requestAccepted,
    TResult? Function(String friendshipId)? requestDeclined,
    TResult? Function(String friendshipId)? requestCancelled,
    TResult? Function(String friendshipId)? removed,
    TResult? Function(String email)? searchRequested,
    TResult? Function()? searchCleared,
    TResult? Function(String userId)? statusChecked,
  }) {
    return loadRequested?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadRequested,
    TResult Function(String targetUserId)? requestSent,
    TResult Function(String friendshipId)? requestAccepted,
    TResult Function(String friendshipId)? requestDeclined,
    TResult Function(String friendshipId)? requestCancelled,
    TResult Function(String friendshipId)? removed,
    TResult Function(String email)? searchRequested,
    TResult Function()? searchCleared,
    TResult Function(String userId)? statusChecked,
    required TResult orElse(),
  }) {
    if (loadRequested != null) {
      return loadRequested();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendLoadRequested value) loadRequested,
    required TResult Function(FriendRequestSent value) requestSent,
    required TResult Function(FriendRequestAccepted value) requestAccepted,
    required TResult Function(FriendRequestDeclined value) requestDeclined,
    required TResult Function(FriendRequestCancelled value) requestCancelled,
    required TResult Function(FriendRemoved value) removed,
    required TResult Function(FriendSearchRequested value) searchRequested,
    required TResult Function(FriendSearchCleared value) searchCleared,
    required TResult Function(FriendStatusChecked value) statusChecked,
  }) {
    return loadRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendLoadRequested value)? loadRequested,
    TResult? Function(FriendRequestSent value)? requestSent,
    TResult? Function(FriendRequestAccepted value)? requestAccepted,
    TResult? Function(FriendRequestDeclined value)? requestDeclined,
    TResult? Function(FriendRequestCancelled value)? requestCancelled,
    TResult? Function(FriendRemoved value)? removed,
    TResult? Function(FriendSearchRequested value)? searchRequested,
    TResult? Function(FriendSearchCleared value)? searchCleared,
    TResult? Function(FriendStatusChecked value)? statusChecked,
  }) {
    return loadRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendLoadRequested value)? loadRequested,
    TResult Function(FriendRequestSent value)? requestSent,
    TResult Function(FriendRequestAccepted value)? requestAccepted,
    TResult Function(FriendRequestDeclined value)? requestDeclined,
    TResult Function(FriendRequestCancelled value)? requestCancelled,
    TResult Function(FriendRemoved value)? removed,
    TResult Function(FriendSearchRequested value)? searchRequested,
    TResult Function(FriendSearchCleared value)? searchCleared,
    TResult Function(FriendStatusChecked value)? statusChecked,
    required TResult orElse(),
  }) {
    if (loadRequested != null) {
      return loadRequested(this);
    }
    return orElse();
  }
}

abstract class FriendLoadRequested implements FriendEvent {
  const factory FriendLoadRequested() = _$FriendLoadRequestedImpl;
}

/// @nodoc
abstract class _$$FriendRequestSentImplCopyWith<$Res> {
  factory _$$FriendRequestSentImplCopyWith(
    _$FriendRequestSentImpl value,
    $Res Function(_$FriendRequestSentImpl) then,
  ) = __$$FriendRequestSentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String targetUserId});
}

/// @nodoc
class __$$FriendRequestSentImplCopyWithImpl<$Res>
    extends _$FriendEventCopyWithImpl<$Res, _$FriendRequestSentImpl>
    implements _$$FriendRequestSentImplCopyWith<$Res> {
  __$$FriendRequestSentImplCopyWithImpl(
    _$FriendRequestSentImpl _value,
    $Res Function(_$FriendRequestSentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? targetUserId = null}) {
    return _then(
      _$FriendRequestSentImpl(
        targetUserId: null == targetUserId
            ? _value.targetUserId
            : targetUserId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FriendRequestSentImpl implements FriendRequestSent {
  const _$FriendRequestSentImpl({required this.targetUserId});

  @override
  final String targetUserId;

  @override
  String toString() {
    return 'FriendEvent.requestSent(targetUserId: $targetUserId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendRequestSentImpl &&
            (identical(other.targetUserId, targetUserId) ||
                other.targetUserId == targetUserId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, targetUserId);

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendRequestSentImplCopyWith<_$FriendRequestSentImpl> get copyWith =>
      __$$FriendRequestSentImplCopyWithImpl<_$FriendRequestSentImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadRequested,
    required TResult Function(String targetUserId) requestSent,
    required TResult Function(String friendshipId) requestAccepted,
    required TResult Function(String friendshipId) requestDeclined,
    required TResult Function(String friendshipId) requestCancelled,
    required TResult Function(String friendshipId) removed,
    required TResult Function(String email) searchRequested,
    required TResult Function() searchCleared,
    required TResult Function(String userId) statusChecked,
  }) {
    return requestSent(targetUserId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadRequested,
    TResult? Function(String targetUserId)? requestSent,
    TResult? Function(String friendshipId)? requestAccepted,
    TResult? Function(String friendshipId)? requestDeclined,
    TResult? Function(String friendshipId)? requestCancelled,
    TResult? Function(String friendshipId)? removed,
    TResult? Function(String email)? searchRequested,
    TResult? Function()? searchCleared,
    TResult? Function(String userId)? statusChecked,
  }) {
    return requestSent?.call(targetUserId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadRequested,
    TResult Function(String targetUserId)? requestSent,
    TResult Function(String friendshipId)? requestAccepted,
    TResult Function(String friendshipId)? requestDeclined,
    TResult Function(String friendshipId)? requestCancelled,
    TResult Function(String friendshipId)? removed,
    TResult Function(String email)? searchRequested,
    TResult Function()? searchCleared,
    TResult Function(String userId)? statusChecked,
    required TResult orElse(),
  }) {
    if (requestSent != null) {
      return requestSent(targetUserId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendLoadRequested value) loadRequested,
    required TResult Function(FriendRequestSent value) requestSent,
    required TResult Function(FriendRequestAccepted value) requestAccepted,
    required TResult Function(FriendRequestDeclined value) requestDeclined,
    required TResult Function(FriendRequestCancelled value) requestCancelled,
    required TResult Function(FriendRemoved value) removed,
    required TResult Function(FriendSearchRequested value) searchRequested,
    required TResult Function(FriendSearchCleared value) searchCleared,
    required TResult Function(FriendStatusChecked value) statusChecked,
  }) {
    return requestSent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendLoadRequested value)? loadRequested,
    TResult? Function(FriendRequestSent value)? requestSent,
    TResult? Function(FriendRequestAccepted value)? requestAccepted,
    TResult? Function(FriendRequestDeclined value)? requestDeclined,
    TResult? Function(FriendRequestCancelled value)? requestCancelled,
    TResult? Function(FriendRemoved value)? removed,
    TResult? Function(FriendSearchRequested value)? searchRequested,
    TResult? Function(FriendSearchCleared value)? searchCleared,
    TResult? Function(FriendStatusChecked value)? statusChecked,
  }) {
    return requestSent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendLoadRequested value)? loadRequested,
    TResult Function(FriendRequestSent value)? requestSent,
    TResult Function(FriendRequestAccepted value)? requestAccepted,
    TResult Function(FriendRequestDeclined value)? requestDeclined,
    TResult Function(FriendRequestCancelled value)? requestCancelled,
    TResult Function(FriendRemoved value)? removed,
    TResult Function(FriendSearchRequested value)? searchRequested,
    TResult Function(FriendSearchCleared value)? searchCleared,
    TResult Function(FriendStatusChecked value)? statusChecked,
    required TResult orElse(),
  }) {
    if (requestSent != null) {
      return requestSent(this);
    }
    return orElse();
  }
}

abstract class FriendRequestSent implements FriendEvent {
  const factory FriendRequestSent({required final String targetUserId}) =
      _$FriendRequestSentImpl;

  String get targetUserId;

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendRequestSentImplCopyWith<_$FriendRequestSentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FriendRequestAcceptedImplCopyWith<$Res> {
  factory _$$FriendRequestAcceptedImplCopyWith(
    _$FriendRequestAcceptedImpl value,
    $Res Function(_$FriendRequestAcceptedImpl) then,
  ) = __$$FriendRequestAcceptedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String friendshipId});
}

/// @nodoc
class __$$FriendRequestAcceptedImplCopyWithImpl<$Res>
    extends _$FriendEventCopyWithImpl<$Res, _$FriendRequestAcceptedImpl>
    implements _$$FriendRequestAcceptedImplCopyWith<$Res> {
  __$$FriendRequestAcceptedImplCopyWithImpl(
    _$FriendRequestAcceptedImpl _value,
    $Res Function(_$FriendRequestAcceptedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? friendshipId = null}) {
    return _then(
      _$FriendRequestAcceptedImpl(
        friendshipId: null == friendshipId
            ? _value.friendshipId
            : friendshipId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FriendRequestAcceptedImpl implements FriendRequestAccepted {
  const _$FriendRequestAcceptedImpl({required this.friendshipId});

  @override
  final String friendshipId;

  @override
  String toString() {
    return 'FriendEvent.requestAccepted(friendshipId: $friendshipId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendRequestAcceptedImpl &&
            (identical(other.friendshipId, friendshipId) ||
                other.friendshipId == friendshipId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, friendshipId);

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendRequestAcceptedImplCopyWith<_$FriendRequestAcceptedImpl>
  get copyWith =>
      __$$FriendRequestAcceptedImplCopyWithImpl<_$FriendRequestAcceptedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadRequested,
    required TResult Function(String targetUserId) requestSent,
    required TResult Function(String friendshipId) requestAccepted,
    required TResult Function(String friendshipId) requestDeclined,
    required TResult Function(String friendshipId) requestCancelled,
    required TResult Function(String friendshipId) removed,
    required TResult Function(String email) searchRequested,
    required TResult Function() searchCleared,
    required TResult Function(String userId) statusChecked,
  }) {
    return requestAccepted(friendshipId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadRequested,
    TResult? Function(String targetUserId)? requestSent,
    TResult? Function(String friendshipId)? requestAccepted,
    TResult? Function(String friendshipId)? requestDeclined,
    TResult? Function(String friendshipId)? requestCancelled,
    TResult? Function(String friendshipId)? removed,
    TResult? Function(String email)? searchRequested,
    TResult? Function()? searchCleared,
    TResult? Function(String userId)? statusChecked,
  }) {
    return requestAccepted?.call(friendshipId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadRequested,
    TResult Function(String targetUserId)? requestSent,
    TResult Function(String friendshipId)? requestAccepted,
    TResult Function(String friendshipId)? requestDeclined,
    TResult Function(String friendshipId)? requestCancelled,
    TResult Function(String friendshipId)? removed,
    TResult Function(String email)? searchRequested,
    TResult Function()? searchCleared,
    TResult Function(String userId)? statusChecked,
    required TResult orElse(),
  }) {
    if (requestAccepted != null) {
      return requestAccepted(friendshipId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendLoadRequested value) loadRequested,
    required TResult Function(FriendRequestSent value) requestSent,
    required TResult Function(FriendRequestAccepted value) requestAccepted,
    required TResult Function(FriendRequestDeclined value) requestDeclined,
    required TResult Function(FriendRequestCancelled value) requestCancelled,
    required TResult Function(FriendRemoved value) removed,
    required TResult Function(FriendSearchRequested value) searchRequested,
    required TResult Function(FriendSearchCleared value) searchCleared,
    required TResult Function(FriendStatusChecked value) statusChecked,
  }) {
    return requestAccepted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendLoadRequested value)? loadRequested,
    TResult? Function(FriendRequestSent value)? requestSent,
    TResult? Function(FriendRequestAccepted value)? requestAccepted,
    TResult? Function(FriendRequestDeclined value)? requestDeclined,
    TResult? Function(FriendRequestCancelled value)? requestCancelled,
    TResult? Function(FriendRemoved value)? removed,
    TResult? Function(FriendSearchRequested value)? searchRequested,
    TResult? Function(FriendSearchCleared value)? searchCleared,
    TResult? Function(FriendStatusChecked value)? statusChecked,
  }) {
    return requestAccepted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendLoadRequested value)? loadRequested,
    TResult Function(FriendRequestSent value)? requestSent,
    TResult Function(FriendRequestAccepted value)? requestAccepted,
    TResult Function(FriendRequestDeclined value)? requestDeclined,
    TResult Function(FriendRequestCancelled value)? requestCancelled,
    TResult Function(FriendRemoved value)? removed,
    TResult Function(FriendSearchRequested value)? searchRequested,
    TResult Function(FriendSearchCleared value)? searchCleared,
    TResult Function(FriendStatusChecked value)? statusChecked,
    required TResult orElse(),
  }) {
    if (requestAccepted != null) {
      return requestAccepted(this);
    }
    return orElse();
  }
}

abstract class FriendRequestAccepted implements FriendEvent {
  const factory FriendRequestAccepted({required final String friendshipId}) =
      _$FriendRequestAcceptedImpl;

  String get friendshipId;

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendRequestAcceptedImplCopyWith<_$FriendRequestAcceptedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FriendRequestDeclinedImplCopyWith<$Res> {
  factory _$$FriendRequestDeclinedImplCopyWith(
    _$FriendRequestDeclinedImpl value,
    $Res Function(_$FriendRequestDeclinedImpl) then,
  ) = __$$FriendRequestDeclinedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String friendshipId});
}

/// @nodoc
class __$$FriendRequestDeclinedImplCopyWithImpl<$Res>
    extends _$FriendEventCopyWithImpl<$Res, _$FriendRequestDeclinedImpl>
    implements _$$FriendRequestDeclinedImplCopyWith<$Res> {
  __$$FriendRequestDeclinedImplCopyWithImpl(
    _$FriendRequestDeclinedImpl _value,
    $Res Function(_$FriendRequestDeclinedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? friendshipId = null}) {
    return _then(
      _$FriendRequestDeclinedImpl(
        friendshipId: null == friendshipId
            ? _value.friendshipId
            : friendshipId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FriendRequestDeclinedImpl implements FriendRequestDeclined {
  const _$FriendRequestDeclinedImpl({required this.friendshipId});

  @override
  final String friendshipId;

  @override
  String toString() {
    return 'FriendEvent.requestDeclined(friendshipId: $friendshipId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendRequestDeclinedImpl &&
            (identical(other.friendshipId, friendshipId) ||
                other.friendshipId == friendshipId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, friendshipId);

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendRequestDeclinedImplCopyWith<_$FriendRequestDeclinedImpl>
  get copyWith =>
      __$$FriendRequestDeclinedImplCopyWithImpl<_$FriendRequestDeclinedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadRequested,
    required TResult Function(String targetUserId) requestSent,
    required TResult Function(String friendshipId) requestAccepted,
    required TResult Function(String friendshipId) requestDeclined,
    required TResult Function(String friendshipId) requestCancelled,
    required TResult Function(String friendshipId) removed,
    required TResult Function(String email) searchRequested,
    required TResult Function() searchCleared,
    required TResult Function(String userId) statusChecked,
  }) {
    return requestDeclined(friendshipId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadRequested,
    TResult? Function(String targetUserId)? requestSent,
    TResult? Function(String friendshipId)? requestAccepted,
    TResult? Function(String friendshipId)? requestDeclined,
    TResult? Function(String friendshipId)? requestCancelled,
    TResult? Function(String friendshipId)? removed,
    TResult? Function(String email)? searchRequested,
    TResult? Function()? searchCleared,
    TResult? Function(String userId)? statusChecked,
  }) {
    return requestDeclined?.call(friendshipId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadRequested,
    TResult Function(String targetUserId)? requestSent,
    TResult Function(String friendshipId)? requestAccepted,
    TResult Function(String friendshipId)? requestDeclined,
    TResult Function(String friendshipId)? requestCancelled,
    TResult Function(String friendshipId)? removed,
    TResult Function(String email)? searchRequested,
    TResult Function()? searchCleared,
    TResult Function(String userId)? statusChecked,
    required TResult orElse(),
  }) {
    if (requestDeclined != null) {
      return requestDeclined(friendshipId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendLoadRequested value) loadRequested,
    required TResult Function(FriendRequestSent value) requestSent,
    required TResult Function(FriendRequestAccepted value) requestAccepted,
    required TResult Function(FriendRequestDeclined value) requestDeclined,
    required TResult Function(FriendRequestCancelled value) requestCancelled,
    required TResult Function(FriendRemoved value) removed,
    required TResult Function(FriendSearchRequested value) searchRequested,
    required TResult Function(FriendSearchCleared value) searchCleared,
    required TResult Function(FriendStatusChecked value) statusChecked,
  }) {
    return requestDeclined(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendLoadRequested value)? loadRequested,
    TResult? Function(FriendRequestSent value)? requestSent,
    TResult? Function(FriendRequestAccepted value)? requestAccepted,
    TResult? Function(FriendRequestDeclined value)? requestDeclined,
    TResult? Function(FriendRequestCancelled value)? requestCancelled,
    TResult? Function(FriendRemoved value)? removed,
    TResult? Function(FriendSearchRequested value)? searchRequested,
    TResult? Function(FriendSearchCleared value)? searchCleared,
    TResult? Function(FriendStatusChecked value)? statusChecked,
  }) {
    return requestDeclined?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendLoadRequested value)? loadRequested,
    TResult Function(FriendRequestSent value)? requestSent,
    TResult Function(FriendRequestAccepted value)? requestAccepted,
    TResult Function(FriendRequestDeclined value)? requestDeclined,
    TResult Function(FriendRequestCancelled value)? requestCancelled,
    TResult Function(FriendRemoved value)? removed,
    TResult Function(FriendSearchRequested value)? searchRequested,
    TResult Function(FriendSearchCleared value)? searchCleared,
    TResult Function(FriendStatusChecked value)? statusChecked,
    required TResult orElse(),
  }) {
    if (requestDeclined != null) {
      return requestDeclined(this);
    }
    return orElse();
  }
}

abstract class FriendRequestDeclined implements FriendEvent {
  const factory FriendRequestDeclined({required final String friendshipId}) =
      _$FriendRequestDeclinedImpl;

  String get friendshipId;

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendRequestDeclinedImplCopyWith<_$FriendRequestDeclinedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FriendRequestCancelledImplCopyWith<$Res> {
  factory _$$FriendRequestCancelledImplCopyWith(
    _$FriendRequestCancelledImpl value,
    $Res Function(_$FriendRequestCancelledImpl) then,
  ) = __$$FriendRequestCancelledImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String friendshipId});
}

/// @nodoc
class __$$FriendRequestCancelledImplCopyWithImpl<$Res>
    extends _$FriendEventCopyWithImpl<$Res, _$FriendRequestCancelledImpl>
    implements _$$FriendRequestCancelledImplCopyWith<$Res> {
  __$$FriendRequestCancelledImplCopyWithImpl(
    _$FriendRequestCancelledImpl _value,
    $Res Function(_$FriendRequestCancelledImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? friendshipId = null}) {
    return _then(
      _$FriendRequestCancelledImpl(
        friendshipId: null == friendshipId
            ? _value.friendshipId
            : friendshipId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FriendRequestCancelledImpl implements FriendRequestCancelled {
  const _$FriendRequestCancelledImpl({required this.friendshipId});

  @override
  final String friendshipId;

  @override
  String toString() {
    return 'FriendEvent.requestCancelled(friendshipId: $friendshipId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendRequestCancelledImpl &&
            (identical(other.friendshipId, friendshipId) ||
                other.friendshipId == friendshipId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, friendshipId);

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendRequestCancelledImplCopyWith<_$FriendRequestCancelledImpl>
  get copyWith =>
      __$$FriendRequestCancelledImplCopyWithImpl<_$FriendRequestCancelledImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadRequested,
    required TResult Function(String targetUserId) requestSent,
    required TResult Function(String friendshipId) requestAccepted,
    required TResult Function(String friendshipId) requestDeclined,
    required TResult Function(String friendshipId) requestCancelled,
    required TResult Function(String friendshipId) removed,
    required TResult Function(String email) searchRequested,
    required TResult Function() searchCleared,
    required TResult Function(String userId) statusChecked,
  }) {
    return requestCancelled(friendshipId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadRequested,
    TResult? Function(String targetUserId)? requestSent,
    TResult? Function(String friendshipId)? requestAccepted,
    TResult? Function(String friendshipId)? requestDeclined,
    TResult? Function(String friendshipId)? requestCancelled,
    TResult? Function(String friendshipId)? removed,
    TResult? Function(String email)? searchRequested,
    TResult? Function()? searchCleared,
    TResult? Function(String userId)? statusChecked,
  }) {
    return requestCancelled?.call(friendshipId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadRequested,
    TResult Function(String targetUserId)? requestSent,
    TResult Function(String friendshipId)? requestAccepted,
    TResult Function(String friendshipId)? requestDeclined,
    TResult Function(String friendshipId)? requestCancelled,
    TResult Function(String friendshipId)? removed,
    TResult Function(String email)? searchRequested,
    TResult Function()? searchCleared,
    TResult Function(String userId)? statusChecked,
    required TResult orElse(),
  }) {
    if (requestCancelled != null) {
      return requestCancelled(friendshipId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendLoadRequested value) loadRequested,
    required TResult Function(FriendRequestSent value) requestSent,
    required TResult Function(FriendRequestAccepted value) requestAccepted,
    required TResult Function(FriendRequestDeclined value) requestDeclined,
    required TResult Function(FriendRequestCancelled value) requestCancelled,
    required TResult Function(FriendRemoved value) removed,
    required TResult Function(FriendSearchRequested value) searchRequested,
    required TResult Function(FriendSearchCleared value) searchCleared,
    required TResult Function(FriendStatusChecked value) statusChecked,
  }) {
    return requestCancelled(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendLoadRequested value)? loadRequested,
    TResult? Function(FriendRequestSent value)? requestSent,
    TResult? Function(FriendRequestAccepted value)? requestAccepted,
    TResult? Function(FriendRequestDeclined value)? requestDeclined,
    TResult? Function(FriendRequestCancelled value)? requestCancelled,
    TResult? Function(FriendRemoved value)? removed,
    TResult? Function(FriendSearchRequested value)? searchRequested,
    TResult? Function(FriendSearchCleared value)? searchCleared,
    TResult? Function(FriendStatusChecked value)? statusChecked,
  }) {
    return requestCancelled?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendLoadRequested value)? loadRequested,
    TResult Function(FriendRequestSent value)? requestSent,
    TResult Function(FriendRequestAccepted value)? requestAccepted,
    TResult Function(FriendRequestDeclined value)? requestDeclined,
    TResult Function(FriendRequestCancelled value)? requestCancelled,
    TResult Function(FriendRemoved value)? removed,
    TResult Function(FriendSearchRequested value)? searchRequested,
    TResult Function(FriendSearchCleared value)? searchCleared,
    TResult Function(FriendStatusChecked value)? statusChecked,
    required TResult orElse(),
  }) {
    if (requestCancelled != null) {
      return requestCancelled(this);
    }
    return orElse();
  }
}

abstract class FriendRequestCancelled implements FriendEvent {
  const factory FriendRequestCancelled({required final String friendshipId}) =
      _$FriendRequestCancelledImpl;

  String get friendshipId;

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendRequestCancelledImplCopyWith<_$FriendRequestCancelledImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FriendRemovedImplCopyWith<$Res> {
  factory _$$FriendRemovedImplCopyWith(
    _$FriendRemovedImpl value,
    $Res Function(_$FriendRemovedImpl) then,
  ) = __$$FriendRemovedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String friendshipId});
}

/// @nodoc
class __$$FriendRemovedImplCopyWithImpl<$Res>
    extends _$FriendEventCopyWithImpl<$Res, _$FriendRemovedImpl>
    implements _$$FriendRemovedImplCopyWith<$Res> {
  __$$FriendRemovedImplCopyWithImpl(
    _$FriendRemovedImpl _value,
    $Res Function(_$FriendRemovedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? friendshipId = null}) {
    return _then(
      _$FriendRemovedImpl(
        friendshipId: null == friendshipId
            ? _value.friendshipId
            : friendshipId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FriendRemovedImpl implements FriendRemoved {
  const _$FriendRemovedImpl({required this.friendshipId});

  @override
  final String friendshipId;

  @override
  String toString() {
    return 'FriendEvent.removed(friendshipId: $friendshipId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendRemovedImpl &&
            (identical(other.friendshipId, friendshipId) ||
                other.friendshipId == friendshipId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, friendshipId);

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendRemovedImplCopyWith<_$FriendRemovedImpl> get copyWith =>
      __$$FriendRemovedImplCopyWithImpl<_$FriendRemovedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadRequested,
    required TResult Function(String targetUserId) requestSent,
    required TResult Function(String friendshipId) requestAccepted,
    required TResult Function(String friendshipId) requestDeclined,
    required TResult Function(String friendshipId) requestCancelled,
    required TResult Function(String friendshipId) removed,
    required TResult Function(String email) searchRequested,
    required TResult Function() searchCleared,
    required TResult Function(String userId) statusChecked,
  }) {
    return removed(friendshipId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadRequested,
    TResult? Function(String targetUserId)? requestSent,
    TResult? Function(String friendshipId)? requestAccepted,
    TResult? Function(String friendshipId)? requestDeclined,
    TResult? Function(String friendshipId)? requestCancelled,
    TResult? Function(String friendshipId)? removed,
    TResult? Function(String email)? searchRequested,
    TResult? Function()? searchCleared,
    TResult? Function(String userId)? statusChecked,
  }) {
    return removed?.call(friendshipId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadRequested,
    TResult Function(String targetUserId)? requestSent,
    TResult Function(String friendshipId)? requestAccepted,
    TResult Function(String friendshipId)? requestDeclined,
    TResult Function(String friendshipId)? requestCancelled,
    TResult Function(String friendshipId)? removed,
    TResult Function(String email)? searchRequested,
    TResult Function()? searchCleared,
    TResult Function(String userId)? statusChecked,
    required TResult orElse(),
  }) {
    if (removed != null) {
      return removed(friendshipId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendLoadRequested value) loadRequested,
    required TResult Function(FriendRequestSent value) requestSent,
    required TResult Function(FriendRequestAccepted value) requestAccepted,
    required TResult Function(FriendRequestDeclined value) requestDeclined,
    required TResult Function(FriendRequestCancelled value) requestCancelled,
    required TResult Function(FriendRemoved value) removed,
    required TResult Function(FriendSearchRequested value) searchRequested,
    required TResult Function(FriendSearchCleared value) searchCleared,
    required TResult Function(FriendStatusChecked value) statusChecked,
  }) {
    return removed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendLoadRequested value)? loadRequested,
    TResult? Function(FriendRequestSent value)? requestSent,
    TResult? Function(FriendRequestAccepted value)? requestAccepted,
    TResult? Function(FriendRequestDeclined value)? requestDeclined,
    TResult? Function(FriendRequestCancelled value)? requestCancelled,
    TResult? Function(FriendRemoved value)? removed,
    TResult? Function(FriendSearchRequested value)? searchRequested,
    TResult? Function(FriendSearchCleared value)? searchCleared,
    TResult? Function(FriendStatusChecked value)? statusChecked,
  }) {
    return removed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendLoadRequested value)? loadRequested,
    TResult Function(FriendRequestSent value)? requestSent,
    TResult Function(FriendRequestAccepted value)? requestAccepted,
    TResult Function(FriendRequestDeclined value)? requestDeclined,
    TResult Function(FriendRequestCancelled value)? requestCancelled,
    TResult Function(FriendRemoved value)? removed,
    TResult Function(FriendSearchRequested value)? searchRequested,
    TResult Function(FriendSearchCleared value)? searchCleared,
    TResult Function(FriendStatusChecked value)? statusChecked,
    required TResult orElse(),
  }) {
    if (removed != null) {
      return removed(this);
    }
    return orElse();
  }
}

abstract class FriendRemoved implements FriendEvent {
  const factory FriendRemoved({required final String friendshipId}) =
      _$FriendRemovedImpl;

  String get friendshipId;

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendRemovedImplCopyWith<_$FriendRemovedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FriendSearchRequestedImplCopyWith<$Res> {
  factory _$$FriendSearchRequestedImplCopyWith(
    _$FriendSearchRequestedImpl value,
    $Res Function(_$FriendSearchRequestedImpl) then,
  ) = __$$FriendSearchRequestedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String email});
}

/// @nodoc
class __$$FriendSearchRequestedImplCopyWithImpl<$Res>
    extends _$FriendEventCopyWithImpl<$Res, _$FriendSearchRequestedImpl>
    implements _$$FriendSearchRequestedImplCopyWith<$Res> {
  __$$FriendSearchRequestedImplCopyWithImpl(
    _$FriendSearchRequestedImpl _value,
    $Res Function(_$FriendSearchRequestedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? email = null}) {
    return _then(
      _$FriendSearchRequestedImpl(
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FriendSearchRequestedImpl implements FriendSearchRequested {
  const _$FriendSearchRequestedImpl({required this.email});

  @override
  final String email;

  @override
  String toString() {
    return 'FriendEvent.searchRequested(email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendSearchRequestedImpl &&
            (identical(other.email, email) || other.email == email));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email);

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendSearchRequestedImplCopyWith<_$FriendSearchRequestedImpl>
  get copyWith =>
      __$$FriendSearchRequestedImplCopyWithImpl<_$FriendSearchRequestedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadRequested,
    required TResult Function(String targetUserId) requestSent,
    required TResult Function(String friendshipId) requestAccepted,
    required TResult Function(String friendshipId) requestDeclined,
    required TResult Function(String friendshipId) requestCancelled,
    required TResult Function(String friendshipId) removed,
    required TResult Function(String email) searchRequested,
    required TResult Function() searchCleared,
    required TResult Function(String userId) statusChecked,
  }) {
    return searchRequested(email);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadRequested,
    TResult? Function(String targetUserId)? requestSent,
    TResult? Function(String friendshipId)? requestAccepted,
    TResult? Function(String friendshipId)? requestDeclined,
    TResult? Function(String friendshipId)? requestCancelled,
    TResult? Function(String friendshipId)? removed,
    TResult? Function(String email)? searchRequested,
    TResult? Function()? searchCleared,
    TResult? Function(String userId)? statusChecked,
  }) {
    return searchRequested?.call(email);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadRequested,
    TResult Function(String targetUserId)? requestSent,
    TResult Function(String friendshipId)? requestAccepted,
    TResult Function(String friendshipId)? requestDeclined,
    TResult Function(String friendshipId)? requestCancelled,
    TResult Function(String friendshipId)? removed,
    TResult Function(String email)? searchRequested,
    TResult Function()? searchCleared,
    TResult Function(String userId)? statusChecked,
    required TResult orElse(),
  }) {
    if (searchRequested != null) {
      return searchRequested(email);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendLoadRequested value) loadRequested,
    required TResult Function(FriendRequestSent value) requestSent,
    required TResult Function(FriendRequestAccepted value) requestAccepted,
    required TResult Function(FriendRequestDeclined value) requestDeclined,
    required TResult Function(FriendRequestCancelled value) requestCancelled,
    required TResult Function(FriendRemoved value) removed,
    required TResult Function(FriendSearchRequested value) searchRequested,
    required TResult Function(FriendSearchCleared value) searchCleared,
    required TResult Function(FriendStatusChecked value) statusChecked,
  }) {
    return searchRequested(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendLoadRequested value)? loadRequested,
    TResult? Function(FriendRequestSent value)? requestSent,
    TResult? Function(FriendRequestAccepted value)? requestAccepted,
    TResult? Function(FriendRequestDeclined value)? requestDeclined,
    TResult? Function(FriendRequestCancelled value)? requestCancelled,
    TResult? Function(FriendRemoved value)? removed,
    TResult? Function(FriendSearchRequested value)? searchRequested,
    TResult? Function(FriendSearchCleared value)? searchCleared,
    TResult? Function(FriendStatusChecked value)? statusChecked,
  }) {
    return searchRequested?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendLoadRequested value)? loadRequested,
    TResult Function(FriendRequestSent value)? requestSent,
    TResult Function(FriendRequestAccepted value)? requestAccepted,
    TResult Function(FriendRequestDeclined value)? requestDeclined,
    TResult Function(FriendRequestCancelled value)? requestCancelled,
    TResult Function(FriendRemoved value)? removed,
    TResult Function(FriendSearchRequested value)? searchRequested,
    TResult Function(FriendSearchCleared value)? searchCleared,
    TResult Function(FriendStatusChecked value)? statusChecked,
    required TResult orElse(),
  }) {
    if (searchRequested != null) {
      return searchRequested(this);
    }
    return orElse();
  }
}

abstract class FriendSearchRequested implements FriendEvent {
  const factory FriendSearchRequested({required final String email}) =
      _$FriendSearchRequestedImpl;

  String get email;

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendSearchRequestedImplCopyWith<_$FriendSearchRequestedImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FriendSearchClearedImplCopyWith<$Res> {
  factory _$$FriendSearchClearedImplCopyWith(
    _$FriendSearchClearedImpl value,
    $Res Function(_$FriendSearchClearedImpl) then,
  ) = __$$FriendSearchClearedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FriendSearchClearedImplCopyWithImpl<$Res>
    extends _$FriendEventCopyWithImpl<$Res, _$FriendSearchClearedImpl>
    implements _$$FriendSearchClearedImplCopyWith<$Res> {
  __$$FriendSearchClearedImplCopyWithImpl(
    _$FriendSearchClearedImpl _value,
    $Res Function(_$FriendSearchClearedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FriendSearchClearedImpl implements FriendSearchCleared {
  const _$FriendSearchClearedImpl();

  @override
  String toString() {
    return 'FriendEvent.searchCleared()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendSearchClearedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadRequested,
    required TResult Function(String targetUserId) requestSent,
    required TResult Function(String friendshipId) requestAccepted,
    required TResult Function(String friendshipId) requestDeclined,
    required TResult Function(String friendshipId) requestCancelled,
    required TResult Function(String friendshipId) removed,
    required TResult Function(String email) searchRequested,
    required TResult Function() searchCleared,
    required TResult Function(String userId) statusChecked,
  }) {
    return searchCleared();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadRequested,
    TResult? Function(String targetUserId)? requestSent,
    TResult? Function(String friendshipId)? requestAccepted,
    TResult? Function(String friendshipId)? requestDeclined,
    TResult? Function(String friendshipId)? requestCancelled,
    TResult? Function(String friendshipId)? removed,
    TResult? Function(String email)? searchRequested,
    TResult? Function()? searchCleared,
    TResult? Function(String userId)? statusChecked,
  }) {
    return searchCleared?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadRequested,
    TResult Function(String targetUserId)? requestSent,
    TResult Function(String friendshipId)? requestAccepted,
    TResult Function(String friendshipId)? requestDeclined,
    TResult Function(String friendshipId)? requestCancelled,
    TResult Function(String friendshipId)? removed,
    TResult Function(String email)? searchRequested,
    TResult Function()? searchCleared,
    TResult Function(String userId)? statusChecked,
    required TResult orElse(),
  }) {
    if (searchCleared != null) {
      return searchCleared();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendLoadRequested value) loadRequested,
    required TResult Function(FriendRequestSent value) requestSent,
    required TResult Function(FriendRequestAccepted value) requestAccepted,
    required TResult Function(FriendRequestDeclined value) requestDeclined,
    required TResult Function(FriendRequestCancelled value) requestCancelled,
    required TResult Function(FriendRemoved value) removed,
    required TResult Function(FriendSearchRequested value) searchRequested,
    required TResult Function(FriendSearchCleared value) searchCleared,
    required TResult Function(FriendStatusChecked value) statusChecked,
  }) {
    return searchCleared(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendLoadRequested value)? loadRequested,
    TResult? Function(FriendRequestSent value)? requestSent,
    TResult? Function(FriendRequestAccepted value)? requestAccepted,
    TResult? Function(FriendRequestDeclined value)? requestDeclined,
    TResult? Function(FriendRequestCancelled value)? requestCancelled,
    TResult? Function(FriendRemoved value)? removed,
    TResult? Function(FriendSearchRequested value)? searchRequested,
    TResult? Function(FriendSearchCleared value)? searchCleared,
    TResult? Function(FriendStatusChecked value)? statusChecked,
  }) {
    return searchCleared?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendLoadRequested value)? loadRequested,
    TResult Function(FriendRequestSent value)? requestSent,
    TResult Function(FriendRequestAccepted value)? requestAccepted,
    TResult Function(FriendRequestDeclined value)? requestDeclined,
    TResult Function(FriendRequestCancelled value)? requestCancelled,
    TResult Function(FriendRemoved value)? removed,
    TResult Function(FriendSearchRequested value)? searchRequested,
    TResult Function(FriendSearchCleared value)? searchCleared,
    TResult Function(FriendStatusChecked value)? statusChecked,
    required TResult orElse(),
  }) {
    if (searchCleared != null) {
      return searchCleared(this);
    }
    return orElse();
  }
}

abstract class FriendSearchCleared implements FriendEvent {
  const factory FriendSearchCleared() = _$FriendSearchClearedImpl;
}

/// @nodoc
abstract class _$$FriendStatusCheckedImplCopyWith<$Res> {
  factory _$$FriendStatusCheckedImplCopyWith(
    _$FriendStatusCheckedImpl value,
    $Res Function(_$FriendStatusCheckedImpl) then,
  ) = __$$FriendStatusCheckedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String userId});
}

/// @nodoc
class __$$FriendStatusCheckedImplCopyWithImpl<$Res>
    extends _$FriendEventCopyWithImpl<$Res, _$FriendStatusCheckedImpl>
    implements _$$FriendStatusCheckedImplCopyWith<$Res> {
  __$$FriendStatusCheckedImplCopyWithImpl(
    _$FriendStatusCheckedImpl _value,
    $Res Function(_$FriendStatusCheckedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null}) {
    return _then(
      _$FriendStatusCheckedImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FriendStatusCheckedImpl implements FriendStatusChecked {
  const _$FriendStatusCheckedImpl({required this.userId});

  @override
  final String userId;

  @override
  String toString() {
    return 'FriendEvent.statusChecked(userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendStatusCheckedImpl &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId);

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendStatusCheckedImplCopyWith<_$FriendStatusCheckedImpl> get copyWith =>
      __$$FriendStatusCheckedImplCopyWithImpl<_$FriendStatusCheckedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadRequested,
    required TResult Function(String targetUserId) requestSent,
    required TResult Function(String friendshipId) requestAccepted,
    required TResult Function(String friendshipId) requestDeclined,
    required TResult Function(String friendshipId) requestCancelled,
    required TResult Function(String friendshipId) removed,
    required TResult Function(String email) searchRequested,
    required TResult Function() searchCleared,
    required TResult Function(String userId) statusChecked,
  }) {
    return statusChecked(userId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadRequested,
    TResult? Function(String targetUserId)? requestSent,
    TResult? Function(String friendshipId)? requestAccepted,
    TResult? Function(String friendshipId)? requestDeclined,
    TResult? Function(String friendshipId)? requestCancelled,
    TResult? Function(String friendshipId)? removed,
    TResult? Function(String email)? searchRequested,
    TResult? Function()? searchCleared,
    TResult? Function(String userId)? statusChecked,
  }) {
    return statusChecked?.call(userId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadRequested,
    TResult Function(String targetUserId)? requestSent,
    TResult Function(String friendshipId)? requestAccepted,
    TResult Function(String friendshipId)? requestDeclined,
    TResult Function(String friendshipId)? requestCancelled,
    TResult Function(String friendshipId)? removed,
    TResult Function(String email)? searchRequested,
    TResult Function()? searchCleared,
    TResult Function(String userId)? statusChecked,
    required TResult orElse(),
  }) {
    if (statusChecked != null) {
      return statusChecked(userId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendLoadRequested value) loadRequested,
    required TResult Function(FriendRequestSent value) requestSent,
    required TResult Function(FriendRequestAccepted value) requestAccepted,
    required TResult Function(FriendRequestDeclined value) requestDeclined,
    required TResult Function(FriendRequestCancelled value) requestCancelled,
    required TResult Function(FriendRemoved value) removed,
    required TResult Function(FriendSearchRequested value) searchRequested,
    required TResult Function(FriendSearchCleared value) searchCleared,
    required TResult Function(FriendStatusChecked value) statusChecked,
  }) {
    return statusChecked(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendLoadRequested value)? loadRequested,
    TResult? Function(FriendRequestSent value)? requestSent,
    TResult? Function(FriendRequestAccepted value)? requestAccepted,
    TResult? Function(FriendRequestDeclined value)? requestDeclined,
    TResult? Function(FriendRequestCancelled value)? requestCancelled,
    TResult? Function(FriendRemoved value)? removed,
    TResult? Function(FriendSearchRequested value)? searchRequested,
    TResult? Function(FriendSearchCleared value)? searchCleared,
    TResult? Function(FriendStatusChecked value)? statusChecked,
  }) {
    return statusChecked?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendLoadRequested value)? loadRequested,
    TResult Function(FriendRequestSent value)? requestSent,
    TResult Function(FriendRequestAccepted value)? requestAccepted,
    TResult Function(FriendRequestDeclined value)? requestDeclined,
    TResult Function(FriendRequestCancelled value)? requestCancelled,
    TResult Function(FriendRemoved value)? removed,
    TResult Function(FriendSearchRequested value)? searchRequested,
    TResult Function(FriendSearchCleared value)? searchCleared,
    TResult Function(FriendStatusChecked value)? statusChecked,
    required TResult orElse(),
  }) {
    if (statusChecked != null) {
      return statusChecked(this);
    }
    return orElse();
  }
}

abstract class FriendStatusChecked implements FriendEvent {
  const factory FriendStatusChecked({required final String userId}) =
      _$FriendStatusCheckedImpl;

  String get userId;

  /// Create a copy of FriendEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendStatusCheckedImplCopyWith<_$FriendStatusCheckedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
