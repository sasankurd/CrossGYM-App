import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/body_paths.dart';
import '../../data/recovery.dart';

const _fresh = Color(0xFF2DD4BF);

Color recoveryColor(double r) => switch (RecoveryState.of(r)) {
      RecoveryState.fresh => _fresh,
      RecoveryState.recovering => AppColors.amber,
      RecoveryState.tired => AppColors.coral,
    };

/// A body figure (front or back) with each muscle group colored by how rested
/// it is, plus a list of the muscles that need rest.
class RecoveryMap extends StatefulWidget {
  const RecoveryMap({super.key});

  @override
  State<RecoveryMap> createState() => _RecoveryMapState();
}

class _RecoveryMapState extends State<RecoveryMap> {
  int _side = 0; // 0 front, 1 back

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final rec = muscleRecovery(state.records, DateTime.now());
    final sorted = rec.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final tiredList = [
      for (final e in sorted)
        if (e.value < 0.85) e,
    ];
    final summary = tiredList.isEmpty
        ? 'All muscle groups are fresh.'
        : 'Needs rest: ${tiredList.take(3).map((e) => '${e.key.label} ${(e.value * 100).round()}%').join(', ')}.';

    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubTabs(
            labels: const ['Front', 'Back'],
            index: _side,
            onChanged: (i) => setState(() => _side = i),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label: 'Body diagram. $summary',
                child: SizedBox(
                  width: 150,
                  height: 264,
                  child: CustomPaint(painter: _BodyPainter(rec, _side == 1)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final e in sorted.take(6))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: recoveryColor(e.value),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(e.key.label,
                                  style: const TextStyle(fontSize: 13)),
                            ),
                            Text(
                              '${(e.value * 100).round()}%',
                              style: mono(size: 13),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                    const Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Pill('Fresh', color: _fresh),
                        Pill('Recovering', color: AppColors.amber),
                        Pill('Tired', color: AppColors.coral),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(summary, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          const Text(
            'An estimate from the workouts you logged and how long ago they '
            'were. It is not a medical measurement.',
            style: TextStyle(
                fontSize: 11, color: AppColors.gray400, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  _BodyPainter(this.rec, this.back);

  final Map<Muscle, double> rec;
  final bool back;

  /// Which drawn part belongs to which muscle group. Parts not listed here
  /// (head, neck, hands, feet, knees, ankles) are drawn plain.
  static const _front = <String, Muscle>{
    'chest': Muscle.chest,
    'deltoids': Muscle.shoulders,
    'biceps': Muscle.arms,
    'triceps': Muscle.arms,
    'forearm': Muscle.arms,
    'abs': Muscle.core,
    'obliques': Muscle.core,
    'serratus': Muscle.core,
    'hip-flexors': Muscle.core,
    'trapezius': Muscle.back,
    'quadriceps': Muscle.quads,
    'adductors': Muscle.quads,
    'calves': Muscle.calves,
    'tibialis': Muscle.calves,
  };
  static const _back = <String, Muscle>{
    'deltoids': Muscle.shoulders,
    'triceps': Muscle.arms,
    'forearm': Muscle.arms,
    'trapezius': Muscle.back,
    'upper-back': Muscle.back,
    'lower-back': Muscle.back,
    'gluteal': Muscle.glutes,
    'adductors': Muscle.hamstrings,
    'hamstring': Muscle.hamstrings,
    'calves': Muscle.calves,
  };

  static final Map<String, List<Path>> _cache = {};

  static List<Path> _paths(String key, List<String> svg) => _cache.putIfAbsent(
        key,
        () => [for (final d in svg) parseSvgPathData(d)],
      );

  @override
  void paint(Canvas canvas, Size size) {
    final view = back ? kMaleBack : kMaleFront;
    final map = back ? _back : _front;
    canvas.scale(size.width / view.w, size.height / view.h);
    canvas.translate(-view.x, -view.y);
    final line = Paint()
      ..color = AppColors.gray400.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final plain = Paint()..color = AppColors.container;
    final id = back ? 'b' : 'f';
    // Plain parts first so muscles draw on top of them.
    for (final entry in view.parts.entries) {
      if (map.containsKey(entry.key)) continue;
      for (final p in _paths('$id:${entry.key}', entry.value)) {
        canvas.drawPath(p, plain);
        canvas.drawPath(p, line);
      }
    }
    for (final entry in view.parts.entries) {
      final m = map[entry.key];
      if (m == null) continue;
      final fill = Paint()
        ..color = recoveryColor(rec[m] ?? 1).withValues(alpha: 0.85);
      for (final p in _paths('$id:${entry.key}', entry.value)) {
        canvas.drawPath(p, fill);
        canvas.drawPath(p, line);
      }
    }
  }

  @override
  bool shouldRepaint(_BodyPainter old) => old.back != back || old.rec != rec;
}
