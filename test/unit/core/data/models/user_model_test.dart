// Tests all UserModel business logic methods and JSON serialization/deserialization
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    late UserModel testUser;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2023, 12, 1, 12, 0, 0);
      testUser = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        isEmailVerified: true,
        createdAt: testDate,
        lastSignInAt: testDate,
        updatedAt: testDate,
        isAnonymous: false,
        firstName: 'Test',
        lastName: 'User',
        phoneNumber: '+1234567890',
        dateOfBirth: DateTime(1990, 1, 1),
        location: 'Test City',
        bio: 'Test bio',
        groupIds: ['group1', 'group2'],
        gameIds: ['game1', 'game2'],
        notificationsEnabled: true,
        emailNotifications: true,
        pushNotifications: false,
        privacyLevel: UserPrivacyLevel.public,
        showEmail: true,
        showPhoneNumber: false,
        gamesPlayed: 10,
        gamesWon: 7,
        totalScore: 150,
      );
    });

    group('Factory constructors', () {
      test('creates UserModel with required fields only', () {
        const user = UserModel(
          uid: 'uid',
          email: 'email@test.com',
          isEmailVerified: false,
          isAnonymous: true,
        );

        expect(user.uid, 'uid');
        expect(user.email, 'email@test.com');
        expect(user.isEmailVerified, false);
        expect(user.isAnonymous, true);
        expect(user.displayName, null);
        expect(user.photoUrl, null);
        expect(user.createdAt, null);
        expect(user.lastSignInAt, null);
        expect(user.updatedAt, null);
        expect(user.firstName, null);
        expect(user.lastName, null);
        expect(user.phoneNumber, null);
        expect(user.dateOfBirth, null);
        expect(user.location, null);
        expect(user.bio, null);
        expect(user.groupIds, []);
        expect(user.gameIds, []);
        expect(user.notificationsEnabled, true);
        expect(user.emailNotifications, true);
        expect(user.pushNotifications, true);
        expect(user.privacyLevel, UserPrivacyLevel.public);
        expect(user.showEmail, true);
        expect(user.showPhoneNumber, true);
        expect(user.gamesPlayed, 0);
        expect(user.gamesWon, 0);
        expect(user.totalScore, 0);
      });

      test('fromFirestore creates UserModel from DocumentSnapshot', () {
        // Mock DocumentSnapshot data
        final data = {
          'email': 'test@example.com',
          'displayName': 'Test User',
          'isEmailVerified': true,
          'isAnonymous': false,
          'firstName': 'Test',
          'lastName': 'User',
          'gamesPlayed': 5,
        };

        // Create a mock DocumentSnapshot
        final mockDoc = MockDocumentSnapshot('test-uid', data);
        final user = UserModel.fromFirestore(mockDoc);

        expect(user.uid, 'test-uid');
        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');
        expect(user.isEmailVerified, true);
        expect(user.isAnonymous, false);
        expect(user.firstName, 'Test');
        expect(user.lastName, 'User');
        expect(user.gamesPlayed, 5);
      });
    });

    group('JSON serialization', () {
      test('toJson serializes all fields correctly', () {
        final json = testUser.toJson();

        expect(json['uid'], 'test-uid');
        expect(json['email'], 'test@example.com');
        expect(json['displayName'], 'Test User');
        expect(json['photoUrl'], 'https://example.com/photo.jpg');
        expect(json['isEmailVerified'], true);
        expect(json['isAnonymous'], false);
        expect(json['firstName'], 'Test');
        expect(json['lastName'], 'User');
        expect(json['phoneNumber'], '+1234567890');
        expect(json['location'], 'Test City');
        expect(json['bio'], 'Test bio');
        expect(json['groupIds'], ['group1', 'group2']);
        expect(json['gameIds'], ['game1', 'game2']);
        expect(json['notificationsEnabled'], true);
        expect(json['emailNotifications'], true);
        expect(json['pushNotifications'], false);
        expect(json['privacyLevel'], 'public');
        expect(json['showEmail'], true);
        expect(json['showPhoneNumber'], false);
        expect(json['gamesPlayed'], 10);
        expect(json['gamesWon'], 7);
        expect(json['totalScore'], 150);
      });

      test('fromJson deserializes all fields correctly', () {
        final json = {
          'uid': 'test-uid',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'photoUrl': 'https://example.com/photo.jpg',
          'isEmailVerified': true,
          'createdAt': Timestamp.fromDate(testDate),
          'lastSignInAt': Timestamp.fromDate(testDate),
          'updatedAt': Timestamp.fromDate(testDate),
          'isAnonymous': false,
          'firstName': 'Test',
          'lastName': 'User',
          'phoneNumber': '+1234567890',
          'dateOfBirth': testDate.toIso8601String(),
          'location': 'Test City',
          'bio': 'Test bio',
          'groupIds': ['group1', 'group2'],
          'gameIds': ['game1', 'game2'],
          'notificationsEnabled': true,
          'emailNotifications': true,
          'pushNotifications': false,
          'privacyLevel': 'public',
          'showEmail': true,
          'showPhoneNumber': false,
          'gamesPlayed': 10,
          'gamesWon': 7,
          'totalScore': 150,
        };

        final user = UserModel.fromJson(json);

        expect(user.uid, 'test-uid');
        expect(user.email, 'test@example.com');
        expect(user.displayName, 'Test User');
        expect(user.photoUrl, 'https://example.com/photo.jpg');
        expect(user.isEmailVerified, true);
        expect(user.createdAt, testDate);
        expect(user.lastSignInAt, testDate);
        expect(user.updatedAt, testDate);
        expect(user.isAnonymous, false);
        expect(user.firstName, 'Test');
        expect(user.lastName, 'User');
        expect(user.phoneNumber, '+1234567890');
        expect(user.location, 'Test City');
        expect(user.bio, 'Test bio');
        expect(user.groupIds, ['group1', 'group2']);
        expect(user.gameIds, ['game1', 'game2']);
        expect(user.notificationsEnabled, true);
        expect(user.emailNotifications, true);
        expect(user.pushNotifications, false);
        expect(user.privacyLevel, UserPrivacyLevel.public);
        expect(user.showEmail, true);
        expect(user.showPhoneNumber, false);
        expect(user.gamesPlayed, 10);
        expect(user.gamesWon, 7);
        expect(user.totalScore, 150);
      });

      test('toFirestore excludes uid field', () {
        final firestoreData = testUser.toFirestore();

        expect(firestoreData.containsKey('uid'), false);
        expect(firestoreData['email'], 'test@example.com');
        expect(firestoreData['displayName'], 'Test User');
      });
    });

    group('Business logic methods', () {
      test('hasCompleteProfile returns true when profile is complete', () {
        expect(testUser.hasCompleteProfile, true);
      });

      test('hasCompleteProfile returns false when displayName is missing', () {
        final incompleteUser = testUser.copyWith(displayName: null);
        expect(incompleteUser.hasCompleteProfile, false);
      });

      test('hasCompleteProfile returns false when firstName is missing', () {
        final incompleteUser = testUser.copyWith(firstName: null);
        expect(incompleteUser.hasCompleteProfile, false);
      });

      test('hasCompleteProfile returns false when lastName is missing', () {
        final incompleteUser = testUser.copyWith(lastName: null);
        expect(incompleteUser.hasCompleteProfile, false);
      });

      test('fullDisplayName returns full name when available', () {
        expect(testUser.fullDisplayName, 'Test User');
      });

      test('fullDisplayName returns displayName when first/last name unavailable', () {
        final user = testUser.copyWith(firstName: null, lastName: null);
        expect(user.fullDisplayName, 'Test User');
      });

      test('fullDisplayName returns email when no names available', () {
        final user = testUser.copyWith(
          displayName: null,
          firstName: null,
          lastName: null,
        );
        expect(user.fullDisplayName, 'test@example.com');
      });

      test('displayNameOrEmail returns displayName when available', () {
        expect(testUser.displayNameOrEmail, 'Test User');
      });

      test('displayNameOrEmail returns email when displayName is null', () {
        final user = testUser.copyWith(displayName: null);
        expect(user.displayNameOrEmail, 'test@example.com');
      });

      test('canBeContacted returns true when email is shown and not private', () {
        final user = testUser.copyWith(
          showEmail: true,
          privacyLevel: UserPrivacyLevel.public,
        );
        expect(user.canBeContacted, true);
      });

      test('canBeContacted returns true when phone is shown and not private', () {
        final user = testUser.copyWith(
          showEmail: false,
          showPhoneNumber: true,
          privacyLevel: UserPrivacyLevel.public,
        );
        expect(user.canBeContacted, true);
      });

      test('canBeContacted returns false when private', () {
        final user = testUser.copyWith(
          showEmail: true,
          showPhoneNumber: true,
          privacyLevel: UserPrivacyLevel.private,
        );
        expect(user.canBeContacted, false);
      });

      test('canBeContacted returns false when no contact info is shown', () {
        final user = testUser.copyWith(
          showEmail: false,
          showPhoneNumber: false,
          privacyLevel: UserPrivacyLevel.public,
        );
        expect(user.canBeContacted, false);

        // Also test when phone number is null
        final userNoPhone = testUser.copyWith(
          showEmail: false,
          showPhoneNumber: true,
          phoneNumber: null,
          privacyLevel: UserPrivacyLevel.public,
        );
        expect(userNoPhone.canBeContacted, false);
      });

      test('winRate calculates correctly', () {
        expect(testUser.winRate, 0.7); // 7 wins out of 10 games
      });

      test('winRate returns 0 when no games played', () {
        final user = testUser.copyWith(gamesPlayed: 0, gamesWon: 0);
        expect(user.winRate, 0.0);
      });

      test('averageScore calculates correctly', () {
        expect(testUser.averageScore, 15.0); // 150 total score / 10 games
      });

      test('averageScore returns 0 when no games played', () {
        final user = testUser.copyWith(gamesPlayed: 0, totalScore: 0);
        expect(user.averageScore, 0.0);
      });

      test('hasValidEmail returns true for valid email', () {
        expect(testUser.hasValidEmail, true);
      });

      test('hasValidEmail returns false for invalid email', () {
        final user = testUser.copyWith(email: 'invalid-email');
        expect(user.hasValidEmail, false);

        final emptyEmailUser = testUser.copyWith(email: '');
        expect(emptyEmailUser.hasValidEmail, false);
      });

      test('isActive returns true when last sign in is recent', () {
        final recentUser = testUser.copyWith(
          lastSignInAt: DateTime.now().subtract(const Duration(days: 15)),
        );
        expect(recentUser.isActive, true);
      });

      test('isActive returns false when last sign in is old', () {
        final oldUser = testUser.copyWith(
          lastSignInAt: DateTime.now().subtract(const Duration(days: 35)),
        );
        expect(oldUser.isActive, false);
      });

      test('isActive returns false when lastSignInAt is null', () {
        final user = testUser.copyWith(lastSignInAt: null);
        expect(user.isActive, false);
      });
    });

    group('Update methods', () {
      test('updateProfile updates profile fields and updatedAt', () {
        final originalUpdatedAt = testUser.updatedAt;

        // Wait a bit to ensure different timestamp
        Future.delayed(const Duration(milliseconds: 1));

        final updatedUser = testUser.updateProfile(
          displayName: 'Updated Name',
          firstName: 'Updated',
          lastName: 'Name',
          phoneNumber: '+9876543210',
          location: 'New City',
          bio: 'Updated bio',
          dateOfBirth: DateTime(1995, 1, 1),
        );

        expect(updatedUser.displayName, 'Updated Name');
        expect(updatedUser.firstName, 'Updated');
        expect(updatedUser.lastName, 'Name');
        expect(updatedUser.phoneNumber, '+9876543210');
        expect(updatedUser.location, 'New City');
        expect(updatedUser.bio, 'Updated bio');
        expect(updatedUser.dateOfBirth, DateTime(1995, 1, 1));
        expect(updatedUser.updatedAt!.isAfter(originalUpdatedAt!), true);
      });

      test('updateProfile keeps existing values when not provided', () {
        final updatedUser = testUser.updateProfile(displayName: 'New Name');

        expect(updatedUser.displayName, 'New Name');
        expect(updatedUser.firstName, testUser.firstName);
        expect(updatedUser.lastName, testUser.lastName);
        expect(updatedUser.phoneNumber, testUser.phoneNumber);
        expect(updatedUser.location, testUser.location);
        expect(updatedUser.bio, testUser.bio);
        expect(updatedUser.dateOfBirth, testUser.dateOfBirth);
      });

      test('updatePreferences updates notification settings', () {
        final updatedUser = testUser.updatePreferences(
          notificationsEnabled: false,
          emailNotifications: false,
          pushNotifications: true,
        );

        expect(updatedUser.notificationsEnabled, false);
        expect(updatedUser.emailNotifications, false);
        expect(updatedUser.pushNotifications, true);
      });

      test('updatePrivacy updates privacy settings', () {
        final updatedUser = testUser.updatePrivacy(
          privacyLevel: UserPrivacyLevel.private,
          showEmail: false,
          showPhoneNumber: true,
        );

        expect(updatedUser.privacyLevel, UserPrivacyLevel.private);
        expect(updatedUser.showEmail, false);
        expect(updatedUser.showPhoneNumber, true);
      });

      test('joinGroup adds group to groupIds', () {
        final updatedUser = testUser.joinGroup('group3');

        expect(updatedUser.groupIds, ['group1', 'group2', 'group3']);
      });

      test('joinGroup does not add duplicate group', () {
        final updatedUser = testUser.joinGroup('group1');

        expect(updatedUser.groupIds, ['group1', 'group2']);
      });

      test('leaveGroup removes group from groupIds', () {
        final updatedUser = testUser.leaveGroup('group1');

        expect(updatedUser.groupIds, ['group2']);
      });

      test('leaveGroup does nothing when group not in list', () {
        final updatedUser = testUser.leaveGroup('nonexistent');

        expect(updatedUser.groupIds, ['group1', 'group2']);
      });

      test('addGame updates game stats correctly', () {
        final updatedUser = testUser.addGame('game3', won: true, score: 25);

        expect(updatedUser.gameIds, ['game1', 'game2', 'game3']);
        expect(updatedUser.gamesPlayed, 11);
        expect(updatedUser.gamesWon, 8);
        expect(updatedUser.totalScore, 175);
      });

      test('addGame with loss updates stats correctly', () {
        final updatedUser = testUser.addGame('game3', won: false, score: 15);

        expect(updatedUser.gameIds, ['game1', 'game2', 'game3']);
        expect(updatedUser.gamesPlayed, 11);
        expect(updatedUser.gamesWon, 7); // No change in wins
        expect(updatedUser.totalScore, 165);
      });

      test('addGame does not add duplicate game', () {
        final updatedUser = testUser.addGame('game1', won: true, score: 20);

        expect(updatedUser.gameIds, ['game1', 'game2']);
        expect(updatedUser.gamesPlayed, 11); // Still increments
        expect(updatedUser.gamesWon, 8);
        expect(updatedUser.totalScore, 170);
      });
    });

    group('Privacy level enum', () {
      test('UserPrivacyLevel enum has correct JSON values', () {
        expect(UserPrivacyLevel.public.toString(), 'UserPrivacyLevel.public');
        expect(UserPrivacyLevel.friends.toString(), 'UserPrivacyLevel.friends');
        expect(UserPrivacyLevel.private.toString(), 'UserPrivacyLevel.private');
      });
    });

    group('TimestampConverter', () {
      test('converts Timestamp to DateTime', () {
        const converter = TimestampConverter();
        final timestamp = Timestamp.fromDate(testDate);

        final result = converter.fromJson(timestamp);

        expect(result, testDate);
      });

      test('converts String to DateTime', () {
        const converter = TimestampConverter();
        final dateString = testDate.toIso8601String();

        final result = converter.fromJson(dateString);

        expect(result, testDate);
      });

      test('converts int (milliseconds) to DateTime', () {
        const converter = TimestampConverter();
        final milliseconds = testDate.millisecondsSinceEpoch;

        final result = converter.fromJson(milliseconds);

        expect(result, testDate);
      });

      test('returns null for null input', () {
        const converter = TimestampConverter();

        final result = converter.fromJson(null);

        expect(result, null);
      });

      test('converts DateTime to Timestamp', () {
        const converter = TimestampConverter();

        final result = converter.toJson(testDate);

        expect(result, isA<Timestamp>());
        expect((result as Timestamp).toDate(), testDate);
      });

      test('returns null when converting null DateTime', () {
        const converter = TimestampConverter();

        final result = converter.toJson(null);

        expect(result, null);
      });
    });
  });
}

// Mock DocumentSnapshot for testing
class MockDocumentSnapshot implements DocumentSnapshot {
  final String _id;
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => true;

  // Implement other required methods as no-ops for testing
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}