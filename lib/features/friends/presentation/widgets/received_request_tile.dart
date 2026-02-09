import 'package:flutter/material.dart';
import 'package:play_with_me/core/domain/entities/friendship_entity.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// Widget for displaying a received friend request
class ReceivedRequestTile extends StatelessWidget {
  final FriendshipEntity request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const ReceivedRequestTile({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFEACE6A).withValues(alpha: 0.25),
        child: Text(
          _getInitials(request.initiatorName),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF004E64),
          ),
        ),
      ),
      title: Text(
        request.initiatorName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        'Sent ${_formatDate(request.createdAt)}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: onAccept,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              backgroundColor: Colors.green,
            ),
            child: Text(l10n.accept),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onDecline,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: Text(l10n.decline),
          ),
        ],
      ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
