import 'models.dart';

/// Every slug here must exist as `assets/art/<slug>.txt`
/// (checked by tool/check_assets.sh).
const List<Exercise> kExercises = [
  // Running and cardio
  Exercise('running', WorkoutType.running),
  Exercise('treadmill-incline-walk', WorkoutType.running),
  Exercise('walking', WorkoutType.running),
  Exercise('high-knees', WorkoutType.running),
  Exercise('jump-rope', WorkoutType.running),
  Exercise('cycling', WorkoutType.running),

  // Gym
  Exercise('bench-press', WorkoutType.gym),
  Exercise('squat', WorkoutType.gym),
  Exercise('deadlift', WorkoutType.gym),
  Exercise('pull-up', WorkoutType.gym),
  Exercise('romanian-deadlift', WorkoutType.gym),
  Exercise('goblet-squat', WorkoutType.gym),
  Exercise('barbell-row', WorkoutType.gym),
  Exercise('hammer-curl', WorkoutType.gym),
  Exercise('rope-tricep-pushdown', WorkoutType.gym),
  Exercise('front-squat', WorkoutType.gym),

  // CrossFit
  Exercise('burpee', WorkoutType.crossfit),
  Exercise('kettlebell-swing', WorkoutType.crossfit),
  Exercise('overhead-squat', WorkoutType.crossfit),
  Exercise('mountain-climber', WorkoutType.crossfit),
  Exercise('wall-walk', WorkoutType.crossfit),
  Exercise('battle-ropes', WorkoutType.crossfit),
  Exercise('handstand-push-up', WorkoutType.crossfit),
  Exercise('rowing', WorkoutType.crossfit),
  Exercise('pistol-squat', WorkoutType.crossfit),

  // Pilates and core
  Exercise('plank', WorkoutType.pilates),
  Exercise('dead-bug', WorkoutType.pilates),
  Exercise('bird-dog', WorkoutType.pilates),
  Exercise('glute-bridge', WorkoutType.pilates),
  Exercise('side-plank', WorkoutType.pilates),
  Exercise('bicycle-crunch', WorkoutType.pilates),
  Exercise('clamshell', WorkoutType.pilates),
  Exercise('reverse-crunch', WorkoutType.pilates),
  Exercise('single-leg-glute-bridge', WorkoutType.pilates),

  // Recovery and mobility
  Exercise('childs-pose', WorkoutType.recovery),
  Exercise('cat-cow-stretch', WorkoutType.recovery),
  Exercise('hamstring-stretch', WorkoutType.recovery),
  Exercise('kneeling-hip-flexor-stretch', WorkoutType.recovery),
  Exercise('worlds-greatest-stretch', WorkoutType.recovery),
  Exercise('standing-quad-stretch', WorkoutType.recovery),
  Exercise('wall-calf-stretch', WorkoutType.recovery),
  Exercise('seated-forward-fold-stretch', WorkoutType.recovery),
  Exercise('cross-body-shoulder-stretch', WorkoutType.recovery),
  Exercise('doorway-chest-stretch', WorkoutType.recovery),
  Exercise('butterfly-stretch', WorkoutType.recovery),
];

List<Exercise> exercisesFor(WorkoutType type) =>
    kExercises.where((e) => e.type == type).toList();
