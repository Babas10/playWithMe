import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_model.dart'; // For RequiredTimestampConverter

part 'rating_history_entry.freezed.dart';
part 'rating_history_entry.g.dart';

/// Represents an entry in a user's ELO rating history (Story 14.5.3).
/// Each entry records a rating change after a game.
@freezed
class RatingHistoryEntry with _$RatingHistoryEntry {
  const factory RatingHistoryEntry({
    /// Auto-generated document ID from Firestore
    required String entryId,

    /// Reference to the game that caused this rating change
    required String gameId,

    /// Rating before the game
    required double oldRating,

    /// Rating after the game
    required double newRating,

    /// Rating change (positive or negative)
    required double ratingChange,

    /// Display string for opponent team (e.g., "Player A & Player B")
    required String opponentTeam,

    /// Whether the player's team won
    required bool won,

    /// When this rating update was recorded
    @RequiredTimestampConverter() required DateTime timestamp,
  }) = _RatingHistoryEntry;

  const RatingHistoryEntry._();

  factory RatingHistoryEntry.fromJson(Map<String, dynamic> json) =>
      _$RatingHistoryEntryFromJson(json);

  /// Factory constructor for creating from Firestore DocumentSnapshot
  factory RatingHistoryEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RatingHistoryEntry.fromJson({
      ...data,
      'entryId': doc.id,
    });
  }

  /// Convert to Firestore-compatible map (excludes entryId since it's the document ID)
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('entryId'); // Remove entryId as it's the document ID
    return json;
  }

  /// Convenience getters for display

  /// Whether this was a rating gain
  bool get isGain => ratingChange > 0;

  /// Whether this was a rating loss
  bool get isLoss => ratingChange < 0;

  /// Absolute value of rating change for display
  double get absoluteChange => ratingChange.abs();

  /// Formatted rating change string (e.g., "+16.0" or "-12.5")
  String get formattedChange {
    final sign = ratingChange >= 0 ? '+' : '';
    return '$sign${ratingChange.toStringAsFixed(1)}';
  }

  /// Formatted new rating string
  String get formattedNewRating => newRating.toStringAsFixed(0);

  /// Formatted old rating string
  String get formattedOldRating => oldRating.toStringAsFixed(0);
}
