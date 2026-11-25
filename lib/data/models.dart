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

/// A point on a map, in degrees.
class GeoPoint {
  const GeoPoint(this.lat, this.lon);

  final double lat;
  final double lon;

  /// Stored as [lat, lon] rounded to 5 decimals (about one meter).
  List<double> toJson() => [_round5(lat), _round5(lon)];

  factory GeoPoint.fromJson(List<dynamic> j) =>
      GeoPoint((j[0] as num).toDouble(), (j[1] as num).toDouble());

  static double _round5(double v) => (v * 100000).round() / 100000;
}

/// One logged workout. Only [type] and [at] are always known; runs recorded
/// with GPS or imported from a watch also carry distance, time and a route.
class WorkoutLog {
  const WorkoutLog(
    this.type,
    this.at, {
    this.id = '',
    this.title,
    this.durationSec,
    this.distanceM,
    this.avgHr,
    this.route = const <GeoPoint>[],
    this.source = 'logged',
  });

  final WorkoutType type;
  final DateTime at;
  final String id;
  final String? title;
  final int? durationSec;
  final double? distanceM;
  final int? avgHr;
  final List<GeoPoint> route;

  /// logged (tapped Log workout), plan (finished a plan day), gps (recorded
  /// in the app) or watch (imported from a watch file).
  final String source;

  String get displayTitle => title ?? '${type.label} workout';
  bool get hasRoute => route.length >= 2;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'at': at.toIso8601String(),
        if (title != null) 'title': title,
        if (durationSec != null) 'dur': durationSec,
        if (distanceM != null) 'dist': distanceM,
        if (avgHr != null) 'hr': avgHr,
        if (route.isNotEmpty) 'route': [for (final p in route) p.toJson()],
        'src': source,
      };

  factory WorkoutLog.fromJson(Map<String, dynamic> j) => WorkoutLog(
        WorkoutType.values.byName(j['type'] as String),
        DateTime.parse(j['at'] as String),
        id: (j['id'] as String?) ?? '',
        title: j['title'] as String?,
        durationSec: (j['dur'] as num?)?.toInt(),
        distanceM: (j['dist'] as num?)?.toDouble(),
        avgHr: (j['hr'] as num?)?.toInt(),
        route: [
          for (final p in (j['route'] as List<dynamic>? ?? const []))
            GeoPoint.fromJson(p as List<dynamic>),
        ],
        source: (j['src'] as String?) ?? 'logged',
      );
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
