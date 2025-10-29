// Confirmation dialogs for member management actions
import 'package:flutter/material.dart';
import 'package:play_with_me/core/data/models/user_model.dart';

/// Shows a confirmation dialog for promoting a member to admin
Future<bool> showPromoteConfirmationDialog(
  BuildContext context,
  UserModel member,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Promote to Admin'),
          content: Text(
            'Are you sure you want to promote ${member.displayName ?? member.email} to admin?\n\n'
            'Admins can:\n'
            '• Manage group members\n'
            '• Invite new members\n'
            '• Modify group settings',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Promote'),
            ),
          ],
        ),
      ) ??
      false;
}

/// Shows a confirmation dialog for demoting an admin to member
Future<bool> showDemoteConfirmationDialog(
  BuildContext context,
  UserModel member,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Demote to Member'),
          content: Text(
            'Are you sure you want to demote ${member.displayName ?? member.email} to regular member?\n\n'
            'They will lose admin privileges.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Demote'),
            ),
          ],
        ),
      ) ??
      false;
}

/// Shows a confirmation dialog for removing a member from the group
Future<bool> showRemoveMemberConfirmationDialog(
  BuildContext context,
  UserModel member,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove Member'),
          content: Text(
            'Are you sure you want to remove ${member.displayName ?? member.email} from the group?\n\n'
            'This action cannot be undone. They will need to be re-invited to rejoin.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Remove'),
            ),
          ],
        ),
      ) ??
      false;
}

/// Shows a confirmation dialog for leaving a group
Future<bool> showLeaveGroupConfirmationDialog(
  BuildContext context,
  String groupName,
) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Leave Group'),
          content: Text(
            'Are you sure you want to leave "$groupName"?\n\n'
            'You will need to be re-invited to rejoin this group.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Leave'),
            ),
          ],
        ),
      ) ??
      false;
}
