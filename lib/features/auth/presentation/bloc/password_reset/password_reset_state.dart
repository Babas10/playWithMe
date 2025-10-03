import 'package:equatable/equatable.dart';

abstract class PasswordResetState extends Equatable {
  const PasswordResetState();

  @override
  List<Object?> get props => [];
}

/// Initial state of the password reset form
class PasswordResetInitial extends PasswordResetState {
  const PasswordResetInitial();
}

/// State when password reset is in progress
class PasswordResetLoading extends PasswordResetState {
  const PasswordResetLoading();
}

/// State when password reset email is sent successfully
class PasswordResetSuccess extends PasswordResetState {
  const PasswordResetSuccess(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

/// State when password reset fails
class PasswordResetFailure extends PasswordResetState {
  const PasswordResetFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}