import 'package:flutter/material.dart';

import '../../../../core/data/models/exercise_model.dart';

/// Widget displaying a single exercise item in a list
class ExerciseListItem extends StatelessWidget {
  final ExerciseModel exercise;
  final bool canModify;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExerciseListItem({
    super.key,
    required this.exercise,
    required this.canModify,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.fitness_center),
        ),
        title: Text(
          exercise.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exercise.description != null &&
                exercise.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                exercise.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (exercise.hasDuration) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.timer, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    exercise.formattedDuration,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: canModify
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit' && onEdit != null) {
                    onEdit!();
                  } else if (value == 'delete' && onDelete != null) {
                    onDelete!();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
