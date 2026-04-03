// Validates AccountDeletionBloc emits correct states during account deletion flow.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';
import 'package:play_with_me/features/profile/presentation/bloc/account_deletion/account_deletion_event.dart';
import 'package:play_with_me/features/profile/presentation/bloc/account_deletion/account_deletion_state.dart';

/// BLoC for managing the permanent account deletion flow.
class AccountDeletionBloc
    extends Bloc<AccountDeletionEvent, AccountDeletionState> {
  final AuthRepository _authRepository;

  AccountDeletionBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AccountDeletionState.initial()) {
    on<AccountDeletionRequested>(_onDeleteRequested);
  }

  Future<void> _onDeleteRequested(
    AccountDeletionRequested event,
    Emitter<AccountDeletionState> emit,
  ) async {
    emit(const AccountDeletionState.inProgress());
    try {
      await _authRepository.deleteAccount();
      emit(const AccountDeletionState.success());
    } catch (e) {
      emit(AccountDeletionState.failure(
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }
}
