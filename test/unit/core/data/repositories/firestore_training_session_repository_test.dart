// Tests FirestoreTrainingSessionRepository methods with mocked dependencies.

import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/data/models/training_session_model.dart';
import 'package:play_with_me/core/data/repositories/firestore_training_session_repository.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/group_repository.dart';

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

class MockHttpsCallable extends Mock implements HttpsCallable {}

class MockHttpsCallableResult<T> extends Mock implements HttpsCallableResult<T> {}

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  group('FirestoreTrainingSessionRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseFunctions mockFunctions;
    late MockGroupRepository mockGroupRepository;
    late FirestoreTrainingSessionRepository repository;

    const testLocation = GameLocation(name: 'Beach Court', address: '123 Beach Rd');

    TrainingSessionModel createTestSession({
      String id = '',
      String groupId = 'group-123',
      String title = 'Test Session',
      String createdBy = 'user-123',
      DateTime? startTime,
      DateTime? endTime,
      DateTime? createdAt,
      TrainingStatus status = TrainingStatus.scheduled,
      List<String> participantIds = const [],
      int minParticipants = 2,
      int maxParticipants = 8,
    }) {
      final now = DateTime.now();
      return TrainingSessionModel(
        id: id,
        groupId: groupId,
        title: title,
        location: testLocation,
        startTime: startTime ?? now.add(const Duration(days: 1)),
        endTime: endTime ?? now.add(const Duration(days: 1, hours: 2)),
        minParticipants: minParticipants,
        maxParticipants: maxParticipants,
        createdBy: createdBy,
        createdAt: createdAt ?? now.subtract(const Duration(days: 1)),
        status: status,
        participantIds: participantIds,
      );
    }

    Future<String> addTestSessionToFirestore(TrainingSessionModel session) async {
      final docRef = await fakeFirestore.collection('trainingSessions').add(
        session.toFirestore(),
      );
      return docRef.id;
    }

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockFunctions = MockFirebaseFunctions();
      mockGroupRepository = MockGroupRepository();
      repository = FirestoreTrainingSessionRepository(
        firestore: fakeFirestore,
        functions: mockFunctions,
        groupRepository: mockGroupRepository,
      );
    });

    group('constructor', () {
      test('creates repository with custom dependencies', () {
        final repo = FirestoreTrainingSessionRepository(
          firestore: fakeFirestore,
          functions: mockFunctions,
          groupRepository: mockGroupRepository,
        );
        expect(repo, isNotNull);
      });
    });

    group('getTrainingSessionById', () {
      test('returns session when it exists', () async {
        final testSession = createTestSession();
        final sessionId = await addTestSessionToFirestore(testSession);

        final result = await repository.getTrainingSessionById(sessionId);

        expect(result, isNotNull);
        expect(result!.id, equals(sessionId));
        expect(result.title, equals('Test Session'));
        expect(result.groupId, equals('group-123'));
      });

      test('returns null when session does not exist', () async {
        final result = await repository.getTrainingSessionById('non-existent-id');

        expect(result, isNull);
      });
    });

    group('deleteTrainingSession', () {
      test('deletes session successfully', () async {
        final testSession = createTestSession();
        final sessionId = await addTestSessionToFirestore(testSession);

        // Verify session exists
        var doc = await fakeFirestore
            .collection('trainingSessions')
            .doc(sessionId)
            .get();
        expect(doc.exists, isTrue);

        // Delete session
        await repository.deleteTrainingSession(sessionId);

        // Verify session is deleted
        doc = await fakeFirestore
            .collection('trainingSessions')
            .doc(sessionId)
            .get();
        expect(doc.exists, isFalse);
      });
    });

    group('trainingSessionExists', () {
      test('returns true when session exists', () async {
        final testSession = createTestSession();
        final sessionId = await addTestSessionToFirestore(testSession);

        final exists = await repository.trainingSessionExists(sessionId);

        expect(exists, isTrue);
      });

      test('returns false when session does not exist', () async {
        final exists = await repository.trainingSessionExists('non-existent-id');

        expect(exists, isFalse);
      });
    });

    group('getTrainingSessionParticipants', () {
      test('returns participant IDs from session', () async {
        final testSession = createTestSession(
          participantIds: ['user-1', 'user-2', 'user-3'],
        );
        final sessionId = await addTestSessionToFirestore(testSession);

        final participants =
            await repository.getTrainingSessionParticipants(sessionId);

        expect(participants, hasLength(3));
        expect(participants, contains('user-1'));
        expect(participants, contains('user-2'));
        expect(participants, contains('user-3'));
      });

      test('returns empty list for non-existent session', () async {
        final participants =
            await repository.getTrainingSessionParticipants('non-existent');

        expect(participants, isEmpty);
      });
    });

    group('canUserJoinTrainingSession', () {
      test('returns true when user can join', () async {
        final testSession = createTestSession(
          participantIds: ['user-1'],
          maxParticipants: 4,
        );
        final sessionId = await addTestSessionToFirestore(testSession);

        when(() => mockGroupRepository.getGroupMembers('group-123'))
            .thenAnswer((_) async => ['user-1', 'user-2', 'user-3']);

        final canJoin =
            await repository.canUserJoinTrainingSession(sessionId, 'user-2');

        expect(canJoin, isTrue);
      });

      test('returns false when user is not group member', () async {
        final testSession = createTestSession(
          participantIds: ['user-1'],
          maxParticipants: 4,
        );
        final sessionId = await addTestSessionToFirestore(testSession);

        when(() => mockGroupRepository.getGroupMembers('group-123'))
            .thenAnswer((_) async => ['user-1', 'user-2']);

        final canJoin =
            await repository.canUserJoinTrainingSession(sessionId, 'user-999');

        expect(canJoin, isFalse);
      });

      test('returns false for non-existent session', () async {
        final canJoin =
            await repository.canUserJoinTrainingSession('non-existent', 'user-1');

        expect(canJoin, isFalse);
      });
    });

    group('addParticipant', () {
      test('adds participant to session', () async {
        final testSession = createTestSession(
          participantIds: ['user-1'],
          maxParticipants: 4,
        );
        final sessionId = await addTestSessionToFirestore(testSession);

        when(() => mockGroupRepository.getGroupMembers('group-123'))
            .thenAnswer((_) async => ['user-1', 'user-2', 'user-3']);

        await repository.addParticipant(sessionId, 'user-2');

        final updatedSession = await repository.getTrainingSessionById(sessionId);
        expect(updatedSession!.participantIds, contains('user-2'));
      });

      test('throws exception when session not found', () async {
        expect(
          () => repository.addParticipant('non-existent', 'user-1'),
          throwsA(isA<TrainingSessionException>()),
        );
      });

      test('throws exception when user not in group', () async {
        final testSession = createTestSession(
          participantIds: ['user-1'],
        );
        final sessionId = await addTestSessionToFirestore(testSession);

        when(() => mockGroupRepository.getGroupMembers('group-123'))
            .thenAnswer((_) async => ['user-1']);

        expect(
          () => repository.addParticipant(sessionId, 'user-999'),
          throwsA(isA<TrainingSessionException>()),
        );
      });

      test('throws exception when session is full', () async {
        final testSession = createTestSession(
          participantIds: ['user-1', 'user-2'],
          maxParticipants: 2,
        );
        final sessionId = await addTestSessionToFirestore(testSession);

        when(() => mockGroupRepository.getGroupMembers('group-123'))
            .thenAnswer((_) async => ['user-1', 'user-2', 'user-3']);

        expect(
          () => repository.addParticipant(sessionId, 'user-3'),
          throwsA(isA<TrainingSessionException>()),
        );
      });
    });

    group('removeParticipant', () {
      test('removes participant from session', () async {
        final testSession = createTestSession(
          participantIds: ['user-1', 'user-2'],
        );
        final sessionId = await addTestSessionToFirestore(testSession);

        await repository.removeParticipant(sessionId, 'user-2');

        final updatedSession = await repository.getTrainingSessionById(sessionId);
        expect(updatedSession!.participantIds, isNot(contains('user-2')));
        expect(updatedSession.participantIds, contains('user-1'));
      });

      test('throws exception when session not found', () async {
        expect(
          () => repository.removeParticipant('non-existent', 'user-1'),
          throwsA(isA<TrainingSessionException>()),
        );
      });
    });

    group('completeTrainingSession', () {
      test('marks session as completed', () async {
        final testSession = createTestSession();
        final sessionId = await addTestSessionToFirestore(testSession);

        await repository.completeTrainingSession(sessionId);

        final updatedSession = await repository.getTrainingSessionById(sessionId);
        expect(updatedSession!.status, equals(TrainingStatus.completed));
      });

      test('throws exception when session not found', () async {
        expect(
          () => repository.completeTrainingSession('non-existent'),
          throwsA(isA<TrainingSessionException>()),
        );
      });
    });

    group('updateTrainingSessionInfo', () {
      test('updates session title', () async {
        final testSession = createTestSession(title: 'Original Title');
        final sessionId = await addTestSessionToFirestore(testSession);

        await repository.updateTrainingSessionInfo(
          sessionId,
          title: 'Updated Title',
        );

        final updatedSession = await repository.getTrainingSessionById(sessionId);
        expect(updatedSession!.title, equals('Updated Title'));
      });

      test('updates session description', () async {
        final testSession = createTestSession();
        final sessionId = await addTestSessionToFirestore(testSession);

        await repository.updateTrainingSessionInfo(
          sessionId,
          description: 'New description',
        );

        final updatedSession = await repository.getTrainingSessionById(sessionId);
        expect(updatedSession!.description, equals('New description'));
      });

      test('throws exception when session not found', () async {
        expect(
          () => repository.updateTrainingSessionInfo(
            'non-existent',
            title: 'New Title',
          ),
          throwsA(isA<TrainingSessionException>()),
        );
      });
    });

    group('updateTrainingSessionSettings', () {
      test('updates max participants', () async {
        final testSession = createTestSession(maxParticipants: 8);
        final sessionId = await addTestSessionToFirestore(testSession);

        await repository.updateTrainingSessionSettings(
          sessionId,
          maxParticipants: 12,
        );

        final updatedSession = await repository.getTrainingSessionById(sessionId);
        expect(updatedSession!.maxParticipants, equals(12));
      });

      test('updates min participants', () async {
        final testSession = createTestSession(minParticipants: 2);
        final sessionId = await addTestSessionToFirestore(testSession);

        await repository.updateTrainingSessionSettings(
          sessionId,
          minParticipants: 4,
        );

        final updatedSession = await repository.getTrainingSessionById(sessionId);
        expect(updatedSession!.minParticipants, equals(4));
      });

      test('throws exception when session not found', () async {
        expect(
          () => repository.updateTrainingSessionSettings(
            'non-existent',
            maxParticipants: 10,
          ),
          throwsA(isA<TrainingSessionException>()),
        );
      });
    });

    group('createTrainingSession', () {
      test('calls Cloud Function and returns session ID', () async {
        final mockCallable = MockHttpsCallable();
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

        when(() => mockFunctions.httpsCallable('createTrainingSession'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call<Map<String, dynamic>>(any()))
            .thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({'sessionId': 'new-session-123'});

        final testSession = createTestSession();
        final sessionId = await repository.createTrainingSession(testSession);

        expect(sessionId, equals('new-session-123'));
        verify(() => mockFunctions.httpsCallable('createTrainingSession'))
            .called(1);
      });

      test('throws exception on unauthenticated error', () async {
        final mockCallable = MockHttpsCallable();

        when(() => mockFunctions.httpsCallable('createTrainingSession'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call<Map<String, dynamic>>(any()))
            .thenThrow(FirebaseFunctionsException(code: 'unauthenticated', message: 'message'));

        final testSession = createTestSession();

        expect(
          () => repository.createTrainingSession(testSession),
          throwsA(
            isA<TrainingSessionException>().having(
              (e) => e.code,
              'code',
              equals('unauthenticated'),
            ),
          ),
        );
      });
    });

    group('joinTrainingSession', () {
      test('calls Cloud Function successfully', () async {
        final mockCallable = MockHttpsCallable();
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

        when(() => mockFunctions.httpsCallable('joinTrainingSession'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call<Map<String, dynamic>>(any()))
            .thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({});

        await repository.joinTrainingSession('session-123');

        verify(() => mockFunctions.httpsCallable('joinTrainingSession'))
            .called(1);
      });

      test('throws exception on already joined error', () async {
        final mockCallable = MockHttpsCallable();

        when(() => mockFunctions.httpsCallable('joinTrainingSession'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call<Map<String, dynamic>>(any()))
            .thenThrow(FirebaseFunctionsException(code: 'already-exists', message: 'message'));

        expect(
          () => repository.joinTrainingSession('session-123'),
          throwsA(
            isA<TrainingSessionException>().having(
              (e) => e.code,
              'code',
              equals('already-exists'),
            ),
          ),
        );
      });
    });

    group('leaveTrainingSession', () {
      test('calls Cloud Function successfully', () async {
        final mockCallable = MockHttpsCallable();
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

        when(() => mockFunctions.httpsCallable('leaveTrainingSession'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call<Map<String, dynamic>>(any()))
            .thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({});

        await repository.leaveTrainingSession('session-123');

        verify(() => mockFunctions.httpsCallable('leaveTrainingSession'))
            .called(1);
      });
    });

    group('cancelTrainingSession', () {
      test('calls Cloud Function successfully', () async {
        final mockCallable = MockHttpsCallable();
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

        when(() => mockFunctions.httpsCallable('cancelTrainingSession'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call<Map<String, dynamic>>(any()))
            .thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({});

        await repository.cancelTrainingSession('session-123');

        verify(() => mockFunctions.httpsCallable('cancelTrainingSession'))
            .called(1);
      });

      test('throws exception on permission denied', () async {
        final mockCallable = MockHttpsCallable();

        when(() => mockFunctions.httpsCallable('cancelTrainingSession'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call<Map<String, dynamic>>(any()))
            .thenThrow(FirebaseFunctionsException(code: 'permission-denied', message: 'message'));

        expect(
          () => repository.cancelTrainingSession('session-123'),
          throwsA(
            isA<TrainingSessionException>().having(
              (e) => e.code,
              'code',
              equals('permission-denied'),
            ),
          ),
        );
      });
    });

    group('generateRecurringInstances', () {
      test('calls Cloud Function and returns session IDs', () async {
        final mockCallable = MockHttpsCallable();
        final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

        when(() => mockFunctions.httpsCallable('generateRecurringTrainingSessions'))
            .thenReturn(mockCallable);
        when(() => mockCallable.call<Map<String, dynamic>>(any()))
            .thenAnswer((_) async => mockResult);
        when(() => mockResult.data).thenReturn({
          'sessionIds': ['session-1', 'session-2', 'session-3']
        });

        final sessionIds =
            await repository.generateRecurringInstances('parent-session');

        expect(sessionIds, hasLength(3));
        expect(sessionIds, contains('session-1'));
        expect(sessionIds, contains('session-2'));
        expect(sessionIds, contains('session-3'));
      });
    });
  });
}
