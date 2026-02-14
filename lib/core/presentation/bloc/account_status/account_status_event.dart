// Events for the AccountStatusBloc.
import 'package:equatable/equatable.dart';

sealed class AccountStatusEvent extends Equatable {
  const AccountStatusEvent();

  @override
  List<Object?> get props => [];
}

/// Check the current account status based on email verification and account age.
class CheckAccountStatus extends AccountStatusEvent {
  const CheckAccountStatus();
}

/// Triggered when the user's email has been verified.
class AccountEmailVerified extends AccountStatusEvent {
  const AccountEmailVerified();
}

/// Dismiss the warning banner for the current session.
class DismissAccountWarning extends AccountStatusEvent {
  const DismissAccountWarning();
}
