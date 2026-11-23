import 'package:flutter/material.dart';

import '../../core/exercise_art.dart';
import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/exercise_catalog.dart';
import '../../data/models.dart';

/// Three-step picker: discipline, then sub-category, then a photo grid.
Future<void> showExercisePicker(
  BuildContext context, {
  required ValueChanged<Exercise> onPick,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.sheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SizedBox(
      height: MediaQuery.sizeOf(sheetContext).height * 0.82,
      child: _ExercisePicker(
        onPick: (e) {
          Navigator.of(sheetContext).pop();
          onPick(e);
        },
      ),
    ),
  );
}

class _ExercisePicker extends StatefulWidget {
  const _ExercisePicker({required this.onPick});

  final ValueChanged<Exercise> onPick;

  @override
  State<_ExercisePicker> createState() => _ExercisePickerState();
}

class _ExercisePickerState extends State<_ExercisePicker> {
  WorkoutType? _type;
  String? _sub; // null means "All"

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final type = _type;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.hairlineStrong,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (type != null)
                  IconButton(
                    onPressed: () => setState(() {
                      _type = null;
                      _sub = null;
                    }),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                  ),
                Expanded(
                  child: Text(
                    type == null ? 'Choose a discipline' : type.label,
                    style: text.titleLarge,
                  ),
                ),
                Text(
                  type == null ? 'STEP 1/3' : 'STEP 3/3',
                  style: mono(size: 10, color: AppColors.gray400),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (type == null)
              Expanded(child: _disciplines())
            else ...[
              _subPills(type),
              const SizedBox(height: 12),
              Expanded(child: _grid(type)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _disciplines() {
    return ListView(
      children: [
        for (final t in WorkoutType.values) ...[
          NeoCard(
            radius: 20,
            padding: const EdgeInsets.all(14),
            onTap: () => setState(() => _type = t),
            child: Row(
              children: [
                Icon(t.icon, color: typeColor(context, t)),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(t.label,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Text(
                  '${exercisesFor(t).length}',
                  style: mono(size: 12, color: AppColors.gray400),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: AppColors.gray400),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _subPills(WorkoutType type) {
    final subs = subCategoriesFor(type);
    final primary = Theme.of(context).colorScheme.primary;
    Widget pill(String label, bool selected, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected
                    ? primary.withValues(alpha: 0.14)
                    : AppColors.glassFill,
                borderRadius: BorderRadius.circular(999),
                border:
                    Border.all(color: selected ? primary : AppColors.hairline),
              ),
              child: Text(
                label,
                style: mono(
                  size: 12,
                  color: selected ? primary : AppColors.gray300,
                ),
              ),
            ),
          ),
        );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          pill('All', _sub == null, () => setState(() => _sub = null)),
          for (final s in subs) pill(s, _sub == s, () => setState(() => _sub = s)),
        ],
      ),
    );
  }

  Widget _grid(WorkoutType type) {
    final items = exercisesFor(type)
        .where((e) => _sub == null || e.sub == _sub)
        .toList();
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 140,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final e = items[i];
        return NeoCard(
          radius: 16,
          padding: const EdgeInsets.all(8),
          onTap: () => widget.onPick(e),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.glassFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: ExerciseArt(slug: e.slug, size: 76)),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                e.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, height: 1.2),
              ),
            ],
          ),
        );
      },
    );
  }
}
