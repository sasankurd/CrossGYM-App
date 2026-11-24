import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/nutrition.dart';

/// Opens the add-food sheet for [day].
Future<void> showAddFoodSheet(BuildContext context, DateTime day) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.sheet,
      builder: (_) => _AddFoodSheet(day: day),
    );

class _AddFoodSheet extends StatefulWidget {
  const _AddFoodSheet({required this.day});

  final DateTime day;

  @override
  State<_AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends State<_AddFoodSheet> {
  final _search = TextEditingController();
  final _name = TextEditingController();
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  Meal _meal = Meal.forTime(DateTime.now());
  int _tab = 0;
  String? _error;

  @override
  void dispose() {
    _search.dispose();
    _name.dispose();
    _kcal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  /// Logged time: now for today, midday for another day.
  DateTime get _when {
    final now = DateTime.now();
    final d = widget.day;
    if (DateUtils.isSameDay(d, now)) return now;
    return DateTime(d.year, d.month, d.day, 12);
  }

  void _addItem(FoodItem f) {
    AppScope.of(context).addFood(
      name: f.name,
      kcal: f.kcal,
      protein: f.protein,
      carbs: f.carbs,
      fat: f.fat,
      meal: _meal,
      at: _when,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${f.name} added to ${_meal.label.toLowerCase()}')),
    );
  }

  void _addCustom() {
    final kcal = int.tryParse(_kcal.text.trim());
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Enter a name for the food.');
      return;
    }
    if (kcal == null || kcal <= 0) {
      setState(() => _error = 'Enter calories as a whole number above 0.');
      return;
    }
    AppScope.of(context).addFood(
      name: _name.text,
      kcal: kcal,
      protein: double.tryParse(_protein.text.trim()) ?? 0,
      carbs: double.tryParse(_carbs.text.trim()) ?? 0,
      fat: double.tryParse(_fat.text.trim()) ?? 0,
      meal: _meal,
      at: _when,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    final query = _search.text.trim().toLowerCase();
    final foods = [
      for (final f in kFoods)
        if (query.isEmpty || f.name.toLowerCase().contains(query)) f,
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + inset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add food', style: text.titleLarge),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final m in Meal.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(m.label),
                      selected: _meal == m,
                      onSelected: (_) => setState(() => _meal = m),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SubTabs(
            labels: const ['Quick add', 'Custom'],
            index: _tab,
            onChanged: (i) => setState(() {
              _tab = i;
              _error = null;
            }),
          ),
          const SizedBox(height: 12),
          if (_tab == 0) ...[
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search foods',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: foods.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No match. Use the Custom tab to enter it yourself.',
                        style: text.bodyMedium
                            ?.copyWith(color: AppColors.gray400),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: foods.length,
                      itemBuilder: (context, i) {
                        final f = foods[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(f.name),
                          subtitle: Text(f.serving),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${f.kcal} cal', style: mono(size: 12)),
                              IconButton(
                                tooltip: 'Add ${f.name}',
                                onPressed: () => _addItem(f),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                          onTap: () => _addItem(f),
                        );
                      },
                    ),
            ),
            Text(
              'Amounts are approximate. Use Custom for exact numbers from a '
              'food label.',
              style: text.bodySmall?.copyWith(color: AppColors.gray400),
            ),
          ] else
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _name,
                      textCapitalization: TextCapitalization.sentences,
                      decoration:
                          const InputDecoration(labelText: 'Food name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _kcal,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Calories'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final (label, c) in [
                          ('Protein (g)', _protein),
                          ('Carbs (g)', _carbs),
                          ('Fat (g)', _fat),
                        ])
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: label.startsWith('Fat') ? 0 : 8),
                              child: TextField(
                                controller: c,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration:
                                    InputDecoration(labelText: label),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!,
                          style: text.bodySmall
                              ?.copyWith(color: AppColors.rose)),
                    ],
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: _addCustom,
                      child: const Text('Add food'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
