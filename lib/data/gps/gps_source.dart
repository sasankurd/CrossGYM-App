/// A source of GPS positions. The web build uses the browser's location
/// feature; other builds report that they are not supported.
library;

abstract class GpsSource {
  /// Whether this browser or device can give a position.
  bool get isSupported;

  /// Starts sending positions. [onError] gets a plain-language message.
  void start({
    required void Function(double lat, double lon, double accuracyM) onPoint,
    required void Function(String message) onError,
  });

  /// Stops sending positions. Safe to call when not started.
  void stop();
}
