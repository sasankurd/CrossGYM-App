import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/models.dart';
import 'tokens.dart';

/// JetBrains Mono, used for reps, weights, timers, percentages and badges.
TextStyle mono({
  double size = 13,
  FontWeight weight = FontWeight.w600,
  Color color = AppColors.text,
}) =>
    GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: weight, color: color);

/// Accent color for each workout type.
Color typeColor(BuildContext context, WorkoutType t) {
  final scheme = Theme.of(context).colorScheme;
  return switch (t) {
    WorkoutType.running => scheme.secondary,
    WorkoutType.gym => scheme.primary,
    WorkoutType.crossfit => AppColors.amber,
    WorkoutType.pilates => const Color(0xFFA78BFA),
    WorkoutType.recovery => const Color(0xFF2DD4BF),
  };
}

String ago(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'now';
  if (d.inMinutes < 60) return '${d.inMinutes}m';
  if (d.inHours < 24) return '${d.inHours}h';
  return '${d.inDays}d';
}

/// Liquid glass: a frosted, translucent surface with a bright specular edge.
///
/// [tint] paints a two-colour glass gradient instead of plain white glass.
/// [glow] draws a solid coloured edge and glow (used for selected items).
/// With [blur] false the surface only draws a light fill, which is cheaper and
/// right for glass nested inside glass.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.radius = 24,
    this.sigma = 18,
    this.tint,
    this.strong = false,
    this.glow,
    this.blur = true,
    this.fill,
  });

  final Widget child;
  final double radius;
  final double sigma;
  final List<Color>? tint;
  final bool strong;
  final Color? glow;
  final bool blur;
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    final colors = tint ??
        [
          Colors.white.withValues(alpha: strong ? 0.16 : 0.11),
          Colors.white.withValues(alpha: strong ? 0.06 : 0.04),
        ];
    Widget body = CustomPaint(
      foregroundPainter: _GlassEdgePainter(radius: radius, glow: glow),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          gradient: fill == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                )
              : null,
          borderRadius: shape,
        ),
        child: child,
      ),
    );
    if (blur) {
      body = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: body,
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [
          BoxShadow(
            color: (glow ?? Colors.black).withValues(alpha: glow == null ? 0.22 : 0.35),
            blurRadius: glow == null ? 24 : 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(borderRadius: shape, child: body),
    );
  }
}

class _GlassEdgePainter extends CustomPainter {
  _GlassEdgePainter({required this.radius, this.glow});

  final double radius;
  final Color? glow;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect =
        RRect.fromRectAndRadius(rect, Radius.circular(radius)).deflate(0.6);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    if (glow != null) {
      edge.color = glow!;
    } else {
      edge.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.50),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.03),
          Colors.white.withValues(alpha: 0.28),
        ],
        stops: const [0, 0.35, 0.65, 1],
      ).createShader(rect);
    }
    canvas.drawRRect(rrect, edge);

    // Bright specular line along the top edge.
    final inset = radius * 0.8;
    if (size.width > inset * 2 + 8) {
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.6),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(
          Rect.fromLTWH(inset, 0, size.width - inset * 2, 1),
        );
      canvas.drawLine(Offset(inset, 1), Offset(size.width - inset, 1), line);
    }
  }

  @override
  bool shouldRepaint(covariant _GlassEdgePainter old) =>
      old.radius != radius || old.glow != glow;
}

/// Soft colour glow behind the whole app. This is what the glass blurs, and it
/// follows the selected anime theme.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    super.key,
    required this.primary,
    required this.secondary,
    required this.child,
  });

  final Color primary;
  final Color secondary;
  final Widget child;

  Widget _orb({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
    required double alpha,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: alpha),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: AppColors.canvas)),
        _orb(top: -140, left: -100, size: 440, color: primary, alpha: 0.42),
        _orb(top: 240, right: -170, size: 460, color: secondary, alpha: 0.30),
        _orb(bottom: -180, left: -90, size: 480, color: primary, alpha: 0.26),
        _orb(bottom: 140, right: -110, size: 320, color: secondary, alpha: 0.16),
        Positioned.fill(child: child),
      ],
    );
  }
}

/// Top padding for scrolling pages so content starts below the floating header
/// but can still scroll underneath it.
double contentTop(BuildContext context) =>
    MediaQuery.paddingOf(context).top + 80;

/// Glass card. [accent] tints it with the theme colours, [selected] draws the
/// primary edge and glow. A custom [color] makes it a light nested tile.
class NeoCard extends StatelessWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.accent = false,
    this.selected = false,
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool accent;
  final bool selected;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final nested = color != null;
    return GlassSurface(
      radius: radius,
      blur: !nested,
      fill: color,
      tint: accent && !nested
          ? [
              scheme.primary.withValues(alpha: 0.22),
              scheme.secondary.withValues(alpha: 0.10),
            ]
          : null,
      glow: selected ? scheme.primary : null,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          hoverColor: Colors.white.withValues(alpha: 0.04),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Small mono badge.
class Pill extends StatelessWidget {
  const Pill(this.text,
      {super.key, this.color = AppColors.gray300, this.icon});

  final String text;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(text, style: mono(size: 11, color: color)),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: mono(size: 10, weight: FontWeight.w500, color: AppColors.gray400)
          .copyWith(letterSpacing: 1.2),
    );
  }
}

/// Horizontal sub-tab switcher.
class SubTabs extends StatelessWidget {
  const SubTabs({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: i == index
                        ? primary.withValues(alpha: 0.14)
                        : AppColors.glassFill,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: i == index ? primary : AppColors.hairline,
                    ),
                    boxShadow: i == index
                        ? [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.35),
                              blurRadius: 14,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    labels[i],
                    style: mono(
                      size: 12,
                      color: i == index ? primary : AppColors.gray300,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GradientAvatar extends StatelessWidget {
  const GradientAvatar({super.key, required this.initial, this.size = 48});

  final String initial;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [scheme.primary, scheme.secondary]),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.35),
            blurRadius: 14,
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.card,
        child: Text(
          initial.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w800,
            fontSize: size * 0.38,
            color: AppColors.text,
          ),
        ),
      ),
    );
  }
}

/// Circular progress ring with a mono percentage in the middle.
class ReadinessRing extends StatelessWidget {
  const ReadinessRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 96,
  });

  final double value;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size(size, size), painter: _RingPainter(value, color)),
          Text(
            '${(value * 100).round()}%',
            style: mono(size: size * 0.22, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color);

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke,
        size.height - stroke);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.hairline;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color;
}
