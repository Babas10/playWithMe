// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendshipEntityImpl _$$FriendshipEntityImplFromJson(
  Map<String, dynamic> json,
) => _$FriendshipEntityImpl(
  id: json['id'] as String,
  initiatorId: json['initiatorId'] as String,
  recipientId: json['recipientId'] as String,
  initiatorName: json['initiatorName'] as String,
  recipientName: json['recipientName'] as String,
  status: $enumDecode(_$FriendshipStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$FriendshipEntityImplToJson(
  _$FriendshipEntityImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'initiatorId': instance.initiatorId,
  'recipientId': instance.recipientId,
  'initiatorName': instance.initiatorName,
  'recipientName': instance.recipientName,
  'status': _$FriendshipStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$FriendshipStatusEnumMap = {
  FriendshipStatus.pending: 'pending',
  FriendshipStatus.accepted: 'accepted',
  FriendshipStatus.declined: 'declined',
};
