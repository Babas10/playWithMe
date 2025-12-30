// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_ranking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserRankingImpl _$$UserRankingImplFromJson(Map<String, dynamic> json) =>
    _$UserRankingImpl(
      globalRank: (json['globalRank'] as num).toInt(),
      totalUsers: (json['totalUsers'] as num).toInt(),
      percentile: (json['percentile'] as num).toDouble(),
      friendsRank: (json['friendsRank'] as num?)?.toInt(),
      totalFriends: (json['totalFriends'] as num?)?.toInt(),
      calculatedAt: const RequiredTimestampConverter().fromJson(
        json['calculatedAt'] as Object,
      ),
    );

Map<String, dynamic> _$$UserRankingImplToJson(_$UserRankingImpl instance) =>
    <String, dynamic>{
      'globalRank': instance.globalRank,
      'totalUsers': instance.totalUsers,
      'percentile': instance.percentile,
      'friendsRank': instance.friendsRank,
      'totalFriends': instance.totalFriends,
      'calculatedAt': const RequiredTimestampConverter().toJson(
        instance.calculatedAt,
      ),
    };
