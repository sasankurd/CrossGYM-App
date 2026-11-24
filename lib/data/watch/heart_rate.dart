/// Heart-rate reading from a Bluetooth watch or strap, plus the pure logic
/// around it (parsing, zones, session stats). No browser code lives here so it
/// can be unit tested.
library;

/// Reads a beats-per-minute value from a standard Bluetooth "Heart Rate
/// Measurement" message. Byte 0 is a flags byte: bit 0 says whether the value
/// is 8 bit (0) or 16 bit little endian (1). Returns null when the message is
/// too short or the value is not a plausible heart rate (30 to 240), which is
/// what many devices send when the sensor has no skin contact.
int? parseHeartRate(List<int> bytes) {
  if (bytes.length < 2) return null;
  final sixteenBit = (bytes[0] & 0x01) != 0;
  final int bpm;
  if (sixteenBit) {
    if (bytes.length < 3) return null;
    bpm = bytes[1] | (bytes[2] << 8);
  } else {
    bpm = bytes[1];
  }
  return (bpm >= 30 && bpm <= 240) ? bpm : null;
}

/// Heart-rate zones as a share of maximum heart rate.
enum HeartZone {
  rest('Resting', 0),
  z1('Zone 1, very light', 1),
  z2('Zone 2, light', 2),
  z3('Zone 3, moderate', 3),
  z4('Zone 4, hard', 4),
  z5('Zone 5, maximum', 5);

  const HeartZone(this.label, this.number);
  final String label;
  final int number;
}

/// The zone for [bpm]. [maxHr] is an estimate (220 minus age), not a measured
/// maximum.
HeartZone zoneFor(int bpm, int maxHr) {
  if (maxHr <= 0) return HeartZone.rest;
  final share = bpm / maxHr;
  if (share < 0.5) return HeartZone.rest;
  if (share < 0.6) return HeartZone.z1;
  if (share < 0.7) return HeartZone.z2;
  if (share < 0.8) return HeartZone.z3;
  if (share < 0.9) return HeartZone.z4;
  return HeartZone.z5;
}

/// Readings from one connection. Kept in memory only.
class HeartRateSession {
  static const int maxRecent = 120;

  /// The latest readings, oldest first, for the live graph.
  final List<int> recent = [];
  int _count = 0;
  int _sum = 0;
  int? min;
  int? max;

  int get count => _count;
  int? get average => _count == 0 ? null : (_sum / _count).round();

  void add(int bpm) {
    recent.add(bpm);
    if (recent.length > maxRecent) recent.removeAt(0);
    _count++;
    _sum += bpm;
    min = (min == null || bpm < min!) ? bpm : min;
    max = (max == null || bpm > max!) ? bpm : max;
  }

  void clear() {
    recent.clear();
    _count = 0;
    _sum = 0;
    min = null;
    max = null;
  }
}

/// Something went wrong connecting, or the person closed the device chooser.
class HeartRateException implements Exception {
  const HeartRateException(this.message, {this.cancelled = false});

  final String message;

  /// True when the person closed the chooser without picking a device.
  final bool cancelled;

  @override
  String toString() => message;
}

/// A source of live heart-rate readings. The web build uses Web Bluetooth;
/// other builds report that they are not supported.
abstract class HeartRateSource {
  /// Whether this browser or device can connect to a heart-rate device.
  bool get isSupported;

  /// Opens the device chooser, connects, and starts sending readings.
  /// Returns the device name. Throws [HeartRateException].
  Future<String> connect({
    required void Function(int bpm) onBpm,
    required void Function() onDisconnected,
  });

  /// Closes the connection. Safe to call when not connected.
  void disconnect();
}
