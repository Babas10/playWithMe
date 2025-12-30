// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'elo_history_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$EloHistoryState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<RatingHistoryEntry> history,
      List<RatingHistoryEntry> filteredHistory,
      DateTime? filterStartDate,
      DateTime? filterEndDate,
      TimePeriod selectedPeriod,
    )
    loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<RatingHistoryEntry> history,
      List<RatingHistoryEntry> filteredHistory,
      DateTime? filterStartDate,
      DateTime? filterEndDate,
      TimePeriod selectedPeriod,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<RatingHistoryEntry> history,
      List<RatingHistoryEntry> filteredHistory,
      DateTime? filterStartDate,
      DateTime? filterEndDate,
      TimePeriod selectedPeriod,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EloHistoryInitial value) initial,
    required TResult Function(EloHistoryLoading value) loading,
    required TResult Function(EloHistoryLoaded value) loaded,
    required TResult Function(EloHistoryError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EloHistoryInitial value)? initial,
    TResult? Function(EloHistoryLoading value)? loading,
    TResult? Function(EloHistoryLoaded value)? loaded,
    TResult? Function(EloHistoryError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EloHistoryInitial value)? initial,
    TResult Function(EloHistoryLoading value)? loading,
    TResult Function(EloHistoryLoaded value)? loaded,
    TResult Function(EloHistoryError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EloHistoryStateCopyWith<$Res> {
  factory $EloHistoryStateCopyWith(
    EloHistoryState value,
    $Res Function(EloHistoryState) then,
  ) = _$EloHistoryStateCopyWithImpl<$Res, EloHistoryState>;
}

/// @nodoc
class _$EloHistoryStateCopyWithImpl<$Res, $Val extends EloHistoryState>
    implements $EloHistoryStateCopyWith<$Res> {
  _$EloHistoryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EloHistoryState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$EloHistoryInitialImplCopyWith<$Res> {
  factory _$$EloHistoryInitialImplCopyWith(
    _$EloHistoryInitialImpl value,
    $Res Function(_$EloHistoryInitialImpl) then,
  ) = __$$EloHistoryInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EloHistoryInitialImplCopyWithImpl<$Res>
    extends _$EloHistoryStateCopyWithImpl<$Res, _$EloHistoryInitialImpl>
    implements _$$EloHistoryInitialImplCopyWith<$Res> {
  __$$EloHistoryInitialImplCopyWithImpl(
    _$EloHistoryInitialImpl _value,
    $Res Function(_$EloHistoryInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EloHistoryState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$EloHistoryInitialImpl implements EloHistoryInitial {
  const _$EloHistoryInitialImpl();

  @override
  String toString() {
    return 'EloHistoryState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$EloHistoryInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<RatingHistoryEntry> history,
      List<RatingHistoryEntry> filteredHistory,
      DateTime? filterStartDate,
      DateTime? filterEndDate,
      TimePeriod selectedPeriod,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<RatingHistoryEntry> history,
      List<RatingHistoryEntry> filteredHistory,
      DateTime? filterStartDate,
      DateTime? filterEndDate,
      TimePeriod selectedPeriod,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<RatingHistoryEntry> history,
      List<RatingHistoryEntry> filteredHistory,
      DateTime? filterStartDate,
      DateTime? filterEndDate,
      TimePeriod selectedPeriod,
    )?
    loaded,
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
    required TResult Function(EloHistoryInitial value) initial,
    required TResult Function(EloHistoryLoading value) loading,
    required TResult Function(EloHistoryLoaded value) loaded,
    required TResult Function(EloHistoryError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EloHistoryInitial value)? initial,
    TResult? Function(EloHistoryLoading value)? loading,
    TResult? Function(EloHistoryLoaded value)? loaded,
    TResult? Function(EloHistoryError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EloHistoryInitial value)? initial,
    TResult Function(EloHistoryLoading value)? loading,
    TResult Function(EloHistoryLoaded value)? loaded,
    TResult Function(EloHistoryError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class EloHistoryInitial implements EloHistoryState {
  const factory EloHistoryInitial() = _$EloHistoryInitialImpl;
}

/// @nodoc
abstract class _$$EloHistoryLoadingImplCopyWith<$Res> {
  factory _$$EloHistoryLoadingImplCopyWith(
    _$EloHistoryLoadingImpl value,
    $Res Function(_$EloHistoryLoadingImpl) then,
  ) = __$$EloHistoryLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EloHistoryLoadingImplCopyWithImpl<$Res>
    extends _$EloHistoryStateCopyWithImpl<$Res, _$EloHistoryLoadingImpl>
    implements _$$EloHistoryLoadingImplCopyWith<$Res> {
  __$$EloHistoryLoadingImplCopyWithImpl(
    _$EloHistoryLoadingImpl _value,
    $Res Function(_$EloHistoryLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EloHistoryState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$EloHistoryLoadingImpl implements EloHistoryLoading {
  const _$EloHistoryLoadingImpl();

  @override
  String toString() {
    return 'EloHistoryState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$EloHistoryLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<RatingHistoryEntry> history,
      List<RatingHistoryEntry> filteredHistory,
      DateTime? filterStartDate,
      DateTime? filterEndDate,
      TimePeriod selectedPeriod,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<RatingHistoryEntry> history,
      List<RatingHistoryEntry> filteredHistory,
      DateTime? filterStartDate,
      DateTime? filterEndDate,
      TimePeriod selectedPeriod,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<RatingHistoryEntry> history,
      List<RatingHistoryEntry> filteredHistory,
      DateTime? filterStartDate,
      DateTime? filterEndDate,
      TimePeriod selectedPeriod,
    )?
    loaded,
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
    required TResult Function(EloHistoryInitial value) initial,
    required TResult Function(EloHistoryLoading value) loading,
    required TResult Function(EloHistoryLoaded value) loaded,
    required TResult Function(EloHistoryError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EloHistoryInitial value)? initial,
    TResult? Function(EloHistoryLoading value)? loading,
    TResult? Function(EloHistoryLoaded value)? loaded,
    TResult? Function(EloHistoryError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EloHistoryInitial value)? initial,
    TResult Function(EloHistoryLoading value)? loading,
    TResult Function(EloHistoryLoaded value)? loaded,
    TResult Function(EloHistoryError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class EloHistoryLoading implements EloHistoryState {
  const factory EloHistoryLoading() = _$EloHistoryLoadingImpl;
}

/// @nodoc
abstract class _$$EloHistoryLoadedImplCopyWith<$Res> {
  factory _$$EloHistoryLoadedImplCopyWith(
    _$EloHistoryLoadedImpl value,
    $Res Function(_$EloHistoryLoadedImpl) then,
  ) = __$$EloHistoryLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    List<RatingHistoryEntry> history,
    List<RatingHistoryEntry> filteredHistory,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    TimePeriod selectedPeriod,
  });
}

/// @nodoc
class __$$EloHistoryLoadedImplCopyWithImpl<$Res>
    extends _$EloHistoryStateCopyWithImpl<$Res, _$EloHistoryLoadedImpl>
    implements _$$EloHistoryLoadedImplCopyWith<$Res> {
  __$$EloHistoryLoadedImplCopyWithImpl(
    _$EloHistoryLoadedImpl _value,
    $Res Function(_$EloHistoryLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EloHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? history = null,
    Object? filteredHistory = null,
    Object? filterStartDate = freezed,
    Object? filterEndDate = freezed,
    Object? selectedPeriod = null,
  }) {
    return _then(
      _$EloHistoryLoadedImpl(
        history: null == history
            ? _value._history
            : history // ignore: cast_nullable_to_non_nullable
                  as List<RatingHistoryEntry>,
        filteredHistory: null == filteredHistory
            ? _value._filteredHistory
            : filteredHistory // ignore: cast_nullable_to_non_nullable
                  as List<RatingHistoryEntry>,
        filterStartDate: freezed == filterStartDate
            ? _value.filterStartDate
            : filterStartDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        filterEndDate: freezed == filterEndDate
            ? _value.filterEndDate
            : filterEndDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        selectedPeriod: null == selectedPeriod
            ? _value.selectedPeriod
            : selectedPeriod // ignore: cast_nullable_to_non_nullable
                  as TimePeriod,
      ),
    );
  }
}

/// @nodoc

class _$EloHistoryLoadedImpl implements EloHistoryLoaded {
  const _$EloHistoryLoadedImpl({
    required final List<RatingHistoryEntry> history,
    required final List<RatingHistoryEntry> filteredHistory,
    this.filterStartDate,
    this.filterEndDate,
    this.selectedPeriod = TimePeriod.allTime,
  }) : _history = history,
       _filteredHistory = filteredHistory;

  final List<RatingHistoryEntry> _history;
  @override
  List<RatingHistoryEntry> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  final List<RatingHistoryEntry> _filteredHistory;
  @override
  List<RatingHistoryEntry> get filteredHistory {
    if (_filteredHistory is EqualUnmodifiableListView) return _filteredHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredHistory);
  }

  @override
  final DateTime? filterStartDate;
  @override
  final DateTime? filterEndDate;
  @override
  @JsonKey()
  final TimePeriod selectedPeriod;

  @override
  String toString() {
    return 'EloHistoryState.loaded(history: $history, filteredHistory: $filteredHistory, filterStartDate: $filterStartDate, filterEndDate: $filterEndDate, selectedPeriod: $selectedPeriod)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EloHistoryLoadedImpl &&
            const DeepCollectionEquality().equals(other._history, _history) &&
            const DeepCollectionEquality().equals(
              other._filteredHistory,
              _filteredHistory,
            ) &&
            (identical(other.filterStartDate, filterStartDate) ||
                other.filterStartDate == filterStartDate) &&
            (identical(other.filterEndDate, filterEndDate) ||
                other.filterEndDate == filterEndDate) &&
            (identical(other.selectedPeriod, selectedPeriod) ||
                other.selectedPeriod == selectedPeriod));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_history),
    const DeepCollectionEquality().hash(_filteredHistory),
    filterStartDate,
    filterEndDate,
    selectedPeriod,
  );

  /// Create a copy of EloHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EloHistoryLoadedImplCopyWith<_$EloHistoryLoadedImpl> get copyWith =>
      __$$EloHistoryLoadedImplCopyWithImpl<_$EloHistoryLoadedImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<RatingHistoryEntry> history,
      List<RatingHistoryEntry> filteredHistory,
      DateTime? filterStartDate,
      DateTime? filterEndDate,
      TimePeriod selectedPeriod,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(
      history,
      filteredHistory,
      filterStartDate,
      filterEndDate,
      selectedPeriod,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<RatingHistoryEntry> history,
      List<RatingHistoryEntry> filteredHistory,
      DateTime? filterStartDate,
      DateTime? filterEndDate,
      TimePeriod selectedPeriod,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(
      history,
      filteredHistory,
      filterStartDate,
      filterEndDate,
      selectedPeriod,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<RatingHistoryEntry> history,
      List<RatingHistoryEntry> filteredHistory,
      DateTime? filterStartDate,
      DateTime? filterEndDate,
      TimePeriod selectedPeriod,
    )?
    loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(
        history,
        filteredHistory,
        filterStartDate,
        filterEndDate,
        selectedPeriod,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(EloHistoryInitial value) initial,
    required TResult Function(EloHistoryLoading value) loading,
    required TResult Function(EloHistoryLoaded value) loaded,
    required TResult Function(EloHistoryError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EloHistoryInitial value)? initial,
    TResult? Function(EloHistoryLoading value)? loading,
    TResult? Function(EloHistoryLoaded value)? loaded,
    TResult? Function(EloHistoryError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EloHistoryInitial value)? initial,
    TResult Function(EloHistoryLoading value)? loading,
    TResult Function(EloHistoryLoaded value)? loaded,
    TResult Function(EloHistoryError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class EloHistoryLoaded implements EloHistoryState {
  const factory EloHistoryLoaded({
    required final List<RatingHistoryEntry> history,
    required final List<RatingHistoryEntry> filteredHistory,
    final DateTime? filterStartDate,
    final DateTime? filterEndDate,
    final TimePeriod selectedPeriod,
  }) = _$EloHistoryLoadedImpl;

  List<RatingHistoryEntry> get history;
  List<RatingHistoryEntry> get filteredHistory;
  DateTime? get filterStartDate;
  DateTime? get filterEndDate;
  TimePeriod get selectedPeriod;

  /// Create a copy of EloHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EloHistoryLoadedImplCopyWith<_$EloHistoryLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EloHistoryErrorImplCopyWith<$Res> {
  factory _$$EloHistoryErrorImplCopyWith(
    _$EloHistoryErrorImpl value,
    $Res Function(_$EloHistoryErrorImpl) then,
  ) = __$$EloHistoryErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$EloHistoryErrorImplCopyWithImpl<$Res>
    extends _$EloHistoryStateCopyWithImpl<$Res, _$EloHistoryErrorImpl>
    implements _$$EloHistoryErrorImplCopyWith<$Res> {
  __$$EloHistoryErrorImplCopyWithImpl(
    _$EloHistoryErrorImpl _value,
    $Res Function(_$EloHistoryErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EloHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$EloHistoryErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$EloHistoryErrorImpl implements EloHistoryError {
  const _$EloHistoryErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'EloHistoryState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EloHistoryErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of EloHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EloHistoryErrorImplCopyWith<_$EloHistoryErrorImpl> get copyWith =>
      __$$EloHistoryErrorImplCopyWithImpl<_$EloHistoryErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
      List<RatingHistoryEntry> history,
      List<RatingHistoryEntry> filteredHistory,
      DateTime? filterStartDate,
      DateTime? filterEndDate,
      TimePeriod selectedPeriod,
    )
    loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
      List<RatingHistoryEntry> history,
      List<RatingHistoryEntry> filteredHistory,
      DateTime? filterStartDate,
      DateTime? filterEndDate,
      TimePeriod selectedPeriod,
    )?
    loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
      List<RatingHistoryEntry> history,
      List<RatingHistoryEntry> filteredHistory,
      DateTime? filterStartDate,
      DateTime? filterEndDate,
      TimePeriod selectedPeriod,
    )?
    loaded,
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
    required TResult Function(EloHistoryInitial value) initial,
    required TResult Function(EloHistoryLoading value) loading,
    required TResult Function(EloHistoryLoaded value) loaded,
    required TResult Function(EloHistoryError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(EloHistoryInitial value)? initial,
    TResult? Function(EloHistoryLoading value)? loading,
    TResult? Function(EloHistoryLoaded value)? loaded,
    TResult? Function(EloHistoryError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(EloHistoryInitial value)? initial,
    TResult Function(EloHistoryLoading value)? loading,
    TResult Function(EloHistoryLoaded value)? loaded,
    TResult Function(EloHistoryError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class EloHistoryError implements EloHistoryState {
  const factory EloHistoryError({required final String message}) =
      _$EloHistoryErrorImpl;

  String get message;

  /// Create a copy of EloHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EloHistoryErrorImplCopyWith<_$EloHistoryErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
