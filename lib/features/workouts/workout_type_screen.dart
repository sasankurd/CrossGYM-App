import 'package:flutter/material.dart';

import '../../core/exercise_art.dart';
import '../../data/app_state.dart';
import '../../data/exercise_catalog.dart';
import '../../data/models.dart';
import 'exercise_detail_screen.dart';

class WorkoutTypeScreen extends StatelessWidget {
  const WorkoutTypeScreen({super.key, required this.type});

  final WorkoutType type;

  @override
  Widget build(BuildContext context) {
    final exercises = exercisesFor(type);
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(type.label)),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.check),
        label: const Text('Log workout'),
        onPressed: () {
          state.logWorkout(type);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${type.label} workout logged')),
          );
        },
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: exercises.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final e = exercises[i];
          return Card(
            child: ListTile(
              leading: ExerciseArt(slug: e.slug, size: 56),
              title: Text(e.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ExerciseDetailScreen(exercise: e),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
