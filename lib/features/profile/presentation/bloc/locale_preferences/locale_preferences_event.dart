import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'locale_preferences_event.freezed.dart';

/// Events for LocalePreferencesBloc
@freezed
class LocalePreferencesEvent with _$LocalePreferencesEvent {
  /// Load preferences from local storage
  const factory LocalePreferencesEvent.loadPreferences() = LoadPreferences;

  /// Update the selected language
  const factory LocalePreferencesEvent.updateLanguage(Locale locale) = UpdateLanguage;

  /// Update the selected country
  const factory LocalePreferencesEvent.updateCountry(String country) = UpdateCountry;

  /// Save preferences to local storage and Firestore
  const factory LocalePreferencesEvent.savePreferences(String userId) = SavePreferences;

  /// Load preferences from Firestore
  const factory LocalePreferencesEvent.loadFromFirestore(String userId) = LoadFromFirestore;
}
