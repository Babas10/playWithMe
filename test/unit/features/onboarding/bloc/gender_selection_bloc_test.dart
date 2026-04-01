// Validates GenderSelectionBloc emits correct states during gender check and save.
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/features/onboarding/presentation/bloc/gender_selection/gender_selection_bloc.dart';
import 'package:play_with_me/features/onboarding/presentation/bloc/gender_selection/gender_selection_event.dart';
import 'package:play_with_me/features/onboarding/presentation/bloc/gender_selection/gender_selection_state.dart';

class MockUserRepository extends Mock implements UserRepository {}

UserModel _makeUser({UserGender? gender}) => UserModel(
      uid: 'user-1',
      email: 'test@test.com',
      displayName: 'Test',
      isEmailVerified: true,
      isAnonymous: false,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
      gender: gender,
    );

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    registerFallbackValue(UserGender.male);
  });

  GenderSelectionBloc build() =>
      GenderSelectionBloc(userRepository: mockUserRepository);

  group('CheckGenderSelection', () {
    blocTest<GenderSelectionBloc, GenderSelectionState>(
      'emits [Checking, NotRequired] when user already has gender set',
      setUp: () {
        when(() => mockUserRepository.getUserById('user-1'))
            .thenAnswer((_) async => _makeUser(gender: UserGender.male));
      },
      build: build,
      act: (bloc) => bloc.add(const CheckGenderSelection(uid: 'user-1')),
      expect: () => [
        const GenderSelectionChecking(),
        const GenderSelectionNotRequired(),
      ],
    );

    blocTest<GenderSelectionBloc, GenderSelectionState>(
      'emits [Checking, Required] when user has no gender',
      setUp: () {
        when(() => mockUserRepository.getUserById('user-1'))
            .thenAnswer((_) async => _makeUser(gender: null));
      },
      build: build,
      act: (bloc) => bloc.add(const CheckGenderSelection(uid: 'user-1')),
      expect: () => [
        const GenderSelectionChecking(),
        GenderSelectionRequired(uid: 'user-1'),
      ],
    );

    blocTest<GenderSelectionBloc, GenderSelectionState>(
      'emits [Checking, NotRequired] when user document does not exist',
      setUp: () {
        when(() => mockUserRepository.getUserById('user-1'))
            .thenAnswer((_) async => null);
      },
      build: build,
      act: (bloc) => bloc.add(const CheckGenderSelection(uid: 'user-1')),
      expect: () => [
        const GenderSelectionChecking(),
        const GenderSelectionNotRequired(),
      ],
    );

    blocTest<GenderSelectionBloc, GenderSelectionState>(
      'emits [Checking, NotRequired] on repository error (fails safe)',
      setUp: () {
        when(() => mockUserRepository.getUserById('user-1'))
            .thenThrow(Exception('Firestore error'));
      },
      build: build,
      act: (bloc) => bloc.add(const CheckGenderSelection(uid: 'user-1')),
      expect: () => [
        const GenderSelectionChecking(),
        const GenderSelectionNotRequired(),
      ],
    );
  });

  group('GenderOptionSelected', () {
    blocTest<GenderSelectionBloc, GenderSelectionState>(
      'updates selectedGender in Required state',
      setUp: () {
        when(() => mockUserRepository.getUserById('user-1'))
            .thenAnswer((_) async => _makeUser(gender: null));
      },
      build: build,
      seed: () => GenderSelectionRequired(uid: 'user-1'),
      act: (bloc) =>
          bloc.add(const GenderOptionSelected(gender: UserGender.female)),
      expect: () => [
        GenderSelectionRequired(uid: 'user-1', selectedGender: UserGender.female),
      ],
    );

    blocTest<GenderSelectionBloc, GenderSelectionState>(
      'changes selection from one value to another',
      build: build,
      seed: () => GenderSelectionRequired(
        uid: 'user-1',
        selectedGender: UserGender.male,
      ),
      act: (bloc) =>
          bloc.add(const GenderOptionSelected(gender: UserGender.none)),
      expect: () => [
        GenderSelectionRequired(uid: 'user-1', selectedGender: UserGender.none),
      ],
    );

    blocTest<GenderSelectionBloc, GenderSelectionState>(
      'is a no-op when state is not GenderSelectionRequired',
      build: build,
      seed: () => const GenderSelectionNotRequired(),
      act: (bloc) =>
          bloc.add(const GenderOptionSelected(gender: UserGender.male)),
      expect: () => [],
    );
  });

  group('GenderSelectionConfirmed', () {
    blocTest<GenderSelectionBloc, GenderSelectionState>(
      'emits [Saving, Saved] on successful save',
      setUp: () {
        when(() => mockUserRepository.updateUserProfile(
              'user-1',
              gender: any(named: 'gender'),
            )).thenAnswer((_) async {});
      },
      build: build,
      seed: () => GenderSelectionRequired(
        uid: 'user-1',
        selectedGender: UserGender.male,
      ),
      act: (bloc) => bloc.add(const GenderSelectionConfirmed()),
      expect: () => [
        const GenderSelectionSaving(),
        const GenderSelectionSaved(),
      ],
      verify: (_) {
        verify(() => mockUserRepository.updateUserProfile(
              'user-1',
              gender: UserGender.male,
            )).called(1);
      },
    );

    blocTest<GenderSelectionBloc, GenderSelectionState>(
      'emits [Saving, Error] when repository throws',
      setUp: () {
        when(() => mockUserRepository.updateUserProfile(
              'user-1',
              gender: any(named: 'gender'),
            )).thenThrow(Exception('Save failed'));
      },
      build: build,
      seed: () => GenderSelectionRequired(
        uid: 'user-1',
        selectedGender: UserGender.female,
      ),
      act: (bloc) => bloc.add(const GenderSelectionConfirmed()),
      expect: () => [
        const GenderSelectionSaving(),
        isA<GenderSelectionError>(),
      ],
    );

    blocTest<GenderSelectionBloc, GenderSelectionState>(
      'is a no-op when no gender is selected',
      build: build,
      seed: () => GenderSelectionRequired(uid: 'user-1'),
      act: (bloc) => bloc.add(const GenderSelectionConfirmed()),
      expect: () => [],
    );

    blocTest<GenderSelectionBloc, GenderSelectionState>(
      'is a no-op when state is not GenderSelectionRequired',
      build: build,
      seed: () => const GenderSelectionNotRequired(),
      act: (bloc) => bloc.add(const GenderSelectionConfirmed()),
      expect: () => [],
    );
  });
}
