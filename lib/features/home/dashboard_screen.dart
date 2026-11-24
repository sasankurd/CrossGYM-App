import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../nutrition/calorie_summary.dart';
import '../workouts/workout_type_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final readiness = state.readiness;
    final shield = state.shieldRemaining;
    final week = state.weekCounts;
    final maxCount = week.fold<int>(1, (m, c) => c > m ? c : m);
    final today = DateTime.now();

    return ListView(
      padding: EdgeInsets.fromLTRB(16, contentTop(context), 16, 120),
      children: [
        NeoCard(
          accent: true,
          child: Row(
            children: [
              ReadinessRing(value: readiness, color: AppColors.emerald),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('CNS readiness'),
                    const SizedBox(height: 4),
                    Text(
                      readiness >= 0.8
                          ? 'Ready to push'
                          : readiness >= 0.6
                              ? 'Train smart today'
                              : 'Go easy or recover',
                      style: text.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Estimated from the sessions you log. Not a medical '
                      'measurement.',
                      style: text.bodySmall?.copyWith(color: AppColors.gray400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (state.profile != null) ...[
          const SizedBox(height: 12),
          const CalorieCard(),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            _Metric(
              label: 'Sessions',
              value: '${state.totalWorkouts}',
              color: AppColors.text,
            ),
            const SizedBox(width: 10),
            _Metric(
              label: 'Streak',
              value: '${state.streakDays}',
              color: AppColors.orange,
            ),
            const SizedBox(width: 10),
            _Metric(
              label: 'XP',
              value: '${state.xp}',
              color: AppColors.amber,
            ),
          ],
        ),
        const SizedBox(height: 12),
        NeoCard(
          radius: 16,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Level ${state.level}', style: text.titleMedium),
                  const Spacer(),
                  Text(
                    '${(state.levelProgress * 250).round()}/250 XP',
                    style: mono(size: 11, color: AppColors.gray400),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: state.levelProgress,
                borderRadius: BorderRadius.circular(999),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        NeoCard(
          radius: 16,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, color: scheme.secondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('6h Recovery Shield', style: text.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      shield == null
                          ? 'No session in the last 6 hours'
                          : '${shield.inHours}h ${shield.inMinutes % 60}m left '
                              'after your last session',
                      style: mono(
                        size: 11,
                        weight: FontWeight.w500,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
              Pill(shield == null ? 'IDLE' : 'ACTIVE', color: scheme.secondary),
            ],
          ),
        ),
        const SizedBox(height: 12),
        NeoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Last 7 days'),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${week[i]}',
                              style: mono(
                                size: 10,
                                color: week[i] == 0
                                    ? AppColors.gray400
                                    : AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 18,
                              height: 6 + 58.0 * week[i] / maxCount,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: week[i] == 0
                                    ? null
                                    : LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          scheme.primary,
                                          scheme.secondary,
                                        ],
                                      ),
                                color: week[i] == 0 ? AppColors.hairline : null,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _dayLetters[today
                                  .subtract(Duration(days: 6 - i))
                                  .weekday -
                                  1],
                              style: mono(
                                size: 10,
                                weight: FontWeight.w500,
                                color: AppColors.gray400,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionLabel('Start a workout'),
        const SizedBox(height: 10),
        for (final type in WorkoutType.values) ...[
          _TypeTile(type: type, done: state.workoutsOf(type)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: NeoCard(
        radius: 16,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: mono(size: 24, weight: FontWeight.w700, color: color),
            ),
            const SizedBox(height: 2),
            SectionLabel(label),
          ],
        ),
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
    final color = typeColor(context, type);
    return NeoCard(
      radius: 20,
      padding: const EdgeInsets.all(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => WorkoutTypeScreen(type: type)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Icon(type.icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.label, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  '$done logged',
                  style: mono(
                    size: 11,
                    weight: FontWeight.w500,
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.gray400),
        ],
      ),
    );
  }
}
