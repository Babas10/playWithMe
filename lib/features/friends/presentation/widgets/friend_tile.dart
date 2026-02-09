import 'package:flutter/material.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';

/// Widget for displaying a friend in the friends list
class FriendTile extends StatelessWidget {
  final UserEntity friend;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  const FriendTile({
    super.key,
    required this.friend,
    required this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFEACE6A).withValues(alpha: 0.25),
        backgroundImage:
            friend.photoUrl != null ? NetworkImage(friend.photoUrl!) : null,
        child: friend.photoUrl == null
            ? Text(
                _getInitials(friend.displayNameOrEmail),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004E64),
                ),
              )
            : null,
      ),
      title: Text(
        friend.displayName ?? friend.email,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: friend.displayName != null ? Text(friend.email) : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        tooltip: 'Remove friend',
        onPressed: onRemove,
      ),
      onTap: onTap,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
