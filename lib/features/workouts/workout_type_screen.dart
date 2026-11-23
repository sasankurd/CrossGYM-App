import 'package:flutter/material.dart';

import '../../core/exercise_art.dart';
import '../../core/tokens.dart';
import '../../core/widgets.dart';
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
    final color = typeColor(context, type);
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
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final e = exercises[i];
          return NeoCard(
            radius: 20,
            padding: const EdgeInsets.all(10),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ExerciseDetailScreen(exercise: e),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.glassFill,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: Center(child: ExerciseArt(slug: e.slug, size: 50)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.name,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Pill(e.sub, color: color),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.gray400),
              ],
            ),
          );
        },
      ),
    );
  }
}
