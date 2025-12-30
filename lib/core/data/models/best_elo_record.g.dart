// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'best_elo_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BestEloRecordImpl _$$BestEloRecordImplFromJson(Map<String, dynamic> json) =>
    _$BestEloRecordImpl(
      elo: (json['elo'] as num).toDouble(),
      date: const RequiredTimestampConverter().fromJson(json['date'] as Object),
      gameId: json['gameId'] as String,
    );

Map<String, dynamic> _$$BestEloRecordImplToJson(_$BestEloRecordImpl instance) =>
    <String, dynamic>{
      'elo': instance.elo,
      'date': const RequiredTimestampConverter().toJson(instance.date),
      'gameId': instance.gameId,
    };
