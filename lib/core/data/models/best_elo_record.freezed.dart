// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'best_elo_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BestEloRecord _$BestEloRecordFromJson(Map<String, dynamic> json) {
  return _BestEloRecord.fromJson(json);
}

/// @nodoc
mixin _$BestEloRecord {
  /// The highest ELO rating achieved
  double get elo => throw _privateConstructorUsedError;

  /// The date when this ELO was achieved
  @RequiredTimestampConverter()
  DateTime get date => throw _privateConstructorUsedError;

  /// Reference to the game that resulted in this rating
  String get gameId => throw _privateConstructorUsedError;

  /// Serializes this BestEloRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BestEloRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BestEloRecordCopyWith<BestEloRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BestEloRecordCopyWith<$Res> {
  factory $BestEloRecordCopyWith(
    BestEloRecord value,
    $Res Function(BestEloRecord) then,
  ) = _$BestEloRecordCopyWithImpl<$Res, BestEloRecord>;
  @useResult
  $Res call({
    double elo,
    @RequiredTimestampConverter() DateTime date,
    String gameId,
  });
}

/// @nodoc
class _$BestEloRecordCopyWithImpl<$Res, $Val extends BestEloRecord>
    implements $BestEloRecordCopyWith<$Res> {
  _$BestEloRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BestEloRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? elo = null, Object? date = null, Object? gameId = null}) {
    return _then(
      _value.copyWith(
            elo: null == elo
                ? _value.elo
                : elo // ignore: cast_nullable_to_non_nullable
                      as double,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            gameId: null == gameId
                ? _value.gameId
                : gameId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BestEloRecordImplCopyWith<$Res>
    implements $BestEloRecordCopyWith<$Res> {
  factory _$$BestEloRecordImplCopyWith(
    _$BestEloRecordImpl value,
    $Res Function(_$BestEloRecordImpl) then,
  ) = __$$BestEloRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double elo,
    @RequiredTimestampConverter() DateTime date,
    String gameId,
  });
}

/// @nodoc
class __$$BestEloRecordImplCopyWithImpl<$Res>
    extends _$BestEloRecordCopyWithImpl<$Res, _$BestEloRecordImpl>
    implements _$$BestEloRecordImplCopyWith<$Res> {
  __$$BestEloRecordImplCopyWithImpl(
    _$BestEloRecordImpl _value,
    $Res Function(_$BestEloRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BestEloRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? elo = null, Object? date = null, Object? gameId = null}) {
    return _then(
      _$BestEloRecordImpl(
        elo: null == elo
            ? _value.elo
            : elo // ignore: cast_nullable_to_non_nullable
                  as double,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        gameId: null == gameId
            ? _value.gameId
            : gameId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BestEloRecordImpl implements _BestEloRecord {
  const _$BestEloRecordImpl({
    required this.elo,
    @RequiredTimestampConverter() required this.date,
    required this.gameId,
  });

  factory _$BestEloRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$BestEloRecordImplFromJson(json);

  /// The highest ELO rating achieved
  @override
  final double elo;

  /// The date when this ELO was achieved
  @override
  @RequiredTimestampConverter()
  final DateTime date;

  /// Reference to the game that resulted in this rating
  @override
  final String gameId;

  @override
  String toString() {
    return 'BestEloRecord(elo: $elo, date: $date, gameId: $gameId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BestEloRecordImpl &&
            (identical(other.elo, elo) || other.elo == elo) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.gameId, gameId) || other.gameId == gameId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, elo, date, gameId);

  /// Create a copy of BestEloRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BestEloRecordImplCopyWith<_$BestEloRecordImpl> get copyWith =>
      __$$BestEloRecordImplCopyWithImpl<_$BestEloRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BestEloRecordImplToJson(this);
  }
}

abstract class _BestEloRecord implements BestEloRecord {
  const factory _BestEloRecord({
    required final double elo,
    @RequiredTimestampConverter() required final DateTime date,
    required final String gameId,
  }) = _$BestEloRecordImpl;

  factory _BestEloRecord.fromJson(Map<String, dynamic> json) =
      _$BestEloRecordImpl.fromJson;

  /// The highest ELO rating achieved
  @override
  double get elo;

  /// The date when this ELO was achieved
  @override
  @RequiredTimestampConverter()
  DateTime get date;

  /// Reference to the game that resulted in this rating
  @override
  String get gameId;

  /// Create a copy of BestEloRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BestEloRecordImplCopyWith<_$BestEloRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
