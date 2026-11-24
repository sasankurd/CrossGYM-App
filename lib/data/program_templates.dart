import 'models.dart';

/// A ready-made weekly program. [days] maps a weekday (0 = Monday) to the
/// exercise slugs for that day. Every slug must exist in the exercise catalog.
class ProgramTemplate {
  const ProgramTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.days,
  });

  final String id;
  final String name;
  final String description;
  final WorkoutType type;
  final Map<int, List<String>> days;
}

const List<ProgramTemplate> kProgramTemplates = [
  ProgramTemplate(
    id: 't-ppl',
    name: 'Push Pull Legs',
    description: 'Gym split: push, pull and legs, repeated twice a week.',
    type: WorkoutType.gym,
    days: {
      0: ['bench-press', 'rope-tricep-pushdown'],
      1: ['pull-up', 'barbell-row', 'hammer-curl'],
      2: ['squat', 'romanian-deadlift', 'goblet-squat'],
      4: ['bench-press', 'rope-tricep-pushdown'],
      5: ['deadlift', 'pull-up', 'hammer-curl'],
      6: ['front-squat', 'romanian-deadlift'],
    },
  ),
  ProgramTemplate(
    id: 't-run',
    name: 'Run Base',
    description: 'Three runs a week with cardio drills and an easy walk.',
    type: WorkoutType.running,
    days: {
      0: ['running', 'high-knees'],
      2: ['running', 'jump-rope'],
      4: ['running'],
      5: ['walking', 'cycling'],
    },
  ),
  ProgramTemplate(
    id: 't-cf',
    name: 'CrossFit Week',
    description: 'Three mixed sessions: metcon, lifting and gymnastics.',
    type: WorkoutType.crossfit,
    days: {
      0: ['burpee', 'kettlebell-swing', 'rowing'],
      2: ['wall-walk', 'overhead-squat', 'mountain-climber'],
      4: ['battle-ropes', 'pistol-squat', 'handstand-push-up'],
    },
  ),
  ProgramTemplate(
    id: 't-pil',
    name: 'Pilates Core',
    description: 'Core and glute sessions three times a week.',
    type: WorkoutType.pilates,
    days: {
      0: ['plank', 'dead-bug', 'bird-dog'],
      2: ['glute-bridge', 'clamshell', 'side-plank'],
      4: ['bicycle-crunch', 'reverse-crunch', 'single-leg-glute-bridge'],
    },
  ),
  ProgramTemplate(
    id: 't-rec',
    name: 'Recovery Week',
    description: 'Short daily mobility and stretching.',
    type: WorkoutType.recovery,
    days: {
      0: ['cat-cow-stretch', 'hamstring-stretch'],
      1: ['childs-pose', 'standing-quad-stretch'],
      2: ['worlds-greatest-stretch', 'kneeling-hip-flexor-stretch'],
      3: ['doorway-chest-stretch', 'cross-body-shoulder-stretch'],
      4: ['butterfly-stretch', 'wall-calf-stretch'],
      5: ['seated-forward-fold-stretch', 'childs-pose'],
    },
  ),
];

/// First template for a workout type, used to turn a store plan into a program.
ProgramTemplate templateForType(WorkoutType type) =>
    kProgramTemplates.firstWhere((t) => t.type == type);
