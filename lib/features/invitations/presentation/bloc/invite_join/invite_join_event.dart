// Events for the InviteJoinBloc.
import 'package:equatable/equatable.dart';

sealed class InviteJoinEvent extends Equatable {
  const InviteJoinEvent();

  @override
  List<Object?> get props => [];
}

class ValidateInviteToken extends InviteJoinEvent {
  final String token;

  const ValidateInviteToken(this.token);

  @override
  List<Object?> get props => [token];
}

class JoinGroupViaInvite extends InviteJoinEvent {
  final String token;

  const JoinGroupViaInvite(this.token);

  @override
  List<Object?> get props => [token];
}

class ProcessPendingInvite extends InviteJoinEvent {
  const ProcessPendingInvite();
}
