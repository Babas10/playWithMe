import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_bloc.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_state.dart';
import '../../../data/mock_auth_repository.dart';

void main() {
  group('PasswordResetBloc', () {
    late MockAuthRepository mockAuthRepository;
    late PasswordResetBloc passwordResetBloc;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      passwordResetBloc = PasswordResetBloc(authRepository: mockAuthRepository);
    });

    tearDown(() {
      passwordResetBloc.close();
      mockAuthRepository.dispose();
    });

    test('initial state is PasswordResetInitial', () {
      expect(passwordResetBloc.state, const PasswordResetInitial());
    });

    group('PasswordResetRequested', () {
      const testEmail = 'test@example.com';

      blocTest<PasswordResetBloc, PasswordResetState>(
        'emits [PasswordResetLoading, PasswordResetSuccess] when password reset succeeds',
        build: () {
          when(mockAuthRepository.sendPasswordResetEmail(email: testEmail))
              .thenAnswer((_) async {});
          return passwordResetBloc;
        },
        act: (bloc) => bloc.add(const PasswordResetRequested(email: testEmail)),
        expect: () => [
          const PasswordResetLoading(),
          const PasswordResetSuccess(testEmail),
        ],
        verify: (_) {
          verify(mockAuthRepository.sendPasswordResetEmail(email: testEmail)).called(1);
        },
      );

      blocTest<PasswordResetBloc, PasswordResetState>(
        'emits [PasswordResetLoading, PasswordResetFailure] when password reset fails',
        build: () {
          when(mockAuthRepository.sendPasswordResetEmail(email: testEmail))
              .thenThrow(Exception('User not found'));
          return passwordResetBloc;
        },
        act: (bloc) => bloc.add(const PasswordResetRequested(email: testEmail)),
        expect: () => [
          const PasswordResetLoading(),
          const PasswordResetFailure('User not found'),
        ],
      );

      blocTest<PasswordResetBloc, PasswordResetState>(
        'trims email before sending password reset',
        build: () {
          when(mockAuthRepository.sendPasswordResetEmail(email: testEmail))
              .thenAnswer((_) async {});
          return passwordResetBloc;
        },
        act: (bloc) => bloc.add(const PasswordResetRequested(email: '  $testEmail  ')),
        expect: () => [
          const PasswordResetLoading(),
          const PasswordResetSuccess(testEmail),
        ],
        verify: (_) {
          verify(mockAuthRepository.sendPasswordResetEmail(email: testEmail)).called(1);
        },
      );

      group('Input validation', () {
        blocTest<PasswordResetBloc, PasswordResetState>(
          'fails when email is empty',
          build: () => passwordResetBloc,
          act: (bloc) => bloc.add(const PasswordResetRequested(email: '')),
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetFailure('Email cannot be empty'),
          ],
          verify: (_) {
            verifyNever(mockAuthRepository.sendPasswordResetEmail(email: 'any@example.com'));
          },
        );

        blocTest<PasswordResetBloc, PasswordResetState>(
          'fails when email is only whitespace',
          build: () => passwordResetBloc,
          act: (bloc) => bloc.add(const PasswordResetRequested(email: '   ')),
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetFailure('Email cannot be empty'),
          ],
          verify: (_) {
            verifyNever(mockAuthRepository.sendPasswordResetEmail(email: 'any@example.com'));
          },
        );

        blocTest<PasswordResetBloc, PasswordResetState>(
          'fails when email format is invalid',
          build: () => passwordResetBloc,
          act: (bloc) => bloc.add(const PasswordResetRequested(email: 'invalid-email')),
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetFailure('Please enter a valid email address'),
          ],
          verify: (_) {
            verifyNever(mockAuthRepository.sendPasswordResetEmail(email: 'any@example.com'));
          },
        );

        group('Email validation edge cases', () {
          const validEmails = [
            'test@example.com',
            'user.name@example.com',
            'user+tag@example.co.uk',
            'test123@example-domain.com',
            'simple@domain.co',
          ];

          const invalidEmails = [
            'plainaddress',
            '@missingdomain.com',
            'missing@.com',
            'missing@domain',
            'spaces @domain.com',
            'test@',
            '@domain.com',
            'test@domain',
            'test.domain.com',
          ];

          for (final email in validEmails) {
            blocTest<PasswordResetBloc, PasswordResetState>(
              'accepts valid email: $email',
              build: () {
                when(mockAuthRepository.sendPasswordResetEmail(email: email))
                    .thenAnswer((_) async {});
                return passwordResetBloc;
              },
              act: (bloc) => bloc.add(PasswordResetRequested(email: email)),
              expect: () => [
                const PasswordResetLoading(),
                PasswordResetSuccess(email),
              ],
            );
          }

          for (final email in invalidEmails) {
            blocTest<PasswordResetBloc, PasswordResetState>(
              'rejects invalid email: $email',
              build: () => passwordResetBloc,
              act: (bloc) => bloc.add(PasswordResetRequested(email: email)),
              expect: () => [
                const PasswordResetLoading(),
                const PasswordResetFailure('Please enter a valid email address'),
              ],
            );
          }
        });
      });

      group('Repository error handling', () {
        final testCases = [
          {'error': 'User not found', 'expected': 'User not found'},
          {'error': 'Exception: Network error', 'expected': 'Network error'},
          {'error': 'Exception: Too many requests', 'expected': 'Too many requests'},
          {'error': 'Invalid email address', 'expected': 'Invalid email address'},
          {'error': 'Exception: Service unavailable', 'expected': 'Service unavailable'},
        ];

        for (final testCase in testCases) {
          blocTest<PasswordResetBloc, PasswordResetState>(
            'handles repository error: ${testCase['error']}',
            build: () {
              when(mockAuthRepository.sendPasswordResetEmail(email: testEmail))
                  .thenThrow(Exception(testCase['error']));
              return passwordResetBloc;
            },
            act: (bloc) => bloc.add(const PasswordResetRequested(email: testEmail)),
            expect: () => [
              const PasswordResetLoading(),
              PasswordResetFailure(testCase['expected']!),
            ],
          );
        }
      });

      group('Multiple requests', () {
        blocTest<PasswordResetBloc, PasswordResetState>(
          'handles multiple password reset requests for same email',
          build: () {
            when(mockAuthRepository.sendPasswordResetEmail(email: testEmail))
                .thenAnswer((_) async {});
            return passwordResetBloc;
          },
          act: (bloc) {
            bloc.add(const PasswordResetRequested(email: testEmail));
            bloc.add(const PasswordResetRequested(email: testEmail));
          },
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetSuccess(testEmail),
            const PasswordResetLoading(),
            const PasswordResetSuccess(testEmail),
          ],
          verify: (_) {
            verify(mockAuthRepository.sendPasswordResetEmail(email: testEmail)).called(2);
          },
        );

        blocTest<PasswordResetBloc, PasswordResetState>(
          'handles multiple password reset requests for different emails',
          build: () {
            when(mockAuthRepository.sendPasswordResetEmail(email: 'user1@example.com'))
                .thenAnswer((_) async {});
            when(mockAuthRepository.sendPasswordResetEmail(email: 'user2@example.com'))
                .thenAnswer((_) async {});
            return passwordResetBloc;
          },
          act: (bloc) {
            bloc.add(const PasswordResetRequested(email: 'user1@example.com'));
            bloc.add(const PasswordResetRequested(email: 'user2@example.com'));
          },
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetSuccess('user1@example.com'),
            const PasswordResetLoading(),
            const PasswordResetSuccess('user2@example.com'),
          ],
        );

        blocTest<PasswordResetBloc, PasswordResetState>(
          'handles failure followed by success',
          build: () {
            when(mockAuthRepository.sendPasswordResetEmail(email: 'fail@example.com'))
                .thenThrow(Exception('User not found'));
            when(mockAuthRepository.sendPasswordResetEmail(email: 'success@example.com'))
                .thenAnswer((_) async {});
            return passwordResetBloc;
          },
          act: (bloc) {
            bloc.add(const PasswordResetRequested(email: 'fail@example.com'));
            bloc.add(const PasswordResetRequested(email: 'success@example.com'));
          },
          expect: () => [
            const PasswordResetLoading(),
            const PasswordResetFailure('User not found'),
            const PasswordResetLoading(),
            const PasswordResetSuccess('success@example.com'),
          ],
        );
      });
    });

    group('PasswordResetFormReset', () {
      blocTest<PasswordResetBloc, PasswordResetState>(
        'emits [PasswordResetInitial] when form is reset',
        build: () => passwordResetBloc,
        seed: () => const PasswordResetFailure('Some error'),
        act: (bloc) => bloc.add(const PasswordResetFormReset()),
        expect: () => [const PasswordResetInitial()],
      );

      blocTest<PasswordResetBloc, PasswordResetState>(
        'can reset from success state',
        build: () => passwordResetBloc,
        seed: () => const PasswordResetSuccess('test@example.com'),
        act: (bloc) => bloc.add(const PasswordResetFormReset()),
        expect: () => [const PasswordResetInitial()],
      );

      blocTest<PasswordResetBloc, PasswordResetState>(
        'can reset from loading state',
        build: () => passwordResetBloc,
        seed: () => const PasswordResetLoading(),
        act: (bloc) => bloc.add(const PasswordResetFormReset()),
        expect: () => [const PasswordResetInitial()],
      );

      blocTest<PasswordResetBloc, PasswordResetState>(
        'can reset multiple times',
        build: () => passwordResetBloc,
        act: (bloc) {
          bloc.add(const PasswordResetFormReset());
          bloc.add(const PasswordResetFormReset());
          bloc.add(const PasswordResetFormReset());
        },
        expect: () => [
          const PasswordResetInitial(),
          const PasswordResetInitial(),
          const PasswordResetInitial(),
        ],
      );
    });

    group('Complex scenarios', () {
      blocTest<PasswordResetBloc, PasswordResetState>(
        'handles reset, request, reset sequence',
        build: () {
          when(mockAuthRepository.sendPasswordResetEmail(email: 'test@example.com'))
              .thenAnswer((_) async {});
          return passwordResetBloc;
        },
        act: (bloc) {
          bloc.add(const PasswordResetFormReset());
          bloc.add(const PasswordResetRequested(email: 'test@example.com'));
          bloc.add(const PasswordResetFormReset());
        },
        expect: () => [
          const PasswordResetInitial(),
          const PasswordResetLoading(),
          const PasswordResetSuccess('test@example.com'),
          const PasswordResetInitial(),
        ],
      );

      blocTest<PasswordResetBloc, PasswordResetState>(
        'handles rapid consecutive events',
        build: () {
          when(mockAuthRepository.sendPasswordResetEmail(email: 'test@example.com'))
              .thenAnswer((_) async {});
          return passwordResetBloc;
        },
        act: (bloc) {
          for (int i = 0; i < 3; i++) {
            bloc.add(PasswordResetRequested(email: 'test$i@example.com'));
            bloc.add(const PasswordResetFormReset());
          }
        },
        expect: () => [
          const PasswordResetLoading(),
          const PasswordResetSuccess('test0@example.com'),
          const PasswordResetInitial(),
          const PasswordResetLoading(),
          const PasswordResetSuccess('test1@example.com'),
          const PasswordResetInitial(),
          const PasswordResetLoading(),
          const PasswordResetSuccess('test2@example.com'),
          const PasswordResetInitial(),
        ],
      );

      blocTest<PasswordResetBloc, PasswordResetState>(
        'handles validation error followed by successful request',
        build: () {
          when(mockAuthRepository.sendPasswordResetEmail(email: 'valid@example.com'))
              .thenAnswer((_) async {});
          return passwordResetBloc;
        },
        act: (bloc) {
          bloc.add(const PasswordResetRequested(email: 'invalid-email'));
          bloc.add(const PasswordResetRequested(email: 'valid@example.com'));
        },
        expect: () => [
          const PasswordResetLoading(),
          const PasswordResetFailure('Please enter a valid email address'),
          const PasswordResetLoading(),
          const PasswordResetSuccess('valid@example.com'),
        ],
      );
    });

    group('Edge cases', () {
      blocTest<PasswordResetBloc, PasswordResetState>(
        'handles very long valid email',
        build: () {
          final longEmail = '${'a' * 50}@${'b' * 50}.com';
          when(mockAuthRepository.sendPasswordResetEmail(email: longEmail))
              .thenAnswer((_) async {});
          return passwordResetBloc;
        },
        act: (bloc) => bloc.add(PasswordResetRequested(email: '${'a' * 50}@${'b' * 50}.com')),
        expect: () => [
          const PasswordResetLoading(),
          PasswordResetSuccess('${'a' * 50}@${'b' * 50}.com'),
        ],
      );

      blocTest<PasswordResetBloc, PasswordResetState>(
        'handles email with special characters',
        build: () {
          when(mockAuthRepository.sendPasswordResetEmail(email: 'test+tag.name@example-domain.co.uk'))
              .thenAnswer((_) async {});
          return passwordResetBloc;
        },
        act: (bloc) => bloc.add(const PasswordResetRequested(email: 'test+tag.name@example-domain.co.uk')),
        expect: () => [
          const PasswordResetLoading(),
          const PasswordResetSuccess('test+tag.name@example-domain.co.uk'),
        ],
      );

      blocTest<PasswordResetBloc, PasswordResetState>(
        'handles repository throwing non-Exception error',
        build: () {
          when(mockAuthRepository.sendPasswordResetEmail(email: 'test@example.com'))
              .thenThrow('String error');
          return passwordResetBloc;
        },
        act: (bloc) => bloc.add(const PasswordResetRequested(email: 'test@example.com')),
        expect: () => [
          const PasswordResetLoading(),
          const PasswordResetFailure('String error'),
        ],
      );
    });
  });
}