import 'package:crossgym/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('every tab draws without errors', (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    final errors = <String>[];
    final oldHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.toString();
      // The test sandbox has no internet, so Google Fonts cannot download.
      if (text.contains('google_fonts') ||
          text.contains('GoogleFonts') ||
          text.contains('fonts.gstatic')) {
        return;
      }
      errors.add(text);
    };
    addTearDown(() => FlutterError.onError = oldHandler);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(CrossGymApp(prefs: prefs));
    await tester.pump(const Duration(milliseconds: 500));

    Future<void> tap(String label) async {
      final f = find.text(label);
      await tester.ensureVisible(f.first);
      await tester.tap(f.first);
      await tester.pump(const Duration(milliseconds: 500));
    }

    await tap('Continue as guest');
    for (var i = 0; i < 5; i++) {
      await tap('Continue');
    }
    await tap('Start training');

    expect(find.text('Command hub'), findsOneWidget, reason: 'Hub title');
    for (final tab in ['Train', 'Fuel', 'Market', 'Athlete', 'Hub']) {
      await tap(tab);
    }
    await tap('Fuel');
    expect(find.text('Precision fuel'), findsOneWidget, reason: 'Fuel title');
    await tap('Market');
    expect(find.text('Plan market'), findsOneWidget, reason: 'Market title');
    await tap('Train');
    expect(find.text('Training studio'), findsOneWidget, reason: 'Train title');

    expect(errors, isEmpty, reason: errors.join('\n----\n'));
  });
}
