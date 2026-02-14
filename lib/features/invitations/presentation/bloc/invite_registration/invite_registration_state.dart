// States for the InviteRegistrationBloc.
import 'package:equatable/equatable.dart';

sealed class InviteRegistrationState extends Equatable {
  const InviteRegistrationState();

  @override
  List<Object?> get props => [];
}

/// Initial state of the invite registration form.
class InviteRegistrationInitial extends InviteRegistrationState {
  const InviteRegistrationInitial();
}

/// State when account is being created.
class InviteRegistrationCreatingAccount extends InviteRegistrationState {
  const InviteRegistrationCreatingAccount();
}

/// State when account was created and now joining group.
class InviteRegistrationJoiningGroup extends InviteRegistrationState {
  const InviteRegistrationJoiningGroup();
}

/// State when registration and group join succeeded.
class InviteRegistrationSuccess extends InviteRegistrationState {
  final String groupId;
  final String groupName;

  const InviteRegistrationSuccess({
    required this.groupId,
    required this.groupName,
  });

  @override
  List<Object?> get props => [groupId, groupName];
}

/// State when registration fails.
class InviteRegistrationFailure extends InviteRegistrationState {
  final String message;
  final String? errorCode;

  const InviteRegistrationFailure({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// State when invite token expired during registration.
/// Account was created but group join failed due to expired token.
class InviteRegistrationTokenExpired extends InviteRegistrationState {
  const InviteRegistrationTokenExpired();
}
