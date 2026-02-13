// Confirmation page for authenticated users to join a group via invite link.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/features/groups/presentation/pages/group_details_page.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_bloc.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_event.dart';
import 'package:play_with_me/features/invitations/presentation/bloc/invite_join/invite_join_state.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class JoinGroupConfirmationPage extends StatelessWidget {
  final String token;

  const JoinGroupConfirmationPage({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.joinGroupConfirmation),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: BlocConsumer<InviteJoinBloc, InviteJoinState>(
            listener: (context, state) {
              if (state is InviteJoinJoined) {
                final message = state.alreadyMember
                    ? l10n.alreadyAMember
                    : l10n.groupJoinedSuccess(state.groupName);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => GroupDetailsPage(groupId: state.groupId),
                  ),
                  (route) => route.isFirst,
                );
              }
            },
            builder: (context, state) {
              if (state is InviteJoinValidating) {
                return _buildLoadingState(l10n.validatingInvite);
              }
              if (state is InviteJoinJoining) {
                return _buildLoadingState(l10n.joiningGroup);
              }
              if (state is InviteJoinValidated) {
                return _buildConfirmationState(context, l10n, state);
              }
              if (state is InviteJoinInvalidToken) {
                return _buildErrorState(context, l10n, state.reason);
              }
              if (state is InviteJoinError) {
                return _buildErrorState(context, l10n, state.message);
              }
              return _buildLoadingState(l10n.validatingInvite);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildConfirmationState(
    BuildContext context,
    AppLocalizations l10n,
    InviteJoinValidated state,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.groupName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (state.groupDescription != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.groupDescription!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  l10n.invitedBy(state.inviterName),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.membersCount(state.memberCount),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        FilledButton(
          onPressed: () {
            context
                .read<InviteJoinBloc>()
                .add(JoinGroupViaInvite(state.token));
          },
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(l10n.joinGroup),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(l10n.cancel),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    String message,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.danger,
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(l10n.continueToApp),
          ),
        ],
      ),
    );
  }
}
