import 'package:crossgym/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
      // ignore: avoid_print
      print('APPERR: ${text.length > 1500 ? text.substring(0, 1500) : text}');
    };
    addTearDown(() => FlutterError.onError = oldHandler);

    await tester.pumpWidget(const CrossGymApp());
    // ignore: avoid_print
    print('STEP first frame drawn');
    await tester.pump(const Duration(milliseconds: 500));

    Future<void> tap(String label) async {
      // ignore: avoid_print
      print('STEP tap $label');
      final f = find.text(label);
      await tester.ensureVisible(f.first);
      // ignore: avoid_print
      print('  visible');
      await tester.tap(f.first);
      // ignore: avoid_print
      print('  tapped');
      await tester.pump(const Duration(milliseconds: 100));
      // ignore: avoid_print
      print('  pumped');
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
  }, timeout: const Timeout(Duration(seconds: 90)));
}
