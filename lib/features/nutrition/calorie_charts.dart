import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/nutrition.dart';

const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

/// Calories eaten on each of the 7 days ending at [day], with the daily
/// target as a line.
class WeekCalorieChart extends StatelessWidget {
  const WeekCalorieChart({super.key, required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final target = state.profile?.targetKcal;
    final days = [for (var i = 6; i >= 0; i--) day.subtract(Duration(days: i))];
    final values = [for (final d in days) state.caloriesOn(d)];
    final total = values.fold(0, (a, b) => a + b);
    final logged = values.where((v) => v > 0).length;
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Last 7 days',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              if (logged > 0)
                Text('avg ${formatInt((total / logged).round())} cal',
                    style: mono(size: 12, color: AppColors.gray300)),
            ],
          ),
          const SizedBox(height: 12),
          Semantics(
            label: 'Bar chart of calories for the last 7 days. '
                '${[
              for (var i = 0; i < 7; i++) '${_dayLetters[days[i].weekday - 1]} ${values[i]}',
            ].join(', ')}.',
            child: SizedBox(
              height: 150,
              child: CustomPaint(
                size: Size.infinite,
                painter: _BarsPainter(
                  values: values,
                  letters: [for (final d in days) _dayLetters[d.weekday - 1]],
                  target: target,
                  bar: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          if (target != null) ...[
            const SizedBox(height: 8),
            Text('Dashed line: your target of ${formatInt(target)} cal. '
                'Bars over it turn red.',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.gray400)),
          ],
        ],
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.values,
    required this.letters,
    required this.target,
    required this.bar,
  });

  final List<int> values;
  final List<String> letters;
  final int? target;
  final Color bar;

  @override
  void paint(Canvas canvas, Size size) {
    const labelH = 18.0;
    final chartH = size.height - labelH - 14;
    final top = 14.0;
    final maxV = [
      ...values,
      if (target != null) (target! * 1.15).round(),
      500,
    ].reduce((a, b) => a > b ? a : b);
    final slot = size.width / values.length;
    final barW = slot * 0.55;

    for (var i = 0; i < values.length; i++) {
      final x = slot * i + (slot - barW) / 2;
      final h = chartH * values[i] / maxV;
      final over = target != null && values[i] > target!;
      canvas.drawRRect(
        RRect.fromLTRBR(x, top + chartH - h, x + barW, top + chartH,
            const Radius.circular(6)),
        Paint()..color = values[i] == 0
            ? AppColors.hairline
            : (over ? AppColors.coral : bar),
      );
      if (values[i] > 0) {
        _text(canvas, '${values[i]}', Offset(x + barW / 2, top + chartH - h - 12),
            9, AppColors.gray300);
      }
      _text(canvas, letters[i], Offset(x + barW / 2, size.height - 9), 11,
          AppColors.gray300);
    }
    if (target != null) {
      final y = top + chartH - chartH * target! / maxV;
      final p = Paint()
        ..color = AppColors.gray300
        ..strokeWidth = 1;
      for (var x = 0.0; x < size.width; x += 8) {
        canvas.drawLine(Offset(x, y), Offset(x + 4, y), p);
      }
    }
  }

  void _text(Canvas c, String s, Offset center, double size, Color color) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(fontSize: size, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.values != values || old.target != target || old.bar != bar;
}

/// Where today's calories came from: protein, carbs and fat.
class MacroDonut extends StatelessWidget {
  const MacroDonut({super.key, required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final p = state.proteinOn(day) * 4;
    final c = state.carbsOn(day) * 4;
    final f = state.fatOn(day) * 9;
    final total = p + c + f;
    const protein = AppColors.cyan;
    const carbs = AppColors.volt;
    const fat = AppColors.amber;
    Widget row(String name, double kcal, Color color) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
            Text(total == 0 ? '--' : '${(kcal / total * 100).round()}%',
                style: mono(size: 13)),
          ]),
        );
    return NeoCard(
      child: Row(
        children: [
          Semantics(
            label: total == 0
                ? 'Calorie split chart, nothing logged'
                : 'Calorie split: protein ${(p / total * 100).round()} percent, '
                    'carbs ${(c / total * 100).round()} percent, '
                    'fat ${(f / total * 100).round()} percent',
            child: SizedBox(
              width: 110,
              height: 110,
              child: CustomPaint(
                painter: _DonutPainter(
                  [p, c, f],
                  const [protein, carbs, fat],
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Where the calories came from',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                row('Protein', p, protein),
                row('Carbs', c, carbs),
                row('Fat', f, fat),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.values, this.colors);

  final List<double> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.hairline;
    canvas.drawArc(arc, 0, 6.2832, false, base);
    final total = values.fold(0.0, (a, b) => a + b);
    if (total == 0) return;
    var start = -1.5708;
    for (var i = 0; i < values.length; i++) {
      final sweep = 6.2832 * values[i] / total;
      if (sweep <= 0) continue;
      canvas.drawArc(
        arc,
        start,
        sweep > 0.04 ? sweep - 0.03 : sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = colors[i],
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.values != values || old.colors != colors;
}
