import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/authentication/authentication_state.dart';
import '../../../data/mock_auth_repository.dart';

void main() {
  group('AuthenticationBloc', () {
    late MockAuthRepository mockAuthRepository;
    late AuthenticationBloc authenticationBloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      authenticationBloc = AuthenticationBloc(authRepository: mockAuthRepository);
    });

    tearDown(() {
      authenticationBloc.close();
      mockAuthRepository.dispose();
    });

    test('initial state is AuthenticationUnknown', () {
      expect(authenticationBloc.state, const AuthenticationUnknown());
    });

    group('AuthenticationStarted', () {
      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationUnauthenticated] when user is null',
        build: () {
          mockAuthRepository.setCurrentUser(null);
          return authenticationBloc;
        },
        act: (bloc) => bloc.add(const AuthenticationStarted()),
        expect: () => [const AuthenticationUnauthenticated()],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationAuthenticated] when user is not null',
        build: () {
          mockAuthRepository.setCurrentUser(TestUserData.testUser);
          return authenticationBloc;
        },
        act: (bloc) => bloc.add(const AuthenticationStarted()),
        expect: () => [const AuthenticationAuthenticated(TestUserData.testUser)],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'subscribes to auth state changes and emits subsequent states',
        build: () {
          // Start with no user
          mockAuthRepository.setCurrentUser(null);
          return authenticationBloc;
        },
        act: (bloc) async {
          bloc.add(const AuthenticationStarted());
          // Simulate user logging in
          await Future.delayed(const Duration(milliseconds: 10));
          mockAuthRepository.emitAuthStateChange(TestUserData.testUser);
          // Simulate user logging out
          await Future.delayed(const Duration(milliseconds: 10));
          mockAuthRepository.emitAuthStateChange(null);
        },
        expect: () => [
          const AuthenticationUnauthenticated(),
          const AuthenticationAuthenticated(TestUserData.testUser),
          const AuthenticationUnauthenticated(),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'handles auth state stream errors by emitting unauthenticated state',
        build: () {
          return authenticationBloc;
        },
        act: (bloc) async {
          bloc.add(const AuthenticationStarted());
          // Simulate stream error
          await Future.delayed(const Duration(milliseconds: 10));
          mockAuthRepository.authStateController.addError(Exception('Auth error'));
        },
        expect: () => [
          const AuthenticationUnauthenticated(),
        ],
      );
    });

    group('AuthenticationUserChanged', () {
      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationAuthenticated] when user is provided',
        build: () => authenticationBloc,
        act: (bloc) => bloc.add(const AuthenticationUserChanged(TestUserData.testUser)),
        expect: () => [const AuthenticationAuthenticated(TestUserData.testUser)],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationUnauthenticated] when user is null',
        build: () => authenticationBloc,
        act: (bloc) => bloc.add(const AuthenticationUserChanged(null)),
        expect: () => [const AuthenticationUnauthenticated()],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationAuthenticated] when anonymous user is provided',
        build: () => authenticationBloc,
        act: (bloc) => bloc.add(const AuthenticationUserChanged(TestUserData.anonymousUser)),
        expect: () => [const AuthenticationAuthenticated(TestUserData.anonymousUser)],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'handles multiple user changes correctly',
        build: () => authenticationBloc,
        act: (bloc) {
          bloc.add(const AuthenticationUserChanged(TestUserData.testUser));
          bloc.add(const AuthenticationUserChanged(TestUserData.anonymousUser));
          bloc.add(const AuthenticationUserChanged(null));
        },
        expect: () => [
          const AuthenticationAuthenticated(TestUserData.testUser),
          const AuthenticationAuthenticated(TestUserData.anonymousUser),
          const AuthenticationUnauthenticated(),
        ],
      );
    });

    group('AuthenticationLogoutRequested', () {
      blocTest<AuthenticationBloc, AuthenticationState>(
        'calls signOut on repository when logout requested',
        build: () {
          when(mockAuthRepository.signOut()).thenAnswer((_) async {});
          return authenticationBloc;
        },
        act: (bloc) => bloc.add(const AuthenticationLogoutRequested()),
        verify: (_) {
          verify(mockAuthRepository.signOut()).called(1);
        },
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'does not emit any state when logout succeeds',
        build: () {
          when(mockAuthRepository.signOut()).thenAnswer((_) async {});
          return authenticationBloc;
        },
        act: (bloc) => bloc.add(const AuthenticationLogoutRequested()),
        expect: () => [],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'does not emit error state when logout fails',
        build: () {
          when(mockAuthRepository.signOut()).thenThrow(Exception('Logout failed'));
          return authenticationBloc;
        },
        act: (bloc) => bloc.add(const AuthenticationLogoutRequested()),
        expect: () => [],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'handles logout with repository error gracefully',
        build: () {
          when(mockAuthRepository.signOut()).thenThrow(Exception('Network error'));
          return authenticationBloc;
        },
        act: (bloc) => bloc.add(const AuthenticationLogoutRequested()),
        verify: (_) {
          verify(mockAuthRepository.signOut()).called(1);
        },
      );
    });

    group('Complex authentication flows', () {
      blocTest<AuthenticationBloc, AuthenticationState>(
        'handles complete authentication flow: start -> login -> logout',
        build: () {
          when(mockAuthRepository.signOut()).thenAnswer((_) async {});
          mockAuthRepository.setCurrentUser(null);
          return authenticationBloc;
        },
        act: (bloc) async {
          // Start monitoring
          bloc.add(const AuthenticationStarted());
          await Future.delayed(const Duration(milliseconds: 10));

          // User logs in
          mockAuthRepository.emitAuthStateChange(TestUserData.testUser);
          await Future.delayed(const Duration(milliseconds: 10));

          // User requests logout
          bloc.add(const AuthenticationLogoutRequested());
          await Future.delayed(const Duration(milliseconds: 10));

          // Auth state changes to null after logout
          mockAuthRepository.emitAuthStateChange(null);
        },
        expect: () => [
          const AuthenticationUnauthenticated(),
          const AuthenticationAuthenticated(TestUserData.testUser),
          const AuthenticationUnauthenticated(),
        ],
        verify: (_) {
          verify(mockAuthRepository.signOut()).called(1);
        },
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'handles user switching from regular to anonymous account',
        build: () {
          mockAuthRepository.setCurrentUser(TestUserData.testUser);
          return authenticationBloc;
        },
        act: (bloc) async {
          bloc.add(const AuthenticationStarted());
          await Future.delayed(const Duration(milliseconds: 10));

          // Switch to anonymous
          mockAuthRepository.emitAuthStateChange(TestUserData.anonymousUser);
          await Future.delayed(const Duration(milliseconds: 10));

          // Switch back to regular user
          mockAuthRepository.emitAuthStateChange(TestUserData.testUser);
        },
        expect: () => [
          const AuthenticationAuthenticated(TestUserData.testUser),
          const AuthenticationAuthenticated(TestUserData.anonymousUser),
          const AuthenticationAuthenticated(TestUserData.testUser),
        ],
      );
    });

    group('Edge cases', () {
      blocTest<AuthenticationBloc, AuthenticationState>(
        'handles rapid consecutive events correctly',
        build: () => authenticationBloc,
        act: (bloc) {
          for (int i = 0; i < 5; i++) {
            bloc.add(AuthenticationUserChanged(i % 2 == 0 ? TestUserData.testUser : null));
          }
        },
        expect: () => [
          const AuthenticationAuthenticated(TestUserData.testUser),
          const AuthenticationUnauthenticated(),
          const AuthenticationAuthenticated(TestUserData.testUser),
          const AuthenticationUnauthenticated(),
          const AuthenticationAuthenticated(TestUserData.testUser),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'handles events before AuthenticationStarted',
        build: () => authenticationBloc,
        act: (bloc) {
          // Add events before starting
          bloc.add(const AuthenticationUserChanged(TestUserData.testUser));
          bloc.add(const AuthenticationLogoutRequested());
          bloc.add(const AuthenticationUserChanged(null));
        },
        expect: () => [
          const AuthenticationAuthenticated(TestUserData.testUser),
          const AuthenticationUnauthenticated(),
        ],
      );
    });
  });
}