// Integration test for game result persistence to Firestore
// Tests saveGameResult with real Firestore using Firebase Emulator

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/repositories/firestore_game_repository.dart';

import 'helpers/firebase_emulator_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await FirebaseEmulatorHelper.initialize();
  });

  setUp(() async {
    await FirebaseEmulatorHelper.clearFirestore();
    await FirebaseEmulatorHelper.signOut();
  });

  tearDown(() async {
    await FirebaseEmulatorHelper.signOut();
  });

  group('Game Result Persistence', () {
    test(
      'saveGameResult atomically saves teams, scores, and sets eloCalculated flag',
      () async {
        // 1. Create test user (game creator)
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'creator@test.com',
          password: 'password123',
          displayName: 'Game Creator',
        );

        // 2. Sign in as creator
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'creator@test.com',
          password: 'password123',
        );

        // 3. Create a group
        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          name: 'Test Volleyball Group',
          createdBy: user.uid,
        );

        // 4. Create players for the game
        final player1 = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'player1@test.com',
          password: 'password123',
          displayName: 'Player 1',
        );
        final player2 = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'player2@test.com',
          password: 'password123',
          displayName: 'Player 2',
        );
        final player3 = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'player3@test.com',
          password: 'password123',
          displayName: 'Player 3',
        );
        final player4 = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'player4@test.com',
          password: 'password123',
          displayName: 'Player 4',
        );

        // 5. Create a completed game with players
        final now = DateTime.now();
        final gameModel = GameModel(
          id: 'test-game-123',
          title: 'Beach Volleyball Match',
          groupId: groupId,
          createdBy: user.uid,
          createdAt: now,
          scheduledAt: now.subtract(const Duration(hours: 2)),
          startedAt: now.subtract(const Duration(hours: 2)),
          endedAt: now.subtract(const Duration(minutes: 30)),
          location: const GameLocation(name: 'Sunset Beach Court'),
          status: GameStatus.completed,
          playerIds: [player1.uid, player2.uid, player3.uid, player4.uid],
        );

        // 6. Save the game to Firestore
        final firestore = FirebaseFirestore.instance;
        await firestore
            .collection('games')
            .doc(gameModel.id)
            .set(gameModel.toFirestore());

        // 7. Create teams
        final teams = GameTeams(
          teamAPlayerIds: [player1.uid, player2.uid],
          teamBPlayerIds: [player3.uid, player4.uid],
        );

        // 8. Create game result with multiple games and sets
        const result = GameResult(
          games: [
            IndividualGame(
              gameNumber: 1,
              sets: [
                SetScore(teamAPoints: 21, teamBPoints: 18, setNumber: 1),
              ],
              winner: 'teamA',
            ),
            IndividualGame(
              gameNumber: 2,
              sets: [
                SetScore(teamAPoints: 19, teamBPoints: 21, setNumber: 1),
              ],
              winner: 'teamB',
            ),
            IndividualGame(
              gameNumber: 3,
              sets: [
                SetScore(teamAPoints: 21, teamBPoints: 17, setNumber: 1),
              ],
              winner: 'teamA',
            ),
          ],
          overallWinner: 'teamA',
        );

        // 9. Save game result using repository
        final repository = FirestoreGameRepository(firestore: firestore);

        final timestampBeforeSave = DateTime.now();

        await repository.saveGameResult(
          gameId: gameModel.id,
          userId: user.uid,
          teams: teams,
          result: result,
        );

        // 10. Fetch the updated game from Firestore
        final updatedGameDoc = await firestore
            .collection('games')
            .doc(gameModel.id)
            .get();

        expect(updatedGameDoc.exists, isTrue);
        final updatedGame = GameModel.fromFirestore(updatedGameDoc);

        // 11. Verify teams were saved correctly
        expect(updatedGame.teams, isNotNull);
        expect(updatedGame.teams!.teamAPlayerIds, [player1.uid, player2.uid]);
        expect(updatedGame.teams!.teamBPlayerIds, [player3.uid, player4.uid]);

        // 12. Verify result was saved correctly
        expect(updatedGame.result, isNotNull);
        expect(updatedGame.result!.games.length, 3);
        expect(updatedGame.result!.overallWinner, 'teamA');
        expect(updatedGame.result!.games[0].winner, 'teamA');
        expect(updatedGame.result!.games[1].winner, 'teamB');
        expect(updatedGame.result!.games[2].winner, 'teamA');

        // 13. Verify sets were saved correctly
        expect(updatedGame.result!.games[0].sets.length, 1);
        expect(updatedGame.result!.games[0].sets[0].teamAPoints, 21);
        expect(updatedGame.result!.games[0].sets[0].teamBPoints, 18);

        // 14. Verify eloCalculated flag is set to false
        expect(updatedGame.eloCalculated, isFalse);

        // 15. Verify completedAt timestamp is set
        expect(updatedGame.completedAt, isNotNull);
        expect(
          updatedGame.completedAt!.isAfter(timestampBeforeSave.subtract(const Duration(seconds: 5))),
          isTrue,
        );
        expect(
          updatedGame.completedAt!.isBefore(DateTime.now().add(const Duration(seconds: 5))),
          isTrue,
        );

        // 16. Verify winnerId is set
        expect(updatedGame.winnerId, 'teamA');

        // 17. Verify updatedAt timestamp is set
        expect(updatedGame.updatedAt, isNotNull);
      },
    );

    test(
      'saveGameResult fails when user is not the game creator',
      () async {
        // 1. Create two users
        final creator = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'creator@test.com',
          password: 'password123',
          displayName: 'Game Creator',
        );

        final otherUser = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'other@test.com',
          password: 'password123',
          displayName: 'Other User',
        );

        // 2. Sign in as creator
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'creator@test.com',
          password: 'password123',
        );

        // 3. Create a group
        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          name: 'Test Group',
          createdBy: creator.uid,
        );

        // 4. Create a completed game
        final gameModel = GameModel(
          id: 'test-game-456',
          title: 'Test Game',
          groupId: groupId,
          createdBy: creator.uid,
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now(),
          location: const GameLocation(name: 'Court'),
          status: GameStatus.completed,
          playerIds: ['p1', 'p2', 'p3', 'p4'],
        );

        final firestore = FirebaseFirestore.instance;
        await firestore
            .collection('games')
            .doc(gameModel.id)
            .set(gameModel.toFirestore());

        // 5. Try to save result as non-creator
        final repository = FirestoreGameRepository(firestore: firestore);

        expect(
          () => repository.saveGameResult(
            gameId: gameModel.id,
            userId: otherUser.uid,
            teams: const GameTeams(
              teamAPlayerIds: ['p1', 'p2'],
              teamBPlayerIds: ['p3', 'p4'],
            ),
            result: const GameResult(
              games: [
                IndividualGame(
                  gameNumber: 1,
                  sets: [SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1)],
                  winner: 'teamA',
                ),
              ],
              overallWinner: 'teamA',
            ),
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Only the game creator can save game result'),
            ),
          ),
        );
      },
    );

    test(
      'saveGameResult fails when game is not completed',
      () async {
        // 1. Create test user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'creator@test.com',
          password: 'password123',
          displayName: 'Game Creator',
        );

        // 2. Sign in as creator
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'creator@test.com',
          password: 'password123',
        );

        // 3. Create a group
        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          name: 'Test Group',
          createdBy: user.uid,
        );

        // 4. Create a scheduled (not completed) game
        final gameModel = GameModel(
          id: 'test-game-789',
          title: 'Scheduled Game',
          groupId: groupId,
          createdBy: user.uid,
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now().add(const Duration(days: 1)),
          location: const GameLocation(name: 'Court'),
          status: GameStatus.scheduled, // Not completed!
          playerIds: ['p1', 'p2', 'p3', 'p4'],
        );

        final firestore = FirebaseFirestore.instance;
        await firestore
            .collection('games')
            .doc(gameModel.id)
            .set(gameModel.toFirestore());

        // 5. Try to save result for non-completed game
        final repository = FirestoreGameRepository(firestore: firestore);

        expect(
          () => repository.saveGameResult(
            gameId: gameModel.id,
            userId: user.uid,
            teams: const GameTeams(
              teamAPlayerIds: ['p1', 'p2'],
              teamBPlayerIds: ['p3', 'p4'],
            ),
            result: const GameResult(
              games: [
                IndividualGame(
                  gameNumber: 1,
                  sets: [SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1)],
                  winner: 'teamA',
                ),
              ],
              overallWinner: 'teamA',
            ),
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Can only save result to completed games'),
            ),
          ),
        );
      },
    );

    test(
      'saveGameResult fails with invalid teams (player on both teams)',
      () async {
        // 1. Create test user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'creator@test.com',
          password: 'password123',
          displayName: 'Game Creator',
        );

        // 2. Sign in
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'creator@test.com',
          password: 'password123',
        );

        // 3. Create a group
        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          name: 'Test Group',
          createdBy: user.uid,
        );

        // 4. Create a completed game
        final gameModel = GameModel(
          id: 'test-game-101',
          title: 'Test Game',
          groupId: groupId,
          createdBy: user.uid,
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now(),
          location: const GameLocation(name: 'Court'),
          status: GameStatus.completed,
          playerIds: ['p1', 'p2', 'p3', 'p4'],
        );

        final firestore = FirebaseFirestore.instance;
        await firestore
            .collection('games')
            .doc(gameModel.id)
            .set(gameModel.toFirestore());

        // 5. Try to save with invalid teams (p1 on both teams)
        final repository = FirestoreGameRepository(firestore: firestore);

        expect(
          () => repository.saveGameResult(
            gameId: gameModel.id,
            userId: user.uid,
            teams: const GameTeams(
              teamAPlayerIds: ['p1', 'p2'],
              teamBPlayerIds: ['p1', 'p3'], // p1 on both teams!
            ),
            result: const GameResult(
              games: [
                IndividualGame(
                  gameNumber: 1,
                  sets: [SetScore(teamAPoints: 21, teamBPoints: 19, setNumber: 1)],
                  winner: 'teamA',
                ),
              ],
              overallWinner: 'teamA',
            ),
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('A player cannot be on both teams'),
            ),
          ),
        );
      },
    );

    test(
      'saveGameResult fails with invalid result (invalid set score)',
      () async {
        // 1. Create test user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'creator@test.com',
          password: 'password123',
          displayName: 'Game Creator',
        );

        // 2. Sign in
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: 'creator@test.com',
          password: 'password123',
        );

        // 3. Create a group
        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          name: 'Test Group',
          createdBy: user.uid,
        );

        // 4. Create a completed game
        final gameModel = GameModel(
          id: 'test-game-202',
          title: 'Test Game',
          groupId: groupId,
          createdBy: user.uid,
          createdAt: DateTime.now(),
          scheduledAt: DateTime.now(),
          location: const GameLocation(name: 'Court'),
          status: GameStatus.completed,
          playerIds: ['p1', 'p2', 'p3', 'p4'],
        );

        final firestore = FirebaseFirestore.instance;
        await firestore
            .collection('games')
            .doc(gameModel.id)
            .set(gameModel.toFirestore());

        // 5. Try to save with invalid result (score too low)
        final repository = FirestoreGameRepository(firestore: firestore);

        expect(
          () => repository.saveGameResult(
            gameId: gameModel.id,
            userId: user.uid,
            teams: const GameTeams(
              teamAPlayerIds: ['p1', 'p2'],
              teamBPlayerIds: ['p3', 'p4'],
            ),
            result: const GameResult(
              games: [
                IndividualGame(
                  gameNumber: 1,
                  sets: [SetScore(teamAPoints: 15, teamBPoints: 10, setNumber: 1)], // Invalid - too low
                  winner: 'teamA',
                ),
              ],
              overallWinner: 'teamA',
            ),
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Invalid game result'),
            ),
          ),
        );
      },
    );
  });
}
