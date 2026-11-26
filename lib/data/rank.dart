/// Ranks earned from achievement points.
library;

import 'package:flutter/material.dart';

enum RankTier {
  rookie('Rookie', 0, Color(0xFF8A95A5), Icons.directions_walk),
  bronze('Bronze', 30, Color(0xFFCD7F32), Icons.shield_outlined),
  silver('Silver', 90, Color(0xFFC0C8D4), Icons.shield),
  gold('Gold', 180, Color(0xFFFFB020), Icons.workspace_premium),
  platinum('Platinum', 300, Color(0xFF00F0FF), Icons.military_tech),
  diamond('Diamond', 450, Color(0xFF8B5CF6), Icons.diamond),
  master('Master', 600, Color(0xFFC8FF00), Icons.emoji_events);

  const RankTier(this.label, this.minPoints, this.color, this.icon);

  final String label;
  final int minPoints;
  final Color color;
  final IconData icon;

  static RankTier forPoints(int points) {
    var best = RankTier.rookie;
    for (final t in RankTier.values) {
      if (points >= t.minPoints) best = t;
    }
    return best;
  }

  /// The next rank up, or null at the top.
  RankTier? get next =>
      index + 1 < RankTier.values.length ? RankTier.values[index + 1] : null;

  /// 0 to 1 progress from this rank toward the next one.
  double progress(int points) {
    final n = next;
    if (n == null) return 1;
    return ((points - minPoints) / (n.minPoints - minPoints)).clamp(0.0, 1.0);
  }
}
