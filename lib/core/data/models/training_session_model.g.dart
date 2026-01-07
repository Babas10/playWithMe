// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingSessionModelImpl _$$TrainingSessionModelImplFromJson(
  Map<String, dynamic> json,
) => _$TrainingSessionModelImpl(
  id: json['id'] as String,
  groupId: json['groupId'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  location: GameLocation.fromJson(json['location'] as Map<String, dynamic>),
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  minParticipants: (json['minParticipants'] as num).toInt(),
  maxParticipants: (json['maxParticipants'] as num).toInt(),
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  recurrenceRule: json['recurrenceRule'] == null
      ? null
      : RecurrenceRuleModel.fromJson(
          json['recurrenceRule'] as Map<String, dynamic>,
        ),
  parentSessionId: json['parentSessionId'] as String?,
  status:
      $enumDecodeNullable(_$TrainingStatusEnumMap, json['status']) ??
      TrainingStatus.scheduled,
  participantIds:
      (json['participantIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$TrainingSessionModelImplToJson(
  _$TrainingSessionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'groupId': instance.groupId,
  'title': instance.title,
  'description': instance.description,
  'location': instance.location,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'minParticipants': instance.minParticipants,
  'maxParticipants': instance.maxParticipants,
  'createdBy': instance.createdBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
  'recurrenceRule': instance.recurrenceRule,
  'parentSessionId': instance.parentSessionId,
  'status': _$TrainingStatusEnumMap[instance.status]!,
  'participantIds': instance.participantIds,
  'notes': instance.notes,
};

const _$TrainingStatusEnumMap = {
  TrainingStatus.scheduled: 'scheduled',
  TrainingStatus.completed: 'completed',
  TrainingStatus.cancelled: 'cancelled',
};
