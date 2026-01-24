// Reusable bottom navigation bar for group details page with three main actions
import 'package:flutter/material.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class GroupBottomNavBar extends StatelessWidget {
  final bool isAdmin;
  final int upcomingGamesCount;
  final VoidCallback? onInviteTap;
  final VoidCallback? onCreateGameTap;
  final VoidCallback? onCreateTrainingTap;
  final VoidCallback? onGamesListTap;

  const GroupBottomNavBar({
    super.key,
    required this.isAdmin,
    this.upcomingGamesCount = 0,
    this.onInviteTap,
    this.onCreateGameTap,
    this.onCreateTrainingTap,
    this.onGamesListTap,
  });

  void _showCreateMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.sports_volleyball),
                title: Text(l10n.createGame),
                subtitle: Text(l10n.competitiveGameWithElo),
                onTap: () {
                  Navigator.pop(context);
                  onCreateGameTap?.call();
                },
              ),
              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: Text(l10n.createTrainingSession),
                subtitle: Text(l10n.practiceSessionNoElo),
                onTap: () {
                  Navigator.pop(context);
                  onCreateTrainingTap?.call();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
            _showCreateMenu(context);
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
          label: l10n.invite,
          tooltip: isAdmin ? l10n.inviteMembers : l10n.adminOnly,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.add_circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          label: l10n.create,
          tooltip: l10n.createGameOrTraining,
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text(upcomingGamesCount > 9 ? '9+' : '$upcomingGamesCount'),
            isLabelVisible: upcomingGamesCount > 0,
            child: Icon(
              Icons.list,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          label: l10n.activities,
          tooltip: l10n.viewAllActivities,
        ),
      ],
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    );
  }
}
