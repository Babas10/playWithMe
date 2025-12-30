// Integration test for rating history time period filtering (Story 302.1)
// Tests getRatingHistoryByPeriod and getBestEloInPeriod with real Firestore using Firebase Emulator

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:play_with_me/core/data/repositories/firestore_user_repository.dart';
import 'package:play_with_me/core/domain/entities/time_period.dart';

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

  group('Rating History Time Period Filtering', () {
    test('getRatingHistoryByPeriod returns entries within time period', () async {
      // 1. Create test user
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'player@test.com',
        password: 'password123',
        displayName: 'Test Player',
      );

      // 2. Create rating history entries at different times
      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();

      // Entry from 10 days ago (within 15-day period)
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratingHistory')
          .add({
        'gameId': 'game-1',
        'oldRating': 1500.0,
        'newRating': 1520.0,
        'ratingChange': 20.0,
        'opponentTeam': 'Player A & Player B',
        'won': true,
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 10))),
      });

      // Entry from 20 days ago (outside 15-day period, within 30-day)
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratingHistory')
          .add({
        'gameId': 'game-2',
        'oldRating': 1480.0,
        'newRating': 1500.0,
        'ratingChange': 20.0,
        'opponentTeam': 'Player C & Player D',
        'won': true,
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 20))),
      });

      // Entry from 60 days ago (outside 30-day period, within 90-day)
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratingHistory')
          .add({
        'gameId': 'game-3',
        'oldRating': 1460.0,
        'newRating': 1480.0,
        'ratingChange': 20.0,
        'opponentTeam': 'Player E & Player F',
        'won': true,
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 60))),
      });

      // Entry from 200 days ago (outside 90-day period, within 1 year)
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratingHistory')
          .add({
        'gameId': 'game-4',
        'oldRating': 1440.0,
        'newRating': 1460.0,
        'ratingChange': 20.0,
        'opponentTeam': 'Player G & Player H',
        'won': true,
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 200))),
      });

      // 3. Create repository
      final repository = FirestoreUserRepository(firestore: firestore);

      // 4. Test 15-day period - should get 1 entry
      final fifteenDayHistory = await repository
          .getRatingHistoryByPeriod(user.uid, TimePeriod.fifteenDays)
          .first;
      expect(fifteenDayHistory.length, equals(1));
      expect(fifteenDayHistory[0].gameId, equals('game-1'));

      // 5. Test 30-day period - should get 2 entries
      final thirtyDayHistory = await repository
          .getRatingHistoryByPeriod(user.uid, TimePeriod.thirtyDays)
          .first;
      expect(thirtyDayHistory.length, equals(2));
      expect(
        thirtyDayHistory.map((e) => e.gameId).toSet(),
        containsAll(['game-1', 'game-2']),
      );

      // 6. Test 90-day period - should get 3 entries
      final ninetyDayHistory = await repository
          .getRatingHistoryByPeriod(user.uid, TimePeriod.ninetyDays)
          .first;
      expect(ninetyDayHistory.length, equals(3));
      expect(
        ninetyDayHistory.map((e) => e.gameId).toSet(),
        containsAll(['game-1', 'game-2', 'game-3']),
      );

      // 7. Test 1 year period - should get all 4 entries
      final oneYearHistory = await repository
          .getRatingHistoryByPeriod(user.uid, TimePeriod.oneYear)
          .first;
      expect(oneYearHistory.length, equals(4));

      // 8. Test all-time period - should get all 4 entries
      final allTimeHistory = await repository
          .getRatingHistoryByPeriod(user.uid, TimePeriod.allTime)
          .first;
      expect(allTimeHistory.length, equals(4));
    });

    test('getRatingHistoryByPeriod returns empty list when no entries in period',
        () async {
      // 1. Create test user
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'player@test.com',
        password: 'password123',
        displayName: 'Test Player',
      );

      // 2. Create only one entry from 100 days ago
      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratingHistory')
          .add({
        'gameId': 'game-old',
        'oldRating': 1500.0,
        'newRating': 1520.0,
        'ratingChange': 20.0,
        'opponentTeam': 'Player A & Player B',
        'won': true,
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 100))),
      });

      // 3. Create repository
      final repository = FirestoreUserRepository(firestore: firestore);

      // 4. Test 15-day period - should be empty
      final history = await repository
          .getRatingHistoryByPeriod(user.uid, TimePeriod.fifteenDays)
          .first;
      expect(history, isEmpty);
    });

    test('getBestEloInPeriod returns highest rating in period', () async {
      // 1. Create test user
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'player@test.com',
        password: 'password123',
        displayName: 'Test Player',
      );

      // 2. Create rating history entries with different ratings
      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();

      // Highest rating (1600) from 5 days ago
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratingHistory')
          .add({
        'gameId': 'game-best',
        'oldRating': 1580.0,
        'newRating': 1600.0,
        'ratingChange': 20.0,
        'opponentTeam': 'Player A & Player B',
        'won': true,
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
      });

      // Lower rating (1550) from 3 days ago
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratingHistory')
          .add({
        'gameId': 'game-lower',
        'oldRating': 1570.0,
        'newRating': 1550.0,
        'ratingChange': -20.0,
        'opponentTeam': 'Player C & Player D',
        'won': false,
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
      });

      // Even higher rating (1650) from 40 days ago (outside 30-day period)
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratingHistory')
          .add({
        'gameId': 'game-outside-period',
        'oldRating': 1630.0,
        'newRating': 1650.0,
        'ratingChange': 20.0,
        'opponentTeam': 'Player E & Player F',
        'won': true,
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 40))),
      });

      // 3. Create repository
      final repository = FirestoreUserRepository(firestore: firestore);

      // 4. Test 30-day period - should get best ELO within 30 days (1600)
      final bestElo = await repository.getBestEloInPeriod(
        user.uid,
        TimePeriod.thirtyDays,
      );

      expect(bestElo, isNotNull);
      expect(bestElo!.elo, equals(1600.0));
      expect(bestElo.gameId, equals('game-best'));

      // Verify the date is within the last 30 days
      final daysSinceBest = now.difference(bestElo.date).inDays;
      expect(daysSinceBest, lessThan(30));
    });

    test('getBestEloInPeriod returns null when no entries in period', () async {
      // 1. Create test user
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'player@test.com',
        password: 'password123',
        displayName: 'Test Player',
      );

      // 2. Create only one entry from 100 days ago
      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratingHistory')
          .add({
        'gameId': 'game-old',
        'oldRating': 1500.0,
        'newRating': 1520.0,
        'ratingChange': 20.0,
        'opponentTeam': 'Player A & Player B',
        'won': true,
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 100))),
      });

      // 3. Create repository
      final repository = FirestoreUserRepository(firestore: firestore);

      // 4. Test 15-day period - should return null
      final bestElo = await repository.getBestEloInPeriod(
        user.uid,
        TimePeriod.fifteenDays,
      );
      expect(bestElo, isNull);
    });

    test('getBestEloInPeriod handles user with no rating history', () async {
      // 1. Create test user without any rating history
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'newplayer@test.com',
        password: 'password123',
        displayName: 'New Player',
      );

      // 2. Create repository
      final firestore = FirebaseFirestore.instance;
      final repository = FirestoreUserRepository(firestore: firestore);

      // 3. Test - should return null
      final bestElo = await repository.getBestEloInPeriod(
        user.uid,
        TimePeriod.allTime,
      );
      expect(bestElo, isNull);
    });

    test('getRatingHistoryByPeriod returns entries ordered by timestamp descending',
        () async {
      // 1. Create test user
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'player@test.com',
        password: 'password123',
        displayName: 'Test Player',
      );

      // 2. Create rating history entries
      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now();

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratingHistory')
          .add({
        'gameId': 'game-oldest',
        'oldRating': 1500.0,
        'newRating': 1510.0,
        'ratingChange': 10.0,
        'opponentTeam': 'Team 1',
        'won': true,
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 10))),
      });

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratingHistory')
          .add({
        'gameId': 'game-newest',
        'oldRating': 1510.0,
        'newRating': 1520.0,
        'ratingChange': 10.0,
        'opponentTeam': 'Team 2',
        'won': true,
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
      });

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('ratingHistory')
          .add({
        'gameId': 'game-middle',
        'oldRating': 1500.0,
        'newRating': 1510.0,
        'ratingChange': 10.0,
        'opponentTeam': 'Team 3',
        'won': true,
        'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 5))),
      });

      // 3. Create repository
      final repository = FirestoreUserRepository(firestore: firestore);

      // 4. Get history for 15-day period
      final history = await repository
          .getRatingHistoryByPeriod(user.uid, TimePeriod.fifteenDays)
          .first;

      // 5. Verify ordering (newest first)
      expect(history.length, equals(3));
      expect(history[0].gameId, equals('game-newest'));
      expect(history[1].gameId, equals('game-middle'));
      expect(history[2].gameId, equals('game-oldest'));
    });
  });
}
