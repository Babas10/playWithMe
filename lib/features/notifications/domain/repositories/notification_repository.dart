import '../entities/notification_preferences_entity.dart';

/// Repository interface for managing notification preferences
abstract class NotificationRepository {
  /// Get notification preferences for the current user
  Future<NotificationPreferencesEntity> getPreferences();

  /// Update notification preferences for the current user
  Future<void> updatePreferences(NotificationPreferencesEntity preferences);

  /// Stream of notification preference changes
  Stream<NotificationPreferencesEntity> preferencesStream();
}
