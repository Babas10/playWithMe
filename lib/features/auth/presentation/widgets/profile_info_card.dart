import 'package:flutter/material.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.user,
  });

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Account creation date
            if (user.createdAt != null) ...[
              _InfoRow(
                icon: Icons.calendar_today,
                label: 'Member since',
                value: _formatDate(user.createdAt!),
              ),
              const SizedBox(height: 12),
            ],

            // Last sign-in
            if (user.lastSignInAt != null) ...[
              _InfoRow(
                icon: Icons.access_time,
                label: 'Last sign-in',
                value: _formatDateTime(user.lastSignInAt!),
              ),
              const SizedBox(height: 12),
            ],

            // Authentication method
            _InfoRow(
              icon: Icons.security,
              label: 'Authentication',
              value: user.isAnonymous ? 'Anonymous' : 'Email & Password',
            ),
            const SizedBox(height: 12),

            // Email verification status
            _InfoRow(
              icon: user.isEmailVerified ? Icons.verified : Icons.warning,
              label: 'Email verification',
              value: user.isEmailVerified ? 'Verified' : 'Not verified',
              valueColor: user.isEmailVerified
                  ? Colors.green
                  : Theme.of(context).colorScheme.error,
            ),

            // Show verification warning if not verified
            if (!user.isEmailVerified) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Verify your email to secure your account and enable all features.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference < 1) {
      return 'Today';
    } else if (difference < 7) {
      return '$difference ${difference == 1 ? 'day' : 'days'} ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference < 365) {
      final months = (difference / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return _formatDate(dateTime);
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}