// Action menu for group member management (promote, demote, remove)
import 'package:flutter/material.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

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
            PopupMenuItem(
              value: MemberAction.promote,
              child: Row(
                children: [
                  const Icon(Icons.admin_panel_settings, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.promoteToAdmin),
                ],
              ),
            ),
          );
        }

        // Demote to Member (only if is admin, not creator, and not last admin)
        if (isTargetUserAdmin && !isTargetUserCreator && canDemote) {
          items.add(
            PopupMenuItem(
              value: MemberAction.demote,
              child: Row(
                children: [
                  const Icon(Icons.person, size: 20),
                  const SizedBox(width: 12),
                  Text(l10n.demoteToMember),
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
                    l10n.removeFromGroup,
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
