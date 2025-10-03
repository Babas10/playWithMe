import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_event.dart';
import 'package:play_with_me/features/auth/presentation/bloc/login/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository _authRepository;

  LoginBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const LoginInitial()) {
    on<LoginWithEmailAndPasswordSubmitted>(_onLoginWithEmailAndPasswordSubmitted);
    on<LoginAnonymouslySubmitted>(_onLoginAnonymouslySubmitted);
    on<LoginFormReset>(_onLoginFormReset);
  }

  Future<void> _onLoginWithEmailAndPasswordSubmitted(
    LoginWithEmailAndPasswordSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    try {
      debugPrint('🔐 LoginBloc: Attempting login with email: ${event.email}');

      // Basic validation
      if (event.email.trim().isEmpty) {
        emit(const LoginFailure('Email cannot be empty'));
        return;
      }

      if (event.password.trim().isEmpty) {
        emit(const LoginFailure('Password cannot be empty'));
        return;
      }

      if (!_isValidEmail(event.email)) {
        emit(const LoginFailure('Please enter a valid email address'));
        return;
      }

      await _authRepository.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );

      debugPrint('✅ LoginBloc: Login successful');
      emit(const LoginSuccess());
    } catch (error) {
      debugPrint('❌ LoginBloc: Login failed: $error');
      final errorMessage = error.toString().replaceFirst('Exception: ', '');
      emit(LoginFailure(errorMessage));
    }
  }

  Future<void> _onLoginAnonymouslySubmitted(
    LoginAnonymouslySubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    try {
      debugPrint('🔐 LoginBloc: Attempting anonymous login');

      await _authRepository.signInAnonymously();

      debugPrint('✅ LoginBloc: Anonymous login successful');
      emit(const LoginSuccess());
    } catch (error) {
      debugPrint('❌ LoginBloc: Anonymous login failed: $error');
      final errorMessage = error.toString().replaceFirst('Exception: ', '');
      emit(LoginFailure(errorMessage));
    }
  }

  void _onLoginFormReset(
    LoginFormReset event,
    Emitter<LoginState> emit,
  ) {
    debugPrint('🔐 LoginBloc: Form reset');
    emit(const LoginInitial());
  }

  /// Basic email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}