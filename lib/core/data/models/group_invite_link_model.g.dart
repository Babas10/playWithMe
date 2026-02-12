// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_invite_link_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupInviteLinkModelImpl _$$GroupInviteLinkModelImplFromJson(
  Map<String, dynamic> json,
) => _$GroupInviteLinkModelImpl(
  id: json['id'] as String,
  token: json['token'] as String,
  createdBy: json['createdBy'] as String,
  createdAt: const RequiredTimestampConverter().fromJson(json['createdAt']),
  expiresAt: const TimestampConverter().fromJson(json['expiresAt']),
  revoked: json['revoked'] as bool? ?? false,
  usageLimit: (json['usageLimit'] as num?)?.toInt(),
  usageCount: (json['usageCount'] as num?)?.toInt() ?? 0,
  groupId: json['groupId'] as String,
  inviteType: json['inviteType'] as String? ?? 'group_link',
);

Map<String, dynamic> _$$GroupInviteLinkModelImplToJson(
  _$GroupInviteLinkModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'token': instance.token,
  'createdBy': instance.createdBy,
  'createdAt': const RequiredTimestampConverter().toJson(instance.createdAt),
  'expiresAt': const TimestampConverter().toJson(instance.expiresAt),
  'revoked': instance.revoked,
  'usageLimit': instance.usageLimit,
  'usageCount': instance.usageCount,
  'groupId': instance.groupId,
  'inviteType': instance.inviteType,
};
