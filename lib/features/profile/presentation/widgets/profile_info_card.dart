import 'package:flutter/material.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';
import 'package:play_with_me/features/profile/presentation/widgets/verification_badge.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// Card widget displaying account information
class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.user,
    this.onVerificationTap,
  });

  final UserEntity user;
  final VoidCallback? onVerificationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('MMM d, yyyy');

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.accountInformation,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Email and verification status
            if (!user.isAnonymous) ...[
              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.email,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            VerificationBadge(isVerified: user.isEmailVerified),
                            if (!user.isEmailVerified && onVerificationTap != null) ...[
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: onVerificationTap,
                                icon: const Icon(Icons.send, size: 16),
                                label: Text(l10n.verify),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
            ],

            // Account type
            _InfoRow(
              icon: Icons.person_outline,
              label: l10n.accountType,
              value: user.isAnonymous ? l10n.anonymous : l10n.regular,
            ),
            const Divider(height: 24),

            // Member since
            if (user.createdAt != null) ...[
              _InfoRow(
                icon: Icons.calendar_today,
                label: l10n.memberSince,
                value: dateFormat.format(user.createdAt!),
              ),
              const Divider(height: 24),
            ],

            // Last sign in
            if (user.lastSignInAt != null) ...[
              _InfoRow(
                icon: Icons.access_time,
                label: l10n.lastActive,
                value: dateFormat.format(user.lastSignInAt!),
              ),
            ],
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
