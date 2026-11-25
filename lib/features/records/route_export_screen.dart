import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';
import '../../data/export/route_scene.dart';
import '../../data/export/route_video.dart';
import '../../data/export/route_video_factory.dart';
import '../../data/format.dart';
import '../../data/models.dart';

/// Turns a run into a short 2D or 3D video the person can save or share.
class RouteExportScreen extends StatefulWidget {
  const RouteExportScreen({super.key, required this.log});

  final WorkoutLog log;

  @override
  State<RouteExportScreen> createState() => _RouteExportScreenState();
}

class _RouteExportScreenState extends State<RouteExportScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
      vsync: this, duration: const Duration(seconds: 12))
    ..repeat();
  RouteVideoStyle _style = RouteVideoStyle.flat;
  bool _busy = false;
  String? _error;
  RouteVideo? _video;

  WorkoutLog get _log => widget.log;

  String get _stats {
    final d = _log.distanceM, s = _log.durationSec;
    return [
      if (d != null) '${formatKm(d)} km',
      if (s != null) formatDuration(s),
      if (d != null && s != null) formatPace(d, s),
    ].join('   ');
  }

  String get _message =>
      '${_log.displayTitle} on ${formatDate(_log.at)}: $_stats. Tracked with CrossGYM.';

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  Future<void> _make() async {
    setState(() {
      _busy = true;
      _error = null;
      _video = null;
    });
    try {
      final v = await renderRouteVideo(RouteVideoSpec(
        route: _log.route,
        title: _log.displayTitle,
        stats: _stats,
        style: _style,
      ));
      if (!mounted) return;
      setState(() => _video = v);
    } on Object {
      if (!mounted) return;
      setState(() => _error =
          'The video could not be made in this browser. Try Chrome, Edge or '
          'Safari, and keep this page open while it records.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareVideo() async {
    final messenger = ScaffoldMessenger.of(context);
    final out = await _video!.share(_message);
    if (!mounted) return;
    if (out == ShareOutcome.unsupported) {
      _video!.save();
      messenger.showSnackBar(const SnackBar(
          content: Text('Sharing files is not supported here, so the video '
              'was saved to your device instead.')));
    }
  }

  Future<void> _shareText() async {
    final messenger = ScaffoldMessenger.of(context);
    final out = await shareText(_log.displayTitle, _message);
    if (!mounted || out != ShareOutcome.unsupported) return;
    await Clipboard.setData(ClipboardData(text: _message));
    messenger.showSnackBar(
        const SnackBar(content: Text('Summary copied. Paste it anywhere.')));
  }

  @override
  Widget build(BuildContext context) {
    final scene = RouteScene(_log.route);
    return Scaffold(
      appBar: AppBar(title: const Text('Export run')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            SubTabs(
              labels: [for (final s in RouteVideoStyle.values) s.label],
              index: _style.index,
              onChanged: (i) =>
                  setState(() => _style = RouteVideoStyle.values[i]),
            ),
            const SizedBox(height: 14),
            AspectRatio(
              aspectRatio: 1,
              child: Panel(
                child: AnimatedBuilder(
                  animation: _spin,
                  builder: (context, _) => CustomPaint(
                    painter: _PreviewPainter(
                      scene,
                      _style,
                      _spin.value,
                      Theme.of(context).colorScheme,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _style == RouteVideoStyle.flat
                  ? 'Top-down view. The route draws itself, then holds.'
                  : 'Tilted view that slowly turns. The height is for looks '
                      'only, not real elevation.',
              style:
                  const TextStyle(fontSize: 12, color: AppColors.gray400),
            ),
            const SizedBox(height: 16),
            if (!canRenderVideo)
              const NeoCard(
                child: Text(
                  'This browser cannot record video. You can still share the '
                  'run as text.',
                  style: TextStyle(color: AppColors.gray300, height: 1.4),
                ),
              )
            else
              FilledButton.icon(
                onPressed: _busy ? null : _make,
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.movie_creation_outlined),
                label: Text(_busy
                    ? 'Recording... keep this page open'
                    : 'Create ${_style.label} video'),
              ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.coral)),
            ],
            if (_video != null) ...[
              const SizedBox(height: 14),
              NeoCard(
                accent: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Video ready  -  ${_video!.megabytes.toStringAsFixed(1)} MB',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (_video!.mime.startsWith('video/webm'))
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'WebM plays in most apps and browsers. Some iPhone '
                          'apps cannot open it.',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.gray400),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: _shareVideo,
                          icon: const Icon(Icons.ios_share),
                          label: const Text('Share video'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _video!.save,
                          icon: const Icon(Icons.download),
                          label: const Text('Save to device'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _shareText,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Share summary as text'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewPainter extends CustomPainter {
  _PreviewPainter(this.scene, this.style, this.t, this.scheme);

  final RouteScene scene;
  final RouteVideoStyle style;
  final double t;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height);
    Path path(List<ScreenPoint> p) {
      final r = Path();
      for (var i = 0; i < p.length; i++) {
        i == 0 ? r.moveTo(p[i].$1, p[i].$2) : r.lineTo(p[i].$1, p[i].$2);
      }
      return r;
    }

    Paint stroke(Color c, double w) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (style == RouteVideoStyle.flat) {
      canvas.drawPath(path(scene.flat(side, side * 0.15, 1)),
          stroke(scheme.secondary, 4));
    } else {
      final s = scene.tilted(side, side * 0.12, 1, yaw: 0.6 + t * 2 * math.pi);
      for (var i = 1; i < s.base.length; i++) {
        final wall = Path()
          ..moveTo(s.base[i - 1].$1, s.base[i - 1].$2)
          ..lineTo(s.base[i].$1, s.base[i].$2)
          ..lineTo(s.top[i].$1, s.top[i].$2)
          ..lineTo(s.top[i - 1].$1, s.top[i - 1].$2)
          ..close();
        canvas.drawPath(wall,
            Paint()..color = scheme.secondary.withValues(alpha: 0.22));
      }
      canvas.drawPath(path(s.base), stroke(Colors.white24, 2));
      canvas.drawPath(path(s.top), stroke(scheme.primary, 3));
    }
  }

  @override
  bool shouldRepaint(_PreviewPainter old) =>
      old.t != t || old.style != style || old.scene != scene;
}
