// Integration test for training session flow
// Tests real Firebase Firestore interactions for training sessions using Firebase Emulator

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

  group('Training Session Creation', () {
    late String groupId;
    late String userId;

    Future<void> createTestGroupAndUser() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'trainingtest@test.com',
        password: 'password123',
        displayName: 'Training Tester',
      );
      userId = user.uid;

      groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: userId,
        name: 'Training Group',
        memberIds: [userId],
      );
    }

    test(
      'User can create a training session within a group',
      () async {
        await createTestGroupAndUser();

        final firestore = FirebaseFirestore.instance;
        final startTime = DateTime.now().add(const Duration(days: 1));
        final endTime = startTime.add(const Duration(hours: 2));

        final sessionRef = await firestore.collection('trainingSessions').add({
          'groupId': groupId,
          'createdBy': userId,
          'title': 'Morning Training',
          'description': 'Practice drills and warm-up',
          'startTime': Timestamp.fromDate(startTime),
          'endTime': Timestamp.fromDate(endTime),
          'location': {
            'name': 'Beach Court 1',
            'address': '123 Beach Blvd',
          },
          'minParticipants': 4,
          'maxParticipants': 12,
          'participantIds': [userId],
          'status': 'scheduled',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Verify session was created
        final sessionDoc = await sessionRef.get();
        expect(sessionDoc.exists, isTrue);
        expect(sessionDoc.data()?['title'], equals('Morning Training'));
        expect(sessionDoc.data()?['groupId'], equals(groupId));
        expect(sessionDoc.data()?['createdBy'], equals(userId));
        expect(sessionDoc.data()?['status'], equals('scheduled'));
      },
    );

    test(
      'Training session stores location correctly',
      () async {
        await createTestGroupAndUser();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Location Test Session',
          locationName: 'Venice Beach Court',
          locationAddress: '456 Ocean Ave, Venice, CA',
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        final location = sessionDoc.data()?['location'] as Map<String, dynamic>?;
        expect(location?['name'], equals('Venice Beach Court'));
        expect(location?['address'], equals('456 Ocean Ave, Venice, CA'));
      },
    );

    test(
      'Training session stores participant limits correctly',
      () async {
        await createTestGroupAndUser();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Limited Session',
          minParticipants: 6,
          maxParticipants: 20,
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        expect(sessionDoc.data()?['minParticipants'], equals(6));
        expect(sessionDoc.data()?['maxParticipants'], equals(20));
      },
    );

    test(
      'Training session time is stored correctly',
      () async {
        await createTestGroupAndUser();

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
        final storedEndTime =
            (sessionDoc.data()?['endTime'] as Timestamp).toDate();

        expect(storedStartTime.year, equals(2026));
        expect(storedStartTime.month, equals(3));
        expect(storedStartTime.day, equals(15));
        expect(storedStartTime.hour, equals(9));

        expect(storedEndTime.hour, equals(11));
      },
    );

    test(
      'Multiple training sessions can be created in same group',
      () async {
        await createTestGroupAndUser();

        // Create first session
        await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Morning Training',
        );

        // Create second session
        await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Evening Training',
        );

        final firestore = FirebaseFirestore.instance;
        final sessions = await firestore
            .collection('trainingSessions')
            .where('groupId', isEqualTo: groupId)
            .get();

        expect(sessions.docs.length, equals(2));
      },
    );
  });

  group('Training Session Participation', () {
    late String groupId;
    late String creatorId;
    late String participantId;

    Future<void> createTestUsersAndGroup() async {
      // Create session creator
      final creator = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'creator@test.com',
        password: 'password123',
        displayName: 'Session Creator',
      );
      creatorId = creator.uid;

      // Sign out and create participant
      await FirebaseEmulatorHelper.signOut();
      final participant = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'participant@test.com',
        password: 'password123',
        displayName: 'Session Participant',
      );
      participantId = participant.uid;

      // Create group with both members
      groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: creatorId,
        name: 'Participation Test Group',
        memberIds: [creatorId, participantId],
      );
    }

    test(
      'User can join a training session',
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

        // Also create participant subcollection entry
        await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('participants')
            .doc(participantId)
            .set({
          'userId': participantId,
          'joinedAt': FieldValue.serverTimestamp(),
          'status': 'joined',
        });

        // Verify participant was added
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();
        final participantIds =
            List<String>.from(sessionDoc.data()?['participantIds'] ?? []);

        expect(participantIds, contains(participantId));
        expect(participantIds.length, equals(2));

        // Verify participant subcollection
        final participantDoc = await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('participants')
            .doc(participantId)
            .get();

        expect(participantDoc.exists, isTrue);
        expect(participantDoc.data()?['status'], equals('joined'));
      },
    );

    test(
      'User can leave a training session',
      () async {
        await createTestUsersAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: creatorId,
          title: 'Leave Test Session',
          participantIds: [creatorId, participantId],
        );

        final firestore = FirebaseFirestore.instance;

        // Create participant entry first
        await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('participants')
            .doc(participantId)
            .set({
          'userId': participantId,
          'joinedAt': FieldValue.serverTimestamp(),
          'status': 'joined',
        });

        // Simulate leaving by removing participant
        await firestore.collection('trainingSessions').doc(sessionId).update({
          'participantIds': FieldValue.arrayRemove([participantId]),
        });

        // Update participant status
        await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('participants')
            .doc(participantId)
            .update({
          'status': 'left',
          'leftAt': FieldValue.serverTimestamp(),
        });

        // Verify participant was removed from main array
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();
        final participantIds =
            List<String>.from(sessionDoc.data()?['participantIds'] ?? []);

        expect(participantIds, isNot(contains(participantId)));
        expect(participantIds.length, equals(1));

        // Verify participant status updated
        final participantDoc = await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('participants')
            .doc(participantId)
            .get();

        expect(participantDoc.data()?['status'], equals('left'));
      },
    );

    test(
      'Creator remains in participant list after creation',
      () async {
        await createTestUsersAndGroup();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: creatorId,
          title: 'Creator Participation Test',
          participantIds: [creatorId],
        );

        final firestore = FirebaseFirestore.instance;
        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        final participantIds =
            List<String>.from(sessionDoc.data()?['participantIds'] ?? []);

        expect(participantIds, contains(creatorId));
      },
    );
  });

  group('Exercise Management', () {
    late String groupId;
    late String userId;
    late String sessionId;

    Future<void> createTestSessionWithGroup() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'exercisetest@test.com',
        password: 'password123',
        displayName: 'Exercise Tester',
      );
      userId = user.uid;

      groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: userId,
        name: 'Exercise Test Group',
      );

      sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
        groupId: groupId,
        createdBy: userId,
        title: 'Exercise Test Session',
      );
    }

    test(
      'User can add exercise to training session',
      () async {
        await createTestSessionWithGroup();

        final exerciseId = await FirebaseEmulatorHelper.createTestExercise(
          trainingSessionId: sessionId,
          name: 'Passing Drills',
          description: 'Practice basic passing techniques',
          durationMinutes: 15,
        );

        final firestore = FirebaseFirestore.instance;
        final exerciseDoc = await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('exercises')
            .doc(exerciseId)
            .get();

        expect(exerciseDoc.exists, isTrue);
        expect(exerciseDoc.data()?['name'], equals('Passing Drills'));
        expect(exerciseDoc.data()?['description'],
            equals('Practice basic passing techniques'));
        expect(exerciseDoc.data()?['durationMinutes'], equals(15));
      },
    );

    test(
      'Multiple exercises can be added to session',
      () async {
        await createTestSessionWithGroup();

        // Add multiple exercises
        await FirebaseEmulatorHelper.createTestExercise(
          trainingSessionId: sessionId,
          name: 'Warm-up',
          durationMinutes: 10,
        );

        await FirebaseEmulatorHelper.createTestExercise(
          trainingSessionId: sessionId,
          name: 'Serving Practice',
          durationMinutes: 20,
        );

        await FirebaseEmulatorHelper.createTestExercise(
          trainingSessionId: sessionId,
          name: 'Scrimmage',
          durationMinutes: 30,
        );

        final firestore = FirebaseFirestore.instance;
        final exercises = await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('exercises')
            .get();

        expect(exercises.docs.length, equals(3));
      },
    );

    test(
      'Exercise can be updated',
      () async {
        await createTestSessionWithGroup();

        final exerciseId = await FirebaseEmulatorHelper.createTestExercise(
          trainingSessionId: sessionId,
          name: 'Original Name',
          durationMinutes: 10,
        );

        final firestore = FirebaseFirestore.instance;

        // Update exercise
        await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('exercises')
            .doc(exerciseId)
            .update({
          'name': 'Updated Name',
          'durationMinutes': 20,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final exerciseDoc = await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('exercises')
            .doc(exerciseId)
            .get();

        expect(exerciseDoc.data()?['name'], equals('Updated Name'));
        expect(exerciseDoc.data()?['durationMinutes'], equals(20));
      },
    );

    test(
      'Exercise can be deleted',
      () async {
        await createTestSessionWithGroup();

        final exerciseId = await FirebaseEmulatorHelper.createTestExercise(
          trainingSessionId: sessionId,
          name: 'To Be Deleted',
        );

        final firestore = FirebaseFirestore.instance;

        // Verify exercise exists
        var exerciseDoc = await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('exercises')
            .doc(exerciseId)
            .get();
        expect(exerciseDoc.exists, isTrue);

        // Delete exercise
        await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('exercises')
            .doc(exerciseId)
            .delete();

        // Verify exercise is deleted
        exerciseDoc = await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('exercises')
            .doc(exerciseId)
            .get();
        expect(exerciseDoc.exists, isFalse);
      },
    );
  });

  group('Feedback Submission', () {
    late String groupId;
    late String userId;
    late String sessionId;

    Future<void> createTestSessionWithGroup() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'feedbacktest@test.com',
        password: 'password123',
        displayName: 'Feedback Tester',
      );
      userId = user.uid;

      groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: userId,
        name: 'Feedback Test Group',
      );

      sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
        groupId: groupId,
        createdBy: userId,
        title: 'Feedback Test Session',
        participantIds: [userId],
        status: 'completed',
      );
    }

    test(
      'User can submit feedback for a training session',
      () async {
        await createTestSessionWithGroup();

        // Generate a participant hash (simulating what the Cloud Function would do)
        final participantHash = 'hash_${sessionId}_$userId';

        final feedbackId = await FirebaseEmulatorHelper.createTestFeedback(
          trainingSessionId: sessionId,
          exercisesQuality: 4,
          trainingIntensity: 5,
          coachingClarity: 4,
          comment: 'Great session!',
          participantHash: participantHash,
        );

        final firestore = FirebaseFirestore.instance;
        final feedbackDoc = await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('feedback')
            .doc(feedbackId)
            .get();

        expect(feedbackDoc.exists, isTrue);
        expect(feedbackDoc.data()?['exercisesQuality'], equals(4));
        expect(feedbackDoc.data()?['trainingIntensity'], equals(5));
        expect(feedbackDoc.data()?['coachingClarity'], equals(4));
        expect(feedbackDoc.data()?['comment'], equals('Great session!'));
        expect(feedbackDoc.data()?['participantHash'], equals(participantHash));
      },
    );

    test(
      'Feedback is anonymous (no direct user ID stored)',
      () async {
        await createTestSessionWithGroup();

        final participantHash = 'anonymous_hash_123';

        final feedbackId = await FirebaseEmulatorHelper.createTestFeedback(
          trainingSessionId: sessionId,
          exercisesQuality: 3,
          trainingIntensity: 4,
          coachingClarity: 5,
          participantHash: participantHash,
        );

        final firestore = FirebaseFirestore.instance;
        final feedbackDoc = await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('feedback')
            .doc(feedbackId)
            .get();

        // Verify no userId field exists
        expect(feedbackDoc.data()?.containsKey('userId'), isFalse);
        // Verify only hash is stored
        expect(feedbackDoc.data()?['participantHash'], equals(participantHash));
      },
    );

    test(
      'Multiple feedback entries can be submitted for same session',
      () async {
        await createTestSessionWithGroup();

        // Submit feedback from different "participants" (simulated with different hashes)
        await FirebaseEmulatorHelper.createTestFeedback(
          trainingSessionId: sessionId,
          exercisesQuality: 5,
          trainingIntensity: 5,
          coachingClarity: 5,
          participantHash: 'hash_participant_1',
        );

        await FirebaseEmulatorHelper.createTestFeedback(
          trainingSessionId: sessionId,
          exercisesQuality: 4,
          trainingIntensity: 4,
          coachingClarity: 4,
          participantHash: 'hash_participant_2',
        );

        await FirebaseEmulatorHelper.createTestFeedback(
          trainingSessionId: sessionId,
          exercisesQuality: 3,
          trainingIntensity: 3,
          coachingClarity: 3,
          participantHash: 'hash_participant_3',
        );

        final firestore = FirebaseFirestore.instance;
        final feedbackList = await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('feedback')
            .get();

        expect(feedbackList.docs.length, equals(3));
      },
    );

    test(
      'Feedback ratings are within valid range',
      () async {
        await createTestSessionWithGroup();

        final feedbackId = await FirebaseEmulatorHelper.createTestFeedback(
          trainingSessionId: sessionId,
          exercisesQuality: 1,
          trainingIntensity: 3,
          coachingClarity: 5,
          participantHash: 'test_hash',
        );

        final firestore = FirebaseFirestore.instance;
        final feedbackDoc = await firestore
            .collection('trainingSessions')
            .doc(sessionId)
            .collection('feedback')
            .doc(feedbackId)
            .get();

        final exercisesQuality = feedbackDoc.data()?['exercisesQuality'] as int;
        final trainingIntensity = feedbackDoc.data()?['trainingIntensity'] as int;
        final coachingClarity = feedbackDoc.data()?['coachingClarity'] as int;

        // Verify ratings are within 1-5 range
        expect(exercisesQuality, greaterThanOrEqualTo(1));
        expect(exercisesQuality, lessThanOrEqualTo(5));
        expect(trainingIntensity, greaterThanOrEqualTo(1));
        expect(trainingIntensity, lessThanOrEqualTo(5));
        expect(coachingClarity, greaterThanOrEqualTo(1));
        expect(coachingClarity, lessThanOrEqualTo(5));
      },
    );
  });

  group('Training Session Status', () {
    late String groupId;
    late String userId;

    Future<void> createTestGroupAndUser() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'statustest@test.com',
        password: 'password123',
        displayName: 'Status Tester',
      );
      userId = user.uid;

      groupId = await FirebaseEmulatorHelper.createTestGroup(
        createdBy: userId,
        name: 'Status Test Group',
      );
    }

    test(
      'Training session status can be updated to cancelled',
      () async {
        await createTestGroupAndUser();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Cancellation Test',
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

    test(
      'Training session status can be updated to completed',
      () async {
        await createTestGroupAndUser();

        final sessionId = await FirebaseEmulatorHelper.createTestTrainingSession(
          groupId: groupId,
          createdBy: userId,
          title: 'Completion Test',
          status: 'scheduled',
        );

        final firestore = FirebaseFirestore.instance;

        // Complete the session
        await firestore.collection('trainingSessions').doc(sessionId).update({
          'status': 'completed',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final sessionDoc =
            await firestore.collection('trainingSessions').doc(sessionId).get();

        expect(sessionDoc.data()?['status'], equals('completed'));
      },
    );
  });
}
