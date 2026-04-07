// Page listing a user's pending game invitations (Story 28.7).
// Allows the user to accept or decline each invitation.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/core/theme/play_with_me_app_bar.dart';
import 'package:play_with_me/core/data/models/game_invitation_details.dart';
import 'package:play_with_me/features/games/presentation/bloc/game_invitations/game_invitations_bloc.dart';
import 'package:play_with_me/features/games/presentation/pages/game_details_page.dart';
import 'package:play_with_me/features/games/presentation/widgets/game_invitation_card.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class PendingGameInvitationsPage extends StatelessWidget {
  final GameInvitationsBloc? blocOverride;

  const PendingGameInvitationsPage({super.key, this.blocOverride});

  @override
  Widget build(BuildContext context) {
    final child = _PendingGameInvitationsView();
    if (blocOverride != null) {
      return BlocProvider<GameInvitationsBloc>.value(
        value: blocOverride!,
        child: child,
      );
    }
    return child;
  }
}

class _PendingGameInvitationsView extends StatefulWidget {
  const _PendingGameInvitationsView();

  @override
  State<_PendingGameInvitationsView> createState() =>
      _PendingGameInvitationsViewState();
}

class _PendingGameInvitationsViewState
    extends State<_PendingGameInvitationsView> {
  @override
  void initState() {
    super.initState();
    context.read<GameInvitationsBloc>().add(const LoadGameInvitations());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: PlayWithMeAppBar.build(
        context: context,
        title: l10n.gameInvitations,
      ),
      body: BlocConsumer<GameInvitationsBloc, GameInvitationsState>(
        listener: _handleStateChange,
        builder: (context, state) => _buildBody(context, state, l10n),
      ),
    );
  }

  void _handleStateChange(BuildContext context, GameInvitationsState state) {
    final l10n = AppLocalizations.of(context)!;

    if (state is GameInvitationActionSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.accepted
                ? l10n.gameInvitationAccepted
                : l10n.gameInvitationDeclined,
          ),
          backgroundColor:
              state.accepted ? Colors.green.shade600 : AppColors.textMuted,
        ),
      );
      // Navigate to game details after accept
      if (state.accepted && state.gameId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameDetailsPage(gameId: state.gameId!),
          ),
        );
      }
    }

    if (state is GameInvitationActionError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.gameInvitationActionError),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Widget _buildBody(
    BuildContext context,
    GameInvitationsState state,
    AppLocalizations l10n,
  ) {
    if (state is GameInvitationsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is GameInvitationsError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(state.message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context
                    .read<GameInvitationsBloc>()
                    .add(const LoadGameInvitations()),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    final invitations = switch (state) {
      GameInvitationsLoaded() => state.invitations,
      GameInvitationActionInFlight() => state.invitations,
      GameInvitationActionSuccess() => state.invitations,
      GameInvitationActionError() => state.invitations,
      _ => <GameInvitationDetails>[],
    };

    final processingId = state is GameInvitationActionInFlight
        ? state.processingInvitationId
        : null;

    if (invitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              l10n.noPendingGameInvitations,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context
          .read<GameInvitationsBloc>()
          .add(const LoadGameInvitations()),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: invitations.length,
        itemBuilder: (context, index) {
          final inv = invitations[index];
          return GameInvitationCard(
            invitation: inv,
            isProcessing: processingId == inv.invitationId,
            onAccept: () => context
                .read<GameInvitationsBloc>()
                .add(AcceptGameInvitation(inv.invitationId)),
            onDecline: () => context
                .read<GameInvitationsBloc>()
                .add(DeclineGameInvitation(inv.invitationId)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GameDetailsPage(gameId: inv.gameId),
              ),
            ),
          );
        },
      ),
    );
  }
}

