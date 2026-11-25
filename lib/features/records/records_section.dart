import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import 'record_detail_screen.dart';
import 'records_screen.dart';
import 'records_widgets.dart';

/// The Records section on the Hub.
class RecordsSection extends StatelessWidget {
  const RecordsSection({super.key});

  void _open(BuildContext context, [WorkoutType? type]) {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => RecordsScreen(initialType: type)));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final all = state.records;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Records'),
        const SizedBox(height: 10),
        if (all.isEmpty)
          NeoCard(
            onTap: () => _open(context),
            child: const Text(
              'Every workout you log is saved here. Filter by running, gym, '
              'CrossFit and more, or by date.',
              style: TextStyle(color: AppColors.gray300, height: 1.4),
            ),
          )
        else
          RecordSummary(logs: all),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final t in WorkoutType.values) ...[
                FilterChipButton(
                  label: '${t.label} (${state.workoutsOf(t)})',
                  selected: false,
                  color: typeColor(context, t),
                  onTap: () => _open(context, t),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        for (final l in all.take(3)) ...[
          RecordTile(
            log: l,
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => RecordDetailScreen(log: l))),
          ),
          const SizedBox(height: 8),
        ],
        TextButton(
          onPressed: () => _open(context),
          child: const Text('See all records'),
        ),
      ],
    );
  }
}
