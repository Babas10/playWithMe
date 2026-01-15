import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/data/models/training_session_model.dart';
import '../../../../core/data/models/user_model.dart';
import '../../../../core/domain/repositories/training_session_repository.dart';
import '../../../../core/domain/repositories/user_repository.dart';
import '../../../../core/services/service_locator.dart';
import '../bloc/exercise/exercise_bloc.dart';
import '../bloc/feedback/training_feedback_bloc.dart';
import '../bloc/training_session_participation/training_session_participation_bloc.dart';
import '../bloc/training_session_participation/training_session_participation_event.dart';
import '../bloc/training_session_participation/training_session_participation_state.dart';
import '../widgets/exercise_list_widget.dart';
import '../widgets/feedback_display_widget.dart';

/// Training session details page with complete functionality:
/// - Session details display
/// - Exercise management (Story 15.7)
/// - Join/Leave functionality
/// - Participant list with user profiles
/// - Organizer information
/// - Feedback for completed sessions (Story 15.8)
class TrainingSessionDetailsPage extends StatefulWidget {
  final String trainingSessionId;

  const TrainingSessionDetailsPage({
    super.key,
    required this.trainingSessionId,
  });

  @override
  State<TrainingSessionDetailsPage> createState() =>
      _TrainingSessionDetailsPageState();
}

class _TrainingSessionDetailsPageState
    extends State<TrainingSessionDetailsPage> {
  late final TrainingSessionParticipationBloc _participationBloc;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _participationBloc = sl<TrainingSessionParticipationBloc>();
    _participationBloc.add(LoadParticipants(widget.trainingSessionId));
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Auto-update session status if needed (completed/cancelled based on time and participants)
    _updateSessionStatusIfNeeded();
  }

  Future<void> _updateSessionStatusIfNeeded() async {
    try {
      await sl<TrainingSessionRepository>()
          .updateSessionStatusIfNeeded(widget.trainingSessionId);
    } catch (e) {
      // Silently fail - status will be updated on next page load
      // This is a best-effort background update
    }
  }

  @override
  void dispose() {
    _participationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TrainingSessionParticipationBloc>.value(
      value: _participationBloc,
      child: StreamBuilder<TrainingSessionModel?>(
        stream: sl<TrainingSessionRepository>()
            .getTrainingSessionStream(widget.trainingSessionId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: AppBar(title: const Text('Training Session')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Training Session')),
              body: const Center(
                child: Text('Training session not found'),
              ),
            );
          }

          final session = snapshot.data!;
          final isOrganizer = _currentUserId == session.createdBy;
          final isParticipant = session.isParticipant(_currentUserId ?? '');
          final showFeedbackTab = session.status == TrainingStatus.completed && isParticipant;
          final tabCount = showFeedbackTab ? 3 : 2;
          final canCancel = session.canUserCancel(_currentUserId ?? '');

          return Scaffold(
            appBar: AppBar(
              title: Text(session.title),
              actions: [
                // Cancel button only visible to organizer for scheduled sessions
                if (canCancel)
                  BlocConsumer<TrainingSessionParticipationBloc,
                      TrainingSessionParticipationState>(
                    listener: (context, state) {
                      if (state is CancelledSession) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Training session cancelled'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        // Navigate back after cancellation
                        Navigator.of(context).pop();
                      }
                    },
                    builder: (context, state) {
                      final isCancelling = state is CancellingSession;
                      return PopupMenuButton<String>(
                        enabled: !isCancelling,
                        icon: isCancelling
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'cancel') {
                            _showCancelConfirmation(context, session);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: 'cancel',
                            child: Row(
                              children: [
                                Icon(Icons.cancel, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Cancel Session',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
            body: DefaultTabController(
              length: tabCount,
              child: Column(
                children: [
                  // Session info header
                  _buildSessionHeader(context, session, isOrganizer),

                  // Tabs
                  TabBar(
                    tabs: [
                      const Tab(text: 'Participants', icon: Icon(Icons.people)),
                      const Tab(text: 'Exercises', icon: Icon(Icons.fitness_center)),
                      if (showFeedbackTab)
                        const Tab(text: 'Feedback', icon: Icon(Icons.feedback_outlined)),
                    ],
                  ),

                  // Tab views
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Participants tab
                        _buildParticipantsTab(session, isOrganizer),

                        // Exercises tab
                        BlocProvider(
                          create: (context) => sl<ExerciseBloc>(),
                          child: ExerciseListWidget(
                            trainingSessionId: widget.trainingSessionId,
                          ),
                        ),

                        // Feedback tab (only for completed sessions where user participated)
                        if (showFeedbackTab)
                          BlocProvider(
                            create: (context) => sl<TrainingFeedbackBloc>(),
                            child: FeedbackDisplayWidget(
                              trainingSessionId: widget.trainingSessionId,
                              sessionTitle: session.title,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Join/Leave floating action button
            floatingActionButton: _buildActionButton(context, session, isParticipant),
          );
        },
      ),
    );
  }

  Widget _buildSessionHeader(
    BuildContext context,
    TrainingSessionModel session,
    bool isOrganizer,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and status badge
          Row(
            children: [
              Expanded(
                child: Text(
                  session.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _buildStatusBadge(session.status),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          if (session.description != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                session.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

          // Organizer info
          FutureBuilder<UserModel?>(
            future: sl<UserRepository>().getUserById(session.createdBy),
            builder: (context, userSnapshot) {
              final organizer = userSnapshot.data;
              return Row(
                children: [
                  Icon(
                    isOrganizer ? Icons.star : Icons.person_outline,
                    size: 16,
                    color: isOrganizer ? Colors.amber : null,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOrganizer
                        ? 'You are organizing'
                        : 'Organized by ${organizer?.displayName ?? "Loading..."}',
                    style: TextStyle(
                      fontWeight: isOrganizer ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 8),

          // Date/Time
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM dd, yyyy • HH:mm').format(session.startTime),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Location
          Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  session.location.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Participant count
          Row(
            children: [
              const Icon(Icons.people, size: 16),
              const SizedBox(width: 4),
              Text(
                '${session.participantIds.length}/${session.maxParticipants} participants',
              ),
              if (session.isFull) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red),
                  ),
                  child: const Text(
                    'FULL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Notes (if available)
          if (session.notes != null && session.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withAlpha(77)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      session.notes!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TrainingStatus status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case TrainingStatus.scheduled:
        color = Colors.blue;
        icon = Icons.schedule;
        label = 'Scheduled';
        break;
      case TrainingStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'Completed';
        break;
      case TrainingStatus.cancelled:
        color = Colors.red;
        icon = Icons.cancel;
        label = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsTab(TrainingSessionModel session, bool isOrganizer) {
    if (session.participantIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No participants yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Be the first to join!',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Show participation info even when empty
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _buildParticipationInfoCard(session),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<UserModel>>(
      future: sl<UserRepository>().getUsersByIds(session.participantIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading participants'),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        }

        final participants = snapshot.data ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: participants.length + 1, // +1 for participation info card
          itemBuilder: (context, index) {
            // First item is the participation info card
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildParticipationInfoCard(session),
              );
            }

            // Adjust index for participant list
            final participantIndex = index - 1;
            final participant = participants[participantIndex];
            final isOrg = participant.uid == session.createdBy;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: participant.photoUrl != null
                      ? NetworkImage(participant.photoUrl!)
                      : null,
                  child: participant.photoUrl == null
                      ? Text(participant.displayNameOrEmail[0].toUpperCase())
                      : null,
                ),
                title: Row(
                  children: [
                    Text(participant.displayNameOrEmail),
                    if (isOrg) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                    ],
                  ],
                ),
                subtitle: isOrg
                    ? const Text(
                        'Organizer',
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
                trailing: participant.uid == _currentUserId
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : null,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildParticipationInfoCard(TrainingSessionModel session) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Participation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            _buildParticipationRow('Current', '${session.participantIds.length}'),
            _buildParticipationRow('Minimum', '${session.minParticipants}'),
            _buildParticipationRow('Maximum', '${session.maxParticipants}'),
            _buildParticipationRow('Available Spots', '${session.availableSpots}'),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget? _buildActionButton(
    BuildContext context,
    TrainingSessionModel session,
    bool isParticipant,
  ) {
    // No action button for cancelled sessions
    if (session.status == TrainingStatus.cancelled) {
      return null;
    }

    // No action button for completed sessions
    if (session.status == TrainingStatus.completed) {
      return null;
    }

    // No action button for past sessions
    if (session.isPast) {
      return null;
    }

    return BlocConsumer<TrainingSessionParticipationBloc,
        TrainingSessionParticipationState>(
      listener: (context, state) {
        if (state is JoinedSession) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully joined training session!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is LeftSession) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have left the training session'),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (state is ParticipationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading =
            state is JoiningSession || state is LeavingSession;

        if (isParticipant) {
          // Show Leave button
          return FloatingActionButton.extended(
            onPressed: isLoading
                ? null
                : () => _leaveSession(context, session),
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.exit_to_app),
            label: Text(isLoading ? 'Leaving...' : 'Leave'),
            backgroundColor: Colors.orange,
          );
        } else {
          // Show Join button
          final canJoin = session.canUserJoin(_currentUserId ?? '');

          return FloatingActionButton.extended(
            onPressed: (!canJoin || isLoading)
                ? null
                : () => _joinSession(context, session),
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add),
            label: Text(
              isLoading
                  ? 'Joining...'
                  : canJoin
                      ? 'Join'
                      : session.isFull
                          ? 'Full'
                          : 'Cannot Join',
            ),
            backgroundColor: canJoin ? Colors.green : Colors.grey,
          );
        }
      },
    );
  }

  void _joinSession(BuildContext context, TrainingSessionModel session) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Join Training Session'),
        content: Text(
          'Do you want to join "${session.title}"?\n\n'
          'Date: ${DateFormat('MMM dd, yyyy • HH:mm').format(session.startTime)}\n'
          'Location: ${session.location.name}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TrainingSessionParticipationBloc>().add(
                    JoinTrainingSession(widget.trainingSessionId),
                  );
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  void _leaveSession(BuildContext context, TrainingSessionModel session) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave Training Session'),
        content: Text(
          'Are you sure you want to leave "${session.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TrainingSessionParticipationBloc>().add(
                    LeaveTrainingSession(widget.trainingSessionId),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog before cancelling a training session (Story 15.14)
  void _showCancelConfirmation(
      BuildContext context, TrainingSessionModel session) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Training Session?'),
        content: Text(
          'Are you sure you want to cancel "${session.title}"?\n\n'
          'All participants will be notified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep Session'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<TrainingSessionParticipationBloc>().add(
                    CancelTrainingSession(widget.trainingSessionId),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cancel Session'),
          ),
        ],
      ),
    );
  }
}
