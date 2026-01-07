// Represents an item in the group activity feed (either a game or training session)
import 'package:freezed_annotation/freezed_annotation.dart';
import 'game_model.dart';
import 'training_session_model.dart';

part 'group_activity_item.freezed.dart';

/// Union type representing an activity in a group (game or training session)
/// Used to combine and display both types in a unified activity feed
@freezed
class GroupActivityItem with _$GroupActivityItem {
  const factory GroupActivityItem.game(GameModel game) = GameActivityItem;
  const factory GroupActivityItem.training(TrainingSessionModel session) =
      TrainingActivityItem;

  const GroupActivityItem._();

  /// Get the activity ID (either game.id or session.id)
  String get id => when(
        game: (game) => game.id,
        training: (session) => session.id,
      );

  /// Get the activity start time for sorting
  DateTime get startTime => when(
        game: (game) => game.scheduledAt,
        training: (session) => session.startTime,
      );

  /// Get the activity title
  String get title => when(
        game: (game) => game.title,
        training: (session) => session.title,
      );

  /// Get the group ID
  String get groupId => when(
        game: (game) => game.groupId,
        training: (session) => session.groupId,
      );

  /// Check if activity is in the past
  bool get isPast => startTime.isBefore(DateTime.now());

  /// Check if activity is upcoming
  bool get isUpcoming => !isPast;
}
