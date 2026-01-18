// Tests FirestoreGameRepository methods with fake Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/repositories/firestore_game_repository.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';

void main() {
  group('FirestoreGameRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirestoreGameRepository repository;

    GameModel createTestGame({
      String id = '',
      String title = 'Test Game',
      String groupId = 'group-123',
      String createdBy = 'user-123',
      DateTime? createdAt,
      DateTime? scheduledAt,
      GameStatus status = GameStatus.scheduled,
      List<String> playerIds = const [],
      List<String> waitlistIds = const [],
      int maxPlayers = 4,
      int minPlayers = 2,
    }) {
      return GameModel(
        id: id,
        title: title,
        groupId: groupId,
        createdBy: createdBy,
        createdAt: createdAt ?? DateTime(2024, 1, 1),
        scheduledAt: scheduledAt ?? DateTime.now().add(const Duration(days: 1)),
        location: const GameLocation(name: 'Beach Court'),
        status: status,
        playerIds: playerIds,
        waitlistIds: waitlistIds,
        maxPlayers: maxPlayers,
        minPlayers: minPlayers,
      );
    }

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = FirestoreGameRepository(firestore: fakeFirestore);
    });

    group('constructor', () {
      test('creates repository with custom Firestore instance', () {
        final customFirestore = FakeFirebaseFirestore();
        final repo = FirestoreGameRepository(firestore: customFirestore);
        expect(repo, isNotNull);
      });

      // Note: Cannot test default Firestore without Firebase.initializeApp()
      // The default constructor uses FirebaseFirestore.instance which requires
      // Firebase to be initialized. This is tested in integration tests.
    });

    group('createGame', () {
      test('creates game successfully and returns document ID', () async {
        final testGame = createTestGame();

        final gameId = await repository.createGame(testGame);

        expect(gameId, isNotEmpty);
        final doc = await fakeFirestore.collection('games').doc(gameId).get();
        expect(doc.exists, true);
        expect(doc.data()!['title'], 'Test Game');
        expect(doc.data()!['groupId'], 'group-123');
        expect(doc.data()!['createdBy'], 'user-123');
      });

      test('creates game without id field in Firestore document', () async {
        final testGame = createTestGame(id: 'should-be-ignored');

        final gameId = await repository.createGame(testGame);

        final doc = await fakeFirestore.collection('games').doc(gameId).get();
        expect(doc.data()!.containsKey('id'), false);
      });

      test('creates game with all fields', () async {
        final testGame = GameModel(
          id: '',
          title: 'Full Game',
          description: 'A complete game',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          scheduledAt: DateTime(2024, 2, 1),
          location: const GameLocation(
            name: 'Beach Court',
            address: '123 Beach St',
            latitude: 34.0,
            longitude: -118.0,
          ),
          status: GameStatus.scheduled,
          maxPlayers: 8,
          minPlayers: 4,
          playerIds: const ['user-123', 'user-456'],
          allowWaitlist: true,
          notes: 'Bring sunscreen',
          equipment: const ['Ball', 'Net'],
        );

        final gameId = await repository.createGame(testGame);

        final doc = await fakeFirestore.collection('games').doc(gameId).get();
        final data = doc.data()!;
        expect(data['description'], 'A complete game');
        expect(data['maxPlayers'], 8);
        expect(data['minPlayers'], 4);
        expect(data['playerIds'], ['user-123', 'user-456']);
        expect(data['notes'], 'Bring sunscreen');
        expect(data['equipment'], ['Ball', 'Net']);
      });
    });

    group('getGameById', () {
      test('returns game when it exists', () async {
        final testGame = createTestGame();
        final gameId = await repository.createGame(testGame);

        final retrievedGame = await repository.getGameById(gameId);

        expect(retrievedGame, isNotNull);
        expect(retrievedGame!.id, gameId);
        expect(retrievedGame.title, 'Test Game');
        expect(retrievedGame.groupId, 'group-123');
      });

      test('returns null when game does not exist', () async {
        final game = await repository.getGameById('non-existent-id');
        expect(game, isNull);
      });
    });

    group('getGamesByIds', () {
      test('returns empty list when gameIds is empty', () async {
        final games = await repository.getGamesByIds([]);
        expect(games, isEmpty);
      });

      test('returns games for valid IDs', () async {
        final game1 = createTestGame(title: 'Game 1');
        final game2 = createTestGame(title: 'Game 2');
        final id1 = await repository.createGame(game1);
        final id2 = await repository.createGame(game2);

        final games = await repository.getGamesByIds([id1, id2]);

        expect(games.length, 2);
        expect(games.any((g) => g.title == 'Game 1'), true);
        expect(games.any((g) => g.title == 'Game 2'), true);
      });

      test('handles more than 10 IDs by batching', () async {
        final gameIds = <String>[];
        for (int i = 0; i < 15; i++) {
          final game = createTestGame(title: 'Game $i');
          final id = await repository.createGame(game);
          gameIds.add(id);
        }

        final games = await repository.getGamesByIds(gameIds);

        expect(games.length, 15);
      });

      test('ignores non-existent IDs', () async {
        final game = createTestGame(title: 'Existing Game');
        final existingId = await repository.createGame(game);

        final games =
            await repository.getGamesByIds([existingId, 'non-existent-id']);

        expect(games.length, 1);
        expect(games.first.title, 'Existing Game');
      });
    });

    group('getGamesForUser', () {
      test('returns stream of games for user', () async {
        final game1 = createTestGame(
          title: 'User Game',
          playerIds: const ['user-123', 'user-456'],
        );
        final game2 = createTestGame(
          title: 'Other Game',
          playerIds: const ['user-789'],
        );
        await repository.createGame(game1);
        await repository.createGame(game2);

        final stream = repository.getGamesForUser('user-123');
        final games = await stream.first;

        expect(games.length, 1);
        expect(games.first.title, 'User Game');
      });

      test('returns empty list when user has no games', () async {
        final game = createTestGame(playerIds: const ['other-user']);
        await repository.createGame(game);

        final stream = repository.getGamesForUser('user-123');
        final games = await stream.first;

        expect(games, isEmpty);
      });
    });

    group('getGamesForGroup', () {
      test('returns stream of games for group', () async {
        final game1 = createTestGame(title: 'Group Game', groupId: 'group-123');
        final game2 =
            createTestGame(title: 'Other Group', groupId: 'group-456');
        await repository.createGame(game1);
        await repository.createGame(game2);

        final stream = repository.getGamesForGroup('group-123');
        final games = await stream.first;

        expect(games.length, 1);
        expect(games.first.title, 'Group Game');
      });

      test('returns empty list when group has no games', () async {
        final game = createTestGame(groupId: 'other-group');
        await repository.createGame(game);

        final stream = repository.getGamesForGroup('group-123');
        final games = await stream.first;

        expect(games, isEmpty);
      });
    });

    group('updateGameInfo', () {
      test('updates game info successfully', () async {
        final testGame = createTestGame();
        final gameId = await repository.createGame(testGame);

        await repository.updateGameInfo(
          gameId,
          title: 'Updated Title',
          description: 'New description',
          notes: 'Updated notes',
        );

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.title, 'Updated Title');
        expect(updatedGame.description, 'New description');
        expect(updatedGame.notes, 'Updated notes');
      });

      test('throws GameException when game not found', () async {
        await expectLater(
          repository.updateGameInfo('non-existent', title: 'New Title'),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'not-found',
          )),
        );
      });

      test('updates location', () async {
        final testGame = createTestGame();
        final gameId = await repository.createGame(testGame);

        await repository.updateGameInfo(
          gameId,
          location: const GameLocation(
            name: 'New Court',
            address: '456 New St',
          ),
        );

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.location.name, 'New Court');
        expect(updatedGame.location.address, '456 New St');
      });
    });

    group('updateGameSettings', () {
      test('updates game settings successfully', () async {
        final testGame = createTestGame();
        final gameId = await repository.createGame(testGame);

        await repository.updateGameSettings(
          gameId,
          maxPlayers: 10,
          minPlayers: 4,
          allowWaitlist: false,
        );

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.maxPlayers, 10);
        expect(updatedGame.minPlayers, 4);
        expect(updatedGame.allowWaitlist, false);
      });

      test('throws GameException when game not found', () async {
        await expectLater(
          repository.updateGameSettings('non-existent', maxPlayers: 10),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'not-found',
          )),
        );
      });

      test('updates visibility and game type', () async {
        final testGame = createTestGame();
        final gameId = await repository.createGame(testGame);

        await repository.updateGameSettings(
          gameId,
          visibility: GameVisibility.public,
          gameType: GameType.beachVolleyball,
          skillLevel: GameSkillLevel.advanced,
        );

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.visibility, GameVisibility.public);
        expect(updatedGame.gameType, GameType.beachVolleyball);
        expect(updatedGame.skillLevel, GameSkillLevel.advanced);
      });
    });

    group('addPlayer', () {
      test('adds player to game', () async {
        final testGame = createTestGame(playerIds: const ['user-123']);
        final gameId = await repository.createGame(testGame);

        await repository.addPlayer(gameId, 'user-456');

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.playerIds, contains('user-456'));
      });

      test('throws GameException when game not found', () async {
        await expectLater(
          repository.addPlayer('non-existent', 'user-123'),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'not-found',
          )),
        );
      });

      test('adds player to waitlist when game is full', () async {
        final testGame = createTestGame(
          playerIds: const ['user-1', 'user-2', 'user-3', 'user-4'],
          maxPlayers: 4,
        );
        final gameId = await repository.createGame(testGame);

        await repository.addPlayer(gameId, 'user-5');

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.waitlistIds, contains('user-5'));
        expect(updatedGame.playerIds, isNot(contains('user-5')));
      });

      test('does not add player if already in game', () async {
        final testGame = createTestGame(playerIds: const ['user-123']);
        final gameId = await repository.createGame(testGame);

        await repository.addPlayer(gameId, 'user-123');

        final updatedGame = await repository.getGameById(gameId);
        expect(
            updatedGame!.playerIds.where((id) => id == 'user-123').length, 1);
      });
    });

    group('removePlayer', () {
      test('removes player from game', () async {
        final testGame = createTestGame(
          playerIds: const ['user-123', 'user-456'],
        );
        final gameId = await repository.createGame(testGame);

        await repository.removePlayer(gameId, 'user-456');

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.playerIds, isNot(contains('user-456')));
        expect(updatedGame.playerIds, contains('user-123'));
      });

      test('throws GameException when game not found', () async {
        await expectLater(
          repository.removePlayer('non-existent', 'user-123'),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'not-found',
          )),
        );
      });

      test('promotes waitlisted player when spot opens', () async {
        final testGame = createTestGame(
          playerIds: const ['user-1', 'user-2', 'user-3', 'user-4'],
          waitlistIds: const ['user-5'],
          maxPlayers: 4,
        );
        final gameId = await repository.createGame(testGame);

        await repository.removePlayer(gameId, 'user-1');

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.playerIds, contains('user-5'));
        expect(updatedGame.waitlistIds, isNot(contains('user-5')));
      });
    });

    group('startGame', () {
      test('starts game successfully', () async {
        final testGame = createTestGame(
          playerIds: const ['user-1', 'user-2'],
          minPlayers: 2,
          status: GameStatus.scheduled,
        );
        final gameId = await repository.createGame(testGame);

        await repository.startGame(gameId);

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.status, GameStatus.inProgress);
        expect(updatedGame.startedAt, isNotNull);
      });

      test('throws GameException when game not found', () async {
        await expectLater(
          repository.startGame('non-existent'),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'not-found',
          )),
        );
      });

      test('does not start game without minimum players', () async {
        final testGame = createTestGame(
          playerIds: const ['user-1'],
          minPlayers: 2,
          status: GameStatus.scheduled,
        );
        final gameId = await repository.createGame(testGame);

        await repository.startGame(gameId);

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.status, GameStatus.scheduled);
      });
    });

    group('endGame', () {
      test('ends game successfully', () async {
        final testGame = createTestGame(
          playerIds: const ['user-1', 'user-2'],
          status: GameStatus.inProgress,
        );
        final gameId = await repository.createGame(testGame);

        await repository.endGame(gameId, winnerId: 'user-1');

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.status, GameStatus.completed);
        expect(updatedGame.winnerId, 'user-1');
        expect(updatedGame.endedAt, isNotNull);
      });

      test('throws GameException when game not found', () async {
        await expectLater(
          repository.endGame('non-existent'),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'not-found',
          )),
        );
      });

      test('does not end game if not in progress', () async {
        final testGame = createTestGame(status: GameStatus.scheduled);
        final gameId = await repository.createGame(testGame);

        await repository.endGame(gameId);

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.status, GameStatus.scheduled);
      });

      test('ends game with final scores', () async {
        final testGame = createTestGame(
          playerIds: const ['user-1', 'user-2'],
          status: GameStatus.inProgress,
        );
        final gameId = await repository.createGame(testGame);
        final scores = [
          const GameScore(playerId: 'user-1', score: 21),
          const GameScore(playerId: 'user-2', score: 15),
        ];

        await repository.endGame(gameId, finalScores: scores);

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.scores.length, 2);
      });
    });

    group('cancelGame', () {
      test('cancels game successfully', () async {
        final testGame = createTestGame(status: GameStatus.scheduled);
        final gameId = await repository.createGame(testGame);

        await repository.cancelGame(gameId);

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.status, GameStatus.cancelled);
      });

      test('throws GameException when game not found', () async {
        await expectLater(
          repository.cancelGame('non-existent'),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'not-found',
          )),
        );
      });

      test('does not cancel already completed game', () async {
        final testGame = createTestGame(status: GameStatus.completed);
        final gameId = await repository.createGame(testGame);

        await repository.cancelGame(gameId);

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.status, GameStatus.completed);
      });
    });

    group('markGameAsCompleted', () {
      test('marks game as completed when user is creator', () async {
        final testGame = createTestGame(
          createdBy: 'user-123',
          status: GameStatus.inProgress,
        );
        final gameId = await repository.createGame(testGame);

        await repository.markGameAsCompleted(gameId, 'user-123');

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.status, GameStatus.completed);
      });

      test('throws GameException when game not found', () async {
        await expectLater(
          repository.markGameAsCompleted('non-existent', 'user-123'),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'not-found',
          )),
        );
      });

      test('throws GameException when user is not creator', () async {
        final testGame = createTestGame(createdBy: 'user-123');
        final gameId = await repository.createGame(testGame);

        await expectLater(
          repository.markGameAsCompleted(gameId, 'user-456'),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          )),
        );
      });

      test('throws GameException when game already completed', () async {
        final testGame = createTestGame(
          createdBy: 'user-123',
          status: GameStatus.completed,
        );
        final gameId = await repository.createGame(testGame);

        await expectLater(
          repository.markGameAsCompleted(gameId, 'user-123'),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'already-completed',
          )),
        );
      });

      test('throws GameException when game is cancelled', () async {
        final testGame = createTestGame(
          createdBy: 'user-123',
          status: GameStatus.cancelled,
        );
        final gameId = await repository.createGame(testGame);

        await expectLater(
          repository.markGameAsCompleted(gameId, 'user-123'),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'invalid-state',
          )),
        );
      });
    });

    group('updateGameTeams', () {
      test('updates teams when user is participant', () async {
        final testGame = createTestGame(
          createdBy: 'user-123',
          playerIds: const ['user-1', 'user-2', 'user-3', 'user-4'],
          status: GameStatus.scheduled,
        );
        final gameId = await repository.createGame(testGame);
        const teams = GameTeams(
          teamAPlayerIds: ['user-1', 'user-2'],
          teamBPlayerIds: ['user-3', 'user-4'],
        );

        await repository.updateGameTeams(gameId, 'user-123', teams);

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.teams, isNotNull);
        expect(updatedGame.teams!.teamAPlayerIds, ['user-1', 'user-2']);
        expect(updatedGame.teams!.teamBPlayerIds, ['user-3', 'user-4']);
      });

      test('throws GameException when game not found', () async {
        const teams = GameTeams(
          teamAPlayerIds: ['user-1'],
          teamBPlayerIds: ['user-2'],
        );

        await expectLater(
          repository.updateGameTeams('non-existent', 'user-123', teams),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'not-found',
          )),
        );
      });

      test('throws GameException when user is not participant or creator',
          () async {
        final testGame = createTestGame(
          createdBy: 'user-123',
          playerIds: const ['user-1', 'user-2'],
        );
        final gameId = await repository.createGame(testGame);
        const teams = GameTeams(
          teamAPlayerIds: ['user-1'],
          teamBPlayerIds: ['user-2'],
        );

        await expectLater(
          repository.updateGameTeams(gameId, 'user-999', teams),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          )),
        );
      });

      test('throws GameException when player on both teams', () async {
        final testGame = createTestGame(
          createdBy: 'user-123',
          playerIds: const ['user-1', 'user-2'],
        );
        final gameId = await repository.createGame(testGame);
        const teams = GameTeams(
          teamAPlayerIds: ['user-1'],
          teamBPlayerIds: ['user-1', 'user-2'],
        );

        await expectLater(
          repository.updateGameTeams(gameId, 'user-123', teams),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'invalid-argument',
          )),
        );
      });

      test('throws GameException when not all players assigned', () async {
        final testGame = createTestGame(
          createdBy: 'user-123',
          playerIds: const ['user-1', 'user-2', 'user-3', 'user-4'],
        );
        final gameId = await repository.createGame(testGame);
        const teams = GameTeams(
          teamAPlayerIds: ['user-1'],
          teamBPlayerIds: ['user-2'],
        );

        await expectLater(
          repository.updateGameTeams(gameId, 'user-123', teams),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'invalid-argument',
          )),
        );
      });

      test('throws GameException when game is cancelled', () async {
        final testGame = createTestGame(
          createdBy: 'user-123',
          playerIds: const ['user-1', 'user-2'],
          status: GameStatus.cancelled,
        );
        final gameId = await repository.createGame(testGame);
        const teams = GameTeams(
          teamAPlayerIds: ['user-1'],
          teamBPlayerIds: ['user-2'],
        );

        await expectLater(
          repository.updateGameTeams(gameId, 'user-123', teams),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'invalid-state',
          )),
        );
      });
    });

    group('updateScores', () {
      test('updates scores successfully', () async {
        final testGame = createTestGame(
          playerIds: const ['user-1', 'user-2'],
          status: GameStatus.inProgress,
        );
        final gameId = await repository.createGame(testGame);
        final scores = [
          const GameScore(playerId: 'user-1', score: 10),
          const GameScore(playerId: 'user-2', score: 8),
        ];

        await repository.updateScores(gameId, scores);

        final updatedGame = await repository.getGameById(gameId);
        expect(updatedGame!.scores.length, 2);
      });

      test('throws GameException when game not found', () async {
        final scores = [const GameScore(playerId: 'user-1', score: 10)];

        await expectLater(
          repository.updateScores('non-existent', scores),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'not-found',
          )),
        );
      });
    });

    group('getGamesByStatus', () {
      test('returns games with matching status', () async {
        final scheduledGame =
            createTestGame(title: 'Scheduled', status: GameStatus.scheduled);
        final completedGame =
            createTestGame(title: 'Completed', status: GameStatus.completed);
        await repository.createGame(scheduledGame);
        await repository.createGame(completedGame);

        final games = await repository.getGamesByStatus(GameStatus.scheduled);

        expect(games.length, 1);
        expect(games.first.title, 'Scheduled');
      });

      test('returns empty list when no games match status', () async {
        final game = createTestGame(status: GameStatus.scheduled);
        await repository.createGame(game);

        final games = await repository.getGamesByStatus(GameStatus.cancelled);

        expect(games, isEmpty);
      });

      test('respects limit parameter', () async {
        for (int i = 0; i < 5; i++) {
          final game = createTestGame(
            title: 'Game $i',
            status: GameStatus.scheduled,
          );
          await repository.createGame(game);
        }

        final games =
            await repository.getGamesByStatus(GameStatus.scheduled, limit: 3);

        expect(games.length, 3);
      });
    });

    group('searchGames', () {
      test('returns empty list for empty query', () async {
        final game = createTestGame(title: 'Beach Volleyball');
        await repository.createGame(game);

        final results = await repository.searchGames('');

        expect(results, isEmpty);
      });

      test('returns empty list for whitespace query', () async {
        final game = createTestGame(title: 'Beach Volleyball');
        await repository.createGame(game);

        final results = await repository.searchGames('   ');

        expect(results, isEmpty);
      });

      test('finds games by title', () async {
        final game1 = createTestGame(title: 'beach volleyball');
        final game2 = createTestGame(title: 'soccer game');
        await repository.createGame(game1);
        await repository.createGame(game2);

        final results = await repository.searchGames('beach');

        expect(results.length, 1);
        expect(results.first.title, 'beach volleyball');
      });
    });

    group('getGameParticipants', () {
      test('returns participants for existing game', () async {
        final testGame = createTestGame(
          playerIds: const ['user-1', 'user-2', 'user-3'],
        );
        final gameId = await repository.createGame(testGame);

        final participants = await repository.getGameParticipants(gameId);

        expect(participants, ['user-1', 'user-2', 'user-3']);
      });

      test('returns empty list when game does not exist', () async {
        final participants =
            await repository.getGameParticipants('non-existent');
        expect(participants, isEmpty);
      });
    });

    group('getGameWaitlist', () {
      test('returns waitlist for existing game', () async {
        final testGame = createTestGame(
          waitlistIds: const ['user-5', 'user-6'],
        );
        final gameId = await repository.createGame(testGame);

        final waitlist = await repository.getGameWaitlist(gameId);

        expect(waitlist, ['user-5', 'user-6']);
      });

      test('returns empty list when game does not exist', () async {
        final waitlist = await repository.getGameWaitlist('non-existent');
        expect(waitlist, isEmpty);
      });
    });

    group('canUserJoinGame', () {
      test('returns true when user can join', () async {
        final testGame = createTestGame(
          playerIds: const ['user-1'],
          maxPlayers: 4,
          status: GameStatus.scheduled,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
        );
        final gameId = await repository.createGame(testGame);

        final canJoin = await repository.canUserJoinGame(gameId, 'user-2');

        expect(canJoin, true);
      });

      test('returns false when game does not exist', () async {
        final canJoin =
            await repository.canUserJoinGame('non-existent', 'user-1');
        expect(canJoin, false);
      });

      test('returns false when user already in game', () async {
        final testGame = createTestGame(
          playerIds: const ['user-1'],
          maxPlayers: 4,
          status: GameStatus.scheduled,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
        );
        final gameId = await repository.createGame(testGame);

        final canJoin = await repository.canUserJoinGame(gameId, 'user-1');

        expect(canJoin, false);
      });

      test('returns false when game is not scheduled', () async {
        final testGame = createTestGame(
          playerIds: const ['user-1'],
          maxPlayers: 4,
          status: GameStatus.cancelled,
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
        );
        final gameId = await repository.createGame(testGame);

        final canJoin = await repository.canUserJoinGame(gameId, 'user-2');

        expect(canJoin, false);
      });
    });

    group('deleteGame', () {
      test('deletes game successfully', () async {
        final testGame = createTestGame();
        final gameId = await repository.createGame(testGame);

        await repository.deleteGame(gameId);

        final deletedGame = await repository.getGameById(gameId);
        expect(deletedGame, isNull);
      });

      test('does not throw when deleting non-existent game', () async {
        await expectLater(
          repository.deleteGame('non-existent'),
          completes,
        );
      });
    });

    group('gameExists', () {
      test('returns true when game exists', () async {
        final testGame = createTestGame();
        final gameId = await repository.createGame(testGame);

        final exists = await repository.gameExists(gameId);

        expect(exists, true);
      });

      test('returns false when game does not exist', () async {
        final exists = await repository.gameExists('non-existent');
        expect(exists, false);
      });
    });

    group('getGameStats', () {
      test('returns stats for existing game', () async {
        final testGame = createTestGame(
          playerIds: const ['user-1', 'user-2'],
          waitlistIds: const ['user-3'],
          maxPlayers: 4,
          minPlayers: 2,
          status: GameStatus.scheduled,
        );
        final gameId = await repository.createGame(testGame);

        final stats = await repository.getGameStats(gameId);

        expect(stats['currentPlayerCount'], 2);
        expect(stats['availableSpots'], 2);
        expect(stats['waitlistCount'], 1);
        expect(stats['isFull'], false);
        expect(stats['hasMinimumPlayers'], true);
        expect(stats['status'], 'scheduled');
      });

      test('throws GameException when game not found', () async {
        await expectLater(
          repository.getGameStats('non-existent'),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'not-found',
          )),
        );
      });
    });

    group('getGameStream', () {
      test('returns stream of game updates', () async {
        final testGame = createTestGame(title: 'Original Title');
        final gameId = await repository.createGame(testGame);

        final stream = repository.getGameStream(gameId);
        final firstGame = await stream.first;

        expect(firstGame, isNotNull);
        expect(firstGame!.title, 'Original Title');
      });

      test('returns null for non-existent game', () async {
        final stream = repository.getGameStream('non-existent');
        final game = await stream.first;

        expect(game, isNull);
      });
    });

    group('getGamesToday', () {
      test('returns games scheduled for today', () async {
        final now = DateTime.now();
        final todayGame = createTestGame(
          title: 'Today Game',
          scheduledAt:
              DateTime(now.year, now.month, now.day, 14, 0), // Today at 2pm
        );
        final tomorrowGame = createTestGame(
          title: 'Tomorrow Game',
          scheduledAt: DateTime(now.year, now.month, now.day)
              .add(const Duration(days: 1, hours: 10)),
        );
        await repository.createGame(todayGame);
        await repository.createGame(tomorrowGame);

        final games = await repository.getGamesToday();

        expect(games.length, 1);
        expect(games.first.title, 'Today Game');
      });
    });

    group('getGamesThisWeek', () {
      test('returns games scheduled for this week', () async {
        final now = DateTime.now();
        // Calculate start of current week (Monday)
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

        final thisWeekGame = createTestGame(
          title: 'This Week Game',
          scheduledAt: startOfWeek.add(const Duration(days: 2, hours: 10)),
        );
        final nextWeekGame = createTestGame(
          title: 'Next Week Game',
          scheduledAt: startOfWeek.add(const Duration(days: 10)),
        );
        await repository.createGame(thisWeekGame);
        await repository.createGame(nextWeekGame);

        final games = await repository.getGamesThisWeek();

        expect(games.any((g) => g.title == 'This Week Game'), true);
        expect(games.any((g) => g.title == 'Next Week Game'), false);
      });
    });

    group('getGamesByLocation', () {
      test('returns games within radius', () async {
        final nearbyGame = GameModel(
          id: '',
          title: 'Nearby Game',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          location: const GameLocation(
            name: 'Beach Court',
            latitude: 34.0195,
            longitude: -118.4912,
          ),
        );
        final farGame = GameModel(
          id: '',
          title: 'Far Game',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          location: const GameLocation(
            name: 'Mountain Court',
            latitude: 40.0,
            longitude: -100.0,
          ),
        );
        await repository.createGame(nearbyGame);
        await repository.createGame(farGame);

        final games = await repository.getGamesByLocation(
          34.0, // Search near Santa Monica
          -118.5,
          50, // 50km radius
        );

        expect(games.any((g) => g.title == 'Nearby Game'), true);
        expect(games.any((g) => g.title == 'Far Game'), false);
      });

      test('excludes games without coordinates', () async {
        final gameWithCoords = GameModel(
          id: '',
          title: 'Has Coords',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          location: const GameLocation(
            name: 'Beach Court',
            latitude: 34.0195,
            longitude: -118.4912,
          ),
        );
        final gameWithoutCoords = GameModel(
          id: '',
          title: 'No Coords',
          groupId: 'group-123',
          createdBy: 'user-123',
          createdAt: DateTime(2024, 1, 1),
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          location: const GameLocation(name: 'Unknown Location'),
        );
        await repository.createGame(gameWithCoords);
        await repository.createGame(gameWithoutCoords);

        final games = await repository.getGamesByLocation(34.0, -118.5, 50);

        expect(games.any((g) => g.title == 'Has Coords'), true);
        expect(games.any((g) => g.title == 'No Coords'), false);
      });
    });

    group('getPastGamesForUser', () {
      test('returns past games for user', () async {
        final pastGame = createTestGame(
          title: 'Past Game',
          playerIds: const ['user-123'],
          scheduledAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        final futureGame = createTestGame(
          title: 'Future Game',
          playerIds: const ['user-123'],
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
        );
        await repository.createGame(pastGame);
        await repository.createGame(futureGame);

        final games = await repository.getPastGamesForUser('user-123');

        expect(games.any((g) => g.title == 'Past Game'), true);
        expect(games.any((g) => g.title == 'Future Game'), false);
      });

      test('respects limit parameter', () async {
        for (int i = 0; i < 5; i++) {
          final game = createTestGame(
            title: 'Past Game $i',
            playerIds: const ['user-123'],
            scheduledAt:
                DateTime.now().subtract(Duration(days: i + 1)),
          );
          await repository.createGame(game);
        }

        final games =
            await repository.getPastGamesForUser('user-123', limit: 3);

        expect(games.length, 3);
      });
    });

    group('updateGameResult', () {
      test('throws GameException when game not found', () async {
        const result = GameResult(
          games: [],
          overallWinner: 'teamA',
        );

        await expectLater(
          repository.updateGameResult('non-existent', 'user-123', result),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'not-found',
          )),
        );
      });

      test('throws GameException when user is not participant or creator',
          () async {
        final testGame = createTestGame(
          createdBy: 'user-123',
          playerIds: const ['user-1', 'user-2'],
        );
        final gameId = await repository.createGame(testGame);
        const result = GameResult(
          games: [],
          overallWinner: 'teamA',
        );

        await expectLater(
          repository.updateGameResult(gameId, 'user-999', result),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          )),
        );
      });

      test('throws GameException when game is cancelled', () async {
        final testGame = createTestGame(
          createdBy: 'user-123',
          playerIds: const ['user-123'],
          status: GameStatus.cancelled,
        );
        final gameId = await repository.createGame(testGame);
        const result = GameResult(
          games: [],
          overallWinner: 'teamA',
        );

        await expectLater(
          repository.updateGameResult(gameId, 'user-123', result),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'invalid-state',
          )),
        );
      });

      test('throws GameException when teams not assigned', () async {
        final testGame = createTestGame(
          createdBy: 'user-123',
          playerIds: const ['user-123'],
          status: GameStatus.inProgress,
        );
        final gameId = await repository.createGame(testGame);
        const result = GameResult(
          games: [],
          overallWinner: 'teamA',
        );

        await expectLater(
          repository.updateGameResult(gameId, 'user-123', result),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'failed-precondition',
          )),
        );
      });
    });

    group('confirmGameResult', () {
      test('throws GameException when game not found', () async {
        await expectLater(
          repository.confirmGameResult('non-existent', 'user-123'),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'not-found',
          )),
        );
      });
    });

    group('saveGameResult', () {
      test('throws GameException when game not found', () async {
        const teams = GameTeams(
          teamAPlayerIds: ['user-1'],
          teamBPlayerIds: ['user-2'],
        );
        const result = GameResult(
          games: [],
          overallWinner: 'teamA',
        );

        await expectLater(
          repository.saveGameResult(
            gameId: 'non-existent',
            userId: 'user-123',
            teams: teams,
            result: result,
          ),
          throwsA(isA<GameException>().having(
            (e) => e.code,
            'code',
            'not-found',
          )),
        );
      });
    });
  });
}
