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
    // Check for stored pending invite first
    final storedToken = await _pendingInviteStorage.retrieve();
    if (storedToken != null) {
      emit(DeepLinkPendingInvite(token: storedToken));
      return;
    }

    // Check for initial deep link (cold start)
    final initialToken = await _deepLinkService.getInitialInviteToken();
    if (initialToken != null) {
      await _pendingInviteStorage.store(initialToken);
      emit(DeepLinkPendingInvite(token: initialToken));
    } else {
      emit(const DeepLinkNoInvite());
    }

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
    await _pendingInviteStorage.store(event.token);
    emit(DeepLinkPendingInvite(token: event.token));
  }

  Future<void> _onClearPendingInvite(
    ClearPendingInvite event,
    Emitter<DeepLinkState> emit,
  ) async {
    await _pendingInviteStorage.clear();
    emit(const DeepLinkNoInvite());
  }

  @override
  Future<void> close() {
    _tokenSubscription?.cancel();
    return super.close();
  }
}
