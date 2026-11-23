import 'package:flutter/material.dart';

import '../../core/exercise_art.dart';
import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final state = AppScope.of(context);
    final color = typeColor(context, exercise.type);
    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NeoCard(
            accent: true,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ExerciseArt(slug: exercise.slug, size: 280, animate: true),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Pill(exercise.type.label, color: color, icon: exercise.type.icon),
              const SizedBox(width: 8),
              Pill(exercise.sub),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'The drawing shows the movement between its start and end '
            'positions. Instructions are coming.',
            style: text.bodyMedium?.copyWith(color: AppColors.gray300),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              state.addToPlan(DateTime.now().weekday - 1, exercise);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Added to today's plan")),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text("Add to today's plan"),
          ),
          const SizedBox(height: 24),
          Text(
            'Illustrations: Workout Guide and Everkinetic via GymMane, '
            'CC BY-SA 4.0.',
            style: text.bodySmall?.copyWith(color: AppColors.gray400),
          ),
        ],
      ),
    );
  }
}
