// Validates GameCreationBloc correctly manages form state, validation, and game creation logic.

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:play_with_me/core/data/models/game_model.dart';
import 'package:play_with_me/core/domain/repositories/game_repository.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_creation/game_creation_bloc.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_creation/game_creation_event.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_creation/game_creation_state.dart';

class MockGameRepository extends Mock implements GameRepository {}

class FakeGameModel extends Fake implements GameModel {}

void main() {
  late GameRepository mockGameRepository;
  late GameCreationBloc gameCreationBloc;

  setUpAll(() {
    registerFallbackValue(FakeGameModel());
  });

  setUp(() {
    mockGameRepository = MockGameRepository();
    gameCreationBloc = GameCreationBloc(gameRepository: mockGameRepository);
  });

  tearDown(() {
    gameCreationBloc.close();
  });

  group('GameCreationBloc', () {
    test('initial state is GameCreationInitial', () {
      expect(gameCreationBloc.state, equals(const GameCreationInitial()));
    });

    group('SelectGroup', () {
      blocTest<GameCreationBloc, GameCreationState>(
        'emits GameCreationFormState with selected group and validation errors for other fields',
        build: () => gameCreationBloc,
        act: (bloc) => bloc.add(const SelectGroup(
          groupId: 'group1',
          groupName: 'Test Group',
        )),
        expect: () => [
          const GameCreationFormState(
            groupId: 'group1',
            groupName: 'Test Group',
            groupError: null,
            dateTimeError: 'Please select a date and time',
            locationError: 'Please enter a location',
            titleError: 'Please enter a game title',
            isValid: false,
          ),
        ],
      );

      blocTest<GameCreationBloc, GameCreationState>(
        'clears groupError when group is selected',
        build: () => gameCreationBloc,
        seed: () => const GameCreationFormState(
          groupError: 'Please select a group',
        ),
        act: (bloc) => bloc.add(const SelectGroup(
          groupId: 'group1',
          groupName: 'Test Group',
        )),
        expect: () => [
          const GameCreationFormState(
            groupId: 'group1',
            groupName: 'Test Group',
            groupError: null,
            dateTimeError: 'Please select a date and time',
            locationError: 'Please enter a location',
            titleError: 'Please enter a game title',
            isValid: false,
          ),
        ],
      );
    });

    group('SetDateTime', () {
      final futureDate = DateTime.now().add(const Duration(days: 1));

      blocTest<GameCreationBloc, GameCreationState>(
        'emits GameCreationFormState with selected dateTime and validation errors for other fields',
        build: () => gameCreationBloc,
        act: (bloc) => bloc.add(SetDateTime(dateTime: futureDate)),
        expect: () => [
          GameCreationFormState(
            dateTime: futureDate,
            dateTimeError: null,
            groupError: 'Please select a group',
            locationError: 'Please enter a location',
            titleError: 'Please enter a game title',
            isValid: false,
          ),
        ],
      );

      blocTest<GameCreationBloc, GameCreationState>(
        'clears dateTimeError when dateTime is set',
        build: () => gameCreationBloc,
        seed: () => const GameCreationFormState(
          dateTimeError: 'Please select a date and time',
        ),
        act: (bloc) => bloc.add(SetDateTime(dateTime: futureDate)),
        expect: () => [
          GameCreationFormState(
            dateTime: futureDate,
            dateTimeError: null,
            groupError: 'Please select a group',
            locationError: 'Please enter a location',
            titleError: 'Please enter a game title',
            isValid: false,
          ),
        ],
      );
    });

    group('SetLocation', () {
      blocTest<GameCreationBloc, GameCreationState>(
        'emits GameCreationFormState with location and validation errors for other fields',
        build: () => gameCreationBloc,
        act: (bloc) => bloc.add(const SetLocation(
          locationName: 'Venice Beach',
          address: '123 Beach Blvd',
        )),
        expect: () => [
          const GameCreationFormState(
            locationName: 'Venice Beach',
            address: '123 Beach Blvd',
            locationError: null,
            groupError: 'Please select a group',
            dateTimeError: 'Please select a date and time',
            titleError: 'Please enter a game title',
            isValid: false,
          ),
        ],
      );

      blocTest<GameCreationBloc, GameCreationState>(
        'emits GameCreationFormState with location without address',
        build: () => gameCreationBloc,
        act: (bloc) => bloc.add(const SetLocation(
          locationName: 'Venice Beach',
        )),
        expect: () => [
          const GameCreationFormState(
            locationName: 'Venice Beach',
            locationError: null,
            groupError: 'Please select a group',
            dateTimeError: 'Please select a date and time',
            titleError: 'Please enter a game title',
            isValid: false,
          ),
        ],
      );
    });

    group('SetTitle', () {
      blocTest<GameCreationBloc, GameCreationState>(
        'emits GameCreationFormState with title and validation errors for other fields',
        build: () => gameCreationBloc,
        act: (bloc) => bloc.add(const SetTitle(title: 'Beach Volleyball')),
        expect: () => [
          const GameCreationFormState(
            title: 'Beach Volleyball',
            titleError: null,
            groupError: 'Please select a group',
            dateTimeError: 'Please select a date and time',
            locationError: 'Please enter a location',
            isValid: false,
          ),
        ],
      );
    });

    group('SetDescription', () {
      blocTest<GameCreationBloc, GameCreationState>(
        'emits GameCreationFormState with description (no validation)',
        build: () => gameCreationBloc,
        act: (bloc) => bloc.add(const SetDescription(
          description: 'Casual beach volleyball game',
        )),
        expect: () => [
          const GameCreationFormState(
            description: 'Casual beach volleyball game',
            groupError: null,
            dateTimeError: null,
            locationError: null,
            titleError: null,
            playersError: null,
            isValid: false,
          ),
        ],
      );
    });

    group('SetMaxPlayers', () {
      blocTest<GameCreationBloc, GameCreationState>(
        'emits GameCreationFormState with maxPlayers and validation errors for other fields',
        build: () => gameCreationBloc,
        act: (bloc) => bloc.add(const SetMaxPlayers(maxPlayers: 6)),
        expect: () => [
          const GameCreationFormState(
            maxPlayers: 6,
            playersError: null,
            groupError: 'Please select a group',
            dateTimeError: 'Please select a date and time',
            locationError: 'Please enter a location',
            titleError: 'Please enter a game title',
            isValid: false,
          ),
        ],
      );
    });

    group('SetMinPlayers', () {
      blocTest<GameCreationBloc, GameCreationState>(
        'emits GameCreationFormState with minPlayers and validation errors for other fields',
        build: () => gameCreationBloc,
        act: (bloc) => bloc.add(const SetMinPlayers(minPlayers: 4)),
        expect: () => [
          const GameCreationFormState(
            minPlayers: 4,
            playersError: null,
            groupError: 'Please select a group',
            dateTimeError: 'Please select a date and time',
            locationError: 'Please enter a location',
            titleError: 'Please enter a game title',
            isValid: false,
          ),
        ],
      );
    });

    group('SetGameType', () {
      blocTest<GameCreationBloc, GameCreationState>(
        'emits GameCreationFormState with gameType',
        build: () => gameCreationBloc,
        act: (bloc) => bloc.add(const SetGameType(
          gameType: GameType.beachVolleyball,
        )),
        expect: () => [
          const GameCreationFormState(
            gameType: GameType.beachVolleyball,
            isValid: false,
          ),
        ],
      );
    });

    group('SetSkillLevel', () {
      blocTest<GameCreationBloc, GameCreationState>(
        'emits GameCreationFormState with skillLevel',
        build: () => gameCreationBloc,
        act: (bloc) => bloc.add(const SetSkillLevel(
          skillLevel: GameSkillLevel.intermediate,
        )),
        expect: () => [
          const GameCreationFormState(
            skillLevel: GameSkillLevel.intermediate,
            isValid: false,
          ),
        ],
      );
    });

    group('ValidateForm', () {
      final futureDate = DateTime.now().add(const Duration(days: 1));

      blocTest<GameCreationBloc, GameCreationState>(
        'validates and marks form as invalid when fields are missing',
        build: () => gameCreationBloc,
        seed: () => const GameCreationFormState(),
        act: (bloc) => bloc.add(const ValidateForm()),
        expect: () => [
          const GameCreationFormState(
            groupError: 'Please select a group',
            dateTimeError: 'Please select a date and time',
            locationError: 'Please enter a location',
            titleError: 'Please enter a game title',
            isValid: false,
          ),
        ],
      );

      blocTest<GameCreationBloc, GameCreationState>(
        'validates and marks form as valid when all required fields are filled',
        build: () => gameCreationBloc,
        seed: () => GameCreationFormState(
          groupId: 'group1',
          groupName: 'Test Group',
          dateTime: futureDate,
          locationName: 'Venice Beach',
          title: 'Beach Volleyball',
        ),
        act: (bloc) => bloc.add(const ValidateForm()),
        expect: () => [
          GameCreationFormState(
            groupId: 'group1',
            groupName: 'Test Group',
            dateTime: futureDate,
            locationName: 'Venice Beach',
            title: 'Beach Volleyball',
            isValid: true,
          ),
        ],
      );

      blocTest<GameCreationBloc, GameCreationState>(
        'validates title length - too short',
        build: () => gameCreationBloc,
        seed: () => GameCreationFormState(
          groupId: 'group1',
          groupName: 'Test Group',
          dateTime: futureDate,
          locationName: 'Venice Beach',
          title: 'ab',
        ),
        act: (bloc) => bloc.add(const ValidateForm()),
        expect: () => [
          GameCreationFormState(
            groupId: 'group1',
            groupName: 'Test Group',
            dateTime: futureDate,
            locationName: 'Venice Beach',
            title: 'ab',
            titleError: 'Title must be at least 3 characters',
            isValid: false,
          ),
        ],
      );

      blocTest<GameCreationBloc, GameCreationState>(
        'validates title length - too long',
        build: () => gameCreationBloc,
        seed: () => GameCreationFormState(
          groupId: 'group1',
          groupName: 'Test Group',
          dateTime: futureDate,
          locationName: 'Venice Beach',
          title: 'a' * 101,
        ),
        act: (bloc) => bloc.add(const ValidateForm()),
        expect: () => [
          GameCreationFormState(
            groupId: 'group1',
            groupName: 'Test Group',
            dateTime: futureDate,
            locationName: 'Venice Beach',
            title: 'a' * 101,
            titleError: 'Title must be less than 100 characters',
            isValid: false,
          ),
        ],
      );

      blocTest<GameCreationBloc, GameCreationState>(
        'validates date is in the future',
        build: () => gameCreationBloc,
        seed: () {
          final pastDate = DateTime.now().subtract(const Duration(days: 1));
          return GameCreationFormState(
            groupId: 'group1',
            groupName: 'Test Group',
            dateTime: pastDate,
            locationName: 'Venice Beach',
            title: 'Beach Volleyball',
          );
        },
        act: (bloc) => bloc.add(const ValidateForm()),
        expect: () => [
          isA<GameCreationFormState>()
              .having((s) => s.groupId, 'groupId', 'group1')
              .having((s) => s.groupName, 'groupName', 'Test Group')
              .having((s) => s.dateTimeError, 'dateTimeError', 'Game date must be in the future')
              .having((s) => s.isValid, 'isValid', false),
        ],
      );

      blocTest<GameCreationBloc, GameCreationState>(
        'validates minPlayers is at least 2',
        build: () => gameCreationBloc,
        seed: () => GameCreationFormState(
          groupId: 'group1',
          groupName: 'Test Group',
          dateTime: futureDate,
          locationName: 'Venice Beach',
          title: 'Beach Volleyball',
          minPlayers: 1,
        ),
        act: (bloc) => bloc.add(const ValidateForm()),
        expect: () => [
          GameCreationFormState(
            groupId: 'group1',
            groupName: 'Test Group',
            dateTime: futureDate,
            locationName: 'Venice Beach',
            title: 'Beach Volleyball',
            minPlayers: 1,
            playersError: 'Minimum players must be at least 2',
            isValid: false,
          ),
        ],
      );

      blocTest<GameCreationBloc, GameCreationState>(
        'validates maxPlayers is greater than or equal to minPlayers',
        build: () => gameCreationBloc,
        seed: () => GameCreationFormState(
          groupId: 'group1',
          groupName: 'Test Group',
          dateTime: futureDate,
          locationName: 'Venice Beach',
          title: 'Beach Volleyball',
          minPlayers: 4,
          maxPlayers: 2,
        ),
        act: (bloc) => bloc.add(const ValidateForm()),
        expect: () => [
          GameCreationFormState(
            groupId: 'group1',
            groupName: 'Test Group',
            dateTime: futureDate,
            locationName: 'Venice Beach',
            title: 'Beach Volleyball',
            minPlayers: 4,
            maxPlayers: 2,
            playersError: 'Maximum players must be greater than or equal to minimum players',
            isValid: false,
          ),
        ],
      );

      blocTest<GameCreationBloc, GameCreationState>(
        'validates maxPlayers does not exceed 20',
        build: () => gameCreationBloc,
        seed: () => GameCreationFormState(
          groupId: 'group1',
          groupName: 'Test Group',
          dateTime: futureDate,
          locationName: 'Venice Beach',
          title: 'Beach Volleyball',
          maxPlayers: 21,
        ),
        act: (bloc) => bloc.add(const ValidateForm()),
        expect: () => [
          GameCreationFormState(
            groupId: 'group1',
            groupName: 'Test Group',
            dateTime: futureDate,
            locationName: 'Venice Beach',
            title: 'Beach Volleyball',
            maxPlayers: 21,
            playersError: 'Maximum players cannot exceed 20',
            isValid: false,
          ),
        ],
      );
    });

    group('SubmitGame', () {
      final futureDate = DateTime.now().add(const Duration(days: 1));

      blocTest<GameCreationBloc, GameCreationState>(
        'emits GameCreationSubmitting and GameCreationSuccess when form is valid',
        build: () {
          when(() => mockGameRepository.createGame(any())).thenAnswer(
            (_) async => 'game123',
          );
          return gameCreationBloc;
        },
        seed: () => GameCreationFormState(
          groupId: 'group1',
          groupName: 'Test Group',
          dateTime: futureDate,
          locationName: 'Venice Beach',
          address: '123 Beach Blvd',
          title: 'Beach Volleyball',
          description: 'Casual game',
          maxPlayers: 4,
          minPlayers: 2,
          gameType: GameType.beachVolleyball,
          skillLevel: GameSkillLevel.intermediate,
          isValid: true,
        ),
        act: (bloc) => bloc.add(const SubmitGame(createdBy: 'user123')),
        expect: () => [
          const GameCreationSubmitting(),
          isA<GameCreationSuccess>()
              .having((s) => s.gameId, 'gameId', equals('game123'))
              .having((s) => s.game.title, 'game.title', equals('Beach Volleyball'))
              .having((s) => s.game.groupId, 'game.groupId', equals('group1'))
              .having((s) => s.game.createdBy, 'game.createdBy', equals('user123'))
              .having((s) => s.game.playerIds, 'game.playerIds', contains('user123')),
        ],
        verify: (_) {
          verify(() => mockGameRepository.createGame(any())).called(1);
        },
      );

      blocTest<GameCreationBloc, GameCreationState>(
        'emits validation errors when form is invalid',
        build: () => gameCreationBloc,
        seed: () => const GameCreationFormState(),
        act: (bloc) => bloc.add(const SubmitGame(createdBy: 'user123')),
        expect: () => [
          const GameCreationFormState(
            groupError: 'Please select a group',
            dateTimeError: 'Please select a date and time',
            locationError: 'Please enter a location',
            titleError: 'Please enter a game title',
            isValid: false,
          ),
        ],
        verify: (_) {
          verifyNever(() => mockGameRepository.createGame(any()));
        },
      );

      blocTest<GameCreationBloc, GameCreationState>(
        'emits GameCreationError when repository throws exception',
        build: () {
          when(() => mockGameRepository.createGame(any())).thenThrow(
            Exception('Failed to create game'),
          );
          return gameCreationBloc;
        },
        seed: () => GameCreationFormState(
          groupId: 'group1',
          groupName: 'Test Group',
          dateTime: futureDate,
          locationName: 'Venice Beach',
          title: 'Beach Volleyball',
          isValid: true,
        ),
        act: (bloc) => bloc.add(const SubmitGame(createdBy: 'user123')),
        expect: () => [
          const GameCreationSubmitting(),
          isA<GameCreationError>()
              .having((s) => s.message, 'message', contains('Failed to create game'))
              .having((s) => s.errorCode, 'errorCode', equals('CREATE_GAME_ERROR')),
        ],
      );
    });

    group('ResetForm', () {
      blocTest<GameCreationBloc, GameCreationState>(
        'resets form to initial state',
        build: () => gameCreationBloc,
        seed: () => GameCreationFormState(
          groupId: 'group1',
          groupName: 'Test Group',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          locationName: 'Venice Beach',
          title: 'Beach Volleyball',
        ),
        act: (bloc) => bloc.add(const ResetForm()),
        expect: () => [
          const GameCreationFormState(),
        ],
      );
    });
  });
}
