import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/password_reset/password_reset_state.dart';

class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  final AuthRepository _authRepository;

  PasswordResetBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const PasswordResetInitial()) {
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<PasswordResetFormReset>(_onPasswordResetFormReset);
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<PasswordResetState> emit,
  ) async {
    emit(const PasswordResetLoading());

    try {
      debugPrint('🔐 PasswordResetBloc: Requesting password reset for: ${event.email}');

      // Basic validation
      if (event.email.trim().isEmpty) {
        emit(const PasswordResetFailure('Email cannot be empty'));
        return;
      }

      if (!_isValidEmail(event.email)) {
        emit(const PasswordResetFailure('Please enter a valid email address'));
        return;
      }

      await _authRepository.sendPasswordResetEmail(
        email: event.email.trim(),
      );

      debugPrint('✅ PasswordResetBloc: Password reset email sent successfully');
      emit(PasswordResetSuccess(event.email.trim()));
    } catch (error) {
      debugPrint('❌ PasswordResetBloc: Password reset failed: $error');
      final errorMessage = error.toString().replaceFirst('Exception: ', '');
      emit(PasswordResetFailure(errorMessage));
    }
  }

  void _onPasswordResetFormReset(
    PasswordResetFormReset event,
    Emitter<PasswordResetState> emit,
  ) {
    debugPrint('🔐 PasswordResetBloc: Form reset');
    emit(const PasswordResetInitial());
  }

  /// Basic email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\+\-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}