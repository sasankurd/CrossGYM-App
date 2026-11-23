import 'dart:math' as math;

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

/// Elevated card. [accent] paints the primary and secondary gradient,
/// [selected] draws the primary border with a soft glow.
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
    final base = color ?? AppColors.card;
    final shape = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        color: accent ? null : base,
        gradient: accent
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(scheme.primary.withValues(alpha: 0.14), base),
                  Color.alphaBlend(
                      scheme.secondary.withValues(alpha: 0.07), base),
                ],
              )
            : null,
        borderRadius: shape,
        border: Border.all(
          color: selected ? scheme.primary : AppColors.hairline,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.35),
                  blurRadius: 18,
                ),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: shape,
          onTap: onTap,
          hoverColor: Colors.white.withValues(alpha: 0.03),
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
                        : AppColors.container,
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
