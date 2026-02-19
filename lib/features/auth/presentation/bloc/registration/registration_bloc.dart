import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/registration/registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final AuthRepository _authRepository;

  RegistrationBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const RegistrationInitial()) {
    on<RegistrationSubmitted>(_onRegistrationSubmitted);
    on<RegistrationFormReset>(_onRegistrationFormReset);
  }

  Future<void> _onRegistrationSubmitted(
    RegistrationSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    emit(const RegistrationLoading());

    try {
      debugPrint('🔐 RegistrationBloc: Attempting registration with email: ${event.email}');

      // Validate input
      final validationError = _validateInput(event);
      if (validationError != null) {
        emit(RegistrationFailure(validationError));
        return;
      }

      // Create user
      final user = await _authRepository.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );

      debugPrint('✅ RegistrationBloc: User created: ${user.email}');

      // Update display name
      try {
        await _authRepository.updateUserProfile(displayName: event.displayName.trim());
        debugPrint('✅ RegistrationBloc: Display name updated');
      } catch (e) {
        debugPrint('⚠️ RegistrationBloc: Failed to update display name: $e');
      }

      // Persist firstName and lastName to Firestore via Cloud Function
      try {
        await _authRepository.updateUserNames(
          firstName: event.firstName.trim(),
          lastName: event.lastName.trim(),
        );
        debugPrint('✅ RegistrationBloc: First/last name persisted to Firestore');
      } catch (e) {
        debugPrint('⚠️ RegistrationBloc: Failed to persist names: $e');
      }

      // NOTE: Firestore user document is automatically created by the Cloud Function
      // createUserDocument (functions/src/createUserDocument.ts) when the Auth user is created.
      // No manual client-side creation needed to avoid permission conflicts.
      debugPrint('ℹ️ RegistrationBloc: Firestore document will be created by Cloud Function');

      // Send email verification
      try {
        await _authRepository.sendEmailVerification();
        debugPrint('✅ RegistrationBloc: Email verification sent');
      } catch (e) {
        debugPrint('⚠️ RegistrationBloc: Failed to send email verification: $e');
      }

      emit(const RegistrationSuccess());
    } catch (error) {
      String errorMessage = error.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      debugPrint('❌ RegistrationBloc: Registration failed: $errorMessage');
      emit(RegistrationFailure(errorMessage));
    }
  }

  void _onRegistrationFormReset(
    RegistrationFormReset event,
    Emitter<RegistrationState> emit,
  ) {
    debugPrint('🔐 RegistrationBloc: Form reset');
    emit(const RegistrationInitial());
  }

  /// Validate registration input
  String? _validateInput(RegistrationSubmitted event) {
    if (event.firstName.trim().isEmpty) {
      return 'First name is required';
    }

    if (event.firstName.trim().length < 2) {
      return 'First name must be at least 2 characters';
    }

    if (event.lastName.trim().isEmpty) {
      return 'Last name is required';
    }

    if (event.lastName.trim().length < 2) {
      return 'Last name must be at least 2 characters';
    }

    if (event.displayName.trim().isEmpty) {
      return 'Display name is required';
    }

    if (event.displayName.trim().length < 3) {
      return 'Display name must be at least 3 characters';
    }

    if (event.displayName.trim().length > 30) {
      return 'Display name must be at most 30 characters';
    }

    if (event.email.trim().isEmpty) {
      return 'Email cannot be empty';
    }

    if (!_isValidEmail(event.email)) {
      return 'Please enter a valid email address';
    }

    if (event.password.trim().isEmpty) {
      return 'Password cannot be empty';
    }

    if (event.password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!event.password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least 1 uppercase letter';
    }

    if (!event.password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least 1 number';
    }

    if (event.password != event.confirmPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Basic email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\+\-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
