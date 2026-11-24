import 'package:flutter/material.dart';

import '../../core/shell_nav.dart';
import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/nutrition.dart';
import 'add_food_sheet.dart';
import 'nutrition_screen.dart';

/// Opens the Fuel tab, or the tracker as its own page when there is no shell.
void openFuel(BuildContext context) {
  final nav = ShellNav.maybeOf(context);
  if (nav != null) {
    nav.go(ShellNav.fuel);
  } else {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const NutritionScreen()),
    );
  }
}

/// Today's calories at a glance. Used on Home and at the top of the tracker.
class CalorieCard extends StatelessWidget {
  const CalorieCard({super.key, this.day, this.openable = true});

  /// The day to show. Defaults to today.
  final DateTime? day;

  /// Whether tapping opens the full tracker.
  final bool openable;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final profile = state.profile;
    if (profile == null) return const SizedBox.shrink();
    final date = day ?? DateTime.now();
    final target = profile.targetKcal;
    final eaten = state.caloriesOn(date);
    final left = target - eaten;
    final text = Theme.of(context).textTheme;
    final over = left < 0;
    final ringColor = over ? AppColors.amber : AppColors.emerald;

    return NeoCard(
      onTap: openable ? () => openFuel(context) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ReadinessRing(
                value: target == 0 ? 0 : (eaten / target).clamp(0.0, 1.0),
                color: ringColor,
                size: 96,
                label: formatInt(left.abs()),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Calories', style: text.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      over
                          ? '${formatInt(-left)} over your target'
                          : '${formatInt(left)} left today',
                      style: text.bodyMedium?.copyWith(color: ringColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatInt(eaten)} eaten of ${formatInt(target)}',
                      style: text.bodySmall
                          ?.copyWith(color: AppColors.gray400),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Goal: ${profile.goal.label.toLowerCase()}',
                      style: text.bodySmall
                          ?.copyWith(color: AppColors.gray400),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          MacroBars(date: date),
          if (openable) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => showAddFoodSheet(context, date),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Log food'),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(46)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Protein, carbs and fat eaten against their daily targets.
class MacroBars extends StatelessWidget {
  const MacroBars({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final p = state.profile!;
    return Row(
      children: [
        _Bar('Protein', state.proteinOn(date), p.proteinG, AppColors.rose),
        const SizedBox(width: 12),
        _Bar('Carbs', state.carbsOn(date), p.carbsG, AppColors.amber),
        const SizedBox(width: 12),
        _Bar('Fat', state.fatOn(date), p.fatG, AppColors.emerald),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar(this.label, this.eaten, this.target, this.color);

  final String label;
  final double eaten;
  final int target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final fraction = target == 0 ? 0.0 : (eaten / target).clamp(0.0, 1.0);
    return Expanded(
      child: Semantics(
        label: '$label ${eaten.round()} of $target grams',
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: text.bodySmall?.copyWith(color: AppColors.gray300)),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                color: color,
                backgroundColor: AppColors.hairlineStrong,
              ),
            ),
            const SizedBox(height: 4),
            Text('${eaten.round()} / $target g', style: mono(size: 11)),
          ],
        ),
      ),
    );
  }
}
