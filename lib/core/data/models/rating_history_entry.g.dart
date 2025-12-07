// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_history_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RatingHistoryEntryImpl _$$RatingHistoryEntryImplFromJson(
  Map<String, dynamic> json,
) => _$RatingHistoryEntryImpl(
  entryId: json['entryId'] as String,
  gameId: json['gameId'] as String,
  oldRating: (json['oldRating'] as num).toDouble(),
  newRating: (json['newRating'] as num).toDouble(),
  ratingChange: (json['ratingChange'] as num).toDouble(),
  opponentTeam: json['opponentTeam'] as String,
  won: json['won'] as bool,
  timestamp: const RequiredTimestampConverter().fromJson(
    json['timestamp'] as Object,
  ),
);

Map<String, dynamic> _$$RatingHistoryEntryImplToJson(
  _$RatingHistoryEntryImpl instance,
) => <String, dynamic>{
  'entryId': instance.entryId,
  'gameId': instance.gameId,
  'oldRating': instance.oldRating,
  'newRating': instance.newRating,
  'ratingChange': instance.ratingChange,
  'opponentTeam': instance.opponentTeam,
  'won': instance.won,
  'timestamp': const RequiredTimestampConverter().toJson(instance.timestamp),
};
