import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme.dart';
import 'core/shell_nav.dart';
import 'core/tokens.dart';
import 'core/widgets.dart';
import 'data/app_state.dart';
import 'features/auth/auth_screen.dart';
import 'features/home/dashboard_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/plan/plan_screen.dart';
import 'features/nutrition/nutrition_screen.dart';
import 'features/profile/athlete_tab.dart';
import 'features/store/store_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences? prefs;
  try {
    prefs = await SharedPreferences.getInstance();
  } on Object {
    // Storage blocked (for example a private window): the app still runs,
    // it just won't remember anything after a reload.
    prefs = null;
  }
  runApp(CrossGymApp(prefs: prefs));
}

class CrossGymApp extends StatefulWidget {
  const CrossGymApp({super.key, this.prefs});

  final SharedPreferences? prefs;

  @override
  State<CrossGymApp> createState() => _CrossGymAppState();
}

class _CrossGymAppState extends State<CrossGymApp> {
  late final AppState _state = AppState(prefs: widget.prefs);

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
            builder: (context, child) =>
                AmbientBackground(child: child ?? const SizedBox.shrink()),
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

/// Shows sign in, the first-run questions, or the app, depending on state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    if (!state.isSignedIn) return const AuthScreen();
    if (state.needsOnboarding) return const OnboardingScreen();
    return const AppShell();
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
    NutritionScreen(embedded: true),
    StoreScreen(),
    AthleteTab(),
  ];

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return ShellNav(
      go: _go,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1152),
              child: IndexedStack(index: _index, children: _pages),
            ),
          ),
        ),
        bottomNavigationBar: _NavBar(index: _index, onSelect: _go),
      ),
    );
  }
}

// ---- bottom bar --------------------------------------------------------------

class _NavBar extends StatelessWidget {
  const _NavBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  static const _items = <(IconData, String)>[
    (Icons.grid_view_rounded, 'Hub'),
    (Icons.bolt_rounded, 'Train'),
    (Icons.local_fire_department_rounded, 'Fuel'),
    (Icons.storefront_rounded, 'Market'),
    (Icons.person_rounded, 'Athlete'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 14 + bottom),
      decoration: const BoxDecoration(
        color: AppColors.header,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _items.length; i++)
                Semantics(
                  button: true,
                  selected: i == index,
                  label: _items[i].$2,
                  excludeSemantics: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelect(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: i == index
                            ? primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: i == index
                              ? primary.withValues(alpha: 0.35)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _items[i].$1,
                            size: 22,
                            color: i == index ? primary : AppColors.gray300,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _items[i].$2,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  i == index ? FontWeight.w700 : FontWeight.w500,
                              color: i == index ? primary : AppColors.gray300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
