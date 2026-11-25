import 'package:crossgym/core/theme.dart';
import 'package:crossgym/data/app_state.dart';
import 'package:crossgym/data/nutrition.dart';
import 'package:crossgym/data/models.dart';
import 'package:crossgym/features/auth/auth_screen.dart';
import 'package:crossgym/features/home/dashboard_screen.dart';
import 'package:crossgym/features/nutrition/nutrition_screen.dart';
import 'package:crossgym/features/onboarding/onboarding_screen.dart';
import 'package:crossgym/features/plan/plan_screen.dart';
import 'package:crossgym/features/profile/athlete_tab.dart';
import 'package:crossgym/features/store/store_screen.dart';
import 'package:crossgym/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Draws one screen at phone size and fails on any framework error.
/// Google Fonts cannot download in the test sandbox, so those are ignored.
void screenTest(String name, Widget Function() build,
    {String? expectText, bool signedIn = true}) {
  testWidgets(name, (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final errors = <String>[];
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      final t = d.toString();
      if (t.contains('google_fonts') ||
          t.contains('GoogleFonts') ||
          t.contains('fonts.gstatic')) {
        return;
      }
      errors.add(t.length > 1800 ? t.substring(0, 1800) : t);
    };
    addTearDown(() => FlutterError.onError = old);

    final state = AppState();
    if (signedIn) {
      state.continueAsGuest();
      state.saveProfile(const HealthProfile(
        sex: Sex.male,
        age: 30,
        heightCm: 175,
        weightKg: 72,
        sessionsPerWeek: 3,
        minutesPerSession: 45,
        types: {WorkoutType.gym},
        goal: Goal.maintain,
      ));
    }
    addTearDown(state.dispose);

    await tester.pumpWidget(AppScope(
      state: state,
      child: MaterialApp(
        theme: buildTheme(state.theme),
        home: Scaffold(body: SafeArea(child: build())),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    if (name == 'app shell with tabs') {
      final size = tester.getSize(find.byType(DashboardScreen));
      expect(size.height, greaterThan(400), reason: 'Hub page height');
      expect(size.width, greaterThan(300), reason: 'Hub page width');
    }
    if (expectText != null) {
      expect(find.text(expectText), findsOneWidget, reason: 'title text');
    }
    // ignore: avoid_print
    for (final e in errors) {
      // ignore: avoid_print
      print('APPERR[$name]: $e');
    }
    expect(errors, isEmpty, reason: errors.join('\n----\n'));
  }, timeout: const Timeout(Duration(seconds: 60)));
}

void main() {
  screenTest('sign in screen', () => const AuthScreen(),
      expectText: 'Create your account', signedIn: false);
  screenTest('first-run questions', () => const OnboardingScreen(),
      expectText: 'About you');
  screenTest('Hub', () => const DashboardScreen(), expectText: 'Command hub');
  screenTest('Train', () => const PlanScreen(), expectText: 'Training studio');
  screenTest('Fuel', () => const NutritionScreen(embedded: true),
      expectText: 'Precision fuel');
  screenTest('Market', () => const StoreScreen(), expectText: 'Plan market');
  screenTest('Athlete', () => const AthleteTab());
  screenTest('app shell with tabs', () => const AppShell(),
      expectText: 'Command hub');
  screenTest('whole app', () => const CrossGymApp(), expectText: 'Create your account');
}
