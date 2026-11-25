import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/format.dart';
import '../../data/gps/gps_source_factory.dart';
import '../../data/gps/run_recorder.dart';
import 'route_map.dart';

/// Records a run with the phone's GPS.
class RunRecorderScreen extends StatefulWidget {
  const RunRecorderScreen({super.key});

  @override
  State<RunRecorderScreen> createState() => _RunRecorderScreenState();
}

class _RunRecorderScreenState extends State<RunRecorderScreen> {
  RunRecorder? _rec;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _rec ??= RunRecorder(
      source: createGpsSource(),
      watch: AppScope.of(context).watch,
    );
  }

  @override
  void dispose() {
    _rec?.dispose();
    super.dispose();
  }

  void _finish() {
    final rec = _rec!;
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final log = rec.finish();
    if (log == null) {
      messenger.showSnackBar(const SnackBar(
        content: Text('No route yet, so nothing was saved. Keep moving a few '
            'steps and try again.'),
      ));
      return;
    }
    state.addRecord(log);
    nav.pop();
    messenger.showSnackBar(
        const SnackBar(content: Text('Run saved to your records')));
  }

  @override
  Widget build(BuildContext context) {
    final rec = _rec!;
    return Scaffold(
      appBar: AppBar(title: const Text('Record a run')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: rec,
          builder: (context, _) {
            final bpm = AppScope.of(context).watch.bpm;
            Widget stat(String v, String label) => Expanded(
                  child: Column(
                    children: [
                      Text(v, style: mono(size: 22, weight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(label,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.gray300)),
                    ],
                  ),
                );
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (!rec.isSupported)
                  const NeoCard(
                    child: Text(
                      'This browser cannot give a location, so a run cannot be '
                      'recorded here. You can still import a run from your '
                      'watch as a GPX file.',
                      style: TextStyle(color: AppColors.gray300, height: 1.4),
                    ),
                  )
                else ...[
                  NeoCard(
                    child: Row(
                      children: [
                        stat(formatDuration(rec.elapsedSec), 'Time'),
                        stat('${formatKm(rec.distanceM)} km', 'Distance'),
                        stat(formatPace(rec.distanceM, rec.elapsedSec), 'Pace'),
                        if (bpm != null) stat('$bpm', 'bpm'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (rec.isRecording || rec.points.isNotEmpty)
                    RouteMap(route: rec.points, follow: true, height: 300)
                  else
                    const NeoCard(
                      child: Text(
                        'Press Start, allow location when the browser asks, '
                        'and begin running. Keep this page open and the '
                        'screen on while you run: a web page cannot track '
                        'you once the phone is locked.',
                        style:
                            TextStyle(color: AppColors.gray300, height: 1.4),
                      ),
                    ),
                  if (rec.error != null) ...[
                    const SizedBox(height: 12),
                    Text(rec.error!,
                        style: const TextStyle(color: AppColors.coral)),
                  ],
                  const SizedBox(height: 16),
                  if (!rec.isRecording)
                    FilledButton.icon(
                      onPressed: rec.start,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Start run'),
                    )
                  else ...[
                    FilledButton.icon(
                      onPressed: _finish,
                      icon: const Icon(Icons.stop_rounded),
                      label: const Text('Finish and save'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () {
                        rec.discard();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Discard'),
                    ),
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
