// Bottom sheet for inviting people from other groups to a game (Story 28.6).
// Shows one card per source group; tapping a card invites all its members.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/data/models/invitable_player_model.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

import '../bloc/game_guest_invitation/game_guest_invitation_bloc.dart';
import '../bloc/game_guest_invitation/game_guest_invitation_event.dart';
import '../bloc/game_guest_invitation/game_guest_invitation_state.dart';

/// Opens the invite-from-other-groups bottom sheet for [gameId].
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
      child: _InviteGroupsSheet(gameId: gameId),
    ),
  );
}

// ── Sheet ─────────────────────────────────────────────────────────────────────

class _InviteGroupsSheet extends StatefulWidget {
  final String gameId;

  const _InviteGroupsSheet({required this.gameId});

  @override
  State<_InviteGroupsSheet> createState() => _InviteGroupsSheetState();
}

class _InviteGroupsSheetState extends State<_InviteGroupsSheet> {
  /// Groups that have been successfully invited this session.
  final Set<String> _invitedGroupIds = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
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
                  if (state is InviteGroupSuccess) {
                    setState(() => _invitedGroupIds.add(state.groupId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.inviteGroupSuccess)),
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
                    return _ErrorView(
                      message: state.message,
                      gameId: widget.gameId,
                    );
                  }

                  final players = switch (state) {
                    InvitablePlayersLoaded s => s.players,
                    InviteGroupSending s => s.players,
                    InviteGroupSuccess s => s.players,
                    InvitePlayerSending s => s.players,
                    InvitePlayerSuccess s => s.players,
                    InvitePlayerError s => s.players,
                    _ => const <InvitablePlayerModel>[],
                  };

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

                  // Group players by sourceGroupId
                  final grouped = <String, List<InvitablePlayerModel>>{};
                  for (final p in players) {
                    grouped.putIfAbsent(p.sourceGroupId, () => []).add(p);
                  }

                  final sendingGroupId = state is InviteGroupSending
                      ? state.groupId
                      : null;
                  final isSendingAny = sendingGroupId != null;

                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    children: grouped.entries.map((entry) {
                      final groupId = entry.key;
                      final members = entry.value;
                      final groupName = members.first.sourceGroupName;
                      final isThisSending = sendingGroupId == groupId;
                      final isInvited = _invitedGroupIds.contains(groupId);

                      return _GroupCard(
                        groupName: groupName,
                        members: members,
                        isSending: isThisSending,
                        isInvited: isInvited,
                        isDisabled: isSendingAny || isInvited,
                        onTap: () {
                          context.read<GameGuestInvitationBloc>().add(
                                InviteGroupPlayers(
                                  gameId: widget.gameId,
                                  groupId: groupId,
                                ),
                              );
                        },
                      );
                    }).toList(),
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

// ── Group card ────────────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  final String groupName;
  final List<InvitablePlayerModel> members;
  final bool isSending;
  final bool isInvited;
  final bool isDisabled;
  final VoidCallback onTap;

  const _GroupCard({
    required this.groupName,
    required this.members,
    required this.isSending,
    required this.isInvited,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isInvited
              ? Colors.green.shade200
              : Colors.grey.shade200,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Stacked avatars
              _AvatarStack(members: members),
              const SizedBox(width: 14),
              // Group name + count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A2C32),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.groupMembersCount(members.length),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Trailing state
              if (isSending)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (isInvited)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle,
                        size: 18, color: Colors.green.shade600),
                    const SizedBox(width: 4),
                    Text(
                      l10n.invitedLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                )
              else
                const Icon(Icons.chevron_right,
                    size: 20, color: Color(0xFF64748B)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Avatar stack ─────────────────────────────────────────────────────────────

class _AvatarStack extends StatelessWidget {
  static const _size = 32.0;
  static const _overlap = 10.0;
  static const _maxVisible = 3;

  final List<InvitablePlayerModel> members;

  const _AvatarStack({required this.members});

  @override
  Widget build(BuildContext context) {
    final visible = members.take(_maxVisible).toList();
    final extra = members.length - _maxVisible;
    final totalWidth = _size + (_size - _overlap) * (visible.length - 1).clamp(0, _maxVisible - 1).toDouble();

    return SizedBox(
      width: totalWidth,
      height: _size,
      child: Stack(
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * (_size - _overlap),
              child: _buildAvatar(visible[i], extra > 0 && i == visible.length - 1 ? extra : 0),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(InvitablePlayerModel player, int overflowCount) {
    if (overflowCount > 0) {
      return CircleAvatar(
        radius: _size / 2,
        backgroundColor: Colors.grey.shade300,
        child: Text(
          '+$overflowCount',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: _size / 2,
      backgroundImage:
          player.photoUrl != null ? NetworkImage(player.photoUrl!) : null,
      backgroundColor: Colors.grey.shade200,
      child: player.photoUrl == null
          ? Text(
              player.displayName.isNotEmpty
                  ? player.displayName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A2C32),
              ),
            )
          : null,
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final String gameId;

  const _ErrorView({required this.message, required this.gameId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
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
}
