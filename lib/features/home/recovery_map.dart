import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
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
                  width: 140,
                  height: 294,
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

  // Drawn in a 200 x 420 box and scaled to fit.
  static RRect _r(double l, double t, double r, double b, [double rad = 12]) =>
      RRect.fromLTRBR(l, t, r, b, Radius.circular(rad));

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 200, size.height / 420);
    final outline = Paint()
      ..color = AppColors.gray400.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final neutral = Paint()..color = AppColors.container;

    // head, neck, hands and feet (not tracked)
    canvas.drawCircle(const Offset(100, 34), 22, neutral);
    canvas.drawCircle(const Offset(100, 34), 22, outline);
    canvas.drawRRect(_r(90, 54, 110, 78, 6), neutral);
    for (final r in [
      _r(28, 240, 52, 262, 10),
      _r(148, 240, 172, 262, 10),
      _r(70, 408, 98, 420, 6),
      _r(102, 408, 130, 420, 6),
    ]) {
      canvas.drawRRect(r, neutral);
    }

    void draw(Muscle m, List<RRect> shapes) {
      final p = Paint()
        ..color = recoveryColor(rec[m] ?? 1).withValues(alpha: 0.85);
      for (final s in shapes) {
        canvas.drawRRect(s, p);
        canvas.drawRRect(s, outline);
      }
    }

    draw(Muscle.shoulders,
        [_r(40, 78, 82, 108, 14), _r(118, 78, 160, 108, 14)]);
    draw(Muscle.arms, [
      _r(30, 112, 54, 172, 10),
      _r(146, 112, 170, 172, 10),
      _r(28, 178, 52, 236, 10),
      _r(148, 178, 172, 236, 10),
    ]);
    if (!back) {
      draw(Muscle.chest, [_r(60, 84, 98, 132, 12), _r(102, 84, 140, 132, 12)]);
      draw(Muscle.core, [_r(76, 138, 124, 222, 12)]);
      draw(Muscle.quads, [_r(66, 232, 98, 332, 14), _r(102, 232, 134, 332, 14)]);
      draw(Muscle.calves,
          [_r(70, 338, 96, 406, 12), _r(104, 338, 130, 406, 12)]);
    } else {
      draw(Muscle.back, [_r(60, 84, 140, 190, 14)]);
      draw(Muscle.glutes, [_r(66, 196, 98, 244, 16), _r(102, 196, 134, 244, 16)]);
      draw(Muscle.hamstrings,
          [_r(66, 250, 98, 334, 14), _r(102, 250, 134, 334, 14)]);
      draw(Muscle.calves,
          [_r(70, 340, 96, 406, 12), _r(104, 340, 130, 406, 12)]);
    }
  }

  @override
  bool shouldRepaint(_BodyPainter old) => old.back != back || old.rec != rec;
}
