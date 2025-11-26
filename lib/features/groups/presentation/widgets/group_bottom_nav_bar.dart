// Reusable bottom navigation bar for group details page with three main actions
import 'package:flutter/material.dart';

class GroupBottomNavBar extends StatelessWidget {
  final bool isAdmin;
  final VoidCallback? onInviteTap;
  final VoidCallback? onCreateGameTap;
  final VoidCallback? onGamesListTap;

  const GroupBottomNavBar({
    super.key,
    required this.isAdmin,
    this.onInviteTap,
    this.onCreateGameTap,
    this.onGamesListTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 0:
            if (isAdmin && onInviteTap != null) {
              onInviteTap!();
            }
            break;
          case 1:
            onCreateGameTap?.call();
            break;
          case 2:
            onGamesListTap?.call();
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person_add,
            color: isAdmin
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).disabledColor,
          ),
          label: 'Invite',
          tooltip: isAdmin ? 'Invite Members' : 'Admin only',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.add_circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          label: 'Create Game',
          tooltip: 'Create a new game',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.list,
            color: Theme.of(context).colorScheme.primary,
          ),
          label: 'Games',
          tooltip: 'View all games',
        ),
      ],
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }
}
