// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_invitation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameInvitationModelImpl _$$GameInvitationModelImplFromJson(
  Map<String, dynamic> json,
) => _$GameInvitationModelImpl(
  id: json['id'] as String,
  gameId: json['gameId'] as String,
  groupId: json['groupId'] as String,
  inviteeId: json['inviteeId'] as String,
  inviterId: json['inviterId'] as String,
  status:
      $enumDecodeNullable(_$GameInvitationStatusEnumMap, json['status']) ??
      GameInvitationStatus.pending,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  expiresAt: const TimestampConverter().fromJson(json['expiresAt']),
);

Map<String, dynamic> _$$GameInvitationModelImplToJson(
  _$GameInvitationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'gameId': instance.gameId,
  'groupId': instance.groupId,
  'inviteeId': instance.inviteeId,
  'inviterId': instance.inviterId,
  'status': _$GameInvitationStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
  'expiresAt': const TimestampConverter().toJson(instance.expiresAt),
};

const _$GameInvitationStatusEnumMap = {
  GameInvitationStatus.pending: 'pending',
  GameInvitationStatus.accepted: 'accepted',
  GameInvitationStatus.declined: 'declined',
  GameInvitationStatus.expired: 'expired',
};
