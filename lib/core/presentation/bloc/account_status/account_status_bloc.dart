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

  AccountStatusBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AccountStatusLoading()) {
    on<CheckAccountStatus>(_onCheckStatus);
    on<AccountEmailVerified>(_onEmailVerified);
    on<DismissAccountWarning>(_onDismissWarning);
    on<RefreshVerificationStatus>(_onRefreshVerificationStatus);

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

    // Reload to get the freshest email-verification status from Firebase.
    // This handles the case where the user verified their email before the
    // app cold-started (cached token still has isEmailVerified = false).
    try {
      await _authRepository.reloadUser();
      final freshUser = _authRepository.currentUser;
      if (freshUser != null && freshUser.isEmailVerified) {
        emit(const AccountStatusActive());
        return;
      }
    } catch (_) {
      // Ignore reload failures; proceed with cached status.
    }

    final status = computeAccountStatus(
      isEmailVerified: false,
      accountCreatedAt: user.createdAt,
    );

    switch (status) {
      case AccountStatus.active:
        emit(const AccountStatusActive());
      case AccountStatus.pendingVerification:
        final daysLeft = computeDaysRemaining(accountCreatedAt: user.createdAt);
        emit(AccountStatusPending(daysRemaining: daysLeft));
      case AccountStatus.restricted:
        final daysSinceCreation = user.createdAt != null
            ? DateTime.now().difference(user.createdAt!).inDays
            : deletionPeriodDays;
        final daysUntilDeletion = deletionPeriodDays - daysSinceCreation;
        emit(
          AccountStatusRestricted(
            daysUntilDeletion: daysUntilDeletion > 0 ? daysUntilDeletion : 0,
          ),
        );
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

  Future<void> _onRefreshVerificationStatus(
    RefreshVerificationStatus event,
    Emitter<AccountStatusState> emit,
  ) async {
    // Only worth reloading when we know the email is still unverified.
    if (state is! AccountStatusPending && state is! AccountStatusRestricted) {
      return;
    }
    try {
      await _authRepository.reloadUser();
      final user = _authRepository.currentUser;
      if (user != null && user.isEmailVerified) {
        emit(const AccountStatusActive());
      }
    } catch (_) {
      // Silently ignore — the next natural refresh will pick it up.
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
