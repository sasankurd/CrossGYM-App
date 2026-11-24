import 'package:flutter/material.dart';

/// Fixed colors of the "CrossGym OS" look: a near-black void, flat dark
/// cards with a faint white edge, and four signal colors. The accent pair
/// (primary and secondary) comes from the selected [AnimeTheme]; by default
/// primary is volt (lime) and secondary is cyan.
class AppColors {
  AppColors._();

  static const Color canvas = Color(0xFF06080D); // the void
  static const Color header = Color(0xF006080D);
  static const Color card = Color(0xFF0E131D); // surface card
  static const Color container = Color(0xFF151C2B); // elevated surface
  static const Color input = Color(0xFF151C2B);
  static const Color inputRaised = Color(0xFF151C2B);

  static const Color glassFill = Color(0xFF151C2B); // nested tiles
  static const Color sheet = Color(0xFF0E131D); // bottom sheets

  static const Color volt = Color(0xFFC8FF00); // primary action, gym
  static const Color cyan = Color(0xFF00F0FF); // telemetry, running
  static const Color coral = Color(0xFFFF3366); // heart rate, calories
  static const Color violet = Color(0xFF8B5CF6); // marketplace

  static const Color emerald = volt; // readiness, completion
  static const Color amber = Color(0xFFFFB020); // CrossFit, PRs, stars
  static const Color orange = Color(0xFFFF7A1A); // streaks
  static const Color rose = coral; // likes, delete, errors

  static const Color text = Color(0xFFF4F7FB);
  static const Color gray300 = Color(0xFF8A95A5); // secondary text
  static const Color gray400 = Color(0xFF6F7B8C); // muted text

  static const Color hairline = Color(0x14FFFFFF); // white at 8%
  static const Color hairlineStrong = Color(0x29FFFFFF); // white at 16%
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
  AnimeTheme('Volt Cyan', Color(0xFFC8FF00), Color(0xFF00F0FF)),
  AnimeTheme('Sakura Voltage', Color(0xFFF04FAD), Color(0xFF00F0FF)),
  AnimeTheme('Naruto', Color(0xFFFF7A1A), Color(0xFF2F6BFF)),
  AnimeTheme('One Piece', Color(0xFFE63946), Color(0xFFFFC53D)),
  AnimeTheme('Dragon Ball', Color(0xFFFF9F1C), Color(0xFF3BA7FF)),
  AnimeTheme('Demon Slayer', Color(0xFF22C55E), Color(0xFF14B8A6)),
  AnimeTheme('Jujutsu Kaisen', Color(0xFF7C5CFF), Color(0xFF38BDF8)),
];
