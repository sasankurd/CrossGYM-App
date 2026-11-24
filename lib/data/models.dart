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
/// [sub] is the sub-category shown as a pill in the exercise picker.
class Exercise {
  const Exercise(this.slug, this.type, this.sub);

  final String slug;
  final WorkoutType type;
  final String sub;

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
  String name;
  String handle;
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

/// One logged workout session.
class WorkoutLog {
  const WorkoutLog(this.type, this.at);

  final WorkoutType type;
  final DateTime at;
}

enum MedalTier {
  bronze('Bronze'),
  silver('Silver'),
  gold('Gold'),
  diamond('Diamond');

  const MedalTier(this.label);
  final String label;
}

class Achievement {
  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.goal,
    required this.progress,
    required this.tier,
  });

  final String title;
  final String description;
  final IconData icon;
  final int goal;
  final int progress;
  final MedalTier tier;

  bool get unlocked => progress >= goal;
  double get fraction => progress >= goal ? 1.0 : progress / goal;
}

/// One set inside a planned exercise.
class SetEntry {
  SetEntry({this.reps = 10, this.kg = 0});

  int reps;
  double kg;
}

class PlannedExercise {
  PlannedExercise({required this.id, required this.exercise})
      : sets = [SetEntry(), SetEntry(), SetEntry()];

  final int id;
  final Exercise exercise;
  final List<SetEntry> sets;

  /// Whether the sets are revealed (the star is on).
  bool open = false;
}

/// A named weekly training program: exercises for each day (0 = Monday).
class Program {
  Program({required this.id, required this.name, this.description = ''})
      : days = {for (var i = 0; i < 7; i++) i: <PlannedExercise>[]};

  final String id;
  String name;
  String description;
  final Map<int, List<PlannedExercise>> days;

  int get exerciseCount => days.values.fold(0, (sum, l) => sum + l.length);
  int get trainingDays => days.values.where((l) => l.isNotEmpty).length;
}

enum AttachmentKind { plan, pr }

class PostAttachment {
  const PostAttachment({
    required this.kind,
    required this.title,
    required this.detail,
  });

  final AttachmentKind kind;
  final String title;
  final String detail;
}

class Post {
  const Post({
    required this.id,
    required this.authorId,
    required this.text,
    required this.createdAt,
    this.attachment,
    this.baseLikes = 0,
  });

  final String id;
  final String authorId;
  final String text;
  final DateTime createdAt;
  final PostAttachment? attachment;
  final int baseLikes;
}
