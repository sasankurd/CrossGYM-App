/// Making a short video of a run and sharing it.
library;

import '../models.dart';

enum RouteVideoStyle {
  flat('2D'),
  tilted('3D');

  const RouteVideoStyle(this.label);
  final String label;
}

/// What goes into the video.
class RouteVideoSpec {
  const RouteVideoSpec({
    required this.route,
    required this.title,
    required this.stats,
    this.style = RouteVideoStyle.flat,
    this.seconds = 8,
  });

  final List<GeoPoint> route;
  final String title;

  /// One line such as "5.23 km  -  31:12  -  5:58 /km".
  final String stats;
  final RouteVideoStyle style;
  final int seconds;
}

enum ShareOutcome { shared, cancelled, unsupported }

/// A finished video held in memory.
abstract class RouteVideo {
  String get fileName;
  String get mime;
  double get megabytes;

  /// Saves the file to the device (a download in the browser).
  void save();

  /// Opens the phone's share sheet with the file.
  Future<ShareOutcome> share(String message);
}
