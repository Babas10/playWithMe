// Events for the InviteRegistrationBloc.
import 'package:equatable/equatable.dart';

sealed class InviteRegistrationEvent extends Equatable {
  const InviteRegistrationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to submit the invite registration form.
class InviteRegistrationSubmitted extends InviteRegistrationEvent {
  final String fullName;
  final String displayName;
  final String email;
  final String password;
  final String confirmPassword;
  final String token;

  const InviteRegistrationSubmitted({
    required this.fullName,
    required this.displayName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.token,
  });

  @override
  List<Object?> get props => [
        fullName,
        displayName,
        email,
        password,
        confirmPassword,
        token,
      ];
}

/// Event to reset the invite registration form state.
class InviteRegistrationFormReset extends InviteRegistrationEvent {
  const InviteRegistrationFormReset();
}
