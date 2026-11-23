import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../core/widgets.dart';

class Metric {
  const Metric(this.label, this.value);

  final String label;
  final String value;
}

/// Gradient profile card with live metrics, used for you and for other users.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.handle,
    required this.bio,
    required this.metrics,
    this.subtitle = '',
    this.actions,
  });

  final String name;
  final String handle;
  final String bio;
  final String subtitle;
  final List<Metric> metrics;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return NeoCard(
      accent: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientAvatar(initial: name[0], size: 72),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: text.headlineSmall),
                    Text(
                      '@$handle',
                      style: mono(
                        size: 12,
                        weight: FontWeight.w500,
                        color: AppColors.gray400,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: text.bodySmall?.copyWith(color: AppColors.gray400),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(bio, style: text.bodyMedium?.copyWith(color: AppColors.gray300)),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final m in metrics)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.value,
                        style: mono(size: 20, weight: FontWeight.w700),
                      ),
                      SectionLabel(m.label),
                    ],
                  ),
                ),
            ],
          ),
          if (actions != null) ...[
            const SizedBox(height: 16),
            actions!,
          ],
        ],
      ),
    );
  }
}
