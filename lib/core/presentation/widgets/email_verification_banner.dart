// Dismissible warning banner for users who have not verified their email.
import 'package:flutter/material.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class EmailVerificationBanner extends StatelessWidget {
  final int daysRemaining;
  final VoidCallback onVerifyNow;
  final VoidCallback onDismiss;

  const EmailVerificationBanner({
    super.key,
    required this.daysRemaining,
    required this.onVerifyNow,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.amber.shade700,
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.verifyEmailWarning(daysRemaining),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _BannerButton(
            label: l10n.verifyNow,
            onPressed: onVerifyNow,
            filled: true,
          ),
          const SizedBox(width: 6),
          _BannerButton(
            label: l10n.dismiss,
            onPressed: onDismiss,
            filled: false,
          ),
        ],
      ),
    );
  }
}

class _BannerButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  const _BannerButton({
    required this.label,
    required this.onPressed,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.amber.shade800,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );
    }

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
