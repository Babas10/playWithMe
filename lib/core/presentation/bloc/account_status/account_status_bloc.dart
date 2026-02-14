// BLoC for managing account status based on email verification and grace period.
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/entities/account_status.dart';
import 'package:play_with_me/core/presentation/bloc/account_status/account_status_event.dart';
import 'package:play_with_me/core/presentation/bloc/account_status/account_status_state.dart';
import 'package:play_with_me/features/auth/domain/repositories/auth_repository.dart';

class AccountStatusBloc extends Bloc<AccountStatusEvent, AccountStatusState> {
  final AuthRepository _authRepository;
  StreamSubscription<dynamic>? _authStateSubscription;

  AccountStatusBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AccountStatusLoading()) {
    on<CheckAccountStatus>(_onCheckStatus);
    on<AccountEmailVerified>(_onEmailVerified);
    on<DismissAccountWarning>(_onDismissWarning);

    _authStateSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null && user.isEmailVerified) {
        add(const AccountEmailVerified());
      }
    });
  }

  Future<void> _onCheckStatus(
    CheckAccountStatus event,
    Emitter<AccountStatusState> emit,
  ) async {
    final user = _authRepository.currentUser;

    if (user == null) {
      emit(const AccountStatusActive());
      return;
    }

    if (user.isEmailVerified) {
      emit(const AccountStatusActive());
      return;
    }

    final status = computeAccountStatus(
      isEmailVerified: user.isEmailVerified,
      accountCreatedAt: user.createdAt,
    );

    switch (status) {
      case AccountStatus.active:
        emit(const AccountStatusActive());
      case AccountStatus.pendingVerification:
        final daysLeft = computeDaysRemaining(
          accountCreatedAt: user.createdAt,
        );
        emit(AccountStatusPending(daysRemaining: daysLeft));
      case AccountStatus.restricted:
        final daysSinceCreation = user.createdAt != null
            ? DateTime.now().difference(user.createdAt!).inDays
            : deletionPeriodDays;
        final daysUntilDeletion = deletionPeriodDays - daysSinceCreation;
        emit(AccountStatusRestricted(
          daysUntilDeletion: daysUntilDeletion > 0 ? daysUntilDeletion : 0,
        ));
      case AccountStatus.scheduledForDeletion:
        emit(const AccountStatusRestricted(daysUntilDeletion: 0));
    }
  }

  Future<void> _onEmailVerified(
    AccountEmailVerified event,
    Emitter<AccountStatusState> emit,
  ) async {
    emit(const AccountStatusActive());
  }

  Future<void> _onDismissWarning(
    DismissAccountWarning event,
    Emitter<AccountStatusState> emit,
  ) async {
    final currentState = state;
    if (currentState is AccountStatusPending) {
      emit(currentState.copyWith(isDismissed: true));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
