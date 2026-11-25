import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'gps_source.dart';

/// Reads positions with the browser's Geolocation feature.
GpsSource createGpsSource() => _WebGps();

class _WebGps implements GpsSource {
  int? _watchId;

  JSObject? get _geolocation {
    final nav = globalContext.getProperty<JSAny?>('navigator'.toJS);
    if (nav == null) return null;
    final geo = (nav as JSObject).getProperty<JSAny?>('geolocation'.toJS);
    return geo == null ? null : geo as JSObject;
  }

  @override
  bool get isSupported => _geolocation != null;

  @override
  void start({
    required void Function(double lat, double lon, double accuracyM) onPoint,
    required void Function(String message) onError,
  }) {
    final geo = _geolocation;
    if (geo == null) {
      onError('This browser cannot give a location.');
      return;
    }
    stop();
    final success = ((JSObject position) {
      final c = position.getProperty<JSObject>('coords'.toJS);
      onPoint(
        c.getProperty<JSNumber>('latitude'.toJS).toDartDouble,
        c.getProperty<JSNumber>('longitude'.toJS).toDartDouble,
        c.getProperty<JSNumber>('accuracy'.toJS).toDartDouble,
      );
    }).toJS;
    final failure = ((JSObject error) {
      final code = error.getProperty<JSNumber>('code'.toJS).toDartInt;
      onError(switch (code) {
        1 => 'Location is blocked. Allow location for this site in the '
            'browser settings, then try again.',
        2 => 'Your position is not available right now. Try going outside.',
        _ => 'Finding your position took too long. Try again.',
      });
    }).toJS;
    final options = {
      'enableHighAccuracy': true,
      'maximumAge': 0,
      'timeout': 20000,
    }.jsify();
    _watchId = geo
        .callMethod<JSNumber>('watchPosition'.toJS, success, failure, options)
        .toDartInt;
  }

  @override
  void stop() {
    final id = _watchId;
    final geo = _geolocation;
    if (id != null && geo != null) {
      geo.callMethod<JSAny?>('clearWatch'.toJS, id.toJS);
    }
    _watchId = null;
  }
}
