// Validates FirestoreNotificationRepository handles preferences correctly

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/notifications/data/repositories/firestore_notification_repository.dart';
import 'package:play_with_me/features/notifications/domain/entities/notification_preferences_entity.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late FirestoreNotificationRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;
  late MockDocumentSnapshot mockSnapshot;

  const testUserId = 'test-user-id';

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();
    mockSnapshot = MockDocumentSnapshot();

    repository = FirestoreNotificationRepository(
      firestore: mockFirestore,
      auth: mockAuth,
    );

    // Default setup: authenticated user
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn(testUserId);
    when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
    when(() => mockCollection.doc(testUserId)).thenReturn(mockDocument);
  });

  group('getPreferences', () {
    test('returns default preferences when no preferences exist', () async {
      // Arrange
      when(() => mockDocument.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.data()).thenReturn({});

      // Act
      final result = await repository.getPreferences();

      // Assert
      expect(result, const NotificationPreferencesEntity());
      verify(() => mockDocument.get()).called(1);
    });

    test('returns default preferences when notificationPreferences field is null', () async {
      // Arrange
      when(() => mockDocument.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.data()).thenReturn({
        'displayName': 'Test User',
        'email': 'test@example.com',
      });

      // Act
      final result = await repository.getPreferences();

      // Assert
      expect(result, const NotificationPreferencesEntity());
    });

    test('returns stored preferences when they exist', () async {
      // Arrange
      final prefsData = {
        'groupInvitations': false,
        'invitationAccepted': true,
        'gameCreated': false,
        'memberJoined': true,
        'memberLeft': true,
        'roleChanged': false,
        'quietHoursEnabled': true,
        'quietHoursStart': '22:00',
        'quietHoursEnd': '08:00',
        'groupSpecific': {'group1': false},
      };

      when(() => mockDocument.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.data()).thenReturn({
        'notificationPreferences': prefsData,
      });

      // Act
      final result = await repository.getPreferences();

      // Assert
      expect(result.groupInvitations, false);
      expect(result.invitationAccepted, true);
      expect(result.gameCreated, false);
      expect(result.memberJoined, true);
      expect(result.memberLeft, true);
      expect(result.roleChanged, false);
      expect(result.quietHoursEnabled, true);
      expect(result.quietHoursStart, '22:00');
      expect(result.quietHoursEnd, '08:00');
      expect(result.groupSpecific, {'group1': false});
    });

    test('throws exception when user is not authenticated', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(
        () => repository.getPreferences(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('User not authenticated'),
        )),
      );
    });
  });

  group('updatePreferences', () {
    test('updates preferences successfully', () async {
      // Arrange
      const preferences = NotificationPreferencesEntity(
        groupInvitations: false,
        gameCreated: true,
        quietHoursEnabled: true,
        quietHoursStart: '23:00',
        quietHoursEnd: '07:00',
      );

      when(() => mockDocument.update(any())).thenAnswer((_) async => {});

      // Act
      await repository.updatePreferences(preferences);

      // Assert
      verify(() => mockDocument.update({
        'notificationPreferences': preferences.toJson(),
      })).called(1);
    });

    test('converts preferences to JSON correctly before updating', () async {
      // Arrange
      const preferences = NotificationPreferencesEntity(
        groupInvitations: true,
        invitationAccepted: false,
        gameCreated: true,
        memberJoined: false,
        memberLeft: true,
        roleChanged: false,
        quietHoursEnabled: true,
        quietHoursStart: '22:00',
        quietHoursEnd: '08:00',
        groupSpecific: {'group1': false, 'group2': true},
      );

      when(() => mockDocument.update(any())).thenAnswer((_) async => {});

      // Act
      await repository.updatePreferences(preferences);

      // Assert
      final captured = verify(() => mockDocument.update(captureAny())).captured;
      final updateData = captured.first;
      final prefsJson = updateData['notificationPreferences'];

      expect(prefsJson['groupInvitations'], true);
      expect(prefsJson['invitationAccepted'], false);
      expect(prefsJson['gameCreated'], true);
      expect(prefsJson['memberJoined'], false);
      expect(prefsJson['memberLeft'], true);
      expect(prefsJson['roleChanged'], false);
      expect(prefsJson['quietHoursEnabled'], true);
      expect(prefsJson['quietHoursStart'], '22:00');
      expect(prefsJson['quietHoursEnd'], '08:00');
      expect(prefsJson['groupSpecific'], {'group1': false, 'group2': true});
    });

    test('throws exception when user is not authenticated', () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);
      const preferences = NotificationPreferencesEntity();

      // Act & Assert
      expect(
        () => repository.updatePreferences(preferences),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('User not authenticated'),
        )),
      );
    });

    test('propagates Firestore errors', () async {
      // Arrange
      const preferences = NotificationPreferencesEntity();
      when(() => mockDocument.update(any()))
          .thenThrow(FirebaseException(plugin: 'firestore', message: 'Update failed'));

      // Act & Assert
      expect(
        () => repository.updatePreferences(preferences),
        throwsA(isA<FirebaseException>()),
      );
    });
  });

  group('preferencesStream', () {
    test('throws exception when user is not authenticated', () {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(
        () => repository.preferencesStream(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('User not authenticated'),
        )),
      );
    });

    test('emits default preferences when no preferences exist in snapshot', () async {
      // Arrange
      when(() => mockDocument.snapshots()).thenAnswer((_) {
        return Stream.value(mockSnapshot);
      });
      when(() => mockSnapshot.data()).thenReturn({});

      // Act
      final stream = repository.preferencesStream();

      // Assert
      await expectLater(
        stream,
        emits(const NotificationPreferencesEntity()),
      );
    });

    test('emits stored preferences when they exist', () async {
      // Arrange
      final prefsData = {
        'groupInvitations': false,
        'gameCreated': true,
        'quietHoursEnabled': true,
        'quietHoursStart': '22:00',
        'quietHoursEnd': '08:00',
      };

      when(() => mockDocument.snapshots()).thenAnswer((_) {
        return Stream.value(mockSnapshot);
      });
      when(() => mockSnapshot.data()).thenReturn({
        'notificationPreferences': prefsData,
      });

      // Act
      final stream = repository.preferencesStream();

      // Assert
      await expectLater(
        stream,
        emits(predicate<NotificationPreferencesEntity>((prefs) {
          return prefs.groupInvitations == false &&
                 prefs.gameCreated == true &&
                 prefs.quietHoursEnabled == true &&
                 prefs.quietHoursStart == '22:00' &&
                 prefs.quietHoursEnd == '08:00';
        })),
      );
    });

    test('emits multiple updates when preferences change', () async {
      // Arrange
      final snapshot1 = MockDocumentSnapshot();
      final snapshot2 = MockDocumentSnapshot();

      when(() => snapshot1.data()).thenReturn({
        'notificationPreferences': {'groupInvitations': true},
      });
      when(() => snapshot2.data()).thenReturn({
        'notificationPreferences': {'groupInvitations': false},
      });

      when(() => mockDocument.snapshots()).thenAnswer((_) {
        return Stream.fromIterable([snapshot1, snapshot2]);
      });

      // Act
      final stream = repository.preferencesStream();

      // Assert
      await expectLater(
        stream,
        emitsInOrder([
          predicate<NotificationPreferencesEntity>((p) => p.groupInvitations == true),
          predicate<NotificationPreferencesEntity>((p) => p.groupInvitations == false),
        ]),
      );
    });
  });
}
