import 'package:flutter/material.dart';

import '../../../../core/domain/repositories/training_feedback_repository.dart';

/// Displays aggregated feedback statistics for a training session
/// Shows average ratings, total count, and rating breakdowns
class FeedbackSummaryCard extends StatelessWidget {
  final FeedbackAggregation aggregation;

  const FeedbackSummaryCard({
    super.key,
    required this.aggregation,
  });

  @override
  Widget build(BuildContext context) {
    if (aggregation.totalCount == 0) {
      return const SizedBox.shrink();
    }

    final overallAverage = aggregation.overallAverage;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.bar_chart, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Feedback Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Overall rating
            Center(
              child: Column(
                children: [
                  Text(
                    overallAverage.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  _buildStarRating(overallAverage),
                  const SizedBox(height: 8),
                  Text(
                    'Based on ${aggregation.totalCount} ${aggregation.totalCount == 1 ? 'rating' : 'ratings'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Individual category ratings
            _buildCategoryRating(
              context,
              'Exercises Quality',
              Icons.fitness_center,
              aggregation.averageExercisesQuality,
            ),
            const SizedBox(height: 12),
            _buildCategoryRating(
              context,
              'Training Intensity',
              Icons.local_fire_department,
              aggregation.averageTrainingIntensity,
            ),
            const SizedBox(height: 12),
            _buildCategoryRating(
              context,
              'Coaching Clarity',
              Icons.school,
              aggregation.averageCoachingClarity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        IconData icon;

        if (rating >= starValue) {
          icon = Icons.star;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }

        return Icon(
          icon,
          color: Colors.amber,
          size: 32,
        );
      }),
    );
  }

  Widget _buildCategoryRating(
    BuildContext context,
    String label,
    IconData icon,
    double rating,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: rating / 5,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getRatingColor(rating),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) {
      return Colors.green;
    } else if (rating >= 3.5) {
      return Colors.lightGreen;
    } else if (rating >= 2.5) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
