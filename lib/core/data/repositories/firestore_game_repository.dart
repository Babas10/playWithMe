import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../domain/exceptions/repository_exceptions.dart';
import '../../domain/repositories/game_repository.dart';
import '../models/game_model.dart';

class FirestoreGameRepository implements GameRepository {
  final FirebaseFirestore _firestore;

  static const String _collection = 'games';

  FirestoreGameRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<GameModel?> getGameById(String gameId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(gameId).get();
      return doc.exists ? GameModel.fromFirestore(doc) : null;
    } on FirebaseException catch (e) {
      throw GameException('Failed to get game: ${e.message}', code: e.code);
    } catch (e) {
      throw GameException('Failed to get game: $e', code: 'unknown');
    }
  }

  @override
  Stream<GameModel?> getGameStream(String gameId) {
    try {
      return _firestore
          .collection(_collection)
          .doc(gameId)
          .snapshots()
          .map((snapshot) =>
              snapshot.exists ? GameModel.fromFirestore(snapshot) : null)
          .handleError((error) {
        if (error is FirebaseException) {
          throw GameException('Failed to stream game: ${error.message}',
              code: error.code);
        }
        throw GameException('Failed to stream game: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw GameException('Failed to stream game: $e', code: 'stream-error');
    }
  }

  @override
  Future<List<GameModel>> getGamesByIds(List<String> gameIds) async {
    if (gameIds.isEmpty) return [];

    try {
      final List<GameModel> games = [];

      // Firestore 'in' queries are limited to 10 items
      const int batchSize = 10;
      for (int i = 0; i < gameIds.length; i += batchSize) {
        final batch = gameIds.skip(i).take(batchSize).toList();
        final query = await _firestore
            .collection(_collection)
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        for (final doc in query.docs) {
          if (doc.exists) {
            games.add(GameModel.fromFirestore(doc));
          }
        }
      }

      return games;
    } on FirebaseException catch (e) {
      throw GameException('Failed to get games: ${e.message}', code: e.code);
    } catch (e) {
      throw GameException('Failed to get games: $e', code: 'unknown');
    }
  }

  @override
  Stream<List<GameModel>> getGamesForUser(String userId) {
    try {
      return _firestore
          .collection(_collection)
          .where('playerIds', arrayContains: userId)
          .orderBy('scheduledAt', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .where((doc) => doc.exists)
              .map((doc) => GameModel.fromFirestore(doc))
              .toList())
          .handleError((error) {
        if (error is FirebaseException) {
          throw GameException(
              'Failed to get games for user: ${error.message}',
              code: error.code);
        }
        throw GameException('Failed to get games for user: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw GameException('Failed to get games for user: $e',
          code: 'stream-error');
    }
  }

  @override
  Stream<List<GameModel>> getGamesForGroup(String groupId) {
    try {
      return _firestore
          .collection(_collection)
          .where('groupId', isEqualTo: groupId)
          .orderBy('scheduledAt', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .where((doc) => doc.exists)
              .map((doc) => GameModel.fromFirestore(doc))
              .toList())
          .handleError((error) {
        if (error is FirebaseException) {
          throw GameException(
              'Failed to get games for group: ${error.message}',
              code: error.code);
        }
        throw GameException('Failed to get games for group: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw GameException('Failed to get games for group: $e',
          code: 'stream-error');
    }
  }

  @override
  Stream<int> getUpcomingGamesCount(String groupId) {
    try {
      final now = Timestamp.now();
      return _firestore
          .collection(_collection)
          .where('groupId', isEqualTo: groupId)
          .where('scheduledAt', isGreaterThan: now)
          .where('status', isEqualTo: 'scheduled')
          .snapshots()
          .map((snapshot) => snapshot.docs.length)
          .handleError((error) {
        if (error is FirebaseException) {
          throw GameException(
              'Failed to get upcoming games count: ${error.message}',
              code: error.code);
        }
        throw GameException('Failed to get upcoming games count: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw GameException('Failed to get upcoming games count: $e',
          code: 'stream-error');
    }
  }

  @override
  Stream<List<GameModel>> getUpcomingGamesForUser(String userId) {
    try {
      final now = Timestamp.now();
      return _firestore
          .collection(_collection)
          .where('playerIds', arrayContains: userId)
          .where('scheduledAt', isGreaterThan: now)
          .orderBy('scheduledAt', descending: false)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .where((doc) => doc.exists)
              .map((doc) => GameModel.fromFirestore(doc))
              .toList())
          .handleError((error) {
        if (error is FirebaseException) {
          throw GameException(
              'Failed to get upcoming games for user: ${error.message}',
              code: error.code);
        }
        throw GameException('Failed to get upcoming games for user: $error',
            code: 'stream-error');
      });
    } catch (e) {
      throw GameException('Failed to get upcoming games for user: $e',
          code: 'stream-error');
    }
  }

  @override
  Stream<GameModel?> getNextGameForUser(String userId) {
    final controller = StreamController<GameModel?>();
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? groupsSub;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? gamesSub;

    groupsSub = _firestore
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .listen(
      (groupsSnapshot) {
        gamesSub?.cancel();
        final groupIds = groupsSnapshot.docs.map((d) => d.id).toList();
        if (groupIds.isEmpty) {
          controller.add(null);
          return;
        }

        // Firestore 'whereIn' is limited to 30 values
        gamesSub = _firestore
            .collection(_collection)
            .where('groupId', whereIn: groupIds.take(30).toList())
            .where('status', isEqualTo: 'scheduled')
            .where('scheduledAt', isGreaterThan: Timestamp.now())
            .orderBy('scheduledAt')
            .snapshots()
            .listen(
          (gamesSnapshot) {
            final games = gamesSnapshot.docs
                .where((doc) => doc.exists)
                .map((doc) => GameModel.fromFirestore(doc))
                .toList();

            controller.add(games.isEmpty ? null : games.first);
          },
          onError: (Object error) {
            if (error is FirebaseException) {
              controller.addError(GameException(
                  'Failed to get next game: ${error.message}',
                  code: error.code));
            } else {
              controller.addError(GameException(
                  'Failed to get next game: $error',
                  code: 'stream-error'));
            }
          },
        );
      },
      onError: (Object error) {
        if (error is FirebaseException) {
          controller.addError(GameException(
              'Failed to get next game: ${error.message}',
              code: error.code));
        } else {
          controller.addError(GameException(
              'Failed to get next game: $error',
              code: 'stream-error'));
        }
      },
    );

    controller.onCancel = () {
      groupsSub?.cancel();
      gamesSub?.cancel();
    };

    return controller.stream;
  }

  @override
  Future<List<GameModel>> getPastGamesForUser(String userId,
      {int limit = 20}) async {
    try {
      final now = Timestamp.now();
      final query = await _firestore
          .collection(_collection)
          .where('playerIds', arrayContains: userId)
          .where('scheduledAt', isLessThan: now)
          .orderBy('scheduledAt', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .where((doc) => doc.exists)
          .map((doc) => GameModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw GameException('Failed to get past games for user: ${e.message}',
          code: e.code);
    } catch (e) {
      throw GameException('Failed to get past games for user: $e',
          code: 'unknown');
    }
  }

  @override
  Future<String> createGame(GameModel game) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(game.toFirestore());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw GameException('Failed to create game: ${e.message}', code: e.code);
    } catch (e) {
      throw GameException('Failed to create game: $e', code: 'unknown');
    }
  }

  @override
  Future<void> updateGameInfo(
    String gameId, {
    String? title,
    String? description,
    DateTime? scheduledAt,
    GameLocation? location,
    String? notes,
    List<String>? equipment,
    Duration? estimatedDuration,
  }) async {
    try {
      final currentGame = await getGameById(gameId);
      if (currentGame == null) {
        throw GameException('Game not found', code: 'not-found');
      }

      final updatedGame = currentGame.updateInfo(
        title: title,
        description: description,
        scheduledAt: scheduledAt,
        location: location,
        notes: notes,
        equipment: equipment,
        estimatedDuration: estimatedDuration,
      );

      await _firestore
          .collection(_collection)
          .doc(gameId)
          .set(updatedGame.toFirestore(), SetOptions(merge: true));
    } on GameException {
      rethrow;
    } on FirebaseException catch (e) {
      throw GameException('Failed to update game info: ${e.message}',
          code: e.code);
    } catch (e) {
      throw GameException('Failed to update game info: $e', code: 'unknown');
    }
  }

  @override
  Future<void> updateGameSettings(
    String gameId, {
    int? maxPlayers,
    int? minPlayers,
    bool? allowWaitlist,
    bool? allowPlayerInvites,
    GameVisibility? visibility,
    GameType? gameType,
    GameSkillLevel? skillLevel,
    bool? weatherDependent,
    String? weatherNotes,
  }) async {
    try {
      final currentGame = await getGameById(gameId);
      if (currentGame == null) {
        throw GameException('Game not found', code: 'not-found');
      }

      final updatedGame = currentGame.updateSettings(
        maxPlayers: maxPlayers,
        minPlayers: minPlayers,
        allowWaitlist: allowWaitlist,
        allowPlayerInvites: allowPlayerInvites,
        visibility: visibility,
        gameType: gameType,
        skillLevel: skillLevel,
        weatherDependent: weatherDependent,
        weatherNotes: weatherNotes,
      );

      await _firestore
          .collection(_collection)
          .doc(gameId)
          .set(updatedGame.toFirestore(), SetOptions(merge: true));
    } on GameException {
      rethrow;
    } on FirebaseException catch (e) {
      throw GameException('Failed to update game settings: ${e.message}',
          code: e.code);
    } catch (e) {
      throw GameException('Failed to update game settings: $e',
          code: 'unknown');
    }
  }

  @override
  Future<void> addPlayer(String gameId, String userId) async {
    try {
      final currentGame = await getGameById(gameId);
      if (currentGame == null) {
        throw GameException('Game not found', code: 'not-found');
      }

      final updatedGame = currentGame.addPlayer(userId);

      await _firestore
          .collection(_collection)
          .doc(gameId)
          .set(updatedGame.toFirestore(), SetOptions(merge: true));
    } on GameException {
      rethrow;
    } on FirebaseException catch (e) {
      throw GameException('Failed to add player: ${e.message}', code: e.code);
    } catch (e) {
      throw GameException('Failed to add player: $e', code: 'unknown');
    }
  }

  @override
  Future<void> removePlayer(String gameId, String userId) async {
    try {
      final currentGame = await getGameById(gameId);
      if (currentGame == null) {
        throw GameException('Game not found', code: 'not-found');
      }

      final updatedGame = currentGame.removePlayer(userId);

      await _firestore
          .collection(_collection)
          .doc(gameId)
          .set(updatedGame.toFirestore(), SetOptions(merge: true));
    } on GameException {
      rethrow;
    } on FirebaseException catch (e) {
      throw GameException('Failed to remove player: ${e.message}',
          code: e.code);
    } catch (e) {
      throw GameException('Failed to remove player: $e', code: 'unknown');
    }
  }

  @override
  Future<void> startGame(String gameId) async {
    try {
      final currentGame = await getGameById(gameId);
      if (currentGame == null) {
        throw GameException('Game not found', code: 'not-found');
      }

      final updatedGame = currentGame.startGame();

      await _firestore
          .collection(_collection)
          .doc(gameId)
          .set(updatedGame.toFirestore(), SetOptions(merge: true));
    } on GameException {
      rethrow;
    } on FirebaseException catch (e) {
      throw GameException('Failed to start game: ${e.message}', code: e.code);
    } catch (e) {
      throw GameException('Failed to start game: $e', code: 'unknown');
    }
  }

  @override
  Future<void> endGame(
    String gameId, {
    String? winnerId,
    List<GameScore>? finalScores,
  }) async {
    try {
      final currentGame = await getGameById(gameId);
      if (currentGame == null) {
        throw GameException('Game not found', code: 'not-found');
      }

      final updatedGame = currentGame.endGame(
        winnerId: winnerId,
        finalScores: finalScores,
      );

      await _firestore
          .collection(_collection)
          .doc(gameId)
          .set(updatedGame.toFirestore(), SetOptions(merge: true));
    } on GameException {
      rethrow;
    } on FirebaseException catch (e) {
      throw GameException('Failed to end game: ${e.message}', code: e.code);
    } catch (e) {
      throw GameException('Failed to end game: $e', code: 'unknown');
    }
  }

  @override
  Future<void> cancelGame(String gameId) async {
    try {
      final currentGame = await getGameById(gameId);
      if (currentGame == null) {
        throw GameException('Game not found', code: 'not-found');
      }

      final updatedGame = currentGame.cancelGame();

      await _firestore
          .collection(_collection)
          .doc(gameId)
          .set(updatedGame.toFirestore(), SetOptions(merge: true));
    } on GameException {
      rethrow;
    } on FirebaseException catch (e) {
      throw GameException('Failed to cancel game: ${e.message}', code: e.code);
    } catch (e) {
      throw GameException('Failed to cancel game: $e', code: 'unknown');
    }
  }

  @override
  Future<void> markGameAsCompleted(String gameId, String userId) async {
    try {
      final currentGame = await getGameById(gameId);
      if (currentGame == null) {
        throw GameException('Game not found', code: 'not-found');
      }

      // Check if user has permission (creator only for now)
      if (!currentGame.isCreator(userId)) {
        throw GameException(
            'Only the game creator can mark the game as completed',
            code: 'permission-denied');
      }

      // Check if game can be marked as completed
      if (currentGame.status == GameStatus.completed) {
        throw GameException('Game is already completed',
            code: 'already-completed');
      }

      if (currentGame.status == GameStatus.cancelled) {
        throw GameException('Cannot complete a cancelled game',
            code: 'invalid-state');
      }

      // Update game status to completed
      final updatedGame = currentGame.copyWith(
        status: GameStatus.completed,
        endedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(gameId)
          .set(updatedGame.toFirestore(), SetOptions(merge: true));
    } on GameException {
      rethrow;
    } on FirebaseException catch (e) {
      throw GameException('Failed to mark game as completed: ${e.message}',
          code: e.code);
    } catch (e) {
      throw GameException('Failed to mark game as completed: $e',
          code: 'unknown');
    }
  }

  @override
  Future<void> updateGameTeams(
      String gameId, String userId, GameTeams teams) async {
    try {
      final currentGame = await getGameById(gameId);
      if (currentGame == null) {
        throw GameException('Game not found', code: 'not-found');
      }

      // Check if user has permission (participant or creator)
      if (!currentGame.isPlayer(userId) && !currentGame.isCreator(userId)) {
        throw GameException('Only participants can update teams',
            code: 'permission-denied');
      }

      // Check if game is active
      if (currentGame.status == GameStatus.cancelled) {
        throw GameException('Cannot update teams for a cancelled game',
            code: 'invalid-state');
      }

      // Validate teams
      if (teams.hasPlayerOnBothTeams()) {
        throw GameException('A player cannot be on both teams',
            code: 'invalid-argument');
      }

      if (!teams.areAllPlayersAssigned(currentGame.playerIds)) {
        final unassigned = teams.getUnassignedPlayers(currentGame.playerIds);
        throw GameException(
            'All players must be assigned to a team. Unassigned: ${unassigned.join(", ")}',
            code: 'invalid-argument');
      }

      // Update game with teams
      final updatedGame = currentGame.copyWith(
        teams: teams,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(gameId)
          .set(updatedGame.toFirestore(), SetOptions(merge: true));
    } on GameException {
      rethrow;
    } on FirebaseException catch (e) {
      throw GameException('Failed to update game teams: ${e.message}',
          code: e.code);
    } catch (e) {
      throw GameException('Failed to update game teams: $e', code: 'unknown');
    }
  }

  @override
  Future<void> updateGameResult(
      String gameId, String userId, GameResult result) async {
    try {
      final currentGame = await getGameById(gameId);
      if (currentGame == null) {
        throw GameException('Game not found', code: 'not-found');
      }

      // Check if user has permission (participant or creator)
      if (!currentGame.isPlayer(userId) && !currentGame.isCreator(userId)) {
        throw GameException('Only participants can update game result',
            code: 'permission-denied');
      }

      // Check if game is active
      if (currentGame.status == GameStatus.cancelled) {
        throw GameException('Cannot update result of a cancelled game',
            code: 'invalid-state');
      }

      // Check if teams are assigned
      if (currentGame.teams == null) {
        throw GameException('Teams must be assigned before entering scores',
            code: 'failed-precondition');
      }

      // Validate result
      if (!result.isValid()) {
        throw GameException(
            'Invalid game result. Check that all sets are valid and winner is correct.',
            code: 'invalid-argument');
      }

      // Determine winner team and update winnerId
      String? winnerId;
      if (currentGame.teams != null) {
        final winningTeam = currentGame.teams!;
        if (result.overallWinner == 'teamA' &&
            winningTeam.teamAPlayerIds.isNotEmpty) {
          winnerId = result.overallWinner;
        } else if (result.overallWinner == 'teamB' &&
            winningTeam.teamBPlayerIds.isNotEmpty) {
          winnerId = result.overallWinner;
        }
      }

      // Update game with result
      final updatedGame = currentGame.copyWith(
        result: result,
        winnerId: winnerId,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(gameId)
          .set(updatedGame.toFirestore(), SetOptions(merge: true));
    } on GameException {
      rethrow;
    } on FirebaseException catch (e) {
      throw GameException('Failed to update game result: ${e.message}',
          code: e.code);
    } catch (e) {
      throw GameException('Failed to update game result: $e', code: 'unknown');
    }
  }

  @override
  Future<void> saveGameResult({
    required String gameId,
    required String userId,
    required GameTeams teams,
    required GameResult result,
  }) async {
    try {
      // Use a transaction to ensure atomic update
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection(_collection).doc(gameId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw GameException('Game not found', code: 'not-found');
        }

        final currentGame = GameModel.fromFirestore(snapshot);

        // Check if user has permission (participant or creator)
        if (!currentGame.isPlayer(userId) && !currentGame.isCreator(userId)) {
          throw GameException('Only participants can save game result',
              code: 'permission-denied');
        }

        // Check if game is active
        if (currentGame.status == GameStatus.cancelled) {
          throw GameException('Cannot save result to a cancelled game',
              code: 'invalid-state');
        }

        // Check if game has passed its scheduled time
        if (!currentGame.isPast &&
            currentGame.status != GameStatus.completed &&
            currentGame.status != GameStatus.inProgress) {
          throw GameException(
              'Cannot save result before the scheduled game time',
              code: 'failed-precondition');
        }

        // Check if game has minimum required players
        if (!currentGame.hasMinimumPlayers) {
          throw GameException(
              'Cannot save result without the minimum number of players (${currentGame.minPlayers} required, ${currentGame.currentPlayerCount} joined)',
              code: 'failed-precondition');
        }

        // Validate teams
        if (teams.hasPlayerOnBothTeams()) {
          throw GameException('A player cannot be on both teams',
              code: 'invalid-argument');
        }

        if (!teams.areAllPlayersAssigned(currentGame.playerIds)) {
          final unassigned = teams.getUnassignedPlayers(currentGame.playerIds);
          throw GameException(
              'All players must be assigned to a team. Unassigned: ${unassigned.join(", ")}',
              code: 'invalid-argument');
        }

        // Validate result
        if (!result.isValid()) {
          throw GameException(
              'Invalid game result. Check that all sets are valid and winner is correct.',
              code: 'invalid-argument');
        }

        // Determine winner team
        String? winnerId;
        if (result.overallWinner == 'teamA' ||
            result.overallWinner == 'teamB') {
          winnerId = result.overallWinner;
        }

        // Update game with teams, result, and set to verification
        final updatedGame = currentGame.copyWith(
          teams: teams,
          result: result,
          winnerId: winnerId,
          status: GameStatus.verification,
          resultSubmittedBy: userId,
          confirmedBy: [], // Reset confirmations on new submission
          eloCalculated: false, // Flag for Python function to process
          completedAt: DateTime.now(), // Mark when result was entered
          updatedAt: DateTime.now(),
        );

        // Perform atomic write
        transaction.set(
          docRef,
          updatedGame.toFirestore(),
          SetOptions(merge: true),
        );
      });
    } on GameException {
      rethrow;
    } on FirebaseException catch (e) {
      throw GameException('Failed to save game result: ${e.message}',
          code: e.code);
    } catch (e) {
      throw GameException('Failed to save game result: $e', code: 'unknown');
    }
  }

  @override
  Future<void> confirmGameResult(String gameId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection(_collection).doc(gameId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw GameException('Game not found', code: 'not-found');
        }

        final currentGame = GameModel.fromFirestore(snapshot);

        if (currentGame.status != GameStatus.verification) {
          throw GameException('Game is not in verification state',
              code: 'invalid-state');
        }

        if (currentGame.resultSubmittedBy == userId) {
          throw GameException('You cannot confirm your own result',
              code: 'permission-denied');
        }

        if (currentGame.confirmedBy.contains(userId)) {
          throw GameException('You have already confirmed this result',
              code: 'already-exists');
        }

        final updatedConfirmedBy = [...currentGame.confirmedBy, userId];
        // 1 confirmation is sufficient to complete the game
        final newStatus = GameStatus.completed;

        final updatedGame = currentGame.copyWith(
          confirmedBy: updatedConfirmedBy,
          status: newStatus,
          eloCalculated: false,
          updatedAt: DateTime.now(),
        );

        transaction.set(
          docRef,
          updatedGame.toFirestore(),
          SetOptions(merge: true),
        );
      });
    } on GameException {
      rethrow;
    } on FirebaseException catch (e) {
      throw GameException('Failed to confirm game result: ${e.message}',
          code: e.code);
    } catch (e) {
      throw GameException('Failed to confirm game result: $e', code: 'unknown');
    }
  }

  @override
  Future<void> updateScores(String gameId, List<GameScore> scores) async {
    try {
      final currentGame = await getGameById(gameId);
      if (currentGame == null) {
        throw GameException('Game not found', code: 'not-found');
      }

      final updatedGame = currentGame.updateScores(scores);

      await _firestore
          .collection(_collection)
          .doc(gameId)
          .set(updatedGame.toFirestore(), SetOptions(merge: true));
    } on GameException {
      rethrow;
    } on FirebaseException catch (e) {
      throw GameException('Failed to update scores: ${e.message}',
          code: e.code);
    } catch (e) {
      throw GameException('Failed to update scores: $e', code: 'unknown');
    }
  }

  @override
  Future<List<GameModel>> getGamesByLocation(
    double latitude,
    double longitude,
    double radiusKm, {
    int limit = 20,
  }) async {
    try {
      // Simple bounding box calculation for proximity search
      // For production, consider using a geohashing library or Firestore's native geoqueries
      const double earthRadiusKm = 6371.0;
      final double latDelta = (radiusKm / earthRadiusKm) * (180 / pi);
      final double lonDelta =
          (radiusKm / earthRadiusKm) * (180 / pi) / cos(latitude * pi / 180);

      final double minLat = latitude - latDelta;
      final double maxLat = latitude + latDelta;
      final double minLon = longitude - lonDelta;
      final double maxLon = longitude + lonDelta;

      final query = await _firestore
          .collection(_collection)
          .where('location.latitude', isGreaterThanOrEqualTo: minLat)
          .where('location.latitude', isLessThanOrEqualTo: maxLat)
          .limit(limit)
          .get();

      // Filter by longitude and calculate actual distance
      final games = query.docs
          .where((doc) => doc.exists)
          .map((doc) => GameModel.fromFirestore(doc))
          .where((game) {
        if (game.location.latitude == null ||
            game.location.longitude == null) {
          return false;
        }
        final gameLon = game.location.longitude!;
        if (gameLon < minLon || gameLon > maxLon) return false;

        // Calculate actual distance
        final distance = _calculateDistance(
          latitude,
          longitude,
          game.location.latitude!,
          game.location.longitude!,
        );
        return distance <= radiusKm;
      }).toList();

      return games;
    } on FirebaseException catch (e) {
      throw GameException('Failed to get games by location: ${e.message}',
          code: e.code);
    } catch (e) {
      throw GameException('Failed to get games by location: $e',
          code: 'unknown');
    }
  }

  @override
  Future<List<GameModel>> getGamesByStatus(
    GameStatus status, {
    int limit = 20,
  }) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status.toString().split('.').last)
          .orderBy('scheduledAt', descending: false)
          .limit(limit)
          .get();

      return query.docs
          .where((doc) => doc.exists)
          .map((doc) => GameModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw GameException('Failed to get games by status: ${e.message}',
          code: e.code);
    } catch (e) {
      throw GameException('Failed to get games by status: $e', code: 'unknown');
    }
  }

  @override
  Future<List<GameModel>> getGamesToday() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final query = await _firestore
          .collection(_collection)
          .where('scheduledAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('scheduledAt', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('scheduledAt', descending: false)
          .get();

      return query.docs
          .where((doc) => doc.exists)
          .map((doc) => GameModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw GameException('Failed to get games today: ${e.message}',
          code: e.code);
    } catch (e) {
      throw GameException('Failed to get games today: $e', code: 'unknown');
    }
  }

  @override
  Future<List<GameModel>> getGamesThisWeek() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 7));

      final query = await _firestore
          .collection(_collection)
          .where('scheduledAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .where('scheduledAt', isLessThan: Timestamp.fromDate(endOfWeek))
          .orderBy('scheduledAt', descending: false)
          .get();

      return query.docs
          .where((doc) => doc.exists)
          .map((doc) => GameModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw GameException('Failed to get games this week: ${e.message}',
          code: e.code);
    } catch (e) {
      throw GameException('Failed to get games this week: $e', code: 'unknown');
    }
  }

  @override
  Future<List<GameModel>> searchGames(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];

    try {
      final queryLower = query.toLowerCase();

      // Search by title (case-insensitive)
      final titleQuery = await _firestore
          .collection(_collection)
          .where('title', isGreaterThanOrEqualTo: queryLower)
          .where('title', isLessThanOrEqualTo: '${queryLower}z')
          .limit(limit)
          .get();

      return titleQuery.docs
          .where((doc) => doc.exists)
          .map((doc) => GameModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw GameException('Failed to search games: ${e.message}', code: e.code);
    } catch (e) {
      throw GameException('Failed to search games: $e', code: 'unknown');
    }
  }

  @override
  Future<List<String>> getGameParticipants(String gameId) async {
    try {
      final game = await getGameById(gameId);
      return game?.playerIds ?? [];
    } on GameException {
      rethrow;
    } catch (e) {
      throw GameException('Failed to get game participants: $e',
          code: 'unknown');
    }
  }

  @override
  Future<List<String>> getGameWaitlist(String gameId) async {
    try {
      final game = await getGameById(gameId);
      return game?.waitlistIds ?? [];
    } on GameException {
      rethrow;
    } catch (e) {
      throw GameException('Failed to get game waitlist: $e', code: 'unknown');
    }
  }

  @override
  Future<bool> canUserJoinGame(String gameId, String userId) async {
    try {
      final game = await getGameById(gameId);
      if (game == null) return false;

      return game.canUserJoin(userId);
    } on GameException {
      rethrow;
    } catch (e) {
      throw GameException('Failed to check if user can join game: $e',
          code: 'unknown');
    }
  }

  @override
  Future<void> deleteGame(String gameId) async {
    try {
      await _firestore.collection(_collection).doc(gameId).delete();
    } on FirebaseException catch (e) {
      throw GameException('Failed to delete game: ${e.message}', code: e.code);
    } catch (e) {
      throw GameException('Failed to delete game: $e', code: 'unknown');
    }
  }

  @override
  Future<bool> gameExists(String gameId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(gameId).get();
      return doc.exists;
    } on FirebaseException catch (e) {
      throw GameException('Failed to check if game exists: ${e.message}',
          code: e.code);
    } catch (e) {
      throw GameException('Failed to check if game exists: $e',
          code: 'unknown');
    }
  }

  @override
  Future<Map<String, dynamic>> getGameStats(String gameId) async {
    try {
      final game = await getGameById(gameId);
      if (game == null) {
        throw GameException('Game not found', code: 'not-found');
      }

      return {
        'currentPlayerCount': game.currentPlayerCount,
        'availableSpots': game.availableSpots,
        'waitlistCount': game.waitlistCount,
        'isFull': game.isFull,
        'hasMinimumPlayers': game.hasMinimumPlayers,
        'canStart': game.canStart,
        'isPast': game.isPast,
        'isToday': game.isToday,
        'isThisWeek': game.isThisWeek,
        'gameDuration': game.gameDuration?.inMinutes,
        'status': game.status.toString().split('.').last,
        'createdAt': game.createdAt.toIso8601String(),
        'scheduledAt': game.scheduledAt.toIso8601String(),
      };
    } on GameException {
      rethrow;
    } catch (e) {
      throw GameException('Failed to get game stats: $e', code: 'unknown');
    }
  }

  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusKm = 6371.0;

    final double dLat = (lat2 - lat1) * pi / 180;
    final double dLon = (lon2 - lon1) * pi / 180;

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  @override
  Stream<GameHistoryPage> getCompletedGames({
    String? groupId,
    int limit = 20,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    DocumentSnapshot? lastDocument,
  }) async* {
    try {
      // Call Cloud Function to fetch completed games
      final callable =
          FirebaseFunctions.instance.httpsCallable('getCompletedGames');

      final result = await callable.call({
        if (groupId != null) 'groupId': groupId,
        if (userId != null) 'userId': userId,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        'limit': limit,
        if (lastDocument != null) 'lastGameId': lastDocument.id,
      });

      final data = result.data as Map<String, dynamic>;
      final gamesData = data['games'] as List<dynamic>;
      final hasMore = data['hasMore'] as bool;

      final games = gamesData.map<GameModel>((gameData) {
        // Convert Cloud Function response to GameModel
        final Map<String, dynamic> gameMap =
            Map<String, dynamic>.from(gameData);

        // Convert Firestore Timestamps to ISO strings for fromJson
        if (gameMap['createdAt'] is Map) {
          final ts = gameMap['createdAt'] as Map;
          final timestamp =
              Timestamp(ts['_seconds'] as int, ts['_nanoseconds'] as int);
          gameMap['createdAt'] = timestamp.toDate().toIso8601String();
        }
        if (gameMap['updatedAt'] is Map) {
          final ts = gameMap['updatedAt'] as Map;
          final timestamp =
              Timestamp(ts['_seconds'] as int, ts['_nanoseconds'] as int);
          gameMap['updatedAt'] = timestamp.toDate().toIso8601String();
        }
        if (gameMap['scheduledAt'] is Map) {
          final ts = gameMap['scheduledAt'] as Map;
          final timestamp =
              Timestamp(ts['_seconds'] as int, ts['_nanoseconds'] as int);
          gameMap['scheduledAt'] = timestamp.toDate().toIso8601String();
        }
        if (gameMap['completedAt'] != null && gameMap['completedAt'] is Map) {
          final ts = gameMap['completedAt'] as Map;
          final timestamp =
              Timestamp(ts['_seconds'] as int, ts['_nanoseconds'] as int);
          gameMap['completedAt'] = timestamp.toDate().toIso8601String();
        }

        return GameModel.fromJson(gameMap);
      }).toList();

      yield GameHistoryPage(
        games: games,
        lastDocument: null, // Cloud Function uses game ID for pagination
        hasMore: hasMore,
      );
    } on FirebaseFunctionsException catch (e) {
      throw GameException('Failed to get completed games: ${e.message}',
          code: e.code);
    } catch (e) {
      throw GameException('Failed to get completed games: $e', code: 'unknown');
    }
  }
}
