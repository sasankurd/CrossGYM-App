import 'package:flutter/material.dart';

import '../../core/exercise_art.dart';
import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import 'exercise_picker.dart';
import 'program_picker.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  static const _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  int _day = DateTime.now().weekday - 1;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    final items = state.planFor(_day);

    return ListView(
      padding: EdgeInsets.fromLTRB(16, contentTop(context), 16, 120),
      children: [
        Text('Plan', style: text.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Tap the star on an exercise to open and edit its sets.',
          style: text.bodySmall?.copyWith(color: AppColors.gray400),
        ),
        const SizedBox(height: 16),
        NeoCard(
          accent: true,
          radius: 20,
          padding: const EdgeInsets.all(16),
          onTap: () => showProgramPicker(context),
          child: Row(
            children: [
              Icon(Icons.layers_outlined,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Active program'),
                    const SizedBox(height: 2),
                    Text(
                      state.activeProgram.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    Text(
                      '${state.activeProgram.exerciseCount} exercises - '
                      '${state.activeProgram.trainingDays} days',
                      style: mono(
                        size: 11,
                        weight: FontWeight.w500,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
              const Pill('CHANGE', icon: Icons.swap_horiz),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 6 ? 6 : 0),
                  child: _DayChip(
                    label: _days[i],
                    count: state.planFor(i).length,
                    selected: i == _day,
                    onTap: () => setState(() => _day = i),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => showExercisePicker(
                  context,
                  onPick: (e) => state.addToPlan(_day, e),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add exercise'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.emerald,
                  side: BorderSide(
                    color: items.isEmpty
                        ? AppColors.hairline
                        : AppColors.emerald.withValues(alpha: 0.5),
                  ),
                ),
                onPressed: items.isEmpty
                    ? null
                    : () {
                        final type = state.completeDay(_day);
                        if (type != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${type.label} session logged'),
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.check),
                label: const Text('Complete'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          NeoCard(
            radius: 20,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.event_available, color: AppColors.gray400),
                const SizedBox(height: 8),
                Text(
                  'Nothing planned for ${_days[_day]}',
                  style: text.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Add an exercise to start building this day.',
                  style: text.bodySmall?.copyWith(color: AppColors.gray400),
                ),
              ],
            ),
          )
        else
          for (final p in items) ...[
            _PlannedCard(day: _day, planned: p),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.14) : AppColors.glassFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? primary : AppColors.hairline),
          boxShadow: selected
              ? [BoxShadow(color: primary.withValues(alpha: 0.35), blurRadius: 12)]
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: mono(
                size: 10,
                color: selected ? primary : AppColors.gray300,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: mono(
                size: 14,
                weight: FontWeight.w700,
                color: count == 0 ? AppColors.gray400 : AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannedCard extends StatelessWidget {
  const _PlannedCard({required this.day, required this.planned});

  final int day;
  final PlannedExercise planned;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    final e = planned.exercise;
    return NeoCard(
      padding: const EdgeInsets.all(12),
      selected: planned.open,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.hairline),
                ),
                child: Center(child: ExerciseArt(slug: e.slug, size: 46)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.name, style: text.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${e.type.label} - ${planned.sets.length} sets',
                      style: mono(
                        size: 11,
                        weight: FontWeight.w500,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: planned.open ? 'Hide sets' : 'Show sets',
                onPressed: () => state.toggleOpen(planned),
                icon: Icon(
                  planned.open ? Icons.star : Icons.star_border,
                  color: AppColors.amber,
                ),
              ),
              IconButton(
                tooltip: 'Remove',
                onPressed: () => state.removeFromPlan(day, planned),
                icon: const Icon(Icons.delete_outline, color: AppColors.rose),
              ),
            ],
          ),
          if (planned.open) ...[
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 6),
            for (var i = 0; i < planned.sets.length; i++)
              _SetRow(planned: planned, index: i),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => state.addSet(planned),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add set'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.planned, required this.index});

  final PlannedExercise planned;
  final int index;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final set = planned.sets[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 26,
            child: Text(
              '${index + 1}',
              style: mono(size: 12, color: AppColors.gray400),
            ),
          ),
          Expanded(
            child: _Stepper(
              unit: 'REPS',
              value: '${set.reps}',
              onMinus: () => state.adjustReps(set, -1),
              onPlus: () => state.adjustReps(set, 1),
            ),
          ),
          Expanded(
            child: _Stepper(
              unit: 'KG',
              value: set.kg == set.kg.roundToDouble()
                  ? set.kg.toStringAsFixed(0)
                  : set.kg.toStringAsFixed(1),
              onMinus: () => state.adjustKg(set, -2.5),
              onPlus: () => state.adjustKg(set, 2.5),
            ),
          ),
          IconButton(
            tooltip: 'Remove set',
            visualDensity: VisualDensity.compact,
            onPressed: planned.sets.length > 1
                ? () => state.removeSet(planned, index)
                : null,
            icon: const Icon(Icons.close, size: 16, color: AppColors.gray400),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.unit,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String unit;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, VoidCallback onTap) => InkResponse(
          onTap: onTap,
          radius: 16,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(icon, size: 16, color: AppColors.gray300),
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        button(Icons.remove, onMinus),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: mono(size: 15, weight: FontWeight.w700)),
            Text(
              unit,
              style: mono(
                size: 8,
                weight: FontWeight.w500,
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
        button(Icons.add, onPlus),
      ],
    );
  }
}
