import 'models.dart';

/// Every slug here must exist as `assets/art/<slug>.txt`
/// (checked by tool/check_assets.sh).
const List<Exercise> kExercises = [
  // Running and cardio
  Exercise('running', WorkoutType.running, 'Run and walk'),
  Exercise('walking', WorkoutType.running, 'Run and walk'),
  Exercise('treadmill-incline-walk', WorkoutType.running, 'Run and walk'),
  Exercise('cycling', WorkoutType.running, 'Cardio'),
  Exercise('jump-rope', WorkoutType.running, 'Cardio'),
  Exercise('high-knees', WorkoutType.running, 'Cardio'),

  // Gym
  Exercise('squat', WorkoutType.gym, 'Legs'),
  Exercise('goblet-squat', WorkoutType.gym, 'Legs'),
  Exercise('front-squat', WorkoutType.gym, 'Legs'),
  Exercise('romanian-deadlift', WorkoutType.gym, 'Legs'),
  Exercise('bench-press', WorkoutType.gym, 'Chest'),
  Exercise('deadlift', WorkoutType.gym, 'Back'),
  Exercise('pull-up', WorkoutType.gym, 'Back'),
  Exercise('barbell-row', WorkoutType.gym, 'Back'),
  Exercise('hammer-curl', WorkoutType.gym, 'Arms'),
  Exercise('rope-tricep-pushdown', WorkoutType.gym, 'Arms'),

  // CrossFit
  Exercise('burpee', WorkoutType.crossfit, 'Metcon'),
  Exercise('mountain-climber', WorkoutType.crossfit, 'Metcon'),
  Exercise('battle-ropes', WorkoutType.crossfit, 'Metcon'),
  Exercise('rowing', WorkoutType.crossfit, 'Metcon'),
  Exercise('kettlebell-swing', WorkoutType.crossfit, 'Weightlifting'),
  Exercise('overhead-squat', WorkoutType.crossfit, 'Weightlifting'),
  Exercise('wall-walk', WorkoutType.crossfit, 'Gymnastics'),
  Exercise('handstand-push-up', WorkoutType.crossfit, 'Gymnastics'),
  Exercise('pistol-squat', WorkoutType.crossfit, 'Gymnastics'),

  // Pilates
  Exercise('plank', WorkoutType.pilates, 'Core'),
  Exercise('side-plank', WorkoutType.pilates, 'Core'),
  Exercise('dead-bug', WorkoutType.pilates, 'Core'),
  Exercise('bird-dog', WorkoutType.pilates, 'Core'),
  Exercise('bicycle-crunch', WorkoutType.pilates, 'Core'),
  Exercise('reverse-crunch', WorkoutType.pilates, 'Core'),
  Exercise('glute-bridge', WorkoutType.pilates, 'Glutes'),
  Exercise('single-leg-glute-bridge', WorkoutType.pilates, 'Glutes'),
  Exercise('clamshell', WorkoutType.pilates, 'Glutes'),

  // Recovery and mobility
  Exercise('hamstring-stretch', WorkoutType.recovery, 'Lower body'),
  Exercise('kneeling-hip-flexor-stretch', WorkoutType.recovery, 'Lower body'),
  Exercise('standing-quad-stretch', WorkoutType.recovery, 'Lower body'),
  Exercise('wall-calf-stretch', WorkoutType.recovery, 'Lower body'),
  Exercise('butterfly-stretch', WorkoutType.recovery, 'Lower body'),
  Exercise('seated-forward-fold-stretch', WorkoutType.recovery, 'Lower body'),
  Exercise('childs-pose', WorkoutType.recovery, 'Upper body and spine'),
  Exercise('cat-cow-stretch', WorkoutType.recovery, 'Upper body and spine'),
  Exercise('cross-body-shoulder-stretch', WorkoutType.recovery,
      'Upper body and spine'),
  Exercise('doorway-chest-stretch', WorkoutType.recovery,
      'Upper body and spine'),
  Exercise('worlds-greatest-stretch', WorkoutType.recovery, 'Full body'),
];

List<Exercise> exercisesFor(WorkoutType type) =>
    kExercises.where((e) => e.type == type).toList();

List<String> subCategoriesFor(WorkoutType type) {
  final subs = <String>[];
  for (final e in kExercises) {
    if (e.type == type && !subs.contains(e.sub)) subs.add(e.sub);
  }
  return subs;
}

Exercise? exerciseBySlug(String slug) {
  for (final e in kExercises) {
    if (e.slug == slug) return e;
  }
  return null;
}
