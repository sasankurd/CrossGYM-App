import 'package:flutter/material.dart';

import '../../data/app_state.dart';
import '../../data/models.dart';

class SellPlanScreen extends StatefulWidget {
  const SellPlanScreen({super.key});

  @override
  State<SellPlanScreen> createState() => _SellPlanScreenState();
}

class _SellPlanScreenState extends State<SellPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _weeks = TextEditingController(text: '4');
  final _price = TextEditingController(text: '0');
  WorkoutType _type = WorkoutType.gym;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _weeks.dispose();
    _price.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    AppScope.of(context).publishPlan(
      title: _title.text.trim(),
      description: _description.text.trim(),
      type: _type,
      weeks: int.parse(_weeks.text.trim()),
      priceUsd: double.parse(_price.text.trim()),
    );
    Navigator.of(context).pop();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sell a plan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: _required,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<WorkoutType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Workout type'),
              items: [
                for (final t in WorkoutType.values)
                  DropdownMenuItem(value: t, child: Text(t.label)),
              ],
              onChanged: (t) => setState(() => _type = t ?? _type),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weeks,
              decoration: const InputDecoration(labelText: 'Length (weeks)'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                return (n == null || n < 1 || n > 52) ? '1 to 52' : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _price,
              decoration: const InputDecoration(
                labelText: 'Price (USD, 0 for free)',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = double.tryParse((v ?? '').trim());
                return (n == null || n < 0) ? 'Enter 0 or more' : null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _submit, child: const Text('Publish')),
          ],
        ),
      ),
    );
  }
}
