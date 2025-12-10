import 'package:flutter/material.dart';
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
    final statusColor = _getStatusColor(context);
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
              Row(
                children: [
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
                    GameResultBadge(result: game.result!)
                  else if (isVerification)
                    _buildVerificationBadge(context)
                  else if (!isCancelled)
                    _buildRsvpStatusBadge(context),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context,
                Icons.calendar_today,
                _formatDateTime(game.scheduledAt),
                isCancelled ? Colors.grey : statusColor,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                context,
                Icons.location_on,
                game.location.name,
                isCancelled ? Colors.grey : statusColor,
              ),
              const SizedBox(height: 12),
              if (isCompletedWithResult) ...[
                const Divider(),
                const SizedBox(height: 8),
                SetScoresDisplay(result: game.result!),
              ] else if (!isCancelled) ...[
                _buildPlayerCountBar(context),
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
        return Colors.purple.withOpacity(0.05);
      case GameStatus.completed:
        return Colors.green.withOpacity(0.05);
      case GameStatus.inProgress:
        return Colors.orange.withOpacity(0.05);
      default:
        return null;
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (game.status) {
      case GameStatus.scheduled:
        return Colors.blue;
      case GameStatus.inProgress:
        return Colors.orange;
      case GameStatus.verification:
        return Colors.purple;
      case GameStatus.completed:
        return Colors.green;
      case GameStatus.cancelled:
        return Colors.grey;
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pending_actions, size: 16, color: Colors.purple.shade700),
          const SizedBox(width: 4),
          Text(
            'Pending Verification',
            style: TextStyle(
              color: Colors.purple.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRsvpStatusBadge(BuildContext context) {
    final isPlayer = game.isPlayer(userId);
    final isOnWaitlist = game.isOnWaitlist(userId);

    if (isPlayer) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 16, color: Colors.green),
            const SizedBox(width: 4),
            Text(
              "You're In",
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (isOnWaitlist) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_empty, size: 16, color: Colors.orange),
            const SizedBox(width: 4),
            Text(
              'On Waitlist',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    if (game.isFull && !game.allowWaitlist) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.block, size: 16, color: Colors.red),
            const SizedBox(width: 4),
            Text(
              'Full',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_add,
            size: 16,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            'Join Game',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCountBar(BuildContext context) {
    final progress = game.currentPlayerCount / game.maxPlayers;

    return Column(
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
                  : game.currentPlayerCount >= game.minPlayers
                      ? Colors.green
                      : Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final gameDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dayString;
    if (gameDate == today) {
      dayString = 'Today';
    } else if (gameDate == tomorrow) {
      dayString = 'Tomorrow';
    } else {
      dayString = DateFormat('EEE, MMM d').format(dateTime);
    }

    final timeString = DateFormat('h:mm a').format(dateTime);
    return '$dayString • $timeString';
  }
}
