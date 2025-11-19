// Validates GameCreationBloc manages game creation form state and submission logic.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data/models/game_model.dart';
import '../../../../../core/domain/repositories/game_repository.dart';
import 'game_creation_event.dart';
import 'game_creation_state.dart';

class GameCreationBloc extends Bloc<GameCreationEvent, GameCreationState> {
  final GameRepository _gameRepository;

  GameCreationBloc({
    required GameRepository gameRepository,
  })  : _gameRepository = gameRepository,
        super(const GameCreationInitial()) {
    on<SelectGroup>(_onSelectGroup);
    on<SetDateTime>(_onSetDateTime);
    on<SetLocation>(_onSetLocation);
    on<SetTitle>(_onSetTitle);
    on<SetDescription>(_onSetDescription);
    on<SetMaxPlayers>(_onSetMaxPlayers);
    on<SetMinPlayers>(_onSetMinPlayers);
    on<SetGameType>(_onSetGameType);
    on<SetSkillLevel>(_onSetSkillLevel);
    on<ValidateForm>(_onValidateForm);
    on<SubmitGame>(_onSubmitGame);
    on<ResetForm>(_onResetForm);
  }

  GameCreationFormState get _currentFormState {
    final currentState = state;
    if (currentState is GameCreationFormState) {
      return currentState;
    }
    return const GameCreationFormState();
  }

  void _onSelectGroup(SelectGroup event, Emitter<GameCreationState> emit) {
    final formState = _currentFormState.copyWith(
      groupId: event.groupId,
      groupName: event.groupName,
      groupError: null,
    );
    emit(_validateAndEmit(formState));
  }

  void _onSetDateTime(SetDateTime event, Emitter<GameCreationState> emit) {
    final formState = _currentFormState.copyWith(
      dateTime: event.dateTime,
      dateTimeError: null,
    );
    emit(_validateAndEmit(formState));
  }

  void _onSetLocation(SetLocation event, Emitter<GameCreationState> emit) {
    final formState = _currentFormState.copyWith(
      locationName: event.locationName,
      address: event.address,
      locationError: null,
    );
    emit(_validateAndEmit(formState));
  }

  void _onSetTitle(SetTitle event, Emitter<GameCreationState> emit) {
    final formState = _currentFormState.copyWith(
      title: event.title,
      titleError: null,
    );
    emit(_validateAndEmit(formState));
  }

  void _onSetDescription(
      SetDescription event, Emitter<GameCreationState> emit) {
    final formState = _currentFormState.copyWith(
      description: event.description,
    );
    emit(formState);
  }

  void _onSetMaxPlayers(SetMaxPlayers event, Emitter<GameCreationState> emit) {
    final formState = _currentFormState.copyWith(
      maxPlayers: event.maxPlayers,
      playersError: null,
    );
    emit(_validateAndEmit(formState));
  }

  void _onSetMinPlayers(SetMinPlayers event, Emitter<GameCreationState> emit) {
    final formState = _currentFormState.copyWith(
      minPlayers: event.minPlayers,
      playersError: null,
    );
    emit(_validateAndEmit(formState));
  }

  void _onSetGameType(SetGameType event, Emitter<GameCreationState> emit) {
    final formState = _currentFormState.copyWith(
      gameType: event.gameType,
    );
    emit(formState);
  }

  void _onSetSkillLevel(
      SetSkillLevel event, Emitter<GameCreationState> emit) {
    final formState = _currentFormState.copyWith(
      skillLevel: event.skillLevel,
    );
    emit(formState);
  }

  void _onValidateForm(ValidateForm event, Emitter<GameCreationState> emit) {
    emit(_validateAndEmit(_currentFormState));
  }

  Future<void> _onSubmitGame(
      SubmitGame event, Emitter<GameCreationState> emit) async {
    final formState = _currentFormState;

    // Validate form
    final validatedState = _validateForm(formState);
    if (!validatedState.isValid) {
      emit(validatedState);
      return;
    }

    try {
      emit(const GameCreationSubmitting());

      // Create game model
      final game = GameModel(
        id: '', // Will be set by Firestore
        title: formState.title,
        description: formState.description,
        groupId: formState.groupId!,
        createdBy: event.createdBy,
        createdAt: DateTime.now(),
        scheduledAt: formState.dateTime!,
        location: GameLocation(
          name: formState.locationName!,
          address: formState.address,
        ),
        maxPlayers: formState.maxPlayers,
        minPlayers: formState.minPlayers,
        gameType: formState.gameType,
        skillLevel: formState.skillLevel,
        playerIds: [event.createdBy], // Creator is automatically a player
      );

      // Create game in repository
      final gameId = await _gameRepository.createGame(game);
      final createdGame = game.copyWith(id: gameId);

      emit(GameCreationSuccess(
        gameId: gameId,
        game: createdGame,
      ));
    } catch (e) {
      emit(GameCreationError(
        message: 'Failed to create game: ${e.toString()}',
        errorCode: 'CREATE_GAME_ERROR',
      ));
    }
  }

  void _onResetForm(ResetForm event, Emitter<GameCreationState> emit) {
    emit(const GameCreationFormState());
  }

  /// Validates the form and returns a new state with validation errors
  GameCreationFormState _validateForm(GameCreationFormState formState) {
    String? groupError;
    String? dateTimeError;
    String? locationError;
    String? titleError;
    String? playersError;

    // Validate group selection
    if (formState.groupId == null || formState.groupId!.isEmpty) {
      groupError = 'Please select a group';
    }

    // Validate date and time
    if (formState.dateTime == null) {
      dateTimeError = 'Please select a date and time';
    } else if (formState.dateTime!.isBefore(DateTime.now())) {
      dateTimeError = 'Game date must be in the future';
    }

    // Validate location
    if (formState.locationName == null || formState.locationName!.trim().isEmpty) {
      locationError = 'Please enter a location';
    }

    // Validate title
    if (formState.title.trim().isEmpty) {
      titleError = 'Please enter a game title';
    } else if (formState.title.trim().length < 3) {
      titleError = 'Title must be at least 3 characters';
    } else if (formState.title.trim().length > 100) {
      titleError = 'Title must be less than 100 characters';
    }

    // Validate player limits
    if (formState.minPlayers < 2) {
      playersError = 'Minimum players must be at least 2';
    } else if (formState.maxPlayers < formState.minPlayers) {
      playersError = 'Maximum players must be greater than or equal to minimum players';
    } else if (formState.maxPlayers > 20) {
      playersError = 'Maximum players cannot exceed 20';
    }

    final isValid = groupError == null &&
        dateTimeError == null &&
        locationError == null &&
        titleError == null &&
        playersError == null;

    return formState.copyWith(
      groupError: groupError,
      dateTimeError: dateTimeError,
      locationError: locationError,
      titleError: titleError,
      playersError: playersError,
      isValid: isValid,
    );
  }

  /// Helper method to validate and emit state
  GameCreationFormState _validateAndEmit(GameCreationFormState formState) {
    return _validateForm(formState);
  }
}
