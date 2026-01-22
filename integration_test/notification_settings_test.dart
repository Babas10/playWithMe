// Integration test for notification settings
// Tests real Firebase Firestore interactions for notification preferences using Firebase Emulator

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

  group('Notification Preferences Reading', () {
    late String userId;

    Future<void> createTestUser() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'notiftest@test.com',
        password: 'password123',
        displayName: 'Notification Tester',
      );
      userId = user.uid;
    }

    test(
      'User without notification preferences gets default values',
      () async {
        await createTestUser();

        final firestore = FirebaseFirestore.instance;
        final userDoc = await firestore.collection('users').doc(userId).get();

        // User document exists but may not have notification preferences yet
        expect(userDoc.exists, isTrue);

        // notificationPreferences should be null or not exist
        final prefs = userDoc.data()?['notificationPreferences'];
        expect(prefs, isNull);
      },
    );

    test(
      'User can read their notification preferences',
      () async {
        await createTestUser();

        final firestore = FirebaseFirestore.instance;

        // Set initial notification preferences
        await firestore.collection('users').doc(userId).update({
          'notificationPreferences': {
            'groupInvitations': true,
            'invitationAccepted': true,
            'gameCreated': true,
            'memberJoined': false,
            'memberLeft': false,
            'roleChanged': true,
            'friendRequestReceived': true,
            'friendRequestAccepted': true,
            'friendRemoved': false,
            'quietHoursEnabled': false,
            'trainingSessionCreated': true,
            'trainingMinParticipantsReached': true,
            'trainingFeedbackReceived': true,
            'trainingSessionCancelled': true,
          },
        });

        // Read preferences
        final userDoc = await firestore.collection('users').doc(userId).get();
        final prefs =
            userDoc.data()?['notificationPreferences'] as Map<String, dynamic>;

        expect(prefs['groupInvitations'], isTrue);
        expect(prefs['memberJoined'], isFalse);
        expect(prefs['trainingSessionCreated'], isTrue);
      },
    );
  });

  group('Notification Preferences Toggling', () {
    late String userId;

    Future<void> createTestUserWithPreferences() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'toggletest@test.com',
        password: 'password123',
        displayName: 'Toggle Tester',
      );
      userId = user.uid;

      // Set initial preferences
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('users').doc(userId).update({
        'notificationPreferences': {
          'groupInvitations': true,
          'invitationAccepted': true,
          'gameCreated': true,
          'memberJoined': false,
          'memberLeft': false,
          'roleChanged': true,
          'friendRequestReceived': true,
          'friendRequestAccepted': true,
          'friendRemoved': false,
          'quietHoursEnabled': false,
          'trainingSessionCreated': true,
          'trainingMinParticipantsReached': true,
          'trainingFeedbackReceived': true,
          'trainingSessionCancelled': true,
        },
      });
    }

    test(
      'User can toggle groupInvitations preference',
      () async {
        await createTestUserWithPreferences();

        final firestore = FirebaseFirestore.instance;

        // Toggle groupInvitations to false
        await firestore.collection('users').doc(userId).update({
          'notificationPreferences.groupInvitations': false,
        });

        final userDoc = await firestore.collection('users').doc(userId).get();
        final prefs =
            userDoc.data()?['notificationPreferences'] as Map<String, dynamic>;

        expect(prefs['groupInvitations'], isFalse);
      },
    );

    test(
      'User can toggle gameCreated preference',
      () async {
        await createTestUserWithPreferences();

        final firestore = FirebaseFirestore.instance;

        // Toggle gameCreated to false
        await firestore.collection('users').doc(userId).update({
          'notificationPreferences.gameCreated': false,
        });

        final userDoc = await firestore.collection('users').doc(userId).get();
        final prefs =
            userDoc.data()?['notificationPreferences'] as Map<String, dynamic>;

        expect(prefs['gameCreated'], isFalse);
      },
    );

    test(
      'User can toggle memberJoined preference',
      () async {
        await createTestUserWithPreferences();

        final firestore = FirebaseFirestore.instance;

        // Toggle memberJoined to true (was false)
        await firestore.collection('users').doc(userId).update({
          'notificationPreferences.memberJoined': true,
        });

        final userDoc = await firestore.collection('users').doc(userId).get();
        final prefs =
            userDoc.data()?['notificationPreferences'] as Map<String, dynamic>;

        expect(prefs['memberJoined'], isTrue);
      },
    );

    test(
      'User can toggle training session notification preferences',
      () async {
        await createTestUserWithPreferences();

        final firestore = FirebaseFirestore.instance;

        // Toggle training notification preferences
        await firestore.collection('users').doc(userId).update({
          'notificationPreferences.trainingSessionCreated': false,
          'notificationPreferences.trainingMinParticipantsReached': false,
          'notificationPreferences.trainingFeedbackReceived': false,
          'notificationPreferences.trainingSessionCancelled': false,
        });

        final userDoc = await firestore.collection('users').doc(userId).get();
        final prefs =
            userDoc.data()?['notificationPreferences'] as Map<String, dynamic>;

        expect(prefs['trainingSessionCreated'], isFalse);
        expect(prefs['trainingMinParticipantsReached'], isFalse);
        expect(prefs['trainingFeedbackReceived'], isFalse);
        expect(prefs['trainingSessionCancelled'], isFalse);
      },
    );

    test(
      'Toggling one preference does not affect others',
      () async {
        await createTestUserWithPreferences();

        final firestore = FirebaseFirestore.instance;

        // Toggle only gameCreated
        await firestore.collection('users').doc(userId).update({
          'notificationPreferences.gameCreated': false,
        });

        final userDoc = await firestore.collection('users').doc(userId).get();
        final prefs =
            userDoc.data()?['notificationPreferences'] as Map<String, dynamic>;

        // gameCreated should be false
        expect(prefs['gameCreated'], isFalse);

        // Other preferences should remain unchanged
        expect(prefs['groupInvitations'], isTrue);
        expect(prefs['invitationAccepted'], isTrue);
        expect(prefs['friendRequestReceived'], isTrue);
      },
    );
  });

  group('Notification Preferences Persistence', () {
    late String userId;

    Future<void> createTestUser() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'persisttest@test.com',
        password: 'password123',
        displayName: 'Persist Tester',
      );
      userId = user.uid;
    }

    test(
      'Notification preferences are saved to Firestore correctly',
      () async {
        await createTestUser();

        final firestore = FirebaseFirestore.instance;

        // Save complete preferences
        final prefsToSave = {
          'groupInvitations': true,
          'invitationAccepted': false,
          'gameCreated': true,
          'memberJoined': true,
          'memberLeft': false,
          'roleChanged': true,
          'friendRequestReceived': false,
          'friendRequestAccepted': true,
          'friendRemoved': true,
          'quietHoursEnabled': true,
          'quietHoursStart': '22:00',
          'quietHoursEnd': '08:00',
          'trainingSessionCreated': true,
          'trainingMinParticipantsReached': false,
          'trainingFeedbackReceived': true,
          'trainingSessionCancelled': false,
          'groupSpecific': {
            'group-123': true,
            'group-456': false,
          },
        };

        await firestore.collection('users').doc(userId).update({
          'notificationPreferences': prefsToSave,
        });

        // Read back and verify
        final userDoc = await firestore.collection('users').doc(userId).get();
        final prefs =
            userDoc.data()?['notificationPreferences'] as Map<String, dynamic>;

        expect(prefs['groupInvitations'], isTrue);
        expect(prefs['invitationAccepted'], isFalse);
        expect(prefs['quietHoursEnabled'], isTrue);
        expect(prefs['quietHoursStart'], equals('22:00'));
        expect(prefs['quietHoursEnd'], equals('08:00'));
        expect(prefs['trainingSessionCreated'], isTrue);
        expect(prefs['trainingMinParticipantsReached'], isFalse);
      },
    );

    test(
      'Preferences persist after sign out and sign in',
      () async {
        await createTestUser();

        final firestore = FirebaseFirestore.instance;

        // Save preferences
        await firestore.collection('users').doc(userId).update({
          'notificationPreferences': {
            'groupInvitations': false,
            'gameCreated': false,
            'quietHoursEnabled': true,
          },
        });

        // Sign out
        await FirebaseEmulatorHelper.signOut();

        // Sign back in
        await FirebaseEmulatorHelper.signIn(
          email: 'persisttest@test.com',
          password: 'password123',
        );

        // Read preferences
        final userDoc = await firestore.collection('users').doc(userId).get();
        final prefs =
            userDoc.data()?['notificationPreferences'] as Map<String, dynamic>;

        // Verify preferences persisted
        expect(prefs['groupInvitations'], isFalse);
        expect(prefs['gameCreated'], isFalse);
        expect(prefs['quietHoursEnabled'], isTrue);
      },
    );

    test(
      'Group-specific notification settings are saved correctly',
      () async {
        await createTestUser();

        final firestore = FirebaseFirestore.instance;

        // Create a group
        final groupId = await FirebaseEmulatorHelper.createTestGroup(
          createdBy: userId,
          name: 'Notification Test Group',
        );

        // Save group-specific preferences
        await firestore.collection('users').doc(userId).update({
          'notificationPreferences': {
            'groupSpecific': {
              groupId: false,
            },
          },
        });

        final userDoc = await firestore.collection('users').doc(userId).get();
        final prefs =
            userDoc.data()?['notificationPreferences'] as Map<String, dynamic>;
        final groupSpecific = prefs['groupSpecific'] as Map<String, dynamic>?;

        expect(groupSpecific?[groupId], isFalse);
      },
    );
  });

  group('Quiet Hours Settings', () {
    late String userId;

    Future<void> createTestUser() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'quiettest@test.com',
        password: 'password123',
        displayName: 'Quiet Hours Tester',
      );
      userId = user.uid;
    }

    test(
      'User can enable quiet hours',
      () async {
        await createTestUser();

        final firestore = FirebaseFirestore.instance;

        await firestore.collection('users').doc(userId).update({
          'notificationPreferences': {
            'quietHoursEnabled': true,
            'quietHoursStart': '22:00',
            'quietHoursEnd': '07:00',
          },
        });

        final userDoc = await firestore.collection('users').doc(userId).get();
        final prefs =
            userDoc.data()?['notificationPreferences'] as Map<String, dynamic>;

        expect(prefs['quietHoursEnabled'], isTrue);
        expect(prefs['quietHoursStart'], equals('22:00'));
        expect(prefs['quietHoursEnd'], equals('07:00'));
      },
    );

    test(
      'User can disable quiet hours',
      () async {
        await createTestUser();

        final firestore = FirebaseFirestore.instance;

        // Enable quiet hours first
        await firestore.collection('users').doc(userId).update({
          'notificationPreferences': {
            'quietHoursEnabled': true,
            'quietHoursStart': '22:00',
            'quietHoursEnd': '07:00',
          },
        });

        // Disable quiet hours
        await firestore.collection('users').doc(userId).update({
          'notificationPreferences.quietHoursEnabled': false,
        });

        final userDoc = await firestore.collection('users').doc(userId).get();
        final prefs =
            userDoc.data()?['notificationPreferences'] as Map<String, dynamic>;

        expect(prefs['quietHoursEnabled'], isFalse);
        // Time values may still exist but quiet hours is disabled
      },
    );

    test(
      'User can update quiet hours time range',
      () async {
        await createTestUser();

        final firestore = FirebaseFirestore.instance;

        // Set initial quiet hours
        await firestore.collection('users').doc(userId).update({
          'notificationPreferences': {
            'quietHoursEnabled': true,
            'quietHoursStart': '22:00',
            'quietHoursEnd': '07:00',
          },
        });

        // Update time range
        await firestore.collection('users').doc(userId).update({
          'notificationPreferences.quietHoursStart': '23:00',
          'notificationPreferences.quietHoursEnd': '06:00',
        });

        final userDoc = await firestore.collection('users').doc(userId).get();
        final prefs =
            userDoc.data()?['notificationPreferences'] as Map<String, dynamic>;

        expect(prefs['quietHoursStart'], equals('23:00'));
        expect(prefs['quietHoursEnd'], equals('06:00'));
      },
    );
  });

  group('Complete Notification Preferences Update', () {
    late String userId;

    Future<void> createTestUser() async {
      final user = await FirebaseEmulatorHelper.createCompleteTestUser(
        email: 'completetest@test.com',
        password: 'password123',
        displayName: 'Complete Update Tester',
      );
      userId = user.uid;
    }

    test(
      'User can save complete notification preferences object',
      () async {
        await createTestUser();

        final firestore = FirebaseFirestore.instance;

        // Save complete preferences (as the app would do)
        final completePrefs = {
          'groupInvitations': true,
          'invitationAccepted': true,
          'gameCreated': true,
          'memberJoined': false,
          'memberLeft': false,
          'roleChanged': true,
          'friendRequestReceived': true,
          'friendRequestAccepted': true,
          'friendRemoved': false,
          'quietHoursEnabled': false,
          'quietHoursStart': null,
          'quietHoursEnd': null,
          'groupSpecific': <String, bool>{},
          'trainingSessionCreated': true,
          'trainingMinParticipantsReached': true,
          'trainingFeedbackReceived': true,
          'trainingSessionCancelled': true,
        };

        await firestore.collection('users').doc(userId).update({
          'notificationPreferences': completePrefs,
        });

        // Verify all fields saved
        final userDoc = await firestore.collection('users').doc(userId).get();
        final prefs =
            userDoc.data()?['notificationPreferences'] as Map<String, dynamic>;

        expect(prefs['groupInvitations'], isTrue);
        expect(prefs['invitationAccepted'], isTrue);
        expect(prefs['gameCreated'], isTrue);
        expect(prefs['memberJoined'], isFalse);
        expect(prefs['memberLeft'], isFalse);
        expect(prefs['roleChanged'], isTrue);
        expect(prefs['friendRequestReceived'], isTrue);
        expect(prefs['friendRequestAccepted'], isTrue);
        expect(prefs['friendRemoved'], isFalse);
        expect(prefs['quietHoursEnabled'], isFalse);
        expect(prefs['trainingSessionCreated'], isTrue);
        expect(prefs['trainingMinParticipantsReached'], isTrue);
        expect(prefs['trainingFeedbackReceived'], isTrue);
        expect(prefs['trainingSessionCancelled'], isTrue);
      },
    );

    test(
      'Updating preferences replaces existing values',
      () async {
        await createTestUser();

        final firestore = FirebaseFirestore.instance;

        // Set initial preferences
        await firestore.collection('users').doc(userId).update({
          'notificationPreferences': {
            'groupInvitations': true,
            'gameCreated': true,
          },
        });

        // Update with new preferences (replaces entire object)
        await firestore.collection('users').doc(userId).update({
          'notificationPreferences': {
            'groupInvitations': false,
            'gameCreated': false,
            'memberJoined': true,
          },
        });

        final userDoc = await firestore.collection('users').doc(userId).get();
        final prefs =
            userDoc.data()?['notificationPreferences'] as Map<String, dynamic>;

        expect(prefs['groupInvitations'], isFalse);
        expect(prefs['gameCreated'], isFalse);
        expect(prefs['memberJoined'], isTrue);
      },
    );
  });
}
