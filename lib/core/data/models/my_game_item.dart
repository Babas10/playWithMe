// Unified display model for MyGamesPage (Story 28.11).
// Merges GameModel (joined games) and GameInvitationDetails (pending invitations)
// into a single list item so both sections use the same tile.

import 'package:play_with_me/core/data/models/game_invitation_details.dart';
import 'package:play_with_me/core/data/models/game_model.dart';

class MyGameItem {
  final String gameId;

  /// Non-null when this item represents a pending invitation (user not yet in playerIds).
  final String? invitationId;

  final String title;
  final DateTime scheduledAt;
  final String locationName;
  final String groupName;
  final GameStatus status;

  const MyGameItem({
    required this.gameId,
    this.invitationId,
    required this.title,
    required this.scheduledAt,
    required this.locationName,
    required this.groupName,
    required this.status,
  });

  bool get isInvitation => invitationId != null;

  bool get isUpcoming =>
      status == GameStatus.inProgress ||
      (status == GameStatus.scheduled &&
          scheduledAt.isAfter(DateTime.now()));

  bool get isPast =>
      status == GameStatus.completed ||
      status == GameStatus.verification ||
      // A scheduled game whose time has passed needs results submitted —
      // show it in Past so the user can find it and record the outcome.
      (status == GameStatus.scheduled &&
          !scheduledAt.isAfter(DateTime.now()));

  factory MyGameItem.fromGame(GameModel game) => MyGameItem(
        gameId: game.id,
        title: game.title,
        scheduledAt: game.scheduledAt,
        locationName: game.location.name,
        groupName: '',
        status: game.status,
      );

  factory MyGameItem.fromInvitation(GameInvitationDetails inv) => MyGameItem(
        gameId: inv.gameId,
        invitationId: inv.invitationId,
        title: inv.gameTitle,
        scheduledAt: inv.gameScheduledAt,
        locationName: inv.gameLocationName,
        groupName: inv.groupName,
        status: GameStatus.scheduled,
      );
}
