// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationPreferencesEntityImpl
_$$NotificationPreferencesEntityImplFromJson(Map<String, dynamic> json) =>
    _$NotificationPreferencesEntityImpl(
      groupInvitations: json['groupInvitations'] as bool? ?? true,
      invitationAccepted: json['invitationAccepted'] as bool? ?? true,
      gameCreated: json['gameCreated'] as bool? ?? true,
      memberJoined: json['memberJoined'] as bool? ?? false,
      memberLeft: json['memberLeft'] as bool? ?? false,
      roleChanged: json['roleChanged'] as bool? ?? true,
      quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? false,
      quietHoursStart: json['quietHoursStart'] as String?,
      quietHoursEnd: json['quietHoursEnd'] as String?,
      groupSpecific:
          (json['groupSpecific'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
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
  'quietHoursEnabled': instance.quietHoursEnabled,
  'quietHoursStart': instance.quietHoursStart,
  'quietHoursEnd': instance.quietHoursEnd,
  'groupSpecific': instance.groupSpecific,
};
