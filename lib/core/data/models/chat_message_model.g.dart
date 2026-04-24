// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageModelImpl _$$ChatMessageModelImplFromJson(
  Map<String, dynamic> json,
) => _$ChatMessageModelImpl(
  id: json['id'] as String,
  senderId: json['senderId'] as String,
  senderDisplayName: json['senderDisplayName'] as String,
  text: json['text'] as String,
  sentAt: const TimestampConverter().fromJson(json['sentAt'] as Object),
);

Map<String, dynamic> _$$ChatMessageModelImplToJson(
  _$ChatMessageModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'senderId': instance.senderId,
  'senderDisplayName': instance.senderDisplayName,
  'text': instance.text,
  'sentAt': const TimestampConverter().toJson(instance.sentAt),
};
