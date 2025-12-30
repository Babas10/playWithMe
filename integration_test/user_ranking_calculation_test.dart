// Integration test for user ranking calculation via Cloud Function (Story 302.2)
// Tests calculateUserRanking Cloud Function with real Firebase Emulator

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:play_with_me/core/data/repositories/firestore_user_repository.dart';

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

  group('User Ranking Calculation', () {
    test('calculates correct global ranking for mid-range user', () async {
      // 1. Create 10 test users with varying ELO ratings
      final users = <String>[];

      for (int i = 0; i < 10; i++) {
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user$i@test.com',
          password: 'password123',
          displayName: 'User $i',
        );
        users.add(user.uid);

        // Set varying ELO ratings and mark as having played games
        final eloRating = 1500.0 + (i * 100); // 1500, 1600, 1700, ..., 2400
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'eloRating': eloRating,
          'eloGamesPlayed': 10,
        });
      }

      // 2. Sign in as user with ELO 1800 (rank should be #4 of 10)
      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'user3@test.com', // ELO 1800
        password: 'password123',
      );

      // 3. Create repository and get ranking
      final repository = FirestoreUserRepository(
        firestore: FirebaseFirestore.instance,
        functions: FirebaseFunctions.instance,
      );

      final ranking = await repository.getUserRanking(users[3]);

      // 4. Verify global ranking
      expect(ranking.globalRank, equals(4)); // 3 users have higher ELO
      expect(ranking.totalUsers, equals(10));

      // Expected percentile: (10 - 4 + 1) / 10 = 7 / 10 = 70%
      expect(ranking.percentile, equals(70.0));
    });

    test('calculates rank #1 for highest ELO user', () async {
      // 1. Create 5 test users
      final users = <String>[];

      for (int i = 0; i < 5; i++) {
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user$i@test.com',
          password: 'password123',
          displayName: 'User $i',
        );
        users.add(user.uid);

        final eloRating = 1500.0 + (i * 100);
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'eloRating': eloRating,
          'eloGamesPlayed': 5,
        });
      }

      // 2. Sign in as user with highest ELO (1900)
      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'user4@test.com',
        password: 'password123',
      );

      // 3. Get ranking
      final repository = FirestoreUserRepository(
        firestore: FirebaseFirestore.instance,
        functions: FirebaseFunctions.instance,
      );

      final ranking = await repository.getUserRanking(users[4]);

      // 4. Verify #1 rank
      expect(ranking.globalRank, equals(1));
      expect(ranking.totalUsers, equals(5));
      expect(ranking.percentile, equals(100.0));
    });

    test('calculates friends ranking correctly', () async {
      // 1. Create main user
      final mainUser = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'main@test.com',
        password: 'password123',
        displayName: 'Main User',
      );

      // Set main user's ELO to 1700
      await FirebaseFirestore.instance.collection('users').doc(mainUser.uid).update({
        'eloRating': 1700.0,
        'eloGamesPlayed': 10,
      });

      // 2. Create 5 friends with varying ELO
      final friendIds = <String>[];
      final friendElos = [1500.0, 1600.0, 1650.0, 1750.0, 1800.0]; // Main: 1700

      for (int i = 0; i < 5; i++) {
        final friend = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'friend$i@test.com',
          password: 'password123',
          displayName: 'Friend $i',
        );
        friendIds.add(friend.uid);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(friend.uid)
            .update({
          'eloRating': friendElos[i],
          'eloGamesPlayed': 5,
        });
      }

      // 3. Set main user's friends list
      await FirebaseFirestore.instance.collection('users').doc(mainUser.uid).update({
        'friendIds': friendIds,
      });

      // 4. Sign in as main user
      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'main@test.com',
        password: 'password123',
      );

      // 5. Get ranking
      final repository = FirestoreUserRepository(
        firestore: FirebaseFirestore.instance,
        functions: FirebaseFunctions.instance,
      );

      final ranking = await repository.getUserRanking(mainUser.uid);

      // 6. Verify friends ranking
      // Main user (1700) should be #3 of 5 friends
      // Friends with higher ELO: 1750, 1800 (2 friends)
      expect(ranking.friendsRank, equals(3));
      expect(ranking.totalFriends, equals(5));
    });

    test('returns null friends ranking when user has no friends', () async {
      // 1. Create user with no friends
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'solo@test.com',
        password: 'password123',
        displayName: 'Solo User',
      );

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'eloRating': 1600.0,
        'eloGamesPlayed': 5,
        'friendIds': [], // No friends
      });

      // 2. Create some other users for global ranking
      for (int i = 0; i < 3; i++) {
        final otherUser = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'other$i@test.com',
          password: 'password123',
          displayName: 'Other $i',
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(otherUser.uid)
            .update({
          'eloRating': 1500.0 + (i * 100),
          'eloGamesPlayed': 5,
        });
      }

      // 3. Sign in and get ranking
      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'solo@test.com',
        password: 'password123',
      );

      final repository = FirestoreUserRepository(
        firestore: FirebaseFirestore.instance,
        functions: FirebaseFunctions.instance,
      );

      final ranking = await repository.getUserRanking(user.uid);

      // 4. Verify no friends ranking
      expect(ranking.friendsRank, isNull);
      expect(ranking.totalFriends, isNull);

      // But global ranking should still work
      expect(ranking.globalRank, greaterThan(0));
      expect(ranking.totalUsers, equals(4));
    });

    test('excludes users with no games played from ranking', () async {
      // 1. Create users: some with games, some without
      final userWithGames1 = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'player1@test.com',
        password: 'password123',
        displayName: 'Player 1',
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userWithGames1.uid)
          .update({
        'eloRating': 1700.0,
        'eloGamesPlayed': 10, // Has played games
      });

      final userWithGames2 = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'player2@test.com',
        password: 'password123',
        displayName: 'Player 2',
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userWithGames2.uid)
          .update({
        'eloRating': 1600.0,
        'eloGamesPlayed': 5,
      });

      // Create user with no games (should be excluded)
      final userNoGames = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'newbie@test.com',
        password: 'password123',
        displayName: 'Newbie',
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userNoGames.uid)
          .update({
        'eloRating': 2000.0, // High ELO but no games
        'eloGamesPlayed': 0, // ZERO games
      });

      // 2. Sign in as player2
      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'player2@test.com',
        password: 'password123',
      );

      // 3. Get ranking
      final repository = FirestoreUserRepository(
        firestore: FirebaseFirestore.instance,
        functions: FirebaseFunctions.instance,
      );

      final ranking = await repository.getUserRanking(userWithGames2.uid);

      // 4. Verify only users with games are counted
      expect(ranking.totalUsers, equals(2)); // Only 2 users with games
      expect(ranking.globalRank, equals(2)); // Player1 has higher ELO
    });

    test('handles friends with no games played correctly', () async {
      // 1. Create main user
      final mainUser = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'main@test.com',
        password: 'password123',
        displayName: 'Main User',
      );

      await FirebaseFirestore.instance.collection('users').doc(mainUser.uid).update({
        'eloRating': 1700.0,
        'eloGamesPlayed': 10,
      });

      // 2. Create friends: some with games, some without
      final friend1 = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'friend1@test.com',
        password: 'password123',
        displayName: 'Friend 1',
      );
      await FirebaseFirestore.instance.collection('users').doc(friend1.uid).update({
        'eloRating': 1800.0,
        'eloGamesPlayed': 5, // Has games
      });

      final friend2 = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'friend2@test.com',
        password: 'password123',
        displayName: 'Friend 2',
      );
      await FirebaseFirestore.instance.collection('users').doc(friend2.uid).update({
        'eloRating': 2000.0,
        'eloGamesPlayed': 0, // NO games - should be excluded
      });

      final friend3 = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'friend3@test.com',
        password: 'password123',
        displayName: 'Friend 3',
      );
      await FirebaseFirestore.instance.collection('users').doc(friend3.uid).update({
        'eloRating': 1600.0,
        'eloGamesPlayed': 3, // Has games
      });

      // 3. Set friends list
      await FirebaseFirestore.instance.collection('users').doc(mainUser.uid).update({
        'friendIds': [friend1.uid, friend2.uid, friend3.uid],
      });

      // 4. Sign in and get ranking
      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'main@test.com',
        password: 'password123',
      );

      final repository = FirestoreUserRepository(
        firestore: FirebaseFirestore.instance,
        functions: FirebaseFunctions.instance,
      );

      final ranking = await repository.getUserRanking(mainUser.uid);

      // 5. Verify only friends with games are counted
      expect(ranking.totalFriends, equals(2)); // friend1 and friend3 only
      expect(ranking.friendsRank, equals(2)); // friend1 (1800) > main (1700) > friend3 (1600)
    });

    test('throws error when user is not authenticated', () async {
      // Ensure no user is signed in
      await FirebaseEmulatorHelper.signOut();

      final repository = FirestoreUserRepository(
        firestore: FirebaseFirestore.instance,
        functions: FirebaseFunctions.instance,
      );

      // Should throw unauthenticated error
      expect(
        () => repository.getUserRanking('some-user-id'),
        throwsException,
      );
    });

    test('handles single user correctly', () async {
      // 1. Create only one user
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'onlyone@test.com',
        password: 'password123',
        displayName: 'Only One',
      );

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'eloRating': 1600.0,
        'eloGamesPlayed': 1,
      });

      // 2. Sign in and get ranking
      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'onlyone@test.com',
        password: 'password123',
      );

      final repository = FirestoreUserRepository(
        firestore: FirebaseFirestore.instance,
        functions: FirebaseFunctions.instance,
      );

      final ranking = await repository.getUserRanking(user.uid);

      // 3. Verify ranking for single user
      expect(ranking.globalRank, equals(1));
      expect(ranking.totalUsers, equals(1));
      expect(ranking.percentile, equals(100.0));
    });

    test('percentile calculation is accurate across range', () async {
      // 1. Create 100 users for accurate percentile testing
      final users = <String>[];

      for (int i = 0; i < 100; i++) {
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'user$i@test.com',
          password: 'password123',
          displayName: 'User $i',
        );
        users.add(user.uid);

        final eloRating = 1000.0 + (i * 10); // 1000, 1010, 1020, ..., 1990
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'eloRating': eloRating,
          'eloGamesPlayed': 10,
        });
      }

      // 2. Sign in as user at 50th position (ELO 1490)
      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'user49@test.com',
        password: 'password123',
      );

      // 3. Get ranking
      final repository = FirestoreUserRepository(
        firestore: FirebaseFirestore.instance,
        functions: FirebaseFunctions.instance,
      );

      final ranking = await repository.getUserRanking(users[49]);

      // 4. Verify percentile
      expect(ranking.globalRank, equals(50)); // 49 users have higher ELO
      expect(ranking.totalUsers, equals(100));
      // Percentile: (100 - 50 + 1) / 100 = 51%
      expect(ranking.percentile, equals(51.0));
    });
  });
}
