/// A simple estimate of how rested each muscle group is, from the workouts
/// logged. It is a rule of thumb, not a measurement: the app knows the type,
/// distance and time of a session, not which exercises you did.
library;

import 'models.dart';

enum Muscle {
  chest('Chest'),
  shoulders('Shoulders'),
  arms('Arms'),
  core('Core'),
  back('Back'),
  glutes('Glutes'),
  quads('Quads'),
  hamstrings('Hamstrings'),
  calves('Calves');

  const Muscle(this.label);
  final String label;
}

/// How hard each kind of session works each muscle (0 to 1).
const Map<WorkoutType, Map<Muscle, double>> _load = {
  WorkoutType.running: {
    Muscle.quads: 0.6,
    Muscle.hamstrings: 0.5,
    Muscle.calves: 0.7,
    Muscle.glutes: 0.4,
    Muscle.core: 0.15,
  },
  WorkoutType.gym: {
    Muscle.chest: 0.5,
    Muscle.back: 0.5,
    Muscle.shoulders: 0.45,
    Muscle.arms: 0.45,
    Muscle.quads: 0.45,
    Muscle.hamstrings: 0.4,
    Muscle.glutes: 0.4,
    Muscle.core: 0.25,
    Muscle.calves: 0.15,
  },
  WorkoutType.crossfit: {
    Muscle.chest: 0.5,
    Muscle.back: 0.6,
    Muscle.shoulders: 0.65,
    Muscle.arms: 0.5,
    Muscle.core: 0.6,
    Muscle.glutes: 0.55,
    Muscle.quads: 0.6,
    Muscle.hamstrings: 0.5,
    Muscle.calves: 0.35,
  },
  WorkoutType.pilates: {
    Muscle.core: 0.5,
    Muscle.glutes: 0.4,
    Muscle.back: 0.15,
    Muscle.hamstrings: 0.15,
  },
};

/// Hours until a session of this type has fully worn off.
const Map<WorkoutType, int> _hoursToRecover = {
  WorkoutType.running: 36,
  WorkoutType.gym: 60,
  WorkoutType.crossfit: 72,
  WorkoutType.pilates: 36,
};

/// 1.0 means fully rested, 0.0 means very tired, for every muscle group.
Map<Muscle, double> muscleRecovery(List<WorkoutLog> logs, DateTime now) {
  final fatigue = {for (final m in Muscle.values) m: 0.0};
  for (final log in logs) {
    final window = _hoursToRecover[log.type];
    final load = _load[log.type];
    if (window == null || load == null) continue; // recovery sessions: no load
    final hours = now.difference(log.at).inMinutes / 60;
    if (hours < 0 || hours >= window) continue;
    var scale = 1.0;
    final d = log.distanceM;
    if (log.type == WorkoutType.running && d != null) {
      scale = (0.6 + d / 10000).clamp(0.6, 1.5);
    }
    final left = 1 - hours / window;
    load.forEach((m, v) => fatigue[m] = fatigue[m]! + v * left * scale);
  }
  return {for (final m in Muscle.values) m: (1 - fatigue[m]!).clamp(0.0, 1.0)};
}

enum RecoveryState {
  fresh('Fresh'),
  recovering('Recovering'),
  tired('Tired');

  const RecoveryState(this.label);
  final String label;

  static RecoveryState of(double recovery) => recovery >= 0.85
      ? fresh
      : recovery >= 0.5
          ? recovering
          : tired;
}
