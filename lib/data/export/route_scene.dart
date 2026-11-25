/// Turns a route into screen points for a flat (2D) or tilted, turning (3D)
/// picture. Pure maths, so it is the same in the preview and in the video.
library;

import 'dart:math' as math;

import '../models.dart';

/// A screen position.
typedef ScreenPoint = (double x, double y);

class RouteScene {
  RouteScene(List<GeoPoint> route) : _m = _toMeters(route) {
    var minX = double.infinity, maxX = -double.infinity;
    var minY = double.infinity, maxY = -double.infinity;
    for (final (x, y) in _m) {
      minX = math.min(minX, x);
      maxX = math.max(maxX, x);
      minY = math.min(minY, y);
      maxY = math.max(maxY, y);
    }
    _cx = _m.isEmpty ? 0 : (minX + maxX) / 2;
    _cy = _m.isEmpty ? 0 : (minY + maxY) / 2;
    _spanX = _m.isEmpty ? 1 : math.max(maxX - minX, 1);
    _spanY = _m.isEmpty ? 1 : math.max(maxY - minY, 1);
    var r = 1.0;
    for (final (x, y) in _m) {
      r = math.max(r, math.sqrt(math.pow(x - _cx, 2) + math.pow(y - _cy, 2)));
    }
    _radius = r;
  }

  final List<(double, double)> _m;
  late final double _cx, _cy, _spanX, _spanY, _radius;

  int get length => _m.length;

  static List<(double, double)> _toMeters(List<GeoPoint> r) {
    if (r.isEmpty) return const [];
    final lat0 = r.first.lat;
    final lon0 = r.first.lon;
    final k = math.cos(lat0 * math.pi / 180);
    return [
      for (final p in r)
        ((p.lon - lon0) * 111320 * k, (p.lat - lat0) * 110540),
    ];
  }

  int _count(double progress) {
    if (_m.isEmpty) return 0;
    final n = (_m.length * progress.clamp(0.0, 1.0)).ceil();
    return math.max(math.min(2, _m.length), n);
  }

  /// Top-down view fitted inside a square of [size] with [pad] around it,
  /// showing the first [progress] share of the route.
  List<ScreenPoint> flat(double size, double pad, double progress) {
    final scale = (size - 2 * pad) / math.max(_spanX, _spanY);
    return [
      for (var i = 0; i < _count(progress); i++)
        (
          size / 2 + (_m[i].$1 - _cx) * scale,
          size / 2 - (_m[i].$2 - _cy) * scale,
        ),
    ];
  }

  /// A tilted view turned by [yaw] radians. [tilt] is the camera angle
  /// (0 looks along the ground, pi/2 looks straight down). The route is lifted
  /// into a wall [heightFraction] of its width tall. The height is for looks
  /// only: it is not real elevation.
  ({List<ScreenPoint> base, List<ScreenPoint> top}) tilted(
    double size,
    double pad,
    double progress, {
    required double yaw,
    double tilt = 0.9,
    double heightFraction = 0.12,
  }) {
    final scale = (size / 2 - pad) / _radius;
    final cosY = math.cos(yaw), sinY = math.sin(yaw);
    final lift = _radius * heightFraction * scale * math.cos(tilt) * 2;
    final base = <ScreenPoint>[];
    final top = <ScreenPoint>[];
    for (var i = 0; i < _count(progress); i++) {
      final dx = _m[i].$1 - _cx, dy = _m[i].$2 - _cy;
      final rx = dx * cosY - dy * sinY;
      final ry = dx * sinY + dy * cosY;
      final sx = size / 2 + rx * scale;
      final sy = size / 2 + size * 0.08 - ry * scale * math.sin(tilt);
      base.add((sx, sy));
      top.add((sx, sy - lift));
    }
    return (base: base, top: top);
  }
}
