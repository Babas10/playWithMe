import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/feedback/training_feedback_bloc.dart';
import '../bloc/feedback/training_feedback_event.dart';
import '../bloc/feedback/training_feedback_state.dart';

/// Anonymous feedback page for completed training sessions (Story 15.8)
/// Allows participants to provide ratings and comments after session completion
class TrainingSessionFeedbackPage extends StatefulWidget {
  final String trainingSessionId;
  final String sessionTitle;

  const TrainingSessionFeedbackPage({
    super.key,
    required this.trainingSessionId,
    required this.sessionTitle,
  });

  @override
  State<TrainingSessionFeedbackPage> createState() =>
      _TrainingSessionFeedbackPageState();
}

class _TrainingSessionFeedbackPageState
    extends State<TrainingSessionFeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _exercisesQuality = 0;
  int _trainingIntensity = 0;
  int _coachingClarity = 0;
  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    // Check if user has already submitted feedback
    context.read<TrainingFeedbackBloc>().add(
          CheckFeedbackSubmission(widget.trainingSessionId),
        );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Feedback'),
      ),
      body: BlocConsumer<TrainingFeedbackBloc, TrainingFeedbackState>(
        listener: (context, state) {
          if (state is FeedbackSubmitted) {
            setState(() {
              _hasSubmitted = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thank you for your feedback!'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate back after short delay
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.pop(context);
              }
            });
          } else if (state is FeedbackError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is FeedbackSubmissionChecked && state.hasSubmitted) {
            setState(() {
              _hasSubmitted = true;
            });
          }
        },
        builder: (context, state) {
          if (state is CheckingFeedbackSubmission) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_hasSubmitted || (state is FeedbackSubmissionChecked && state.hasSubmitted)) {
            return _buildAlreadySubmittedView();
          }

          return _buildFeedbackForm(state);
        },
      ),
    );
  }

  Widget _buildAlreadySubmittedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            const Text(
              'Feedback Already Submitted',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You have already provided feedback for "${widget.sessionTitle}".',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Session'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackForm(TrainingFeedbackState state) {
    final isSubmitting = state is SubmittingFeedback;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Session title card
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Provide Anonymous Feedback',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.sessionTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your feedback is anonymous and helps improve future training sessions.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Exercises Quality Rating
            _buildIconRating(
              'Exercises Quality',
              'Were the drills effective?',
              _exercisesQuality,
              (rating) => setState(() => _exercisesQuality = rating),
            ),
            const SizedBox(height: 24),

            // Training Intensity
            _buildIconRating(
              'Training Intensity',
              'Physical demand level',
              _trainingIntensity,
              (rating) => setState(() => _trainingIntensity = rating),
            ),
            const SizedBox(height: 24),

            // Coaching Clarity Rating
            _buildIconRating(
              'Coaching Clarity',
              'Instructions & corrections?',
              _coachingClarity,
              (rating) => setState(() => _coachingClarity = rating),
            ),
            const SizedBox(height: 32),

            // Comment section
            const Text(
              'Additional Comments (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentController,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText:
                    'Share your thoughts about the session, exercises, or suggestions for improvement...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () => _submitFeedback(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Submit Feedback',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),

            // Anonymous reminder
            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your feedback is completely anonymous and cannot be traced back to you.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconRating(
    String label,
    String subtitle,
    int currentRating,
    Function(int) onRatingChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final rating = index + 1;
            final isSelected = currentRating >= rating;
            return GestureDetector(
              onTap: () => onRatingChanged(rating),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.sports_volleyball,
                  size: isSelected ? 44 : 40,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[400],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Needs work', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text('Top-level training', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  void _submitFeedback(BuildContext context) {
    if (_exercisesQuality == 0 || _trainingIntensity == 0 || _coachingClarity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please rate all three categories before submitting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<TrainingFeedbackBloc>().add(
          SubmitFeedback(
            trainingSessionId: widget.trainingSessionId,
            exercisesQuality: _exercisesQuality,
            trainingIntensity: _trainingIntensity,
            coachingClarity: _coachingClarity,
            comment: _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
          ),
        );
  }
}
