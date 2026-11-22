import 'package:flutter/material.dart';

enum WorkoutType {
  running('Running', Icons.directions_run),
  gym('Gym', Icons.fitness_center),
  crossfit('CrossFit', Icons.bolt),
  pilates('Pilates', Icons.self_improvement),
  recovery('Recovery', Icons.spa);

  const WorkoutType(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// One exercise. [slug] is also the file name of its drawing in assets/art.
class Exercise {
  const Exercise(this.slug, this.type);

  final String slug;
  final WorkoutType type;

  String get name => slug
      .split('-')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.handle,
    required this.bio,
    required this.city,
    this.followers = 0,
    this.workouts = 0,
  });

  final String id;
  final String name;
  final String handle;
  final String bio;
  final String city;

  /// Followers shown on the profile (seed value for other users).
  int followers;
  int workouts;
}

class Plan {
  const Plan({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.weeks,
    required this.priceUsd,
    required this.sellerId,
  });

  final String id;
  final String title;
  final String description;
  final WorkoutType type;
  final int weeks;

  /// 0 means free.
  final double priceUsd;
  final String sellerId;

  String get priceLabel =>
      priceUsd == 0 ? 'Free' : '\$${priceUsd.toStringAsFixed(2)}';
}

class ChatMessage {
  const ChatMessage({
    required this.fromId,
    required this.text,
    required this.sentAt,
  });

  final String fromId;
  final String text;
  final DateTime sentAt;
}

class Achievement {
  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.goal,
    required this.progress,
  });

  final String title;
  final String description;
  final IconData icon;
  final int goal;
  final int progress;

  bool get unlocked => progress >= goal;
  double get fraction => (progress / goal).clamp(0.0, 1.0);
}
