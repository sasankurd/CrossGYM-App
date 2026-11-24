import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/watch/heart_rate.dart';
import 'watch_screen.dart';

Color zoneColor(HeartZone z) => switch (z) {
      HeartZone.rest => AppColors.gray300,
      HeartZone.z1 => AppColors.cyan,
      HeartZone.z2 => AppColors.volt,
      HeartZone.z3 => AppColors.amber,
      HeartZone.z4 => AppColors.orange,
      HeartZone.z5 => AppColors.coral,
    };

/// Estimated maximum heart rate: 220 minus age (30 when age is unknown).
int estimatedMaxHr(AppState state) => 220 - (state.profile?.age ?? 30);

/// Live heart rate with a graph. Shows nothing when no watch is connected.
class LiveHeartCard extends StatelessWidget {
  const LiveHeartCard({super.key, this.openable = true});

  /// Whether tapping opens the watch screen.
  final bool openable;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final watch = state.watch;
    return ListenableBuilder(
      listenable: watch,
      builder: (context, _) {
        if (!watch.isConnected) return const SizedBox.shrink();
        final bpm = watch.bpm;
        final maxHr = estimatedMaxHr(state);
        final zone = bpm == null ? HeartZone.rest : zoneFor(bpm, maxHr);
        final color = zoneColor(zone);
        final text = Theme.of(context).textTheme;
        final s = watch.session;
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: NeoCard(
            onTap: openable
                ? () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const WatchScreen()),
                    )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_rounded,
                        color: AppColors.coral, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        watch.deviceName ?? 'Heart rate',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium
                            ?.copyWith(color: AppColors.gray300),
                      ),
                    ),
                    Pill(zone.label, color: color),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      bpm?.toString() ?? '--',
                      style: mono(size: 44, weight: FontWeight.w800),
                    ),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('BPM',
                          style: mono(
                              size: 12, color: AppColors.gray300)),
                    ),
                  ],
                ),
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _SparklinePainter(
                      List<int>.of(s.recent),
                      color,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Stat('Low', s.min),
                    _Stat('Average', s.average),
                    _Stat('High', s.max),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);

  final String label;
  final int? value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value?.toString() ?? '--', style: mono(size: 16)),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.gray400)),
          ],
        ),
      );
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.values, this.color);

  final List<int> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    var lo = values.first;
    var hi = values.first;
    for (final v in values) {
      if (v < lo) lo = v;
      if (v > hi) hi = v;
    }
    final span = (hi - lo) < 10 ? 10 : (hi - lo);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height - (values[i] - lo) / span * (size.height - 4) - 2;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => true;
}

/// Small live BPM badge for tab headers. Empty when no watch is connected.
class HeartRatePill extends StatelessWidget {
  const HeartRatePill({super.key});

  @override
  Widget build(BuildContext context) {
    final watch = AppScope.of(context).watch;
    return ListenableBuilder(
      listenable: watch,
      builder: (context, _) {
        final bpm = watch.bpm;
        if (!watch.isConnected || bpm == null) return const SizedBox.shrink();
        return Pill('$bpm bpm', color: AppColors.coral, icon: Icons.favorite);
      },
    );
  }
}

/// Header button that opens the watch screen. Lit up while connected.
class WatchButton extends StatelessWidget {
  const WatchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final watch = AppScope.of(context).watch;
    return ListenableBuilder(
      listenable: watch,
      builder: (context, _) => IconButton(
        tooltip: watch.isConnected ? 'Watch connected' : 'Connect a watch',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const WatchScreen()),
        ),
        icon: Icon(
          Icons.watch_rounded,
          color: watch.isConnected
              ? Theme.of(context).colorScheme.primary
              : AppColors.gray300,
        ),
      ),
    );
  }
}
