import 'package:flutter/material.dart';

import '../../core/exercise_art.dart';
import '../../data/models.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ExerciseArt(slug: exercise.slug, size: 280, animate: true),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Chip(
                avatar: Icon(exercise.type.icon, size: 18),
                label: Text(exercise.type.label),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Instructions and sets are coming. This screen shows the movement '
            'between its start and end positions.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(
            'Illustrations: Workout Guide and Everkinetic via GymMane, '
            'CC BY-SA 4.0.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
