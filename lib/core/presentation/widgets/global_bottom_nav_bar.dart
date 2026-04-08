// Shared global bottom navigation bar used across top-level app screens.
import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// Global bottom navigation bar with four sections: Home, Stats, Groups, Community.
/// Pass [selectedIndex] to highlight the current section and [friendRequestCount]
/// to show the red badge on the Community icon.
class GlobalBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final int friendRequestCount;

  const GlobalBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.friendRequestCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.bottomNavBackground,
      selectedItemColor: AppColors.navLabelColor,
      unselectedItemColor: AppColors.navLabelColor,
      selectedIconTheme: const IconThemeData(color: AppColors.primary),
      unselectedIconTheme: const IconThemeData(color: AppColors.navLabelColor),
      currentIndex: selectedIndex,
      onTap: onTabSelected,
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
        BottomNavigationBarItem(
          icon: const Icon(Icons.bar_chart),
          label: l10n.stats,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.group_work),
          label: l10n.groups,
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.people),
              if (friendRequestCount > 0)
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      friendRequestCount > 9 ? '9+' : '$friendRequestCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: l10n.community,
        ),
      ],
    );
  }
}
