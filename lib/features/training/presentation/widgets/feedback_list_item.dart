import 'package:flutter/material.dart';
import 'package:play_with_me/core/theme/app_colors.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/data/models/training_feedback_model.dart';

/// Displays a single feedback entry from a training session.
/// All feedback is anonymous (Story 15.8), so no user info is displayed.
class FeedbackListItem extends StatelessWidget {
  final TrainingFeedbackModel feedback;

  const FeedbackListItem({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: avatar + name/meta + rating pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Anonymous avatar
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 18,
                  child: Icon(
                    Icons.person,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),

                // Name + secondary line (timestamp + private badge)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Anonymous',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            timeago.format(feedback.submittedAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.privacy_tip_outlined,
                                size: 11,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 3),
                              const Text(
                                'Private',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Rating pill — top right
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        feedback.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Flat inline sub-ratings (no border boxes)
            Row(
              children: [
                _buildInlineRating(
                  Icons.fitness_center,
                  'Exercises',
                  feedback.exercisesQuality,
                ),
                const SizedBox(width: 20),
                _buildInlineRating(
                  Icons.local_fire_department,
                  'Intensity',
                  feedback.trainingIntensity,
                ),
                const SizedBox(width: 20),
                _buildInlineRating(
                  Icons.school,
                  'Coaching',
                  feedback.coachingClarity,
                ),
              ],
            ),

            // Comment — left-border accent, no background tint
            if (feedback.hasComment) ...[
              const SizedBox(height: 14),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feedback.comment!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInlineRating(IconData icon, String label, int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.secondary),
        const SizedBox(width: 4),
        Text(
          rating.toString(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 3),
        const Text(
          '★',
          style: TextStyle(fontSize: 11, color: AppColors.primary),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
