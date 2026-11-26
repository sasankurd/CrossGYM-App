import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/nutrition.dart';
import 'add_food_sheet.dart';
import 'calorie_charts.dart';
import 'calorie_summary.dart';

/// The calorie tracker: one day at a time, grouped by meal.
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key, this.embedded = false});

  /// True when shown as the Fuel tab (no back button, no own page).
  final bool embedded;

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  late DateTime _day = DateUtils.dateOnly(DateTime.now());

  bool get _isToday => _day == DateUtils.dateOnly(DateTime.now());

  void _shift(int days) =>
      setState(() => _day = _day.add(Duration(days: days)));

  String get _dayLabel {
    if (_isToday) return 'Today';
    final today = DateUtils.dateOnly(DateTime.now());
    if (_day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[_day.month - 1]} ${_day.day}';
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final text = Theme.of(context).textTheme;
    final foods = state.foodsOn(_day);
    final top = MediaQuery.paddingOf(context).top;

    final profile = state.profile;
    final left = profile == null
        ? 0
        : (profile.targetKcal - state.caloriesOn(_day)).clamp(0, 99999);

    final list = ListView(
      padding: EdgeInsets.fromLTRB(16, widget.embedded ? 12 : top + 12, 16, 24),
      children: [
        if (widget.embedded)
          TabHeader(
            kicker: 'CALORIES AND MACROS',
            title: 'Precision fuel',
            trailing: [
              Pill('${formatInt(left)} cal left', color: AppColors.volt),
            ],
          )
        else
          Row(
            children: [
              IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text('Calorie tracker', style: text.titleLarge),
              ),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'Previous day',
              onPressed: () => _shift(-1),
              icon: const Icon(Icons.chevron_left),
            ),
            SizedBox(
              width: 120,
              child: Text(_dayLabel,
                  textAlign: TextAlign.center, style: text.titleMedium),
            ),
            IconButton(
              tooltip: 'Next day',
              onPressed: _isToday ? null : () => _shift(1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CalorieCard(day: _day, openable: false),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => showAddFoodSheet(context, _day),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add food'),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
        ),
        const SizedBox(height: 16),
        WeekCalorieChart(day: _day),
        const SizedBox(height: 12),
        MacroDonut(day: _day),
        const SizedBox(height: 16),
        if (foods.isEmpty)
          NeoCard(
            child: Column(
              children: [
                const Icon(Icons.restaurant_outlined,
                    color: AppColors.gray400),
                const SizedBox(height: 8),
                Text('Nothing logged ${_isToday ? 'yet' : 'this day'}',
                    style: text.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Tap Add food to log what you ate.',
                  style: text.bodySmall?.copyWith(color: AppColors.gray400),
                ),
              ],
            ),
          )
        else
          for (final meal in Meal.values)
            ..._mealSection(context, state, meal,
                foods.where((f) => f.meal == meal).toList()),
      ],
    );

    if (widget.embedded) return list;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: list,
        ),
      ),
    );
  }

  List<Widget> _mealSection(
    BuildContext context,
    AppState state,
    Meal meal,
    List<FoodEntry> items,
  ) {
    if (items.isEmpty) return const [];
    final text = Theme.of(context).textTheme;
    final total = items.fold(0, (sum, f) => sum + f.kcal);
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Row(
          children: [
            Expanded(child: Text(meal.label, style: text.titleMedium)),
            Text('${formatInt(total)} cal',
                style: mono(size: 12, color: AppColors.gray300)),
          ],
        ),
      ),
      for (final f in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: NeoCard(
            padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.name, style: text.bodyLarge),
                      Text(
                        'P ${f.protein.round()}  C ${f.carbs.round()}  '
                        'F ${f.fat.round()} g',
                        style: mono(
                          size: 11,
                          weight: FontWeight.w500,
                          color: AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ),
                Text('${f.kcal}', style: mono(size: 15)),
                IconButton(
                  tooltip: 'Remove ${f.name}',
                  onPressed: () => state.removeFood(f.id),
                  icon: const Icon(Icons.close,
                      size: 18, color: AppColors.gray400),
                ),
              ],
            ),
          ),
        ),
    ];
  }
}
