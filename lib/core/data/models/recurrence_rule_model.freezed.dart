// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurrence_rule_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RecurrenceRuleModel _$RecurrenceRuleModelFromJson(Map<String, dynamic> json) {
  return _RecurrenceRuleModel.fromJson(json);
}

/// @nodoc
mixin _$RecurrenceRuleModel {
  /// The frequency of recurrence (weekly, monthly, or none)
  RecurrenceFrequency get frequency => throw _privateConstructorUsedError;

  /// The interval between occurrences (e.g., every 1 week, every 2 months)
  /// Must be >= 1
  int get interval => throw _privateConstructorUsedError;

  /// The number of occurrences to generate
  /// Either count or endDate should be specified, not both
  int? get count => throw _privateConstructorUsedError;

  /// The date until which to generate occurrences
  /// Either count or endDate should be specified, not both
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get endDate => throw _privateConstructorUsedError;

  /// Days of the week for weekly recurrence (1 = Monday, 7 = Sunday)
  /// Only applicable when frequency is weekly
  /// If null or empty for weekly recurrence, defaults to the same day as the parent session
  List<int>? get daysOfWeek => throw _privateConstructorUsedError;

  /// Serializes this RecurrenceRuleModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecurrenceRuleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecurrenceRuleModelCopyWith<RecurrenceRuleModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecurrenceRuleModelCopyWith<$Res> {
  factory $RecurrenceRuleModelCopyWith(
    RecurrenceRuleModel value,
    $Res Function(RecurrenceRuleModel) then,
  ) = _$RecurrenceRuleModelCopyWithImpl<$Res, RecurrenceRuleModel>;
  @useResult
  $Res call({
    RecurrenceFrequency frequency,
    int interval,
    int? count,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? endDate,
    List<int>? daysOfWeek,
  });
}

/// @nodoc
class _$RecurrenceRuleModelCopyWithImpl<$Res, $Val extends RecurrenceRuleModel>
    implements $RecurrenceRuleModelCopyWith<$Res> {
  _$RecurrenceRuleModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecurrenceRuleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frequency = null,
    Object? interval = null,
    Object? count = freezed,
    Object? endDate = freezed,
    Object? daysOfWeek = freezed,
  }) {
    return _then(
      _value.copyWith(
            frequency: null == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                      as RecurrenceFrequency,
            interval: null == interval
                ? _value.interval
                : interval // ignore: cast_nullable_to_non_nullable
                      as int,
            count: freezed == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                      as int?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            daysOfWeek: freezed == daysOfWeek
                ? _value.daysOfWeek
                : daysOfWeek // ignore: cast_nullable_to_non_nullable
                      as List<int>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecurrenceRuleModelImplCopyWith<$Res>
    implements $RecurrenceRuleModelCopyWith<$Res> {
  factory _$$RecurrenceRuleModelImplCopyWith(
    _$RecurrenceRuleModelImpl value,
    $Res Function(_$RecurrenceRuleModelImpl) then,
  ) = __$$RecurrenceRuleModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    RecurrenceFrequency frequency,
    int interval,
    int? count,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime? endDate,
    List<int>? daysOfWeek,
  });
}

/// @nodoc
class __$$RecurrenceRuleModelImplCopyWithImpl<$Res>
    extends _$RecurrenceRuleModelCopyWithImpl<$Res, _$RecurrenceRuleModelImpl>
    implements _$$RecurrenceRuleModelImplCopyWith<$Res> {
  __$$RecurrenceRuleModelImplCopyWithImpl(
    _$RecurrenceRuleModelImpl _value,
    $Res Function(_$RecurrenceRuleModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecurrenceRuleModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frequency = null,
    Object? interval = null,
    Object? count = freezed,
    Object? endDate = freezed,
    Object? daysOfWeek = freezed,
  }) {
    return _then(
      _$RecurrenceRuleModelImpl(
        frequency: null == frequency
            ? _value.frequency
            : frequency // ignore: cast_nullable_to_non_nullable
                  as RecurrenceFrequency,
        interval: null == interval
            ? _value.interval
            : interval // ignore: cast_nullable_to_non_nullable
                  as int,
        count: freezed == count
            ? _value.count
            : count // ignore: cast_nullable_to_non_nullable
                  as int?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        daysOfWeek: freezed == daysOfWeek
            ? _value._daysOfWeek
            : daysOfWeek // ignore: cast_nullable_to_non_nullable
                  as List<int>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecurrenceRuleModelImpl extends _RecurrenceRuleModel {
  const _$RecurrenceRuleModelImpl({
    this.frequency = RecurrenceFrequency.none,
    this.interval = 1,
    this.count,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) this.endDate,
    final List<int>? daysOfWeek,
  }) : _daysOfWeek = daysOfWeek,
       super._();

  factory _$RecurrenceRuleModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecurrenceRuleModelImplFromJson(json);

  /// The frequency of recurrence (weekly, monthly, or none)
  @override
  @JsonKey()
  final RecurrenceFrequency frequency;

  /// The interval between occurrences (e.g., every 1 week, every 2 months)
  /// Must be >= 1
  @override
  @JsonKey()
  final int interval;

  /// The number of occurrences to generate
  /// Either count or endDate should be specified, not both
  @override
  final int? count;

  /// The date until which to generate occurrences
  /// Either count or endDate should be specified, not both
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? endDate;

  /// Days of the week for weekly recurrence (1 = Monday, 7 = Sunday)
  /// Only applicable when frequency is weekly
  /// If null or empty for weekly recurrence, defaults to the same day as the parent session
  final List<int>? _daysOfWeek;

  /// Days of the week for weekly recurrence (1 = Monday, 7 = Sunday)
  /// Only applicable when frequency is weekly
  /// If null or empty for weekly recurrence, defaults to the same day as the parent session
  @override
  List<int>? get daysOfWeek {
    final value = _daysOfWeek;
    if (value == null) return null;
    if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'RecurrenceRuleModel(frequency: $frequency, interval: $interval, count: $count, endDate: $endDate, daysOfWeek: $daysOfWeek)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecurrenceRuleModelImpl &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality().equals(
              other._daysOfWeek,
              _daysOfWeek,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    frequency,
    interval,
    count,
    endDate,
    const DeepCollectionEquality().hash(_daysOfWeek),
  );

  /// Create a copy of RecurrenceRuleModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecurrenceRuleModelImplCopyWith<_$RecurrenceRuleModelImpl> get copyWith =>
      __$$RecurrenceRuleModelImplCopyWithImpl<_$RecurrenceRuleModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecurrenceRuleModelImplToJson(this);
  }
}

abstract class _RecurrenceRuleModel extends RecurrenceRuleModel {
  const factory _RecurrenceRuleModel({
    final RecurrenceFrequency frequency,
    final int interval,
    final int? count,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    final DateTime? endDate,
    final List<int>? daysOfWeek,
  }) = _$RecurrenceRuleModelImpl;
  const _RecurrenceRuleModel._() : super._();

  factory _RecurrenceRuleModel.fromJson(Map<String, dynamic> json) =
      _$RecurrenceRuleModelImpl.fromJson;

  /// The frequency of recurrence (weekly, monthly, or none)
  @override
  RecurrenceFrequency get frequency;

  /// The interval between occurrences (e.g., every 1 week, every 2 months)
  /// Must be >= 1
  @override
  int get interval;

  /// The number of occurrences to generate
  /// Either count or endDate should be specified, not both
  @override
  int? get count;

  /// The date until which to generate occurrences
  /// Either count or endDate should be specified, not both
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get endDate;

  /// Days of the week for weekly recurrence (1 = Monday, 7 = Sunday)
  /// Only applicable when frequency is weekly
  /// If null or empty for weekly recurrence, defaults to the same day as the parent session
  @override
  List<int>? get daysOfWeek;

  /// Create a copy of RecurrenceRuleModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecurrenceRuleModelImplCopyWith<_$RecurrenceRuleModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
