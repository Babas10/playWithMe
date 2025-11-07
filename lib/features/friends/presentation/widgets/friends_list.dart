import 'package:flutter/material.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'friend_tile.dart';

/// Widget for displaying a list of friends
class FriendsList extends StatelessWidget {
  final List<UserEntity> friends;
  final Function(String friendshipId) onRemoveFriend;
  final Function(UserEntity friend)? onFriendTap;

  const FriendsList({
    super.key,
    required this.friends,
    required this.onRemoveFriend,
    this.onFriendTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (friends.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 64,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noFriendsYet,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.searchForFriends,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return FriendTile(
          friend: friend,
          onRemove: () => _showRemoveConfirmation(
            context,
            friend,
          ),
          onTap: onFriendTap != null ? () => onFriendTap!(friend) : null,
        );
      },
    );
  }

  void _showRemoveConfirmation(BuildContext context, UserEntity friend) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.removeFriend),
        content: Text(
          l10n.removeFriendConfirmation(friend.displayName ?? friend.email),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Note: We need the friendshipId, but we only have the UserEntity
              // This will need to be passed differently or stored in the entity
              // For now, we'll use the uid as a placeholder
              onRemoveFriend(friend.uid);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }
}
