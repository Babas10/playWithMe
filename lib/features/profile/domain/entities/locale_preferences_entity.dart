import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'locale_preferences_entity.freezed.dart';

/// Entity representing user's locale and regional preferences
@freezed
class LocalePreferencesEntity with _$LocalePreferencesEntity {
  const factory LocalePreferencesEntity({
    required Locale locale,
    required String country,
    String? timeZone,
    DateTime? lastSyncedAt,
  }) = _LocalePreferencesEntity;

  const LocalePreferencesEntity._();

  /// Default preferences with English locale and United States country
  factory LocalePreferencesEntity.defaultPreferences() {
    return const LocalePreferencesEntity(
      locale: Locale('en'),
      country: 'United States',
      timeZone: null,
      lastSyncedAt: null,
    );
  }

  /// Supported languages for the application
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('es'), // Spanish
    Locale('de'), // German
    Locale('it'), // Italian
    Locale('fr'), // French
  ];

  /// Get display name for a given locale
  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español (Spanish)';
      case 'de':
        return 'Deutsch (German)';
      case 'it':
        return 'Italiano (Italian)';
      case 'fr':
        return 'Français (French)';
      default:
        return locale.languageCode;
    }
  }
}
