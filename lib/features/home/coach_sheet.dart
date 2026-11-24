import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../workouts/workout_type_screen.dart';

// ---- coach sheet -----------------------------------------------------------

/// Rule-based suggestion for the next session. Honest about not being AI.
void showCoachSheet(BuildContext context) {
  final state = AppScope.of(context);
  final readiness = state.readiness;
  final type =
      readiness < 0.6 ? WorkoutType.recovery : state.leastTrainedType;
  final reason = readiness < 0.6
      ? 'You trained a lot in the last two days, so recovery fits best.'
      : '${type.label} is the type you trained least in the last 7 days.';
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.sheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final scheme = Theme.of(sheetContext).colorScheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Suggested next session'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(type.icon, color: scheme.primary, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    type.label,
                    style: Theme.of(sheetContext).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(reason),
              const SizedBox(height: 8),
              Text(
                'This is a simple rule based on your logged sessions. It is '
                'not AI coaching yet.',
                style: Theme.of(sheetContext)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.gray400),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => WorkoutTypeScreen(type: type),
                      ),
                    );
                  },
                  child: Text('Open ${type.label}'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
