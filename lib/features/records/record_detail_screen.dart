import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/format.dart';
import '../../data/models.dart';
import 'route_map.dart';

/// One workout in full: numbers, map (if it has a route) and delete.
class RecordDetailScreen extends StatelessWidget {
  const RecordDetailScreen({super.key, required this.log});

  final WorkoutLog log;

  @override
  Widget build(BuildContext context) {
    final color = typeColor(context, log.type);
    final sourceText = switch (log.source) {
      'watch' => 'Imported from a watch file',
      'gps' => 'Recorded in CrossGYM with phone GPS',
      'plan' => 'Finished from your plan',
      _ => 'Logged by you',
    };
    Widget stat(String value, String label) => Expanded(
          child: Column(
            children: [
              Text(value, style: mono(size: 20, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.gray300)),
            ],
          ),
        );
    final d = log.distanceM;
    final s = log.durationSec;
    return Scaffold(
      appBar: AppBar(title: Text(log.displayTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Row(
              children: [
                Pill(log.type.label, color: color, icon: log.type.icon),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${formatDate(log.at)} at ${formatTime(log.at)}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.gray300),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (d != null || s != null || log.avgHr != null)
              NeoCard(
                child: Row(
                  children: [
                    if (s != null) stat(formatDuration(s), 'Time'),
                    if (d != null) stat('${formatKm(d)} km', 'Distance'),
                    if (d != null && s != null) stat(formatPace(d, s), 'Pace'),
                    if (log.avgHr != null) stat('${log.avgHr}', 'Avg bpm'),
                  ],
                ),
              )
            else
              const NeoCard(
                child: Text(
                  'This workout was logged without numbers. Runs recorded with '
                  'GPS or imported from a watch show time, distance and a map.',
                  style: TextStyle(color: AppColors.gray300, height: 1.4),
                ),
              ),
            if (log.hasRoute) ...[
              const SizedBox(height: 14),
              RouteMap(route: log.route, height: 280),
            ],
            const SizedBox(height: 14),
            Text(sourceText,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.gray400)),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => _delete(context),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete workout'),
            ),
          ],
        ),
      ),
    );
  }

  void _delete(BuildContext context) {
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final removed = state.removeRecord(log.id);
    Navigator.of(context).pop();
    if (removed == null) return;
    messenger.showSnackBar(SnackBar(
      content: const Text('Workout deleted'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => state.addRecord(removed),
      ),
    ));
  }
}
