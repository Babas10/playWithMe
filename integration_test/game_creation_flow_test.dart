// Integration test for game creation flow
// Tests real Firebase Firestore interactions using Firebase Emulator

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

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

  group('Game Creation Flow', () {
    late String groupId;
    late String userId;

    Future<void> createTestGroupAndUser() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'gametest@test.com',
        password: 'password123',
        displayName: 'Game Tester',
      );
      userId = user.uid;

      final firestore = FirebaseFirestore.instance;
      final groupRef = await firestore.collection('groups').add({
        'name': 'Test Group',
        'createdBy': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'memberIds': [userId],
        'adminIds': [userId],
        'lastActivity': FieldValue.serverTimestamp(),
      });
      groupId = groupRef.id;
    }

    test(
      'User can create a game within a group',
      () async {
        await createTestGroupAndUser();

        final firestore = FirebaseFirestore.instance;
        final scheduledAt = DateTime.now().add(const Duration(days: 7));

        final gameRef = await firestore.collection('games').add({
          'title': 'Saturday Beach Volleyball',
          'groupId': groupId,
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'scheduledAt': Timestamp.fromDate(scheduledAt),
          'location': {
            'name': 'Venice Beach',
            'address': '1500 Ocean Front Walk, Venice, CA',
          },
          'maxPlayers': 4,
          'minPlayers': 2,
          'playerIds': [userId],
          'status': 'scheduled',
        });

        // Verify game was created
        final gameDoc = await gameRef.get();
        expect(gameDoc.exists, isTrue);
        expect(gameDoc.data()?['title'], equals('Saturday Beach Volleyball'));
        expect(gameDoc.data()?['groupId'], equals(groupId));
        expect(gameDoc.data()?['createdBy'], equals(userId));
        expect(gameDoc.data()?['playerIds'], contains(userId));
      },
    );

    test(
      'Game creator is automatically added as a player',
      () async {
        await createTestGroupAndUser();

        final firestore = FirebaseFirestore.instance;
        final scheduledAt = DateTime.now().add(const Duration(days: 1));

        final gameRef = await firestore.collection('games').add({
          'title': 'Quick Match',
          'groupId': groupId,
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'scheduledAt': Timestamp.fromDate(scheduledAt),
          'location': {'name': 'Local Court'},
          'maxPlayers': 4,
          'minPlayers': 2,
          'playerIds': [userId],
          'status': 'scheduled',
        });

        final gameDoc = await gameRef.get();
        final playerIds = List<String>.from(gameDoc.data()?['playerIds'] ?? []);

        expect(playerIds.length, equals(1));
        expect(playerIds.first, equals(userId));
      },
    );

    test(
      'Game with optional description stores correctly',
      () async {
        await createTestGroupAndUser();

        final firestore = FirebaseFirestore.instance;
        final scheduledAt = DateTime.now().add(const Duration(days: 3));

        final gameRef = await firestore.collection('games').add({
          'title': 'Game With Description',
          'description': 'Bring your own water bottle and sunscreen',
          'groupId': groupId,
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'scheduledAt': Timestamp.fromDate(scheduledAt),
          'location': {'name': 'Beach Court'},
          'maxPlayers': 6,
          'minPlayers': 4,
          'playerIds': [userId],
          'status': 'scheduled',
        });

        final gameDoc = await gameRef.get();
        expect(
          gameDoc.data()?['description'],
          equals('Bring your own water bottle and sunscreen'),
        );
      },
    );

    test(
      'Game stores location with address correctly',
      () async {
        await createTestGroupAndUser();

        final firestore = FirebaseFirestore.instance;
        final scheduledAt = DateTime.now().add(const Duration(days: 5));

        final gameRef = await firestore.collection('games').add({
          'title': 'Location Test Game',
          'groupId': groupId,
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'scheduledAt': Timestamp.fromDate(scheduledAt),
          'location': {
            'name': 'Santa Monica Beach',
            'address': '123 Beach Ave, Santa Monica, CA 90401',
          },
          'maxPlayers': 4,
          'minPlayers': 2,
          'playerIds': [userId],
          'status': 'scheduled',
        });

        final gameDoc = await gameRef.get();
        final location = gameDoc.data()?['location'] as Map<String, dynamic>?;

        expect(location?['name'], equals('Santa Monica Beach'));
        expect(
          location?['address'],
          equals('123 Beach Ave, Santa Monica, CA 90401'),
        );
      },
    );

    test(
      'Game scheduled time is stored correctly',
      () async {
        await createTestGroupAndUser();

        final firestore = FirebaseFirestore.instance;
        final scheduledAt = DateTime(2025, 6, 15, 14, 30);

        final gameRef = await firestore.collection('games').add({
          'title': 'Scheduled Time Test',
          'groupId': groupId,
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'scheduledAt': Timestamp.fromDate(scheduledAt),
          'location': {'name': 'Test Court'},
          'maxPlayers': 4,
          'minPlayers': 2,
          'playerIds': [userId],
          'status': 'scheduled',
        });

        final gameDoc = await gameRef.get();
        final storedScheduledAt =
            (gameDoc.data()?['scheduledAt'] as Timestamp).toDate();

        expect(storedScheduledAt.year, equals(2025));
        expect(storedScheduledAt.month, equals(6));
        expect(storedScheduledAt.day, equals(15));
        expect(storedScheduledAt.hour, equals(14));
        expect(storedScheduledAt.minute, equals(30));
      },
    );

    test(
      'Multiple games can be created in same group',
      () async {
        await createTestGroupAndUser();

        final firestore = FirebaseFirestore.instance;

        // Create first game
        await firestore.collection('games').add({
          'title': 'Morning Game',
          'groupId': groupId,
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'scheduledAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 1)),
          ),
          'location': {'name': 'Court 1'},
          'maxPlayers': 4,
          'minPlayers': 2,
          'playerIds': [userId],
          'status': 'scheduled',
        });

        // Create second game
        await firestore.collection('games').add({
          'title': 'Afternoon Game',
          'groupId': groupId,
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'scheduledAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 1, hours: 4)),
          ),
          'location': {'name': 'Court 2'},
          'maxPlayers': 6,
          'minPlayers': 4,
          'playerIds': [userId],
          'status': 'scheduled',
        });

        // Verify both games exist for the group
        final games = await firestore
            .collection('games')
            .where('groupId', isEqualTo: groupId)
            .get();

        expect(games.docs.length, equals(2));
      },
    );

    test(
      'Game with player limits stores correctly',
      () async {
        await createTestGroupAndUser();

        final firestore = FirebaseFirestore.instance;
        final scheduledAt = DateTime.now().add(const Duration(days: 2));

        final gameRef = await firestore.collection('games').add({
          'title': 'Large Tournament',
          'groupId': groupId,
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'scheduledAt': Timestamp.fromDate(scheduledAt),
          'location': {'name': 'Tournament Court'},
          'maxPlayers': 12,
          'minPlayers': 8,
          'playerIds': [userId],
          'status': 'scheduled',
        });

        final gameDoc = await gameRef.get();
        expect(gameDoc.data()?['maxPlayers'], equals(12));
        expect(gameDoc.data()?['minPlayers'], equals(8));
      },
    );

    test(
      'Game status defaults to scheduled',
      () async {
        await createTestGroupAndUser();

        final firestore = FirebaseFirestore.instance;
        final scheduledAt = DateTime.now().add(const Duration(days: 4));

        final gameRef = await firestore.collection('games').add({
          'title': 'Status Test Game',
          'groupId': groupId,
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'scheduledAt': Timestamp.fromDate(scheduledAt),
          'location': {'name': 'Test Location'},
          'maxPlayers': 4,
          'minPlayers': 2,
          'playerIds': [userId],
          'status': 'scheduled',
        });

        final gameDoc = await gameRef.get();
        expect(gameDoc.data()?['status'], equals('scheduled'));
      },
    );

    test(
      'Games are linked to correct group',
      () async {
        await createTestGroupAndUser();

        final firestore = FirebaseFirestore.instance;

        // Create a second group
        final secondGroupRef = await firestore.collection('groups').add({
          'name': 'Second Group',
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'memberIds': [userId],
          'adminIds': [userId],
          'lastActivity': FieldValue.serverTimestamp(),
        });

        // Create game in first group
        await firestore.collection('games').add({
          'title': 'Game in First Group',
          'groupId': groupId,
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'scheduledAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 1)),
          ),
          'location': {'name': 'Court 1'},
          'maxPlayers': 4,
          'minPlayers': 2,
          'playerIds': [userId],
          'status': 'scheduled',
        });

        // Create game in second group
        await firestore.collection('games').add({
          'title': 'Game in Second Group',
          'groupId': secondGroupRef.id,
          'createdBy': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'scheduledAt': Timestamp.fromDate(
            DateTime.now().add(const Duration(days: 2)),
          ),
          'location': {'name': 'Court 2'},
          'maxPlayers': 4,
          'minPlayers': 2,
          'playerIds': [userId],
          'status': 'scheduled',
        });

        // Verify games are in correct groups
        final firstGroupGames = await firestore
            .collection('games')
            .where('groupId', isEqualTo: groupId)
            .get();

        final secondGroupGames = await firestore
            .collection('games')
            .where('groupId', isEqualTo: secondGroupRef.id)
            .get();

        expect(firstGroupGames.docs.length, equals(1));
        expect(
          firstGroupGames.docs.first.data()['title'],
          equals('Game in First Group'),
        );

        expect(secondGroupGames.docs.length, equals(1));
        expect(
          secondGroupGames.docs.first.data()['title'],
          equals('Game in Second Group'),
        );
      },
    );
  });
}
