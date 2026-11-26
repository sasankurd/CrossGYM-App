import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../nutrition/calorie_summary.dart';
import '../watch/heart_widgets.dart';
import '../records/records_section.dart';
import 'recovery_map.dart';
import 'coach_sheet.dart';
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
      padding: EdgeInsets.fromLTRB(16, contentTop(context), 16, 24),
      children: [
        TabHeader(
          kicker: 'CROSSGYM OS',
          title: 'Command hub',
          trailing: [
            const WatchButton(),
            IconButton.filled(
              onPressed: () => showCoachSheet(context),
              tooltip: 'Coach',
              icon: const Icon(Icons.auto_awesome, size: 18),
            ),
          ],
        ),
        NeoCard(
          accent: true,
          child: Row(
            children: [
              ReadinessRing(
                value: readiness,
                color: scheme.primary,
                caption: 'READY',
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      readiness >= 0.8
                          ? 'Ready to push'
                          : readiness >= 0.6
                              ? 'Train smart today'
                              : 'Go easy or recover',
                      style: text.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Estimated from the sessions you log. Not a medical '
                      'measurement.',
                      style: text.bodySmall?.copyWith(
                        color: AppColors.gray300,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const LiveHeartCard(),
        const SizedBox(height: 16),
        const SectionLabel('Quick launch session'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _LaunchTile(
                type: WorkoutType.gym,
                title: 'Gym strength',
                done: state.workoutsOf(WorkoutType.gym),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LaunchTile(
                type: WorkoutType.running,
                title: 'Run',
                done: state.workoutsOf(WorkoutType.running),
              ),
            ),
          ],
        ),
        if (state.profile != null) ...[
          const SizedBox(height: 16),
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
        const SectionLabel('Recovery map'),
        const SizedBox(height: 10),
        const RecoveryMap(),
        const SizedBox(height: 20),
        const RecordsSection(),
        const SizedBox(height: 20),
        const SectionLabel('More sessions'),
        const SizedBox(height: 10),
        for (final type in const [
          WorkoutType.crossfit,
          WorkoutType.pilates,
          WorkoutType.recovery,
        ]) ...[
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

/// Large tile that opens a workout type, in the CrossGym OS launcher style.
class _LaunchTile extends StatelessWidget {
  const _LaunchTile({
    required this.type,
    required this.title,
    required this.done,
  });

  final WorkoutType type;
  final String title;
  final int done;

  @override
  Widget build(BuildContext context) {
    final color = typeColor(context, type);
    return Material(
      color: AppColors.container,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: color.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
              builder: (_) => WorkoutTypeScreen(type: type)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(type.icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                '$done logged',
                style: const TextStyle(fontSize: 12, color: AppColors.gray300),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
