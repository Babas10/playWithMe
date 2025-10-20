// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'locale_preferences_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$LocalePreferencesEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadPreferences,
    required TResult Function(Locale locale) updateLanguage,
    required TResult Function(String country) updateCountry,
    required TResult Function(String userId) savePreferences,
    required TResult Function(String userId) loadFromFirestore,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadPreferences,
    TResult? Function(Locale locale)? updateLanguage,
    TResult? Function(String country)? updateCountry,
    TResult? Function(String userId)? savePreferences,
    TResult? Function(String userId)? loadFromFirestore,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadPreferences,
    TResult Function(Locale locale)? updateLanguage,
    TResult Function(String country)? updateCountry,
    TResult Function(String userId)? savePreferences,
    TResult Function(String userId)? loadFromFirestore,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadPreferences value) loadPreferences,
    required TResult Function(UpdateLanguage value) updateLanguage,
    required TResult Function(UpdateCountry value) updateCountry,
    required TResult Function(SavePreferences value) savePreferences,
    required TResult Function(LoadFromFirestore value) loadFromFirestore,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadPreferences value)? loadPreferences,
    TResult? Function(UpdateLanguage value)? updateLanguage,
    TResult? Function(UpdateCountry value)? updateCountry,
    TResult? Function(SavePreferences value)? savePreferences,
    TResult? Function(LoadFromFirestore value)? loadFromFirestore,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadPreferences value)? loadPreferences,
    TResult Function(UpdateLanguage value)? updateLanguage,
    TResult Function(UpdateCountry value)? updateCountry,
    TResult Function(SavePreferences value)? savePreferences,
    TResult Function(LoadFromFirestore value)? loadFromFirestore,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalePreferencesEventCopyWith<$Res> {
  factory $LocalePreferencesEventCopyWith(
    LocalePreferencesEvent value,
    $Res Function(LocalePreferencesEvent) then,
  ) = _$LocalePreferencesEventCopyWithImpl<$Res, LocalePreferencesEvent>;
}

/// @nodoc
class _$LocalePreferencesEventCopyWithImpl<
  $Res,
  $Val extends LocalePreferencesEvent
>
    implements $LocalePreferencesEventCopyWith<$Res> {
  _$LocalePreferencesEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocalePreferencesEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$LoadPreferencesImplCopyWith<$Res> {
  factory _$$LoadPreferencesImplCopyWith(
    _$LoadPreferencesImpl value,
    $Res Function(_$LoadPreferencesImpl) then,
  ) = __$$LoadPreferencesImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadPreferencesImplCopyWithImpl<$Res>
    extends _$LocalePreferencesEventCopyWithImpl<$Res, _$LoadPreferencesImpl>
    implements _$$LoadPreferencesImplCopyWith<$Res> {
  __$$LoadPreferencesImplCopyWithImpl(
    _$LoadPreferencesImpl _value,
    $Res Function(_$LoadPreferencesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocalePreferencesEvent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadPreferencesImpl implements LoadPreferences {
  const _$LoadPreferencesImpl();

  @override
  String toString() {
    return 'LocalePreferencesEvent.loadPreferences()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadPreferencesImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadPreferences,
    required TResult Function(Locale locale) updateLanguage,
    required TResult Function(String country) updateCountry,
    required TResult Function(String userId) savePreferences,
    required TResult Function(String userId) loadFromFirestore,
  }) {
    return loadPreferences();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadPreferences,
    TResult? Function(Locale locale)? updateLanguage,
    TResult? Function(String country)? updateCountry,
    TResult? Function(String userId)? savePreferences,
    TResult? Function(String userId)? loadFromFirestore,
  }) {
    return loadPreferences?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadPreferences,
    TResult Function(Locale locale)? updateLanguage,
    TResult Function(String country)? updateCountry,
    TResult Function(String userId)? savePreferences,
    TResult Function(String userId)? loadFromFirestore,
    required TResult orElse(),
  }) {
    if (loadPreferences != null) {
      return loadPreferences();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadPreferences value) loadPreferences,
    required TResult Function(UpdateLanguage value) updateLanguage,
    required TResult Function(UpdateCountry value) updateCountry,
    required TResult Function(SavePreferences value) savePreferences,
    required TResult Function(LoadFromFirestore value) loadFromFirestore,
  }) {
    return loadPreferences(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadPreferences value)? loadPreferences,
    TResult? Function(UpdateLanguage value)? updateLanguage,
    TResult? Function(UpdateCountry value)? updateCountry,
    TResult? Function(SavePreferences value)? savePreferences,
    TResult? Function(LoadFromFirestore value)? loadFromFirestore,
  }) {
    return loadPreferences?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadPreferences value)? loadPreferences,
    TResult Function(UpdateLanguage value)? updateLanguage,
    TResult Function(UpdateCountry value)? updateCountry,
    TResult Function(SavePreferences value)? savePreferences,
    TResult Function(LoadFromFirestore value)? loadFromFirestore,
    required TResult orElse(),
  }) {
    if (loadPreferences != null) {
      return loadPreferences(this);
    }
    return orElse();
  }
}

abstract class LoadPreferences implements LocalePreferencesEvent {
  const factory LoadPreferences() = _$LoadPreferencesImpl;
}

/// @nodoc
abstract class _$$UpdateLanguageImplCopyWith<$Res> {
  factory _$$UpdateLanguageImplCopyWith(
    _$UpdateLanguageImpl value,
    $Res Function(_$UpdateLanguageImpl) then,
  ) = __$$UpdateLanguageImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Locale locale});
}

/// @nodoc
class __$$UpdateLanguageImplCopyWithImpl<$Res>
    extends _$LocalePreferencesEventCopyWithImpl<$Res, _$UpdateLanguageImpl>
    implements _$$UpdateLanguageImplCopyWith<$Res> {
  __$$UpdateLanguageImplCopyWithImpl(
    _$UpdateLanguageImpl _value,
    $Res Function(_$UpdateLanguageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocalePreferencesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? locale = null}) {
    return _then(
      _$UpdateLanguageImpl(
        null == locale
            ? _value.locale
            : locale // ignore: cast_nullable_to_non_nullable
                  as Locale,
      ),
    );
  }
}

/// @nodoc

class _$UpdateLanguageImpl implements UpdateLanguage {
  const _$UpdateLanguageImpl(this.locale);

  @override
  final Locale locale;

  @override
  String toString() {
    return 'LocalePreferencesEvent.updateLanguage(locale: $locale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateLanguageImpl &&
            (identical(other.locale, locale) || other.locale == locale));
  }

  @override
  int get hashCode => Object.hash(runtimeType, locale);

  /// Create a copy of LocalePreferencesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateLanguageImplCopyWith<_$UpdateLanguageImpl> get copyWith =>
      __$$UpdateLanguageImplCopyWithImpl<_$UpdateLanguageImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadPreferences,
    required TResult Function(Locale locale) updateLanguage,
    required TResult Function(String country) updateCountry,
    required TResult Function(String userId) savePreferences,
    required TResult Function(String userId) loadFromFirestore,
  }) {
    return updateLanguage(locale);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadPreferences,
    TResult? Function(Locale locale)? updateLanguage,
    TResult? Function(String country)? updateCountry,
    TResult? Function(String userId)? savePreferences,
    TResult? Function(String userId)? loadFromFirestore,
  }) {
    return updateLanguage?.call(locale);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadPreferences,
    TResult Function(Locale locale)? updateLanguage,
    TResult Function(String country)? updateCountry,
    TResult Function(String userId)? savePreferences,
    TResult Function(String userId)? loadFromFirestore,
    required TResult orElse(),
  }) {
    if (updateLanguage != null) {
      return updateLanguage(locale);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadPreferences value) loadPreferences,
    required TResult Function(UpdateLanguage value) updateLanguage,
    required TResult Function(UpdateCountry value) updateCountry,
    required TResult Function(SavePreferences value) savePreferences,
    required TResult Function(LoadFromFirestore value) loadFromFirestore,
  }) {
    return updateLanguage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadPreferences value)? loadPreferences,
    TResult? Function(UpdateLanguage value)? updateLanguage,
    TResult? Function(UpdateCountry value)? updateCountry,
    TResult? Function(SavePreferences value)? savePreferences,
    TResult? Function(LoadFromFirestore value)? loadFromFirestore,
  }) {
    return updateLanguage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadPreferences value)? loadPreferences,
    TResult Function(UpdateLanguage value)? updateLanguage,
    TResult Function(UpdateCountry value)? updateCountry,
    TResult Function(SavePreferences value)? savePreferences,
    TResult Function(LoadFromFirestore value)? loadFromFirestore,
    required TResult orElse(),
  }) {
    if (updateLanguage != null) {
      return updateLanguage(this);
    }
    return orElse();
  }
}

abstract class UpdateLanguage implements LocalePreferencesEvent {
  const factory UpdateLanguage(final Locale locale) = _$UpdateLanguageImpl;

  Locale get locale;

  /// Create a copy of LocalePreferencesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateLanguageImplCopyWith<_$UpdateLanguageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateCountryImplCopyWith<$Res> {
  factory _$$UpdateCountryImplCopyWith(
    _$UpdateCountryImpl value,
    $Res Function(_$UpdateCountryImpl) then,
  ) = __$$UpdateCountryImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String country});
}

/// @nodoc
class __$$UpdateCountryImplCopyWithImpl<$Res>
    extends _$LocalePreferencesEventCopyWithImpl<$Res, _$UpdateCountryImpl>
    implements _$$UpdateCountryImplCopyWith<$Res> {
  __$$UpdateCountryImplCopyWithImpl(
    _$UpdateCountryImpl _value,
    $Res Function(_$UpdateCountryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocalePreferencesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? country = null}) {
    return _then(
      _$UpdateCountryImpl(
        null == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$UpdateCountryImpl implements UpdateCountry {
  const _$UpdateCountryImpl(this.country);

  @override
  final String country;

  @override
  String toString() {
    return 'LocalePreferencesEvent.updateCountry(country: $country)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateCountryImpl &&
            (identical(other.country, country) || other.country == country));
  }

  @override
  int get hashCode => Object.hash(runtimeType, country);

  /// Create a copy of LocalePreferencesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateCountryImplCopyWith<_$UpdateCountryImpl> get copyWith =>
      __$$UpdateCountryImplCopyWithImpl<_$UpdateCountryImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadPreferences,
    required TResult Function(Locale locale) updateLanguage,
    required TResult Function(String country) updateCountry,
    required TResult Function(String userId) savePreferences,
    required TResult Function(String userId) loadFromFirestore,
  }) {
    return updateCountry(country);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadPreferences,
    TResult? Function(Locale locale)? updateLanguage,
    TResult? Function(String country)? updateCountry,
    TResult? Function(String userId)? savePreferences,
    TResult? Function(String userId)? loadFromFirestore,
  }) {
    return updateCountry?.call(country);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadPreferences,
    TResult Function(Locale locale)? updateLanguage,
    TResult Function(String country)? updateCountry,
    TResult Function(String userId)? savePreferences,
    TResult Function(String userId)? loadFromFirestore,
    required TResult orElse(),
  }) {
    if (updateCountry != null) {
      return updateCountry(country);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadPreferences value) loadPreferences,
    required TResult Function(UpdateLanguage value) updateLanguage,
    required TResult Function(UpdateCountry value) updateCountry,
    required TResult Function(SavePreferences value) savePreferences,
    required TResult Function(LoadFromFirestore value) loadFromFirestore,
  }) {
    return updateCountry(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadPreferences value)? loadPreferences,
    TResult? Function(UpdateLanguage value)? updateLanguage,
    TResult? Function(UpdateCountry value)? updateCountry,
    TResult? Function(SavePreferences value)? savePreferences,
    TResult? Function(LoadFromFirestore value)? loadFromFirestore,
  }) {
    return updateCountry?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadPreferences value)? loadPreferences,
    TResult Function(UpdateLanguage value)? updateLanguage,
    TResult Function(UpdateCountry value)? updateCountry,
    TResult Function(SavePreferences value)? savePreferences,
    TResult Function(LoadFromFirestore value)? loadFromFirestore,
    required TResult orElse(),
  }) {
    if (updateCountry != null) {
      return updateCountry(this);
    }
    return orElse();
  }
}

abstract class UpdateCountry implements LocalePreferencesEvent {
  const factory UpdateCountry(final String country) = _$UpdateCountryImpl;

  String get country;

  /// Create a copy of LocalePreferencesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UpdateCountryImplCopyWith<_$UpdateCountryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SavePreferencesImplCopyWith<$Res> {
  factory _$$SavePreferencesImplCopyWith(
    _$SavePreferencesImpl value,
    $Res Function(_$SavePreferencesImpl) then,
  ) = __$$SavePreferencesImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String userId});
}

/// @nodoc
class __$$SavePreferencesImplCopyWithImpl<$Res>
    extends _$LocalePreferencesEventCopyWithImpl<$Res, _$SavePreferencesImpl>
    implements _$$SavePreferencesImplCopyWith<$Res> {
  __$$SavePreferencesImplCopyWithImpl(
    _$SavePreferencesImpl _value,
    $Res Function(_$SavePreferencesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocalePreferencesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null}) {
    return _then(
      _$SavePreferencesImpl(
        null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SavePreferencesImpl implements SavePreferences {
  const _$SavePreferencesImpl(this.userId);

  @override
  final String userId;

  @override
  String toString() {
    return 'LocalePreferencesEvent.savePreferences(userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavePreferencesImpl &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId);

  /// Create a copy of LocalePreferencesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SavePreferencesImplCopyWith<_$SavePreferencesImpl> get copyWith =>
      __$$SavePreferencesImplCopyWithImpl<_$SavePreferencesImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadPreferences,
    required TResult Function(Locale locale) updateLanguage,
    required TResult Function(String country) updateCountry,
    required TResult Function(String userId) savePreferences,
    required TResult Function(String userId) loadFromFirestore,
  }) {
    return savePreferences(userId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadPreferences,
    TResult? Function(Locale locale)? updateLanguage,
    TResult? Function(String country)? updateCountry,
    TResult? Function(String userId)? savePreferences,
    TResult? Function(String userId)? loadFromFirestore,
  }) {
    return savePreferences?.call(userId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadPreferences,
    TResult Function(Locale locale)? updateLanguage,
    TResult Function(String country)? updateCountry,
    TResult Function(String userId)? savePreferences,
    TResult Function(String userId)? loadFromFirestore,
    required TResult orElse(),
  }) {
    if (savePreferences != null) {
      return savePreferences(userId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadPreferences value) loadPreferences,
    required TResult Function(UpdateLanguage value) updateLanguage,
    required TResult Function(UpdateCountry value) updateCountry,
    required TResult Function(SavePreferences value) savePreferences,
    required TResult Function(LoadFromFirestore value) loadFromFirestore,
  }) {
    return savePreferences(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadPreferences value)? loadPreferences,
    TResult? Function(UpdateLanguage value)? updateLanguage,
    TResult? Function(UpdateCountry value)? updateCountry,
    TResult? Function(SavePreferences value)? savePreferences,
    TResult? Function(LoadFromFirestore value)? loadFromFirestore,
  }) {
    return savePreferences?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadPreferences value)? loadPreferences,
    TResult Function(UpdateLanguage value)? updateLanguage,
    TResult Function(UpdateCountry value)? updateCountry,
    TResult Function(SavePreferences value)? savePreferences,
    TResult Function(LoadFromFirestore value)? loadFromFirestore,
    required TResult orElse(),
  }) {
    if (savePreferences != null) {
      return savePreferences(this);
    }
    return orElse();
  }
}

abstract class SavePreferences implements LocalePreferencesEvent {
  const factory SavePreferences(final String userId) = _$SavePreferencesImpl;

  String get userId;

  /// Create a copy of LocalePreferencesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SavePreferencesImplCopyWith<_$SavePreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LoadFromFirestoreImplCopyWith<$Res> {
  factory _$$LoadFromFirestoreImplCopyWith(
    _$LoadFromFirestoreImpl value,
    $Res Function(_$LoadFromFirestoreImpl) then,
  ) = __$$LoadFromFirestoreImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String userId});
}

/// @nodoc
class __$$LoadFromFirestoreImplCopyWithImpl<$Res>
    extends _$LocalePreferencesEventCopyWithImpl<$Res, _$LoadFromFirestoreImpl>
    implements _$$LoadFromFirestoreImplCopyWith<$Res> {
  __$$LoadFromFirestoreImplCopyWithImpl(
    _$LoadFromFirestoreImpl _value,
    $Res Function(_$LoadFromFirestoreImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocalePreferencesEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? userId = null}) {
    return _then(
      _$LoadFromFirestoreImpl(
        null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$LoadFromFirestoreImpl implements LoadFromFirestore {
  const _$LoadFromFirestoreImpl(this.userId);

  @override
  final String userId;

  @override
  String toString() {
    return 'LocalePreferencesEvent.loadFromFirestore(userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoadFromFirestoreImpl &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId);

  /// Create a copy of LocalePreferencesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadFromFirestoreImplCopyWith<_$LoadFromFirestoreImpl> get copyWith =>
      __$$LoadFromFirestoreImplCopyWithImpl<_$LoadFromFirestoreImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() loadPreferences,
    required TResult Function(Locale locale) updateLanguage,
    required TResult Function(String country) updateCountry,
    required TResult Function(String userId) savePreferences,
    required TResult Function(String userId) loadFromFirestore,
  }) {
    return loadFromFirestore(userId);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? loadPreferences,
    TResult? Function(Locale locale)? updateLanguage,
    TResult? Function(String country)? updateCountry,
    TResult? Function(String userId)? savePreferences,
    TResult? Function(String userId)? loadFromFirestore,
  }) {
    return loadFromFirestore?.call(userId);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? loadPreferences,
    TResult Function(Locale locale)? updateLanguage,
    TResult Function(String country)? updateCountry,
    TResult Function(String userId)? savePreferences,
    TResult Function(String userId)? loadFromFirestore,
    required TResult orElse(),
  }) {
    if (loadFromFirestore != null) {
      return loadFromFirestore(userId);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LoadPreferences value) loadPreferences,
    required TResult Function(UpdateLanguage value) updateLanguage,
    required TResult Function(UpdateCountry value) updateCountry,
    required TResult Function(SavePreferences value) savePreferences,
    required TResult Function(LoadFromFirestore value) loadFromFirestore,
  }) {
    return loadFromFirestore(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LoadPreferences value)? loadPreferences,
    TResult? Function(UpdateLanguage value)? updateLanguage,
    TResult? Function(UpdateCountry value)? updateCountry,
    TResult? Function(SavePreferences value)? savePreferences,
    TResult? Function(LoadFromFirestore value)? loadFromFirestore,
  }) {
    return loadFromFirestore?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LoadPreferences value)? loadPreferences,
    TResult Function(UpdateLanguage value)? updateLanguage,
    TResult Function(UpdateCountry value)? updateCountry,
    TResult Function(SavePreferences value)? savePreferences,
    TResult Function(LoadFromFirestore value)? loadFromFirestore,
    required TResult orElse(),
  }) {
    if (loadFromFirestore != null) {
      return loadFromFirestore(this);
    }
    return orElse();
  }
}

abstract class LoadFromFirestore implements LocalePreferencesEvent {
  const factory LoadFromFirestore(final String userId) =
      _$LoadFromFirestoreImpl;

  String get userId;

  /// Create a copy of LocalePreferencesEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoadFromFirestoreImplCopyWith<_$LoadFromFirestoreImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
