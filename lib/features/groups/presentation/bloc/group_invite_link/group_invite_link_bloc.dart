// BLoC for managing group invite link generation and revocation.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/domain/exceptions/repository_exceptions.dart';
import 'package:play_with_me/core/domain/repositories/group_invite_link_repository.dart';
import 'package:play_with_me/core/utils/error_messages.dart';
import 'group_invite_link_event.dart';
import 'group_invite_link_state.dart';

class GroupInviteLinkBloc
    extends Bloc<GroupInviteLinkEvent, GroupInviteLinkState> {
  final GroupInviteLinkRepository _repository;

  GroupInviteLinkBloc({required GroupInviteLinkRepository repository})
      : _repository = repository,
        super(const GroupInviteLinkInitial()) {
    on<GenerateInvite>(_onGenerateInvite);
    on<RevokeInvite>(_onRevokeInvite);
  }

  Future<void> _onGenerateInvite(
    GenerateInvite event,
    Emitter<GroupInviteLinkState> emit,
  ) async {
    try {
      emit(const GroupInviteLinkLoading());

      final result = await _repository.createGroupInvite(
        groupId: event.groupId,
        expiresInHours: event.expiresInHours,
        usageLimit: event.usageLimit,
      );

      emit(GroupInviteLinkGenerated(
        deepLinkUrl: result.deepLinkUrl,
        inviteId: result.inviteId,
      ));
    } on GroupInviteLinkException catch (e) {
      final (message, isRetryable) =
          GroupInviteLinkErrorMessages.getErrorMessage(e);
      emit(GroupInviteLinkError(
        message: message,
        errorCode: e.code ?? 'GENERATE_INVITE_ERROR',
        isRetryable: isRetryable,
      ));
    } catch (e) {
      final (message, isRetryable) = e is Exception
          ? ErrorMessages.getErrorMessage(e)
          : ('Failed to generate invite link', true);
      emit(GroupInviteLinkError(
        message: message,
        errorCode: 'GENERATE_INVITE_ERROR',
        isRetryable: isRetryable,
      ));
    }
  }

  Future<void> _onRevokeInvite(
    RevokeInvite event,
    Emitter<GroupInviteLinkState> emit,
  ) async {
    try {
      emit(const GroupInviteLinkLoading());

      await _repository.revokeGroupInvite(
        groupId: event.groupId,
        inviteId: event.inviteId,
      );

      emit(const GroupInviteLinkRevoked());
    } on GroupInviteLinkException catch (e) {
      final (message, isRetryable) =
          GroupInviteLinkErrorMessages.getErrorMessage(e);
      emit(GroupInviteLinkError(
        message: message,
        errorCode: e.code ?? 'REVOKE_INVITE_ERROR',
        isRetryable: isRetryable,
      ));
    } catch (e) {
      final (message, isRetryable) = e is Exception
          ? ErrorMessages.getErrorMessage(e)
          : ('Failed to revoke invite link', true);
      emit(GroupInviteLinkError(
        message: message,
        errorCode: 'REVOKE_INVITE_ERROR',
        isRetryable: isRetryable,
      ));
    }
  }
}
