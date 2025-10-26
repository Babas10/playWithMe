import '../base_bloc_state.dart';
import '../../../data/models/invitation_model.dart';

abstract class InvitationState extends BaseBlocState {
  const InvitationState();
}

class InvitationInitial extends InvitationState implements InitialState {
  const InvitationInitial();
}

class InvitationLoading extends InvitationState implements LoadingState {
  const InvitationLoading();
}

class InvitationSent extends InvitationState implements SuccessState {
  final String invitationId;
  final String message;

  const InvitationSent({
    required this.invitationId,
    this.message = 'Invitation sent successfully',
  });

  @override
  List<Object?> get props => [invitationId, message];
}

class InvitationsLoaded extends InvitationState implements SuccessState {
  final List<InvitationModel> invitations;

  const InvitationsLoaded({required this.invitations});

  @override
  List<Object?> get props => [invitations];
}

class InvitationAccepted extends InvitationState implements SuccessState {
  final String invitationId;
  final String message;

  const InvitationAccepted({
    required this.invitationId,
    this.message = 'Invitation accepted successfully',
  });

  @override
  List<Object?> get props => [invitationId, message];
}

class InvitationDeclined extends InvitationState implements SuccessState {
  final String invitationId;
  final String message;

  const InvitationDeclined({
    required this.invitationId,
    this.message = 'Invitation declined',
  });

  @override
  List<Object?> get props => [invitationId, message];
}

class InvitationDeleted extends InvitationState implements SuccessState {
  final String invitationId;
  final String message;

  const InvitationDeleted({
    required this.invitationId,
    this.message = 'Invitation deleted',
  });

  @override
  List<Object?> get props => [invitationId, message];
}

class InvitationError extends InvitationState implements ErrorState {
  @override
  final String message;
  @override
  final String? errorCode;

  const InvitationError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}
