import 'package:play_with_me/features/profile/domain/entities/locale_preferences_entity.dart';

/// Repository for managing user locale and regional preferences
abstract class LocalePreferencesRepository {
  /// Load preferences from local storage
  /// Returns default preferences if none are saved
  Future<LocalePreferencesEntity> loadPreferences();

  /// Save preferences to local storage
  Future<void> savePreferences(LocalePreferencesEntity preferences);

  /// Sync preferences to Firestore
  Future<void> syncToFirestore(String userId, LocalePreferencesEntity preferences);

  /// Load preferences from Firestore
  /// Returns null if no preferences are found in Firestore
  Future<LocalePreferencesEntity?> loadFromFirestore(String userId);

  /// Get the device's current timezone
  String getDeviceTimeZone();
}
