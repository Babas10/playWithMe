import 'package:freezed_annotation/freezed_annotation.dart';

part 'account_deletion_event.freezed.dart';

@freezed
class AccountDeletionEvent with _$AccountDeletionEvent {
  /// User confirmed they want to permanently delete their account.
  const factory AccountDeletionEvent.deleteRequested() =
      AccountDeletionRequested;
}
