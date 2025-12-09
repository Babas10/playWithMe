import 'package:flutter/material.dart';

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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Account Settings button (renamed from Edit Profile)
          FilledButton.icon(
            onPressed: onEditProfile,
            icon: const Icon(Icons.settings),
            label: const Text('Account Settings'),
          ),
          const SizedBox(height: 12),

          // Notification Settings button
          if (onNotificationSettings != null)
            OutlinedButton.icon(
              onPressed: onNotificationSettings,
              icon: const Icon(Icons.notifications_outlined),
              label: const Text('Notification Settings'),
            ),

          // Game History button
          if (onGameHistory != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onGameHistory,
              icon: const Icon(Icons.history),
              label: const Text('Game History'),
            ),
          ],
          const SizedBox(height: 24),

          // Sign Out button
          TextButton.icon(
            onPressed: onSignOut,
            icon: const Icon(Icons.logout),
            label: const Text('Sign Out'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
