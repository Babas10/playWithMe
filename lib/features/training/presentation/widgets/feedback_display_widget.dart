import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/repositories/training_feedback_repository.dart';
import '../../../../core/services/service_locator.dart';
import '../bloc/feedback/training_feedback_bloc.dart';
import '../bloc/feedback/training_feedback_event.dart';
import '../bloc/feedback/training_feedback_state.dart';
import '../pages/training_session_feedback_page.dart';
import 'feedback_list_item.dart';
import 'feedback_summary_card.dart';

/// Displays feedback for a training session
/// Shows aggregated statistics and individual feedback entries
/// Provides option to submit feedback if user hasn't done so
class FeedbackDisplayWidget extends StatefulWidget {
  final String trainingSessionId;
  final String sessionTitle;

  const FeedbackDisplayWidget({
    super.key,
    required this.trainingSessionId,
    required this.sessionTitle,
  });

  @override
  State<FeedbackDisplayWidget> createState() => _FeedbackDisplayWidgetState();
}

class _FeedbackDisplayWidgetState extends State<FeedbackDisplayWidget> {
  @override
  void initState() {
    super.initState();
    // Load aggregated feedback when widget is created
    context.read<TrainingFeedbackBloc>().add(
          LoadAggregatedFeedback(widget.trainingSessionId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrainingFeedbackBloc, TrainingFeedbackState>(
      builder: (context, state) {
        // Loading state
        if (state is LoadingAggregatedFeedback) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Error state
        if (state is FeedbackError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading feedback',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<TrainingFeedbackBloc>().add(
                            LoadAggregatedFeedback(widget.trainingSessionId),
                          );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Loaded state
        if (state is AggregatedFeedbackLoaded) {
          final aggregation = state.aggregation;
          final hasUserSubmitted = state.hasUserSubmitted;

          // No feedback yet
          if (aggregation.totalCount == 0) {
            return _buildEmptyState(context, hasUserSubmitted);
          }

          // Display feedback
          return _buildFeedbackDisplay(
            context,
            aggregation,
            hasUserSubmitted,
          );
        }

        // Initial/unknown state - show loading
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool hasUserSubmitted) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.feedback_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No Feedback Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              hasUserSubmitted
                  ? 'You have submitted feedback, but no other participants have provided feedback yet.'
                  : 'Be the first to provide feedback for this training session!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            if (!hasUserSubmitted)
              ElevatedButton.icon(
                onPressed: () => _navigateToSubmitFeedback(context),
                icon: const Icon(Icons.rate_review),
                label: const Text('Submit Feedback'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackDisplay(
    BuildContext context,
    FeedbackAggregation aggregation,
    bool hasUserSubmitted,
  ) {
    return CustomScrollView(
      slivers: [
        // Summary card
        SliverToBoxAdapter(
          child: FeedbackSummaryCard(aggregation: aggregation),
        ),

        // Submit feedback prompt (if user hasn't submitted)
        if (!hasUserSubmitted)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.rate_review,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Share your thoughts about this session',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _navigateToSubmitFeedback(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Section header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.reviews, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Individual Feedback',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${aggregation.totalCount}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Individual feedback list
        SliverToBoxAdapter(
          child: StreamBuilder<List<dynamic>>(
            stream: sl<TrainingFeedbackRepository>()
                .getFeedbackListStream(widget.trainingSessionId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              final feedbackList = snapshot.data!;
              return Column(
                children: feedbackList.map((feedback) {
                  return FeedbackListItem(feedback: feedback);
                }).toList(),
              );
            },
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
      ],
    );
  }

  void _navigateToSubmitFeedback(BuildContext context) {
    // Capture bloc reference before async gap
    final feedbackBloc = context.read<TrainingFeedbackBloc>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<TrainingFeedbackBloc>(),
          child: TrainingSessionFeedbackPage(
            trainingSessionId: widget.trainingSessionId,
            sessionTitle: widget.sessionTitle,
          ),
        ),
      ),
    ).then((_) {
      // Reload feedback after returning from submission page
      if (mounted) {
        feedbackBloc.add(
          LoadAggregatedFeedback(widget.trainingSessionId),
        );
      }
    });
  }
}
