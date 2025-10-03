import 'package:equatable/equatable.dart';

abstract class RegistrationState extends Equatable {
  const RegistrationState();

  @override
  List<Object?> get props => [];
}

/// Initial state of the registration form
class RegistrationInitial extends RegistrationState {
  const RegistrationInitial();
}

/// State when registration is in progress
class RegistrationLoading extends RegistrationState {
  const RegistrationLoading();
}

/// State when registration succeeds
class RegistrationSuccess extends RegistrationState {
  const RegistrationSuccess();
}

/// State when registration fails
class RegistrationFailure extends RegistrationState {
  const RegistrationFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}