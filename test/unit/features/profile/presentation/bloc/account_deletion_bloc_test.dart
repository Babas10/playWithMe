// Validates AccountDeletionBloc emits correct states during account deletion flow.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/account_deletion/account_deletion_bloc.dart';
import 'package:play_with_me/features/profile/presentation/bloc/account_deletion/account_deletion_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/account_deletion/account_deletion_state.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = _MockAuthRepository();
  });

  AccountDeletionBloc buildBloc() =>
      AccountDeletionBloc(authRepository: mockAuthRepository);

  group('AccountDeletionBloc', () {
    test('initial state is AccountDeletionInitial', () {
      expect(buildBloc().state, const AccountDeletionState.initial());
    });

    blocTest<AccountDeletionBloc, AccountDeletionState>(
      'emits [inProgress, success] when deleteAccount succeeds',
      build: () {
        when(() => mockAuthRepository.deleteAccount())
            .thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AccountDeletionEvent.deleteRequested()),
      expect: () => const [
        AccountDeletionState.inProgress(),
        AccountDeletionState.success(),
      ],
      verify: (_) {
        verify(() => mockAuthRepository.deleteAccount()).called(1);
      },
    );

    blocTest<AccountDeletionBloc, AccountDeletionState>(
      'emits [inProgress, failure] when deleteAccount throws',
      build: () {
        when(() => mockAuthRepository.deleteAccount())
            .thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AccountDeletionEvent.deleteRequested()),
      expect: () => [
        const AccountDeletionState.inProgress(),
        const AccountDeletionState.failure(message: 'Network error'),
      ],
    );

    blocTest<AccountDeletionBloc, AccountDeletionState>(
      'calls deleteAccount exactly once per event',
      build: () {
        when(() => mockAuthRepository.deleteAccount())
            .thenAnswer((_) async {});
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AccountDeletionEvent.deleteRequested()),
      verify: (_) {
        verify(() => mockAuthRepository.deleteAccount()).called(1);
      },
    );
  });
}
