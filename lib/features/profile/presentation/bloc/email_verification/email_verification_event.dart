import 'package:freezed_annotation/freezed_annotation.dart';

part 'email_verification_event.freezed.dart';

@freezed
class EmailVerificationEvent with _$EmailVerificationEvent {
  /// Check current verification status
  const factory EmailVerificationEvent.checkStatus() = EmailVerificationCheckStatus;

  /// Send verification email
  const factory EmailVerificationEvent.sendVerificationEmail() = EmailVerificationSendEmail;

  /// Refresh verification status (after user clicks link)
  const factory EmailVerificationEvent.refreshStatus() = EmailVerificationRefreshStatus;

  /// Reset error state
  const factory EmailVerificationEvent.resetError() = EmailVerificationResetError;

  /// Internal event triggered by auth state changes
  const factory EmailVerificationEvent.authStateChanged({
    required bool isVerified,
    DateTime? verifiedAt,
  }) = EmailVerificationAuthStateChanged;
}
