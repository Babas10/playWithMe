import '../base_bloc_event.dart';
import '../../../data/models/game_model.dart';

abstract class GameEvent extends BaseBlocEvent {
  const GameEvent();
}

class LoadGameById extends GameEvent {
  final String gameId;

  const LoadGameById({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}

class LoadGamesForUser extends GameEvent {
  final String userId;

  const LoadGamesForUser({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadGamesForGroup extends GameEvent {
  final String groupId;

  const LoadGamesForGroup({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

class LoadUpcomingGamesForUser extends GameEvent {
  final String userId;

  const LoadUpcomingGamesForUser({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class LoadPastGamesForUser extends GameEvent {
  final String userId;
  final int limit;

  const LoadPastGamesForUser({
    required this.userId,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [userId, limit];
}

class CreateGame extends GameEvent {
  final GameModel game;

  const CreateGame({required this.game});

  @override
  List<Object?> get props => [game];
}

class UpdateGameInfo extends GameEvent {
  final String gameId;
  final String? title;
  final String? description;
  final DateTime? scheduledAt;
  final GameLocation? location;
  final String? notes;
  final List<String>? equipment;
  final Duration? estimatedDuration;

  const UpdateGameInfo({
    required this.gameId,
    this.title,
    this.description,
    this.scheduledAt,
    this.location,
    this.notes,
    this.equipment,
    this.estimatedDuration,
  });

  @override
  List<Object?> get props => [
        gameId,
        title,
        description,
        scheduledAt,
        location,
        notes,
        equipment,
        estimatedDuration,
      ];
}

class UpdateGameSettings extends GameEvent {
  final String gameId;
  final int? maxPlayers;
  final int? minPlayers;
  final bool? allowWaitlist;
  final bool? allowPlayerInvites;
  final GameVisibility? visibility;
  final GameType? gameType;
  final GameSkillLevel? skillLevel;
  final bool? weatherDependent;
  final String? weatherNotes;

  const UpdateGameSettings({
    required this.gameId,
    this.maxPlayers,
    this.minPlayers,
    this.allowWaitlist,
    this.allowPlayerInvites,
    this.visibility,
    this.gameType,
    this.skillLevel,
    this.weatherDependent,
    this.weatherNotes,
  });

  @override
  List<Object?> get props => [
        gameId,
        maxPlayers,
        minPlayers,
        allowWaitlist,
        allowPlayerInvites,
        visibility,
        gameType,
        skillLevel,
        weatherDependent,
        weatherNotes,
      ];
}

class JoinGame extends GameEvent {
  final String gameId;
  final String userId;

  const JoinGame({
    required this.gameId,
    required this.userId,
  });

  @override
  List<Object?> get props => [gameId, userId];
}

class LeaveGame extends GameEvent {
  final String gameId;
  final String userId;

  const LeaveGame({
    required this.gameId,
    required this.userId,
  });

  @override
  List<Object?> get props => [gameId, userId];
}

class StartGame extends GameEvent {
  final String gameId;

  const StartGame({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}

class EndGame extends GameEvent {
  final String gameId;
  final String? winnerId;
  final List<GameScore>? finalScores;

  const EndGame({
    required this.gameId,
    this.winnerId,
    this.finalScores,
  });

  @override
  List<Object?> get props => [gameId, winnerId, finalScores];
}

class CancelGame extends GameEvent {
  final String gameId;

  const CancelGame({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}

class UpdateGameScores extends GameEvent {
  final String gameId;
  final List<GameScore> scores;

  const UpdateGameScores({
    required this.gameId,
    required this.scores,
  });

  @override
  List<Object?> get props => [gameId, scores];
}

class LoadGamesByLocation extends GameEvent {
  final double latitude;
  final double longitude;
  final double radiusKm;
  final int limit;

  const LoadGamesByLocation({
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [latitude, longitude, radiusKm, limit];
}

class LoadGamesByStatus extends GameEvent {
  final GameStatus status;
  final int limit;

  const LoadGamesByStatus({
    required this.status,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [status, limit];
}

class LoadGamesToday extends GameEvent {
  const LoadGamesToday();
}

class LoadGamesThisWeek extends GameEvent {
  const LoadGamesThisWeek();
}

class SearchGames extends GameEvent {
  final String query;
  final int limit;

  const SearchGames({
    required this.query,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, limit];
}

class LoadGameStats extends GameEvent {
  final String gameId;

  const LoadGameStats({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}

class DeleteGame extends GameEvent {
  final String gameId;

  const DeleteGame({required this.gameId});

  @override
  List<Object?> get props => [gameId];
}