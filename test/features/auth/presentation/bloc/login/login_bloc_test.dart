import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_state.dart';
import '../../../data/mock_auth_repository.dart';

void main() {
  group('LoginBloc', () {
    late MockAuthRepository mockAuthRepository;
    late LoginBloc loginBloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      loginBloc = LoginBloc(authRepository: mockAuthRepository);
    });

    tearDown(() {
      loginBloc.close();
      mockAuthRepository.dispose();
    });

    test('initial state is LoginInitial', () {
      expect(loginBloc.state, const LoginInitial());
    });

    group('LoginWithEmailAndPasswordSubmitted', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';

      blocTest<LoginBloc, LoginState>(
        'emits [LoginLoading, LoginSuccess] when login succeeds',
        build: () {
          when(mockAuthRepository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          )).thenAnswer((_) async => TestUserData.testUser);
          return loginBloc;
        },
        act: (bloc) => bloc.add(const LoginWithEmailAndPasswordSubmitted(
          email: testEmail,
          password: testPassword,
        )),
        expect: () => [
          const LoginLoading(),
          const LoginSuccess(),
        ],
        verify: (_) {
          verify(mockAuthRepository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          )).called(1);
        },
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginLoading, LoginFailure] when login fails',
        build: () {
          when(mockAuthRepository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          )).thenThrow(Exception('Invalid credentials'));
          return loginBloc;
        },
        act: (bloc) => bloc.add(const LoginWithEmailAndPasswordSubmitted(
          email: testEmail,
          password: testPassword,
        )),
        expect: () => [
          const LoginLoading(),
          const LoginFailure('Invalid credentials'),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginFailure] when email is empty',
        build: () => loginBloc,
        act: (bloc) => bloc.add(const LoginWithEmailAndPasswordSubmitted(
          email: '',
          password: testPassword,
        )),
        expect: () => [
          const LoginLoading(),
          const LoginFailure('Email cannot be empty'),
        ],
        verify: (_) {
          verifyNever(mockAuthRepository.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ));
        },
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginFailure] when email is only whitespace',
        build: () => loginBloc,
        act: (bloc) => bloc.add(const LoginWithEmailAndPasswordSubmitted(
          email: '   ',
          password: testPassword,
        )),
        expect: () => [
          const LoginLoading(),
          const LoginFailure('Email cannot be empty'),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginFailure] when password is empty',
        build: () => loginBloc,
        act: (bloc) => bloc.add(const LoginWithEmailAndPasswordSubmitted(
          email: testEmail,
          password: '',
        )),
        expect: () => [
          const LoginLoading(),
          const LoginFailure('Password cannot be empty'),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginFailure] when password is only whitespace',
        build: () => loginBloc,
        act: (bloc) => bloc.add(const LoginWithEmailAndPasswordSubmitted(
          email: testEmail,
          password: '   ',
        )),
        expect: () => [
          const LoginLoading(),
          const LoginFailure('Password cannot be empty'),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginFailure] when email format is invalid',
        build: () => loginBloc,
        act: (bloc) => bloc.add(const LoginWithEmailAndPasswordSubmitted(
          email: 'invalid-email',
          password: testPassword,
        )),
        expect: () => [
          const LoginLoading(),
          const LoginFailure('Please enter a valid email address'),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'trims email before validation and login',
        build: () {
          when(mockAuthRepository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          )).thenAnswer((_) async => TestUserData.testUser);
          return loginBloc;
        },
        act: (bloc) => bloc.add(const LoginWithEmailAndPasswordSubmitted(
          email: '  $testEmail  ',
          password: testPassword,
        )),
        expect: () => [
          const LoginLoading(),
          const LoginSuccess(),
        ],
        verify: (_) {
          verify(mockAuthRepository.signInWithEmailAndPassword(
            email: testEmail, // Should be trimmed
            password: testPassword,
          )).called(1);
        },
      );

      group('Email validation edge cases', () {
        const validEmails = [
          'test@example.com',
          'user.name@example.com',
          'user+tag@example.co.uk',
          'test123@example-domain.com',
        ];

        const invalidEmails = [
          'plainaddress',
          '@missingdomain.com',
          'missing@.com',
          'missing@domain',
          'spaces @domain.com',
          'test@',
          '@domain.com',
        ];

        for (final email in validEmails) {
          blocTest<LoginBloc, LoginState>(
            'accepts valid email: $email',
            build: () {
              when(mockAuthRepository.signInWithEmailAndPassword(
                email: email,
                password: testPassword,
              )).thenAnswer((_) async => TestUserData.testUser);
              return loginBloc;
            },
            act: (bloc) => bloc.add(LoginWithEmailAndPasswordSubmitted(
              email: email,
              password: testPassword,
            )),
            expect: () => [
              const LoginLoading(),
              const LoginSuccess(),
            ],
          );
        }

        for (final email in invalidEmails) {
          blocTest<LoginBloc, LoginState>(
            'rejects invalid email: $email',
            build: () => loginBloc,
            act: (bloc) => bloc.add(LoginWithEmailAndPasswordSubmitted(
              email: email,
              password: testPassword,
            )),
            expect: () => [
              const LoginLoading(),
              const LoginFailure('Please enter a valid email address'),
            ],
          );
        }
      });

      group('Repository error handling', () {
        final testCases = [
          {'error': 'Network error', 'expected': 'Network error'},
          {'error': 'Exception: Invalid credentials', 'expected': 'Invalid credentials'},
          {'error': 'Exception: User not found', 'expected': 'User not found'},
          {'error': 'Timeout occurred', 'expected': 'Timeout occurred'},
        ];

        for (final testCase in testCases) {
          blocTest<LoginBloc, LoginState>(
            'handles repository error: ${testCase['error']}',
            build: () {
              when(mockAuthRepository.signInWithEmailAndPassword(
                email: testEmail,
                password: testPassword,
              )).thenThrow(Exception(testCase['error']));
              return loginBloc;
            },
            act: (bloc) => bloc.add(const LoginWithEmailAndPasswordSubmitted(
              email: testEmail,
              password: testPassword,
            )),
            expect: () => [
              const LoginLoading(),
              LoginFailure(testCase['expected']!),
            ],
          );
        }
      });
    });

    group('LoginAnonymouslySubmitted', () {
      blocTest<LoginBloc, LoginState>(
        'emits [LoginLoading, LoginSuccess] when anonymous login succeeds',
        build: () {
          when(mockAuthRepository.signInAnonymously())
              .thenAnswer((_) async => TestUserData.anonymousUser);
          return loginBloc;
        },
        act: (bloc) => bloc.add(const LoginAnonymouslySubmitted()),
        expect: () => [
          const LoginLoading(),
          const LoginSuccess(),
        ],
        verify: (_) {
          verify(mockAuthRepository.signInAnonymously()).called(1);
        },
      );

      blocTest<LoginBloc, LoginState>(
        'emits [LoginLoading, LoginFailure] when anonymous login fails',
        build: () {
          when(mockAuthRepository.signInAnonymously())
              .thenThrow(Exception('Anonymous login not allowed'));
          return loginBloc;
        },
        act: (bloc) => bloc.add(const LoginAnonymouslySubmitted()),
        expect: () => [
          const LoginLoading(),
          const LoginFailure('Anonymous login not allowed'),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'handles anonymous login repository errors correctly',
        build: () {
          when(mockAuthRepository.signInAnonymously())
              .thenThrow(Exception('Network connection failed'));
          return loginBloc;
        },
        act: (bloc) => bloc.add(const LoginAnonymouslySubmitted()),
        expect: () => [
          const LoginLoading(),
          const LoginFailure('Network connection failed'),
        ],
      );
    });

    group('LoginFormReset', () {
      blocTest<LoginBloc, LoginState>(
        'emits [LoginInitial] when form is reset',
        build: () => loginBloc,
        seed: () => const LoginFailure('Some error'),
        act: (bloc) => bloc.add(const LoginFormReset()),
        expect: () => [const LoginInitial()],
      );

      blocTest<LoginBloc, LoginState>(
        'can reset from any state',
        build: () => loginBloc,
        act: (bloc) {
          bloc.add(const LoginFormReset()); // From initial
          bloc.add(const LoginFormReset()); // From initial again
        },
        expect: () => [
          const LoginInitial(),
          const LoginInitial(),
        ],
      );
    });

    group('Complex scenarios', () {
      blocTest<LoginBloc, LoginState>(
        'handles rapid consecutive login attempts',
        build: () {
          when(mockAuthRepository.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => TestUserData.testUser);
          return loginBloc;
        },
        act: (bloc) {
          bloc.add(const LoginWithEmailAndPasswordSubmitted(
            email: 'test1@example.com',
            password: 'password1',
          ));
          bloc.add(const LoginWithEmailAndPasswordSubmitted(
            email: 'test2@example.com',
            password: 'password2',
          ));
          bloc.add(const LoginFormReset());
        },
        expect: () => [
          const LoginLoading(),
          const LoginSuccess(),
          const LoginLoading(),
          const LoginSuccess(),
          const LoginInitial(),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'handles login failure followed by successful login',
        build: () {
          when(mockAuthRepository.signInWithEmailAndPassword(
            email: 'fail@example.com',
            password: 'wrongpassword',
          )).thenThrow(Exception('Invalid credentials'));
          when(mockAuthRepository.signInWithEmailAndPassword(
            email: 'success@example.com',
            password: 'correctpassword',
          )).thenAnswer((_) async => TestUserData.testUser);
          return loginBloc;
        },
        act: (bloc) {
          bloc.add(const LoginWithEmailAndPasswordSubmitted(
            email: 'fail@example.com',
            password: 'wrongpassword',
          ));
          bloc.add(const LoginWithEmailAndPasswordSubmitted(
            email: 'success@example.com',
            password: 'correctpassword',
          ));
        },
        expect: () => [
          const LoginLoading(),
          const LoginFailure('Invalid credentials'),
          const LoginLoading(),
          const LoginSuccess(),
        ],
      );

      blocTest<LoginBloc, LoginState>(
        'handles mixed login types (email/password and anonymous)',
        build: () {
          when(mockAuthRepository.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => TestUserData.testUser);
          when(mockAuthRepository.signInAnonymously())
              .thenAnswer((_) async => TestUserData.anonymousUser);
          return loginBloc;
        },
        act: (bloc) {
          bloc.add(const LoginWithEmailAndPasswordSubmitted(
            email: 'test@example.com',
            password: 'password',
          ));
          bloc.add(const LoginAnonymouslySubmitted());
          bloc.add(const LoginFormReset());
        },
        expect: () => [
          const LoginLoading(),
          const LoginSuccess(),
          const LoginLoading(),
          const LoginSuccess(),
          const LoginInitial(),
        ],
      );
    });
  });
}