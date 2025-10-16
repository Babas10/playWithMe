import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/email_verification/email_verification_state.dart';

/// BLoC for managing email verification flow
class EmailVerificationBloc
    extends Bloc<EmailVerificationEvent, EmailVerificationState> {
  final AuthRepository _authRepository;

  /// Cooldown duration between resend attempts (60 seconds)
  static const int resendCooldownSeconds = 60;

  /// Track last sent time for cooldown
  DateTime? _lastSentAt;

  /// Subscription to auth state changes
  StreamSubscription<dynamic>? _authStateSubscription;

  EmailVerificationBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const EmailVerificationState.initial()) {
    on<EmailVerificationCheckStatus>(_onCheckStatus);
    on<EmailVerificationSendEmail>(_onSendEmail);
    on<EmailVerificationRefreshStatus>(_onRefreshStatus);
    on<EmailVerificationResetError>(_onResetError);
    on<EmailVerificationAuthStateChanged>(_onAuthStateChanged);

    // Listen to auth state changes for real-time verification updates
    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null && user.isEmailVerified) {
        add(EmailVerificationEvent.authStateChanged(
          isVerified: true,
          verifiedAt: user.lastSignInAt,
        ));
      }
    });
  }

  Future<void> _onCheckStatus(
    EmailVerificationCheckStatus event,
    Emitter<EmailVerificationState> emit,
  ) async {
    emit(const EmailVerificationState.loading());

    try {
      // Get current user
      final user = _authRepository.currentUser;

      if (user == null) {
        emit(const EmailVerificationState.error(
          message: 'No user is currently signed in',
        ));
        return;
      }

      // Check verification status
      if (user.isEmailVerified) {
        emit(EmailVerificationState.verified(verifiedAt: user.lastSignInAt));
      } else {
        final cooldown = _calculateCooldown();
        emit(EmailVerificationState.pending(
          email: user.email,
          emailSent: _lastSentAt != null,
          lastSentAt: _lastSentAt,
          resendCooldownSeconds: cooldown,
        ));
      }
    } catch (e) {
      emit(EmailVerificationState.error(
        message: 'Failed to check verification status: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSendEmail(
    EmailVerificationSendEmail event,
    Emitter<EmailVerificationState> emit,
  ) async {
    try {
      // Check cooldown
      final cooldown = _calculateCooldown();
      if (cooldown > 0) {
        emit(EmailVerificationState.error(
          message: 'Please wait $cooldown seconds before resending',
          email: _authRepository.currentUser?.email,
        ));
        return;
      }

      emit(const EmailVerificationState.loading());

      // Get current user
      final user = _authRepository.currentUser;
      if (user == null) {
        emit(const EmailVerificationState.error(
          message: 'No user is currently signed in',
        ));
        return;
      }

      // Check if already verified
      if (user.isEmailVerified) {
        emit(EmailVerificationState.verified(verifiedAt: user.lastSignInAt));
        return;
      }

      // Send verification email
      await _authRepository.sendEmailVerification();

      // Update last sent time
      _lastSentAt = DateTime.now();

      // Emit success state
      emit(EmailVerificationState.emailSent(
        email: user.email,
        sentAt: _lastSentAt!,
        resendCooldownSeconds: resendCooldownSeconds,
      ));

      // After a brief delay, transition to pending state
      await Future.delayed(const Duration(seconds: 2));
      emit(EmailVerificationState.pending(
        email: user.email,
        emailSent: true,
        lastSentAt: _lastSentAt,
        resendCooldownSeconds: resendCooldownSeconds,
      ));
    } catch (e) {
      emit(EmailVerificationState.error(
        message: 'Failed to send verification email: ${e.toString()}',
        email: _authRepository.currentUser?.email,
      ));
    }
  }

  Future<void> _onRefreshStatus(
    EmailVerificationRefreshStatus event,
    Emitter<EmailVerificationState> emit,
  ) async {
    emit(const EmailVerificationState.loading());

    try {
      // Reload user data from Firebase
      await _authRepository.reloadUser();

      // Get updated user
      final user = _authRepository.currentUser;

      if (user == null) {
        emit(const EmailVerificationState.error(
          message: 'No user is currently signed in',
        ));
        return;
      }

      // Check updated verification status
      if (user.isEmailVerified) {
        emit(EmailVerificationState.verified(verifiedAt: user.lastSignInAt));
      } else {
        final cooldown = _calculateCooldown();
        emit(EmailVerificationState.pending(
          email: user.email,
          emailSent: _lastSentAt != null,
          lastSentAt: _lastSentAt,
          resendCooldownSeconds: cooldown,
        ));
      }
    } catch (e) {
      emit(EmailVerificationState.error(
        message: 'Failed to refresh verification status: ${e.toString()}',
        email: _authRepository.currentUser?.email,
      ));
    }
  }

  Future<void> _onResetError(
    EmailVerificationResetError event,
    Emitter<EmailVerificationState> emit,
  ) async {
    // Return to appropriate state based on current user status
    final user = _authRepository.currentUser;
    if (user == null) {
      emit(const EmailVerificationState.initial());
      return;
    }

    if (user.isEmailVerified) {
      emit(EmailVerificationState.verified(verifiedAt: user.lastSignInAt));
    } else {
      final cooldown = _calculateCooldown();
      emit(EmailVerificationState.pending(
        email: user.email,
        emailSent: _lastSentAt != null,
        lastSentAt: _lastSentAt,
        resendCooldownSeconds: cooldown,
      ));
    }
  }

  Future<void> _onAuthStateChanged(
    EmailVerificationAuthStateChanged event,
    Emitter<EmailVerificationState> emit,
  ) async {
    if (event.isVerified) {
      emit(EmailVerificationState.verified(verifiedAt: event.verifiedAt));
    }
  }

  /// Calculate remaining cooldown seconds
  int _calculateCooldown() {
    if (_lastSentAt == null) return 0;

    final elapsed = DateTime.now().difference(_lastSentAt!).inSeconds;
    final remaining = resendCooldownSeconds - elapsed;

    return remaining > 0 ? remaining : 0;
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
