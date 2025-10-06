// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameModelImpl _$$GameModelImplFromJson(
  Map<String, dynamic> json,
) => _$GameModelImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  groupId: json['groupId'] as String,
  createdBy: json['createdBy'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
  scheduledAt: DateTime.parse(json['scheduledAt'] as String),
  startedAt: const TimestampConverter().fromJson(json['startedAt']),
  endedAt: const TimestampConverter().fromJson(json['endedAt']),
  location: GameLocation.fromJson(json['location'] as Map<String, dynamic>),
  status:
      $enumDecodeNullable(_$GameStatusEnumMap, json['status']) ??
      GameStatus.scheduled,
  maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 4,
  minPlayers: (json['minPlayers'] as num?)?.toInt() ?? 2,
  playerIds:
      (json['playerIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  waitlistIds:
      (json['waitlistIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  allowWaitlist: json['allowWaitlist'] as bool? ?? true,
  allowPlayerInvites: json['allowPlayerInvites'] as bool? ?? true,
  visibility:
      $enumDecodeNullable(_$GameVisibilityEnumMap, json['visibility']) ??
      GameVisibility.group,
  notes: json['notes'] as String?,
  equipment:
      (json['equipment'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  estimatedDuration: json['estimatedDuration'] == null
      ? null
      : Duration(microseconds: (json['estimatedDuration'] as num).toInt()),
  courtInfo: json['courtInfo'] as String?,
  gameType: $enumDecodeNullable(_$GameTypeEnumMap, json['gameType']),
  skillLevel: $enumDecodeNullable(_$GameSkillLevelEnumMap, json['skillLevel']),
  scores:
      (json['scores'] as List<dynamic>?)
          ?.map((e) => GameScore.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  winnerId: json['winnerId'] as String?,
  weatherDependent: json['weatherDependent'] as bool? ?? true,
  weatherNotes: json['weatherNotes'] as String?,
);

Map<String, dynamic> _$$GameModelImplToJson(_$GameModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'groupId': instance.groupId,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'scheduledAt': instance.scheduledAt.toIso8601String(),
      'startedAt': const TimestampConverter().toJson(instance.startedAt),
      'endedAt': const TimestampConverter().toJson(instance.endedAt),
      'location': instance.location,
      'status': _$GameStatusEnumMap[instance.status]!,
      'maxPlayers': instance.maxPlayers,
      'minPlayers': instance.minPlayers,
      'playerIds': instance.playerIds,
      'waitlistIds': instance.waitlistIds,
      'allowWaitlist': instance.allowWaitlist,
      'allowPlayerInvites': instance.allowPlayerInvites,
      'visibility': _$GameVisibilityEnumMap[instance.visibility]!,
      'notes': instance.notes,
      'equipment': instance.equipment,
      'estimatedDuration': instance.estimatedDuration?.inMicroseconds,
      'courtInfo': instance.courtInfo,
      'gameType': _$GameTypeEnumMap[instance.gameType],
      'skillLevel': _$GameSkillLevelEnumMap[instance.skillLevel],
      'scores': instance.scores,
      'winnerId': instance.winnerId,
      'weatherDependent': instance.weatherDependent,
      'weatherNotes': instance.weatherNotes,
    };

const _$GameStatusEnumMap = {
  GameStatus.scheduled: 'scheduled',
  GameStatus.inProgress: 'in_progress',
  GameStatus.completed: 'completed',
  GameStatus.cancelled: 'cancelled',
};

const _$GameVisibilityEnumMap = {
  GameVisibility.group: 'group',
  GameVisibility.public: 'public',
  GameVisibility.private: 'private',
};

const _$GameTypeEnumMap = {
  GameType.beachVolleyball: 'beach_volleyball',
  GameType.indoorVolleyball: 'indoor_volleyball',
  GameType.casual: 'casual',
  GameType.competitive: 'competitive',
  GameType.tournament: 'tournament',
};

const _$GameSkillLevelEnumMap = {
  GameSkillLevel.beginner: 'beginner',
  GameSkillLevel.intermediate: 'intermediate',
  GameSkillLevel.advanced: 'advanced',
  GameSkillLevel.mixed: 'mixed',
};

_$GameLocationImpl _$$GameLocationImplFromJson(Map<String, dynamic> json) =>
    _$GameLocationImpl(
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      description: json['description'] as String?,
      parkingInfo: json['parkingInfo'] as String?,
      accessInstructions: json['accessInstructions'] as String?,
    );

Map<String, dynamic> _$$GameLocationImplToJson(_$GameLocationImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'description': instance.description,
      'parkingInfo': instance.parkingInfo,
      'accessInstructions': instance.accessInstructions,
    };

_$GameScoreImpl _$$GameScoreImplFromJson(Map<String, dynamic> json) =>
    _$GameScoreImpl(
      playerId: json['playerId'] as String,
      score: (json['score'] as num).toInt(),
      sets: (json['sets'] as num?)?.toInt() ?? 0,
      gamesWon: (json['gamesWon'] as num?)?.toInt() ?? 0,
      additionalStats: json['additionalStats'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$GameScoreImplToJson(_$GameScoreImpl instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'score': instance.score,
      'sets': instance.sets,
      'gamesWon': instance.gamesWon,
      'additionalStats': instance.additionalStats,
    };
