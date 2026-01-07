// Widget for displaying a training session in the group activity feed
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:play_with_me/core/data/models/training_session_model.dart';

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
    final isCancelled = session.status == TrainingStatus.cancelled;
    final isCompleted = session.status == TrainingStatus.completed;

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
                    color: isCancelled
                        ? Colors.grey
                        : Theme.of(context).colorScheme.secondary,
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
                  _buildTrainingBadge(context),
                ],
              ),
              const SizedBox(height: 12),
              // Date/Time
              _buildInfoRow(
                context,
                Icons.calendar_today,
                _formatDateTime(session.startTime),
                isCancelled ? Colors.grey : Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 8),
              // Location
              _buildInfoRow(
                context,
                Icons.location_on,
                session.location.name,
                isCancelled ? Colors.grey : Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 8),
              // Duration
              _buildInfoRow(
                context,
                Icons.access_time,
                _formatDuration(session.duration),
                isCancelled ? Colors.grey : Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 12),
              // Participant count (no scores for training sessions)
              if (!isCancelled) _buildParticipantCountBar(context),
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
          .withOpacity(0.5);
    }

    if (session.status == TrainingStatus.completed) {
      return Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2);
    }

    // Subtle background for training sessions
    return Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.1);
  }

  Widget _buildTrainingBadge(BuildContext context) {
    final isCancelled = session.status == TrainingStatus.cancelled;
    final isParticipant = session.isParticipant(userId);

    if (isCancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Text(
          'CANCELLED',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      );
    }

    if (isParticipant) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 12,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              'JOINED',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
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
        'TRAINING',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
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

  Widget _buildParticipantCountBar(BuildContext context) {
    final progress = session.currentParticipantCount / session.maxParticipants;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${session.currentParticipantCount}/${session.maxParticipants} participants',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isPast
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (session.currentParticipantCount < session.minParticipants)
              Text(
                'Min: ${session.minParticipants}',
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
                  : session.currentParticipantCount >= session.minParticipants
                      ? Theme.of(context).colorScheme.secondary
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
    final sessionDate =
        DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dayString;
    if (sessionDate == today) {
      dayString = 'Today';
    } else if (sessionDate == tomorrow) {
      dayString = 'Tomorrow';
    } else {
      dayString = DateFormat('EEE, MMM d').format(dateTime);
    }

    final timeString = DateFormat('h:mm a').format(dateTime);
    return '$dayString • $timeString';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}
