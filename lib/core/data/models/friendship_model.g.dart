// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendshipModelImpl _$$FriendshipModelImplFromJson(
  Map<String, dynamic> json,
) => _$FriendshipModelImpl(
  id: json['id'] as String,
  initiatorId: json['initiatorId'] as String,
  recipientId: json['recipientId'] as String,
  status: $enumDecode(_$FriendshipStatusEnumMap, json['status']),
  createdAt: const RequiredTimestampConverter().fromJson(json['createdAt']),
  updatedAt: const RequiredTimestampConverter().fromJson(json['updatedAt']),
  initiatorName: json['initiatorName'] as String,
  recipientName: json['recipientName'] as String,
);

Map<String, dynamic> _$$FriendshipModelImplToJson(
  _$FriendshipModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'initiatorId': instance.initiatorId,
  'recipientId': instance.recipientId,
  'status': _$FriendshipStatusEnumMap[instance.status]!,
  'createdAt': const RequiredTimestampConverter().toJson(instance.createdAt),
  'updatedAt': const RequiredTimestampConverter().toJson(instance.updatedAt),
  'initiatorName': instance.initiatorName,
  'recipientName': instance.recipientName,
};

const _$FriendshipStatusEnumMap = {
  FriendshipStatus.pending: 'pending',
  FriendshipStatus.accepted: 'accepted',
  FriendshipStatus.declined: 'declined',
};
