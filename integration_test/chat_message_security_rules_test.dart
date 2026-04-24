// Integration tests for games/{gameId}/messages security rules (Story 14.14).
// Verifies that only players listed in games/{gameId}.playerIds can read/write
// messages, and that non-players and unauthenticated users cannot.

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

  // ─────────────────────────────────────────────────────────────────────────
  // Helper: write a message document bypassing rules (called while signed in
  // as an admin/creator so they are a player and can create it).
  // ─────────────────────────────────────────────────────────────────────────
  Future<DocumentReference> seedMessage({
    required String gameId,
    required String senderId,
  }) async {
    final msgRef = FirebaseEmulatorHelper.firestore
        .collection('games')
        .doc(gameId)
        .collection('messages')
        .doc();
    await msgRef.set({
      'senderId': senderId,
      'senderDisplayName': 'Creator User',
      'text': 'Hello team!',
      'sentAt': FieldValue.serverTimestamp(),
    });
    await FirebaseEmulatorHelper.waitForFirestore();
    return msgRef;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // READ tests
  // ─────────────────────────────────────────────────────────────────────────

  group('Security Rules — messages read access', () {
    test('Player CAN read messages in a game they are in', () async {
      // 1. Create two users
      final creator = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'creator@test.com',
        password: 'password123',
        displayName: 'Creator User',
      );
      final player = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'player@test.com',
        password: 'password123',
        displayName: 'Player User',
      );

      // 2. Create group and game with both users as players
      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'creator@test.com',
        password: 'password123',
      );

      final groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: creator.uid,
        name: 'Test Group',
        memberIds: [creator.uid, player.uid],
        adminIds: [creator.uid],
      );

      final gameId = await FirebaseEmulatorHelper.createTestGame(
        groupId: groupId,
        createdBy: creator.uid,
        title: 'Test Game',
        playerIds: [creator.uid, player.uid],
      );

      // 3. Seed a message as creator (who is a player)
      final msgRef = await seedMessage(
        gameId: gameId,
        senderId: creator.uid,
      );

      // 4. Sign in as player and read the message — should succeed
      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'player@test.com',
        password: 'password123',
      );

      final doc = await msgRef.get();
      expect(doc.exists, isTrue);
      final data = doc.data() as Map<String, dynamic>;
      expect(data['text'], 'Hello team!');
      expect(data['senderId'], creator.uid);
    });

    test('Non-player authenticated user CANNOT read messages', () async {
      // 1. Create users: creator, player, outsider
      final creator = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'creator@test.com',
        password: 'password123',
        displayName: 'Creator User',
      );
      await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'outsider@test.com',
        password: 'password123',
        displayName: 'Outsider User',
      );

      // 2. Create group and game with only creator as player
      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'creator@test.com',
        password: 'password123',
      );

      final groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: creator.uid,
        name: 'Test Group',
      );

      final gameId = await FirebaseEmulatorHelper.createTestGame(
        groupId: groupId,
        createdBy: creator.uid,
        title: 'Test Game',
        playerIds: [creator.uid],
      );

      // 3. Seed a message
      final msgRef = await seedMessage(
        gameId: gameId,
        senderId: creator.uid,
      );

      // 4. Sign in as outsider and try to read — should fail
      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'outsider@test.com',
        password: 'password123',
      );

      await expectLater(
        () async => msgRef.get(),
        throwsA(
          isA<FirebaseException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          ),
        ),
      );
    });

    test('Unauthenticated user CANNOT read messages', () async {
      // 1. Create creator and game
      final creator = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'creator@test.com',
        password: 'password123',
        displayName: 'Creator User',
      );

      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'creator@test.com',
        password: 'password123',
      );

      final groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: creator.uid,
        name: 'Test Group',
      );

      final gameId = await FirebaseEmulatorHelper.createTestGame(
        groupId: groupId,
        createdBy: creator.uid,
        title: 'Test Game',
        playerIds: [creator.uid],
      );

      final msgRef = await seedMessage(
        gameId: gameId,
        senderId: creator.uid,
      );

      // 2. Sign out and attempt read — should fail
      await FirebaseEmulatorHelper.signOut();

      await expectLater(
        () async => msgRef.get(),
        throwsA(
          isA<FirebaseException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          ),
        ),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // WRITE (create) tests
  // ─────────────────────────────────────────────────────────────────────────

  group('Security Rules — messages write access', () {
    test('Player CAN create a message in a game they are in', () async {
      // 1. Create creator/player
      final player = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'player@test.com',
        password: 'password123',
        displayName: 'Player User',
      );

      // 2. Create group and game
      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'player@test.com',
        password: 'password123',
      );

      final groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: player.uid,
        name: 'Test Group',
      );

      final gameId = await FirebaseEmulatorHelper.createTestGame(
        groupId: groupId,
        createdBy: player.uid,
        title: 'Test Game',
        playerIds: [player.uid],
      );

      // 3. Create a message as the player
      final msgRef = FirebaseEmulatorHelper.firestore
          .collection('games')
          .doc(gameId)
          .collection('messages')
          .doc();

      await msgRef.set({
        'senderId': player.uid,
        'senderDisplayName': 'Player User',
        'text': 'Ready to play!',
        'sentAt': FieldValue.serverTimestamp(),
      });

      await FirebaseEmulatorHelper.waitForFirestore();

      // 4. Verify the message was created
      final doc = await msgRef.get();
      expect(doc.exists, isTrue);
      final data = doc.data() as Map<String, dynamic>;
      expect(data['text'], 'Ready to play!');
    });

    test('Player CANNOT create a message with a different senderId', () async {
      // 1. Create two users
      final player = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'player@test.com',
        password: 'password123',
        displayName: 'Player User',
      );
      final otherPlayer = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'other@test.com',
        password: 'password123',
        displayName: 'Other Player',
      );

      // 2. Create game with both as players
      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'player@test.com',
        password: 'password123',
      );

      final groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: player.uid,
        name: 'Test Group',
        memberIds: [player.uid, otherPlayer.uid],
        adminIds: [player.uid],
      );

      final gameId = await FirebaseEmulatorHelper.createTestGame(
        groupId: groupId,
        createdBy: player.uid,
        title: 'Test Game',
        playerIds: [player.uid, otherPlayer.uid],
      );

      // 3. Try to create a message with a spoofed senderId — should fail
      final msgRef = FirebaseEmulatorHelper.firestore
          .collection('games')
          .doc(gameId)
          .collection('messages')
          .doc();

      await expectLater(
        () async => msgRef.set({
          'senderId': otherPlayer.uid, // spoofed sender
          'senderDisplayName': 'Other Player',
          'text': 'Spoofed message',
          'sentAt': FieldValue.serverTimestamp(),
        }),
        throwsA(
          isA<FirebaseException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          ),
        ),
      );
    });

    test('Non-player CANNOT create messages in a game', () async {
      // 1. Create creator and outsider
      final creator = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'creator@test.com',
        password: 'password123',
        displayName: 'Creator User',
      );
      final outsider = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'outsider@test.com',
        password: 'password123',
        displayName: 'Outsider User',
      );

      // 2. Create game with only creator as player
      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'creator@test.com',
        password: 'password123',
      );

      final groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: creator.uid,
        name: 'Test Group',
      );

      final gameId = await FirebaseEmulatorHelper.createTestGame(
        groupId: groupId,
        createdBy: creator.uid,
        title: 'Test Game',
        playerIds: [creator.uid],
      );

      // 3. Sign in as outsider and try to write — should fail
      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'outsider@test.com',
        password: 'password123',
      );

      final msgRef = FirebaseEmulatorHelper.firestore
          .collection('games')
          .doc(gameId)
          .collection('messages')
          .doc();

      await expectLater(
        () async => msgRef.set({
          'senderId': outsider.uid,
          'senderDisplayName': 'Outsider User',
          'text': 'I should not be here',
          'sentAt': FieldValue.serverTimestamp(),
        }),
        throwsA(
          isA<FirebaseException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          ),
        ),
      );
    });

    test('Unauthenticated user CANNOT create messages', () async {
      // 1. Create creator and game
      final creator = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'creator@test.com',
        password: 'password123',
        displayName: 'Creator User',
      );

      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'creator@test.com',
        password: 'password123',
      );

      final groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: creator.uid,
        name: 'Test Group',
      );

      final gameId = await FirebaseEmulatorHelper.createTestGame(
        groupId: groupId,
        createdBy: creator.uid,
        title: 'Test Game',
        playerIds: [creator.uid],
      );

      // 2. Sign out and attempt write — should fail
      await FirebaseEmulatorHelper.signOut();

      final msgRef = FirebaseEmulatorHelper.firestore
          .collection('games')
          .doc(gameId)
          .collection('messages')
          .doc();

      await expectLater(
        () async => msgRef.set({
          'senderId': creator.uid,
          'senderDisplayName': 'Creator User',
          'text': 'Unauthenticated message',
          'sentAt': FieldValue.serverTimestamp(),
        }),
        throwsA(
          isA<FirebaseException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          ),
        ),
      );
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE / DELETE tests — always forbidden for users
  // ─────────────────────────────────────────────────────────────────────────

  group('Security Rules — messages update and delete forbidden', () {
    test('Player CANNOT update a message', () async {
      // 1. Setup
      final player = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'player@test.com',
        password: 'password123',
        displayName: 'Player User',
      );

      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'player@test.com',
        password: 'password123',
      );

      final groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: player.uid,
        name: 'Test Group',
      );

      final gameId = await FirebaseEmulatorHelper.createTestGame(
        groupId: groupId,
        createdBy: player.uid,
        title: 'Test Game',
        playerIds: [player.uid],
      );

      final msgRef = await seedMessage(
        gameId: gameId,
        senderId: player.uid,
      );

      // 2. Try to update the message — should fail
      await expectLater(
        () async => msgRef.update({'text': 'Edited message'}),
        throwsA(
          isA<FirebaseException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          ),
        ),
      );
    });

    test('Player CANNOT delete a message', () async {
      // 1. Setup
      final player = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'player@test.com',
        password: 'password123',
        displayName: 'Player User',
      );

      await FirebaseEmulatorHelper.signOut();
      await FirebaseEmulatorHelper.signIn(
        email: 'player@test.com',
        password: 'password123',
      );

      final groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: player.uid,
        name: 'Test Group',
      );

      final gameId = await FirebaseEmulatorHelper.createTestGame(
        groupId: groupId,
        createdBy: player.uid,
        title: 'Test Game',
        playerIds: [player.uid],
      );

      final msgRef = await seedMessage(
        gameId: gameId,
        senderId: player.uid,
      );

      // 2. Try to delete the message — should fail
      await expectLater(
        () async => msgRef.delete(),
        throwsA(
          isA<FirebaseException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          ),
        ),
      );
    });
  });
}
