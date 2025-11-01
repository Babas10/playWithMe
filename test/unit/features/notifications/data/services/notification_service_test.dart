// Unit tests for NotificationService - validates FCM initialization, token management, and message handling
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/notifications/data/services/notification_service.dart';

// Mocks
class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockNotificationSettings extends Mock implements NotificationSettings {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

// Fakes
class FakeInitializationSettings extends Fake
    implements InitializationSettings {}

class FakeRemoteMessage extends Fake implements RemoteMessage {}

void main() {
  late MockFirebaseMessaging mockFcm;
  late MockFlutterLocalNotificationsPlugin mockLocalNotifications;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;
  late NotificationService notificationService;

  setUpAll(() {
    registerFallbackValue(FakeInitializationSettings());
    registerFallbackValue(FakeRemoteMessage());
    registerFallbackValue(const AndroidNotificationChannel(
      'test_channel',
      'Test Channel',
    ));
  });

  setUp(() {
    mockFcm = MockFirebaseMessaging();
    mockLocalNotifications = MockFlutterLocalNotificationsPlugin();
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();

    // Default stubs
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test-user-id');
    when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocument);

    notificationService = NotificationService(
      fcm: mockFcm,
      localNotifications: mockLocalNotifications,
      firestore: mockFirestore,
      auth: mockAuth,
    );
  });

  group('NotificationService - getToken', () {
    test('returns FCM token when available', () async {
      // Arrange
      when(() => mockFcm.getToken()).thenAnswer((_) async => 'test-fcm-token');

      // Act
      final token = await notificationService.getToken();

      // Assert
      expect(token, 'test-fcm-token');
      verify(() => mockFcm.getToken()).called(1);
    });

    test('returns null when FCM token is not available', () async {
      // Arrange
      when(() => mockFcm.getToken()).thenAnswer((_) async => null);

      // Act
      final token = await notificationService.getToken();

      // Assert
      expect(token, null);
      verify(() => mockFcm.getToken()).called(1);
    });
  });

  group('NotificationService - deleteToken', () {
    test('deletes FCM token and removes from Firestore when user is authenticated',
        () async {
      // Arrange
      when(() => mockFcm.deleteToken()).thenAnswer((_) async {});
      when(() => mockFcm.getToken()).thenAnswer((_) async => 'old-token');
      when(() => mockDocument.update(any())).thenAnswer((_) async {});

      // Act
      await notificationService.deleteToken();

      // Assert
      verify(() => mockFcm.deleteToken()).called(1);
      verify(() => mockFcm.getToken()).called(1);
      verify(() => mockDocument.update({
            'fcmTokens': FieldValue.arrayRemove(['old-token']),
          })).called(1);
    });

    test('deletes FCM token but does not update Firestore when no token exists',
        () async {
      // Arrange
      when(() => mockFcm.deleteToken()).thenAnswer((_) async {});
      when(() => mockFcm.getToken()).thenAnswer((_) async => null);

      // Act
      await notificationService.deleteToken();

      // Assert
      verify(() => mockFcm.deleteToken()).called(1);
      verify(() => mockFcm.getToken()).called(1);
      verifyNever(() => mockDocument.update(any()));
    });

    test('deletes FCM token but does not update Firestore when user is not authenticated',
        () async {
      // Arrange
      when(() => mockAuth.currentUser).thenReturn(null);
      when(() => mockFcm.deleteToken()).thenAnswer((_) async {});

      // Act
      await notificationService.deleteToken();

      // Assert
      verify(() => mockFcm.deleteToken()).called(1);
      // getToken is NOT called when user is not authenticated (early return)
      verifyNever(() => mockFcm.getToken());
      verifyNever(() => mockDocument.update(any()));
    });
  });
}
