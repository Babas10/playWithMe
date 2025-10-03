import 'package:equatable/equatable.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to submit registration form
class RegistrationSubmitted extends RegistrationEvent {
  const RegistrationSubmitted({
    required this.email,
    required this.password,
    required this.confirmPassword,
    this.displayName,
  });

  final String email;
  final String password;
  final String confirmPassword;
  final String? displayName;

  @override
  List<Object?> get props => [email, password, confirmPassword, displayName];
}

/// Event to reset the registration form state
class RegistrationFormReset extends RegistrationEvent {
  const RegistrationFormReset();
}