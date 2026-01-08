import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/data/models/training_session_model.dart';
import '../../../../core/domain/repositories/training_session_repository.dart';
import '../../../../core/services/service_locator.dart';
import '../bloc/exercise/exercise_bloc.dart';
import '../widgets/exercise_list_widget.dart';

/// Training session details page with exercise management
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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TrainingSessionModel?>(
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

        return Scaffold(
          appBar: AppBar(
            title: Text(session.title),
          ),
          body: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                // Session info header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      if (session.description != null)
                        Text(
                          session.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy • HH:mm')
                                .format(session.startTime),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
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
                      Row(
                        children: [
                          const Icon(Icons.people, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${session.participantIds.length}/${session.maxParticipants} participants',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tabs
                const TabBar(
                  tabs: [
                    Tab(text: 'Details', icon: Icon(Icons.info_outline)),
                    Tab(text: 'Exercises', icon: Icon(Icons.fitness_center)),
                  ],
                ),

                // Tab views
                Expanded(
                  child: TabBarView(
                    children: [
                      // Details tab
                      _buildDetailsTab(session),

                      // Exercises tab
                      BlocProvider(
                        create: (context) => sl<ExerciseBloc>(),
                        child: ExerciseListWidget(
                          trainingSessionId: widget.trainingSessionId,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsTab(TrainingSessionModel session) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailCard(
            'Schedule',
            Icons.schedule,
            [
              _buildDetailRow('Start', DateFormat('MMM dd, yyyy • HH:mm').format(session.startTime)),
              _buildDetailRow('End', DateFormat('MMM dd, yyyy • HH:mm').format(session.endTime)),
              _buildDetailRow('Duration', session.duration.inHours > 0
                  ? '${session.duration.inHours}h ${session.duration.inMinutes.remainder(60)}min'
                  : '${session.duration.inMinutes}min'),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            'Location',
            Icons.location_on,
            [
              _buildDetailRow('Name', session.location.name),
              if (session.location.address != null)
                _buildDetailRow('Address', session.location.address!),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            'Participants',
            Icons.people,
            [
              _buildDetailRow('Current', '${session.participantIds.length}'),
              _buildDetailRow('Minimum', '${session.minParticipants}'),
              _buildDetailRow('Maximum', '${session.maxParticipants}'),
              _buildDetailRow('Available Spots', '${session.availableSpots}'),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            'Status',
            Icons.info_outline,
            [
              _buildDetailRow('Status', session.status.toString().split('.').last),
              _buildDetailRow('Created', DateFormat('MMM dd, yyyy').format(session.createdAt)),
              if (session.updatedAt != null)
                _buildDetailRow('Updated', DateFormat('MMM dd, yyyy').format(session.updatedAt!)),
            ],
          ),
          if (session.notes != null && session.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailCard(
              'Notes',
              Icons.note,
              [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(session.notes!),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
