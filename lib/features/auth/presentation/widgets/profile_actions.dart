import 'package:flutter/material.dart';
import 'package:play_with_me/features/auth/presentation/widgets/auth_button.dart';

class ProfileActions extends StatelessWidget {
  const ProfileActions({
    super.key,
    required this.onEditProfile,
    required this.onAccountSettings,
    required this.onSignOut,
  });

  final VoidCallback onEditProfile;
  final VoidCallback onAccountSettings;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Profile Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Edit Profile Button
            _ActionTile(
              icon: Icons.edit,
              title: 'Edit Profile',
              subtitle: 'Update your profile information',
              onTap: onEditProfile,
            ),

            const Divider(height: 24),

            // Account Settings Button
            _ActionTile(
              icon: Icons.settings,
              title: 'Account Settings',
              subtitle: 'Manage your account preferences',
              onTap: onAccountSettings,
            ),

            const Divider(height: 24),

            // Sign Out Button
            AuthButton(
              text: 'Sign Out',
              onPressed: onSignOut,
              isOutlined: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
      ),
    );
  }
}