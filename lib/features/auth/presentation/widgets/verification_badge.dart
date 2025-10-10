import 'package:flutter/material.dart';

class VerificationBadge extends StatelessWidget {
  const VerificationBadge({
    super.key,
    required this.isVerified,
  });

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.green.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.verified,
              color: Colors.green.shade700,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Your email is verified',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.red.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Email not verified',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Please verify your email address to secure your account and access all features.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Implement resend verification email (Story 1.4.4)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email verification - Coming Soon'),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.red.shade700),
                  foregroundColor: Colors.red.shade700,
                ),
                child: const Text('Verify Email'),
              ),
            ),
          ],
        ),
      );
    }
  }
}