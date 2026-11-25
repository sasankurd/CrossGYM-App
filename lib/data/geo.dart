/// Distance maths for routes.
library;

import 'dart:math' as math;

import 'models.dart';

/// Great-circle distance between two points, in meters.
double haversineM(GeoPoint a, GeoPoint b) {
  const earthRadiusM = 6371000.0;
  double rad(double deg) => deg * math.pi / 180;
  final dLat = rad(b.lat - a.lat);
  final dLon = rad(b.lon - a.lon);
  final h = math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.lat)) * math.cos(rad(b.lat)) * math.pow(math.sin(dLon / 2), 2);
  return 2 * earthRadiusM * math.asin(math.min(1, math.sqrt(h)));
}

/// Length of a route in meters.
double routeDistanceM(List<GeoPoint> points) {
  var total = 0.0;
  for (var i = 1; i < points.length; i++) {
    total += haversineM(points[i - 1], points[i]);
  }
  return total;
}

/// Keeps at most [max] points, evenly spaced, always including the first and
/// last, so a saved route stays small.
List<GeoPoint> thinRoute(List<GeoPoint> points, {int max = 300}) {
  if (points.length <= max || max < 2) return List.of(points);
  final step = (points.length - 1) / (max - 1);
  return [for (var i = 0; i < max; i++) points[(i * step).round()]];
}
