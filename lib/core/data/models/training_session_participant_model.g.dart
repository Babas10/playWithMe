// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_session_participant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingSessionParticipantModelImpl
_$$TrainingSessionParticipantModelImplFromJson(Map<String, dynamic> json) =>
    _$TrainingSessionParticipantModelImpl(
      userId: json['userId'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      status:
          $enumDecodeNullable(_$ParticipantStatusEnumMap, json['status']) ??
          ParticipantStatus.joined,
    );

Map<String, dynamic> _$$TrainingSessionParticipantModelImplToJson(
  _$TrainingSessionParticipantModelImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'joinedAt': instance.joinedAt.toIso8601String(),
  'status': _$ParticipantStatusEnumMap[instance.status]!,
};

const _$ParticipantStatusEnumMap = {
  ParticipantStatus.joined: 'joined',
  ParticipantStatus.left: 'left',
};
