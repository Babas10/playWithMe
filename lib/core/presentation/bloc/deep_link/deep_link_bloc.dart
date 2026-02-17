// BLoC for managing deep link state and pending invites.
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/deep_link/deep_link_event.dart';
import 'package:play_with_me/core/presentation/bloc/deep_link/deep_link_state.dart';
import 'package:play_with_me/core/services/deep_link_service.dart';
import 'package:play_with_me/core/services/pending_invite_storage.dart';

class DeepLinkBloc extends Bloc<DeepLinkEvent, DeepLinkState> {
  final DeepLinkService _deepLinkService;
  final PendingInviteStorage _pendingInviteStorage;
  StreamSubscription<String?>? _tokenSubscription;

  DeepLinkBloc({
    required DeepLinkService deepLinkService,
    required PendingInviteStorage pendingInviteStorage,
  })  : _deepLinkService = deepLinkService,
        _pendingInviteStorage = pendingInviteStorage,
        super(const DeepLinkInitial()) {
    on<InitializeDeepLinks>(_onInitialize);
    on<InviteTokenReceived>(_onInviteTokenReceived);
    on<ClearPendingInvite>(_onClearPendingInvite);
  }

  Future<void> _onInitialize(
    InitializeDeepLinks event,
    Emitter<DeepLinkState> emit,
  ) async {
    // Check for stored pending invite first (survives app restart during auth)
    final storedToken = await _pendingInviteStorage.retrieve();
    if (storedToken != null) {
      // Clear storage immediately — token now lives in BLoC state only.
      // This prevents stale tokens from re-triggering on every restart.
      await _pendingInviteStorage.clear();
      emit(DeepLinkPendingInvite(token: storedToken));
      // Still start the foreground listener
      _startLinkListener();
      return;
    }

    // Check for initial deep link (cold start).
    // Skip if already consumed (getInitialLink() persists across hot restarts).
    final initialToken = await _deepLinkService.getInitialInviteToken();
    if (initialToken != null &&
        !_pendingInviteStorage.isConsumed(initialToken)) {
      emit(DeepLinkPendingInvite(token: initialToken));
    } else {
      emit(const DeepLinkNoInvite());
    }

    _startLinkListener();
  }

  void _startLinkListener() {
    // Listen for foreground deep links
    _tokenSubscription = _deepLinkService.inviteTokenStream.listen(
      (token) {
        if (token != null) {
          add(InviteTokenReceived(token));
        }
      },
    );
  }

  Future<void> _onInviteTokenReceived(
    InviteTokenReceived event,
    Emitter<DeepLinkState> emit,
  ) async {
    // Store token only for unauthenticated users who need to survive
    // the registration/login flow. The listeners in play_with_me_app.dart
    // will clear this after consuming the token.
    await _pendingInviteStorage.store(event.token);
    emit(DeepLinkPendingInvite(token: event.token));
  }

  Future<void> _onClearPendingInvite(
    ClearPendingInvite event,
    Emitter<DeepLinkState> emit,
  ) async {
    // Mark the current token as consumed before clearing,
    // so getInitialLink() won't re-trigger it on hot restart.
    final currentState = state;
    if (currentState is DeepLinkPendingInvite) {
      await _pendingInviteStorage.markConsumed(currentState.token);
    }
    await _pendingInviteStorage.clear();
    emit(const DeepLinkNoInvite());
  }

  @override
  Future<void> close() {
    _tokenSubscription?.cancel();
    return super.close();
  }
}
