/// Reads GPX files, the route format that Garmin Connect, Strava, Apple
/// Fitness exports and most sports watches can export.
library;

import 'package:xml/xml.dart';

import 'geo.dart';
import 'models.dart';

/// A run read from a GPX file.
class GpxRun {
  const GpxRun({
    required this.points,
    this.name,
    this.start,
    this.end,
    this.avgHr,
  });

  final List<GeoPoint> points;
  final String? name;
  final DateTime? start;
  final DateTime? end;
  final int? avgHr;

  double get distanceM => routeDistanceM(points);

  /// Elapsed time from the first to the last time stamp, if the file has them.
  int? get durationSec =>
      (start != null && end != null) ? end!.difference(start!).inSeconds : null;

  WorkoutLog toLog({required String id}) => WorkoutLog(
        WorkoutType.running,
        start ?? DateTime.now(),
        id: id,
        title: name ?? 'Run from watch',
        durationSec: durationSec,
        distanceM: distanceM,
        avgHr: avgHr,
        route: thinRoute(points),
        source: 'watch',
      );
}

/// Parses GPX text. Throws [FormatException] with a plain message when the
/// text is not a GPX route.
GpxRun parseGpx(String source) {
  final XmlDocument doc;
  try {
    doc = XmlDocument.parse(source);
  } on XmlException {
    throw const FormatException('That file is not a valid GPX file.');
  }
  final points = <GeoPoint>[];
  final times = <DateTime>[];
  final heartRates = <int>[];

  for (final e in doc.descendants.whereType<XmlElement>()) {
    if (e.name.local != 'trkpt') continue;
    final lat = double.tryParse(e.getAttribute('lat') ?? '');
    final lon = double.tryParse(e.getAttribute('lon') ?? '');
    if (lat == null || lon == null) continue;
    points.add(GeoPoint(lat, lon));
    for (final c in e.childElements) {
      if (c.name.local == 'time') {
        final t = DateTime.tryParse(c.innerText.trim());
        if (t != null) times.add(t.toLocal());
      }
    }
    for (final x in e.descendants.whereType<XmlElement>()) {
      if (x.name.local == 'hr') {
        final hr = int.tryParse(x.innerText.trim());
        if (hr != null && hr >= 30 && hr <= 240) heartRates.add(hr);
      }
    }
  }
  if (points.length < 2) {
    throw const FormatException('No route found in that file.');
  }
  final names = doc.descendants
      .whereType<XmlElement>()
      .where((e) => e.name.local == 'name')
      .map((e) => e.innerText.trim())
      .where((t) => t.isNotEmpty);
  return GpxRun(
    points: points,
    name: names.isEmpty ? null : names.first,
    start: times.isEmpty ? null : times.first,
    end: times.isEmpty ? null : times.last,
    avgHr: heartRates.isEmpty
        ? null
        : (heartRates.reduce((a, b) => a + b) / heartRates.length).round(),
  );
}
