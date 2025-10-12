import 'package:flutter/material.dart';

/// Widget containing action buttons for profile operations
class ProfileActions extends StatelessWidget {
  const ProfileActions({
    super.key,
    required this.onEditProfile,
    required this.onSettings,
    required this.onSignOut,
  });

  final VoidCallback onEditProfile;
  final VoidCallback onSettings;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Edit Profile button
          FilledButton.icon(
            onPressed: onEditProfile,
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
          ),
          const SizedBox(height: 12),

          // Settings button
          OutlinedButton.icon(
            onPressed: onSettings,
            icon: const Icon(Icons.settings),
            label: const Text('Account Settings'),
          ),
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
