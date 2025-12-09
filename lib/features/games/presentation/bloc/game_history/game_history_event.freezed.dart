// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_history_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GameHistoryEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )
    load,
    required TResult Function() loadMore,
    required TResult Function() refresh,
    required TResult Function(GameHistoryFilter filter) filterChanged,
    required TResult Function(DateTime? startDate, DateTime? endDate)
    dateRangeChanged,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )?
    load,
    TResult? Function()? loadMore,
    TResult? Function()? refresh,
    TResult? Function(GameHistoryFilter filter)? filterChanged,
    TResult? Function(DateTime? startDate, DateTime? endDate)? dateRangeChanged,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )?
    load,
    TResult Function()? loadMore,
    TResult Function()? refresh,
    TResult Function(GameHistoryFilter filter)? filterChanged,
    TResult Function(DateTime? startDate, DateTime? endDate)? dateRangeChanged,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHistoryLoadEvent value) load,
    required TResult Function(GameHistoryLoadMoreEvent value) loadMore,
    required TResult Function(GameHistoryRefreshEvent value) refresh,
    required TResult Function(GameHistoryFilterChangedEvent value)
    filterChanged,
    required TResult Function(GameHistoryDateRangeChangedEvent value)
    dateRangeChanged,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHistoryLoadEvent value)? load,
    TResult? Function(GameHistoryLoadMoreEvent value)? loadMore,
    TResult? Function(GameHistoryRefreshEvent value)? refresh,
    TResult? Function(GameHistoryFilterChangedEvent value)? filterChanged,
    TResult? Function(GameHistoryDateRangeChangedEvent value)? dateRangeChanged,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHistoryLoadEvent value)? load,
    TResult Function(GameHistoryLoadMoreEvent value)? loadMore,
    TResult Function(GameHistoryRefreshEvent value)? refresh,
    TResult Function(GameHistoryFilterChangedEvent value)? filterChanged,
    TResult Function(GameHistoryDateRangeChangedEvent value)? dateRangeChanged,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameHistoryEventCopyWith<$Res> {
  factory $GameHistoryEventCopyWith(
    GameHistoryEvent value,
    $Res Function(GameHistoryEvent) then,
  ) = _$GameHistoryEventCopyWithImpl<$Res, GameHistoryEvent>;
}

/// @nodoc
class _$GameHistoryEventCopyWithImpl<$Res, $Val extends GameHistoryEvent>
    implements $GameHistoryEventCopyWith<$Res> {
  _$GameHistoryEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$GameHistoryLoadEventImplCopyWith<$Res> {
  factory _$$GameHistoryLoadEventImplCopyWith(
    _$GameHistoryLoadEventImpl value,
    $Res Function(_$GameHistoryLoadEventImpl) then,
  ) = __$$GameHistoryLoadEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String? groupId,
    String userId,
    GameHistoryFilter filter,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// @nodoc
class __$$GameHistoryLoadEventImplCopyWithImpl<$Res>
    extends _$GameHistoryEventCopyWithImpl<$Res, _$GameHistoryLoadEventImpl>
    implements _$$GameHistoryLoadEventImplCopyWith<$Res> {
  __$$GameHistoryLoadEventImplCopyWithImpl(
    _$GameHistoryLoadEventImpl _value,
    $Res Function(_$GameHistoryLoadEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? groupId = freezed,
    Object? userId = null,
    Object? filter = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
  }) {
    return _then(
      _$GameHistoryLoadEventImpl(
        groupId: freezed == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        filter: null == filter
            ? _value.filter
            : filter // ignore: cast_nullable_to_non_nullable
                  as GameHistoryFilter,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$GameHistoryLoadEventImpl implements GameHistoryLoadEvent {
  const _$GameHistoryLoadEventImpl({
    this.groupId,
    required this.userId,
    this.filter = GameHistoryFilter.all,
    this.startDate,
    this.endDate,
  });

  @override
  final String? groupId;
  @override
  final String userId;
  @override
  @JsonKey()
  final GameHistoryFilter filter;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;

  @override
  String toString() {
    return 'GameHistoryEvent.load(groupId: $groupId, userId: $userId, filter: $filter, startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHistoryLoadEventImpl &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.filter, filter) || other.filter == filter) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, groupId, userId, filter, startDate, endDate);

  /// Create a copy of GameHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHistoryLoadEventImplCopyWith<_$GameHistoryLoadEventImpl>
  get copyWith =>
      __$$GameHistoryLoadEventImplCopyWithImpl<_$GameHistoryLoadEventImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )
    load,
    required TResult Function() loadMore,
    required TResult Function() refresh,
    required TResult Function(GameHistoryFilter filter) filterChanged,
    required TResult Function(DateTime? startDate, DateTime? endDate)
    dateRangeChanged,
  }) {
    return load(groupId, userId, filter, startDate, endDate);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )?
    load,
    TResult? Function()? loadMore,
    TResult? Function()? refresh,
    TResult? Function(GameHistoryFilter filter)? filterChanged,
    TResult? Function(DateTime? startDate, DateTime? endDate)? dateRangeChanged,
  }) {
    return load?.call(groupId, userId, filter, startDate, endDate);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )?
    load,
    TResult Function()? loadMore,
    TResult Function()? refresh,
    TResult Function(GameHistoryFilter filter)? filterChanged,
    TResult Function(DateTime? startDate, DateTime? endDate)? dateRangeChanged,
    required TResult orElse(),
  }) {
    if (load != null) {
      return load(groupId, userId, filter, startDate, endDate);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHistoryLoadEvent value) load,
    required TResult Function(GameHistoryLoadMoreEvent value) loadMore,
    required TResult Function(GameHistoryRefreshEvent value) refresh,
    required TResult Function(GameHistoryFilterChangedEvent value)
    filterChanged,
    required TResult Function(GameHistoryDateRangeChangedEvent value)
    dateRangeChanged,
  }) {
    return load(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHistoryLoadEvent value)? load,
    TResult? Function(GameHistoryLoadMoreEvent value)? loadMore,
    TResult? Function(GameHistoryRefreshEvent value)? refresh,
    TResult? Function(GameHistoryFilterChangedEvent value)? filterChanged,
    TResult? Function(GameHistoryDateRangeChangedEvent value)? dateRangeChanged,
  }) {
    return load?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHistoryLoadEvent value)? load,
    TResult Function(GameHistoryLoadMoreEvent value)? loadMore,
    TResult Function(GameHistoryRefreshEvent value)? refresh,
    TResult Function(GameHistoryFilterChangedEvent value)? filterChanged,
    TResult Function(GameHistoryDateRangeChangedEvent value)? dateRangeChanged,
    required TResult orElse(),
  }) {
    if (load != null) {
      return load(this);
    }
    return orElse();
  }
}

abstract class GameHistoryLoadEvent implements GameHistoryEvent {
  const factory GameHistoryLoadEvent({
    final String? groupId,
    required final String userId,
    final GameHistoryFilter filter,
    final DateTime? startDate,
    final DateTime? endDate,
  }) = _$GameHistoryLoadEventImpl;

  String? get groupId;
  String get userId;
  GameHistoryFilter get filter;
  DateTime? get startDate;
  DateTime? get endDate;

  /// Create a copy of GameHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHistoryLoadEventImplCopyWith<_$GameHistoryLoadEventImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameHistoryLoadMoreEventImplCopyWith<$Res> {
  factory _$$GameHistoryLoadMoreEventImplCopyWith(
    _$GameHistoryLoadMoreEventImpl value,
    $Res Function(_$GameHistoryLoadMoreEventImpl) then,
  ) = __$$GameHistoryLoadMoreEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GameHistoryLoadMoreEventImplCopyWithImpl<$Res>
    extends _$GameHistoryEventCopyWithImpl<$Res, _$GameHistoryLoadMoreEventImpl>
    implements _$$GameHistoryLoadMoreEventImplCopyWith<$Res> {
  __$$GameHistoryLoadMoreEventImplCopyWithImpl(
    _$GameHistoryLoadMoreEventImpl _value,
    $Res Function(_$GameHistoryLoadMoreEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GameHistoryLoadMoreEventImpl implements GameHistoryLoadMoreEvent {
  const _$GameHistoryLoadMoreEventImpl();

  @override
  String toString() {
    return 'GameHistoryEvent.loadMore()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHistoryLoadMoreEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )
    load,
    required TResult Function() loadMore,
    required TResult Function() refresh,
    required TResult Function(GameHistoryFilter filter) filterChanged,
    required TResult Function(DateTime? startDate, DateTime? endDate)
    dateRangeChanged,
  }) {
    return loadMore();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )?
    load,
    TResult? Function()? loadMore,
    TResult? Function()? refresh,
    TResult? Function(GameHistoryFilter filter)? filterChanged,
    TResult? Function(DateTime? startDate, DateTime? endDate)? dateRangeChanged,
  }) {
    return loadMore?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )?
    load,
    TResult Function()? loadMore,
    TResult Function()? refresh,
    TResult Function(GameHistoryFilter filter)? filterChanged,
    TResult Function(DateTime? startDate, DateTime? endDate)? dateRangeChanged,
    required TResult orElse(),
  }) {
    if (loadMore != null) {
      return loadMore();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHistoryLoadEvent value) load,
    required TResult Function(GameHistoryLoadMoreEvent value) loadMore,
    required TResult Function(GameHistoryRefreshEvent value) refresh,
    required TResult Function(GameHistoryFilterChangedEvent value)
    filterChanged,
    required TResult Function(GameHistoryDateRangeChangedEvent value)
    dateRangeChanged,
  }) {
    return loadMore(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHistoryLoadEvent value)? load,
    TResult? Function(GameHistoryLoadMoreEvent value)? loadMore,
    TResult? Function(GameHistoryRefreshEvent value)? refresh,
    TResult? Function(GameHistoryFilterChangedEvent value)? filterChanged,
    TResult? Function(GameHistoryDateRangeChangedEvent value)? dateRangeChanged,
  }) {
    return loadMore?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHistoryLoadEvent value)? load,
    TResult Function(GameHistoryLoadMoreEvent value)? loadMore,
    TResult Function(GameHistoryRefreshEvent value)? refresh,
    TResult Function(GameHistoryFilterChangedEvent value)? filterChanged,
    TResult Function(GameHistoryDateRangeChangedEvent value)? dateRangeChanged,
    required TResult orElse(),
  }) {
    if (loadMore != null) {
      return loadMore(this);
    }
    return orElse();
  }
}

abstract class GameHistoryLoadMoreEvent implements GameHistoryEvent {
  const factory GameHistoryLoadMoreEvent() = _$GameHistoryLoadMoreEventImpl;
}

/// @nodoc
abstract class _$$GameHistoryRefreshEventImplCopyWith<$Res> {
  factory _$$GameHistoryRefreshEventImplCopyWith(
    _$GameHistoryRefreshEventImpl value,
    $Res Function(_$GameHistoryRefreshEventImpl) then,
  ) = __$$GameHistoryRefreshEventImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GameHistoryRefreshEventImplCopyWithImpl<$Res>
    extends _$GameHistoryEventCopyWithImpl<$Res, _$GameHistoryRefreshEventImpl>
    implements _$$GameHistoryRefreshEventImplCopyWith<$Res> {
  __$$GameHistoryRefreshEventImplCopyWithImpl(
    _$GameHistoryRefreshEventImpl _value,
    $Res Function(_$GameHistoryRefreshEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GameHistoryRefreshEventImpl implements GameHistoryRefreshEvent {
  const _$GameHistoryRefreshEventImpl();

  @override
  String toString() {
    return 'GameHistoryEvent.refresh()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHistoryRefreshEventImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )
    load,
    required TResult Function() loadMore,
    required TResult Function() refresh,
    required TResult Function(GameHistoryFilter filter) filterChanged,
    required TResult Function(DateTime? startDate, DateTime? endDate)
    dateRangeChanged,
  }) {
    return refresh();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )?
    load,
    TResult? Function()? loadMore,
    TResult? Function()? refresh,
    TResult? Function(GameHistoryFilter filter)? filterChanged,
    TResult? Function(DateTime? startDate, DateTime? endDate)? dateRangeChanged,
  }) {
    return refresh?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )?
    load,
    TResult Function()? loadMore,
    TResult Function()? refresh,
    TResult Function(GameHistoryFilter filter)? filterChanged,
    TResult Function(DateTime? startDate, DateTime? endDate)? dateRangeChanged,
    required TResult orElse(),
  }) {
    if (refresh != null) {
      return refresh();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHistoryLoadEvent value) load,
    required TResult Function(GameHistoryLoadMoreEvent value) loadMore,
    required TResult Function(GameHistoryRefreshEvent value) refresh,
    required TResult Function(GameHistoryFilterChangedEvent value)
    filterChanged,
    required TResult Function(GameHistoryDateRangeChangedEvent value)
    dateRangeChanged,
  }) {
    return refresh(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHistoryLoadEvent value)? load,
    TResult? Function(GameHistoryLoadMoreEvent value)? loadMore,
    TResult? Function(GameHistoryRefreshEvent value)? refresh,
    TResult? Function(GameHistoryFilterChangedEvent value)? filterChanged,
    TResult? Function(GameHistoryDateRangeChangedEvent value)? dateRangeChanged,
  }) {
    return refresh?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHistoryLoadEvent value)? load,
    TResult Function(GameHistoryLoadMoreEvent value)? loadMore,
    TResult Function(GameHistoryRefreshEvent value)? refresh,
    TResult Function(GameHistoryFilterChangedEvent value)? filterChanged,
    TResult Function(GameHistoryDateRangeChangedEvent value)? dateRangeChanged,
    required TResult orElse(),
  }) {
    if (refresh != null) {
      return refresh(this);
    }
    return orElse();
  }
}

abstract class GameHistoryRefreshEvent implements GameHistoryEvent {
  const factory GameHistoryRefreshEvent() = _$GameHistoryRefreshEventImpl;
}

/// @nodoc
abstract class _$$GameHistoryFilterChangedEventImplCopyWith<$Res> {
  factory _$$GameHistoryFilterChangedEventImplCopyWith(
    _$GameHistoryFilterChangedEventImpl value,
    $Res Function(_$GameHistoryFilterChangedEventImpl) then,
  ) = __$$GameHistoryFilterChangedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({GameHistoryFilter filter});
}

/// @nodoc
class __$$GameHistoryFilterChangedEventImplCopyWithImpl<$Res>
    extends
        _$GameHistoryEventCopyWithImpl<
          $Res,
          _$GameHistoryFilterChangedEventImpl
        >
    implements _$$GameHistoryFilterChangedEventImplCopyWith<$Res> {
  __$$GameHistoryFilterChangedEventImplCopyWithImpl(
    _$GameHistoryFilterChangedEventImpl _value,
    $Res Function(_$GameHistoryFilterChangedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? filter = null}) {
    return _then(
      _$GameHistoryFilterChangedEventImpl(
        filter: null == filter
            ? _value.filter
            : filter // ignore: cast_nullable_to_non_nullable
                  as GameHistoryFilter,
      ),
    );
  }
}

/// @nodoc

class _$GameHistoryFilterChangedEventImpl
    implements GameHistoryFilterChangedEvent {
  const _$GameHistoryFilterChangedEventImpl({required this.filter});

  @override
  final GameHistoryFilter filter;

  @override
  String toString() {
    return 'GameHistoryEvent.filterChanged(filter: $filter)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHistoryFilterChangedEventImpl &&
            (identical(other.filter, filter) || other.filter == filter));
  }

  @override
  int get hashCode => Object.hash(runtimeType, filter);

  /// Create a copy of GameHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHistoryFilterChangedEventImplCopyWith<
    _$GameHistoryFilterChangedEventImpl
  >
  get copyWith =>
      __$$GameHistoryFilterChangedEventImplCopyWithImpl<
        _$GameHistoryFilterChangedEventImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )
    load,
    required TResult Function() loadMore,
    required TResult Function() refresh,
    required TResult Function(GameHistoryFilter filter) filterChanged,
    required TResult Function(DateTime? startDate, DateTime? endDate)
    dateRangeChanged,
  }) {
    return filterChanged(filter);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )?
    load,
    TResult? Function()? loadMore,
    TResult? Function()? refresh,
    TResult? Function(GameHistoryFilter filter)? filterChanged,
    TResult? Function(DateTime? startDate, DateTime? endDate)? dateRangeChanged,
  }) {
    return filterChanged?.call(filter);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )?
    load,
    TResult Function()? loadMore,
    TResult Function()? refresh,
    TResult Function(GameHistoryFilter filter)? filterChanged,
    TResult Function(DateTime? startDate, DateTime? endDate)? dateRangeChanged,
    required TResult orElse(),
  }) {
    if (filterChanged != null) {
      return filterChanged(filter);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHistoryLoadEvent value) load,
    required TResult Function(GameHistoryLoadMoreEvent value) loadMore,
    required TResult Function(GameHistoryRefreshEvent value) refresh,
    required TResult Function(GameHistoryFilterChangedEvent value)
    filterChanged,
    required TResult Function(GameHistoryDateRangeChangedEvent value)
    dateRangeChanged,
  }) {
    return filterChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHistoryLoadEvent value)? load,
    TResult? Function(GameHistoryLoadMoreEvent value)? loadMore,
    TResult? Function(GameHistoryRefreshEvent value)? refresh,
    TResult? Function(GameHistoryFilterChangedEvent value)? filterChanged,
    TResult? Function(GameHistoryDateRangeChangedEvent value)? dateRangeChanged,
  }) {
    return filterChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHistoryLoadEvent value)? load,
    TResult Function(GameHistoryLoadMoreEvent value)? loadMore,
    TResult Function(GameHistoryRefreshEvent value)? refresh,
    TResult Function(GameHistoryFilterChangedEvent value)? filterChanged,
    TResult Function(GameHistoryDateRangeChangedEvent value)? dateRangeChanged,
    required TResult orElse(),
  }) {
    if (filterChanged != null) {
      return filterChanged(this);
    }
    return orElse();
  }
}

abstract class GameHistoryFilterChangedEvent implements GameHistoryEvent {
  const factory GameHistoryFilterChangedEvent({
    required final GameHistoryFilter filter,
  }) = _$GameHistoryFilterChangedEventImpl;

  GameHistoryFilter get filter;

  /// Create a copy of GameHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHistoryFilterChangedEventImplCopyWith<
    _$GameHistoryFilterChangedEventImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GameHistoryDateRangeChangedEventImplCopyWith<$Res> {
  factory _$$GameHistoryDateRangeChangedEventImplCopyWith(
    _$GameHistoryDateRangeChangedEventImpl value,
    $Res Function(_$GameHistoryDateRangeChangedEventImpl) then,
  ) = __$$GameHistoryDateRangeChangedEventImplCopyWithImpl<$Res>;
  @useResult
  $Res call({DateTime? startDate, DateTime? endDate});
}

/// @nodoc
class __$$GameHistoryDateRangeChangedEventImplCopyWithImpl<$Res>
    extends
        _$GameHistoryEventCopyWithImpl<
          $Res,
          _$GameHistoryDateRangeChangedEventImpl
        >
    implements _$$GameHistoryDateRangeChangedEventImplCopyWith<$Res> {
  __$$GameHistoryDateRangeChangedEventImplCopyWithImpl(
    _$GameHistoryDateRangeChangedEventImpl _value,
    $Res Function(_$GameHistoryDateRangeChangedEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? startDate = freezed, Object? endDate = freezed}) {
    return _then(
      _$GameHistoryDateRangeChangedEventImpl(
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$GameHistoryDateRangeChangedEventImpl
    implements GameHistoryDateRangeChangedEvent {
  const _$GameHistoryDateRangeChangedEventImpl({this.startDate, this.endDate});

  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;

  @override
  String toString() {
    return 'GameHistoryEvent.dateRangeChanged(startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameHistoryDateRangeChangedEventImpl &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @override
  int get hashCode => Object.hash(runtimeType, startDate, endDate);

  /// Create a copy of GameHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameHistoryDateRangeChangedEventImplCopyWith<
    _$GameHistoryDateRangeChangedEventImpl
  >
  get copyWith =>
      __$$GameHistoryDateRangeChangedEventImplCopyWithImpl<
        _$GameHistoryDateRangeChangedEventImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )
    load,
    required TResult Function() loadMore,
    required TResult Function() refresh,
    required TResult Function(GameHistoryFilter filter) filterChanged,
    required TResult Function(DateTime? startDate, DateTime? endDate)
    dateRangeChanged,
  }) {
    return dateRangeChanged(startDate, endDate);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )?
    load,
    TResult? Function()? loadMore,
    TResult? Function()? refresh,
    TResult? Function(GameHistoryFilter filter)? filterChanged,
    TResult? Function(DateTime? startDate, DateTime? endDate)? dateRangeChanged,
  }) {
    return dateRangeChanged?.call(startDate, endDate);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
      String? groupId,
      String userId,
      GameHistoryFilter filter,
      DateTime? startDate,
      DateTime? endDate,
    )?
    load,
    TResult Function()? loadMore,
    TResult Function()? refresh,
    TResult Function(GameHistoryFilter filter)? filterChanged,
    TResult Function(DateTime? startDate, DateTime? endDate)? dateRangeChanged,
    required TResult orElse(),
  }) {
    if (dateRangeChanged != null) {
      return dateRangeChanged(startDate, endDate);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(GameHistoryLoadEvent value) load,
    required TResult Function(GameHistoryLoadMoreEvent value) loadMore,
    required TResult Function(GameHistoryRefreshEvent value) refresh,
    required TResult Function(GameHistoryFilterChangedEvent value)
    filterChanged,
    required TResult Function(GameHistoryDateRangeChangedEvent value)
    dateRangeChanged,
  }) {
    return dateRangeChanged(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(GameHistoryLoadEvent value)? load,
    TResult? Function(GameHistoryLoadMoreEvent value)? loadMore,
    TResult? Function(GameHistoryRefreshEvent value)? refresh,
    TResult? Function(GameHistoryFilterChangedEvent value)? filterChanged,
    TResult? Function(GameHistoryDateRangeChangedEvent value)? dateRangeChanged,
  }) {
    return dateRangeChanged?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(GameHistoryLoadEvent value)? load,
    TResult Function(GameHistoryLoadMoreEvent value)? loadMore,
    TResult Function(GameHistoryRefreshEvent value)? refresh,
    TResult Function(GameHistoryFilterChangedEvent value)? filterChanged,
    TResult Function(GameHistoryDateRangeChangedEvent value)? dateRangeChanged,
    required TResult orElse(),
  }) {
    if (dateRangeChanged != null) {
      return dateRangeChanged(this);
    }
    return orElse();
  }
}

abstract class GameHistoryDateRangeChangedEvent implements GameHistoryEvent {
  const factory GameHistoryDateRangeChangedEvent({
    final DateTime? startDate,
    final DateTime? endDate,
  }) = _$GameHistoryDateRangeChangedEventImpl;

  DateTime? get startDate;
  DateTime? get endDate;

  /// Create a copy of GameHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameHistoryDateRangeChangedEventImplCopyWith<
    _$GameHistoryDateRangeChangedEventImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
