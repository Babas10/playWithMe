import 'package:flutter/material.dart';
import 'package:play_with_me/features/auth/domain/entities/user_entity.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.user,
  });

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? Icon(
                      Icons.person,
                      size: 50,
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
            ),

            const SizedBox(height: 16),

            // Display Name
            Text(
              user.displayNameOrEmail,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Email with verification status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  user.isEmailVerified ? Icons.verified : Icons.pending,
                  size: 18,
                  color: user.isEmailVerified
                      ? Colors.green
                      : Theme.of(context).colorScheme.error,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Account type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: user.isAnonymous
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: user.isAnonymous
                      ? Colors.orange
                      : Theme.of(context).primaryColor,
                  width: 1,
                ),
              ),
              child: Text(
                user.isAnonymous ? 'Guest Account' : 'Registered User',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: user.isAnonymous
                      ? Colors.orange.shade700
                      : Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}