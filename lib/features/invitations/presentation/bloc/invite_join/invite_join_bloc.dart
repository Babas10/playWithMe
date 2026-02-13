// BLoC for validating invite tokens and joining groups via invite links.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/group_invite_link_repository.dart';
import 'package:play_with_me/core/services/pending_invite_storage.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_event.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_state.dart';

class InviteJoinBloc extends Bloc<InviteJoinEvent, InviteJoinState> {
  final GroupInviteLinkRepository _repository;
  final PendingInviteStorage _pendingInviteStorage;

  InviteJoinBloc({
    required GroupInviteLinkRepository repository,
    required PendingInviteStorage pendingInviteStorage,
  })  : _repository = repository,
        _pendingInviteStorage = pendingInviteStorage,
        super(const InviteJoinInitial()) {
    on<ValidateInviteToken>(_onValidateToken);
    on<JoinGroupViaInvite>(_onJoinGroup);
    on<ProcessPendingInvite>(_onProcessPendingInvite);
  }

  Future<void> _onValidateToken(
    ValidateInviteToken event,
    Emitter<InviteJoinState> emit,
  ) async {
    emit(const InviteJoinValidating());
    try {
      final result =
          await _repository.validateInviteToken(token: event.token);
      emit(InviteJoinValidated(
        groupId: result.groupId,
        groupName: result.groupName,
        groupDescription: result.groupDescription,
        groupPhotoUrl: result.groupPhotoUrl,
        memberCount: result.groupMemberCount,
        inviterName: result.inviterName,
        inviterPhotoUrl: result.inviterPhotoUrl,
        token: event.token,
      ));
    } on GroupInviteLinkException catch (e) {
      if (e.code == 'failed-precondition') {
        emit(InviteJoinInvalidToken(reason: e.message));
      } else {
        emit(InviteJoinError(message: e.message));
      }
    } catch (e) {
      emit(InviteJoinError(message: 'Failed to validate invite: $e'));
    }
  }

  Future<void> _onJoinGroup(
    JoinGroupViaInvite event,
    Emitter<InviteJoinState> emit,
  ) async {
    emit(const InviteJoinJoining());
    try {
      final result =
          await _repository.joinGroupViaInvite(token: event.token);
      await _pendingInviteStorage.clear();
      emit(InviteJoinJoined(
        groupId: result.groupId,
        groupName: result.groupName,
        alreadyMember: result.alreadyMember,
      ));
    } on GroupInviteLinkException catch (e) {
      if (e.code == 'failed-precondition') {
        emit(InviteJoinInvalidToken(reason: e.message));
      } else {
        emit(InviteJoinError(message: e.message));
      }
    } catch (e) {
      emit(InviteJoinError(message: 'Failed to join group: $e'));
    }
  }

  Future<void> _onProcessPendingInvite(
    ProcessPendingInvite event,
    Emitter<InviteJoinState> emit,
  ) async {
    final token = await _pendingInviteStorage.retrieve();
    if (token == null) {
      return;
    }
    emit(const InviteJoinValidating());
    try {
      final result =
          await _repository.validateInviteToken(token: token);
      emit(InviteJoinValidated(
        groupId: result.groupId,
        groupName: result.groupName,
        groupDescription: result.groupDescription,
        groupPhotoUrl: result.groupPhotoUrl,
        memberCount: result.groupMemberCount,
        inviterName: result.inviterName,
        inviterPhotoUrl: result.inviterPhotoUrl,
        token: token,
      ));
    } on GroupInviteLinkException catch (e) {
      await _pendingInviteStorage.clear();
      if (e.code == 'failed-precondition') {
        emit(InviteJoinInvalidToken(reason: e.message));
      } else {
        emit(InviteJoinError(message: e.message));
      }
    } catch (e) {
      await _pendingInviteStorage.clear();
      emit(InviteJoinError(message: 'Failed to process invite: $e'));
    }
  }
}
