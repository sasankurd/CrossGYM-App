import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'heart_rate.dart';

/// Connects to a heart-rate device with Web Bluetooth (Chrome and Edge).
HeartRateSource createHeartRateSource() => _WebHeartRate();

class _WebHeartRate implements HeartRateSource {
  JSObject? _device;
  JSObject? _characteristic;
  JSFunction? _onValue;
  JSFunction? _onGone;

  JSObject? get _bluetooth {
    final nav = globalContext.getProperty<JSAny?>('navigator'.toJS);
    if (nav == null) return null;
    final bt = (nav as JSObject).getProperty<JSAny?>('bluetooth'.toJS);
    return bt == null ? null : bt as JSObject;
  }

  @override
  bool get isSupported => _bluetooth != null;

  @override
  Future<String> connect({
    required void Function(int bpm) onBpm,
    required void Function() onDisconnected,
  }) async {
    final bluetooth = _bluetooth;
    if (bluetooth == null) {
      throw const HeartRateException(
          'This browser cannot connect to Bluetooth devices.');
    }
    disconnect();
    try {
      final options = {
        'filters': [
          {
            'services': ['heart_rate'],
          },
        ],
      }.jsify();
      final device = await bluetooth
          .callMethod<JSPromise<JSAny?>>('requestDevice'.toJS, options)
          .toDart as JSObject;
      final gatt = device.getProperty<JSObject>('gatt'.toJS);
      final server = await gatt
          .callMethod<JSPromise<JSAny?>>('connect'.toJS)
          .toDart as JSObject;
      final service = await server
          .callMethod<JSPromise<JSAny?>>(
              'getPrimaryService'.toJS, 'heart_rate'.toJS)
          .toDart as JSObject;
      final characteristic = await service
          .callMethod<JSPromise<JSAny?>>(
              'getCharacteristic'.toJS, 'heart_rate_measurement'.toJS)
          .toDart as JSObject;

      final onValue = ((JSObject event) {
        final target = event.getProperty<JSObject>('target'.toJS);
        final view = target.getProperty<JSObject>('value'.toJS);
        final length = view.getProperty<JSNumber>('byteLength'.toJS).toDartInt;
        final bytes = <int>[
          for (var i = 0; i < length && i < 4; i++)
            view.callMethod<JSNumber>('getUint8'.toJS, i.toJS).toDartInt,
        ];
        final bpm = parseHeartRate(bytes);
        if (bpm != null) onBpm(bpm);
      }).toJS;
      final onGone = ((JSObject event) {
        onDisconnected();
      }).toJS;

      characteristic.callMethod<JSAny?>(
          'addEventListener'.toJS, 'characteristicvaluechanged'.toJS, onValue);
      device.callMethod<JSAny?>(
          'addEventListener'.toJS, 'gattserverdisconnected'.toJS, onGone);
      await characteristic
          .callMethod<JSPromise<JSAny?>>('startNotifications'.toJS)
          .toDart;

      _device = device;
      _characteristic = characteristic;
      _onValue = onValue;
      _onGone = onGone;
      return device.getProperty<JSString?>('name'.toJS)?.toDart ??
          'Heart-rate device';
    } on HeartRateException {
      rethrow;
    } catch (e) {
      final text = e.toString();
      disconnect();
      if (text.contains('NotFoundError') &&
          (text.contains('cancel') || text.contains('chosen'))) {
        throw const HeartRateException('', cancelled: true);
      }
      if (text.contains('No Services matching') ||
          text.contains('not found')) {
        throw const HeartRateException(
            'That device does not share heart rate. Turn on heart-rate '
            'broadcast on the watch and try again.');
      }
      throw const HeartRateException(
          'Could not connect. Keep the watch close, make sure heart-rate '
          'broadcast is on, and try again.');
    }
  }

  @override
  void disconnect() {
    final device = _device;
    final characteristic = _characteristic;
    try {
      if (characteristic != null && _onValue != null) {
        characteristic.callMethod<JSAny?>('removeEventListener'.toJS,
            'characteristicvaluechanged'.toJS, _onValue);
      }
      if (device != null && _onGone != null) {
        device.callMethod<JSAny?>('removeEventListener'.toJS,
            'gattserverdisconnected'.toJS, _onGone);
      }
      if (device != null) {
        final gatt = device.getProperty<JSObject?>('gatt'.toJS);
        gatt?.callMethod<JSAny?>('disconnect'.toJS);
      }
    } catch (_) {
      // Already closed by the device.
    }
    _device = null;
    _characteristic = null;
    _onValue = null;
    _onGone = null;
  }
}
