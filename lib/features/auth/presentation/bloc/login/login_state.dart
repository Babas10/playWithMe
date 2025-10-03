import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

/// Initial state of the login form
class LoginInitial extends LoginState {
  const LoginInitial();
}

/// State when login is in progress
class LoginLoading extends LoginState {
  const LoginLoading();
}

/// State when login succeeds
class LoginSuccess extends LoginState {
  const LoginSuccess();
}

/// State when login fails
class LoginFailure extends LoginState {
  const LoginFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}