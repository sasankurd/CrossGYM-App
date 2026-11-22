import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';
import 'about_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final theme = Theme.of(context);
    final achievements = state.achievements;
    final unlocked = achievements.where((a) => a.unlocked).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About and credits',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 36,
                child: Icon(Icons.person, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.me.name, style: theme.textTheme.titleLarge),
                    Text('@${state.me.handle}'),
                    Text('Level ${state.level}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Count(label: 'Followers', value: state.me.followers),
              _Count(label: 'Following', value: state.followingCount),
              _Count(label: 'Workouts', value: state.totalWorkouts),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Achievements ($unlocked/${achievements.length})',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final a in achievements) _AchievementTile(achievement: a),
          const SizedBox(height: 16),
          Text('Your plans', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (state.myPlans.isEmpty)
            const Text('You have not published a plan yet. Open the Store tab.')
          else
            for (final p in state.myPlans)
              Card(
                child: ListTile(
                  leading: Icon(p.type.icon),
                  title: Text(p.title),
                  trailing: Text(p.priceLabel),
                ),
              ),
        ],
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: Theme.of(context).textTheme.titleLarge),
          Text(label),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final a = achievement;
    return Card(
      child: ListTile(
        leading: Icon(
          a.icon,
          color: a.unlocked ? scheme.primary : scheme.outline,
        ),
        title: Text(a.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a.description),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: a.fraction),
          ],
        ),
        trailing: a.unlocked
            ? Icon(Icons.check_circle, color: scheme.primary)
            : Text('${a.progress.clamp(0, a.goal)}/${a.goal}'),
      ),
    );
  }
}
