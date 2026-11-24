import 'heart_rate.dart';

/// Used where Web Bluetooth does not exist (anything but the web build).
HeartRateSource createHeartRateSource() => _UnsupportedHeartRate();

class _UnsupportedHeartRate implements HeartRateSource {
  @override
  bool get isSupported => false;

  @override
  Future<String> connect({
    required void Function(int bpm) onBpm,
    required void Function() onDisconnected,
  }) =>
      Future.error(const HeartRateException(
          'Heart-rate connection is not available here.'));

  @override
  void disconnect() {}
}
