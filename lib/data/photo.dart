/// Shrinks photos before they are saved, so they stay small in the browser.
library;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Decodes [bytes] and returns a PNG. With [square] the picture is cropped to
/// its centre square of [size] pixels (profile photos); otherwise it keeps its
/// shape with the longest side at most [maxSide] (post photos).
/// Throws when the bytes are not a picture.
Future<Uint8List> shrinkImage(
  Uint8List bytes, {
  bool square = false,
  int size = 256,
  int maxSide = 640,
}) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final img = frame.image;
  final w = img.width.toDouble(), h = img.height.toDouble();
  late final ui.Rect src;
  late final int outW, outH;
  if (square) {
    final side = w < h ? w : h;
    src = ui.Rect.fromLTWH((w - side) / 2, (h - side) / 2, side, side);
    outW = outH = size;
  } else {
    src = ui.Rect.fromLTWH(0, 0, w, h);
    final longest = w > h ? w : h;
    final scale = longest > maxSide ? maxSide / longest : 1.0;
    outW = (w * scale).round().clamp(1, 100000);
    outH = (h * scale).round().clamp(1, 100000);
  }
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawImageRect(
    img,
    src,
    ui.Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble()),
    ui.Paint()..filterQuality = FilterQuality.high,
  );
  final out = await recorder.endRecording().toImage(outW, outH);
  final data = await out.toByteData(format: ui.ImageByteFormat.png);
  img.dispose();
  codec.dispose();
  return data!.buffer.asUint8List();
}
