// States for the AccountStatusBloc.
import 'package:equatable/equatable.dart';
import 'package:play_with_me/core/domain/entities/account_status.dart';

sealed class AccountStatusState extends Equatable {
  const AccountStatusState();

  @override
  List<Object?> get props => [];
}

/// Initial loading state.
class AccountStatusLoading extends AccountStatusState {
  const AccountStatusLoading();
}

/// Email is verified, account is fully active.
class AccountStatusActive extends AccountStatusState {
  const AccountStatusActive();
}

/// Email not verified, within grace period (0-7 days).
class AccountStatusPending extends AccountStatusState {
  final int daysRemaining;
  final bool isDismissed;

  const AccountStatusPending({
    required this.daysRemaining,
    this.isDismissed = false,
  });

  @override
  List<Object?> get props => [daysRemaining, isDismissed];

  AccountStatusPending copyWith({
    int? daysRemaining,
    bool? isDismissed,
  }) {
    return AccountStatusPending(
      daysRemaining: daysRemaining ?? this.daysRemaining,
      isDismissed: isDismissed ?? this.isDismissed,
    );
  }
}

/// Email not verified, past grace period (7-30 days).
class AccountStatusRestricted extends AccountStatusState {
  final int daysUntilDeletion;

  const AccountStatusRestricted({required this.daysUntilDeletion});

  @override
  List<Object?> get props => [daysUntilDeletion];
}

/// Helper extension to get the underlying AccountStatus enum value.
extension AccountStatusStateX on AccountStatusState {
  AccountStatus? get status {
    return switch (this) {
      AccountStatusLoading() => null,
      AccountStatusActive() => AccountStatus.active,
      AccountStatusPending() => AccountStatus.pendingVerification,
      AccountStatusRestricted() => AccountStatus.restricted,
    };
  }
}
