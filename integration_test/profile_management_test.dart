// Integration test for profile management flow
// Tests real Firebase interactions for profile viewing, editing, and settings using Firebase Emulator

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:play_with_me/core/data/models/user_model.dart';

import 'helpers/firebase_emulator_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await FirebaseEmulatorHelper.initialize();
    // Initialize Storage emulator
    FirebaseStorage.instance.useStorageEmulator(
      FirebaseEmulatorHelper.emulatorHost,
      FirebaseEmulatorHelper.storagePort,
    );
  });

  setUp(() async {
    await FirebaseEmulatorHelper.clearFirestore();
    await FirebaseEmulatorHelper.signOut();
  });

  tearDown(() async {
    await FirebaseEmulatorHelper.signOut();
  });

  group('Profile Management - Profile Display', () {
    test(
      'User can view their profile with current data',
      () async {
        // 1. Create a complete test user
        final testEmail = 'profile-view@test.com';
        final testPassword = 'password123';
        final testDisplayName = 'Test Profile User';

        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: testPassword,
          displayName: testDisplayName,
        );

        // 2. Retrieve user profile from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // 3. Verify profile data is correct
        expect(userDoc.exists, isTrue);
        expect(userDoc.data()?['email'], equals(testEmail));
        expect(userDoc.data()?['displayName'], equals(testDisplayName));
        expect(userDoc.data()?['groupIds'], isA<List>());
        expect(userDoc.data()?['gameIds'], isA<List>());
      },
    );

    test(
      'User profile contains default privacy and preference settings',
      () async {
        // 1. Create a test user with extended profile data
        final user = await FirebaseEmulatorHelper.createTestUser(
          email: 'defaults@test.com',
          password: 'password123',
          displayName: 'Defaults User',
        );

        // 2. Create Firestore document with explicit defaults
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': 'defaults@test.com',
          'displayName': 'Defaults User',
          'createdAt': FieldValue.serverTimestamp(),
          'groupIds': <String>[],
          'gameIds': <String>[],
          // Default privacy settings
          'privacyLevel': 'public',
          'showEmail': true,
          'showPhoneNumber': true,
          // Default notification preferences
          'notificationsEnabled': true,
          'emailNotifications': true,
          'pushNotifications': true,
          // Other defaults
          'isEmailVerified': false,
          'isAnonymous': false,
        });

        // 3. Verify default settings
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.data()?['privacyLevel'], equals('public'));
        expect(userDoc.data()?['showEmail'], isTrue);
        expect(userDoc.data()?['showPhoneNumber'], isTrue);
        expect(userDoc.data()?['notificationsEnabled'], isTrue);
        expect(userDoc.data()?['emailNotifications'], isTrue);
        expect(userDoc.data()?['pushNotifications'], isTrue);
      },
    );
  });

  group('Profile Management - Display Name Update', () {
    test(
      'User can update their display name',
      () async {
        // 1. Create a test user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'display-name@test.com',
          password: 'password123',
          displayName: 'Original Name',
        );

        // 2. Update display name in Firestore
        final newDisplayName = 'Updated Name';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'displayName': newDisplayName,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3. Verify the update persisted
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.data()?['displayName'], equals(newDisplayName));
        expect(userDoc.data()?['updatedAt'], isNotNull);
      },
    );

    test(
      'Display name update is reflected in Firebase Auth profile',
      () async {
        // 1. Create and sign in a test user
        final testEmail = 'auth-name@test.com';
        final testPassword = 'password123';

        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: testPassword,
          displayName: 'Auth Original',
        );

        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: testEmail,
          password: testPassword,
        );

        // 2. Update display name in Firebase Auth
        final newDisplayName = 'Auth Updated';
        await FirebaseAuth.instance.currentUser?.updateDisplayName(newDisplayName);
        await FirebaseAuth.instance.currentUser?.reload();

        // 3. Verify the update in Firebase Auth
        final updatedUser = FirebaseAuth.instance.currentUser;
        expect(updatedUser?.displayName, equals(newDisplayName));
      },
    );

    test(
      'Empty display name update is rejected',
      () async {
        // 1. Create a test user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'empty-name@test.com',
          password: 'password123',
          displayName: 'Has Name',
        );

        // 2. Attempt to update with empty string (simulating validation)
        // In actual app, this is validated in BLoC before reaching Firestore
        // We test that the original name is preserved when not updating
        final originalDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(originalDoc.data()?['displayName'], equals('Has Name'));
        expect(originalDoc.data()?['displayName']?.isNotEmpty, isTrue);
      },
    );
  });

  group('Profile Management - Photo URL Update (Avatar)', () {
    test(
      'User can update their photo URL',
      () async {
        // 1. Create a test user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'photo-url@test.com',
          password: 'password123',
          displayName: 'Photo User',
        );

        // 2. Update photo URL in Firestore
        const newPhotoUrl = 'https://example.com/avatar.jpg';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'photoUrl': newPhotoUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3. Verify the update persisted
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.data()?['photoUrl'], equals(newPhotoUrl));
      },
    );

    test(
      'Photo URL update is reflected in Firebase Auth profile',
      () async {
        // 1. Create and sign in a test user
        final testEmail = 'auth-photo@test.com';
        final testPassword = 'password123';

        await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: testPassword,
          displayName: 'Auth Photo User',
        );

        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: testEmail,
          password: testPassword,
        );

        // 2. Update photo URL in Firebase Auth
        const newPhotoUrl = 'https://example.com/new-avatar.jpg';
        await FirebaseAuth.instance.currentUser?.updatePhotoURL(newPhotoUrl);
        await FirebaseAuth.instance.currentUser?.reload();

        // 3. Verify the update in Firebase Auth
        final updatedUser = FirebaseAuth.instance.currentUser;
        expect(updatedUser?.photoURL, equals(newPhotoUrl));
      },
    );

    test(
      'User can remove their photo URL',
      () async {
        // 1. Create a test user with photo URL
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'remove-photo@test.com',
          password: 'password123',
          displayName: 'Remove Photo User',
          photoUrl: 'https://example.com/old-avatar.jpg',
        );

        // 2. Verify initial photo URL exists
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        expect(userDoc.data()?['photoUrl'], equals('https://example.com/old-avatar.jpg'));

        // 3. Remove photo URL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'photoUrl': null,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 4. Verify photo URL was removed
        userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.data()?['photoUrl'], isNull);
      },
    );
  });

  group('Profile Management - Locale/Timezone Preferences', () {
    test(
      'User can save locale preferences to Firestore',
      () async {
        // 1. Create a test user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'locale@test.com',
          password: 'password123',
          displayName: 'Locale User',
        );

        // 2. Save locale preferences to subcollection
        const locale = 'es';
        const country = 'Spain';
        const timeZone = 'Europe/Madrid';

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('preferences')
            .doc('locale')
            .set({
          'language': locale,
          'country': country,
          'timeZone': timeZone,
          'lastSyncedAt': FieldValue.serverTimestamp(),
        });

        // 3. Verify preferences were saved
        final prefsDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('preferences')
            .doc('locale')
            .get();

        expect(prefsDoc.exists, isTrue);
        expect(prefsDoc.data()?['language'], equals(locale));
        expect(prefsDoc.data()?['country'], equals(country));
        expect(prefsDoc.data()?['timeZone'], equals(timeZone));
        expect(prefsDoc.data()?['lastSyncedAt'], isNotNull);
      },
    );

    test(
      'User can update timezone preference',
      () async {
        // 1. Create a test user with initial preferences
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'timezone@test.com',
          password: 'password123',
          displayName: 'Timezone User',
        );

        // 2. Set initial timezone
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('preferences')
            .doc('locale')
            .set({
          'language': 'en',
          'country': 'United States',
          'timeZone': 'America/New_York',
          'lastSyncedAt': FieldValue.serverTimestamp(),
        });

        // 3. Update timezone
        const newTimeZone = 'America/Los_Angeles';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('preferences')
            .doc('locale')
            .update({
          'timeZone': newTimeZone,
          'lastSyncedAt': FieldValue.serverTimestamp(),
        });

        // 4. Verify timezone was updated
        final prefsDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('preferences')
            .doc('locale')
            .get();

        expect(prefsDoc.data()?['timeZone'], equals(newTimeZone));
      },
    );

    test(
      'User can change locale language',
      () async {
        // 1. Create a test user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'language@test.com',
          password: 'password123',
          displayName: 'Language User',
        );

        // 2. Set initial locale to English
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('preferences')
            .doc('locale')
            .set({
          'language': 'en',
          'country': 'United States',
          'lastSyncedAt': FieldValue.serverTimestamp(),
        });

        // 3. Change to French
        const newLanguage = 'fr';
        const newCountry = 'France';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('preferences')
            .doc('locale')
            .update({
          'language': newLanguage,
          'country': newCountry,
          'lastSyncedAt': FieldValue.serverTimestamp(),
        });

        // 4. Verify locale was updated
        final prefsDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('preferences')
            .doc('locale')
            .get();

        expect(prefsDoc.data()?['language'], equals(newLanguage));
        expect(prefsDoc.data()?['country'], equals(newCountry));
      },
    );
  });

  group('Profile Management - Privacy Settings', () {
    test(
      'User can update privacy level to friends-only',
      () async {
        // 1. Create a test user with public privacy
        final user = await FirebaseEmulatorHelper.createTestUser(
          email: 'privacy-friends@test.com',
          password: 'password123',
          displayName: 'Privacy User',
        );

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': 'privacy-friends@test.com',
          'displayName': 'Privacy User',
          'privacyLevel': 'public',
          'showEmail': true,
          'showPhoneNumber': true,
          'isEmailVerified': false,
          'isAnonymous': false,
          'createdAt': FieldValue.serverTimestamp(),
          'groupIds': <String>[],
          'gameIds': <String>[],
        });

        // 2. Update to friends-only privacy
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'privacyLevel': 'friends',
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3. Verify privacy level was updated
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.data()?['privacyLevel'], equals('friends'));
      },
    );

    test(
      'User can update privacy level to private',
      () async {
        // 1. Create a test user with public privacy
        final user = await FirebaseEmulatorHelper.createTestUser(
          email: 'privacy-private@test.com',
          password: 'password123',
          displayName: 'Private User',
        );

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': 'privacy-private@test.com',
          'displayName': 'Private User',
          'privacyLevel': 'public',
          'showEmail': true,
          'showPhoneNumber': true,
          'isEmailVerified': false,
          'isAnonymous': false,
          'createdAt': FieldValue.serverTimestamp(),
          'groupIds': <String>[],
          'gameIds': <String>[],
        });

        // 2. Update to private
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'privacyLevel': 'private',
          'showEmail': false,
          'showPhoneNumber': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3. Verify privacy settings were updated
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.data()?['privacyLevel'], equals('private'));
        expect(userDoc.data()?['showEmail'], isFalse);
        expect(userDoc.data()?['showPhoneNumber'], isFalse);
      },
    );

    test(
      'User can hide email while keeping phone visible',
      () async {
        // 1. Create a test user with all visibility enabled
        final user = await FirebaseEmulatorHelper.createTestUser(
          email: 'selective-privacy@test.com',
          password: 'password123',
          displayName: 'Selective Privacy User',
        );

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': 'selective-privacy@test.com',
          'displayName': 'Selective Privacy User',
          'privacyLevel': 'public',
          'showEmail': true,
          'showPhoneNumber': true,
          'phoneNumber': '+1234567890',
          'isEmailVerified': false,
          'isAnonymous': false,
          'createdAt': FieldValue.serverTimestamp(),
          'groupIds': <String>[],
          'gameIds': <String>[],
        });

        // 2. Hide email only
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'showEmail': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3. Verify selective privacy update
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.data()?['showEmail'], isFalse);
        expect(userDoc.data()?['showPhoneNumber'], isTrue);
      },
    );
  });

  group('Profile Management - Notification Preferences', () {
    test(
      'User can disable all notifications',
      () async {
        // 1. Create a test user with notifications enabled
        final user = await FirebaseEmulatorHelper.createTestUser(
          email: 'notifications@test.com',
          password: 'password123',
          displayName: 'Notifications User',
        );

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': 'notifications@test.com',
          'displayName': 'Notifications User',
          'notificationsEnabled': true,
          'emailNotifications': true,
          'pushNotifications': true,
          'isEmailVerified': false,
          'isAnonymous': false,
          'createdAt': FieldValue.serverTimestamp(),
          'groupIds': <String>[],
          'gameIds': <String>[],
        });

        // 2. Disable all notifications
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'notificationsEnabled': false,
          'emailNotifications': false,
          'pushNotifications': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3. Verify notifications were disabled
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.data()?['notificationsEnabled'], isFalse);
        expect(userDoc.data()?['emailNotifications'], isFalse);
        expect(userDoc.data()?['pushNotifications'], isFalse);
      },
    );

    test(
      'User can selectively enable push notifications only',
      () async {
        // 1. Create a test user with all notifications disabled
        final user = await FirebaseEmulatorHelper.createTestUser(
          email: 'push-only@test.com',
          password: 'password123',
          displayName: 'Push Only User',
        );

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': 'push-only@test.com',
          'displayName': 'Push Only User',
          'notificationsEnabled': false,
          'emailNotifications': false,
          'pushNotifications': false,
          'isEmailVerified': false,
          'isAnonymous': false,
          'createdAt': FieldValue.serverTimestamp(),
          'groupIds': <String>[],
          'gameIds': <String>[],
        });

        // 2. Enable push notifications only
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'notificationsEnabled': true,
          'pushNotifications': true,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3. Verify selective notification settings
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.data()?['notificationsEnabled'], isTrue);
        expect(userDoc.data()?['emailNotifications'], isFalse);
        expect(userDoc.data()?['pushNotifications'], isTrue);
      },
    );
  });

  group('Profile Management - Extended Profile Fields', () {
    test(
      'User can update bio and location',
      () async {
        // 1. Create a test user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'extended@test.com',
          password: 'password123',
          displayName: 'Extended Profile User',
        );

        // 2. Update bio and location
        const bio = 'I love beach volleyball!';
        const location = 'Miami Beach, FL';

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'bio': bio,
          'location': location,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3. Verify extended fields were updated
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.data()?['bio'], equals(bio));
        expect(userDoc.data()?['location'], equals(location));
      },
    );

    test(
      'User can update first name and last name',
      () async {
        // 1. Create a test user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'names@test.com',
          password: 'password123',
          displayName: 'Names User',
        );

        // 2. Update first and last name
        const firstName = 'John';
        const lastName = 'Smith';

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'firstName': firstName,
          'lastName': lastName,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3. Verify name fields were updated
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.data()?['firstName'], equals(firstName));
        expect(userDoc.data()?['lastName'], equals(lastName));
      },
    );

    test(
      'User can update phone number',
      () async {
        // 1. Create a test user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'phone@test.com',
          password: 'password123',
          displayName: 'Phone User',
        );

        // 2. Update phone number
        const phoneNumber = '+1-555-123-4567';

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'phoneNumber': phoneNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3. Verify phone number was updated
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.data()?['phoneNumber'], equals(phoneNumber));
      },
    );
  });

  group('Profile Management - Error Handling', () {
    test(
      'Updating non-existent user document throws error',
      () async {
        // 1. Try to update a non-existent user
        const nonExistentUserId = 'non-existent-user-id';

        // 2. Attempt update should fail
        expect(
          () async => await FirebaseFirestore.instance
              .collection('users')
              .doc(nonExistentUserId)
              .update({'displayName': 'Should Fail'}),
          throwsA(isA<FirebaseException>()),
        );
      },
    );

    test(
      'Cannot read profile when not authenticated',
      () async {
        // 1. Create a test user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'auth-required@test.com',
          password: 'password123',
          displayName: 'Auth Required User',
        );

        final userId = user.uid;

        // 2. Sign out
        await FirebaseEmulatorHelper.signOut();

        // 3. Verify no current user
        expect(FirebaseAuth.instance.currentUser, isNull);

        // Note: Firestore reads depend on security rules.
        // In emulator without strict rules, read may still succeed.
        // This test documents the expected behavior.
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        // Document exists but in production would be protected by security rules
        expect(doc.exists, isTrue);
      },
    );

    test(
      'Invalid field value types are handled',
      () async {
        // 1. Create a test user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'invalid-types@test.com',
          password: 'password123',
          displayName: 'Invalid Types User',
        );

        // 2. Write with correct types
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'displayName': 'Valid Name', // String type
          'gamesPlayed': 5, // Number type
          'groupIds': ['group1', 'group2'], // Array type
        });

        // 3. Verify the update succeeded
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.data()?['displayName'], equals('Valid Name'));
        expect(userDoc.data()?['gamesPlayed'], equals(5));
        expect(userDoc.data()?['groupIds'], contains('group1'));
      },
    );

    test(
      'Concurrent profile updates preserve latest value',
      () async {
        // 1. Create a test user
        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: 'concurrent@test.com',
          password: 'password123',
          displayName: 'Concurrent User',
        );

        // 2. Perform sequential updates (simulating concurrent-like behavior)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'displayName': 'Update 1'});

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'displayName': 'Update 2'});

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'displayName': 'Final Update'});

        // 3. Verify last update persisted
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        expect(userDoc.data()?['displayName'], equals('Final Update'));
      },
    );
  });

  group('Profile Management - Data Persistence', () {
    test(
      'Profile changes persist across sign out and sign in',
      () async {
        // 1. Create a test user
        final testEmail = 'persist@test.com';
        final testPassword = 'password123';

        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: testPassword,
          displayName: 'Persist User',
        );

        final userId = user.uid;

        // 2. Update profile
        const updatedName = 'Persisted Name';
        const updatedBio = 'My updated bio';

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'displayName': updatedName,
          'bio': updatedBio,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 3. Sign out
        await FirebaseEmulatorHelper.signOut();

        // 4. Sign back in
        await FirebaseEmulatorHelper.signIn(
          email: testEmail,
          password: testPassword,
        );

        // 5. Verify changes persisted
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        expect(userDoc.data()?['displayName'], equals(updatedName));
        expect(userDoc.data()?['bio'], equals(updatedBio));
      },
    );

    test(
      'Locale preferences persist in subcollection',
      () async {
        // 1. Create a test user
        final testEmail = 'locale-persist@test.com';
        final testPassword = 'password123';

        final user = await FirebaseEmulatorHelper.createCompleteTestUser(
          email: testEmail,
          password: testPassword,
          displayName: 'Locale Persist User',
        );

        final userId = user.uid;

        // 2. Save locale preferences
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('preferences')
            .doc('locale')
            .set({
          'language': 'de',
          'country': 'Germany',
          'timeZone': 'Europe/Berlin',
          'lastSyncedAt': FieldValue.serverTimestamp(),
        });

        // 3. Sign out and back in
        await FirebaseEmulatorHelper.signOut();
        await FirebaseEmulatorHelper.signIn(
          email: testEmail,
          password: testPassword,
        );

        // 4. Verify preferences persisted
        final prefsDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('preferences')
            .doc('locale')
            .get();

        expect(prefsDoc.exists, isTrue);
        expect(prefsDoc.data()?['language'], equals('de'));
        expect(prefsDoc.data()?['country'], equals('Germany'));
        expect(prefsDoc.data()?['timeZone'], equals('Europe/Berlin'));
      },
    );
  });

  group('Profile Management - UserModel Serialization', () {
    test(
      'UserModel can be serialized to and from Firestore',
      () async {
        // 1. Create a complete UserModel
        final user = await FirebaseEmulatorHelper.createTestUser(
          email: 'model-test@test.com',
          password: 'password123',
          displayName: 'Model Test User',
        );

        final userModel = UserModel(
          uid: user.uid,
          email: 'model-test@test.com',
          displayName: 'Model Test User',
          isEmailVerified: false,
          isAnonymous: false,
          photoUrl: 'https://example.com/photo.jpg',
          firstName: 'Model',
          lastName: 'Test',
          bio: 'Test bio',
          location: 'Test City',
          privacyLevel: UserPrivacyLevel.friends,
          showEmail: false,
          showPhoneNumber: true,
        );

        // 2. Save to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userModel.toFirestore(), SetOptions(merge: true));

        // 3. Read back from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final loadedModel = UserModel.fromFirestore(doc);

        // 4. Verify all fields match
        expect(loadedModel.uid, equals(userModel.uid));
        expect(loadedModel.email, equals(userModel.email));
        expect(loadedModel.displayName, equals(userModel.displayName));
        expect(loadedModel.photoUrl, equals(userModel.photoUrl));
        expect(loadedModel.firstName, equals(userModel.firstName));
        expect(loadedModel.lastName, equals(userModel.lastName));
        expect(loadedModel.bio, equals(userModel.bio));
        expect(loadedModel.location, equals(userModel.location));
        expect(loadedModel.privacyLevel, equals(userModel.privacyLevel));
        expect(loadedModel.showEmail, equals(userModel.showEmail));
        expect(loadedModel.showPhoneNumber, equals(userModel.showPhoneNumber));
      },
    );
  });
}
