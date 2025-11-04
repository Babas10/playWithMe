import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_preferences_entity.freezed.dart';
part 'notification_preferences_entity.g.dart';

@freezed
class NotificationPreferencesEntity with _$NotificationPreferencesEntity {
  const factory NotificationPreferencesEntity({
    @Default(true) bool groupInvitations,
    @Default(true) bool invitationAccepted,
    @Default(true) bool gameCreated,
    @Default(false) bool memberJoined,
    @Default(false) bool memberLeft,
    @Default(true) bool roleChanged,
    @Default(true) bool friendRequestReceived,
    @Default(true) bool friendRequestAccepted,
    @Default(false) bool friendRemoved,
    @Default(false) bool quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    @Default({}) Map<String, bool> groupSpecific,
  }) = _NotificationPreferencesEntity;

  const NotificationPreferencesEntity._();

  factory NotificationPreferencesEntity.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesEntityFromJson(json);

  /// Check if notifications are allowed during current time
  bool isInQuietHours(DateTime now) {
    if (!quietHoursEnabled || quietHoursStart == null || quietHoursEnd == null) {
      return false;
    }

    final currentMinutes = now.hour * 60 + now.minute;

    final startParts = quietHoursStart!.split(':');
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);

    final endParts = quietHoursEnd!.split(':');
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    if (startMinutes <= endMinutes) {
      // Same day quiet hours (e.g., 14:00 to 18:00)
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Overnight quiet hours (e.g., 22:00 to 08:00)
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  /// Check if notifications are enabled for a specific group
  bool isEnabledForGroup(String groupId, bool defaultValue) {
    return groupSpecific[groupId] ?? defaultValue;
  }
}
