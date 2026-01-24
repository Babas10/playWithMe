import 'package:flutter/material.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// Widget containing action buttons for profile operations
class ProfileActions extends StatelessWidget {
  const ProfileActions({
    super.key,
    required this.onEditProfile,
    required this.onSignOut,
    this.onNotificationSettings,
    this.onGameHistory,
  });

  final VoidCallback onEditProfile;
  final VoidCallback onSignOut;
  final VoidCallback? onNotificationSettings;
  final VoidCallback? onGameHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Account Settings button (renamed from Edit Profile)
          FilledButton.icon(
            onPressed: onEditProfile,
            icon: const Icon(Icons.settings),
            label: Text(l10n.accountSettings),
          ),
          const SizedBox(height: 12),

          // Notification Settings button
          if (onNotificationSettings != null)
            OutlinedButton.icon(
              onPressed: onNotificationSettings,
              icon: const Icon(Icons.notifications_outlined),
              label: Text(l10n.notificationSettings),
            ),

          // Game History button
          if (onGameHistory != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onGameHistory,
              icon: const Icon(Icons.history),
              label: Text(l10n.gameHistory),
            ),
          ],
          const SizedBox(height: 24),

          // Sign Out button
          TextButton.icon(
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
            label: Text(l10n.signOut),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
