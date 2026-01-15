// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationPreferencesEntityImpl
_$$NotificationPreferencesEntityImplFromJson(
  Map<String, dynamic> json,
) => _$NotificationPreferencesEntityImpl(
  groupInvitations: json['groupInvitations'] as bool? ?? true,
  invitationAccepted: json['invitationAccepted'] as bool? ?? true,
  gameCreated: json['gameCreated'] as bool? ?? true,
  memberJoined: json['memberJoined'] as bool? ?? false,
  memberLeft: json['memberLeft'] as bool? ?? false,
  roleChanged: json['roleChanged'] as bool? ?? true,
  friendRequestReceived: json['friendRequestReceived'] as bool? ?? true,
  friendRequestAccepted: json['friendRequestAccepted'] as bool? ?? true,
  friendRemoved: json['friendRemoved'] as bool? ?? false,
  quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? false,
  quietHoursStart: json['quietHoursStart'] as String?,
  quietHoursEnd: json['quietHoursEnd'] as String?,
  groupSpecific:
      (json['groupSpecific'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ) ??
      const {},
  trainingSessionCreated: json['trainingSessionCreated'] as bool? ?? true,
  trainingMinParticipantsReached:
      json['trainingMinParticipantsReached'] as bool? ?? true,
  trainingFeedbackReceived: json['trainingFeedbackReceived'] as bool? ?? true,
  trainingSessionCancelled: json['trainingSessionCancelled'] as bool? ?? true,
);

Map<String, dynamic> _$$NotificationPreferencesEntityImplToJson(
  _$NotificationPreferencesEntityImpl instance,
) => <String, dynamic>{
  'groupInvitations': instance.groupInvitations,
  'invitationAccepted': instance.invitationAccepted,
  'gameCreated': instance.gameCreated,
  'memberJoined': instance.memberJoined,
  'memberLeft': instance.memberLeft,
  'roleChanged': instance.roleChanged,
  'friendRequestReceived': instance.friendRequestReceived,
  'friendRequestAccepted': instance.friendRequestAccepted,
  'friendRemoved': instance.friendRemoved,
  'quietHoursEnabled': instance.quietHoursEnabled,
  'quietHoursStart': instance.quietHoursStart,
  'quietHoursEnd': instance.quietHoursEnd,
  'groupSpecific': instance.groupSpecific,
  'trainingSessionCreated': instance.trainingSessionCreated,
  'trainingMinParticipantsReached': instance.trainingMinParticipantsReached,
  'trainingFeedbackReceived': instance.trainingFeedbackReceived,
  'trainingSessionCancelled': instance.trainingSessionCancelled,
};
