import 'package:equatable/equatable.dart';

abstract class PasswordResetEvent extends Equatable {
  const PasswordResetEvent();

  @override
  List<Object?> get props => [];
}

/// Event to request password reset
class PasswordResetRequested extends PasswordResetEvent {
  const PasswordResetRequested({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

/// Event to reset the password reset form state
class PasswordResetFormReset extends PasswordResetEvent {
  const PasswordResetFormReset();
}