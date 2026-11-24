import 'package:flutter/foundation.dart';

import 'heart_rate.dart';
import 'heart_rate_source.dart';

enum WatchStatus { idle, connecting, connected }

/// The connection to a heart-rate watch or strap, and its live readings.
///
/// Separate from the main app state because readings arrive every second and
/// only the screens that show them should rebuild.
class WatchLink extends ChangeNotifier {
  WatchLink({HeartRateSource? source})
      : _source = source ?? createHeartRateSource();

  final HeartRateSource _source;
  final HeartRateSession session = HeartRateSession();
  WatchStatus _status = WatchStatus.idle;
  String? _deviceName;
  int? _bpm;
  String? _error;
  bool _disposed = false;

  bool get isSupported => _source.isSupported;
  WatchStatus get status => _status;
  bool get isConnected => _status == WatchStatus.connected;
  String? get deviceName => _deviceName;

  /// The latest reading, or null when not connected or no reading yet.
  int? get bpm => _bpm;

  /// A message to show, or null.
  String? get error => _error;

  Future<void> connect() async {
    if (_status != WatchStatus.idle) return;
    _status = WatchStatus.connecting;
    _error = null;
    _bpm = null;
    session.clear();
    _notify();
    try {
      _deviceName = await _source.connect(
        onBpm: _onBpm,
        onDisconnected: _onDisconnected,
      );
      _status = WatchStatus.connected;
    } on HeartRateException catch (e) {
      _status = WatchStatus.idle;
      _error = e.cancelled ? null : e.message;
    }
    _notify();
  }

  void disconnect() {
    _source.disconnect();
    _status = WatchStatus.idle;
    _bpm = null;
    _error = null;
    _notify();
  }

  void _onBpm(int value) {
    _bpm = value;
    session.add(value);
    _notify();
  }

  void _onDisconnected() {
    if (_status != WatchStatus.connected) return;
    _status = WatchStatus.idle;
    _bpm = null;
    _error = 'The watch disconnected.';
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _source.disconnect();
    super.dispose();
  }
}
