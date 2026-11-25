import 'gps_source.dart';

/// Used where the browser location feature does not exist.
GpsSource createGpsSource() => _UnsupportedGps();

class _UnsupportedGps implements GpsSource {
  @override
  bool get isSupported => false;

  @override
  void start({
    required void Function(double lat, double lon, double accuracyM) onPoint,
    required void Function(String message) onError,
  }) =>
      onError('Location is not available here.');

  @override
  void stop() {}
}
