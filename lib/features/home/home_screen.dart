import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import '../workouts/workout_type_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('CrossGYM')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Level ${state.level}',
                      style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: state.levelProgress),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Stat(label: 'Workouts', value: '${state.totalWorkouts}'),
                      _Stat(label: 'Streak', value: '${state.streakDays}'),
                      _Stat(label: 'XP', value: '${state.xp}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Choose a workout', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final type in WorkoutType.values) ...[
            _TypeTile(type: type, done: state.workoutsOf(type)),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value, style: theme.textTheme.headlineSmall),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({required this.type, required this.done});

  final WorkoutType type;
  final int done;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(type.icon, size: 32),
        title: Text(type.label),
        subtitle: Text('$done logged'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => WorkoutTypeScreen(type: type),
          ),
        ),
      ),
    );
  }
}
