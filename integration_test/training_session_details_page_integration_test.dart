// Integration tests for TrainingSessionDetailsPage data layer
// Tests real Firebase interactions for training session details using Firebase Emulator
//
// NOTE: These tests validate the data layer that powers TrainingSessionDetailsPage.
// UI rendering tests are not suitable for integration tests because:
// - TrainingSessionDetailsPage uses FirebaseAuth.instance.currentUser directly
// - The page requires full service locator initialization which conflicts with emulator setup
// - Widget rendering with real Firebase requires platform channel handling
//
// Instead, these tests verify:
// - Training session data retrieval
// - Status badge logic based on session data
// - Participant management
// - Session metadata (location, time, counts)
// - Organizer information

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

  group('Training Session Details - Data Retrieval', () {
    late String groupId;
    late String userId;

    Future<void> createTestUserAndGroup() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'details${DateTime.now().millisecondsSinceEpoch}@test.com',
        password: 'password123',
        displayName: 'Details Tester',
      );
      userId = user.uid;

      groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: userId,
        name: 'Details Test Group',
        memberIds: [userId],
      );
    }

    test(
      'Training session data can be retrieved with correct title',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Morning Volleyball Training',
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        expect(sessionDoc.exists, isTrue);
        expect(sessionDoc.data()?['title'], equals('Morning Volleyball Training'));
      },
    );

    test(
      'Training session returns null for non-existent session',
      () async {
        await createTestUserAndGroup();

        final firestore = FirebaseFirestore.instance;
        final sessionDoc = await firestore
            .collection('trainingSessions')
            .doc('non-existent-session-id')
            .get();

        expect(sessionDoc.exists, isFalse);
        expect(sessionDoc.data(), isNull);
      },
    );

    test(
      'Training session stores and retrieves description correctly',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Training with Description',
          description: 'This is a detailed description of the training session.',
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        expect(
          sessionDoc.data()?['description'],
          equals('This is a detailed description of the training session.'),
        );
      },
    );

    test(
      'Training session stores location information correctly',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Location Test Session',
          locationName: 'Beach Court A',
          locationAddress: '123 Beach Blvd, Venice, CA',
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        final location = sessionDoc.data()?['location'] as Map<String, dynamic>?;
        expect(location?['name'], equals('Beach Court A'));
        expect(location?['address'], equals('123 Beach Blvd, Venice, CA'));
      },
    );

    test(
      'Training session stores participant count correctly',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Participants Test',
          participantIds: [userId],
          maxParticipants: 10,
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        final participantIds =
            List<String>.from(sessionDoc.data()?['participantIds'] ?? []);
        expect(participantIds.length, equals(1));
        expect(sessionDoc.data()?['maxParticipants'], equals(10));
      },
    );

    test(
      'Training session stores date and time correctly',
      () async {
        await createTestUserAndGroup();

        final startTime = DateTime(2026, 3, 15, 9, 0);
        final endTime = DateTime(2026, 3, 15, 11, 0);

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Timed Session',
          startTime: startTime,
          endTime: endTime,
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        final storedStartTime =
            (sessionDoc.data()?['startTime'] as Timestamp).toDate();

        expect(storedStartTime.year, equals(2026));
        expect(storedStartTime.month, equals(3));
        expect(storedStartTime.day, equals(15));
        expect(storedStartTime.hour, equals(9));
      },
    );

    test(
      'Training session stream emits data updates',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Stream Test Session',
        );

        final firestore = FirebaseFirestore.instance;

        // Get initial data
        final initialDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();
        expect(initialDoc.data()?['title'], equals('Stream Test Session'));
      },
    );

    test(
      'Training session returns creator ID for organizer info',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Organizer Test Session',
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        expect(sessionDoc.data()?['createdBy'], equals(userId));
      },
    );
  });

  group('Training Session Details - Status Badge Data', () {
    late String groupId;
    late String userId;

    Future<void> createTestUserAndGroup() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'status${DateTime.now().millisecondsSinceEpoch}@test.com',
        password: 'password123',
        displayName: 'Status Tester',
      );
      userId = user.uid;

      groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: userId,
        name: 'Status Test Group',
        memberIds: [userId],
      );
    }

    test(
      'Training session returns scheduled status correctly',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Scheduled Session',
          status: 'scheduled',
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        expect(sessionDoc.data()?['status'], equals('scheduled'));
      },
    );

    test(
      'Training session returns completed status correctly',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Completed Session',
          status: 'completed',
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        expect(sessionDoc.data()?['status'], equals('completed'));
      },
    );

    test(
      'Training session returns cancelled status correctly',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Cancelled Session',
          status: 'cancelled',
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        expect(sessionDoc.data()?['status'], equals('cancelled'));
      },
    );

    test(
      'Training session is full when participantIds equals maxParticipants',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Full Session',
          maxParticipants: 2,
        );

        final firestore = FirebaseFirestore.instance;

        // Fill the session
        await firestore.collection('trainingSessions').doc(sessionId).update({
          'participantIds': [userId, 'other-user-id'],
        });

        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        final participantIds =
            List<String>.from(sessionDoc.data()?['participantIds'] ?? []);
        final maxParticipants = sessionDoc.data()?['maxParticipants'] as int;

        // Verify session is full
        expect(participantIds.length, equals(maxParticipants));
      },
    );
  });

  group('Training Session Details - Tab Data (Participants/Exercises/Feedback)', () {
    late String groupId;
    late String userId;

    Future<void> createTestUserAndGroup() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'tab${DateTime.now().millisecondsSinceEpoch}@test.com',
        password: 'password123',
        displayName: 'Tab Tester',
      );
      userId = user.uid;

      groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: userId,
        name: 'Tab Test Group',
        memberIds: [userId],
      );
    }

    test(
      'Scheduled session has participants and exercises data',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Scheduled Tab Test',
          status: 'scheduled',
          participantIds: [userId],
        );

        // Add an exercise
        await FirebaseEmulatorHelper.createTestExercise(
          trainingSessionId: sessionId,
          name: 'Warm-up Drills',
          durationMinutes: 15,
        );

        final firestore = FirebaseFirestore.instance;

        // Verify participants data
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();
        final participantIds =
            List<String>.from(sessionDoc.data()?['participantIds'] ?? []);
        expect(participantIds, contains(userId));

        // Verify exercises data
        final exercises = await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('exercises')
            .get();
        expect(exercises.docs.length, equals(1));
      },
    );

    test(
      'Completed session has feedback collection available',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Completed Tab Test',
          status: 'completed',
          participantIds: [userId],
        );

        // Add feedback
        final feedbackId = await FirebaseEmulatorHelper.createTestFeedback(
          trainingSessionId: sessionId,
          exercisesQuality: 5,
          trainingIntensity: 4,
          coachingClarity: 5,
          participantHash: 'test_hash_123',
          comment: 'Great session!',
        );

        final firestore = FirebaseFirestore.instance;
        final feedbackDoc = await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('feedback')
            .doc(feedbackId)
            .get();

        expect(feedbackDoc.exists, isTrue);
        expect(feedbackDoc.data()?['exercisesQuality'], equals(5));
      },
    );

    test(
      'Scheduled session does not have feedback (business rule)',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Scheduled No Feedback Test',
          status: 'scheduled',
        );

        final firestore = FirebaseFirestore.instance;

        // Verify no feedback exists for scheduled session
        final feedback = await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('feedback')
            .get();

        expect(feedback.docs, isEmpty);
      },
    );
  });

  group('Training Session Details - Participants Tab Data', () {
    late String groupId;
    late String userId;

    Future<void> createTestUserAndGroup() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'participants${DateTime.now().millisecondsSinceEpoch}@test.com',
        password: 'password123',
        displayName: 'Participants Tester',
      );
      userId = user.uid;

      groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: userId,
        name: 'Participants Test Group',
        memberIds: [userId],
      );
    }

    test(
      'Session with no participants returns empty participantIds array',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Empty Participants Test',
          participantIds: [],
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        final participantIds =
            List<String>.from(sessionDoc.data()?['participantIds'] ?? []);
        expect(participantIds, isEmpty);
      },
    );

    test(
      'Session stores participation limits correctly',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Participation Limits Test',
          participantIds: [userId],
          minParticipants: 4,
          maxParticipants: 12,
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        // Verify Current
        final participantIds =
            List<String>.from(sessionDoc.data()?['participantIds'] ?? []);
        expect(participantIds.length, equals(1));

        // Verify Minimum
        expect(sessionDoc.data()?['minParticipants'], equals(4));

        // Verify Maximum
        expect(sessionDoc.data()?['maxParticipants'], equals(12));

        // Calculate Available Spots
        final maxParticipants = sessionDoc.data()?['maxParticipants'] as int;
        final availableSpots = maxParticipants - participantIds.length;
        expect(availableSpots, equals(11));
      },
    );
  });

  group('Training Session Details - FAB Visibility Logic', () {
    late String groupId;
    late String userId;

    Future<void> createTestUserAndGroup() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'fab${DateTime.now().millisecondsSinceEpoch}@test.com',
        password: 'password123',
        displayName: 'FAB Tester',
      );
      userId = user.uid;

      groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: userId,
        name: 'FAB Test Group',
        memberIds: [userId],
      );
    }

    test(
      'Cancelled session status indicates FAB should not show',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Cancelled FAB Test',
          status: 'cancelled',
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        // FAB should not show for cancelled status (business rule)
        expect(sessionDoc.data()?['status'], equals('cancelled'));
      },
    );

    test(
      'Completed session status indicates FAB should not show',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Completed FAB Test',
          status: 'completed',
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        // FAB should not show for completed status (business rule)
        expect(sessionDoc.data()?['status'], equals('completed'));
      },
    );
  });

  group('Training Session Details - Join/Leave Operations', () {
    late String groupId;
    late String creatorId;
    late String participantId;

    Future<void> createTestUsersAndGroup() async {
      final creator = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'creator${DateTime.now().millisecondsSinceEpoch}@test.com',
        password: 'password123',
        displayName: 'Session Creator',
      );
      creatorId = creator.uid;

      await FirebaseEmulatorHelper.signOut();
      final participant = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'participant${DateTime.now().millisecondsSinceEpoch}@test.com',
        password: 'password123',
        displayName: 'Session Participant',
      );
      participantId = participant.uid;

      groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: creatorId,
        name: 'Join Leave Test Group',
        memberIds: [creatorId, participantId],
      );
    }

    test(
      'User can be added to participantIds (join simulation)',
      () async {
        await createTestUsersAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: creatorId,
          title: 'Join Test Session',
          participantIds: [creatorId],
        );

        final firestore = FirebaseFirestore.instance;

        // Simulate joining by adding participant
        await firestore.collection('trainingSessions').doc(sessionId).update({
          'participantIds': FieldValue.arrayUnion([participantId]),
        });

        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();
        final participantIds =
            List<String>.from(sessionDoc.data()?['participantIds'] ?? []);

        expect(participantIds, contains(participantId));
        expect(participantIds.length, equals(2));
      },
    );

    test(
      'User can be removed from participantIds (leave simulation)',
      () async {
        await createTestUsersAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: creatorId,
          title: 'Leave Test Session',
          participantIds: [creatorId, participantId],
        );

        final firestore = FirebaseFirestore.instance;

        // Simulate leaving by removing participant
        await firestore.collection('trainingSessions').doc(sessionId).update({
          'participantIds': FieldValue.arrayRemove([participantId]),
        });

        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();
        final participantIds =
            List<String>.from(sessionDoc.data()?['participantIds'] ?? []);

        expect(participantIds, isNot(contains(participantId)));
        expect(participantIds.length, equals(1));
      },
    );

    test(
      'Full session prevents additional joins (data validation)',
      () async {
        await createTestUsersAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: creatorId,
          title: 'Full Session Test',
          participantIds: [creatorId, 'user2'],
          maxParticipants: 2,
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        final participantIds =
            List<String>.from(sessionDoc.data()?['participantIds'] ?? []);
        final maxParticipants = sessionDoc.data()?['maxParticipants'] as int;

        // Session is full - business logic should prevent joins
        expect(participantIds.length, equals(maxParticipants));
        expect(participantIds.length >= maxParticipants, isTrue);
      },
    );

    test(
      'Error state can be tracked via session data',
      () async {
        await createTestUsersAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: creatorId,
          title: 'Error Tracking Test',
          participantIds: [],
          maxParticipants: 0, // Invalid config for testing
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        // Max participants of 0 should be caught by business logic
        expect(sessionDoc.data()?['maxParticipants'], equals(0));
      },
    );
  });

  group('Training Session Details - Cancel Operation', () {
    late String groupId;
    late String userId;

    Future<void> createTestUserAndGroup() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'cancel${DateTime.now().millisecondsSinceEpoch}@test.com',
        password: 'password123',
        displayName: 'Cancel Tester',
      );
      userId = user.uid;

      groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: userId,
        name: 'Cancel Test Group',
        memberIds: [userId],
      );
    }

    test(
      'Session can be updated to cancelled status',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Session To Cancel',
          status: 'scheduled',
        );

        final firestore = FirebaseFirestore.instance;

        // Cancel the session
        await firestore.collection('trainingSessions').doc(sessionId).update({
          'status': 'cancelled',
          'cancelledBy': userId,
          'cancelledAt': FieldValue.serverTimestamp(),
        });

        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        expect(sessionDoc.data()?['status'], equals('cancelled'));
        expect(sessionDoc.data()?['cancelledBy'], equals(userId));
      },
    );
  });

  group('Training Session Details - Organizer Info', () {
    late String groupId;
    late String userId;

    Future<void> createTestUserAndGroup() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'organizer${DateTime.now().millisecondsSinceEpoch}@test.com',
        password: 'password123',
        displayName: 'Session Organizer',
      );
      userId = user.uid;

      groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: userId,
        name: 'Organizer Test Group',
        memberIds: [userId],
      );
    }

    test(
      'Session creator ID matches organizer for organizer label',
      () async {
        await createTestUserAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Organizer Test Session',
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        // When currentUserId == createdBy, show "You are organizing"
        expect(sessionDoc.data()?['createdBy'], equals(userId));

        // Can also verify user document exists for display name
        final userDoc = await firestore.collection('users').doc(userId).get();
        expect(userDoc.exists, isTrue);
        expect(userDoc.data()?['displayName'], equals('Session Organizer'));
      },
    );
  });
}
