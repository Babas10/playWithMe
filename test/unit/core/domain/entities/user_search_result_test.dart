// Tests UserSearchResult for equality and properties.

import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/domain/entities/user_search_result.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserSearchResult', () {
    late UserEntity testUser;

    setUp(() {
      testUser = const UserEntity(
        uid: 'user-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        isEmailVerified: true,
        isAnonymous: false,
      );
    });

    group('constructor', () {
      test('creates instance with user found', () {
        final result = UserSearchResult(
          user: testUser,
          isFriend: false,
          hasPendingRequest: false,
        );

        expect(result.user, equals(testUser));
        expect(result.isFriend, isFalse);
        expect(result.hasPendingRequest, isFalse);
        expect(result.requestDirection, isNull);
      });

      test('creates instance with no user found', () {
        const result = UserSearchResult(
          user: null,
          isFriend: false,
          hasPendingRequest: false,
        );

        expect(result.user, isNull);
      });

      test('creates instance with isFriend true', () {
        final result = UserSearchResult(
          user: testUser,
          isFriend: true,
          hasPendingRequest: false,
        );

        expect(result.isFriend, isTrue);
      });

      test('creates instance with pending request sent', () {
        final result = UserSearchResult(
          user: testUser,
          isFriend: false,
          hasPendingRequest: true,
          requestDirection: 'sent',
        );

        expect(result.hasPendingRequest, isTrue);
        expect(result.requestDirection, equals('sent'));
      });

      test('creates instance with pending request received', () {
        final result = UserSearchResult(
          user: testUser,
          isFriend: false,
          hasPendingRequest: true,
          requestDirection: 'received',
        );

        expect(result.hasPendingRequest, isTrue);
        expect(result.requestDirection, equals('received'));
      });
    });

    group('copyWith', () {
      test('creates copy with updated user', () {
        final result = UserSearchResult(
          user: testUser,
          isFriend: false,
          hasPendingRequest: false,
        );

        const newUser = UserEntity(
          uid: 'user-456',
          email: 'new@example.com',
          displayName: 'New User',
          isEmailVerified: true,
          isAnonymous: false,
        );

        final copy = result.copyWith(user: newUser);

        expect(copy.user?.uid, equals('user-456'));
        expect(copy.isFriend, equals(result.isFriend));
      });

      test('creates copy with updated isFriend', () {
        final result = UserSearchResult(
          user: testUser,
          isFriend: false,
          hasPendingRequest: false,
        );

        final copy = result.copyWith(isFriend: true);

        expect(copy.isFriend, isTrue);
        expect(copy.user, equals(result.user));
      });

      test('creates copy with updated hasPendingRequest', () {
        final result = UserSearchResult(
          user: testUser,
          isFriend: false,
          hasPendingRequest: false,
        );

        final copy = result.copyWith(hasPendingRequest: true);

        expect(copy.hasPendingRequest, isTrue);
      });

      test('creates copy with updated requestDirection', () {
        final result = UserSearchResult(
          user: testUser,
          isFriend: false,
          hasPendingRequest: true,
          requestDirection: 'sent',
        );

        final copy = result.copyWith(requestDirection: 'received');

        expect(copy.requestDirection, equals('received'));
      });
    });

    group('equality', () {
      test('two results with same values are equal', () {
        final result1 = UserSearchResult(
          user: testUser,
          isFriend: true,
          hasPendingRequest: false,
        );

        final result2 = UserSearchResult(
          user: testUser,
          isFriend: true,
          hasPendingRequest: false,
        );

        expect(result1, equals(result2));
      });

      test('two results with different user are not equal', () {
        final result1 = UserSearchResult(
          user: testUser,
          isFriend: false,
          hasPendingRequest: false,
        );

        const result2 = UserSearchResult(
          user: null,
          isFriend: false,
          hasPendingRequest: false,
        );

        expect(result1, isNot(equals(result2)));
      });

      test('two results with different isFriend are not equal', () {
        final result1 = UserSearchResult(
          user: testUser,
          isFriend: false,
          hasPendingRequest: false,
        );

        final result2 = UserSearchResult(
          user: testUser,
          isFriend: true,
          hasPendingRequest: false,
        );

        expect(result1, isNot(equals(result2)));
      });

      test('two results with different hasPendingRequest are not equal', () {
        final result1 = UserSearchResult(
          user: testUser,
          isFriend: false,
          hasPendingRequest: false,
        );

        final result2 = UserSearchResult(
          user: testUser,
          isFriend: false,
          hasPendingRequest: true,
        );

        expect(result1, isNot(equals(result2)));
      });

      test('two results with different requestDirection are not equal', () {
        final result1 = UserSearchResult(
          user: testUser,
          isFriend: false,
          hasPendingRequest: true,
          requestDirection: 'sent',
        );

        final result2 = UserSearchResult(
          user: testUser,
          isFriend: false,
          hasPendingRequest: true,
          requestDirection: 'received',
        );

        expect(result1, isNot(equals(result2)));
      });
    });

    group('hashCode', () {
      test('same values produce same hashCode', () {
        final result1 = UserSearchResult(
          user: testUser,
          isFriend: true,
          hasPendingRequest: false,
        );

        final result2 = UserSearchResult(
          user: testUser,
          isFriend: true,
          hasPendingRequest: false,
        );

        expect(result1.hashCode, equals(result2.hashCode));
      });
    });

    group('use cases', () {
      test('user not found scenario', () {
        const result = UserSearchResult(
          user: null,
          isFriend: false,
          hasPendingRequest: false,
        );

        expect(result.user, isNull);
        expect(result.isFriend, isFalse);
        expect(result.hasPendingRequest, isFalse);
        expect(result.requestDirection, isNull);
      });

      test('user found and is already friend', () {
        final result = UserSearchResult(
          user: testUser,
          isFriend: true,
          hasPendingRequest: false,
        );

        expect(result.user, isNotNull);
        expect(result.isFriend, isTrue);
        expect(result.hasPendingRequest, isFalse);
      });

      test('user found with outgoing friend request', () {
        final result = UserSearchResult(
          user: testUser,
          isFriend: false,
          hasPendingRequest: true,
          requestDirection: 'sent',
        );

        expect(result.user, isNotNull);
        expect(result.isFriend, isFalse);
        expect(result.hasPendingRequest, isTrue);
        expect(result.requestDirection, equals('sent'));
      });

      test('user found with incoming friend request', () {
        final result = UserSearchResult(
          user: testUser,
          isFriend: false,
          hasPendingRequest: true,
          requestDirection: 'received',
        );

        expect(result.user, isNotNull);
        expect(result.isFriend, isFalse);
        expect(result.hasPendingRequest, isTrue);
        expect(result.requestDirection, equals('received'));
      });

      test('user found with no relationship', () {
        final result = UserSearchResult(
          user: testUser,
          isFriend: false,
          hasPendingRequest: false,
        );

        expect(result.user, isNotNull);
        expect(result.isFriend, isFalse);
        expect(result.hasPendingRequest, isFalse);
        expect(result.requestDirection, isNull);
      });
    });
  });
}
