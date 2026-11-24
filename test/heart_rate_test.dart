import 'package:crossgym/data/watch/heart_rate.dart';
import 'package:crossgym/data/watch/watch_link.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeSource implements HeartRateSource {
  FakeSource({this.fail});

  final HeartRateException? fail;
  void Function(int bpm)? push;
  void Function()? drop;

  @override
  bool get isSupported => true;

  @override
  Future<String> connect({
    required void Function(int bpm) onBpm,
    required void Function() onDisconnected,
  }) async {
    if (fail != null) throw fail!;
    push = onBpm;
    drop = onDisconnected;
    return 'Test strap';
  }

  @override
  void disconnect() {}
}

void main() {
  test('parses 8 bit and 16 bit heart-rate messages', () {
    expect(parseHeartRate([0, 72]), 72);
    expect(parseHeartRate([1, 0x96, 0x00]), 150);
    expect(parseHeartRate([0, 0]), isNull);
    expect(parseHeartRate([1, 0x2C, 0x01]), isNull); // 300 is not plausible
    expect(parseHeartRate([0]), isNull);
    expect(parseHeartRate([1, 0x96]), isNull);
  });

  test('zones follow share of max heart rate', () {
    expect(zoneFor(90, 190), HeartZone.rest);
    expect(zoneFor(110, 190), HeartZone.z1);
    expect(zoneFor(120, 190), HeartZone.z2);
    expect(zoneFor(140, 190), HeartZone.z3);
    expect(zoneFor(160, 190), HeartZone.z4);
    expect(zoneFor(175, 190), HeartZone.z5);
  });

  test('session tracks min, average, max and keeps a bounded history', () {
    final s = HeartRateSession()..add(100)..add(120)..add(140);
    expect(s.min, 100);
    expect(s.max, 140);
    expect(s.average, 120);
    for (var i = 0; i < 200; i++) {
      s.add(130);
    }
    expect(s.recent.length, HeartRateSession.maxRecent);
    s.clear();
    expect(s.average, isNull);
  });

  test('watch link connects, receives readings and reports a drop', () async {
    final source = FakeSource();
    final link = WatchLink(source: source);
    await link.connect();
    expect(link.isConnected, isTrue);
    expect(link.deviceName, 'Test strap');
    source.push!(130);
    expect(link.bpm, 130);
    expect(link.session.max, 130);
    source.drop!();
    expect(link.isConnected, isFalse);
    expect(link.error, 'The watch disconnected.');
    link.dispose();
  });

  test('closing the chooser is not an error; a failure shows a message',
      () async {
    final cancelled = WatchLink(
        source: FakeSource(
            fail: const HeartRateException('', cancelled: true)));
    await cancelled.connect();
    expect(cancelled.status, WatchStatus.idle);
    expect(cancelled.error, isNull);

    final failed = WatchLink(
        source: FakeSource(fail: const HeartRateException('No signal.')));
    await failed.connect();
    expect(failed.error, 'No signal.');
    cancelled.dispose();
    failed.dispose();
  });
}
