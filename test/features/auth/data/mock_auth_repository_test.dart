import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';

import 'mock_auth_repository.dart';

void main() {
  group('MockAuthRepository', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    tearDown(() {
      mockAuthRepository.dispose();
    });

    group('Initial State', () {
      test('should have null currentUser initially', () {
        expect(mockAuthRepository.currentUser, isNull);
      });

      test('should emit immediate initial state when stream is subscribed', () async {
        // Arrange
        final completer = Completer<UserEntity?>();

        // Act - Subscribe to the stream
        final subscription = mockAuthRepository.authStateChanges.listen(
          (user) {
            if (!completer.isCompleted) {
              completer.complete(user);
            }
          },
        );

        // Assert - Should receive initial null state immediately
        final initialUser = await completer.future.timeout(
          const Duration(milliseconds: 100),
          onTimeout: () => throw TimeoutException('Initial state not emitted'),
        );

        expect(initialUser, isNull);
        await subscription.cancel();
      });

      test('should emit initial state to multiple subscribers', () async {
        // Arrange
        final completer1 = Completer<UserEntity?>();
        final completer2 = Completer<UserEntity?>();

        // Act - Subscribe to the stream with two listeners
        final subscription1 = mockAuthRepository.authStateChanges.listen(
          (user) {
            if (!completer1.isCompleted) {
              completer1.complete(user);
            }
          },
        );

        final subscription2 = mockAuthRepository.authStateChanges.listen(
          (user) {
            if (!completer2.isCompleted) {
              completer2.complete(user);
            }
          },
        );

        // Assert - Both should receive initial null state
        final results = await Future.wait([
          completer1.future.timeout(const Duration(milliseconds: 100)),
          completer2.future.timeout(const Duration(milliseconds: 100)),
        ]);

        expect(results[0], isNull);
        expect(results[1], isNull);

        await subscription1.cancel();
        await subscription2.cancel();
      });
    });

    group('setCurrentUser', () {
      test('should update currentUser property', () {
        // Arrange
        const testUser = TestUserData.testUser;

        // Act
        mockAuthRepository.setCurrentUser(testUser);

        // Assert
        expect(mockAuthRepository.currentUser, equals(testUser));
      });

      test('should emit user state change to stream', () async {
        // Arrange
        const testUser = TestUserData.testUser;
        final receivedUsers = <UserEntity?>[];

        final subscription = mockAuthRepository.authStateChanges.listen(
          (user) => receivedUsers.add(user),
        );

        // Wait for initial emission
        await Future.delayed(const Duration(milliseconds: 10));

        // Act
        mockAuthRepository.setCurrentUser(testUser);

        // Wait for emission
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(receivedUsers.length, equals(2)); // Initial null + new user
        expect(receivedUsers[0], isNull); // Initial state
        expect(receivedUsers[1], equals(testUser)); // Updated state

        await subscription.cancel();
      });

      test('should emit new state to new subscribers after setCurrentUser', () async {
        // Arrange
        const testUser = TestUserData.testUser;
        mockAuthRepository.setCurrentUser(testUser);

        final completer = Completer<UserEntity?>();

        // Act - Subscribe after setting user
        final subscription = mockAuthRepository.authStateChanges.listen(
          (user) {
            if (!completer.isCompleted) {
              completer.complete(user);
            }
          },
        );

        // Assert - Should receive current user state immediately
        final receivedUser = await completer.future.timeout(
          const Duration(milliseconds: 100),
          onTimeout: () => throw TimeoutException('Current state not emitted'),
        );

        expect(receivedUser, equals(testUser));
        await subscription.cancel();
      });

      test('should handle setting user to null', () async {
        // Arrange
        const testUser = TestUserData.testUser;
        mockAuthRepository.setCurrentUser(testUser);

        final receivedUsers = <UserEntity?>[];
        final subscription = mockAuthRepository.authStateChanges.listen(
          (user) => receivedUsers.add(user),
        );

        // Wait for initial emission (should be testUser)
        await Future.delayed(const Duration(milliseconds: 10));

        // Act
        mockAuthRepository.setCurrentUser(null);

        // Wait for emission
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(receivedUsers.length, equals(2));
        expect(receivedUsers[0], equals(testUser)); // Initial current state
        expect(receivedUsers[1], isNull); // Updated to null
        expect(mockAuthRepository.currentUser, isNull);

        await subscription.cancel();
      });
    });

    group('emitAuthStateChange', () {
      test('should emit state change without updating currentUser', () async {
        // Arrange
        const testUser = TestUserData.testUser;
        const differentUser = TestUserData.unverifiedUser;

        mockAuthRepository.setCurrentUser(testUser);

        final receivedUsers = <UserEntity?>[];
        final subscription = mockAuthRepository.authStateChanges.listen(
          (user) => receivedUsers.add(user),
        );

        // Wait for initial emission
        await Future.delayed(const Duration(milliseconds: 10));

        // Act
        mockAuthRepository.emitAuthStateChange(differentUser);

        // Wait for emission
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert
        expect(receivedUsers.length, equals(2));
        expect(receivedUsers[0], equals(testUser)); // Initial current state
        expect(receivedUsers[1], equals(differentUser)); // Emitted state

        // currentUser should remain unchanged
        expect(mockAuthRepository.currentUser, equals(testUser));

        await subscription.cancel();
      });
    });

    group('Stream Behavior', () {
      test('should be a broadcast stream', () {
        // Arrange & Act
        final stream = mockAuthRepository.authStateChanges;

        // Assert
        expect(stream.isBroadcast, isTrue);
      });

      test('should handle rapid successive subscriptions', () async {
        // Arrange
        const testUser = TestUserData.testUser;
        mockAuthRepository.setCurrentUser(testUser);

        final results = <UserEntity?>[];

        // Act - Create multiple rapid subscriptions
        final subscriptions = <StreamSubscription>[];
        for (int i = 0; i < 5; i++) {
          final subscription = mockAuthRepository.authStateChanges.listen(
            (user) => results.add(user),
          );
          subscriptions.add(subscription);
        }

        // Wait for all emissions
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert - Each subscription should receive the current state
        expect(results.length, equals(5));
        expect(results.every((user) => user == testUser), isTrue);

        // Cleanup
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      });

      test('should continue working after dispose and recreate', () async {
        // Arrange
        const testUser = TestUserData.testUser;
        mockAuthRepository.setCurrentUser(testUser);

        // Act - Dispose and create new instance
        mockAuthRepository.dispose();
        mockAuthRepository = MockAuthRepository();

        final completer = Completer<UserEntity?>();
        final subscription = mockAuthRepository.authStateChanges.listen(
          (user) {
            if (!completer.isCompleted) {
              completer.complete(user);
            }
          },
        );

        // Assert - New instance should start with null state
        final receivedUser = await completer.future.timeout(
          const Duration(milliseconds: 100),
        );

        expect(receivedUser, isNull);
        expect(mockAuthRepository.currentUser, isNull);

        await subscription.cancel();
      });
    });

    group('Error Handling', () {
      test('should not emit after dispose', () async {
        // Arrange
        const testUser = TestUserData.testUser;
        final receivedUsers = <UserEntity?>[];

        final subscription = mockAuthRepository.authStateChanges.listen(
          (user) => receivedUsers.add(user),
        );

        // Wait for initial emission
        await Future.delayed(const Duration(milliseconds: 10));

        // Act
        mockAuthRepository.dispose();
        mockAuthRepository.setCurrentUser(testUser);

        // Wait to see if anything gets emitted
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert - Should only have initial null emission
        expect(receivedUsers.length, equals(1));
        expect(receivedUsers[0], isNull);

        await subscription.cancel();
      });

      test('should handle multiple dispose calls', () {
        // Act & Assert - Should not throw
        expect(() {
          mockAuthRepository.dispose();
          mockAuthRepository.dispose();
          mockAuthRepository.dispose();
        }, returnsNormally);
      });
    });

    group('Test Data Helpers', () {
      test('TestUserData.testUser should have correct properties', () {
        const user = TestUserData.testUser;

        expect(user.uid, equals('test-uid-123'));
        expect(user.email, equals('test@example.com'));
        expect(user.displayName, equals('Test User'));
        expect(user.photoUrl, isNull);
        expect(user.isEmailVerified, isTrue);
        expect(user.isAnonymous, isFalse);
      });

      test('TestUserData.anonymousUser should have correct properties', () {
        const user = TestUserData.anonymousUser;

        expect(user.uid, equals('anon-uid-456'));
        expect(user.email, equals(''));
        expect(user.displayName, isNull);
        expect(user.photoUrl, isNull);
        expect(user.isEmailVerified, isFalse);
        expect(user.isAnonymous, isTrue);
      });

      test('TestUserData.unverifiedUser should have correct properties', () {
        const user = TestUserData.unverifiedUser;

        expect(user.uid, equals('unverified-uid-789'));
        expect(user.email, equals('unverified@example.com'));
        expect(user.displayName, equals('Unverified User'));
        expect(user.photoUrl, isNull);
        expect(user.isEmailVerified, isFalse);
        expect(user.isAnonymous, isFalse);
      });
    });

    group('Integration with AuthenticationBloc simulation', () {
      test('should work correctly in typical bloc subscription scenario', () async {
        // Arrange - Simulate how AuthenticationBloc would use the repository
        final receivedStates = <String>[];

        // Simulate bloc subscription
        final subscription = mockAuthRepository.authStateChanges.listen(
          (user) {
            if (user == null) {
              receivedStates.add('Unauthenticated');
            } else if (user.isAnonymous) {
              receivedStates.add('AuthenticatedAnonymous');
            } else {
              receivedStates.add('AuthenticatedUser');
            }
          },
        );

        // Wait for initial state
        await Future.delayed(const Duration(milliseconds: 10));

        // Act - Simulate authentication flow
        mockAuthRepository.setCurrentUser(TestUserData.anonymousUser);
        await Future.delayed(const Duration(milliseconds: 10));

        mockAuthRepository.setCurrentUser(TestUserData.testUser);
        await Future.delayed(const Duration(milliseconds: 10));

        mockAuthRepository.setCurrentUser(null);
        await Future.delayed(const Duration(milliseconds: 10));

        // Assert - Should have received all state transitions
        expect(receivedStates, equals([
          'Unauthenticated',
          'AuthenticatedAnonymous',
          'AuthenticatedUser',
          'Unauthenticated',
        ]));

        await subscription.cancel();
      });
    });
  });
}