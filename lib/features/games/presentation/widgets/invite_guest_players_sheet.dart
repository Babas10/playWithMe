// Bottom sheet for inviting guest players to a game (Story 28.6).
// Visible to the game creator only; groups invitable players by their source group.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/invitable_player_model.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

import '../bloc/game_guest_invitation/game_guest_invitation_bloc.dart';
import '../bloc/game_guest_invitation/game_guest_invitation_event.dart';
import '../bloc/game_guest_invitation/game_guest_invitation_state.dart';

/// Opens the invite-guest-players bottom sheet for [gameId].
/// Must be called from a context that already has [GameGuestInvitationBloc]
/// provided above it in the tree.
void showInviteGuestPlayersSheet(BuildContext context, String gameId) {
  context
      .read<GameGuestInvitationBloc>()
      .add(LoadInvitablePlayers(gameId: gameId));

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => BlocProvider.value(
      value: context.read<GameGuestInvitationBloc>(),
      child: _InviteGuestPlayersSheet(gameId: gameId),
    ),
  );
}

class _InviteGuestPlayersSheet extends StatelessWidget {
  final String gameId;

  const _InviteGuestPlayersSheet({required this.gameId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                l10n.inviteGuestPlayers,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: BlocConsumer<GameGuestInvitationBloc,
                  GameGuestInvitationState>(
                listener: (context, state) {
                  if (state is InvitePlayerSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.invitePlayerSuccess)),
                    );
                  } else if (state is InvitePlayerError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is InvitablePlayersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is InvitablePlayersError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<GameGuestInvitationBloc>()
                                  .add(LoadInvitablePlayers(gameId: gameId)),
                              child: Text(l10n.retry),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final players = switch (state) {
                    InvitablePlayersLoaded s => s.players,
                    InvitePlayerSending s => s.players,
                    InvitePlayerSuccess s => s.players,
                    InvitePlayerError s => s.players,
                    _ => const <InvitablePlayerModel>[],
                  };

                  final sendingInviteeId = state is InvitePlayerSending
                      ? state.inviteeId
                      : null;

                  if (players.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.noInvitablePlayers,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    );
                  }

                  // Group players by sourceGroupName
                  final grouped =
                      <String, List<InvitablePlayerModel>>{};
                  for (final p in players) {
                    grouped
                        .putIfAbsent(p.sourceGroupName, () => [])
                        .add(p);
                  }

                  return ListView(
                    controller: scrollController,
                    children: [
                      for (final entry in grouped.entries) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Text(
                            entry.key,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        ...entry.value.map((player) => _PlayerTile(
                              player: player,
                              gameId: gameId,
                              isSending: sendingInviteeId == player.uid,
                            )),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final InvitablePlayerModel player;
  final String gameId;
  final bool isSending;

  const _PlayerTile({
    required this.player,
    required this.gameId,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isBlocSending = context.watch<GameGuestInvitationBloc>().state
        is InvitePlayerSending;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            player.photoUrl != null ? NetworkImage(player.photoUrl!) : null,
        child: player.photoUrl == null
            ? Text(player.displayName.isNotEmpty
                ? player.displayName[0].toUpperCase()
                : '?')
            : null,
      ),
      title: Text(player.displayName),
      trailing: isSending
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : TextButton(
              onPressed: isBlocSending
                  ? null
                  : () {
                      context.read<GameGuestInvitationBloc>().add(
                            InviteGuestPlayer(
                              gameId: gameId,
                              inviteeId: player.uid,
                            ),
                          );
                    },
              child: Text(l10n.inviteGuest),
            ),
    );
  }
}
