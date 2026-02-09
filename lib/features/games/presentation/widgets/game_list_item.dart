import 'package:flutter/material.dart';
import 'package:play_with_me/core/presentation/widgets/joined_badge.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:play_with_me/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:play_with_me/core/data/models/game_model.dart';
import 'game_result_badge.dart';
import 'set_scores_display.dart';

class GameListItem extends StatelessWidget {
  final GameModel game;
  final String userId;
  final bool isPast;
  final VoidCallback onTap;

  const GameListItem({
    super.key,
    required this.game,
    required this.userId,
    this.isPast = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompletedWithResult = game.status == GameStatus.completed && game.result != null;
    final isCancelled = game.status == GameStatus.cancelled;
    final isVerification = game.status == GameStatus.verification;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isPast ? 0 : 1,
      color: _getCardBackgroundColor(context),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with game badge
              Row(
                children: [
                  // Game icon to distinguish from training sessions
                  Icon(
                    Icons.sports_volleyball,
                    size: 20,
                    color: isCancelled ? Colors.grey : AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      game.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isCancelled
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : null,
                            decoration: isCancelled
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                  ),
                  if (isCompletedWithResult)
                    GameResultBadge(
                      result: game.result!,
                      teams: game.teams,
                    )
                  else if (isVerification)
                    _buildVerificationBadge(context)
                  else if (isCancelled)
                    _buildCancelledBadge(context)
                  else
                    _buildTypeBadge(context),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                Icons.calendar_today,
                _formatDateTime(context, game.scheduledAt),
                isCancelled ? Colors.grey : AppColors.secondary,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.location_on,
                game.location.name,
                isCancelled ? Colors.grey : AppColors.secondary,
              ),
              const SizedBox(height: 12),
              if (isCompletedWithResult) ...[
                const Divider(),
                const SizedBox(height: 8),
                SetScoresDisplay(result: game.result!),
              ] else if (!isCancelled) ...[
                _buildPlayerCountBarWithBadge(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color? _getCardBackgroundColor(BuildContext context) {
    if (game.status == GameStatus.cancelled) {
      return Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5);
    }
    
    switch (game.status) {
      case GameStatus.verification:
        return AppColors.primary.withValues(alpha: 0.1);
      case GameStatus.completed:
        return Colors.green.withOpacity(0.05);
      case GameStatus.inProgress:
        return Colors.orange.withOpacity(0.05);
      default:
        return null;
    }
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isPast
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : null,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationBadge(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pending_actions, size: 16, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(
            l10n.pendingVerification,
            style: TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        l10n.gameLabel,
        style: const TextStyle(
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildCancelledBadge(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Text(
        l10n.cancelled,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget? _buildStatusBadge(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPlayer = game.isPlayer(userId);
    final isOnWaitlist = game.isOnWaitlist(userId);

    if (isPlayer) {
      return const JoinedBadge();
    }

    if (isOnWaitlist) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange),
        ),
        child: Text(
          l10n.onWaitlist,
          style: TextStyle(
            color: Colors.orange.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      );
    }

    if (game.isFull && !game.allowWaitlist) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red),
        ),
        child: Text(
          l10n.full,
          style: TextStyle(
            color: Colors.red.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      );
    }

    return null;
  }

  Widget _buildPlayerCountBarWithBadge(BuildContext context) {
    final progress = game.currentPlayerCount / game.maxPlayers;
    final statusBadge = _buildStatusBadge(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${game.currentPlayerCount}/${game.maxPlayers} players',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isPast
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  if (game.waitlistCount > 0)
                    Text(
                      '${game.waitlistCount} waitlisted',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: isPast
                      ? Theme.of(context).colorScheme.surfaceVariant
                      : Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPast
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (statusBadge != null) ...[
          const SizedBox(width: 12),
          statusBadge,
        ],
      ],
    );
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final gameDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dayString;
    if (gameDate == today) {
      dayString = l10n.today;
    } else if (gameDate == tomorrow) {
      dayString = l10n.tomorrow;
    } else {
      dayString = DateFormat('EEE, MMM d').format(dateTime);
    }

    final timeString = DateFormat('h:mm a').format(dateTime);
    return '$dayString • $timeString';
  }
}
