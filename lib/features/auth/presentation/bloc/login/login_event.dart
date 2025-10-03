import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// Event to attempt login with email and password
class LoginWithEmailAndPasswordSubmitted extends LoginEvent {
  const LoginWithEmailAndPasswordSubmitted({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Event to attempt anonymous login
class LoginAnonymouslySubmitted extends LoginEvent {
  const LoginAnonymouslySubmitted();
}

/// Event to reset the login form state
class LoginFormReset extends LoginEvent {
  const LoginFormReset();
}