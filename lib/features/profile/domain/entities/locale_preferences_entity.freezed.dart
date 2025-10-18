// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'locale_preferences_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$LocalePreferencesEntity {
  Locale get locale => throw _privateConstructorUsedError;
  String get country => throw _privateConstructorUsedError;
  String? get timeZone => throw _privateConstructorUsedError;
  DateTime? get lastSyncedAt => throw _privateConstructorUsedError;

  /// Create a copy of LocalePreferencesEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocalePreferencesEntityCopyWith<LocalePreferencesEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalePreferencesEntityCopyWith<$Res> {
  factory $LocalePreferencesEntityCopyWith(
    LocalePreferencesEntity value,
    $Res Function(LocalePreferencesEntity) then,
  ) = _$LocalePreferencesEntityCopyWithImpl<$Res, LocalePreferencesEntity>;
  @useResult
  $Res call({
    Locale locale,
    String country,
    String? timeZone,
    DateTime? lastSyncedAt,
  });
}

/// @nodoc
class _$LocalePreferencesEntityCopyWithImpl<
  $Res,
  $Val extends LocalePreferencesEntity
>
    implements $LocalePreferencesEntityCopyWith<$Res> {
  _$LocalePreferencesEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocalePreferencesEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locale = null,
    Object? country = null,
    Object? timeZone = freezed,
    Object? lastSyncedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            locale: null == locale
                ? _value.locale
                : locale // ignore: cast_nullable_to_non_nullable
                      as Locale,
            country: null == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String,
            timeZone: freezed == timeZone
                ? _value.timeZone
                : timeZone // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastSyncedAt: freezed == lastSyncedAt
                ? _value.lastSyncedAt
                : lastSyncedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LocalePreferencesEntityImplCopyWith<$Res>
    implements $LocalePreferencesEntityCopyWith<$Res> {
  factory _$$LocalePreferencesEntityImplCopyWith(
    _$LocalePreferencesEntityImpl value,
    $Res Function(_$LocalePreferencesEntityImpl) then,
  ) = __$$LocalePreferencesEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Locale locale,
    String country,
    String? timeZone,
    DateTime? lastSyncedAt,
  });
}

/// @nodoc
class __$$LocalePreferencesEntityImplCopyWithImpl<$Res>
    extends
        _$LocalePreferencesEntityCopyWithImpl<
          $Res,
          _$LocalePreferencesEntityImpl
        >
    implements _$$LocalePreferencesEntityImplCopyWith<$Res> {
  __$$LocalePreferencesEntityImplCopyWithImpl(
    _$LocalePreferencesEntityImpl _value,
    $Res Function(_$LocalePreferencesEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocalePreferencesEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locale = null,
    Object? country = null,
    Object? timeZone = freezed,
    Object? lastSyncedAt = freezed,
  }) {
    return _then(
      _$LocalePreferencesEntityImpl(
        locale: null == locale
            ? _value.locale
            : locale // ignore: cast_nullable_to_non_nullable
                  as Locale,
        country: null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String,
        timeZone: freezed == timeZone
            ? _value.timeZone
            : timeZone // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastSyncedAt: freezed == lastSyncedAt
            ? _value.lastSyncedAt
            : lastSyncedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$LocalePreferencesEntityImpl extends _LocalePreferencesEntity {
  const _$LocalePreferencesEntityImpl({
    required this.locale,
    required this.country,
    this.timeZone,
    this.lastSyncedAt,
  }) : super._();

  @override
  final Locale locale;
  @override
  final String country;
  @override
  final String? timeZone;
  @override
  final DateTime? lastSyncedAt;

  @override
  String toString() {
    return 'LocalePreferencesEntity(locale: $locale, country: $country, timeZone: $timeZone, lastSyncedAt: $lastSyncedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalePreferencesEntityImpl &&
            (identical(other.locale, locale) || other.locale == locale) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.timeZone, timeZone) ||
                other.timeZone == timeZone) &&
            (identical(other.lastSyncedAt, lastSyncedAt) ||
                other.lastSyncedAt == lastSyncedAt));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, locale, country, timeZone, lastSyncedAt);

  /// Create a copy of LocalePreferencesEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalePreferencesEntityImplCopyWith<_$LocalePreferencesEntityImpl>
  get copyWith =>
      __$$LocalePreferencesEntityImplCopyWithImpl<
        _$LocalePreferencesEntityImpl
      >(this, _$identity);
}

abstract class _LocalePreferencesEntity extends LocalePreferencesEntity {
  const factory _LocalePreferencesEntity({
    required final Locale locale,
    required final String country,
    final String? timeZone,
    final DateTime? lastSyncedAt,
  }) = _$LocalePreferencesEntityImpl;
  const _LocalePreferencesEntity._() : super._();

  @override
  Locale get locale;
  @override
  String get country;
  @override
  String? get timeZone;
  @override
  DateTime? get lastSyncedAt;

  /// Create a copy of LocalePreferencesEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocalePreferencesEntityImplCopyWith<_$LocalePreferencesEntityImpl>
  get copyWith => throw _privateConstructorUsedError;
}
