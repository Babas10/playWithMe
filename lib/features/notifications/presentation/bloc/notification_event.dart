import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/notification_preferences_entity.dart';

part 'notification_event.freezed.dart';

@freezed
class NotificationEvent with _$NotificationEvent {
  const factory NotificationEvent.loadPreferences() = _LoadPreferences;
  const factory NotificationEvent.updatePreferences(NotificationPreferencesEntity preferences) = _UpdatePreferences;
  const factory NotificationEvent.toggleGroupInvitations(bool enabled) = _ToggleGroupInvitations;
  const factory NotificationEvent.toggleInvitationAccepted(bool enabled) = _ToggleInvitationAccepted;
  const factory NotificationEvent.toggleGameCreated(bool enabled) = _ToggleGameCreated;
  const factory NotificationEvent.toggleMemberJoined(bool enabled) = _ToggleMemberJoined;
  const factory NotificationEvent.toggleMemberLeft(bool enabled) = _ToggleMemberLeft;
  const factory NotificationEvent.toggleRoleChanged(bool enabled) = _ToggleRoleChanged;
  const factory NotificationEvent.toggleQuietHours({
    required bool enabled,
    String? start,
    String? end,
  }) = _ToggleQuietHours;
  const factory NotificationEvent.toggleGroupSpecific({
    required String groupId,
    required bool enabled,
  }) = _ToggleGroupSpecific;
  // Training session notification toggle events (Story 15.13)
  const factory NotificationEvent.toggleTrainingSessionCreated(bool enabled) = _ToggleTrainingSessionCreated;
  const factory NotificationEvent.toggleTrainingMinParticipantsReached(bool enabled) = _ToggleTrainingMinParticipantsReached;
  const factory NotificationEvent.toggleTrainingFeedbackReceived(bool enabled) = _ToggleTrainingFeedbackReceived;
  const factory NotificationEvent.toggleTrainingSessionCancelled(bool enabled) = _ToggleTrainingSessionCancelled;
}
