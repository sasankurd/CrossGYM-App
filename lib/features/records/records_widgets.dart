import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/format.dart';
import '../../data/models.dart';

/// Which dates to show.
enum DateRangeFilter {
  all('All time'),
  week('7 days'),
  month('30 days'),
  year('This year'),
  custom('Pick dates');

  const DateRangeFilter(this.label);
  final String label;
}

/// Filters [all] by type and date. A null [type] means every type. For
/// [DateRangeFilter.custom] the range is [from]..[to] (whole days).
List<WorkoutLog> filterRecords(
  List<WorkoutLog> all, {
  WorkoutType? type,
  DateRangeFilter range = DateRangeFilter.all,
  DateTimeRange? custom,
  DateTime? now,
}) {
  final n = now ?? DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  DateTime? from;
  DateTime? to;
  switch (range) {
    case DateRangeFilter.all:
      break;
    case DateRangeFilter.week:
      from = today.subtract(const Duration(days: 6));
    case DateRangeFilter.month:
      from = today.subtract(const Duration(days: 29));
    case DateRangeFilter.year:
      from = DateTime(n.year);
    case DateRangeFilter.custom:
      if (custom != null) {
        from = DateTime(custom.start.year, custom.start.month, custom.start.day);
        to = DateTime(custom.end.year, custom.end.month, custom.end.day)
            .add(const Duration(days: 1));
      }
  }
  return [
    for (final l in all)
      if ((type == null || l.type == type) &&
          (from == null || !l.at.isBefore(from)) &&
          (to == null || l.at.isBefore(to)))
        l,
  ];
}

/// One workout in a list.
class RecordTile extends StatelessWidget {
  const RecordTile({super.key, required this.log, required this.onTap});

  final WorkoutLog log;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = typeColor(context, log.type);
    final details = <String>[
      if (log.distanceM != null) '${formatKm(log.distanceM!)} km',
      if (log.durationSec != null) formatDuration(log.durationSec!),
      if (log.avgHr != null) '${log.avgHr} bpm',
    ];
    return NeoCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(log.type.icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '${formatDate(log.at)} at ${formatTime(log.at)}'
                  '${details.isEmpty ? '' : '  -  ${details.join('  -  ')}'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.gray300),
                ),
              ],
            ),
          ),
          if (log.hasRoute)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.map_outlined,
                  size: 18, color: AppColors.gray300),
            ),
          if (log.source == 'watch')
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.watch_outlined,
                  size: 18, color: AppColors.gray300),
            ),
        ],
      ),
    );
  }
}

/// A tappable filter chip with a selected look.
class FilterChipButton extends StatelessWidget {
  const FilterChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? c.withValues(alpha: 0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? c.withValues(alpha: 0.5) : AppColors.hairline,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? c : AppColors.gray300,
            ),
          ),
        ),
      ),
    );
  }
}

/// Totals for a list of workouts.
class RecordSummary extends StatelessWidget {
  const RecordSummary({super.key, required this.logs});

  final List<WorkoutLog> logs;

  @override
  Widget build(BuildContext context) {
    final km = logs.fold<double>(0, (s, l) => s + (l.distanceM ?? 0)) / 1000;
    final sec = logs.fold<int>(0, (s, l) => s + (l.durationSec ?? 0));
    Widget cell(String value, String label) => Expanded(
          child: Column(
            children: [
              Text(value,
                  style: mono(size: 20, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.gray300)),
            ],
          ),
        );
    return NeoCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        children: [
          cell('${logs.length}', 'Workouts'),
          cell(km.toStringAsFixed(1), 'km tracked'),
          cell(sec == 0 ? '--' : formatDuration(sec), 'Time tracked'),
        ],
      ),
    );
  }
}
