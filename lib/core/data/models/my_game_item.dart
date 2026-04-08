// Unified display model for MyGamesPage (Stories 28.11 / 28.12).
// Represents joined games, un-joined group games, and pending invitations
// in a single list item so all sections use the same tile.

import 'package:play_with_me/core/data/models/game_invitation_details.dart';
import 'package:play_with_me/core/data/models/game_model.dart';

enum MyGameItemSource {
  /// User is already in playerIds.
  joined,

  /// Game belongs to one of the user's groups but the user hasn't joined yet.
  groupGame,

  /// Cross-group guest invitation — user is in pendingInviteeIds.
  invitation,
}

class MyGameItem {
  final String gameId;
  final MyGameItemSource source;

  /// Non-null for [MyGameItemSource.invitation] items.
  final String? invitationId;

  final String title;
  final DateTime scheduledAt;
  final String locationName;
  final String groupName;
  final GameStatus status;

  const MyGameItem({
    required this.gameId,
    required this.source,
    this.invitationId,
    required this.title,
    required this.scheduledAt,
    required this.locationName,
    required this.groupName,
    required this.status,
  });

  bool get isInvitation => source == MyGameItemSource.invitation;
  bool get isGroupGame => source == MyGameItemSource.groupGame;
  bool get isJoined => source == MyGameItemSource.joined;

  bool get isUpcoming =>
      status == GameStatus.inProgress ||
      (status == GameStatus.scheduled && scheduledAt.isAfter(DateTime.now()));

  bool get isPast =>
      status == GameStatus.completed ||
      status == GameStatus.verification ||
      // A scheduled game whose time has passed — show in Past so the user
      // can find it and record the outcome.
      (status == GameStatus.scheduled && !scheduledAt.isAfter(DateTime.now()));

  factory MyGameItem.fromGame(GameModel game) => MyGameItem(
    gameId: game.id,
    source: MyGameItemSource.joined,
    title: game.title,
    scheduledAt: game.scheduledAt,
    locationName: game.location.name,
    groupName: '',
    status: game.status,
  );

  factory MyGameItem.fromGroupGame(
    GameModel game, {
    required String groupName,
  }) => MyGameItem(
    gameId: game.id,
    source: MyGameItemSource.groupGame,
    title: game.title,
    scheduledAt: game.scheduledAt,
    locationName: game.location.name,
    groupName: groupName,
    status: game.status,
  );

  factory MyGameItem.fromInvitation(GameInvitationDetails inv) => MyGameItem(
    gameId: inv.gameId,
    source: MyGameItemSource.invitation,
    invitationId: inv.invitationId,
    title: inv.gameTitle,
    scheduledAt: inv.gameScheduledAt,
    locationName: inv.gameLocationName,
    groupName: inv.groupName,
    status: GameStatus.scheduled,
  );
}
