import 'package:play_with_me/core/presentation/bloc/base_bloc_state.dart';

abstract class GroupInviteLinkState extends BaseBlocState {
  const GroupInviteLinkState();
}

class GroupInviteLinkInitial extends GroupInviteLinkState
    implements InitialState {
  const GroupInviteLinkInitial();
}

class GroupInviteLinkLoading extends GroupInviteLinkState
    implements LoadingState {
  const GroupInviteLinkLoading();
}

class GroupInviteLinkGenerated extends GroupInviteLinkState
    implements SuccessState {
  final String deepLinkUrl;
  final String inviteId;

  const GroupInviteLinkGenerated({
    required this.deepLinkUrl,
    required this.inviteId,
  });

  @override
  List<Object?> get props => [deepLinkUrl, inviteId];
}

class GroupInviteLinkRevoked extends GroupInviteLinkState
    implements SuccessState {
  const GroupInviteLinkRevoked();
}

class GroupInviteLinkError extends GroupInviteLinkState implements ErrorState {
  @override
  final String message;
  @override
  final String? errorCode;
  @override
  final bool isRetryable;

  const GroupInviteLinkError({
    required this.message,
    this.errorCode,
    this.isRetryable = true,
  });

  @override
  List<Object?> get props => [message, errorCode, isRetryable];
}
