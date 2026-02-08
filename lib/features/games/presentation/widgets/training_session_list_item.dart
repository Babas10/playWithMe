// Widget for displaying a training session in the group activity feed
import 'package:flutter/material.dart';
import 'package:play_with_me/core/presentation/widgets/joined_badge.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:play_with_me/core/data/models/training_session_model.dart';
import 'package:play_with_me/l10n/app_localizations.dart';

class TrainingSessionListItem extends StatelessWidget {
  final TrainingSessionModel session;
  final String userId;
  final bool isPast;
  final VoidCallback onTap;

  const TrainingSessionListItem({
    super.key,
    required this.session,
    required this.userId,
    this.isPast = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCancelled = session.status == TrainingStatus.cancelled;

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
              // Title row with training badge
              Row(
                children: [
                  // Training icon to distinguish from games
                  Icon(
                    Icons.fitness_center,
                    size: 20,
                    color: isCancelled ? Colors.grey : AppColors.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      session.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isCancelled
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : null,
                            decoration:
                                isCancelled ? TextDecoration.lineThrough : null,
                          ),
                    ),
                  ),
                  _buildTypeBadge(context),
                ],
              ),
              const SizedBox(height: 12),
              // Date/Time
              _buildInfoRow(
                context,
                Icons.calendar_today,
                _formatDateTime(context, session.startTime),
                isCancelled ? Colors.grey : AppColors.secondary,
              ),
              const SizedBox(height: 8),
              // Location
              _buildInfoRow(
                context,
                Icons.location_on,
                session.location.name,
                isCancelled ? Colors.grey : AppColors.secondary,
              ),
              const SizedBox(height: 8),
              // Duration
              _buildInfoRow(
                context,
                Icons.access_time,
                _formatDuration(context, session.duration),
                isCancelled ? Colors.grey : AppColors.secondary,
              ),
              const SizedBox(height: 8),
              // Min participants
              _buildInfoRow(
                context,
                Icons.people,
                l10n.minParticipants(session.minParticipants),
                isCancelled ? Colors.grey : AppColors.secondary,
              ),
              const SizedBox(height: 12),
              // Participant count (no scores for training sessions)
              if (!isCancelled) _buildParticipantCountBarWithBadge(context),
            ],
          ),
        ),
      ),
    );
  }

  Color? _getCardBackgroundColor(BuildContext context) {
    if (session.status == TrainingStatus.cancelled) {
      return Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.5);
    }

    if (session.status == TrainingStatus.completed) {
      return Colors.green.withValues(alpha: 0.05);
    }

    // Default: no special background (same as games)
    return null;
  }

  Widget _buildTypeBadge(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCancelled = session.status == TrainingStatus.cancelled;

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        l10n.training.toUpperCase(),
        style: const TextStyle(
          color: AppColors.secondary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String text, Color iconColor) {
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

  Widget _buildParticipantCountBarWithBadge(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = session.currentParticipantCount / session.maxParticipants;
    final isParticipant = session.isParticipant(userId);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.participantsCount(session.currentParticipantCount, session.maxParticipants),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isPast
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
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
        if (isParticipant) ...[
          const SizedBox(width: 12),
          const JoinedBadge(),
        ],
      ],
    );
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final sessionDate =
        DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dayString;
    if (sessionDate == today) {
      dayString = l10n.today;
    } else if (sessionDate == tomorrow) {
      dayString = l10n.tomorrow;
    } else {
      dayString = DateFormat('EEE, MMM d').format(dateTime);
    }

    final timeString = DateFormat('h:mm a').format(dateTime);
    return '$dayString • $timeString';
  }

  String _formatDuration(BuildContext context, Duration duration) {
    final l10n = AppLocalizations.of(context)!;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return l10n.durationFormat(hours, minutes);
    } else if (hours > 0) {
      return l10n.durationHours(hours);
    } else {
      return l10n.durationMinutes(minutes);
    }
  }
}
