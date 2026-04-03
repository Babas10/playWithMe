import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_deletion_state.freezed.dart';

@freezed
class AccountDeletionState with _$AccountDeletionState {
  /// Idle — waiting for user action.
  const factory AccountDeletionState.initial() = AccountDeletionInitial;

  /// Deletion in progress.
  const factory AccountDeletionState.inProgress() = AccountDeletionInProgress;

  /// Account successfully deleted.
  const factory AccountDeletionState.success() = AccountDeletionSuccess;

  /// Deletion failed.
  const factory AccountDeletionState.failure({required String message}) =
      AccountDeletionFailure;
}
