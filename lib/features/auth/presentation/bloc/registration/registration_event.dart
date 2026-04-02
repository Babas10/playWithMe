import 'package:equatable/equatable.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to submit registration form
class RegistrationSubmitted extends RegistrationEvent {
  const RegistrationSubmitted({
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.gender,
  });

  final String firstName;
  final String lastName;
  final String displayName;
  final String email;
  final String password;
  final String confirmPassword;
  /// Gender value as stored in Firestore: 'male', 'female', or 'none'.
  final String gender;

  @override
  List<Object?> get props => [firstName, lastName, displayName, email, password, confirmPassword, gender];
}

/// Event to reset the registration form state
class RegistrationFormReset extends RegistrationEvent {
  const RegistrationFormReset();
}
