import 'package:freezed_annotation/freezed_annotation.dart';

part 'email_verification_state.freezed.dart';

@freezed
class EmailVerificationState with _$EmailVerificationState {
  /// Initial state
  const factory EmailVerificationState.initial() = EmailVerificationInitial;

  /// Loading state (checking status or sending email)
  const factory EmailVerificationState.loading() = EmailVerificationLoading;

  /// Verified state
  const factory EmailVerificationState.verified({
    required DateTime? verifiedAt,
  }) = EmailVerificationVerified;

  /// Pending verification state
  const factory EmailVerificationState.pending({
    required String email,
    required bool emailSent,
    required DateTime? lastSentAt,
    required int resendCooldownSeconds,
  }) = EmailVerificationPending;

  /// Error state
  const factory EmailVerificationState.error({
    required String message,
    String? email,
    bool? wasVerified,
  }) = EmailVerificationError;

  /// Email sent successfully state
  const factory EmailVerificationState.emailSent({
    required String email,
    required DateTime sentAt,
    required int resendCooldownSeconds,
  }) = EmailVerificationEmailSent;
}
