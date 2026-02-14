// UI guard that blocks restricted account actions and shows an explanation dialog.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/account_status/account_status_bloc.dart';
import 'package:play_with_me/core/presentation/bloc/account_status/account_status_state.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

/// Checks account status before allowing an action.
///
/// If the account is restricted, shows a dialog explaining the restriction
/// and offering to verify the email. Otherwise, calls [onAllowed].
///
/// Usage:
/// ```dart
/// RestrictedActionGuard.check(
///   context: context,
///   onAllowed: () { /* proceed with action */ },
///   onVerifyEmail: () { /* trigger email verification */ },
/// );
/// ```
class RestrictedActionGuard {
  RestrictedActionGuard._();

  /// Returns `true` if the account status allows the action to proceed.
  static bool isActionAllowed(AccountStatusState state) {
    return state is AccountStatusActive ||
        state is AccountStatusPending ||
        state is AccountStatusLoading;
  }

  /// Checks the current account status and either calls [onAllowed]
  /// or shows a restriction dialog.
  static void check({
    required BuildContext context,
    required VoidCallback onAllowed,
    required VoidCallback onVerifyEmail,
  }) {
    final state = context.read<AccountStatusBloc>().state;

    if (isActionAllowed(state)) {
      onAllowed();
      return;
    }

    _showRestrictionDialog(
      context: context,
      onVerifyEmail: onVerifyEmail,
      daysUntilDeletion: state is AccountStatusRestricted
          ? state.daysUntilDeletion
          : 0,
    );
  }

  static void _showRestrictionDialog({
    required BuildContext context,
    required VoidCallback onVerifyEmail,
    required int daysUntilDeletion,
  }) {
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.block, color: Colors.red.shade700, size: 24),
            const SizedBox(width: 8),
            Text(l10n.featureRestrictedTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.featureRestricted),
            const SizedBox(height: 8),
            Text(l10n.verifyToUnlock),
            if (daysUntilDeletion > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.red.shade700, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        l10n.accountDeletionWarning(daysUntilDeletion),
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.dismiss),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onVerifyEmail();
            },
            child: Text(l10n.verifyEmail),
          ),
        ],
      ),
    );
  }
}
