import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart'; // For RequiredTimestampConverter

part 'best_elo_record.freezed.dart';
part 'best_elo_record.g.dart';

/// Represents a user's best ELO rating within a specific time period (Story 302.1).
/// Used to highlight peak performance in the monthly improvement chart.
@freezed
class BestEloRecord with _$BestEloRecord {
  const factory BestEloRecord({
    /// The highest ELO rating achieved
    required double elo,

    /// The date when this ELO was achieved
    @RequiredTimestampConverter() required DateTime date,

    /// Reference to the game that resulted in this rating
    required String gameId,
  }) = _BestEloRecord;

  factory BestEloRecord.fromJson(Map<String, dynamic> json) =>
      _$BestEloRecordFromJson(json);
}
