import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme.dart';
import 'core/tokens.dart';
import 'core/widgets.dart';
import 'data/app_state.dart';
import 'data/models.dart';
import 'features/home/dashboard_screen.dart';
import 'features/plan/plan_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/social/social_screen.dart';
import 'features/store/store_screen.dart';
import 'features/workouts/workout_type_screen.dart';

void main() => runApp(const CrossGymApp());

class CrossGymApp extends StatefulWidget {
  const CrossGymApp({super.key});

  @override
  State<CrossGymApp> createState() => _CrossGymAppState();
}

class _CrossGymAppState extends State<CrossGymApp> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: ListenableBuilder(
        listenable: _state,
        builder: (context, _) {
          final theme = buildTheme(_state.theme);
          return MaterialApp(
            title: 'CrossGYM',
            debugShowCheckedModeBanner: false,
            theme: theme,
            darkTheme: theme,
            themeMode: ThemeMode.dark,
            builder: (context, child) => AmbientBackground(
              primary: _state.theme.primary,
              secondary: _state.theme.secondary,
              child: child ?? const SizedBox.shrink(),
            ),
            home: const AppShell(),
          );
        },
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = <Widget>[
    DashboardScreen(),
    PlanScreen(),
    StoreScreen(),
    SocialScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1152),
                child: IndexedStack(index: _index, children: _pages),
              ),
            ),
          ),
          Positioned(
            top: top + 8,
            left: 12,
            right: 12,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1152),
                child: _GlassHeader(onCoach: () => _showCoachSheet(context)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _Dock(
              index: _index,
              onSelect: (i) => setState(() => _index = i),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- header ----------------------------------------------------------------

class _GlassHeader extends StatelessWidget {
  const _GlassHeader({required this.onCoach});

  final VoidCallback onCoach;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final text = Theme.of(context).textTheme;
    return GlassSurface(
      radius: 28,
      sigma: 24,
      strong: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          children: [
            const _Monogram(),
            if (width >= 420) ...[
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('CrossGYM', style: text.titleLarge),
                  Text(
                    'HYBRID ATHLETE OS',
                    style: mono(
                      size: 9,
                      weight: FontWeight.w500,
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ],
            const Spacer(),
            Pill(
              'CNS ${(state.readiness * 100).round()}%',
              color: AppColors.emerald,
              icon: Icons.bolt,
            ),
            const SizedBox(width: 8),
            Pill(
              '${state.streakDays}',
              color: AppColors.orange,
              icon: Icons.local_fire_department,
            ),
            const _ThemeMenu(),
            if (width >= 600)
              FilledButton.icon(
                onPressed: onCoach,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Coach'),
                style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
              )
            else
              IconButton.filled(
                onPressed: onCoach,
                tooltip: 'Coach',
                icon: const Icon(Icons.auto_awesome, size: 18),
              ),
          ],
        ),
      ),
    );
  }
}

class _Monogram extends StatelessWidget {
  const _Monogram();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.35),
            blurRadius: 14,
          ),
        ],
      ),
      child: Center(
        child: Text(
          'C',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.canvas,
          ),
        ),
      ),
    );
  }
}

class _ThemeMenu extends StatelessWidget {
  const _ThemeMenu();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return PopupMenuButton<int>(
      tooltip: 'Theme',
      icon: const Icon(Icons.palette_outlined, color: AppColors.gray300),
      initialValue: state.themeIndex,
      onSelected: state.setTheme,
      itemBuilder: (context) => [
        for (var i = 0; i < kAnimeThemes.length; i++)
          PopupMenuItem<int>(
            value: i,
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [kAnimeThemes[i].primary, kAnimeThemes[i].secondary],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(kAnimeThemes[i].name),
              ],
            ),
          ),
      ],
    );
  }
}

// ---- floating dock ---------------------------------------------------------

class _Dock extends StatelessWidget {
  const _Dock({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  static const _items = <(IconData, IconData, String)>[
    (Icons.space_dashboard_outlined, Icons.space_dashboard, 'HOME'),
    (Icons.checklist_rounded, Icons.checklist_rounded, 'PLAN'),
    (Icons.storefront_outlined, Icons.storefront, 'STORE'),
    (Icons.forum_outlined, Icons.forum, 'SOCIAL'),
    (Icons.person_outline, Icons.person, 'PROFILE'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final scheme = Theme.of(context).colorScheme;
    final n = _items.length;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom + 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: GlassSurface(
            radius: 36,
            sigma: 28,
            strong: true,
            child: SizedBox(
              height: 72,
              child: Stack(
                children: [
                  // The lens: a brighter piece of glass that slides to the
                  // selected tab.
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment(-1 + 2 * index / (n - 1), 0),
                    child: FractionallySizedBox(
                      widthFactor: 1 / n,
                      heightFactor: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: 0.35),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: GlassSurface(
                            radius: 30,
                            blur: false,
                            tint: [
                              scheme.primary.withValues(alpha: 0.34),
                              Colors.white.withValues(alpha: 0.10),
                            ],
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    type: MaterialType.transparency,
                    child: Row(
                    children: [
                      for (var i = 0; i < n; i++)
                        Expanded(
                          child: _DockItem(
                            icon: i == index ? _items[i].$2 : _items[i].$1,
                            label: _items[i].$3,
                            active: i == index,
                            onTap: () => onSelect(i),
                          ),
                        ),
                    ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : AppColors.gray400;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: active ? 1.12 : 1,
              duration: const Duration(milliseconds: 220),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(label, style: mono(size: 9, color: color)),
          ],
        ),
      ),
    );
  }
}

// ---- coach sheet -----------------------------------------------------------

void _showCoachSheet(BuildContext context) {
  final state = AppScope.of(context);
  final readiness = state.readiness;
  final type =
      readiness < 0.6 ? WorkoutType.recovery : state.leastTrainedType;
  final reason = readiness < 0.6
      ? 'You trained a lot in the last two days, so recovery fits best.'
      : '${type.label} is the type you trained least in the last 7 days.';
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.sheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final scheme = Theme.of(sheetContext).colorScheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Suggested next session'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(type.icon, color: scheme.primary, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    type.label,
                    style: Theme.of(sheetContext).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(reason),
              const SizedBox(height: 8),
              Text(
                'This is a simple rule based on your logged sessions. It is '
                'not AI coaching yet.',
                style: Theme.of(sheetContext)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.gray400),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => WorkoutTypeScreen(type: type),
                      ),
                    );
                  },
                  child: Text('Open ${type.label}'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
