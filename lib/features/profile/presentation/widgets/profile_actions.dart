import 'package:flutter/material.dart';

/// Widget containing action buttons for profile operations
class ProfileActions extends StatelessWidget {
  const ProfileActions({
    super.key,
    required this.onEditProfile,
    required this.onSignOut,
  });

  final VoidCallback onEditProfile;
  final VoidCallback onSignOut;

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
