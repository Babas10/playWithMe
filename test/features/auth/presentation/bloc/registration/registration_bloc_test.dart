import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_state.dart';
import '../../../data/mock_auth_repository.dart';

void main() {
  group('RegistrationBloc', () {
    late MockAuthRepository mockAuthRepository;
    late RegistrationBloc registrationBloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      registrationBloc = RegistrationBloc(authRepository: mockAuthRepository);
    });

    tearDown(() {
      registrationBloc.close();
      mockAuthRepository.dispose();
    });

    test('initial state is RegistrationInitial', () {
      expect(registrationBloc.state, const RegistrationInitial());
    });

    group('RegistrationSubmitted', () {
      const testEmail = 'test@example.com';
      const testPassword = 'password123';
      const testConfirmPassword = 'password123';
      const testDisplayName = 'Test User';

      blocTest<RegistrationBloc, RegistrationState>(
        'emits [RegistrationLoading, RegistrationSuccess] when registration succeeds',
        build: () {
          when(mockAuthRepository.createUserWithEmailAndPassword(
            email: testEmail,
            password: 'password123',
          )).thenAnswer((_) async => TestUserData.unverifiedUser);
          when(mockAuthRepository.updateUserProfile(
            displayName: testDisplayName,
          )).thenAnswer((_) async {});
          when(mockAuthRepository.sendEmailVerification()).thenAnswer((_) async {});
          return registrationBloc;
        },
        act: (bloc) => bloc.add(const RegistrationSubmitted(
          email: testEmail,
          password: testPassword,
          confirmPassword: testConfirmPassword,
          displayName: testDisplayName,
        )),
        expect: () => [
          const RegistrationLoading(),
          const RegistrationSuccess(),
        ],
        verify: (_) {
          verify(mockAuthRepository.createUserWithEmailAndPassword(
            email: testEmail,
            password: 'password123',
          )).called(1);
          verify(mockAuthRepository.updateUserProfile(
            displayName: testDisplayName,
          )).called(1);
          verify(mockAuthRepository.sendEmailVerification()).called(1);
        },
      );

      blocTest<RegistrationBloc, RegistrationState>(
        'succeeds without display name when not provided',
        build: () {
          when(mockAuthRepository.createUserWithEmailAndPassword(
            email: testEmail,
            password: 'password123',
          )).thenAnswer((_) async => TestUserData.unverifiedUser);
          when(mockAuthRepository.sendEmailVerification()).thenAnswer((_) async {});
          return registrationBloc;
        },
        act: (bloc) => bloc.add(const RegistrationSubmitted(
          email: testEmail,
          password: testPassword,
          confirmPassword: testConfirmPassword,
        )),
        expect: () => [
          const RegistrationLoading(),
          const RegistrationSuccess(),
        ],
        verify: (_) {
          verify(mockAuthRepository.createUserWithEmailAndPassword(
            email: testEmail,
            password: 'password123',
          )).called(1);
          verifyNever(mockAuthRepository.updateUserProfile(
            displayName: anyNamed('displayName'),
          ));
          verify(mockAuthRepository.sendEmailVerification()).called(1);
        },
      );

      blocTest<RegistrationBloc, RegistrationState>(
        'succeeds even if display name update fails',
        build: () {
          when(mockAuthRepository.createUserWithEmailAndPassword(
            email: testEmail,
            password: 'password123',
          )).thenAnswer((_) async => TestUserData.unverifiedUser);
          when(mockAuthRepository.updateUserProfile(
            displayName: testDisplayName,
          )).thenThrow(Exception('Profile update failed'));
          when(mockAuthRepository.sendEmailVerification()).thenAnswer((_) async {});
          return registrationBloc;
        },
        act: (bloc) => bloc.add(const RegistrationSubmitted(
          email: testEmail,
          password: testPassword,
          confirmPassword: testConfirmPassword,
          displayName: testDisplayName,
        )),
        expect: () => [
          const RegistrationLoading(),
          const RegistrationSuccess(),
        ],
      );

      blocTest<RegistrationBloc, RegistrationState>(
        'succeeds even if email verification fails',
        build: () {
          when(mockAuthRepository.createUserWithEmailAndPassword(
            email: testEmail,
            password: 'password123',
          )).thenAnswer((_) async => TestUserData.unverifiedUser);
          when(mockAuthRepository.sendEmailVerification())
              .thenThrow(Exception('Email verification failed'));
          return registrationBloc;
        },
        act: (bloc) => bloc.add(const RegistrationSubmitted(
          email: testEmail,
          password: testPassword,
          confirmPassword: testConfirmPassword,
        )),
        expect: () => [
          const RegistrationLoading(),
          const RegistrationSuccess(),
        ],
      );

      blocTest<RegistrationBloc, RegistrationState>(
        'emits [RegistrationLoading, RegistrationFailure] when user creation fails',
        build: () {
          when(mockAuthRepository.createUserWithEmailAndPassword(
            email: testEmail,
            password: 'password123',
          )).thenThrow(Exception('Email already in use'));
          return registrationBloc;
        },
        act: (bloc) => bloc.add(const RegistrationSubmitted(
          email: testEmail,
          password: testPassword,
          confirmPassword: testConfirmPassword,
        )),
        expect: () => [
          const RegistrationLoading(),
          const RegistrationFailure('Email already in use'),
        ],
      );

      group('Input validation', () {
        blocTest<RegistrationBloc, RegistrationState>(
          'fails when email is empty',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: '',
            password: 'password123',
            confirmPassword: testConfirmPassword,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Email cannot be empty'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'fails when email is only whitespace',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: '   ',
            password: 'password123',
            confirmPassword: testConfirmPassword,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Email cannot be empty'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'fails when email format is invalid',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: 'invalid-email',
            password: 'password123',
            confirmPassword: testConfirmPassword,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Please enter a valid email address'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'fails when password is empty',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: testEmail,
            password: '',
            confirmPassword: testConfirmPassword,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Password cannot be empty'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'fails when password is too short',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: testEmail,
            password: '12345',
            confirmPassword: '12345',
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Password must be at least 6 characters long'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'fails when passwords do not match',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: testEmail,
            password: 'password123',
            confirmPassword: 'differentpassword',
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Passwords do not match'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'fails when display name is too long',
          build: () => registrationBloc,
          act: (bloc) => bloc.add(RegistrationSubmitted(
            email: testEmail,
            password: 'password123',
            confirmPassword: testConfirmPassword,
            displayName: 'a' * 51, // 51 characters
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationFailure('Display name must be less than 50 characters'),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'succeeds with display name exactly 50 characters',
          build: () {
            final fiftyCharName = 'a' * 50;
            when(mockAuthRepository.createUserWithEmailAndPassword(
              email: testEmail,
              password: 'password123',
            )).thenAnswer((_) async => TestUserData.unverifiedUser);
            when(mockAuthRepository.updateUserProfile(
              displayName: fiftyCharName,
            )).thenAnswer((_) async {});
            when(mockAuthRepository.sendEmailVerification()).thenAnswer((_) async {});
            return registrationBloc;
          },
          act: (bloc) => bloc.add(RegistrationSubmitted(
            email: testEmail,
            password: 'password123',
            confirmPassword: testConfirmPassword,
            displayName: 'a' * 50,
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationSuccess(),
          ],
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'ignores empty display name',
          build: () {
            when(mockAuthRepository.createUserWithEmailAndPassword(
              email: testEmail,
              password: 'password123',
            )).thenAnswer((_) async => TestUserData.unverifiedUser);
            when(mockAuthRepository.sendEmailVerification()).thenAnswer((_) async {});
            return registrationBloc;
          },
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: testEmail,
            password: 'password123',
            confirmPassword: testConfirmPassword,
            displayName: '',
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationSuccess(),
          ],
          verify: (_) {
            verifyNever(mockAuthRepository.updateUserProfile(
              displayName: anyNamed('displayName'),
            ));
          },
        );

        blocTest<RegistrationBloc, RegistrationState>(
          'trims whitespace from display name',
          build: () {
            when(mockAuthRepository.createUserWithEmailAndPassword(
              email: testEmail,
              password: 'password123',
            )).thenAnswer((_) async => TestUserData.unverifiedUser);
            when(mockAuthRepository.updateUserProfile(
              displayName: testDisplayName,
            )).thenAnswer((_) async {});
            when(mockAuthRepository.sendEmailVerification()).thenAnswer((_) async {});
            return registrationBloc;
          },
          act: (bloc) => bloc.add(const RegistrationSubmitted(
            email: testEmail,
            password: 'password123',
            confirmPassword: testConfirmPassword,
            displayName: '  $testDisplayName  ',
          )),
          expect: () => [
            const RegistrationLoading(),
            const RegistrationSuccess(),
          ],
          verify: (_) {
            verify(mockAuthRepository.updateUserProfile(
              displayName: testDisplayName, // Should be trimmed
            )).called(1);
          },
        );
      });

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
          blocTest<RegistrationBloc, RegistrationState>(
            'accepts valid email: $email',
            build: () {
              when(mockAuthRepository.createUserWithEmailAndPassword(
                email: email,
                password: 'password123',
              )).thenAnswer((_) async => TestUserData.unverifiedUser);
              when(mockAuthRepository.sendEmailVerification()).thenAnswer((_) async {});
              return registrationBloc;
            },
            act: (bloc) => bloc.add(RegistrationSubmitted(
              email: email,
              password: 'password123',
              confirmPassword: testConfirmPassword,
            )),
            expect: () => [
              const RegistrationLoading(),
              const RegistrationSuccess(),
            ],
          );
        }

        for (final email in invalidEmails) {
          blocTest<RegistrationBloc, RegistrationState>(
            'rejects invalid email: $email',
            build: () => registrationBloc,
            act: (bloc) => bloc.add(RegistrationSubmitted(
              email: email,
              password: 'password123',
              confirmPassword: testConfirmPassword,
            )),
            expect: () => [
              const RegistrationLoading(),
              const RegistrationFailure('Please enter a valid email address'),
            ],
          );
        }
      });

      group('Repository error handling', () {
        final testCases = [
          {'error': 'Email already in use', 'expected': 'Email already in use'},
          {'error': 'Exception: Weak password', 'expected': 'Weak password'},
          {'error': 'Exception: Network error', 'expected': 'Network error'},
          {'error': 'Invalid email format', 'expected': 'Invalid email format'},
        ];

        for (final testCase in testCases) {
          blocTest<RegistrationBloc, RegistrationState>(
            'handles repository error: ${testCase['error']}',
            build: () {
              when(mockAuthRepository.createUserWithEmailAndPassword(
                email: testEmail,
                password: 'password123',
              )).thenThrow(Exception(testCase['error']));
              return registrationBloc;
            },
            act: (bloc) => bloc.add(const RegistrationSubmitted(
              email: testEmail,
              password: 'password123',
              confirmPassword: testConfirmPassword,
            )),
            expect: () => [
              const RegistrationLoading(),
              RegistrationFailure(testCase['expected']!),
            ],
          );
        }
      });
    });

    group('RegistrationFormReset', () {
      blocTest<RegistrationBloc, RegistrationState>(
        'emits [RegistrationInitial] when form is reset',
        build: () => registrationBloc,
        seed: () => const RegistrationFailure('Some error'),
        act: (bloc) => bloc.add(const RegistrationFormReset()),
        expect: () => [const RegistrationInitial()],
      );

      blocTest<RegistrationBloc, RegistrationState>(
        'can reset from any state',
        build: () => registrationBloc,
        act: (bloc) {
          bloc.add(const RegistrationFormReset()); // From initial
          bloc.add(const RegistrationFormReset()); // From initial again
        },
        expect: () => [
          const RegistrationInitial(),
          const RegistrationInitial(),
        ],
      );
    });

    group('Complex scenarios', () {
      blocTest<RegistrationBloc, RegistrationState>(
        'handles registration failure followed by successful registration',
        build: () {
          when(mockAuthRepository.createUserWithEmailAndPassword(
            email: 'fail@example.com',
            password: 'password123',
          )).thenThrow(Exception('Email already in use'));
          when(mockAuthRepository.createUserWithEmailAndPassword(
            email: 'success@example.com',
            password: 'password123',
          )).thenAnswer((_) async => TestUserData.unverifiedUser);
          when(mockAuthRepository.sendEmailVerification()).thenAnswer((_) async {});
          return registrationBloc;
        },
        act: (bloc) {
          bloc.add(const RegistrationSubmitted(
            email: 'fail@example.com',
            password: 'password123',
            confirmPassword: 'password123',
          ));
          bloc.add(const RegistrationSubmitted(
            email: 'success@example.com',
            password: 'password123',
            confirmPassword: 'password123',
          ));
        },
        expect: () => [
          const RegistrationLoading(),
          const RegistrationFailure('Email already in use'),
          const RegistrationLoading(),
          const RegistrationSuccess(),
        ],
      );

      blocTest<RegistrationBloc, RegistrationState>(
        'handles rapid consecutive registration attempts',
        build: () {
          when(mockAuthRepository.createUserWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          )).thenAnswer((_) async => TestUserData.unverifiedUser);
          when(mockAuthRepository.sendEmailVerification()).thenAnswer((_) async {});
          return registrationBloc;
        },
        act: (bloc) {
          bloc.add(const RegistrationSubmitted(
            email: 'test1@example.com',
            password: 'password123',
            confirmPassword: 'password123',
          ));
          bloc.add(const RegistrationSubmitted(
            email: 'test2@example.com',
            password: 'password123',
            confirmPassword: 'password123',
          ));
          bloc.add(const RegistrationFormReset());
        },
        expect: () => [
          const RegistrationLoading(),
          const RegistrationSuccess(),
          const RegistrationLoading(),
          const RegistrationSuccess(),
          const RegistrationInitial(),
        ],
      );
    });
  });
}