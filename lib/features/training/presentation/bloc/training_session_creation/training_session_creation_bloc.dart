// Validates CreateTrainingSessionBloc manages training session creation form state and submission logic.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/data/models/game_model.dart';
import '../../../../../core/data/models/training_session_model.dart';
import '../../../../../core/domain/repositories/training_session_repository.dart';
import 'training_session_creation_event.dart';
import 'training_session_creation_state.dart';

class TrainingSessionCreationBloc
    extends Bloc<TrainingSessionCreationEvent, TrainingSessionCreationState> {
  final TrainingSessionRepository _trainingSessionRepository;

  TrainingSessionCreationBloc({
    required TrainingSessionRepository trainingSessionRepository,
  })  : _trainingSessionRepository = trainingSessionRepository,
        super(const TrainingSessionCreationInitial()) {
    on<SelectTrainingGroup>(_onSelectTrainingGroup);
    on<SetStartTime>(_onSetStartTime);
    on<SetEndTime>(_onSetEndTime);
    on<SetTrainingLocation>(_onSetTrainingLocation);
    on<SetTrainingTitle>(_onSetTrainingTitle);
    on<SetTrainingDescription>(_onSetTrainingDescription);
    on<SetMaxParticipants>(_onSetMaxParticipants);
    on<SetMinParticipants>(_onSetMinParticipants);
    on<SetSessionNotes>(_onSetSessionNotes);
    on<SetRecurrenceRule>(_onSetRecurrenceRule); // Story 15.2
    on<GenerateRecurringInstances>(_onGenerateRecurringInstances); // Story 15.2
    on<ValidateTrainingForm>(_onValidateTrainingForm);
    on<SubmitTrainingSession>(_onSubmitTrainingSession);
    on<ResetTrainingForm>(_onResetTrainingForm);
  }

  TrainingSessionCreationFormState get _currentFormState {
    final currentState = state;
    if (currentState is TrainingSessionCreationFormState) {
      return currentState;
    }
    return const TrainingSessionCreationFormState();
  }

  void _onSelectTrainingGroup(
      SelectTrainingGroup event, Emitter<TrainingSessionCreationState> emit) {
    final formState = _currentFormState.copyWith(
      groupId: event.groupId,
      groupName: event.groupName,
      groupError: null,
    );
    emit(_validateAndEmit(formState));
  }

  void _onSetStartTime(
      SetStartTime event, Emitter<TrainingSessionCreationState> emit) {
    final formState = _currentFormState.copyWith(
      startTime: event.startTime,
      startTimeError: null,
      // Also validate end time if it's already set
      endTimeError: null,
    );
    emit(_validateAndEmit(formState));
  }

  void _onSetEndTime(
      SetEndTime event, Emitter<TrainingSessionCreationState> emit) {
    final formState = _currentFormState.copyWith(
      endTime: event.endTime,
      endTimeError: null,
    );
    emit(_validateAndEmit(formState));
  }

  void _onSetTrainingLocation(
      SetTrainingLocation event, Emitter<TrainingSessionCreationState> emit) {
    final formState = _currentFormState.copyWith(
      locationName: event.locationName,
      address: event.address,
      locationError: null,
    );
    emit(_validateAndEmit(formState));
  }

  void _onSetTrainingTitle(
      SetTrainingTitle event, Emitter<TrainingSessionCreationState> emit) {
    final formState = _currentFormState.copyWith(
      title: event.title,
      titleError: null,
    );
    emit(_validateAndEmit(formState));
  }

  void _onSetTrainingDescription(SetTrainingDescription event,
      Emitter<TrainingSessionCreationState> emit) {
    final formState = _currentFormState.copyWith(
      description: event.description,
    );
    emit(formState);
  }

  void _onSetMaxParticipants(
      SetMaxParticipants event, Emitter<TrainingSessionCreationState> emit) {
    final formState = _currentFormState.copyWith(
      maxParticipants: event.maxParticipants,
      participantsError: null,
    );
    emit(_validateAndEmit(formState));
  }

  void _onSetMinParticipants(
      SetMinParticipants event, Emitter<TrainingSessionCreationState> emit) {
    final formState = _currentFormState.copyWith(
      minParticipants: event.minParticipants,
      participantsError: null,
    );
    emit(_validateAndEmit(formState));
  }

  void _onSetSessionNotes(
      SetSessionNotes event, Emitter<TrainingSessionCreationState> emit) {
    final formState = _currentFormState.copyWith(
      notes: event.notes,
    );
    emit(formState);
  }

  // Story 15.2: Handle recurrence rule changes
  void _onSetRecurrenceRule(
      SetRecurrenceRule event, Emitter<TrainingSessionCreationState> emit) {
    final formState = _currentFormState.copyWith(
      recurrenceRule: event.recurrenceRule,
      recurrenceError: null,
      clearRecurrenceRule: event.recurrenceRule == null,
    );
    emit(_validateAndEmit(formState));
  }

  // Story 15.2: Generate recurring training session instances
  Future<void> _onGenerateRecurringInstances(GenerateRecurringInstances event,
      Emitter<TrainingSessionCreationState> emit) async {
    try {
      // Generate instances via repository (calls Cloud Function)
      await _trainingSessionRepository.generateRecurringInstances(
        event.parentSessionId,
      );

      // Success is handled by the existing success state
      // The UI will navigate away automatically
    } catch (e) {
      // If generation fails, we still created the parent session
      // Just log the error and allow the user to try again later
      emit(TrainingSessionCreationError(
        message:
            'Training session created, but failed to generate recurring instances: ${e.toString()}',
        errorCode: 'GENERATE_INSTANCES_ERROR',
      ));
    }
  }

  void _onValidateTrainingForm(ValidateTrainingForm event,
      Emitter<TrainingSessionCreationState> emit) {
    emit(_validateAndEmit(_currentFormState));
  }

  Future<void> _onSubmitTrainingSession(SubmitTrainingSession event,
      Emitter<TrainingSessionCreationState> emit) async {
    final formState = _currentFormState;

    // Validate form
    final validatedState = _validateForm(formState);
    if (!validatedState.isValid) {
      emit(validatedState);
      return;
    }

    try {
      emit(const TrainingSessionCreationSubmitting());

      // Create training session model (Story 15.2: with recurrence rule)
      final session = TrainingSessionModel(
        id: '', // Will be set by Firestore
        groupId: formState.groupId!,
        title: formState.title,
        description: formState.description,
        location: GameLocation(
          name: formState.locationName!,
          address: formState.address,
        ),
        startTime: formState.startTime!,
        endTime: formState.endTime!,
        minParticipants: formState.minParticipants,
        maxParticipants: formState.maxParticipants,
        createdBy: event.createdBy,
        createdAt: DateTime.now(),
        notes: formState.notes,
        recurrenceRule: formState.recurrenceRule, // Story 15.2
      );

      // Create training session in repository
      final sessionId =
          await _trainingSessionRepository.createTrainingSession(session);
      final createdSession = session.copyWith(id: sessionId);

      // Story 15.2: If this is a recurring session, generate instances
      if (formState.recurrenceRule != null &&
          formState.recurrenceRule!.isRecurring) {
        try {
          await _trainingSessionRepository.generateRecurringInstances(sessionId);
        } catch (e) {
          // Instance generation failed, but parent session was created
          // Log error but don't fail the creation
          emit(TrainingSessionCreationError(
            message:
                'Training session created, but failed to generate recurring instances. You can try again later.',
            errorCode: 'GENERATE_INSTANCES_ERROR',
          ));
          return;
        }
      }

      emit(TrainingSessionCreationSuccess(
        sessionId: sessionId,
        session: createdSession,
      ));
    } catch (e) {
      // Check for specific error messages
      String errorMessage = 'Failed to create training session';
      String? errorCode;

      if (e.toString().contains('Creator is not a member of the group')) {
        errorMessage = 'You must be a member of the group to create a training session';
        errorCode = 'NOT_A_MEMBER';
      } else if (e.toString().contains('Group not found')) {
        errorMessage = 'The selected group no longer exists';
        errorCode = 'GROUP_NOT_FOUND';
      } else {
        errorMessage = 'Failed to create training session: ${e.toString()}';
        errorCode = 'CREATE_SESSION_ERROR';
      }

      emit(TrainingSessionCreationError(
        message: errorMessage,
        errorCode: errorCode,
      ));
    }
  }

  void _onResetTrainingForm(
      ResetTrainingForm event, Emitter<TrainingSessionCreationState> emit) {
    emit(const TrainingSessionCreationFormState());
  }

  /// Validates the form and returns a new state with validation errors
  TrainingSessionCreationFormState _validateForm(
      TrainingSessionCreationFormState formState) {
    String? groupError;
    String? startTimeError;
    String? endTimeError;
    String? locationError;
    String? titleError;
    String? participantsError;
    String? recurrenceError; // Story 15.2

    // Validate group selection
    if (formState.groupId == null || formState.groupId!.isEmpty) {
      groupError = 'Please select a group';
    }

    // Validate start time
    if (formState.startTime == null) {
      startTimeError = 'Please select a start time';
    } else if (formState.startTime!.isBefore(DateTime.now())) {
      startTimeError = 'Start time must be in the future';
    }

    // Validate end time
    if (formState.endTime == null) {
      endTimeError = 'Please select an end time';
    } else if (formState.startTime != null &&
        formState.endTime!.isBefore(formState.startTime!)) {
      endTimeError = 'End time must be after start time';
    } else if (formState.startTime != null &&
        formState.endTime!.difference(formState.startTime!).inMinutes < 30) {
      endTimeError = 'Training session must be at least 30 minutes long';
    }

    // Validate location
    if (formState.locationName == null ||
        formState.locationName!.trim().isEmpty) {
      locationError = 'Please enter a location';
    }

    // Validate title
    if (formState.title.trim().isEmpty) {
      titleError = 'Please enter a session title';
    } else if (formState.title.trim().length < 3) {
      titleError = 'Title must be at least 3 characters';
    } else if (formState.title.trim().length > 100) {
      titleError = 'Title must be less than 100 characters';
    }

    // Validate participant limits
    if (formState.minParticipants < 2) {
      participantsError = 'Minimum participants must be at least 2';
    } else if (formState.maxParticipants < formState.minParticipants) {
      participantsError =
          'Maximum participants must be greater than or equal to minimum participants';
    } else if (formState.maxParticipants > 30) {
      participantsError = 'Maximum participants cannot exceed 30';
    }

    // Story 15.2: Validate recurrence rule if present
    if (formState.recurrenceRule != null &&
        formState.recurrenceRule!.isRecurring) {
      if (!formState.recurrenceRule!.isValid) {
        recurrenceError = 'Invalid recurrence rule configuration';
      }
    }

    final isValid = groupError == null &&
        startTimeError == null &&
        endTimeError == null &&
        locationError == null &&
        titleError == null &&
        participantsError == null &&
        recurrenceError == null; // Story 15.2

    return formState.copyWith(
      groupError: groupError,
      startTimeError: startTimeError,
      endTimeError: endTimeError,
      locationError: locationError,
      titleError: titleError,
      participantsError: participantsError,
      recurrenceError: recurrenceError, // Story 15.2
      isValid: isValid,
    );
  }

  /// Helper method to validate and emit state
  TrainingSessionCreationFormState _validateAndEmit(
      TrainingSessionCreationFormState formState) {
    return _validateForm(formState);
  }
}
