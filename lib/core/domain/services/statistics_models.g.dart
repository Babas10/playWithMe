// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlayerRatingImpl _$$PlayerRatingImplFromJson(Map<String, dynamic> json) =>
    _$PlayerRatingImpl(
      playerId: json['playerId'] as String,
      rating: (json['rating'] as num).toDouble(),
      displayName: json['displayName'] as String?,
    );

Map<String, dynamic> _$$PlayerRatingImplToJson(_$PlayerRatingImpl instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'rating': instance.rating,
      'displayName': instance.displayName,
    };

_$EloResultImpl _$$EloResultImplFromJson(Map<String, dynamic> json) =>
    _$EloResultImpl(
      teamAPlayer1: PlayerRating.fromJson(
        json['teamAPlayer1'] as Map<String, dynamic>,
      ),
      teamAPlayer2: PlayerRating.fromJson(
        json['teamAPlayer2'] as Map<String, dynamic>,
      ),
      teamBPlayer1: PlayerRating.fromJson(
        json['teamBPlayer1'] as Map<String, dynamic>,
      ),
      teamBPlayer2: PlayerRating.fromJson(
        json['teamBPlayer2'] as Map<String, dynamic>,
      ),
      teamARating: (json['teamARating'] as num).toDouble(),
      teamBRating: (json['teamBRating'] as num).toDouble(),
      teamAExpectedScore: (json['teamAExpectedScore'] as num).toDouble(),
      teamBExpectedScore: (json['teamBExpectedScore'] as num).toDouble(),
      ratingDelta: (json['ratingDelta'] as num).toDouble(),
      teamAWon: json['teamAWon'] as bool,
    );

Map<String, dynamic> _$$EloResultImplToJson(_$EloResultImpl instance) =>
    <String, dynamic>{
      'teamAPlayer1': instance.teamAPlayer1,
      'teamAPlayer2': instance.teamAPlayer2,
      'teamBPlayer1': instance.teamBPlayer1,
      'teamBPlayer2': instance.teamBPlayer2,
      'teamARating': instance.teamARating,
      'teamBRating': instance.teamBRating,
      'teamAExpectedScore': instance.teamAExpectedScore,
      'teamBExpectedScore': instance.teamBExpectedScore,
      'ratingDelta': instance.ratingDelta,
      'teamAWon': instance.teamAWon,
    };

_$TeammateStatsImpl _$$TeammateStatsImplFromJson(Map<String, dynamic> json) =>
    _$TeammateStatsImpl(
      playerId: json['playerId'] as String,
      displayName: json['displayName'] as String,
      gamesPlayed: (json['gamesPlayed'] as num).toInt(),
      gamesWon: (json['gamesWon'] as num).toInt(),
      gamesLost: (json['gamesLost'] as num).toInt(),
      winRate: (json['winRate'] as num).toDouble(),
      averageRatingChange: (json['averageRatingChange'] as num).toDouble(),
    );

Map<String, dynamic> _$$TeammateStatsImplToJson(_$TeammateStatsImpl instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
      'displayName': instance.displayName,
      'gamesPlayed': instance.gamesPlayed,
      'gamesWon': instance.gamesWon,
      'gamesLost': instance.gamesLost,
      'winRate': instance.winRate,
      'averageRatingChange': instance.averageRatingChange,
    };
