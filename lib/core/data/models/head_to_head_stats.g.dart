// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'head_to_head_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HeadToHeadStatsImpl _$$HeadToHeadStatsImplFromJson(
  Map<String, dynamic> json,
) => _$HeadToHeadStatsImpl(
  userId: json['userId'] as String,
  opponentId: json['opponentId'] as String,
  opponentName: json['opponentName'] as String?,
  opponentEmail: json['opponentEmail'] as String?,
  opponentPhotoUrl: json['opponentPhotoUrl'] as String?,
  gamesPlayed: (json['gamesPlayed'] as num).toInt(),
  gamesWon: (json['gamesWon'] as num).toInt(),
  gamesLost: (json['gamesLost'] as num).toInt(),
  pointsScored: (json['pointsScored'] as num?)?.toInt() ?? 0,
  pointsAllowed: (json['pointsAllowed'] as num?)?.toInt() ?? 0,
  eloChange: (json['eloChange'] as num?)?.toDouble() ?? 0.0,
  largestVictoryMargin: (json['largestVictoryMargin'] as num?)?.toInt() ?? 0,
  largestDefeatMargin: (json['largestDefeatMargin'] as num?)?.toInt() ?? 0,
  recentMatchups:
      (json['recentMatchups'] as List<dynamic>?)
          ?.map((e) => HeadToHeadGameResult.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  lastUpdated: const TimestampConverter().fromJson(json['lastUpdated']),
);

Map<String, dynamic> _$$HeadToHeadStatsImplToJson(
  _$HeadToHeadStatsImpl instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'opponentId': instance.opponentId,
  'opponentName': instance.opponentName,
  'opponentEmail': instance.opponentEmail,
  'opponentPhotoUrl': instance.opponentPhotoUrl,
  'gamesPlayed': instance.gamesPlayed,
  'gamesWon': instance.gamesWon,
  'gamesLost': instance.gamesLost,
  'pointsScored': instance.pointsScored,
  'pointsAllowed': instance.pointsAllowed,
  'eloChange': instance.eloChange,
  'largestVictoryMargin': instance.largestVictoryMargin,
  'largestDefeatMargin': instance.largestDefeatMargin,
  'recentMatchups': instance.recentMatchups,
  'lastUpdated': const TimestampConverter().toJson(instance.lastUpdated),
};

_$HeadToHeadGameResultImpl _$$HeadToHeadGameResultImplFromJson(
  Map<String, dynamic> json,
) => _$HeadToHeadGameResultImpl(
  gameId: json['gameId'] as String,
  won: json['won'] as bool,
  pointsScored: (json['pointsScored'] as num).toInt(),
  pointsAllowed: (json['pointsAllowed'] as num).toInt(),
  eloChange: (json['eloChange'] as num).toDouble(),
  partnerId: json['partnerId'] as String?,
  opponentPartnerId: json['opponentPartnerId'] as String?,
  timestamp: const RequiredTimestampConverter().fromJson(
    json['timestamp'] as Object,
  ),
);

Map<String, dynamic> _$$HeadToHeadGameResultImplToJson(
  _$HeadToHeadGameResultImpl instance,
) => <String, dynamic>{
  'gameId': instance.gameId,
  'won': instance.won,
  'pointsScored': instance.pointsScored,
  'pointsAllowed': instance.pointsAllowed,
  'eloChange': instance.eloChange,
  'partnerId': instance.partnerId,
  'opponentPartnerId': instance.opponentPartnerId,
  'timestamp': const RequiredTimestampConverter().toJson(instance.timestamp),
};
