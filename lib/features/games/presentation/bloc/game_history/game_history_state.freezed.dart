// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_history_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GameHistoryState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<GameModel> games,
      bool hasMore,
      GameHistoryFilter currentFilter,
      DateTime? startDate,
      DateTime? endDate,
      bool isLoadingMore,
    )
    loaded,
    required TResult Function(String message, GameHistoryFilter? lastFilter)
    error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<GameModel> games,
      bool hasMore,
      GameHistoryFilter currentFilter,
      DateTime? startDate,
      DateTime? endDate,
      bool isLoadingMore,
    )?
    loaded,
    TResult? Function(String message, GameHistoryFilter? lastFilter)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<GameModel> games,
      bool hasMore,
      GameHistoryFilter currentFilter,
      DateTime? startDate,
      DateTime? endDate,
      bool isLoadingMore,
    )?
    loaded,
    TResult Function(String message, GameHistoryFilter? lastFilter)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHistoryInitial value) initial,
    required TResult Function(GameHistoryLoading value) loading,
    required TResult Function(GameHistoryLoaded value) loaded,
    required TResult Function(GameHistoryError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHistoryInitial value)? initial,
    TResult? Function(GameHistoryLoading value)? loading,
    TResult? Function(GameHistoryLoaded value)? loaded,
    TResult? Function(GameHistoryError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHistoryInitial value)? initial,
    TResult Function(GameHistoryLoading value)? loading,
    TResult Function(GameHistoryLoaded value)? loaded,
    TResult Function(GameHistoryError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameHistoryStateCopyWith<$Res> {
  factory $GameHistoryStateCopyWith(
    GameHistoryState value,
    $Res Function(GameHistoryState) then,
  ) = _$GameHistoryStateCopyWithImpl<$Res, GameHistoryState>;
}

/// @nodoc
class _$GameHistoryStateCopyWithImpl<$Res, $Val extends GameHistoryState>
    implements $GameHistoryStateCopyWith<$Res> {
  _$GameHistoryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameHistoryState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$GameHistoryInitialImplCopyWith<$Res> {
  factory _$$GameHistoryInitialImplCopyWith(
    _$GameHistoryInitialImpl value,
    $Res Function(_$GameHistoryInitialImpl) then,
  ) = __$$GameHistoryInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GameHistoryInitialImplCopyWithImpl<$Res>
    extends _$GameHistoryStateCopyWithImpl<$Res, _$GameHistoryInitialImpl>
    implements _$$GameHistoryInitialImplCopyWith<$Res> {
  __$$GameHistoryInitialImplCopyWithImpl(
    _$GameHistoryInitialImpl _value,
    $Res Function(_$GameHistoryInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameHistoryState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GameHistoryInitialImpl implements GameHistoryInitial {
  const _$GameHistoryInitialImpl();

  @override
  String toString() {
    return 'GameHistoryState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GameHistoryInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<GameModel> games,
      bool hasMore,
      GameHistoryFilter currentFilter,
      DateTime? startDate,
      DateTime? endDate,
      bool isLoadingMore,
    )
    loaded,
    required TResult Function(String message, GameHistoryFilter? lastFilter)
    error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<GameModel> games,
      bool hasMore,
      GameHistoryFilter currentFilter,
      DateTime? startDate,
      DateTime? endDate,
      bool isLoadingMore,
    )?
    loaded,
    TResult? Function(String message, GameHistoryFilter? lastFilter)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<GameModel> games,
      bool hasMore,
      GameHistoryFilter currentFilter,
      DateTime? startDate,
      DateTime? endDate,
      bool isLoadingMore,
    )?
    loaded,
    TResult Function(String message, GameHistoryFilter? lastFilter)? error,
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
    required TResult Function(GameHistoryInitial value) initial,
    required TResult Function(GameHistoryLoading value) loading,
    required TResult Function(GameHistoryLoaded value) loaded,
    required TResult Function(GameHistoryError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHistoryInitial value)? initial,
    TResult? Function(GameHistoryLoading value)? loading,
    TResult? Function(GameHistoryLoaded value)? loaded,
    TResult? Function(GameHistoryError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHistoryInitial value)? initial,
    TResult Function(GameHistoryLoading value)? loading,
    TResult Function(GameHistoryLoaded value)? loaded,
    TResult Function(GameHistoryError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class GameHistoryInitial implements GameHistoryState {
  const factory GameHistoryInitial() = _$GameHistoryInitialImpl;
}

/// @nodoc
abstract class _$$GameHistoryLoadingImplCopyWith<$Res> {
  factory _$$GameHistoryLoadingImplCopyWith(
    _$GameHistoryLoadingImpl value,
    $Res Function(_$GameHistoryLoadingImpl) then,
  ) = __$$GameHistoryLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GameHistoryLoadingImplCopyWithImpl<$Res>
    extends _$GameHistoryStateCopyWithImpl<$Res, _$GameHistoryLoadingImpl>
    implements _$$GameHistoryLoadingImplCopyWith<$Res> {
  __$$GameHistoryLoadingImplCopyWithImpl(
    _$GameHistoryLoadingImpl _value,
    $Res Function(_$GameHistoryLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameHistoryState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GameHistoryLoadingImpl implements GameHistoryLoading {
  const _$GameHistoryLoadingImpl();

  @override
  String toString() {
    return 'GameHistoryState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GameHistoryLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<GameModel> games,
      bool hasMore,
      GameHistoryFilter currentFilter,
      DateTime? startDate,
      DateTime? endDate,
      bool isLoadingMore,
    )
    loaded,
    required TResult Function(String message, GameHistoryFilter? lastFilter)
    error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<GameModel> games,
      bool hasMore,
      GameHistoryFilter currentFilter,
      DateTime? startDate,
      DateTime? endDate,
      bool isLoadingMore,
    )?
    loaded,
    TResult? Function(String message, GameHistoryFilter? lastFilter)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<GameModel> games,
      bool hasMore,
      GameHistoryFilter currentFilter,
      DateTime? startDate,
      DateTime? endDate,
      bool isLoadingMore,
    )?
    loaded,
    TResult Function(String message, GameHistoryFilter? lastFilter)? error,
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
    required TResult Function(GameHistoryInitial value) initial,
    required TResult Function(GameHistoryLoading value) loading,
    required TResult Function(GameHistoryLoaded value) loaded,
    required TResult Function(GameHistoryError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHistoryInitial value)? initial,
    TResult? Function(GameHistoryLoading value)? loading,
    TResult? Function(GameHistoryLoaded value)? loaded,
    TResult? Function(GameHistoryError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHistoryInitial value)? initial,
    TResult Function(GameHistoryLoading value)? loading,
    TResult Function(GameHistoryLoaded value)? loaded,
    TResult Function(GameHistoryError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class GameHistoryLoading implements GameHistoryState {
  const factory GameHistoryLoading() = _$GameHistoryLoadingImpl;
}

/// @nodoc
abstract class _$$GameHistoryLoadedImplCopyWith<$Res> {
  factory _$$GameHistoryLoadedImplCopyWith(
    _$GameHistoryLoadedImpl value,
    $Res Function(_$GameHistoryLoadedImpl) then,
  ) = __$$GameHistoryLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    List<GameModel> games,
    bool hasMore,
    GameHistoryFilter currentFilter,
    DateTime? startDate,
    DateTime? endDate,
    bool isLoadingMore,
  });
}

/// @nodoc
class __$$GameHistoryLoadedImplCopyWithImpl<$Res>
    extends _$GameHistoryStateCopyWithImpl<$Res, _$GameHistoryLoadedImpl>
    implements _$$GameHistoryLoadedImplCopyWith<$Res> {
  __$$GameHistoryLoadedImplCopyWithImpl(
    _$GameHistoryLoadedImpl _value,
    $Res Function(_$GameHistoryLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? games = null,
    Object? hasMore = null,
    Object? currentFilter = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? isLoadingMore = null,
  }) {
    return _then(
      _$GameHistoryLoadedImpl(
        games: null == games
            ? _value._games
            : games // ignore: cast_nullable_to_non_nullable
                  as List<GameModel>,
        hasMore: null == hasMore
            ? _value.hasMore
            : hasMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentFilter: null == currentFilter
            ? _value.currentFilter
            : currentFilter // ignore: cast_nullable_to_non_nullable
                  as GameHistoryFilter,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isLoadingMore: null == isLoadingMore
            ? _value.isLoadingMore
            : isLoadingMore // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$GameHistoryLoadedImpl implements GameHistoryLoaded {
  const _$GameHistoryLoadedImpl({
    required final List<GameModel> games,
    required this.hasMore,
    required this.currentFilter,
    this.startDate,
    this.endDate,
    this.isLoadingMore = false,
  }) : _games = games;

  final List<GameModel> _games;
  @override
  List<GameModel> get games {
    if (_games is EqualUnmodifiableListView) return _games;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_games);
  }

  @override
  final bool hasMore;
  @override
  final GameHistoryFilter currentFilter;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  @JsonKey()
  final bool isLoadingMore;

  @override
  String toString() {
    return 'GameHistoryState.loaded(games: $games, hasMore: $hasMore, currentFilter: $currentFilter, startDate: $startDate, endDate: $endDate, isLoadingMore: $isLoadingMore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHistoryLoadedImpl &&
            const DeepCollectionEquality().equals(other._games, _games) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.currentFilter, currentFilter) ||
                other.currentFilter == currentFilter) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_games),
    hasMore,
    currentFilter,
    startDate,
    endDate,
    isLoadingMore,
  );

  /// Create a copy of GameHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHistoryLoadedImplCopyWith<_$GameHistoryLoadedImpl> get copyWith =>
      __$$GameHistoryLoadedImplCopyWithImpl<_$GameHistoryLoadedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<GameModel> games,
      bool hasMore,
      GameHistoryFilter currentFilter,
      DateTime? startDate,
      DateTime? endDate,
      bool isLoadingMore,
    )
    loaded,
    required TResult Function(String message, GameHistoryFilter? lastFilter)
    error,
  }) {
    return loaded(
      games,
      hasMore,
      currentFilter,
      startDate,
      endDate,
      isLoadingMore,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<GameModel> games,
      bool hasMore,
      GameHistoryFilter currentFilter,
      DateTime? startDate,
      DateTime? endDate,
      bool isLoadingMore,
    )?
    loaded,
    TResult? Function(String message, GameHistoryFilter? lastFilter)? error,
  }) {
    return loaded?.call(
      games,
      hasMore,
      currentFilter,
      startDate,
      endDate,
      isLoadingMore,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<GameModel> games,
      bool hasMore,
      GameHistoryFilter currentFilter,
      DateTime? startDate,
      DateTime? endDate,
      bool isLoadingMore,
    )?
    loaded,
    TResult Function(String message, GameHistoryFilter? lastFilter)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(
        games,
        hasMore,
        currentFilter,
        startDate,
        endDate,
        isLoadingMore,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHistoryInitial value) initial,
    required TResult Function(GameHistoryLoading value) loading,
    required TResult Function(GameHistoryLoaded value) loaded,
    required TResult Function(GameHistoryError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHistoryInitial value)? initial,
    TResult? Function(GameHistoryLoading value)? loading,
    TResult? Function(GameHistoryLoaded value)? loaded,
    TResult? Function(GameHistoryError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHistoryInitial value)? initial,
    TResult Function(GameHistoryLoading value)? loading,
    TResult Function(GameHistoryLoaded value)? loaded,
    TResult Function(GameHistoryError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class GameHistoryLoaded implements GameHistoryState {
  const factory GameHistoryLoaded({
    required final List<GameModel> games,
    required final bool hasMore,
    required final GameHistoryFilter currentFilter,
    final DateTime? startDate,
    final DateTime? endDate,
    final bool isLoadingMore,
  }) = _$GameHistoryLoadedImpl;

  List<GameModel> get games;
  bool get hasMore;
  GameHistoryFilter get currentFilter;
  DateTime? get startDate;
  DateTime? get endDate;
  bool get isLoadingMore;

  /// Create a copy of GameHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHistoryLoadedImplCopyWith<_$GameHistoryLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameHistoryErrorImplCopyWith<$Res> {
  factory _$$GameHistoryErrorImplCopyWith(
    _$GameHistoryErrorImpl value,
    $Res Function(_$GameHistoryErrorImpl) then,
  ) = __$$GameHistoryErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message, GameHistoryFilter? lastFilter});
}

/// @nodoc
class __$$GameHistoryErrorImplCopyWithImpl<$Res>
    extends _$GameHistoryStateCopyWithImpl<$Res, _$GameHistoryErrorImpl>
    implements _$$GameHistoryErrorImplCopyWith<$Res> {
  __$$GameHistoryErrorImplCopyWithImpl(
    _$GameHistoryErrorImpl _value,
    $Res Function(_$GameHistoryErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null, Object? lastFilter = freezed}) {
    return _then(
      _$GameHistoryErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        lastFilter: freezed == lastFilter
            ? _value.lastFilter
            : lastFilter // ignore: cast_nullable_to_non_nullable
                  as GameHistoryFilter?,
      ),
    );
  }
}

/// @nodoc

class _$GameHistoryErrorImpl implements GameHistoryError {
  const _$GameHistoryErrorImpl({required this.message, this.lastFilter});

  @override
  final String message;
  @override
  final GameHistoryFilter? lastFilter;

  @override
  String toString() {
    return 'GameHistoryState.error(message: $message, lastFilter: $lastFilter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHistoryErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.lastFilter, lastFilter) ||
                other.lastFilter == lastFilter));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, lastFilter);

  /// Create a copy of GameHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHistoryErrorImplCopyWith<_$GameHistoryErrorImpl> get copyWith =>
      __$$GameHistoryErrorImplCopyWithImpl<_$GameHistoryErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<GameModel> games,
      bool hasMore,
      GameHistoryFilter currentFilter,
      DateTime? startDate,
      DateTime? endDate,
      bool isLoadingMore,
    )
    loaded,
    required TResult Function(String message, GameHistoryFilter? lastFilter)
    error,
  }) {
    return error(message, lastFilter);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<GameModel> games,
      bool hasMore,
      GameHistoryFilter currentFilter,
      DateTime? startDate,
      DateTime? endDate,
      bool isLoadingMore,
    )?
    loaded,
    TResult? Function(String message, GameHistoryFilter? lastFilter)? error,
  }) {
    return error?.call(message, lastFilter);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<GameModel> games,
      bool hasMore,
      GameHistoryFilter currentFilter,
      DateTime? startDate,
      DateTime? endDate,
      bool isLoadingMore,
    )?
    loaded,
    TResult Function(String message, GameHistoryFilter? lastFilter)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, lastFilter);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHistoryInitial value) initial,
    required TResult Function(GameHistoryLoading value) loading,
    required TResult Function(GameHistoryLoaded value) loaded,
    required TResult Function(GameHistoryError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHistoryInitial value)? initial,
    TResult? Function(GameHistoryLoading value)? loading,
    TResult? Function(GameHistoryLoaded value)? loaded,
    TResult? Function(GameHistoryError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHistoryInitial value)? initial,
    TResult Function(GameHistoryLoading value)? loading,
    TResult Function(GameHistoryLoaded value)? loaded,
    TResult Function(GameHistoryError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class GameHistoryError implements GameHistoryState {
  const factory GameHistoryError({
    required final String message,
    final GameHistoryFilter? lastFilter,
  }) = _$GameHistoryErrorImpl;

  String get message;
  GameHistoryFilter? get lastFilter;

  /// Create a copy of GameHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHistoryErrorImplCopyWith<_$GameHistoryErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
