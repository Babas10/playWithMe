// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship_status_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendshipStatusResultImpl _$$FriendshipStatusResultImplFromJson(
  Map<String, dynamic> json,
) => _$FriendshipStatusResultImpl(
  isFriend: json['isFriend'] as bool,
  hasPendingRequest: json['hasPendingRequest'] as bool,
  requestDirection: json['requestDirection'] as String?,
  friendshipId: json['friendshipId'] as String?,
);

Map<String, dynamic> _$$FriendshipStatusResultImplToJson(
  _$FriendshipStatusResultImpl instance,
) => <String, dynamic>{
  'isFriend': instance.isFriend,
  'hasPendingRequest': instance.hasPendingRequest,
  'requestDirection': instance.requestDirection,
  'friendshipId': instance.friendshipId,
};
