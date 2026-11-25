import 'dart:async';

import 'package:flutter/foundation.dart';

import '../geo.dart';
import '../models.dart';
import '../watch/watch_link.dart';
import 'gps_source.dart';

/// Records a run from GPS positions. While a watch is connected it also
/// averages its heart rate over the run.
class RunRecorder extends ChangeNotifier {
  RunRecorder({
    required GpsSource source,
    WatchLink? watch,
    DateTime Function()? now,
  })  : _source = source,
        _watch = watch,
        _now = now ?? DateTime.now;

  /// Readings less accurate than this (in meters) are ignored.
  static const double maxAccuracyM = 50;

  /// Moves smaller than this (in meters) are treated as standing still.
  static const double minStepM = 3;

  final GpsSource _source;
  final WatchLink? _watch;
  final DateTime Function() _now;

  final List<GeoPoint> points = [];
  double distanceM = 0;
  int elapsedSec = 0;
  DateTime? startedAt;
  String? error;
  bool _recording = false;
  Timer? _timer;
  int _hrSum = 0;
  int _hrCount = 0;
  int _lastSessionCount = 0;
  bool _disposed = false;

  bool get isRecording => _recording;
  bool get isSupported => _source.isSupported;

  void start() {
    if (_recording) return;
    points.clear();
    distanceM = 0;
    elapsedSec = 0;
    error = null;
    _hrSum = 0;
    _hrCount = 0;
    _lastSessionCount = _watch?.session.count ?? 0;
    startedAt = _now();
    _recording = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsedSec = _now().difference(startedAt!).inSeconds;
      _notify();
    });
    _watch?.addListener(_onWatch);
    _source.start(onPoint: _onPoint, onError: _onError);
    _notify();
  }

  void _onPoint(double lat, double lon, double accuracyM) {
    if (!_recording || accuracyM > maxAccuracyM) return;
    final p = GeoPoint(lat, lon);
    if (points.isNotEmpty) {
      final step = haversineM(points.last, p);
      if (step < minStepM) return;
      distanceM += step;
    }
    points.add(p);
    _notify();
  }

  void _onError(String message) {
    error = message;
    _halt();
    _notify();
  }

  void _onWatch() {
    final w = _watch;
    if (w == null || !_recording) return;
    final bpm = w.bpm;
    if (bpm != null && w.session.count != _lastSessionCount) {
      _lastSessionCount = w.session.count;
      _hrSum += bpm;
      _hrCount++;
    }
  }

  void _halt() {
    _recording = false;
    _timer?.cancel();
    _timer = null;
    _watch?.removeListener(_onWatch);
    _source.stop();
  }

  /// Stops and throws the recording away.
  void discard() {
    _halt();
    points.clear();
    distanceM = 0;
    _notify();
  }

  /// Stops and returns the run, or null when there is no route yet.
  WorkoutLog? finish() {
    if (!_recording) return null;
    final started = startedAt ?? _now();
    final seconds = _now().difference(started).inSeconds;
    _halt();
    if (points.length < 2) {
      _notify();
      return null;
    }
    final log = WorkoutLog(
      WorkoutType.running,
      started,
      id: 'w${started.microsecondsSinceEpoch}',
      title: 'Run',
      durationSec: seconds,
      distanceM: distanceM,
      avgHr: _hrCount == 0 ? null : (_hrSum / _hrCount).round(),
      route: thinRoute(points),
      source: 'gps',
    );
    elapsedSec = seconds;
    _notify();
    return log;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _halt();
    super.dispose();
  }
}
