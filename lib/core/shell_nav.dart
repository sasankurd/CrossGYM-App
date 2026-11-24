import 'package:flutter/widgets.dart';

/// Lets a screen inside a tab switch to another tab of the app shell.
///
/// Tabs: 0 Hub, 1 Train, 2 Fuel, 3 Market, 4 Athlete.
class ShellNav extends InheritedWidget {
  const ShellNav({super.key, required this.go, required super.child});

  final ValueChanged<int> go;

  static const int hub = 0;
  static const int train = 1;
  static const int fuel = 2;
  static const int market = 3;
  static const int athlete = 4;

  /// The shell above [context], or null on a pushed screen.
  static ShellNav? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<ShellNav>();

  @override
  bool updateShouldNotify(ShellNav oldWidget) => false;
}
