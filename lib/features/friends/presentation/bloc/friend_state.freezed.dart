// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'friend_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FriendState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )
    loaded,
    required TResult Function() searchLoading,
    required TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )
    searchResult,
    required TResult Function(FriendshipStatusResult status) statusResult,
    required TResult Function(String message) error,
    required TResult Function(String message) actionSuccess,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult? Function()? searchLoading,
    TResult? Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult? Function(FriendshipStatusResult status)? statusResult,
    TResult? Function(String message)? error,
    TResult? Function(String message)? actionSuccess,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult Function()? searchLoading,
    TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult Function(FriendshipStatusResult status)? statusResult,
    TResult Function(String message)? error,
    TResult Function(String message)? actionSuccess,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendInitial value) initial,
    required TResult Function(FriendLoading value) loading,
    required TResult Function(FriendLoaded value) loaded,
    required TResult Function(FriendSearchLoading value) searchLoading,
    required TResult Function(FriendSearchResult value) searchResult,
    required TResult Function(FriendStatusResult value) statusResult,
    required TResult Function(FriendError value) error,
    required TResult Function(FriendActionSuccess value) actionSuccess,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendInitial value)? initial,
    TResult? Function(FriendLoading value)? loading,
    TResult? Function(FriendLoaded value)? loaded,
    TResult? Function(FriendSearchLoading value)? searchLoading,
    TResult? Function(FriendSearchResult value)? searchResult,
    TResult? Function(FriendStatusResult value)? statusResult,
    TResult? Function(FriendError value)? error,
    TResult? Function(FriendActionSuccess value)? actionSuccess,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendInitial value)? initial,
    TResult Function(FriendLoading value)? loading,
    TResult Function(FriendLoaded value)? loaded,
    TResult Function(FriendSearchLoading value)? searchLoading,
    TResult Function(FriendSearchResult value)? searchResult,
    TResult Function(FriendStatusResult value)? statusResult,
    TResult Function(FriendError value)? error,
    TResult Function(FriendActionSuccess value)? actionSuccess,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FriendStateCopyWith<$Res> {
  factory $FriendStateCopyWith(
    FriendState value,
    $Res Function(FriendState) then,
  ) = _$FriendStateCopyWithImpl<$Res, FriendState>;
}

/// @nodoc
class _$FriendStateCopyWithImpl<$Res, $Val extends FriendState>
    implements $FriendStateCopyWith<$Res> {
  _$FriendStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$FriendInitialImplCopyWith<$Res> {
  factory _$$FriendInitialImplCopyWith(
    _$FriendInitialImpl value,
    $Res Function(_$FriendInitialImpl) then,
  ) = __$$FriendInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FriendInitialImplCopyWithImpl<$Res>
    extends _$FriendStateCopyWithImpl<$Res, _$FriendInitialImpl>
    implements _$$FriendInitialImplCopyWith<$Res> {
  __$$FriendInitialImplCopyWithImpl(
    _$FriendInitialImpl _value,
    $Res Function(_$FriendInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FriendInitialImpl implements FriendInitial {
  const _$FriendInitialImpl();

  @override
  String toString() {
    return 'FriendState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$FriendInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )
    loaded,
    required TResult Function() searchLoading,
    required TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )
    searchResult,
    required TResult Function(FriendshipStatusResult status) statusResult,
    required TResult Function(String message) error,
    required TResult Function(String message) actionSuccess,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult? Function()? searchLoading,
    TResult? Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult? Function(FriendshipStatusResult status)? statusResult,
    TResult? Function(String message)? error,
    TResult? Function(String message)? actionSuccess,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult Function()? searchLoading,
    TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult Function(FriendshipStatusResult status)? statusResult,
    TResult Function(String message)? error,
    TResult Function(String message)? actionSuccess,
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
    required TResult Function(FriendInitial value) initial,
    required TResult Function(FriendLoading value) loading,
    required TResult Function(FriendLoaded value) loaded,
    required TResult Function(FriendSearchLoading value) searchLoading,
    required TResult Function(FriendSearchResult value) searchResult,
    required TResult Function(FriendStatusResult value) statusResult,
    required TResult Function(FriendError value) error,
    required TResult Function(FriendActionSuccess value) actionSuccess,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendInitial value)? initial,
    TResult? Function(FriendLoading value)? loading,
    TResult? Function(FriendLoaded value)? loaded,
    TResult? Function(FriendSearchLoading value)? searchLoading,
    TResult? Function(FriendSearchResult value)? searchResult,
    TResult? Function(FriendStatusResult value)? statusResult,
    TResult? Function(FriendError value)? error,
    TResult? Function(FriendActionSuccess value)? actionSuccess,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendInitial value)? initial,
    TResult Function(FriendLoading value)? loading,
    TResult Function(FriendLoaded value)? loaded,
    TResult Function(FriendSearchLoading value)? searchLoading,
    TResult Function(FriendSearchResult value)? searchResult,
    TResult Function(FriendStatusResult value)? statusResult,
    TResult Function(FriendError value)? error,
    TResult Function(FriendActionSuccess value)? actionSuccess,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class FriendInitial implements FriendState {
  const factory FriendInitial() = _$FriendInitialImpl;
}

/// @nodoc
abstract class _$$FriendLoadingImplCopyWith<$Res> {
  factory _$$FriendLoadingImplCopyWith(
    _$FriendLoadingImpl value,
    $Res Function(_$FriendLoadingImpl) then,
  ) = __$$FriendLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FriendLoadingImplCopyWithImpl<$Res>
    extends _$FriendStateCopyWithImpl<$Res, _$FriendLoadingImpl>
    implements _$$FriendLoadingImplCopyWith<$Res> {
  __$$FriendLoadingImplCopyWithImpl(
    _$FriendLoadingImpl _value,
    $Res Function(_$FriendLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FriendLoadingImpl implements FriendLoading {
  const _$FriendLoadingImpl();

  @override
  String toString() {
    return 'FriendState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$FriendLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )
    loaded,
    required TResult Function() searchLoading,
    required TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )
    searchResult,
    required TResult Function(FriendshipStatusResult status) statusResult,
    required TResult Function(String message) error,
    required TResult Function(String message) actionSuccess,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult? Function()? searchLoading,
    TResult? Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult? Function(FriendshipStatusResult status)? statusResult,
    TResult? Function(String message)? error,
    TResult? Function(String message)? actionSuccess,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult Function()? searchLoading,
    TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult Function(FriendshipStatusResult status)? statusResult,
    TResult Function(String message)? error,
    TResult Function(String message)? actionSuccess,
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
    required TResult Function(FriendInitial value) initial,
    required TResult Function(FriendLoading value) loading,
    required TResult Function(FriendLoaded value) loaded,
    required TResult Function(FriendSearchLoading value) searchLoading,
    required TResult Function(FriendSearchResult value) searchResult,
    required TResult Function(FriendStatusResult value) statusResult,
    required TResult Function(FriendError value) error,
    required TResult Function(FriendActionSuccess value) actionSuccess,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendInitial value)? initial,
    TResult? Function(FriendLoading value)? loading,
    TResult? Function(FriendLoaded value)? loaded,
    TResult? Function(FriendSearchLoading value)? searchLoading,
    TResult? Function(FriendSearchResult value)? searchResult,
    TResult? Function(FriendStatusResult value)? statusResult,
    TResult? Function(FriendError value)? error,
    TResult? Function(FriendActionSuccess value)? actionSuccess,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendInitial value)? initial,
    TResult Function(FriendLoading value)? loading,
    TResult Function(FriendLoaded value)? loaded,
    TResult Function(FriendSearchLoading value)? searchLoading,
    TResult Function(FriendSearchResult value)? searchResult,
    TResult Function(FriendStatusResult value)? statusResult,
    TResult Function(FriendError value)? error,
    TResult Function(FriendActionSuccess value)? actionSuccess,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class FriendLoading implements FriendState {
  const factory FriendLoading() = _$FriendLoadingImpl;
}

/// @nodoc
abstract class _$$FriendLoadedImplCopyWith<$Res> {
  factory _$$FriendLoadedImplCopyWith(
    _$FriendLoadedImpl value,
    $Res Function(_$FriendLoadedImpl) then,
  ) = __$$FriendLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    List<UserEntity> friends,
    List<FriendshipEntity> receivedRequests,
    List<FriendshipEntity> sentRequests,
  });
}

/// @nodoc
class __$$FriendLoadedImplCopyWithImpl<$Res>
    extends _$FriendStateCopyWithImpl<$Res, _$FriendLoadedImpl>
    implements _$$FriendLoadedImplCopyWith<$Res> {
  __$$FriendLoadedImplCopyWithImpl(
    _$FriendLoadedImpl _value,
    $Res Function(_$FriendLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? friends = null,
    Object? receivedRequests = null,
    Object? sentRequests = null,
  }) {
    return _then(
      _$FriendLoadedImpl(
        friends: null == friends
            ? _value._friends
            : friends // ignore: cast_nullable_to_non_nullable
                  as List<UserEntity>,
        receivedRequests: null == receivedRequests
            ? _value._receivedRequests
            : receivedRequests // ignore: cast_nullable_to_non_nullable
                  as List<FriendshipEntity>,
        sentRequests: null == sentRequests
            ? _value._sentRequests
            : sentRequests // ignore: cast_nullable_to_non_nullable
                  as List<FriendshipEntity>,
      ),
    );
  }
}

/// @nodoc

class _$FriendLoadedImpl implements FriendLoaded {
  const _$FriendLoadedImpl({
    required final List<UserEntity> friends,
    required final List<FriendshipEntity> receivedRequests,
    required final List<FriendshipEntity> sentRequests,
  }) : _friends = friends,
       _receivedRequests = receivedRequests,
       _sentRequests = sentRequests;

  final List<UserEntity> _friends;
  @override
  List<UserEntity> get friends {
    if (_friends is EqualUnmodifiableListView) return _friends;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_friends);
  }

  final List<FriendshipEntity> _receivedRequests;
  @override
  List<FriendshipEntity> get receivedRequests {
    if (_receivedRequests is EqualUnmodifiableListView)
      return _receivedRequests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_receivedRequests);
  }

  final List<FriendshipEntity> _sentRequests;
  @override
  List<FriendshipEntity> get sentRequests {
    if (_sentRequests is EqualUnmodifiableListView) return _sentRequests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sentRequests);
  }

  @override
  String toString() {
    return 'FriendState.loaded(friends: $friends, receivedRequests: $receivedRequests, sentRequests: $sentRequests)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendLoadedImpl &&
            const DeepCollectionEquality().equals(other._friends, _friends) &&
            const DeepCollectionEquality().equals(
              other._receivedRequests,
              _receivedRequests,
            ) &&
            const DeepCollectionEquality().equals(
              other._sentRequests,
              _sentRequests,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_friends),
    const DeepCollectionEquality().hash(_receivedRequests),
    const DeepCollectionEquality().hash(_sentRequests),
  );

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendLoadedImplCopyWith<_$FriendLoadedImpl> get copyWith =>
      __$$FriendLoadedImplCopyWithImpl<_$FriendLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )
    loaded,
    required TResult Function() searchLoading,
    required TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )
    searchResult,
    required TResult Function(FriendshipStatusResult status) statusResult,
    required TResult Function(String message) error,
    required TResult Function(String message) actionSuccess,
  }) {
    return loaded(friends, receivedRequests, sentRequests);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult? Function()? searchLoading,
    TResult? Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult? Function(FriendshipStatusResult status)? statusResult,
    TResult? Function(String message)? error,
    TResult? Function(String message)? actionSuccess,
  }) {
    return loaded?.call(friends, receivedRequests, sentRequests);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult Function()? searchLoading,
    TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult Function(FriendshipStatusResult status)? statusResult,
    TResult Function(String message)? error,
    TResult Function(String message)? actionSuccess,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(friends, receivedRequests, sentRequests);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendInitial value) initial,
    required TResult Function(FriendLoading value) loading,
    required TResult Function(FriendLoaded value) loaded,
    required TResult Function(FriendSearchLoading value) searchLoading,
    required TResult Function(FriendSearchResult value) searchResult,
    required TResult Function(FriendStatusResult value) statusResult,
    required TResult Function(FriendError value) error,
    required TResult Function(FriendActionSuccess value) actionSuccess,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendInitial value)? initial,
    TResult? Function(FriendLoading value)? loading,
    TResult? Function(FriendLoaded value)? loaded,
    TResult? Function(FriendSearchLoading value)? searchLoading,
    TResult? Function(FriendSearchResult value)? searchResult,
    TResult? Function(FriendStatusResult value)? statusResult,
    TResult? Function(FriendError value)? error,
    TResult? Function(FriendActionSuccess value)? actionSuccess,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendInitial value)? initial,
    TResult Function(FriendLoading value)? loading,
    TResult Function(FriendLoaded value)? loaded,
    TResult Function(FriendSearchLoading value)? searchLoading,
    TResult Function(FriendSearchResult value)? searchResult,
    TResult Function(FriendStatusResult value)? statusResult,
    TResult Function(FriendError value)? error,
    TResult Function(FriendActionSuccess value)? actionSuccess,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class FriendLoaded implements FriendState {
  const factory FriendLoaded({
    required final List<UserEntity> friends,
    required final List<FriendshipEntity> receivedRequests,
    required final List<FriendshipEntity> sentRequests,
  }) = _$FriendLoadedImpl;

  List<UserEntity> get friends;
  List<FriendshipEntity> get receivedRequests;
  List<FriendshipEntity> get sentRequests;

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendLoadedImplCopyWith<_$FriendLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FriendSearchLoadingImplCopyWith<$Res> {
  factory _$$FriendSearchLoadingImplCopyWith(
    _$FriendSearchLoadingImpl value,
    $Res Function(_$FriendSearchLoadingImpl) then,
  ) = __$$FriendSearchLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$FriendSearchLoadingImplCopyWithImpl<$Res>
    extends _$FriendStateCopyWithImpl<$Res, _$FriendSearchLoadingImpl>
    implements _$$FriendSearchLoadingImplCopyWith<$Res> {
  __$$FriendSearchLoadingImplCopyWithImpl(
    _$FriendSearchLoadingImpl _value,
    $Res Function(_$FriendSearchLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$FriendSearchLoadingImpl implements FriendSearchLoading {
  const _$FriendSearchLoadingImpl();

  @override
  String toString() {
    return 'FriendState.searchLoading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendSearchLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )
    loaded,
    required TResult Function() searchLoading,
    required TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )
    searchResult,
    required TResult Function(FriendshipStatusResult status) statusResult,
    required TResult Function(String message) error,
    required TResult Function(String message) actionSuccess,
  }) {
    return searchLoading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult? Function()? searchLoading,
    TResult? Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult? Function(FriendshipStatusResult status)? statusResult,
    TResult? Function(String message)? error,
    TResult? Function(String message)? actionSuccess,
  }) {
    return searchLoading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult Function()? searchLoading,
    TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult Function(FriendshipStatusResult status)? statusResult,
    TResult Function(String message)? error,
    TResult Function(String message)? actionSuccess,
    required TResult orElse(),
  }) {
    if (searchLoading != null) {
      return searchLoading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendInitial value) initial,
    required TResult Function(FriendLoading value) loading,
    required TResult Function(FriendLoaded value) loaded,
    required TResult Function(FriendSearchLoading value) searchLoading,
    required TResult Function(FriendSearchResult value) searchResult,
    required TResult Function(FriendStatusResult value) statusResult,
    required TResult Function(FriendError value) error,
    required TResult Function(FriendActionSuccess value) actionSuccess,
  }) {
    return searchLoading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendInitial value)? initial,
    TResult? Function(FriendLoading value)? loading,
    TResult? Function(FriendLoaded value)? loaded,
    TResult? Function(FriendSearchLoading value)? searchLoading,
    TResult? Function(FriendSearchResult value)? searchResult,
    TResult? Function(FriendStatusResult value)? statusResult,
    TResult? Function(FriendError value)? error,
    TResult? Function(FriendActionSuccess value)? actionSuccess,
  }) {
    return searchLoading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendInitial value)? initial,
    TResult Function(FriendLoading value)? loading,
    TResult Function(FriendLoaded value)? loaded,
    TResult Function(FriendSearchLoading value)? searchLoading,
    TResult Function(FriendSearchResult value)? searchResult,
    TResult Function(FriendStatusResult value)? statusResult,
    TResult Function(FriendError value)? error,
    TResult Function(FriendActionSuccess value)? actionSuccess,
    required TResult orElse(),
  }) {
    if (searchLoading != null) {
      return searchLoading(this);
    }
    return orElse();
  }
}

abstract class FriendSearchLoading implements FriendState {
  const factory FriendSearchLoading() = _$FriendSearchLoadingImpl;
}

/// @nodoc
abstract class _$$FriendSearchResultImplCopyWith<$Res> {
  factory _$$FriendSearchResultImplCopyWith(
    _$FriendSearchResultImpl value,
    $Res Function(_$FriendSearchResultImpl) then,
  ) = __$$FriendSearchResultImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    UserEntity? user,
    bool isFriend,
    bool hasPendingRequest,
    String? requestDirection,
    String searchedEmail,
  });

  $UserEntityCopyWith<$Res>? get user;
}

/// @nodoc
class __$$FriendSearchResultImplCopyWithImpl<$Res>
    extends _$FriendStateCopyWithImpl<$Res, _$FriendSearchResultImpl>
    implements _$$FriendSearchResultImplCopyWith<$Res> {
  __$$FriendSearchResultImplCopyWithImpl(
    _$FriendSearchResultImpl _value,
    $Res Function(_$FriendSearchResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? isFriend = null,
    Object? hasPendingRequest = null,
    Object? requestDirection = freezed,
    Object? searchedEmail = null,
  }) {
    return _then(
      _$FriendSearchResultImpl(
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
        searchedEmail: null == searchedEmail
            ? _value.searchedEmail
            : searchedEmail // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserEntityCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserEntityCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value));
    });
  }
}

/// @nodoc

class _$FriendSearchResultImpl implements FriendSearchResult {
  const _$FriendSearchResultImpl({
    this.user,
    required this.isFriend,
    required this.hasPendingRequest,
    this.requestDirection,
    required this.searchedEmail,
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
  final String searchedEmail;

  @override
  String toString() {
    return 'FriendState.searchResult(user: $user, isFriend: $isFriend, hasPendingRequest: $hasPendingRequest, requestDirection: $requestDirection, searchedEmail: $searchedEmail)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendSearchResultImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.isFriend, isFriend) ||
                other.isFriend == isFriend) &&
            (identical(other.hasPendingRequest, hasPendingRequest) ||
                other.hasPendingRequest == hasPendingRequest) &&
            (identical(other.requestDirection, requestDirection) ||
                other.requestDirection == requestDirection) &&
            (identical(other.searchedEmail, searchedEmail) ||
                other.searchedEmail == searchedEmail));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    user,
    isFriend,
    hasPendingRequest,
    requestDirection,
    searchedEmail,
  );

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendSearchResultImplCopyWith<_$FriendSearchResultImpl> get copyWith =>
      __$$FriendSearchResultImplCopyWithImpl<_$FriendSearchResultImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )
    loaded,
    required TResult Function() searchLoading,
    required TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )
    searchResult,
    required TResult Function(FriendshipStatusResult status) statusResult,
    required TResult Function(String message) error,
    required TResult Function(String message) actionSuccess,
  }) {
    return searchResult(
      user,
      isFriend,
      hasPendingRequest,
      requestDirection,
      searchedEmail,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult? Function()? searchLoading,
    TResult? Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult? Function(FriendshipStatusResult status)? statusResult,
    TResult? Function(String message)? error,
    TResult? Function(String message)? actionSuccess,
  }) {
    return searchResult?.call(
      user,
      isFriend,
      hasPendingRequest,
      requestDirection,
      searchedEmail,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult Function()? searchLoading,
    TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult Function(FriendshipStatusResult status)? statusResult,
    TResult Function(String message)? error,
    TResult Function(String message)? actionSuccess,
    required TResult orElse(),
  }) {
    if (searchResult != null) {
      return searchResult(
        user,
        isFriend,
        hasPendingRequest,
        requestDirection,
        searchedEmail,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendInitial value) initial,
    required TResult Function(FriendLoading value) loading,
    required TResult Function(FriendLoaded value) loaded,
    required TResult Function(FriendSearchLoading value) searchLoading,
    required TResult Function(FriendSearchResult value) searchResult,
    required TResult Function(FriendStatusResult value) statusResult,
    required TResult Function(FriendError value) error,
    required TResult Function(FriendActionSuccess value) actionSuccess,
  }) {
    return searchResult(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendInitial value)? initial,
    TResult? Function(FriendLoading value)? loading,
    TResult? Function(FriendLoaded value)? loaded,
    TResult? Function(FriendSearchLoading value)? searchLoading,
    TResult? Function(FriendSearchResult value)? searchResult,
    TResult? Function(FriendStatusResult value)? statusResult,
    TResult? Function(FriendError value)? error,
    TResult? Function(FriendActionSuccess value)? actionSuccess,
  }) {
    return searchResult?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendInitial value)? initial,
    TResult Function(FriendLoading value)? loading,
    TResult Function(FriendLoaded value)? loaded,
    TResult Function(FriendSearchLoading value)? searchLoading,
    TResult Function(FriendSearchResult value)? searchResult,
    TResult Function(FriendStatusResult value)? statusResult,
    TResult Function(FriendError value)? error,
    TResult Function(FriendActionSuccess value)? actionSuccess,
    required TResult orElse(),
  }) {
    if (searchResult != null) {
      return searchResult(this);
    }
    return orElse();
  }
}

abstract class FriendSearchResult implements FriendState {
  const factory FriendSearchResult({
    final UserEntity? user,
    required final bool isFriend,
    required final bool hasPendingRequest,
    final String? requestDirection,
    required final String searchedEmail,
  }) = _$FriendSearchResultImpl;

  UserEntity? get user;
  bool get isFriend;
  bool get hasPendingRequest;
  String? get requestDirection;
  String get searchedEmail;

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendSearchResultImplCopyWith<_$FriendSearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FriendStatusResultImplCopyWith<$Res> {
  factory _$$FriendStatusResultImplCopyWith(
    _$FriendStatusResultImpl value,
    $Res Function(_$FriendStatusResultImpl) then,
  ) = __$$FriendStatusResultImplCopyWithImpl<$Res>;
  @useResult
  $Res call({FriendshipStatusResult status});

  $FriendshipStatusResultCopyWith<$Res> get status;
}

/// @nodoc
class __$$FriendStatusResultImplCopyWithImpl<$Res>
    extends _$FriendStateCopyWithImpl<$Res, _$FriendStatusResultImpl>
    implements _$$FriendStatusResultImplCopyWith<$Res> {
  __$$FriendStatusResultImplCopyWithImpl(
    _$FriendStatusResultImpl _value,
    $Res Function(_$FriendStatusResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? status = null}) {
    return _then(
      _$FriendStatusResultImpl(
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as FriendshipStatusResult,
      ),
    );
  }

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FriendshipStatusResultCopyWith<$Res> get status {
    return $FriendshipStatusResultCopyWith<$Res>(_value.status, (value) {
      return _then(_value.copyWith(status: value));
    });
  }
}

/// @nodoc

class _$FriendStatusResultImpl implements FriendStatusResult {
  const _$FriendStatusResultImpl({required this.status});

  @override
  final FriendshipStatusResult status;

  @override
  String toString() {
    return 'FriendState.statusResult(status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendStatusResultImpl &&
            (identical(other.status, status) || other.status == status));
  }

  @override
  int get hashCode => Object.hash(runtimeType, status);

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendStatusResultImplCopyWith<_$FriendStatusResultImpl> get copyWith =>
      __$$FriendStatusResultImplCopyWithImpl<_$FriendStatusResultImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )
    loaded,
    required TResult Function() searchLoading,
    required TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )
    searchResult,
    required TResult Function(FriendshipStatusResult status) statusResult,
    required TResult Function(String message) error,
    required TResult Function(String message) actionSuccess,
  }) {
    return statusResult(status);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult? Function()? searchLoading,
    TResult? Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult? Function(FriendshipStatusResult status)? statusResult,
    TResult? Function(String message)? error,
    TResult? Function(String message)? actionSuccess,
  }) {
    return statusResult?.call(status);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult Function()? searchLoading,
    TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult Function(FriendshipStatusResult status)? statusResult,
    TResult Function(String message)? error,
    TResult Function(String message)? actionSuccess,
    required TResult orElse(),
  }) {
    if (statusResult != null) {
      return statusResult(status);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendInitial value) initial,
    required TResult Function(FriendLoading value) loading,
    required TResult Function(FriendLoaded value) loaded,
    required TResult Function(FriendSearchLoading value) searchLoading,
    required TResult Function(FriendSearchResult value) searchResult,
    required TResult Function(FriendStatusResult value) statusResult,
    required TResult Function(FriendError value) error,
    required TResult Function(FriendActionSuccess value) actionSuccess,
  }) {
    return statusResult(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendInitial value)? initial,
    TResult? Function(FriendLoading value)? loading,
    TResult? Function(FriendLoaded value)? loaded,
    TResult? Function(FriendSearchLoading value)? searchLoading,
    TResult? Function(FriendSearchResult value)? searchResult,
    TResult? Function(FriendStatusResult value)? statusResult,
    TResult? Function(FriendError value)? error,
    TResult? Function(FriendActionSuccess value)? actionSuccess,
  }) {
    return statusResult?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendInitial value)? initial,
    TResult Function(FriendLoading value)? loading,
    TResult Function(FriendLoaded value)? loaded,
    TResult Function(FriendSearchLoading value)? searchLoading,
    TResult Function(FriendSearchResult value)? searchResult,
    TResult Function(FriendStatusResult value)? statusResult,
    TResult Function(FriendError value)? error,
    TResult Function(FriendActionSuccess value)? actionSuccess,
    required TResult orElse(),
  }) {
    if (statusResult != null) {
      return statusResult(this);
    }
    return orElse();
  }
}

abstract class FriendStatusResult implements FriendState {
  const factory FriendStatusResult({
    required final FriendshipStatusResult status,
  }) = _$FriendStatusResultImpl;

  FriendshipStatusResult get status;

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendStatusResultImplCopyWith<_$FriendStatusResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FriendErrorImplCopyWith<$Res> {
  factory _$$FriendErrorImplCopyWith(
    _$FriendErrorImpl value,
    $Res Function(_$FriendErrorImpl) then,
  ) = __$$FriendErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$FriendErrorImplCopyWithImpl<$Res>
    extends _$FriendStateCopyWithImpl<$Res, _$FriendErrorImpl>
    implements _$$FriendErrorImplCopyWith<$Res> {
  __$$FriendErrorImplCopyWithImpl(
    _$FriendErrorImpl _value,
    $Res Function(_$FriendErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$FriendErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FriendErrorImpl implements FriendError {
  const _$FriendErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'FriendState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendErrorImplCopyWith<_$FriendErrorImpl> get copyWith =>
      __$$FriendErrorImplCopyWithImpl<_$FriendErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )
    loaded,
    required TResult Function() searchLoading,
    required TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )
    searchResult,
    required TResult Function(FriendshipStatusResult status) statusResult,
    required TResult Function(String message) error,
    required TResult Function(String message) actionSuccess,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult? Function()? searchLoading,
    TResult? Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult? Function(FriendshipStatusResult status)? statusResult,
    TResult? Function(String message)? error,
    TResult? Function(String message)? actionSuccess,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult Function()? searchLoading,
    TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult Function(FriendshipStatusResult status)? statusResult,
    TResult Function(String message)? error,
    TResult Function(String message)? actionSuccess,
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
    required TResult Function(FriendInitial value) initial,
    required TResult Function(FriendLoading value) loading,
    required TResult Function(FriendLoaded value) loaded,
    required TResult Function(FriendSearchLoading value) searchLoading,
    required TResult Function(FriendSearchResult value) searchResult,
    required TResult Function(FriendStatusResult value) statusResult,
    required TResult Function(FriendError value) error,
    required TResult Function(FriendActionSuccess value) actionSuccess,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendInitial value)? initial,
    TResult? Function(FriendLoading value)? loading,
    TResult? Function(FriendLoaded value)? loaded,
    TResult? Function(FriendSearchLoading value)? searchLoading,
    TResult? Function(FriendSearchResult value)? searchResult,
    TResult? Function(FriendStatusResult value)? statusResult,
    TResult? Function(FriendError value)? error,
    TResult? Function(FriendActionSuccess value)? actionSuccess,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendInitial value)? initial,
    TResult Function(FriendLoading value)? loading,
    TResult Function(FriendLoaded value)? loaded,
    TResult Function(FriendSearchLoading value)? searchLoading,
    TResult Function(FriendSearchResult value)? searchResult,
    TResult Function(FriendStatusResult value)? statusResult,
    TResult Function(FriendError value)? error,
    TResult Function(FriendActionSuccess value)? actionSuccess,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class FriendError implements FriendState {
  const factory FriendError({required final String message}) =
      _$FriendErrorImpl;

  String get message;

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendErrorImplCopyWith<_$FriendErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FriendActionSuccessImplCopyWith<$Res> {
  factory _$$FriendActionSuccessImplCopyWith(
    _$FriendActionSuccessImpl value,
    $Res Function(_$FriendActionSuccessImpl) then,
  ) = __$$FriendActionSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$FriendActionSuccessImplCopyWithImpl<$Res>
    extends _$FriendStateCopyWithImpl<$Res, _$FriendActionSuccessImpl>
    implements _$$FriendActionSuccessImplCopyWith<$Res> {
  __$$FriendActionSuccessImplCopyWithImpl(
    _$FriendActionSuccessImpl _value,
    $Res Function(_$FriendActionSuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$FriendActionSuccessImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FriendActionSuccessImpl implements FriendActionSuccess {
  const _$FriendActionSuccessImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'FriendState.actionSuccess(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FriendActionSuccessImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FriendActionSuccessImplCopyWith<_$FriendActionSuccessImpl> get copyWith =>
      __$$FriendActionSuccessImplCopyWithImpl<_$FriendActionSuccessImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )
    loaded,
    required TResult Function() searchLoading,
    required TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )
    searchResult,
    required TResult Function(FriendshipStatusResult status) statusResult,
    required TResult Function(String message) error,
    required TResult Function(String message) actionSuccess,
  }) {
    return actionSuccess(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult? Function()? searchLoading,
    TResult? Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult? Function(FriendshipStatusResult status)? statusResult,
    TResult? Function(String message)? error,
    TResult? Function(String message)? actionSuccess,
  }) {
    return actionSuccess?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<UserEntity> friends,
      List<FriendshipEntity> receivedRequests,
      List<FriendshipEntity> sentRequests,
    )?
    loaded,
    TResult Function()? searchLoading,
    TResult Function(
      UserEntity? user,
      bool isFriend,
      bool hasPendingRequest,
      String? requestDirection,
      String searchedEmail,
    )?
    searchResult,
    TResult Function(FriendshipStatusResult status)? statusResult,
    TResult Function(String message)? error,
    TResult Function(String message)? actionSuccess,
    required TResult orElse(),
  }) {
    if (actionSuccess != null) {
      return actionSuccess(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(FriendInitial value) initial,
    required TResult Function(FriendLoading value) loading,
    required TResult Function(FriendLoaded value) loaded,
    required TResult Function(FriendSearchLoading value) searchLoading,
    required TResult Function(FriendSearchResult value) searchResult,
    required TResult Function(FriendStatusResult value) statusResult,
    required TResult Function(FriendError value) error,
    required TResult Function(FriendActionSuccess value) actionSuccess,
  }) {
    return actionSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(FriendInitial value)? initial,
    TResult? Function(FriendLoading value)? loading,
    TResult? Function(FriendLoaded value)? loaded,
    TResult? Function(FriendSearchLoading value)? searchLoading,
    TResult? Function(FriendSearchResult value)? searchResult,
    TResult? Function(FriendStatusResult value)? statusResult,
    TResult? Function(FriendError value)? error,
    TResult? Function(FriendActionSuccess value)? actionSuccess,
  }) {
    return actionSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(FriendInitial value)? initial,
    TResult Function(FriendLoading value)? loading,
    TResult Function(FriendLoaded value)? loaded,
    TResult Function(FriendSearchLoading value)? searchLoading,
    TResult Function(FriendSearchResult value)? searchResult,
    TResult Function(FriendStatusResult value)? statusResult,
    TResult Function(FriendError value)? error,
    TResult Function(FriendActionSuccess value)? actionSuccess,
    required TResult orElse(),
  }) {
    if (actionSuccess != null) {
      return actionSuccess(this);
    }
    return orElse();
  }
}

abstract class FriendActionSuccess implements FriendState {
  const factory FriendActionSuccess({required final String message}) =
      _$FriendActionSuccessImpl;

  String get message;

  /// Create a copy of FriendState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FriendActionSuccessImplCopyWith<_$FriendActionSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
