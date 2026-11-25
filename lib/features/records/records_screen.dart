import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/format.dart';
import '../../data/gpx.dart';
import '../../data/models.dart';
import 'record_detail_screen.dart';
import 'records_widgets.dart';
import 'route_map.dart';
import 'run_recorder_screen.dart';

/// Every past workout, with filters by type and date. The Running filter also
/// shows a map and the ways to bring in runs from a watch.
class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key, this.initialType});

  final WorkoutType? initialType;

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  late WorkoutType? _type = widget.initialType;
  DateRangeFilter _range = DateRangeFilter.all;
  DateTimeRange? _custom;
  String? _selectedId;

  Future<void> _pickDates() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: _custom,
    );
    if (!mounted || picked == null) return;
    setState(() {
      _custom = picked;
      _range = DateRangeFilter.custom;
    });
  }

  Future<void> _importGpx() async {
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    void say(String m) =>
        messenger.showSnackBar(SnackBar(content: Text(m)));
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['gpx'],
        withData: true,
      );
      if (result == null) return;
      final bytes = result.files.single.bytes;
      if (bytes == null) {
        say('Could not read that file.');
        return;
      }
      final run = parseGpx(utf8.decode(bytes, allowMalformed: true));
      final at = run.start ?? DateTime.now();
      final duplicate = state.records.any((l) =>
          l.source == 'watch' && l.at.difference(at).inSeconds.abs() < 60);
      if (duplicate) {
        say('That run is already in your records.');
        return;
      }
      final log = run.toLog(id: 'w${at.microsecondsSinceEpoch}');
      state.addRecord(log);
      if (!mounted) return;
      setState(() => _selectedId = log.id);
      say('Imported ${formatKm(log.distanceM ?? 0)} km run');
    } on FormatException catch (e) {
      say(e.message);
    } on Object {
      say('Could not import that file. Try exporting it again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final all = state.records;
    final filtered = filterRecords(all,
        type: _type, range: _range, custom: _custom);
    final running = _type == WorkoutType.running;
    final withRoute = [for (final l in filtered) if (l.hasRoute) l];
    WorkoutLog? mapped;
    for (final l in withRoute) {
      if (l.id == _selectedId) mapped = l;
    }
    mapped ??= withRoute.isEmpty ? null : withRoute.first;

    final children = <Widget>[
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChipButton(
              label: 'All (${all.length})',
              selected: _type == null,
              onTap: () => setState(() => _type = null),
            ),
            for (final t in WorkoutType.values) ...[
              const SizedBox(width: 8),
              FilterChipButton(
                label: '${t.label} (${state.workoutsOf(t)})',
                selected: _type == t,
                color: typeColor(context, t),
                onTap: () => setState(() => _type = t),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 10),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final r in DateRangeFilter.values) ...[
              FilterChipButton(
                label: r == DateRangeFilter.custom && _custom != null
                    ? '${formatDate(_custom!.start)} - ${formatDate(_custom!.end)}'
                    : r.label,
                selected: _range == r,
                color: AppColors.gray300,
                onTap: r == DateRangeFilter.custom
                    ? _pickDates
                    : () => setState(() => _range = r),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
      const SizedBox(height: 14),
    ];

    if (running) {
      children.addAll([
        NeoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (mapped != null) ...[
                Text(mapped.displayTitle,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                RouteMap(key: ValueKey(mapped.id), route: mapped.route),
              ] else
                const Text(
                  'No run with a map yet. Record a run with your phone or '
                  'import one from your watch and its route shows here.',
                  style: TextStyle(color: AppColors.gray300, height: 1.4),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) => const RunRecorderScreen()),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Record a run'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _importGpx,
                    icon: const Icon(Icons.watch_outlined),
                    label: const Text('Import from watch'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Watch sync works with a route file (GPX). On Garmin Connect '
                'open the activity, choose Export to GPX, then import it here. '
                'Automatic sync with Garmin or Apple needs their approval and '
                'a server, so it is not built yet.',
                style: TextStyle(
                    fontSize: 12, color: AppColors.gray400, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ]);
    }

    if (filtered.isEmpty) {
      children.add(NeoCard(
        child: Column(
          children: [
            Text(
              all.isEmpty
                  ? 'No workouts yet'
                  : 'No workouts match these filters',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              all.isEmpty
                  ? 'Log a workout from the Hub and it appears here.'
                  : 'Try a different type or date range.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.gray300),
            ),
            if (all.isNotEmpty) ...[
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => setState(() {
                  _type = null;
                  _range = DateRangeFilter.all;
                }),
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ));
    } else {
      children.add(RecordSummary(logs: filtered));
      String? heading;
      for (final l in filtered) {
        final h = monthHeading(l.at);
        if (h != heading) {
          heading = h;
          children.addAll([
            const SizedBox(height: 16),
            SectionLabel(h),
            const SizedBox(height: 8),
          ]);
        }
        children.addAll([
          RecordTile(
            log: l,
            onTap: () {
              if (running && l.hasRoute) setState(() => _selectedId = l.id);
              Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => RecordDetailScreen(log: l)));
            },
          ),
          const SizedBox(height: 8),
        ]);
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Records')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
