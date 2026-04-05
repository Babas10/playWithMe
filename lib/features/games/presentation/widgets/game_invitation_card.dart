// Widget displaying a single pending game invitation with Accept / Decline actions.
// Part of Story 28.7 — receive and respond to game invitations.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:play_with_me/core/data/models/game_invitation_details.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class GameInvitationCard extends StatelessWidget {
  final GameInvitationDetails invitation;

  /// When non-null, this invitation's buttons are disabled (CF call in-flight).
  final bool isProcessing;

  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const GameInvitationCard({
    super.key,
    required this.invitation,
    required this.isProcessing,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);
    final timeFormat = DateFormat.jm(Localizations.localeOf(context).languageCode);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Game title ──────────────────────────────────────────────────
            Text(
              invitation.gameTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
            ),
            const SizedBox(height: 8),

            // ── Date & time ─────────────────────────────────────────────────
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              text:
                  '${dateFormat.format(invitation.gameScheduledAt)} · ${timeFormat.format(invitation.gameScheduledAt)}',
            ),

            // ── Location (if available) ─────────────────────────────────────
            if (invitation.gameLocationName.isNotEmpty) ...[
              const SizedBox(height: 4),
              _InfoRow(
                icon: Icons.location_on_outlined,
                text: invitation.gameLocationName,
              ),
            ],

            // ── Group ───────────────────────────────────────────────────────
            if (invitation.groupName.isNotEmpty) ...[
              const SizedBox(height: 4),
              _InfoRow(
                icon: Icons.group_outlined,
                text: l10n.fromGroup(invitation.groupName),
              ),
            ],

            // ── Inviter ─────────────────────────────────────────────────────
            if (invitation.inviterDisplayName.isNotEmpty) ...[
              const SizedBox(height: 4),
              _InfoRow(
                icon: Icons.person_outline,
                text: l10n.invitedBy(invitation.inviterDisplayName),
              ),
            ],

            const SizedBox(height: 16),

            // ── Action buttons ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isProcessing)
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                OutlinedButton(
                  onPressed: isProcessing ? null : onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  child: Text(l10n.decline),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: isProcessing ? null : onAccept,
                  child: Text(l10n.accept),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
