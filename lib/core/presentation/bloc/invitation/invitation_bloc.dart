import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/invitation_repository.dart';
import '../../../data/models/invitation_model.dart';
import 'invitation_event.dart';
import 'invitation_state.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  final InvitationRepository _invitationRepository;
  StreamSubscription<dynamic>? _invitationsSubscription;

  InvitationBloc({required InvitationRepository invitationRepository})
      : _invitationRepository = invitationRepository,
        super(const InvitationInitial()) {
    on<SendInvitation>(_onSendInvitation);
    on<LoadPendingInvitations>(_onLoadPendingInvitations);
    on<LoadInvitations>(_onLoadInvitations);
    on<AcceptInvitation>(_onAcceptInvitation);
    on<DeclineInvitation>(_onDeclineInvitation);
    on<DeleteInvitation>(_onDeleteInvitation);
  }

  Future<void> _onSendInvitation(
    SendInvitation event,
    Emitter<InvitationState> emit,
  ) async {
    try {
      emit(const InvitationLoading());

      final invitationId = await _invitationRepository.sendInvitation(
        groupId: event.groupId,
        groupName: event.groupName,
        invitedUserId: event.invitedUserId,
        invitedBy: event.invitedBy,
        inviterName: event.inviterName,
      );

      emit(InvitationSent(invitationId: invitationId));
    } catch (e) {
      emit(InvitationError(
        message: 'Failed to send invitation: ${e.toString()}',
        errorCode: 'SEND_INVITATION_ERROR',
      ));
    }
  }

  Future<void> _onLoadPendingInvitations(
    LoadPendingInvitations event,
    Emitter<InvitationState> emit,
  ) async {
    // Cancel existing subscription
    await _invitationsSubscription?.cancel();

    try {
      final stream = _invitationRepository.getPendingInvitations(event.userId);

      // Use emit.forEach to keep the emitter alive and automatically emit states
      await emit.forEach<List<InvitationModel>>(
        stream,
        onData: (invitations) {
          return InvitationsLoaded(invitations: invitations);
        },
        onError: (error, stackTrace) {
          return InvitationError(
            message: 'Failed to load pending invitations: ${error.toString()}',
            errorCode: 'LOAD_PENDING_INVITATIONS_ERROR',
          );
        },
      );
    } catch (e) {
      emit(InvitationError(
        message: 'Failed to load pending invitations: ${e.toString()}',
        errorCode: 'LOAD_PENDING_INVITATIONS_ERROR',
      ));
    }
  }

  Future<void> _onLoadInvitations(
    LoadInvitations event,
    Emitter<InvitationState> emit,
  ) async {
    try {
      emit(const InvitationLoading());

      final invitations = await _invitationRepository.getInvitations(event.userId);

      emit(InvitationsLoaded(invitations: invitations));
    } catch (e) {
      emit(InvitationError(
        message: 'Failed to load invitations: ${e.toString()}',
        errorCode: 'LOAD_INVITATIONS_ERROR',
      ));
    }
  }

  Future<void> _onAcceptInvitation(
    AcceptInvitation event,
    Emitter<InvitationState> emit,
  ) async {
    try {
      emit(const InvitationLoading());

      await _invitationRepository.acceptInvitation(
        userId: event.userId,
        invitationId: event.invitationId,
      );

      emit(InvitationAccepted(invitationId: event.invitationId));
    } catch (e) {
      emit(InvitationError(
        message: 'Failed to accept invitation: ${e.toString()}',
        errorCode: 'ACCEPT_INVITATION_ERROR',
      ));
    }
  }

  Future<void> _onDeclineInvitation(
    DeclineInvitation event,
    Emitter<InvitationState> emit,
  ) async {
    try {
      emit(const InvitationLoading());

      await _invitationRepository.declineInvitation(
        userId: event.userId,
        invitationId: event.invitationId,
      );

      emit(InvitationDeclined(invitationId: event.invitationId));
    } catch (e) {
      emit(InvitationError(
        message: 'Failed to decline invitation: ${e.toString()}',
        errorCode: 'DECLINE_INVITATION_ERROR',
      ));
    }
  }

  Future<void> _onDeleteInvitation(
    DeleteInvitation event,
    Emitter<InvitationState> emit,
  ) async {
    try {
      emit(const InvitationLoading());

      await _invitationRepository.deleteInvitation(
        userId: event.userId,
        invitationId: event.invitationId,
      );

      emit(InvitationDeleted(invitationId: event.invitationId));
    } catch (e) {
      emit(InvitationError(
        message: 'Failed to delete invitation: ${e.toString()}',
        errorCode: 'DELETE_INVITATION_ERROR',
      ));
    }
  }

  @override
  Future<void> close() {
    _invitationsSubscription?.cancel();
    return super.close();
  }
}
