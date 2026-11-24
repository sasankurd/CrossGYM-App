import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/app_state.dart';
import '../../data/models.dart';
import '../../data/nutrition.dart';

/// First-run questions: body, training week, goal, then the calorie result.
///
/// With [edit] set it opens pre-filled from the saved profile and closes
/// itself after saving.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.edit = false});

  final bool edit;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _lastStep = 5;

  int _step = 0;
  Sex _sex = Sex.male;
  int _age = 30;
  int _height = 175;
  double _weight = 72;
  int _sessions = 3;
  int _minutes = 45;
  Set<WorkoutType> _types = {WorkoutType.gym};
  Goal _goal = Goal.maintain;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final p = AppScope.of(context).profile;
    if (p != null) {
      _sex = p.sex;
      _age = p.age;
      _height = p.heightCm;
      _weight = p.weightKg;
      _sessions = p.sessionsPerWeek;
      _minutes = p.minutesPerSession;
      _types = {...p.types};
      _goal = p.goal;
    }
  }

  HealthProfile get _profile => HealthProfile(
        sex: _sex,
        age: _age,
        heightCm: _height,
        weightKg: _weight,
        sessionsPerWeek: _sessions,
        minutesPerSession: _minutes,
        types: _types,
        goal: _goal,
      );

  bool get _canContinue => _step != 3 || _types.isNotEmpty;

  void _next() {
    if (_step == 2 && _age < 18 && _goal == Goal.cut) _goal = Goal.maintain;
    if (_step < _lastStep) {
      setState(() => _step++);
      return;
    }
    AppScope.of(context).saveProfile(_profile);
    if (widget.edit) Navigator.of(context).pop();
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else if (widget.edit) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final scheme = Theme.of(context).colorScheme;
    final canGoBack = _step > 0 || widget.edit;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, top + 20, 20, bottom + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    for (var i = 0; i <= _lastStep; i++)
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 5,
                          margin: EdgeInsets.only(right: i == _lastStep ? 0 : 6),
                          decoration: BoxDecoration(
                            color: i <= _step
                                ? scheme.primary
                                : AppColors.hairlineStrong,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Step ${_step + 1} of ${_lastStep + 1}',
                    style: mono(
                      size: 11,
                      weight: FontWeight.w500,
                      color: AppColors.gray400,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: SingleChildScrollView(
                      key: ValueKey(_step),
                      child: _stepBody(context),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (canGoBack) ...[
                      OutlinedButton(
                        onPressed: _back,
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size(96, 50)),
                        child: const Text('Back'),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: FilledButton(
                        onPressed: _canContinue ? _next : null,
                        style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(50)),
                        child: Text(_step == _lastStep
                            ? (widget.edit ? 'Save changes' : 'Start training')
                            : 'Continue'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepBody(BuildContext context) => switch (_step) {
        0 => _aboutYou(context),
        1 => _body(context),
        2 => _week(context),
        3 => _trainingTypes(context),
        4 => _goalStep(context),
        _ => _result(context),
      };

  // ---- steps -----------------------------------------------------------------

  Widget _heading(BuildContext context, String title, String hint) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.headlineMedium),
          const SizedBox(height: 6),
          Text(hint,
              style: text.bodyMedium?.copyWith(color: AppColors.gray300)),
        ],
      ),
    );
  }

  Widget _aboutYou(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            context,
            'About you',
            'Your sex and age set your resting calorie burn. The formula we '
                'use needs one of the two options below.',
          ),
          Row(
            children: [
              for (final s in Sex.values)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: s == Sex.male ? 10 : 0),
                    child: NeoCard(
                      selected: _sex == s,
                      accent: _sex == s,
                      onTap: () => setState(() => _sex = s),
                      child: Center(
                        child: Text(s.label,
                            style: Theme.of(context).textTheme.titleMedium),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _Slider(
            label: 'Age',
            value: _age.toDouble(),
            min: 13,
            max: 80,
            display: '$_age years',
            onChanged: (v) => setState(() => _age = v.round()),
          ),
        ],
      );

  Widget _body(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(context, 'Height and weight',
              'Drag the sliders. You can change these later.'),
          _Slider(
            label: 'Height',
            value: _height.toDouble(),
            min: 120,
            max: 220,
            display: '$_height cm',
            onChanged: (v) => setState(() => _height = v.round()),
          ),
          const SizedBox(height: 12),
          _Slider(
            label: 'Weight',
            value: _weight,
            min: 30,
            max: 200,
            display: '${_weight.toStringAsFixed(1)} kg',
            divisions: 340,
            onChanged: (v) => setState(() => _weight = (v * 2).round() / 2),
          ),
        ],
      );

  Widget _week(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(context, 'Your training week',
              'How much do you train in a normal week?'),
          _Slider(
            label: 'Sessions per week',
            value: _sessions.toDouble(),
            min: 0,
            max: 14,
            display: _sessions == 1 ? '1 session' : '$_sessions sessions',
            onChanged: (v) => setState(() => _sessions = v.round()),
          ),
          const SizedBox(height: 12),
          _Slider(
            label: 'Minutes per session',
            value: _minutes.toDouble(),
            min: 15,
            max: 180,
            display: '$_minutes min',
            divisions: 33,
            onChanged: (v) => setState(() => _minutes = (v / 5).round() * 5),
          ),
          const SizedBox(height: 12),
          Text(
            'That is about ${_profile.weeklyHours.toStringAsFixed(1)} hours '
            'of training a week.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.gray300),
          ),
        ],
      );

  Widget _trainingTypes(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(context, 'What do you train?',
              'Pick every type you do. Choose at least one.'),
          for (final t in WorkoutType.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: NeoCard(
                selected: _types.contains(t),
                accent: _types.contains(t),
                onTap: () => setState(() {
                  if (!_types.remove(t)) _types.add(t);
                }),
                child: Row(
                  children: [
                    Icon(t.icon, color: typeColor(context, t)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(t.label,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    Icon(
                      _types.contains(t)
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: _types.contains(t)
                          ? Theme.of(context).colorScheme.primary
                          : AppColors.gray400,
                    ),
                  ],
                ),
              ),
            ),
        ],
      );

  Widget _goalStep(BuildContext context) {
    final minor = _age < 18;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(context, 'What is your goal?',
            'This decides how many calories you should eat each day.'),
        for (final g in Goal.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Opacity(
              opacity: minor && g == Goal.cut ? 0.45 : 1,
              child: NeoCard(
                selected: _goal == g,
                accent: _goal == g,
                onTap: minor && g == Goal.cut
                    ? null
                    : () => setState(() => _goal = g),
                child: Row(
                  children: [
                    Icon(g.icon, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.label,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            g.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.gray300),
                          ),
                        ],
                      ),
                    ),
                    if (_goal == g)
                      Icon(Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary),
                  ],
                ),
              ),
            ),
          ),
        if (minor)
          Text(
            'Weight loss targets are not offered under 18. Talk to a doctor '
            'before changing how you eat.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.gray400),
          ),
      ],
    );
  }

  Widget _result(BuildContext context) {
    final p = _profile;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(context, 'Your daily calories',
            'Based on your answers and your goal to ${p.goal.label.toLowerCase()}.'),
        NeoCard(
          accent: true,
          child: Column(
            children: [
              Text(formatInt(p.targetKcal),
                  style: mono(size: 48, weight: FontWeight.w700)
                      .copyWith(color: scheme.primary)),
              Text('calories per day', style: text.bodyMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Macro('Protein', '${p.proteinG} g', AppColors.rose),
                  _Macro('Carbs', '${p.carbsG} g', AppColors.amber),
                  _Macro('Fat', '${p.fatG} g', AppColors.emerald),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        NeoCard(
          child: Column(
            children: [
              _Row('Resting burn (BMR)', '${formatInt(p.bmr.round())} cal'),
              const SizedBox(height: 8),
              _Row('With training (daily burn)',
                  '${formatInt(p.tdee.round())} cal'),
              const SizedBox(height: 8),
              _Row(
                'Goal adjustment',
                p.goal == Goal.maintain
                    ? 'None'
                    : '${p.goal.adjust > 0 ? '+' : ''}${(p.goal.adjust * 100).round()}%',
              ),
            ],
          ),
        ),
        if (p.hitFloor) ...[
          const SizedBox(height: 12),
          Text(
            'Your weight-loss target was raised to ${formatInt(p.targetKcal)} '
            'calories, the lowest level we suggest.',
            style: text.bodySmall?.copyWith(color: AppColors.amber),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          'These are estimates from a standard formula (Mifflin-St Jeor), not '
          'medical advice. If you have a health condition or are pregnant, ask '
          'a doctor or dietitian first.',
          style: text.bodySmall?.copyWith(color: AppColors.gray400),
        ),
      ],
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.display,
    required this.onChanged,
    this.divisions,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String display;
  final int? divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.gray300)),
              ),
              Text(display, style: mono(size: 18, weight: FontWeight.w700)),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions ?? (max - min).round(),
            semanticFormatterCallback: (_) => '$label $display',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Macro extends StatelessWidget {
  const _Macro(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value, style: mono(size: 18, weight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: color)),
          ],
        ),
      );
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.gray300)),
          ),
          Text(value, style: mono(size: 14)),
        ],
      );
}
