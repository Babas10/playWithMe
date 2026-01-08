import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/models/exercise_model.dart';
import '../bloc/exercise/exercise_bloc.dart';
import '../bloc/exercise/exercise_event.dart';
import '../bloc/exercise/exercise_state.dart';
import 'exercise_form_dialog.dart';
import 'exercise_list_item.dart';

/// Widget displaying the list of exercises for a training session
class ExerciseListWidget extends StatefulWidget {
  final String trainingSessionId;

  const ExerciseListWidget({
    super.key,
    required this.trainingSessionId,
  });

  @override
  State<ExerciseListWidget> createState() => _ExerciseListWidgetState();
}

class _ExerciseListWidgetState extends State<ExerciseListWidget> {
  @override
  void initState() {
    super.initState();
    // Load exercises when widget is created
    context.read<ExerciseBloc>().add(
          LoadExercises(trainingSessionId: widget.trainingSessionId),
        );
  }

  Future<void> _showAddExerciseDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const ExerciseFormDialog(),
    );

    if (result != null && mounted) {
      context.read<ExerciseBloc>().add(
            AddExercise(
              trainingSessionId: widget.trainingSessionId,
              name: result['name'] as String,
              description: result['description'] as String?,
              durationMinutes: result['durationMinutes'] as int?,
            ),
          );
    }
  }

  Future<void> _showEditExerciseDialog(ExerciseModel exercise) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ExerciseFormDialog(exercise: exercise),
    );

    if (result != null && mounted) {
      context.read<ExerciseBloc>().add(
            UpdateExercise(
              trainingSessionId: widget.trainingSessionId,
              exerciseId: exercise.id,
              name: result['name'] as String?,
              description: result['description'] as String?,
              durationMinutes: result['durationMinutes'] as int?,
            ),
          );
    }
  }

  Future<void> _confirmDelete(ExerciseModel exercise) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: Text(
          'Are you sure you want to delete "${exercise.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<ExerciseBloc>().add(
            DeleteExercise(
              trainingSessionId: widget.trainingSessionId,
              exerciseId: exercise.id,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExerciseBloc, ExerciseState>(
      listener: (context, state) {
        if (state is ExerciseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ExercisesLocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (state is ExerciseAdded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exercise added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ExerciseUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exercise updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ExerciseDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exercise deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ExercisesLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ExercisesLoaded) {
          return Column(
            children: [
              // Header with add button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Exercises (${state.exercises.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (state.canModify)
                      ElevatedButton.icon(
                        onPressed: _showAddExerciseDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Exercise'),
                      ),
                  ],
                ),
              ),

              // Exercise list or empty state
              if (state.exercises.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No exercises yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (state.canModify)
                          const Text(
                            'Tap "Add Exercise" to get started',
                            style: TextStyle(color: Colors.grey),
                          )
                        else
                          const Text(
                            'Cannot add exercises after session starts',
                            style: TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: state.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = state.exercises[index];
                      return ExerciseListItem(
                        exercise: exercise,
                        canModify: state.canModify,
                        onEdit: () => _showEditExerciseDialog(exercise),
                        onDelete: () => _confirmDelete(exercise),
                      );
                    },
                  ),
                ),

              // Lock message
              if (!state.canModify)
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.orange[100],
                  child: Row(
                    children: [
                      const Icon(Icons.lock, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Exercises cannot be modified after session starts',
                          style: TextStyle(
                            color: Colors.orange[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }

        // Initial or error state
        return const Center(
          child: Text('Unable to load exercises'),
        );
      },
    );
  }
}
