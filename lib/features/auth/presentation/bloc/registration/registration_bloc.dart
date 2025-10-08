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

      // Update display name if provided
      if (event.displayName != null && event.displayName!.trim().isNotEmpty) {
        try {
          await _authRepository.updateUserProfile(
            displayName: event.displayName!.trim(),
          );
          debugPrint('✅ RegistrationBloc: Display name updated');
        } catch (e) {
          debugPrint('⚠️ RegistrationBloc: Failed to update display name: $e');
          // Don't fail registration if display name update fails
        }
      }

      // Send email verification
      try {
        await _authRepository.sendEmailVerification();
        debugPrint('✅ RegistrationBloc: Email verification sent');
      } catch (e) {
        debugPrint('⚠️ RegistrationBloc: Failed to send email verification: $e');
        // Don't fail registration if email verification fails
      }

      emit(const RegistrationSuccess());
    } catch (error) {
      debugPrint('❌ RegistrationBloc: Registration failed: $error');
      String errorMessage = error.toString();
      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      // Also handle nested exceptions like "Exception: Exception: message"
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
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
    if (event.email.trim().isEmpty) {
      return 'Email cannot be empty';
    }

    if (!_isValidEmail(event.email)) {
      return 'Please enter a valid email address';
    }

    if (event.password.trim().isEmpty) {
      return 'Password cannot be empty';
    }

    if (event.password.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    if (event.password != event.confirmPassword) {
      return 'Passwords do not match';
    }

    if (event.displayName != null && event.displayName!.trim().length > 50) {
      return 'Display name must be less than 50 characters';
    }

    return null;
  }

  /// Basic email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\+\-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}