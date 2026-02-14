// Tests all UserModel business logic methods and JSON serialization/deserialization
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/domain/entities/account_status.dart';

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
        // Account status fields (Story 17.8.2)
        expect(user.emailVerifiedAt, null);
        expect(user.accountStatus, AccountStatus.pendingVerification);
        expect(user.gracePeriodExpiresAt, null);
        expect(user.deletionScheduledAt, null);
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

    // Story 11.6: Tests for friend cache methods
    group('Friend cache methods (Story 11.6)', () {
      test('addFriend adds friend to friendIds and increments count', () {
        final user = testUser.copyWith(friendIds: [], friendCount: 0);
        final updatedUser = user.addFriend('friend1');

        expect(updatedUser.friendIds, ['friend1']);
        expect(updatedUser.friendCount, 1);
        expect(updatedUser.friendsLastUpdated, isNotNull);
      });

      test('addFriend does not add duplicate friend', () {
        final user = testUser.copyWith(
          friendIds: ['friend1'],
          friendCount: 1,
        );
        final updatedUser = user.addFriend('friend1');

        expect(updatedUser.friendIds, ['friend1']);
        expect(updatedUser.friendCount, 1);
        expect(updatedUser, equals(user));
      });

      test('addFriend updates friendsLastUpdated timestamp', () {
        final user = testUser.copyWith(
          friendIds: [],
          friendCount: 0,
          friendsLastUpdated: DateTime(2023, 1, 1),
        );

        final updatedUser = user.addFriend('friend1');

        expect(updatedUser.friendsLastUpdated, isNotNull);
        expect(
          updatedUser.friendsLastUpdated!.isAfter(DateTime(2023, 1, 1)),
          true,
        );
      });

      test('removeFriend removes friend from friendIds and decrements count', () {
        final user = testUser.copyWith(
          friendIds: ['friend1', 'friend2'],
          friendCount: 2,
        );
        final updatedUser = user.removeFriend('friend1');

        expect(updatedUser.friendIds, ['friend2']);
        expect(updatedUser.friendCount, 1);
        expect(updatedUser.friendsLastUpdated, isNotNull);
      });

      test('removeFriend does nothing when friend not in list', () {
        final user = testUser.copyWith(
          friendIds: ['friend1'],
          friendCount: 1,
        );
        final updatedUser = user.removeFriend('friend2');

        expect(updatedUser.friendIds, ['friend1']);
        expect(updatedUser.friendCount, 1);
        expect(updatedUser, equals(user));
      });

      test('removeFriend does not go below zero count', () {
        final user = testUser.copyWith(
          friendIds: ['friend1'],
          friendCount: 0, // Manually set to 0 (inconsistent state)
        );
        final updatedUser = user.removeFriend('friend1');

        expect(updatedUser.friendIds, isEmpty);
        expect(updatedUser.friendCount, 0);
      });

      test('removeFriend updates friendsLastUpdated timestamp', () {
        final user = testUser.copyWith(
          friendIds: ['friend1'],
          friendCount: 1,
          friendsLastUpdated: DateTime(2023, 1, 1),
        );

        final updatedUser = user.removeFriend('friend1');

        expect(updatedUser.friendsLastUpdated, isNotNull);
        expect(
          updatedUser.friendsLastUpdated!.isAfter(DateTime(2023, 1, 1)),
          true,
        );
      });

      test('isFriend returns true when userId is in friendIds', () {
        final user = testUser.copyWith(
          friendIds: ['friend1', 'friend2', 'friend3'],
        );

        expect(user.isFriend('friend1'), true);
        expect(user.isFriend('friend2'), true);
        expect(user.isFriend('friend3'), true);
      });

      test('isFriend returns false when userId is not in friendIds', () {
        final user = testUser.copyWith(
          friendIds: ['friend1', 'friend2'],
        );

        expect(user.isFriend('friend3'), false);
        expect(user.isFriend('nonexistent'), false);
      });

      test('needsFriendCacheRefresh returns true when friendsLastUpdated is null', () {
        final user = testUser.copyWith(friendsLastUpdated: null);

        expect(user.needsFriendCacheRefresh, true);
      });

      test('needsFriendCacheRefresh returns false when cache is fresh', () {
        final user = testUser.copyWith(
          friendsLastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
        );

        expect(user.needsFriendCacheRefresh, false);
      });

      test('needsFriendCacheRefresh returns true when cache is stale (>24 hours)', () {
        final user = testUser.copyWith(
          friendsLastUpdated: DateTime.now().subtract(const Duration(hours: 25)),
        );

        expect(user.needsFriendCacheRefresh, true);
      });

      test('needsFriendCacheRefresh returns false when exactly 24 hours old', () {
        final user = testUser.copyWith(
          friendsLastUpdated: DateTime.now().subtract(const Duration(hours: 24)),
        );

        // Should be false because we check for > 24 hours
        expect(user.needsFriendCacheRefresh, false);
      });
    });

    // Story 14.5.3: Tests for ELO rating fields
    group('ELO rating fields (Story 14.5.3)', () {
      test('has default ELO rating of 1600', () {
        const user = UserModel(
          uid: 'uid',
          email: 'email@test.com',
          isEmailVerified: false,
          isAnonymous: false,
        );

        expect(user.eloRating, 1600.0);
        expect(user.eloPeak, 1600.0);
        expect(user.eloGamesPlayed, 0);
        expect(user.eloLastUpdated, null);
        expect(user.eloPeakDate, null);
      });

      test('serializes ELO fields to JSON', () {
        final eloDate = DateTime(2024, 12, 6, 10, 30, 0);
        final user = testUser.copyWith(
          eloRating: 1650.5,
          eloPeak: 1700.0,
          eloGamesPlayed: 15,
          eloLastUpdated: eloDate,
          eloPeakDate: eloDate,
        );

        final json = user.toJson();

        expect(json['eloRating'], 1650.5);
        expect(json['eloPeak'], 1700.0);
        expect(json['eloGamesPlayed'], 15);
        expect(json['eloLastUpdated'], isA<Timestamp>());
        expect(json['eloPeakDate'], isA<Timestamp>());
      });

      test('deserializes ELO fields from JSON with Timestamp', () {
        final eloDate = DateTime(2024, 12, 6, 10, 30, 0);
        final json = {
          'uid': 'test-uid',
          'email': 'test@example.com',
          'isEmailVerified': true,
          'isAnonymous': false,
          'eloRating': 1725.0,
          'eloPeak': 1800.0,
          'eloGamesPlayed': 25,
          'eloLastUpdated': Timestamp.fromDate(eloDate),
          'eloPeakDate': Timestamp.fromDate(eloDate),
        };

        final user = UserModel.fromJson(json);

        expect(user.eloRating, 1725.0);
        expect(user.eloPeak, 1800.0);
        expect(user.eloGamesPlayed, 25);
        expect(user.eloLastUpdated, eloDate);
        expect(user.eloPeakDate, eloDate);
      });

      test('backward compatibility - missing ELO fields default correctly', () {
        // Simulates a user document created before ELO was implemented
        final json = {
          'uid': 'legacy-user',
          'email': 'legacy@test.com',
          'isEmailVerified': true,
          'isAnonymous': false,
          // No ELO fields
        };

        final user = UserModel.fromJson(json);

        expect(user.eloRating, 1600.0);
        expect(user.eloPeak, 1600.0);
        expect(user.eloGamesPlayed, 0);
        expect(user.eloLastUpdated, null);
        expect(user.eloPeakDate, null);
      });

      test('toFirestore includes ELO fields', () {
        final eloDate = DateTime(2024, 12, 6, 10, 30, 0);
        final user = testUser.copyWith(
          eloRating: 1550.0,
          eloPeak: 1600.0,
          eloGamesPlayed: 3,
          eloLastUpdated: eloDate,
          eloPeakDate: eloDate,
        );

        final firestoreData = user.toFirestore();

        expect(firestoreData['eloRating'], 1550.0);
        expect(firestoreData['eloPeak'], 1600.0);
        expect(firestoreData['eloGamesPlayed'], 3);
        expect(firestoreData['eloLastUpdated'], isA<Timestamp>());
        expect(firestoreData['eloPeakDate'], isA<Timestamp>());
        expect(firestoreData.containsKey('uid'), false);
      });

      test('fromFirestore parses ELO fields correctly', () {
        final eloDate = DateTime(2024, 12, 6, 10, 30, 0);
        final data = {
          'email': 'elo@test.com',
          'displayName': 'ELO Test User',
          'isEmailVerified': true,
          'isAnonymous': false,
          'eloRating': 1850.0,
          'eloPeak': 1900.0,
          'eloGamesPlayed': 42,
          'eloLastUpdated': Timestamp.fromDate(eloDate),
          'eloPeakDate': Timestamp.fromDate(eloDate),
        };

        final mockDoc = MockDocumentSnapshot('elo-test-uid', data);
        final user = UserModel.fromFirestore(mockDoc);

        expect(user.uid, 'elo-test-uid');
        expect(user.eloRating, 1850.0);
        expect(user.eloPeak, 1900.0);
        expect(user.eloGamesPlayed, 42);
        expect(user.eloLastUpdated, eloDate);
        expect(user.eloPeakDate, eloDate);
      });

      test('copyWith updates ELO fields correctly', () {
        final newDate = DateTime(2024, 12, 7, 14, 0, 0);
        final updatedUser = testUser.copyWith(
          eloRating: 1680.0,
          eloPeak: 1680.0,
          eloGamesPlayed: 10,
          eloLastUpdated: newDate,
          eloPeakDate: newDate,
        );

        expect(updatedUser.eloRating, 1680.0);
        expect(updatedUser.eloPeak, 1680.0);
        expect(updatedUser.eloGamesPlayed, 10);
        expect(updatedUser.eloLastUpdated, newDate);
        expect(updatedUser.eloPeakDate, newDate);
        // Other fields unchanged
        expect(updatedUser.uid, testUser.uid);
        expect(updatedUser.email, testUser.email);
      });

      test('handles decimal ELO ratings', () {
        final user = testUser.copyWith(
          eloRating: 1632.567,
          eloPeak: 1700.123,
        );

        expect(user.eloRating, 1632.567);
        expect(user.eloPeak, 1700.123);

        final json = user.toJson();
        final restored = UserModel.fromJson(json);

        expect(restored.eloRating, 1632.567);
        expect(restored.eloPeak, 1700.123);
      });
    });

    // Story 14.6: Tests for new player stats fields
    group('Player stats fields (Story 14.6)', () {
      test('has default values for new stats fields', () {
        const user = UserModel(
          uid: 'uid',
          email: 'email@test.com',
          isEmailVerified: false,
          isAnonymous: false,
        );

        expect(user.gamesLost, 0);
        expect(user.currentStreak, 0);
        expect(user.recentGameIds, []);
        expect(user.lastGameDate, null);
        expect(user.teammateStats, {});
      });

      test('lossRate calculates correctly', () {
        final user = testUser.copyWith(gamesPlayed: 10, gamesLost: 3);
        expect(user.lossRate, 0.3);
      });

      test('lossRate returns 0 when no games played', () {
        final user = testUser.copyWith(gamesPlayed: 0, gamesLost: 0);
        expect(user.lossRate, 0.0);
      });

      test('isOnWinningStreak returns true for positive streak', () {
        final user = testUser.copyWith(currentStreak: 5);
        expect(user.isOnWinningStreak, true);
        expect(user.isOnLosingStreak, false);
        expect(user.streakValue, 5);
      });

      test('isOnLosingStreak returns true for negative streak', () {
        final user = testUser.copyWith(currentStreak: -3);
        expect(user.isOnWinningStreak, false);
        expect(user.isOnLosingStreak, true);
        expect(user.streakValue, 3);
      });

      test('streak is zero for no streak', () {
        final user = testUser.copyWith(currentStreak: 0);
        expect(user.isOnWinningStreak, false);
        expect(user.isOnLosingStreak, false);
        expect(user.streakValue, 0);
      });

      test('serializes new stats fields to JSON', () {
        final lastGame = DateTime(2024, 12, 8, 10, 0, 0);
        final user = testUser.copyWith(
          gamesLost: 3,
          currentStreak: 5,
          recentGameIds: ['game1', 'game2', 'game3'],
          lastGameDate: lastGame,
          teammateStats: {
            'player1': {'gamesPlayed': 10, 'gamesWon': 7},
            'player2': {'gamesPlayed': 5, 'gamesWon': 3}
          },
        );

        final json = user.toJson();

        expect(json['gamesLost'], 3);
        expect(json['currentStreak'], 5);
        expect(json['recentGameIds'], ['game1', 'game2', 'game3']);
        expect(json['lastGameDate'], isA<Timestamp>());
        expect(json['teammateStats'], {
          'player1': {'gamesPlayed': 10, 'gamesWon': 7},
          'player2': {'gamesPlayed': 5, 'gamesWon': 3}
        });
      });

      test('deserializes new stats fields from JSON', () {
        final lastGame = DateTime(2024, 12, 8, 10, 0, 0);
        final json = {
          'uid': 'test-uid',
          'email': 'test@example.com',
          'isEmailVerified': true,
          'isAnonymous': false,
          'gamesLost': 2,
          'currentStreak': -2,
          'recentGameIds': ['game5', 'game4', 'game3'],
          'lastGameDate': Timestamp.fromDate(lastGame),
          'teammateStats': {
            'teammate1': {'gamesPlayed': 8, 'gamesWon': 6}
          },
        };

        final user = UserModel.fromJson(json);

        expect(user.gamesLost, 2);
        expect(user.currentStreak, -2);
        expect(user.recentGameIds, ['game5', 'game4', 'game3']);
        expect(user.lastGameDate, lastGame);
        expect(user.teammateStats, {
          'teammate1': {'gamesPlayed': 8, 'gamesWon': 6}
        });
      });

      test('backward compatibility - missing new stats fields default correctly', () {
        final json = {
          'uid': 'legacy-user',
          'email': 'legacy@test.com',
          'isEmailVerified': true,
          'isAnonymous': false,
          'gamesPlayed': 5,
          'gamesWon': 3,
          // No new stats fields
        };

        final user = UserModel.fromJson(json);

        expect(user.gamesPlayed, 5);
        expect(user.gamesWon, 3);
        expect(user.gamesLost, 0);
        expect(user.currentStreak, 0);
        expect(user.recentGameIds, []);
        expect(user.lastGameDate, null);
        expect(user.teammateStats, {});
      });

      test('toFirestore includes new stats fields', () {
        final lastGame = DateTime(2024, 12, 8, 10, 0, 0);
        final user = testUser.copyWith(
          gamesLost: 4,
          currentStreak: 3,
          recentGameIds: ['g1', 'g2'],
          lastGameDate: lastGame,
          teammateStats: {'p1': {'gamesPlayed': 2, 'gamesWon': 1}},
        );

        final firestoreData = user.toFirestore();

        expect(firestoreData['gamesLost'], 4);
        expect(firestoreData['currentStreak'], 3);
        expect(firestoreData['recentGameIds'], ['g1', 'g2']);
        expect(firestoreData['lastGameDate'], isA<Timestamp>());
        expect(firestoreData['teammateStats'], {'p1': {'gamesPlayed': 2, 'gamesWon': 1}});
        expect(firestoreData.containsKey('uid'), false);
      });

      test('fromFirestore parses new stats fields correctly', () {
        final lastGame = DateTime(2024, 12, 8, 15, 30, 0);
        final data = {
          'email': 'stats@test.com',
          'displayName': 'Stats Test User',
          'isEmailVerified': true,
          'isAnonymous': false,
          'gamesLost': 6,
          'currentStreak': -1,
          'recentGameIds': ['game-a', 'game-b', 'game-c'],
          'lastGameDate': Timestamp.fromDate(lastGame),
          'teammateStats': {
            'mate1': {'gamesPlayed': 15, 'gamesWon': 10},
            'mate2': {'gamesPlayed': 8, 'gamesWon': 8}
          },
        };

        final mockDoc = MockDocumentSnapshot('stats-test-uid', data);
        final user = UserModel.fromFirestore(mockDoc);

        expect(user.uid, 'stats-test-uid');
        expect(user.gamesLost, 6);
        expect(user.currentStreak, -1);
        expect(user.recentGameIds, ['game-a', 'game-b', 'game-c']);
        expect(user.lastGameDate, lastGame);
        expect(user.teammateStats, {
          'mate1': {'gamesPlayed': 15, 'gamesWon': 10},
          'mate2': {'gamesPlayed': 8, 'gamesWon': 8}
        });
      });

      test('copyWith updates new stats fields correctly', () {
        final newDate = DateTime(2024, 12, 9, 14, 0, 0);
        final updatedUser = testUser.copyWith(
          gamesLost: 5,
          currentStreak: 7,
          recentGameIds: ['new-g1', 'new-g2'],
          lastGameDate: newDate,
          teammateStats: {'new-mate': {'gamesPlayed': 1, 'gamesWon': 1}},
        );

        expect(updatedUser.gamesLost, 5);
        expect(updatedUser.currentStreak, 7);
        expect(updatedUser.recentGameIds, ['new-g1', 'new-g2']);
        expect(updatedUser.lastGameDate, newDate);
        expect(updatedUser.teammateStats, {'new-mate': {'gamesPlayed': 1, 'gamesWon': 1}});
        // Other fields unchanged
        expect(updatedUser.uid, testUser.uid);
        expect(updatedUser.email, testUser.email);
      });

      test('handles empty teammateStats map', () {
        final user = testUser.copyWith(teammateStats: {});
        expect(user.teammateStats, {});

        final json = user.toJson();
        final restored = UserModel.fromJson(json);

        expect(restored.teammateStats, {});
      });

      test('handles complex teammateStats structure', () {
        final stats = {
          'player-1': {'gamesPlayed': 20, 'gamesWon': 15},
          'player-2': {'gamesPlayed': 10, 'gamesWon': 8},
          'player-3': {'gamesPlayed': 5, 'gamesWon': 2}
        };

        final user = testUser.copyWith(teammateStats: stats);
        expect(user.teammateStats, stats);

        final json = user.toJson();
        final restored = UserModel.fromJson(json);

        expect(restored.teammateStats, stats);
      });
    });

    // Story 17.8.2: Tests for account status fields
    group('Account status fields (Story 17.8.2)', () {
      test('has default accountStatus of pendingVerification', () {
        const user = UserModel(
          uid: 'uid',
          email: 'email@test.com',
          isEmailVerified: false,
          isAnonymous: false,
        );

        expect(user.accountStatus, AccountStatus.pendingVerification);
        expect(user.emailVerifiedAt, null);
        expect(user.gracePeriodExpiresAt, null);
        expect(user.deletionScheduledAt, null);
      });

      test('serializes account status fields to JSON', () {
        final verifiedAt = DateTime(2024, 6, 1, 10, 0, 0);
        final graceExpires = DateTime(2024, 6, 8, 10, 0, 0);
        final user = testUser.copyWith(
          accountStatus: AccountStatus.active,
          emailVerifiedAt: verifiedAt,
          gracePeriodExpiresAt: graceExpires,
          deletionScheduledAt: null,
        );

        final json = user.toJson();

        expect(json['accountStatus'], 'active');
        expect(json['emailVerifiedAt'], isA<Timestamp>());
        expect(json['gracePeriodExpiresAt'], isA<Timestamp>());
        expect(json['deletionScheduledAt'], null);
      });

      test('deserializes account status fields from JSON with Timestamp', () {
        final verifiedAt = DateTime(2024, 6, 1, 10, 0, 0);
        final graceExpires = DateTime(2024, 6, 8, 10, 0, 0);
        final deletionDate = DateTime(2024, 7, 1, 10, 0, 0);
        final json = {
          'uid': 'test-uid',
          'email': 'test@example.com',
          'isEmailVerified': false,
          'isAnonymous': false,
          'accountStatus': 'restricted',
          'emailVerifiedAt': Timestamp.fromDate(verifiedAt),
          'gracePeriodExpiresAt': Timestamp.fromDate(graceExpires),
          'deletionScheduledAt': Timestamp.fromDate(deletionDate),
        };

        final user = UserModel.fromJson(json);

        expect(user.accountStatus, AccountStatus.restricted);
        expect(user.emailVerifiedAt, verifiedAt);
        expect(user.gracePeriodExpiresAt, graceExpires);
        expect(user.deletionScheduledAt, deletionDate);
      });

      test('deserializes all AccountStatus enum values from JSON', () {
        for (final status in AccountStatus.values) {
          final json = {
            'uid': 'test-uid',
            'email': 'test@example.com',
            'isEmailVerified': false,
            'isAnonymous': false,
            'accountStatus': status.name,
          };

          final user = UserModel.fromJson(json);
          expect(user.accountStatus, status);
        }
      });

      test('backward compatibility - missing account status fields default correctly', () {
        final json = {
          'uid': 'legacy-user',
          'email': 'legacy@test.com',
          'isEmailVerified': true,
          'isAnonymous': false,
        };

        final user = UserModel.fromJson(json);

        expect(user.accountStatus, AccountStatus.pendingVerification);
        expect(user.emailVerifiedAt, null);
        expect(user.gracePeriodExpiresAt, null);
        expect(user.deletionScheduledAt, null);
      });

      test('toFirestore includes account status fields', () {
        final graceExpires = DateTime(2024, 6, 8, 10, 0, 0);
        final user = testUser.copyWith(
          accountStatus: AccountStatus.pendingVerification,
          gracePeriodExpiresAt: graceExpires,
        );

        final firestoreData = user.toFirestore();

        expect(firestoreData['accountStatus'], 'pendingVerification');
        expect(firestoreData['gracePeriodExpiresAt'], isA<Timestamp>());
        expect(firestoreData.containsKey('uid'), false);
      });

      test('fromFirestore parses account status fields correctly', () {
        final verifiedAt = DateTime(2024, 6, 1, 10, 0, 0);
        final graceExpires = DateTime(2024, 6, 8, 10, 0, 0);
        final data = {
          'email': 'status@test.com',
          'displayName': 'Status Test User',
          'isEmailVerified': true,
          'isAnonymous': false,
          'accountStatus': 'active',
          'emailVerifiedAt': Timestamp.fromDate(verifiedAt),
          'gracePeriodExpiresAt': Timestamp.fromDate(graceExpires),
          'deletionScheduledAt': null,
        };

        final mockDoc = MockDocumentSnapshot('status-test-uid', data);
        final user = UserModel.fromFirestore(mockDoc);

        expect(user.uid, 'status-test-uid');
        expect(user.accountStatus, AccountStatus.active);
        expect(user.emailVerifiedAt, verifiedAt);
        expect(user.gracePeriodExpiresAt, graceExpires);
        expect(user.deletionScheduledAt, null);
      });

      test('copyWith updates account status fields correctly', () {
        final newVerifiedAt = DateTime(2024, 6, 15, 8, 0, 0);
        final updatedUser = testUser.copyWith(
          accountStatus: AccountStatus.active,
          emailVerifiedAt: newVerifiedAt,
        );

        expect(updatedUser.accountStatus, AccountStatus.active);
        expect(updatedUser.emailVerifiedAt, newVerifiedAt);
        expect(updatedUser.uid, testUser.uid);
        expect(updatedUser.email, testUser.email);
      });

      test('serializes scheduledForDeletion status correctly', () {
        final deletionDate = DateTime(2024, 7, 1, 10, 0, 0);
        final user = testUser.copyWith(
          accountStatus: AccountStatus.scheduledForDeletion,
          deletionScheduledAt: deletionDate,
        );

        final json = user.toJson();
        expect(json['accountStatus'], 'scheduledForDeletion');
        expect(json['deletionScheduledAt'], isA<Timestamp>());

        final restored = UserModel.fromJson(json);
        expect(restored.accountStatus, AccountStatus.scheduledForDeletion);
        expect(restored.deletionScheduledAt, deletionDate);
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