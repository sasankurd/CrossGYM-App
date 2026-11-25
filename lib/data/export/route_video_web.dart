import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math' as math;

import 'route_scene.dart';
import 'route_video.dart';

@JS('MediaRecorder')
extension type _Recorder._(JSObject _) implements JSObject {
  external factory _Recorder(JSObject stream, JSObject options);
  external void start();
  external void stop();
  external set ondataavailable(JSFunction f);
  external set onstop(JSFunction f);
  external static bool isTypeSupported(String type);
}

@JS('Blob')
extension type _Blob._(JSObject _) implements JSObject {
  external factory _Blob(JSArray<JSAny?> parts, JSObject options);
  external double get size;
}

@JS('File')
extension type _File._(JSObject _) implements JSObject {
  external factory _File(JSArray<JSAny?> parts, String name, JSObject options);
}

const _mimes = ['video/webm;codecs=vp9', 'video/webm', 'video/mp4'];
const _fps = 30;
const _px = 720.0;

bool get canRenderVideo =>
    globalContext.has('MediaRecorder') &&
    _mimes.any((m) => _Recorder.isTypeSupported(m));

JSObject _options(Map<String, Object?> m) => m.jsify()! as JSObject;

/// Draws the route onto a hidden canvas frame by frame and records it.
Future<RouteVideo> renderRouteVideo(RouteVideoSpec spec) async {
  if (!canRenderVideo) {
    throw UnsupportedError('This browser cannot record video.');
  }
  final mime = _mimes.firstWhere(_Recorder.isTypeSupported);
  final doc = globalContext.getProperty<JSObject>('document'.toJS);
  final canvas =
      doc.callMethodVarArgs<JSObject>('createElement'.toJS, ['canvas'.toJS]);
  canvas.setProperty('width'.toJS, _px.toJS);
  canvas.setProperty('height'.toJS, _px.toJS);
  final ctx = _Ctx(
      canvas.callMethodVarArgs<JSObject>('getContext'.toJS, ['2d'.toJS]));
  final scene = RouteScene(spec.route);

  final stream =
      canvas.callMethodVarArgs<JSObject>('captureStream'.toJS, [_fps.toJS]);
  final recorder = _Recorder(stream, _options({'mimeType': mime}));
  final chunks = <JSAny?>[];
  final stopped = Completer<void>();
  recorder.ondataavailable = ((JSObject e) {
    final data = e.getProperty<JSObject>('data'.toJS);
    if (data.getProperty<JSNumber>('size'.toJS).toDartDouble > 0) {
      chunks.add(data);
    }
  }).toJS;
  recorder.onstop = (() {
    if (!stopped.isCompleted) stopped.complete();
  }).toJS;

  final drawFrames = spec.seconds * _fps;
  const holdFrames = _fps;
  var frame = 0;
  _draw(ctx, scene, spec, 0, 0);
  recorder.start();
  final timer = Timer.periodic(
    const Duration(milliseconds: 1000 ~/ _fps),
    (t) {
      frame++;
      final progress = math.min(1.0, frame / drawFrames);
      _draw(ctx, scene, spec, progress, frame / (drawFrames + holdFrames));
      if (frame >= drawFrames + holdFrames) {
        t.cancel();
        recorder.stop();
      }
    },
  );
  try {
    await stopped.future;
  } finally {
    timer.cancel();
  }
  final blob = _Blob(chunks.toJS, _options({'type': mime}));
  return _WebVideo(blob, mime);
}

class _WebVideo implements RouteVideo {
  _WebVideo(this._blob, this.mime);

  final _Blob _blob;
  @override
  final String mime;

  @override
  String get fileName =>
      'crossgym-run.${mime.startsWith('video/mp4') ? 'mp4' : 'webm'}';

  @override
  double get megabytes => _blob.size / (1024 * 1024);

  @override
  void save() {
    final url = globalContext
        .getProperty<JSObject>('URL'.toJS)
        .callMethodVarArgs<JSString>('createObjectURL'.toJS, [_blob])
        .toDart;
    final doc = globalContext.getProperty<JSObject>('document'.toJS);
    final a = doc.callMethodVarArgs<JSObject>('createElement'.toJS, ['a'.toJS]);
    a.setProperty('href'.toJS, url.toJS);
    a.setProperty('download'.toJS, fileName.toJS);
    a.callMethodVarArgs<JSAny?>('click'.toJS);
    Timer(const Duration(seconds: 30), () {
      globalContext
          .getProperty<JSObject>('URL'.toJS)
          .callMethodVarArgs<JSAny?>('revokeObjectURL'.toJS, [url.toJS]);
    });
  }

  @override
  Future<ShareOutcome> share(String message) async {
    final file = _File(<JSAny?>[_blob].toJS, fileName, _options({'type': mime}));
    final data = JSObject();
    data.setProperty('files'.toJS, <JSAny?>[file].toJS);
    data.setProperty('text'.toJS, message.toJS);
    return _share(data, checkFiles: true);
  }
}

Future<ShareOutcome> shareText(String title, String text) {
  final data = JSObject();
  data.setProperty('title'.toJS, title.toJS);
  data.setProperty('text'.toJS, text.toJS);
  return _share(data, checkFiles: false);
}

Future<ShareOutcome> _share(JSObject data, {required bool checkFiles}) async {
  final nav = globalContext.getProperty<JSObject>('navigator'.toJS);
  if (!nav.has('share')) return ShareOutcome.unsupported;
  if (checkFiles) {
    if (!nav.has('canShare')) return ShareOutcome.unsupported;
    final ok =
        nav.callMethodVarArgs<JSBoolean>('canShare'.toJS, [data]).toDart;
    if (!ok) return ShareOutcome.unsupported;
  }
  try {
    await nav.callMethodVarArgs<JSPromise<JSAny?>>('share'.toJS, [data]).toDart;
    return ShareOutcome.shared;
  } on Object catch (e) {
    return e.toString().contains('AbortError')
        ? ShareOutcome.cancelled
        : ShareOutcome.unsupported;
  }
}

// ---- drawing -------------------------------------------------------------------

class _Ctx {
  _Ctx(this.o);
  final JSObject o;

  void call(String m, [List<double> a = const []]) =>
      o.callMethodVarArgs<JSAny?>(m.toJS, [for (final v in a) v.toJS]);
  void style(String p, String v) => o.setProperty(p.toJS, v.toJS);
  void num(String p, double v) => o.setProperty(p.toJS, v.toJS);
  void text(String s, double x, double y) =>
      o.callMethodVarArgs<JSAny?>('fillText'.toJS, [s.toJS, x.toJS, y.toJS]);

  void line(List<ScreenPoint> pts) {
    if (pts.length < 2) return;
    call('beginPath');
    call('moveTo', [pts.first.$1, pts.first.$2]);
    for (final p in pts.skip(1)) {
      call('lineTo', [p.$1, p.$2]);
    }
    call('stroke');
  }
}

void _draw(_Ctx c, RouteScene scene, RouteVideoSpec spec, double progress,
    double turn) {
  c.style('fillStyle', '#06080D');
  c.call('fillRect', [0, 0, _px, _px]);
  c.style('strokeStyle', 'rgba(255,255,255,0.05)');
  c.num('lineWidth', 1);
  for (var g = 60.0; g < _px; g += 60) {
    c.line([(g, 0), (g, _px)]);
    c.line([(0, g), (_px, g)]);
  }
  c.style('lineCap', 'round');
  c.style('lineJoin', 'round');

  late final List<ScreenPoint> head;
  if (spec.style == RouteVideoStyle.flat) {
    final pts = scene.flat(_px, 110, progress);
    c.style('strokeStyle', '#00F0FF');
    c.num('lineWidth', 7);
    c.line(pts);
    head = pts;
  } else {
    final s = scene.tilted(_px, 90, progress, yaw: 0.6 + turn * math.pi);
    c.style('strokeStyle', 'rgba(255,255,255,0.18)');
    c.num('lineWidth', 4);
    c.line(s.base);
    c.style('fillStyle', 'rgba(0,240,255,0.22)');
    for (var i = 1; i < s.base.length; i++) {
      c.call('beginPath');
      c.call('moveTo', [s.base[i - 1].$1, s.base[i - 1].$2]);
      c.call('lineTo', [s.base[i].$1, s.base[i].$2]);
      c.call('lineTo', [s.top[i].$1, s.top[i].$2]);
      c.call('lineTo', [s.top[i - 1].$1, s.top[i - 1].$2]);
      c.call('closePath');
      c.call('fill');
    }
    c.style('strokeStyle', '#C8FF00');
    c.num('lineWidth', 6);
    c.line(s.top);
    head = s.top;
  }
  if (head.isNotEmpty) {
    c.style('fillStyle', '#FF3366');
    c.call('beginPath');
    c.call('arc', [head.last.$1, head.last.$2, 11, 0, math.pi * 2]);
    c.call('fill');
  }
  c.style('fillStyle', '#FFFFFF');
  c.style('font', '700 34px Inter, Arial, sans-serif');
  c.text(spec.title, 40, 70);
  c.style('fillStyle', '#8A95A5');
  c.style('font', '500 26px Inter, Arial, sans-serif');
  c.text(spec.stats, 40, _px - 40);
  c.style('fillStyle', '#C8FF00');
  c.style('font', '800 24px Inter, Arial, sans-serif');
  c.style('textAlign', 'right');
  c.text('CROSSGYM', _px - 40, 70);
  c.style('textAlign', 'left');
}
