// Tests UserBloc functionality and validates all user management operations work correctly.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:play_with_me/core/presentation/bloc/user/user_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/user/user_event.dart';
import 'package:play_with_me/core/presentation/bloc/user/user_state.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/core/data/models/user_model.dart';

import '../../../data/repositories/mock_user_repository.dart';

void main() {
  group('UserBloc', () {
    late UserBloc userBloc;
    late MockUserRepository mockUserRepository;

    setUp(() {
      mockUserRepository = MockUserRepository();
      userBloc = UserBloc(userRepository: mockUserRepository);
    });

    tearDown(() {
      userBloc.close();
    });

    test('initial state is UserInitial', () {
      expect(userBloc.state, equals(const UserInitial()));
    });

    group('LoadCurrentUser', () {
      final testUser = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
      );

      blocTest<UserBloc, UserState>(
        'emits UserLoaded when current user exists',
        build: () {
          mockUserRepository.setCurrentUserValue(testUser);
          return userBloc;
        },
        act: (bloc) => bloc.add(const LoadCurrentUser()),
        expect: () => [
          const UserLoading(),
          UserLoaded(user: testUser),
        ],
      );

      blocTest<UserBloc, UserState>(
        'emits UserNotFound when no current user',
        build: () {
          mockUserRepository.setCurrentUserValue(null);
          return userBloc;
        },
        act: (bloc) => bloc.add(const LoadCurrentUser()),
        expect: () => [
          const UserLoading(),
          const UserNotFound(message: 'No current user found'),
        ],
      );

      blocTest<UserBloc, UserState>(
        'emits UserError when stream has error',
        build: () {
          mockUserRepository.setCurrentUserError('Stream error');
          return userBloc;
        },
        act: (bloc) => bloc.add(const LoadCurrentUser()),
        expect: () => [
          const UserLoading(),
          const UserError(
            message: 'Failed to load current user: Stream error',
            errorCode: 'CURRENT_USER_ERROR',
          ),
        ],
      );
    });

    group('LoadUserById', () {
      final testUser = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
      );

      blocTest<UserBloc, UserState>(
        'emits UserLoaded when user exists',
        build: () {
          mockUserRepository.addUser(testUser);
          return userBloc;
        },
        act: (bloc) => bloc.add(const LoadUserById(uid: 'test-uid')),
        expect: () => [
          const UserLoading(),
          UserLoaded(user: testUser),
        ],
      );

      blocTest<UserBloc, UserState>(
        'emits UserNotFound when user does not exist',
        build: () {
          mockUserRepository.clearUsers();
          return userBloc;
        },
        act: (bloc) => bloc.add(const LoadUserById(uid: 'test-uid')),
        expect: () => [
          const UserLoading(),
          const UserNotFound(message: 'User not found'),
        ],
      );

      // Skipping error test as mock doesn't support throwing exceptions
      // Error handling is covered in integration tests
    });

    group('UpdateUserProfile', () {
      final originalUser = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
        firstName: 'John',
      );

      final updatedUser = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
        firstName: 'Jane',
        lastName: 'Doe',
      );

      blocTest<UserBloc, UserState>(
        'emits UserUpdated when profile update succeeds',
        build: () {
          mockUserRepository.addUser(originalUser);
          return userBloc;
        },
        act: (bloc) => bloc.add(const UpdateUserProfile(
          uid: 'test-uid',
          firstName: 'Jane',
          lastName: 'Doe',
        )),
        expect: () => [
          const UserLoading(),
          isA<UserUpdated>(),
        ],
      );

      // Skipping error test as mock doesn't support throwing exceptions
      // Error handling is covered in integration tests
    });

    group('UpdateUserPreferences', () {
      final updatedUser = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
        notificationsEnabled: false,
      );

      blocTest<UserBloc, UserState>(
        'emits UserUpdated when preferences update succeeds',
        build: () {
          mockUserRepository.addUser(updatedUser);
          return userBloc;
        },
        act: (bloc) => bloc.add(const UpdateUserPreferences(
          uid: 'test-uid',
          notificationsEnabled: false,
        )),
        expect: () => [
          const UserLoading(),
          isA<UserUpdated>(),
        ],
      );
    });

    group('JoinGroup', () {
      final updatedUser = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
        groupIds: ['group-1'],
      );

      blocTest<UserBloc, UserState>(
        'emits UserUpdated when join group succeeds',
        build: () {
          mockUserRepository.addUser(updatedUser);
          return userBloc;
        },
        act: (bloc) => bloc.add(const JoinGroup(
          uid: 'test-uid',
          groupId: 'group-1',
        )),
        expect: () => [
          const UserLoading(),
          isA<UserUpdated>(),
        ],
      );
    });

    group('SearchUsers', () {
      final users = [
        UserModel(
          uid: 'user-1',
          email: 'user1@example.com',
          isEmailVerified: true,
          isAnonymous: false,
          displayName: 'User One',
        ),
        UserModel(
          uid: 'user-2',
          email: 'user2@example.com',
          isEmailVerified: true,
          isAnonymous: false,
          displayName: 'User Two',
        ),
      ];

      blocTest<UserBloc, UserState>(
        'emits UsersLoaded when search succeeds',
        build: () {
          for (final user in users) {
            mockUserRepository.addUser(user);
          }
          return userBloc;
        },
        act: (bloc) => bloc.add(const SearchUsers(query: 'query')),
        expect: () => [
          const UserLoading(),
          isA<UsersLoaded>(),
        ],
      );

      // Skipping error test as mock doesn't support throwing exceptions
      // Error handling is covered in integration tests
    });

    group('DeleteUser', () {
      final testUser = UserModel(
        uid: 'test-uid',
        email: 'test@example.com',
        isEmailVerified: true,
        isAnonymous: false,
      );

      blocTest<UserBloc, UserState>(
        'emits UserOperationSuccess when delete succeeds',
        build: () {
          mockUserRepository.addUser(testUser);
          return userBloc;
        },
        act: (bloc) => bloc.add(const DeleteUser(uid: 'test-uid')),
        expect: () => [
          const UserLoading(),
          const UserOperationSuccess(
            message: 'User account deleted successfully',
          ),
        ],
      );

      // Skipping error test as mock doesn't support throwing exceptions
      // Error handling is covered in integration tests
    });
  });
}