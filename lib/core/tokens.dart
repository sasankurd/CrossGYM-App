import 'package:flutter/material.dart';

/// Fixed colors of the "Hybrid Neo-Tokyo" look. The accent pair (primary and
/// secondary) is not fixed: it comes from the selected [AnimeTheme].
class AppColors {
  AppColors._();

  static const Color canvas = Color(0xFF0D0B18);
  static const Color header = Color(0xE6100E1D); // 90% opacity
  static const Color card = Color(0xFF141228);
  static const Color container = Color(0xFF121024);
  static const Color input = Color(0xFF100E1D);
  static const Color inputRaised = Color(0xFF16132B);

  static const Color glassFill = Color(0x14FFFFFF); // white at 8%
  static const Color sheet = Color(0xF0141228); // bottom sheets

  static const Color emerald = Color(0xFF10B981); // readiness, completion
  static const Color amber = Color(0xFFF59E0B); // CrossFit, PRs, stars
  static const Color orange = Color(0xFFF97316); // streaks
  static const Color rose = Color(0xFFF43F5E); // likes, delete

  static const Color text = Color(0xFFF3F4F6);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);

  static const Color hairline = Color(0x1AFFFFFF); // white at 10%
  static const Color hairlineStrong = Color(0x33FFFFFF); // white at 20%
}

/// A swappable primary and secondary accent pair.
class AnimeTheme {
  const AnimeTheme(this.name, this.primary, this.secondary);

  final String name;
  final Color primary;
  final Color secondary;

  /// Soft outer glow used behind selected items and the brand mark.
  Color get glow => primary.withValues(alpha: 0.35);
}

const List<AnimeTheme> kAnimeThemes = [
  AnimeTheme('Sakura Voltage', Color(0xFFF04FAD), Color(0xFF00F0FF)),
  AnimeTheme('Naruto', Color(0xFFFF7A1A), Color(0xFF2F6BFF)),
  AnimeTheme('One Piece', Color(0xFFE63946), Color(0xFFFFC53D)),
  AnimeTheme('Dragon Ball', Color(0xFFFF9F1C), Color(0xFF3BA7FF)),
  AnimeTheme('Demon Slayer', Color(0xFF22C55E), Color(0xFF14B8A6)),
  AnimeTheme('Jujutsu Kaisen', Color(0xFF7C5CFF), Color(0xFF38BDF8)),
];
