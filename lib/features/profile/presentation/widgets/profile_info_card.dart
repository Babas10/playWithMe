import 'package:flutter/material.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:intl/intl.dart';

/// Card widget displaying account information
class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.user,
  });

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Account type
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Account Type',
              value: user.isAnonymous ? 'Anonymous' : 'Regular',
            ),
            const Divider(height: 24),

            // Member since
            if (user.createdAt != null) ...[
              _InfoRow(
                icon: Icons.calendar_today,
                label: 'Member Since',
                value: dateFormat.format(user.createdAt!),
              ),
              const Divider(height: 24),
            ],

            // Last sign in
            if (user.lastSignInAt != null) ...[
              _InfoRow(
                icon: Icons.access_time,
                label: 'Last Active',
                value: dateFormat.format(user.lastSignInAt!),
              ),
              const Divider(height: 24),
            ],

            // User ID
            _InfoRow(
              icon: Icons.fingerprint,
              label: 'User ID',
              value: '${user.uid.substring(0, 8)}...',
              valueStyle: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Private widget for displaying information rows
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: valueStyle ?? theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
