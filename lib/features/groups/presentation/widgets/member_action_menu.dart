// Action menu for group member management (promote, demote, remove)
import 'package:flutter/material.dart';

enum MemberAction {
  promote,
  demote,
  remove,
}

class MemberActionMenu extends StatelessWidget {
  final bool isCurrentUserAdmin;
  final bool isTargetUserAdmin;
  final bool isTargetUserCreator;
  final bool canDemote; // False if this is the last admin
  final void Function(MemberAction action) onActionSelected;

  const MemberActionMenu({
    super.key,
    required this.isCurrentUserAdmin,
    required this.isTargetUserAdmin,
    required this.isTargetUserCreator,
    required this.canDemote,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Non-admins don't see any menu
    if (!isCurrentUserAdmin) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<MemberAction>(
      onSelected: onActionSelected,
      itemBuilder: (context) {
        final items = <PopupMenuEntry<MemberAction>>[];

        // Promote to Admin (only if not already an admin)
        if (!isTargetUserAdmin) {
          items.add(
            const PopupMenuItem(
              value: MemberAction.promote,
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings, size: 20),
                  SizedBox(width: 12),
                  Text('Promote to Admin'),
                ],
              ),
            ),
          );
        }

        // Demote to Member (only if is admin, not creator, and not last admin)
        if (isTargetUserAdmin && !isTargetUserCreator && canDemote) {
          items.add(
            const PopupMenuItem(
              value: MemberAction.demote,
              child: Row(
                children: [
                  Icon(Icons.person, size: 20),
                  SizedBox(width: 12),
                  Text('Demote to Member'),
                ],
              ),
            ),
          );
        }

        // Remove from Group (always available for non-creators)
        if (!isTargetUserCreator) {
          if (items.isNotEmpty) {
            items.add(const PopupMenuDivider());
          }
          items.add(
            PopupMenuItem(
              value: MemberAction.remove,
              child: Row(
                children: [
                  Icon(
                    Icons.person_remove,
                    size: 20,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Remove from Group',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return items;
      },
      icon: const Icon(Icons.more_vert),
    );
  }
}
