// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'elo_history_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$EloHistoryEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId, int limit) loadHistory,
    required TResult Function(TimePeriod period) filterByPeriod,
    required TResult Function(DateTime startDate, DateTime endDate)
    filterByDateRange,
    required TResult Function() clearFilter,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId, int limit)? loadHistory,
    TResult? Function(TimePeriod period)? filterByPeriod,
    TResult? Function(DateTime startDate, DateTime endDate)? filterByDateRange,
    TResult? Function()? clearFilter,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId, int limit)? loadHistory,
    TResult Function(TimePeriod period)? filterByPeriod,
    TResult Function(DateTime startDate, DateTime endDate)? filterByDateRange,
    TResult Function()? clearFilter,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadEloHistory value) loadHistory,
    required TResult Function(FilterByPeriod value) filterByPeriod,
    required TResult Function(FilterByDateRange value) filterByDateRange,
    required TResult Function(ClearFilter value) clearFilter,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadEloHistory value)? loadHistory,
    TResult? Function(FilterByPeriod value)? filterByPeriod,
    TResult? Function(FilterByDateRange value)? filterByDateRange,
    TResult? Function(ClearFilter value)? clearFilter,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadEloHistory value)? loadHistory,
    TResult Function(FilterByPeriod value)? filterByPeriod,
    TResult Function(FilterByDateRange value)? filterByDateRange,
    TResult Function(ClearFilter value)? clearFilter,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EloHistoryEventCopyWith<$Res> {
  factory $EloHistoryEventCopyWith(
    EloHistoryEvent value,
    $Res Function(EloHistoryEvent) then,
  ) = _$EloHistoryEventCopyWithImpl<$Res, EloHistoryEvent>;
}

/// @nodoc
class _$EloHistoryEventCopyWithImpl<$Res, $Val extends EloHistoryEvent>
    implements $EloHistoryEventCopyWith<$Res> {
  _$EloHistoryEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EloHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadEloHistoryImplCopyWith<$Res> {
  factory _$$LoadEloHistoryImplCopyWith(
    _$LoadEloHistoryImpl value,
    $Res Function(_$LoadEloHistoryImpl) then,
  ) = __$$LoadEloHistoryImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String userId, int limit});
}

/// @nodoc
class __$$LoadEloHistoryImplCopyWithImpl<$Res>
    extends _$EloHistoryEventCopyWithImpl<$Res, _$LoadEloHistoryImpl>
    implements _$$LoadEloHistoryImplCopyWith<$Res> {
  __$$LoadEloHistoryImplCopyWithImpl(
    _$LoadEloHistoryImpl _value,
    $Res Function(_$LoadEloHistoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EloHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null, Object? limit = null}) {
    return _then(
      _$LoadEloHistoryImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        limit: null == limit
            ? _value.limit
            : limit // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$LoadEloHistoryImpl implements LoadEloHistory {
  const _$LoadEloHistoryImpl({required this.userId, this.limit = 100});

  @override
  final String userId;
  @override
  @JsonKey()
  final int limit;

  @override
  String toString() {
    return 'EloHistoryEvent.loadHistory(userId: $userId, limit: $limit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadEloHistoryImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.limit, limit) || other.limit == limit));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId, limit);

  /// Create a copy of EloHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadEloHistoryImplCopyWith<_$LoadEloHistoryImpl> get copyWith =>
      __$$LoadEloHistoryImplCopyWithImpl<_$LoadEloHistoryImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId, int limit) loadHistory,
    required TResult Function(TimePeriod period) filterByPeriod,
    required TResult Function(DateTime startDate, DateTime endDate)
    filterByDateRange,
    required TResult Function() clearFilter,
  }) {
    return loadHistory(userId, limit);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId, int limit)? loadHistory,
    TResult? Function(TimePeriod period)? filterByPeriod,
    TResult? Function(DateTime startDate, DateTime endDate)? filterByDateRange,
    TResult? Function()? clearFilter,
  }) {
    return loadHistory?.call(userId, limit);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId, int limit)? loadHistory,
    TResult Function(TimePeriod period)? filterByPeriod,
    TResult Function(DateTime startDate, DateTime endDate)? filterByDateRange,
    TResult Function()? clearFilter,
    required TResult orElse(),
  }) {
    if (loadHistory != null) {
      return loadHistory(userId, limit);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadEloHistory value) loadHistory,
    required TResult Function(FilterByPeriod value) filterByPeriod,
    required TResult Function(FilterByDateRange value) filterByDateRange,
    required TResult Function(ClearFilter value) clearFilter,
  }) {
    return loadHistory(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadEloHistory value)? loadHistory,
    TResult? Function(FilterByPeriod value)? filterByPeriod,
    TResult? Function(FilterByDateRange value)? filterByDateRange,
    TResult? Function(ClearFilter value)? clearFilter,
  }) {
    return loadHistory?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadEloHistory value)? loadHistory,
    TResult Function(FilterByPeriod value)? filterByPeriod,
    TResult Function(FilterByDateRange value)? filterByDateRange,
    TResult Function(ClearFilter value)? clearFilter,
    required TResult orElse(),
  }) {
    if (loadHistory != null) {
      return loadHistory(this);
    }
    return orElse();
  }
}

abstract class LoadEloHistory implements EloHistoryEvent {
  const factory LoadEloHistory({
    required final String userId,
    final int limit,
  }) = _$LoadEloHistoryImpl;

  String get userId;
  int get limit;

  /// Create a copy of EloHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadEloHistoryImplCopyWith<_$LoadEloHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FilterByPeriodImplCopyWith<$Res> {
  factory _$$FilterByPeriodImplCopyWith(
    _$FilterByPeriodImpl value,
    $Res Function(_$FilterByPeriodImpl) then,
  ) = __$$FilterByPeriodImplCopyWithImpl<$Res>;
  @useResult
  $Res call({TimePeriod period});
}

/// @nodoc
class __$$FilterByPeriodImplCopyWithImpl<$Res>
    extends _$EloHistoryEventCopyWithImpl<$Res, _$FilterByPeriodImpl>
    implements _$$FilterByPeriodImplCopyWith<$Res> {
  __$$FilterByPeriodImplCopyWithImpl(
    _$FilterByPeriodImpl _value,
    $Res Function(_$FilterByPeriodImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EloHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? period = null}) {
    return _then(
      _$FilterByPeriodImpl(
        null == period
            ? _value.period
            : period // ignore: cast_nullable_to_non_nullable
                  as TimePeriod,
      ),
    );
  }
}

/// @nodoc

class _$FilterByPeriodImpl implements FilterByPeriod {
  const _$FilterByPeriodImpl(this.period);

  @override
  final TimePeriod period;

  @override
  String toString() {
    return 'EloHistoryEvent.filterByPeriod(period: $period)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FilterByPeriodImpl &&
            (identical(other.period, period) || other.period == period));
  }

  @override
  int get hashCode => Object.hash(runtimeType, period);

  /// Create a copy of EloHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FilterByPeriodImplCopyWith<_$FilterByPeriodImpl> get copyWith =>
      __$$FilterByPeriodImplCopyWithImpl<_$FilterByPeriodImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId, int limit) loadHistory,
    required TResult Function(TimePeriod period) filterByPeriod,
    required TResult Function(DateTime startDate, DateTime endDate)
    filterByDateRange,
    required TResult Function() clearFilter,
  }) {
    return filterByPeriod(period);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId, int limit)? loadHistory,
    TResult? Function(TimePeriod period)? filterByPeriod,
    TResult? Function(DateTime startDate, DateTime endDate)? filterByDateRange,
    TResult? Function()? clearFilter,
  }) {
    return filterByPeriod?.call(period);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId, int limit)? loadHistory,
    TResult Function(TimePeriod period)? filterByPeriod,
    TResult Function(DateTime startDate, DateTime endDate)? filterByDateRange,
    TResult Function()? clearFilter,
    required TResult orElse(),
  }) {
    if (filterByPeriod != null) {
      return filterByPeriod(period);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadEloHistory value) loadHistory,
    required TResult Function(FilterByPeriod value) filterByPeriod,
    required TResult Function(FilterByDateRange value) filterByDateRange,
    required TResult Function(ClearFilter value) clearFilter,
  }) {
    return filterByPeriod(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadEloHistory value)? loadHistory,
    TResult? Function(FilterByPeriod value)? filterByPeriod,
    TResult? Function(FilterByDateRange value)? filterByDateRange,
    TResult? Function(ClearFilter value)? clearFilter,
  }) {
    return filterByPeriod?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadEloHistory value)? loadHistory,
    TResult Function(FilterByPeriod value)? filterByPeriod,
    TResult Function(FilterByDateRange value)? filterByDateRange,
    TResult Function(ClearFilter value)? clearFilter,
    required TResult orElse(),
  }) {
    if (filterByPeriod != null) {
      return filterByPeriod(this);
    }
    return orElse();
  }
}

abstract class FilterByPeriod implements EloHistoryEvent {
  const factory FilterByPeriod(final TimePeriod period) = _$FilterByPeriodImpl;

  TimePeriod get period;

  /// Create a copy of EloHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FilterByPeriodImplCopyWith<_$FilterByPeriodImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FilterByDateRangeImplCopyWith<$Res> {
  factory _$$FilterByDateRangeImplCopyWith(
    _$FilterByDateRangeImpl value,
    $Res Function(_$FilterByDateRangeImpl) then,
  ) = __$$FilterByDateRangeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({DateTime startDate, DateTime endDate});
}

/// @nodoc
class __$$FilterByDateRangeImplCopyWithImpl<$Res>
    extends _$EloHistoryEventCopyWithImpl<$Res, _$FilterByDateRangeImpl>
    implements _$$FilterByDateRangeImplCopyWith<$Res> {
  __$$FilterByDateRangeImplCopyWithImpl(
    _$FilterByDateRangeImpl _value,
    $Res Function(_$FilterByDateRangeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EloHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? startDate = null, Object? endDate = null}) {
    return _then(
      _$FilterByDateRangeImpl(
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$FilterByDateRangeImpl implements FilterByDateRange {
  const _$FilterByDateRangeImpl({
    required this.startDate,
    required this.endDate,
  });

  @override
  final DateTime startDate;
  @override
  final DateTime endDate;

  @override
  String toString() {
    return 'EloHistoryEvent.filterByDateRange(startDate: $startDate, endDate: $endDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FilterByDateRangeImpl &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate));
  }

  @override
  int get hashCode => Object.hash(runtimeType, startDate, endDate);

  /// Create a copy of EloHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FilterByDateRangeImplCopyWith<_$FilterByDateRangeImpl> get copyWith =>
      __$$FilterByDateRangeImplCopyWithImpl<_$FilterByDateRangeImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId, int limit) loadHistory,
    required TResult Function(TimePeriod period) filterByPeriod,
    required TResult Function(DateTime startDate, DateTime endDate)
    filterByDateRange,
    required TResult Function() clearFilter,
  }) {
    return filterByDateRange(startDate, endDate);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId, int limit)? loadHistory,
    TResult? Function(TimePeriod period)? filterByPeriod,
    TResult? Function(DateTime startDate, DateTime endDate)? filterByDateRange,
    TResult? Function()? clearFilter,
  }) {
    return filterByDateRange?.call(startDate, endDate);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId, int limit)? loadHistory,
    TResult Function(TimePeriod period)? filterByPeriod,
    TResult Function(DateTime startDate, DateTime endDate)? filterByDateRange,
    TResult Function()? clearFilter,
    required TResult orElse(),
  }) {
    if (filterByDateRange != null) {
      return filterByDateRange(startDate, endDate);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadEloHistory value) loadHistory,
    required TResult Function(FilterByPeriod value) filterByPeriod,
    required TResult Function(FilterByDateRange value) filterByDateRange,
    required TResult Function(ClearFilter value) clearFilter,
  }) {
    return filterByDateRange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadEloHistory value)? loadHistory,
    TResult? Function(FilterByPeriod value)? filterByPeriod,
    TResult? Function(FilterByDateRange value)? filterByDateRange,
    TResult? Function(ClearFilter value)? clearFilter,
  }) {
    return filterByDateRange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadEloHistory value)? loadHistory,
    TResult Function(FilterByPeriod value)? filterByPeriod,
    TResult Function(FilterByDateRange value)? filterByDateRange,
    TResult Function(ClearFilter value)? clearFilter,
    required TResult orElse(),
  }) {
    if (filterByDateRange != null) {
      return filterByDateRange(this);
    }
    return orElse();
  }
}

abstract class FilterByDateRange implements EloHistoryEvent {
  const factory FilterByDateRange({
    required final DateTime startDate,
    required final DateTime endDate,
  }) = _$FilterByDateRangeImpl;

  DateTime get startDate;
  DateTime get endDate;

  /// Create a copy of EloHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FilterByDateRangeImplCopyWith<_$FilterByDateRangeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ClearFilterImplCopyWith<$Res> {
  factory _$$ClearFilterImplCopyWith(
    _$ClearFilterImpl value,
    $Res Function(_$ClearFilterImpl) then,
  ) = __$$ClearFilterImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$ClearFilterImplCopyWithImpl<$Res>
    extends _$EloHistoryEventCopyWithImpl<$Res, _$ClearFilterImpl>
    implements _$$ClearFilterImplCopyWith<$Res> {
  __$$ClearFilterImplCopyWithImpl(
    _$ClearFilterImpl _value,
    $Res Function(_$ClearFilterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EloHistoryEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$ClearFilterImpl implements ClearFilter {
  const _$ClearFilterImpl();

  @override
  String toString() {
    return 'EloHistoryEvent.clearFilter()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$ClearFilterImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String userId, int limit) loadHistory,
    required TResult Function(TimePeriod period) filterByPeriod,
    required TResult Function(DateTime startDate, DateTime endDate)
    filterByDateRange,
    required TResult Function() clearFilter,
  }) {
    return clearFilter();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String userId, int limit)? loadHistory,
    TResult? Function(TimePeriod period)? filterByPeriod,
    TResult? Function(DateTime startDate, DateTime endDate)? filterByDateRange,
    TResult? Function()? clearFilter,
  }) {
    return clearFilter?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String userId, int limit)? loadHistory,
    TResult Function(TimePeriod period)? filterByPeriod,
    TResult Function(DateTime startDate, DateTime endDate)? filterByDateRange,
    TResult Function()? clearFilter,
    required TResult orElse(),
  }) {
    if (clearFilter != null) {
      return clearFilter();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadEloHistory value) loadHistory,
    required TResult Function(FilterByPeriod value) filterByPeriod,
    required TResult Function(FilterByDateRange value) filterByDateRange,
    required TResult Function(ClearFilter value) clearFilter,
  }) {
    return clearFilter(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadEloHistory value)? loadHistory,
    TResult? Function(FilterByPeriod value)? filterByPeriod,
    TResult? Function(FilterByDateRange value)? filterByDateRange,
    TResult? Function(ClearFilter value)? clearFilter,
  }) {
    return clearFilter?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadEloHistory value)? loadHistory,
    TResult Function(FilterByPeriod value)? filterByPeriod,
    TResult Function(FilterByDateRange value)? filterByDateRange,
    TResult Function(ClearFilter value)? clearFilter,
    required TResult orElse(),
  }) {
    if (clearFilter != null) {
      return clearFilter(this);
    }
    return orElse();
  }
}

abstract class ClearFilter implements EloHistoryEvent {
  const factory ClearFilter() = _$ClearFilterImpl;
}
