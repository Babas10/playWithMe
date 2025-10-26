// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InvitationModelImpl _$$InvitationModelImplFromJson(
  Map<String, dynamic> json,
) => _$InvitationModelImpl(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  groupName: json['groupName'] as String,
  invitedBy: json['invitedBy'] as String,
  inviterName: json['inviterName'] as String,
  invitedUserId: json['invitedUserId'] as String,
  status:
      $enumDecodeNullable(_$InvitationStatusEnumMap, json['status']) ??
      InvitationStatus.pending,
  createdAt: const TimestampConverter().fromJson(json['createdAt'] as Object),
  respondedAt: _$JsonConverterFromJson<Object, DateTime>(
    json['respondedAt'],
    const TimestampConverter().fromJson,
  ),
);

Map<String, dynamic> _$$InvitationModelImplToJson(
  _$InvitationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'groupId': instance.groupId,
  'groupName': instance.groupName,
  'invitedBy': instance.invitedBy,
  'inviterName': instance.inviterName,
  'invitedUserId': instance.invitedUserId,
  'status': _$InvitationStatusEnumMap[instance.status]!,
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'respondedAt': _$JsonConverterToJson<Object, DateTime>(
    instance.respondedAt,
    const TimestampConverter().toJson,
  ),
};

const _$InvitationStatusEnumMap = {
  InvitationStatus.pending: 'pending',
  InvitationStatus.accepted: 'accepted',
  InvitationStatus.declined: 'declined',
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
