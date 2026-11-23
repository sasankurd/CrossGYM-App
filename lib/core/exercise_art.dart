import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_drawing/path_drawing.dart';

/// Draws an exercise illustration from `assets/art/<slug>.txt`.
///
/// Each file holds one SVG path per line (one line per pose). The art comes
/// from GymMane / Workout Guide / Everkinetic under CC BY-SA 4.0, see
/// CREDITS.md. With [animate] the poses cycle, otherwise the first is shown.
class ExerciseArt extends StatefulWidget {
  const ExerciseArt({
    super.key,
    required this.slug,
    this.size = 96,
    this.animate = false,
  });

  final String slug;
  final double size;
  final bool animate;

  @override
  State<ExerciseArt> createState() => _ExerciseArtState();
}

class _ExerciseArtState extends State<ExerciseArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Future<List<Path>> _frames;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _frames = _load(widget.slug);
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(covariant ExerciseArt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      _frames = _load(widget.slug);
    }
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static Future<List<Path>> _load(String slug) async {
    final raw = await rootBundle.loadString('assets/art/$slug.txt');
    final lines = raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
    return [
      for (final d in lines)
        parseSvgPathData(d)..fillType = PathFillType.evenOdd,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FutureBuilder<List<Path>>(
        future: _frames,
        builder: (context, snapshot) {
          final frames = snapshot.data;
          if (frames == null || frames.isEmpty) {
            return Icon(
              snapshot.hasError ? Icons.image_not_supported : Icons.image,
              color: color.withValues(alpha: 0.3),
            );
          }
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final index = widget.animate
                  ? (_controller.value * frames.length)
                      .floor()
                      .clamp(0, frames.length - 1)
                  : 0;
              return CustomPaint(
                painter: _ArtPainter(frames, index, color),
              );
            },
          );
        },
      ),
    );
  }
}

class _ArtPainter extends CustomPainter {
  _ArtPainter(this.frames, this.index, this.color);

  final List<Path> frames;
  final int index;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // Use one shared box so poses stay aligned when they cycle.
    var bounds = frames.first.getBounds();
    for (final f in frames.skip(1)) {
      bounds = bounds.expandToInclude(f.getBounds());
    }
    if (bounds.isEmpty) return;
    final scale = (size.width / bounds.width) < (size.height / bounds.height)
        ? size.width / bounds.width
        : size.height / bounds.height;
    final dx = (size.width - bounds.width * scale) / 2 - bounds.left * scale;
    final dy = (size.height - bounds.height * scale) / 2 - bounds.top * scale;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);
    canvas.drawPath(frames[index], Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ArtPainter old) =>
      old.index != index || old.color != color || old.frames != frames;
}
