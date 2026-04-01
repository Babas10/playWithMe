import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/repositories/user_repository.dart';
import 'package:play_with_me/features/onboarding/presentation/bloc/gender_selection/gender_selection_event.dart';
import 'package:play_with_me/features/onboarding/presentation/bloc/gender_selection/gender_selection_state.dart';

class GenderSelectionBloc
    extends Bloc<GenderSelectionEvent, GenderSelectionState> {
  GenderSelectionBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const GenderSelectionInitial()) {
    on<CheckGenderSelection>(_onCheckGenderSelection);
    on<GenderOptionSelected>(_onGenderOptionSelected);
    on<GenderSelectionConfirmed>(_onGenderSelectionConfirmed);
  }

  final UserRepository _userRepository;

  Future<void> _onCheckGenderSelection(
    CheckGenderSelection event,
    Emitter<GenderSelectionState> emit,
  ) async {
    emit(const GenderSelectionChecking());
    try {
      final user = await _userRepository.getUserById(event.uid);
      if (user == null || user.gender != null) {
        debugPrint(
          '✅ GenderSelectionBloc: Gender already set for ${event.uid}',
        );
        emit(const GenderSelectionNotRequired());
      } else {
        debugPrint(
          '⚠️ GenderSelectionBloc: Gender required for ${event.uid}',
        );
        emit(GenderSelectionRequired(uid: event.uid));
      }
    } catch (e) {
      debugPrint('❌ GenderSelectionBloc: Error checking gender: $e');
      // Default to not required on error to avoid blocking the user.
      emit(const GenderSelectionNotRequired());
    }
  }

  void _onGenderOptionSelected(
    GenderOptionSelected event,
    Emitter<GenderSelectionState> emit,
  ) {
    final current = state;
    if (current is GenderSelectionRequired) {
      emit(
        GenderSelectionRequired(
          uid: current.uid,
          selectedGender: event.gender,
        ),
      );
    }
  }

  Future<void> _onGenderSelectionConfirmed(
    GenderSelectionConfirmed event,
    Emitter<GenderSelectionState> emit,
  ) async {
    final current = state;
    if (current is! GenderSelectionRequired ||
        current.selectedGender == null) {
      return;
    }
    emit(const GenderSelectionSaving());
    try {
      await _userRepository.updateUserProfile(
        current.uid,
        gender: current.selectedGender,
      );
      debugPrint(
        '✅ GenderSelectionBloc: Gender saved — ${current.selectedGender}',
      );
      emit(const GenderSelectionSaved());
    } catch (e) {
      debugPrint('❌ GenderSelectionBloc: Error saving gender: $e');
      emit(GenderSelectionError(message: e.toString()));
    }
  }
}
