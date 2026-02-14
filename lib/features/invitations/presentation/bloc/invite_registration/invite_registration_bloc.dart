// BLoC for invite-based account creation with automatic group join.
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/group_invite_link_repository.dart';
import 'package:play_with_me/core/services/pending_invite_storage.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_event.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_registration/invite_registration_state.dart';

class InviteRegistrationBloc
    extends Bloc<InviteRegistrationEvent, InviteRegistrationState> {
  final AuthRepository _authRepository;
  final GroupInviteLinkRepository _groupInviteLinkRepository;
  final PendingInviteStorage _pendingInviteStorage;

  InviteRegistrationBloc({
    required AuthRepository authRepository,
    required GroupInviteLinkRepository groupInviteLinkRepository,
    required PendingInviteStorage pendingInviteStorage,
  })  : _authRepository = authRepository,
        _groupInviteLinkRepository = groupInviteLinkRepository,
        _pendingInviteStorage = pendingInviteStorage,
        super(const InviteRegistrationInitial()) {
    on<InviteRegistrationSubmitted>(_onSubmitted);
    on<InviteRegistrationFormReset>(_onFormReset);
  }

  Future<void> _onSubmitted(
    InviteRegistrationSubmitted event,
    Emitter<InviteRegistrationState> emit,
  ) async {
    emit(const InviteRegistrationCreatingAccount());

    try {
      // Validate input
      final validationError = _validateInput(event);
      if (validationError != null) {
        emit(InviteRegistrationFailure(message: validationError));
        return;
      }

      // Step 1: Create Firebase Auth account
      debugPrint(
          '🔐 InviteRegistrationBloc: Creating account for ${event.email}');
      await _authRepository.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );
      debugPrint('✅ InviteRegistrationBloc: Account created');

      // Step 2: Update display name
      try {
        await _authRepository.updateUserProfile(
          displayName: event.displayName.trim(),
        );
        debugPrint('✅ InviteRegistrationBloc: Display name updated');
      } catch (e) {
        debugPrint(
            '⚠️ InviteRegistrationBloc: Failed to update display name: $e');
      }

      // Step 3: Send email verification (non-blocking)
      try {
        await _authRepository.sendEmailVerification();
        debugPrint('✅ InviteRegistrationBloc: Verification email sent');
      } catch (e) {
        debugPrint(
            '⚠️ InviteRegistrationBloc: Failed to send verification: $e');
      }

      // Step 4: Join group via invite token
      emit(const InviteRegistrationJoiningGroup());
      debugPrint(
          '🔐 InviteRegistrationBloc: Joining group with token: ${event.token}');

      try {
        final joinResult = await _groupInviteLinkRepository.joinGroupViaInvite(
          token: event.token,
        );

        // Step 5: Clear pending invite
        await _pendingInviteStorage.clear();
        debugPrint(
            '✅ InviteRegistrationBloc: Joined group ${joinResult.groupName}');

        emit(InviteRegistrationSuccess(
          groupId: joinResult.groupId,
          groupName: joinResult.groupName,
        ));
      } on GroupInviteLinkException catch (e) {
        // Token expired or invalid — account was still created successfully
        await _pendingInviteStorage.clear();
        if (e.code == 'failed-precondition') {
          debugPrint(
              '⚠️ InviteRegistrationBloc: Token expired during registration');
          emit(const InviteRegistrationTokenExpired());
        } else {
          emit(InviteRegistrationFailure(
            message: e.message,
            errorCode: e.code,
          ));
        }
      }
    } catch (error) {
      final errorMessage = _mapFirebaseError(error.toString());
      final errorCode = _extractErrorCode(error.toString());
      debugPrint(
          '❌ InviteRegistrationBloc: Registration failed: $errorMessage');
      emit(InviteRegistrationFailure(
        message: errorMessage,
        errorCode: errorCode,
      ));
    }
  }

  void _onFormReset(
    InviteRegistrationFormReset event,
    Emitter<InviteRegistrationState> emit,
  ) {
    emit(const InviteRegistrationInitial());
  }

  String? _validateInput(InviteRegistrationSubmitted event) {
    if (event.fullName.trim().isEmpty) {
      return 'Full name is required';
    }
    if (event.fullName.trim().length < 2) {
      return 'Full name must be at least 2 characters';
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
      return 'Email is required';
    }
    if (!_isValidEmail(event.email)) {
      return 'Please enter a valid email address';
    }
    if (event.password.isEmpty) {
      return 'Password is required';
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

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\+\-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _mapFirebaseError(String error) {
    if (error.contains('email-already-in-use')) {
      return 'An account with this email already exists. Try logging in instead.';
    }
    if (error.contains('weak-password')) {
      return 'Password is too weak. Use at least 8 characters.';
    }
    if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    }
    if (error.contains('network-request-failed') ||
        error.contains('network')) {
      return 'Unable to connect. Please check your connection and try again.';
    }
    // Clean up error prefix
    String cleanError = error;
    if (cleanError.startsWith('Exception: ')) {
      cleanError = cleanError.substring(11);
    }
    if (cleanError.startsWith('Exception: ')) {
      cleanError = cleanError.substring(11);
    }
    return cleanError;
  }

  String? _extractErrorCode(String error) {
    if (error.contains('email-already-in-use')) return 'email-already-in-use';
    if (error.contains('weak-password')) return 'weak-password';
    if (error.contains('invalid-email')) return 'invalid-email';
    if (error.contains('network-request-failed')) {
      return 'network-request-failed';
    }
    return null;
  }
}
