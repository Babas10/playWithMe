// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_feedback_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingFeedbackModelImpl _$$TrainingFeedbackModelImplFromJson(
  Map<String, dynamic> json,
) => _$TrainingFeedbackModelImpl(
  id: json['id'] as String,
  trainingSessionId: json['trainingSessionId'] as String,
  exercisesQuality: (json['exercisesQuality'] as num).toInt(),
  trainingIntensity: (json['trainingIntensity'] as num).toInt(),
  coachingClarity: (json['coachingClarity'] as num).toInt(),
  comment: json['comment'] as String?,
  participantHash: json['participantHash'] as String,
  submittedAt: const TimestampConverter().fromJson(json['submittedAt']),
);

Map<String, dynamic> _$$TrainingFeedbackModelImplToJson(
  _$TrainingFeedbackModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'trainingSessionId': instance.trainingSessionId,
  'exercisesQuality': instance.exercisesQuality,
  'trainingIntensity': instance.trainingIntensity,
  'coachingClarity': instance.coachingClarity,
  'comment': instance.comment,
  'participantHash': instance.participantHash,
  'submittedAt': const TimestampConverter().toJson(instance.submittedAt),
};
