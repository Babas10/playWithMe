// Widget for displaying group member with friendship status and add friend button
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/user_model.dart';
import 'package:play_with_me/core/domain/repositories/friend_repository.dart';

/// Displays a group member with their friendship status and action buttons
class MemberListItemWithFriendship extends StatelessWidget {
  final UserModel user;
  final bool isAdmin;
  final bool isCreator;
  final bool isCurrentUser;
  final String currentUserId;
  final bool isFriend;
  final FriendRequestStatus requestStatus;
  final VoidCallback? onRefresh;
  final Function(String targetUserId)? onSendFriendRequest;

  const MemberListItemWithFriendship({
    super.key,
    required this.user,
    required this.isAdmin,
    required this.isCreator,
    required this.isCurrentUser,
    required this.currentUserId,
    required this.isFriend,
    required this.requestStatus,
    this.onRefresh,
    this.onSendFriendRequest,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
        child: user.photoUrl == null
            ? Text(
                _getInitials(user.displayName ?? user.email),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.displayName ?? user.email,
              style: const TextStyle(fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            Text(
              '(You)',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (isAdmin) ...[
            const SizedBox(width: 8),
            Chip(
              label: const Text(
                'Admin',
                style: TextStyle(fontSize: 12),
              ),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
          if (isCreator) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.star,
              size: 16,
              color: Colors.amber[700],
            ),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user.displayName != null) Text(user.email),
          if (!isCurrentUser) _buildFriendshipStatus(context),
        ],
      ),
      trailing: !isCurrentUser ? _buildTrailingWidget(context) : null,
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

  Widget _buildFriendshipStatus(BuildContext context) {
    if (isFriend) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green[700],
          ),
          const SizedBox(width: 4),
          Text(
            'Friend',
            style: TextStyle(
              color: Colors.green[700],
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    if (requestStatus == FriendRequestStatus.sentByMe) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 16,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Text(
            'Request Sent',
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    if (requestStatus == FriendRequestStatus.receivedFromThem) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_add,
            size: 16,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 4),
          Text(
            'Wants to be friends',
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return Text(
      'Not in Community',
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 12,
      ),
    );
  }

  Widget? _buildTrailingWidget(BuildContext context) {
    if (isFriend) {
      return null; // Already friends, no action needed
    }

    if (requestStatus == FriendRequestStatus.sentByMe) {
      return Chip(
        label: const Text('Pending'),
        backgroundColor: Colors.orange.shade100,
        labelStyle: TextStyle(
          color: Colors.orange[900],
          fontSize: 11,
        ),
      );
    }

    if (requestStatus == FriendRequestStatus.receivedFromThem) {
      // Show accept/decline buttons for incoming requests
      // Note: This is a simplified version - full implementation would
      // require access to the friendshipId
      return const SizedBox.shrink();
    }

    // Not in community - show add button
    return IconButton(
      icon: const Icon(Icons.person_add_outlined),
      onPressed: () => _sendFriendRequest(context),
      tooltip: 'Add to Community',
      color: Theme.of(context).colorScheme.primary,
      iconSize: 24,
    );
  }

  void _sendFriendRequest(BuildContext context) {
    if (onSendFriendRequest != null) {
      onSendFriendRequest!(user.uid);
    }
  }
}
