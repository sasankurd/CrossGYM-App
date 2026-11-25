import 'package:crossgym/data/export/route_scene.dart';
import 'package:crossgym/data/format.dart';
import 'package:crossgym/data/geo.dart';
import 'package:crossgym/data/gps/gps_source.dart';
import 'package:crossgym/data/gps/run_recorder.dart';
import 'package:crossgym/data/gpx.dart';
import 'package:crossgym/data/models.dart';
import 'package:crossgym/features/records/records_widgets.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';

const _gpx = '''<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="test" xmlns="http://www.topografix.com/GPX/1/1"
     xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1">
  <trk><name>Morning run</name><trkseg>
    <trkpt lat="36.1900" lon="44.0100"><time>2026-11-20T05:00:00Z</time>
      <extensions><gpxtpx:TrackPointExtension><gpxtpx:hr>140</gpxtpx:hr></gpxtpx:TrackPointExtension></extensions></trkpt>
    <trkpt lat="36.1950" lon="44.0100"><time>2026-11-20T05:03:00Z</time>
      <extensions><gpxtpx:TrackPointExtension><gpxtpx:hr>160</gpxtpx:hr></gpxtpx:TrackPointExtension></extensions></trkpt>
    <trkpt lat="36.2000" lon="44.0100"><time>2026-11-20T05:06:00Z</time></trkpt>
  </trkseg></trk>
</gpx>''';

class FakeGps implements GpsSource {
  void Function(double, double, double)? push;
  void Function(String)? fail;
  bool stopped = false;

  @override
  bool get isSupported => true;

  @override
  void start({
    required void Function(double lat, double lon, double accuracyM) onPoint,
    required void Function(String message) onError,
  }) {
    push = onPoint;
    fail = onError;
  }

  @override
  void stop() => stopped = true;
}

void main() {
  test('distance between two points on a meridian', () {
    const a = GeoPoint(0, 0);
    const b = GeoPoint(0, 0.01);
    expect(haversineM(a, b), closeTo(1112, 1));
    expect(routeDistanceM([a, b, const GeoPoint(0, 0.02)]), closeTo(2224, 2));
  });

  test('thinning keeps the first and last point', () {
    final pts = [for (var i = 0; i < 1000; i++) GeoPoint(i * 0.0001, 0)];
    final thin = thinRoute(pts);
    expect(thin.length, 300);
    expect(thin.first.lat, pts.first.lat);
    expect(thin.last.lat, pts.last.lat);
    expect(thinRoute(pts.take(10).toList()).length, 10);
  });

  test('formats duration, distance, pace and dates', () {
    expect(formatDuration(125), '2:05');
    expect(formatDuration(3725), '1:02:05');
    expect(formatKm(5230), '5.23');
    expect(formatPace(5000, 1500), '5:00 /km');
    expect(formatPace(10, 60), '--');
    expect(formatDate(DateTime(2026, 11, 25), now: DateTime(2026, 12, 1)),
        'Nov 25');
    expect(formatDate(DateTime(2025, 1, 5), now: DateTime(2026, 12, 1)),
        'Jan 5, 2025');
    expect(monthHeading(DateTime(2026, 11, 25)), 'November 2026');
  });

  test('reads a GPX run with heart rate', () {
    final run = parseGpx(_gpx);
    expect(run.name, 'Morning run');
    expect(run.points.length, 3);
    expect(run.durationSec, 360);
    expect(run.avgHr, 150);
    expect(run.distanceM, closeTo(1112, 5)); // 0.01 degrees of latitude
    final log = run.toLog(id: 'x');
    expect(log.type, WorkoutType.running);
    expect(log.source, 'watch');
    expect(log.hasRoute, isTrue);
  });

  test('rejects files that are not a route', () {
    expect(() => parseGpx('not xml'), throwsFormatException);
    expect(() => parseGpx('<gpx></gpx>'), throwsFormatException);
  });

  test('a workout survives a JSON round trip', () {
    final log = WorkoutLog(
      WorkoutType.running,
      DateTime(2026, 11, 20, 8),
      id: 'a',
      title: 'Run',
      durationSec: 1800,
      distanceM: 5000,
      avgHr: 150,
      route: const [GeoPoint(36.19, 44.01), GeoPoint(36.2, 44.01)],
      source: 'gps',
    );
    final back = WorkoutLog.fromJson(log.toJson());
    expect(back.type, WorkoutType.running);
    expect(back.distanceM, 5000);
    expect(back.route.length, 2);
    expect(back.route.first.lat, 36.19);
    final plain = WorkoutLog.fromJson(
        WorkoutLog(WorkoutType.gym, DateTime(2026, 1, 1)).toJson());
    expect(plain.displayTitle, 'Gym workout');
    expect(plain.hasRoute, isFalse);
  });

  test('recorder adds distance, ignores bad readings, and saves a run', () {
    final gps = FakeGps();
    final rec = RunRecorder(source: gps);
    rec.start();
    gps.push!(36.1900, 44.01, 10);
    gps.push!(36.1900, 44.01, 10); // same spot: ignored
    gps.push!(36.1950, 44.01, 200); // too inaccurate: ignored
    gps.push!(36.1950, 44.01, 10);
    gps.push!(36.2000, 44.01, 10);
    expect(rec.points.length, 3);
    expect(rec.distanceM, closeTo(1112, 5));
    final log = rec.finish();
    expect(log, isNotNull);
    expect(log!.source, 'gps');
    expect(log.distanceM, closeTo(1112, 5));
    expect(gps.stopped, isTrue);
    expect(rec.isRecording, isFalse);
    rec.dispose();
  });

  test('recorder returns nothing without a route and reports errors', () {
    final gps = FakeGps();
    final rec = RunRecorder(source: gps);
    rec.start();
    expect(rec.finish(), isNull);
    rec.start();
    gps.fail!('Location is blocked.');
    expect(rec.error, 'Location is blocked.');
    expect(rec.isRecording, isFalse);
    rec.dispose();
  });

  test('filters by type and date', () {
    final now = DateTime(2026, 11, 25, 12);
    final logs = [
      WorkoutLog(WorkoutType.running, DateTime(2026, 11, 24), id: 'a'),
      WorkoutLog(WorkoutType.gym, DateTime(2026, 11, 10), id: 'b'),
      WorkoutLog(WorkoutType.running, DateTime(2026, 3, 1), id: 'c'),
    ];
    List<String> ids(List<WorkoutLog> l) => [for (final x in l) x.id];
    expect(ids(filterRecords(logs, now: now)), ['a', 'b', 'c']);
    expect(ids(filterRecords(logs, type: WorkoutType.running, now: now)),
        ['a', 'c']);
    expect(ids(filterRecords(logs, range: DateRangeFilter.week, now: now)),
        ['a']);
    expect(ids(filterRecords(logs, range: DateRangeFilter.month, now: now)),
        ['a', 'b']);
    expect(ids(filterRecords(logs, range: DateRangeFilter.year, now: now)),
        ['a', 'b', 'c']);
    expect(
        ids(filterRecords(logs,
            range: DateRangeFilter.custom,
            custom: DateTimeRange(
                start: DateTime(2026, 11, 10), end: DateTime(2026, 11, 10)),
            now: now)),
        ['b']);
  });

  test('scene fits points inside the picture and reveals by progress', () {
    const route = [
      GeoPoint(36.19, 44.01),
      GeoPoint(36.195, 44.012),
      GeoPoint(36.20, 44.01),
      GeoPoint(36.205, 44.008),
    ];
    final scene = RouteScene(route);
    final all = scene.flat(720, 100, 1);
    expect(all.length, 4);
    for (final (x, y) in all) {
      expect(x, inInclusiveRange(99, 621));
      expect(y, inInclusiveRange(99, 621));
    }
    expect(scene.flat(720, 100, 0.5).length, 2);
    final t = scene.tilted(720, 90, 1, yaw: 1.2);
    expect(t.base.length, 4);
    for (var i = 0; i < 4; i++) {
      expect(t.top[i].$2, lessThan(t.base[i].$2)); // wall rises up the screen
      expect(t.top[i].$1, t.base[i].$1);
    }
    expect(RouteScene(const []).flat(720, 100, 1), isEmpty);
  });
}
