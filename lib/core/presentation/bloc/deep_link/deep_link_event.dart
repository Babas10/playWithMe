// Events for the DeepLinkBloc.
import 'package:equatable/equatable.dart';

sealed class DeepLinkEvent extends Equatable {
  const DeepLinkEvent();

  @override
  List<Object?> get props => [];
}

class InitializeDeepLinks extends DeepLinkEvent {
  const InitializeDeepLinks();
}

class InviteTokenReceived extends DeepLinkEvent {
  final String token;

  const InviteTokenReceived(this.token);

  @override
  List<Object?> get props => [token];
}

class ClearPendingInvite extends DeepLinkEvent {
  const ClearPendingInvite();
}
