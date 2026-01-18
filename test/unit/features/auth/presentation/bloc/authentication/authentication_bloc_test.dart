// Verifies that AuthenticationBloc correctly handles authentication state transitions and emits appropriate states.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
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
      authenticationBloc = AuthenticationBloc(
        authRepository: mockAuthRepository,
      );
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
        'emits [AuthenticationAuthenticated] when user is emitted from auth stream',
        setUp: () {
          mockAuthRepository.setCurrentUser(TestUserData.testUser);
        },
        build: () => authenticationBloc,
        act: (bloc) => bloc.add(const AuthenticationStarted()),
        wait: const Duration(milliseconds: 50),
        expect: () => [
          const AuthenticationAuthenticated(TestUserData.testUser),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationUnauthenticated] when null is emitted from auth stream',
        setUp: () {
          mockAuthRepository.setCurrentUser(null);
        },
        build: () => authenticationBloc,
        act: (bloc) => bloc.add(const AuthenticationStarted()),
        wait: const Duration(milliseconds: 50),
        expect: () => [
          const AuthenticationUnauthenticated(),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationAuthenticated] then [AuthenticationUnauthenticated] when user logs out',
        setUp: () {
          mockAuthRepository.setCurrentUser(TestUserData.testUser);
        },
        build: () => authenticationBloc,
        act: (bloc) async {
          bloc.add(const AuthenticationStarted());
          await Future.delayed(const Duration(milliseconds: 50));
          mockAuthRepository.setCurrentUser(null);
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const AuthenticationAuthenticated(TestUserData.testUser),
          const AuthenticationUnauthenticated(),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationUnauthenticated] then [AuthenticationAuthenticated] when user logs in',
        setUp: () {
          mockAuthRepository.setCurrentUser(null);
        },
        build: () => authenticationBloc,
        act: (bloc) async {
          bloc.add(const AuthenticationStarted());
          await Future.delayed(const Duration(milliseconds: 50));
          mockAuthRepository.setCurrentUser(TestUserData.testUser);
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const AuthenticationUnauthenticated(),
          const AuthenticationAuthenticated(TestUserData.testUser),
        ],
      );
    });

    group('AuthenticationUserChanged', () {
      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationAuthenticated] when user is non-null',
        build: () => authenticationBloc,
        act: (bloc) => bloc.add(const AuthenticationUserChanged(TestUserData.testUser)),
        expect: () => [
          const AuthenticationAuthenticated(TestUserData.testUser),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationUnauthenticated] when user is null',
        build: () => authenticationBloc,
        act: (bloc) => bloc.add(const AuthenticationUserChanged(null)),
        expect: () => [
          const AuthenticationUnauthenticated(),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationAuthenticated] with anonymous user',
        build: () => authenticationBloc,
        act: (bloc) => bloc.add(const AuthenticationUserChanged(TestUserData.anonymousUser)),
        expect: () => [
          const AuthenticationAuthenticated(TestUserData.anonymousUser),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'emits [AuthenticationAuthenticated] with unverified user',
        build: () => authenticationBloc,
        act: (bloc) => bloc.add(const AuthenticationUserChanged(TestUserData.unverifiedUser)),
        expect: () => [
          const AuthenticationAuthenticated(TestUserData.unverifiedUser),
        ],
      );
    });

    group('AuthenticationLogoutRequested', () {
      blocTest<AuthenticationBloc, AuthenticationState>(
        'calls signOut on repository when logout is requested',
        setUp: () {
          mockAuthRepository.resetCallCounts();
        },
        build: () => authenticationBloc,
        act: (bloc) => bloc.add(const AuthenticationLogoutRequested()),
        verify: (_) {
          expect(mockAuthRepository.signOutCallCount, 1);
        },
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'does not emit error state when signOut succeeds',
        setUp: () {
          mockAuthRepository.setSignOutBehavior(() async {});
        },
        build: () => authenticationBloc,
        act: (bloc) => bloc.add(const AuthenticationLogoutRequested()),
        expect: () => <AuthenticationState>[],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'does not emit error state when signOut fails',
        setUp: () {
          mockAuthRepository.setSignOutBehavior(() async {
            throw Exception('Logout failed');
          });
        },
        build: () => authenticationBloc,
        act: (bloc) => bloc.add(const AuthenticationLogoutRequested()),
        expect: () => <AuthenticationState>[],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'auth state changes to unauthenticated after successful logout via stream',
        setUp: () {
          mockAuthRepository.setCurrentUser(TestUserData.testUser);
          mockAuthRepository.setSignOutBehavior(() async {
            mockAuthRepository.setCurrentUser(null);
          });
        },
        build: () => authenticationBloc,
        act: (bloc) async {
          bloc.add(const AuthenticationStarted());
          await Future.delayed(const Duration(milliseconds: 50));
          bloc.add(const AuthenticationLogoutRequested());
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const AuthenticationAuthenticated(TestUserData.testUser),
          const AuthenticationUnauthenticated(),
        ],
      );
    });

    group('Complex scenarios', () {
      blocTest<AuthenticationBloc, AuthenticationState>(
        'handles multiple consecutive user changes',
        build: () => authenticationBloc,
        act: (bloc) {
          bloc.add(const AuthenticationUserChanged(TestUserData.testUser));
          bloc.add(const AuthenticationUserChanged(TestUserData.anonymousUser));
          bloc.add(const AuthenticationUserChanged(null));
          bloc.add(const AuthenticationUserChanged(TestUserData.unverifiedUser));
        },
        expect: () => [
          const AuthenticationAuthenticated(TestUserData.testUser),
          const AuthenticationAuthenticated(TestUserData.anonymousUser),
          const AuthenticationUnauthenticated(),
          const AuthenticationAuthenticated(TestUserData.unverifiedUser),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'handles logout request while unauthenticated',
        setUp: () {
          mockAuthRepository.resetCallCounts();
        },
        build: () => authenticationBloc,
        seed: () => const AuthenticationUnauthenticated(),
        act: (bloc) => bloc.add(const AuthenticationLogoutRequested()),
        verify: (_) {
          expect(mockAuthRepository.signOutCallCount, 1);
        },
        expect: () => <AuthenticationState>[],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'deduplicates identical user change events (same user)',
        build: () => authenticationBloc,
        act: (bloc) {
          bloc.add(const AuthenticationUserChanged(TestUserData.testUser));
          bloc.add(const AuthenticationUserChanged(TestUserData.testUser));
        },
        expect: () => [
          // BLoC deduplicates identical states, so only one emission
          const AuthenticationAuthenticated(TestUserData.testUser),
        ],
      );

      blocTest<AuthenticationBloc, AuthenticationState>(
        'handles rapid authentication state changes',
        build: () => authenticationBloc,
        act: (bloc) {
          bloc.add(const AuthenticationUserChanged(null));
          bloc.add(const AuthenticationUserChanged(TestUserData.testUser));
          bloc.add(const AuthenticationUserChanged(null));
          bloc.add(const AuthenticationUserChanged(TestUserData.anonymousUser));
          bloc.add(const AuthenticationUserChanged(null));
        },
        expect: () => [
          const AuthenticationUnauthenticated(),
          const AuthenticationAuthenticated(TestUserData.testUser),
          const AuthenticationUnauthenticated(),
          const AuthenticationAuthenticated(TestUserData.anonymousUser),
          const AuthenticationUnauthenticated(),
        ],
      );
    });

    group('State equality', () {
      test('AuthenticationUnknown instances are equal', () {
        const state1 = AuthenticationUnknown();
        const state2 = AuthenticationUnknown();
        expect(state1, equals(state2));
      });

      test('AuthenticationUnauthenticated instances are equal', () {
        const state1 = AuthenticationUnauthenticated();
        const state2 = AuthenticationUnauthenticated();
        expect(state1, equals(state2));
      });

      test('AuthenticationAuthenticated instances with same user are equal', () {
        const state1 = AuthenticationAuthenticated(TestUserData.testUser);
        const state2 = AuthenticationAuthenticated(TestUserData.testUser);
        expect(state1, equals(state2));
      });

      test('AuthenticationAuthenticated instances with different users are not equal', () {
        const state1 = AuthenticationAuthenticated(TestUserData.testUser);
        const state2 = AuthenticationAuthenticated(TestUserData.anonymousUser);
        expect(state1, isNot(equals(state2)));
      });

      test('Different state types are not equal', () {
        const unknown = AuthenticationUnknown();
        const unauthenticated = AuthenticationUnauthenticated();
        const authenticated = AuthenticationAuthenticated(TestUserData.testUser);

        expect(unknown, isNot(equals(unauthenticated)));
        expect(unknown, isNot(equals(authenticated)));
        expect(unauthenticated, isNot(equals(authenticated)));
      });
    });

    group('Event equality', () {
      test('AuthenticationStarted instances are equal', () {
        const event1 = AuthenticationStarted();
        const event2 = AuthenticationStarted();
        expect(event1, equals(event2));
      });

      test('AuthenticationLogoutRequested instances are equal', () {
        const event1 = AuthenticationLogoutRequested();
        const event2 = AuthenticationLogoutRequested();
        expect(event1, equals(event2));
      });

      test('AuthenticationUserChanged instances with same user are equal', () {
        const event1 = AuthenticationUserChanged(TestUserData.testUser);
        const event2 = AuthenticationUserChanged(TestUserData.testUser);
        expect(event1, equals(event2));
      });

      test('AuthenticationUserChanged instances with different users are not equal', () {
        const event1 = AuthenticationUserChanged(TestUserData.testUser);
        const event2 = AuthenticationUserChanged(TestUserData.anonymousUser);
        expect(event1, isNot(equals(event2)));
      });

      test('AuthenticationUserChanged instances with null are equal', () {
        const event1 = AuthenticationUserChanged(null);
        const event2 = AuthenticationUserChanged(null);
        expect(event1, equals(event2));
      });
    });

    group('State props', () {
      test('AuthenticationUnknown props returns empty list', () {
        const state = AuthenticationUnknown();
        expect(state.props, isEmpty);
      });

      test('AuthenticationUnauthenticated props returns empty list', () {
        const state = AuthenticationUnauthenticated();
        expect(state.props, isEmpty);
      });

      test('AuthenticationAuthenticated props contains user', () {
        const state = AuthenticationAuthenticated(TestUserData.testUser);
        expect(state.props, [TestUserData.testUser]);
      });
    });

    group('Event props', () {
      test('AuthenticationStarted props returns empty list', () {
        const event = AuthenticationStarted();
        expect(event.props, isEmpty);
      });

      test('AuthenticationLogoutRequested props returns empty list', () {
        const event = AuthenticationLogoutRequested();
        expect(event.props, isEmpty);
      });

      test('AuthenticationUserChanged props contains user', () {
        const event = AuthenticationUserChanged(TestUserData.testUser);
        expect(event.props, [TestUserData.testUser]);
      });

      test('AuthenticationUserChanged with null props contains null', () {
        const event = AuthenticationUserChanged(null);
        expect(event.props, [null]);
      });
    });
  });
}
