import 'dart:math' as math;
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/models.dart';
import 'tokens.dart';

/// Inter in tabular figures (every digit the same width), used for reps,
/// weights, timers, percentages and badges.
TextStyle mono({
  double size = 13,
  FontWeight weight = FontWeight.w600,
  Color color = AppColors.text,
}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

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

/// A flat dark panel: solid fill, one-pixel faint edge, no blur.
///
/// [borderColor] replaces the faint edge (used for accent and selected
/// panels). [fill] replaces the card color.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.radius = 20,
    this.fill,
    this.borderColor,
    this.borderWidth = 1,
  });

  final Widget child;
  final double radius;
  final Color? fill;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill ?? AppColors.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? AppColors.hairline,
          width: borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - borderWidth),
        child: child,
      ),
    );
  }
}

/// The flat black background behind the whole app.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: AppColors.canvas, child: child);
  }
}

/// Top padding for scrolling pages. The shell already keeps content below the
/// status bar, so this is just breathing room.
double contentTop(BuildContext context) => 12;

/// Title row at the top of a tab: optional small kicker, a heavy title, and
/// trailing actions.
class TabHeader extends StatelessWidget {
  const TabHeader({
    super.key,
    required this.title,
    this.kicker,
    this.trailing = const [],
  });

  final String title;
  final String? kicker;
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (kicker != null)
                  Text(
                    kicker!,
                    style: mono(size: 11, weight: FontWeight.w700, color: primary)
                        .copyWith(letterSpacing: 1.4),
                  ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          for (final w in trailing) ...[const SizedBox(width: 8), w],
        ],
      ),
    );
  }
}

/// Flat card. [accent] gives it a faint primary edge, [selected] a full
/// primary edge and tint. A custom [color] makes it a nested tile.
class NeoCard extends StatelessWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
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
    return Panel(
      radius: radius,
      fill: color ??
          (selected
              ? Color.alphaBlend(
                  scheme.primary.withValues(alpha: 0.08), AppColors.card)
              : null),
      borderColor: selected
          ? scheme.primary
          : accent
              ? scheme.primary.withValues(alpha: 0.28)
              : null,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          hoverColor: Colors.white.withValues(alpha: 0.03),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text.toUpperCase(),
            style: mono(size: 11, weight: FontWeight.w700, color: color)
                .copyWith(letterSpacing: 0.4),
          ),
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
      style: mono(size: 11, weight: FontWeight.w700, color: AppColors.gray300)
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
    if (labels.length <= 4) {
      // Segmented switcher: one panel, the active segment filled.
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.hairline),
        ),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i == index,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == index ? primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        labels[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: i == index
                              ? AppColors.canvas
                              : AppColors.gray300,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }
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
      ),
      child: CircleAvatar(
        backgroundColor: AppColors.card,
        child: Text(
          initial.toUpperCase(),
          style: GoogleFonts.inter(
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
    this.label,
    this.caption,
  });

  final double value;
  final Color color;
  final double size;

  /// Small text under the middle label (for example "READY").
  final String? caption;

  /// Text in the middle. Shows the percentage when null.
  final String? label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size(size, size), painter: _RingPainter(value, color)),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label ?? '${(value * 100).round()}%',
                style: mono(size: size * 0.22, weight: FontWeight.w800),
              ),
              if (caption != null)
                Text(
                  caption!,
                  style: mono(
                    size: size * 0.095,
                    weight: FontWeight.w600,
                    color: AppColors.gray300,
                  ).copyWith(letterSpacing: 1.1),
                ),
            ],
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
      ..color = AppColors.container;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 3 / 2,
        colors: [AppColors.cyan, color],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value || old.color != color;
}

/// The CrossGYM logo tile: a gradient square with a "C".
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 3),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.secondary],
        ),
      ),
      child: Center(
        child: Text(
          'C',
          style: GoogleFonts.inter(
            fontSize: size * 0.55,
            fontWeight: FontWeight.w900,
            color: AppColors.canvas,
          ),
        ),
      ),
    );
  }
}
