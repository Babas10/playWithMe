/// Account status based on email verification and account age.
///
/// Used to enforce the grace period policy:
/// - 0-7 days: Full access with warning banner
/// - 7-30 days: Restricted access
/// - 30+ days: Scheduled for deletion
enum AccountStatus {
  /// Email verified OR within 7-day grace period with verified email
  active,

  /// Within 7-day grace period, email not verified
  pendingVerification,

  /// Past 7 days, email not verified
  restricted,

  /// Past 30 days, email not verified
  scheduledForDeletion,
}

/// Grace period duration constants.
const int gracePeriodDays = 7;
const int deletionPeriodDays = 30;

/// Computes the account status based on email verification and account age.
///
/// Returns [AccountStatus.active] if email is verified.
/// Otherwise computes based on days since account creation.
AccountStatus computeAccountStatus({
  required bool isEmailVerified,
  required DateTime? accountCreatedAt,
}) {
  if (isEmailVerified) return AccountStatus.active;

  if (accountCreatedAt == null) return AccountStatus.pendingVerification;

  final daysSinceCreation =
      DateTime.now().difference(accountCreatedAt).inDays;

  if (daysSinceCreation <= gracePeriodDays) {
    return AccountStatus.pendingVerification;
  }
  if (daysSinceCreation <= deletionPeriodDays) {
    return AccountStatus.restricted;
  }
  return AccountStatus.scheduledForDeletion;
}

/// Computes the number of days remaining in the grace period.
///
/// Returns 0 if the grace period has expired or accountCreatedAt is null.
int computeDaysRemaining({required DateTime? accountCreatedAt}) {
  if (accountCreatedAt == null) return gracePeriodDays;

  final daysSinceCreation =
      DateTime.now().difference(accountCreatedAt).inDays;
  final remaining = gracePeriodDays - daysSinceCreation;

  return remaining > 0 ? remaining : 0;
}
