import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:play_with_me/features/profile/data/models/locale_preferences_model.dart';
import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';
import 'package:play_with_me/features/profile/domain/repositories/locale_preferences_repository.dart';

/// Implementation of LocalePreferencesRepository using SharedPreferences and Firestore
class LocalePreferencesRepositoryImpl implements LocalePreferencesRepository {
  final SharedPreferences _sharedPreferences;
  final FirebaseFirestore _firestore;

  // SharedPreferences keys
  static const String _keyLanguage = 'user_locale_language';
  static const String _keyCountry = 'user_locale_country';
  static const String _keyTimeZone = 'user_timezone';
  static const String _keyLastSynced = 'user_locale_last_synced';

  LocalePreferencesRepositoryImpl({
    required SharedPreferences sharedPreferences,
    required FirebaseFirestore firestore,
  })  : _sharedPreferences = sharedPreferences,
        _firestore = firestore;

  @override
  Future<LocalePreferencesEntity> loadPreferences() async {
    try {
      final language = _sharedPreferences.getString(_keyLanguage);
      final country = _sharedPreferences.getString(_keyCountry);
      final timeZone = _sharedPreferences.getString(_keyTimeZone);
      final lastSyncedMillis = _sharedPreferences.getInt(_keyLastSynced);

      // If no saved preferences, return defaults
      if (language == null || country == null) {
        return LocalePreferencesEntity.defaultPreferences();
      }

      return LocalePreferencesEntity(
        locale: Locale(language),
        country: country,
        timeZone: timeZone ?? getDeviceTimeZone(),
        lastSyncedAt: lastSyncedMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(lastSyncedMillis)
            : null,
      );
    } catch (e) {
      // If there's any error, return defaults
      return LocalePreferencesEntity.defaultPreferences();
    }
  }

  @override
  Future<void> savePreferences(LocalePreferencesEntity preferences) async {
    try {
      await _sharedPreferences.setString(
        _keyLanguage,
        preferences.locale.languageCode,
      );
      await _sharedPreferences.setString(_keyCountry, preferences.country);

      final timeZone = preferences.timeZone ?? getDeviceTimeZone();
      await _sharedPreferences.setString(_keyTimeZone, timeZone);

      final now = DateTime.now().millisecondsSinceEpoch;
      await _sharedPreferences.setInt(_keyLastSynced, now);
    } catch (e) {
      throw Exception('Failed to save preferences locally: $e');
    }
  }

  @override
  Future<void> syncToFirestore(
    String userId,
    LocalePreferencesEntity preferences,
  ) async {
    try {
      final model = LocalePreferencesModel.fromEntity(preferences);
      final data = model.toFirestore();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('preferences')
          .doc('locale')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to sync preferences to Firestore: $e');
    }
  }

  @override
  Future<LocalePreferencesEntity?> loadFromFirestore(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('preferences')
          .doc('locale')
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      final model = LocalePreferencesModel.fromMap(doc.data()!);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to load preferences from Firestore: $e');
    }
  }

  @override
  String getDeviceTimeZone() {
    // Get the device's current timezone
    final now = DateTime.now();
    return now.timeZoneName;
  }
}
