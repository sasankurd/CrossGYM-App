import 'package:flutter/material.dart';

import 'models.dart';

enum Sex {
  male('Male'),
  female('Female');

  const Sex(this.label);
  final String label;
}

enum Goal {
  cut(
    'Lose weight',
    'Eat about 20% less than you burn.',
    -0.20,
    Icons.trending_down,
  ),
  maintain(
    'Maintain weight',
    'Eat about what you burn.',
    0,
    Icons.trending_flat,
  ),
  gain(
    'Gain weight',
    'Eat about 10% more than you burn.',
    0.10,
    Icons.trending_up,
  );

  const Goal(this.label, this.description, this.adjust, this.icon);
  final String label;
  final String description;

  /// Share added to (or removed from) daily calories burned.
  final double adjust;
  final IconData icon;
}

enum Meal {
  breakfast('Breakfast'),
  lunch('Lunch'),
  dinner('Dinner'),
  snack('Snacks');

  const Meal(this.label);
  final String label;

  /// The meal that fits the time of day.
  static Meal forTime(DateTime t) {
    final minutes = t.hour * 60 + t.minute;
    if (minutes < 10 * 60 + 30) return Meal.breakfast;
    if (minutes < 15 * 60) return Meal.lunch;
    if (minutes < 21 * 60) return Meal.dinner;
    return Meal.snack;
  }
}

/// What the person told us in the first-run questions, plus the calorie maths.
///
/// Calories use the Mifflin-St Jeor estimate of resting burn, multiplied by an
/// activity factor taken from weekly training hours. Results are estimates,
/// not medical advice.
class HealthProfile {
  const HealthProfile({
    required this.sex,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.sessionsPerWeek,
    required this.minutesPerSession,
    required this.types,
    required this.goal,
  });

  final Sex sex;
  final int age;
  final int heightCm;
  final double weightKg;
  final int sessionsPerWeek;
  final int minutesPerSession;
  final Set<WorkoutType> types;
  final Goal goal;

  /// Calories burned at rest per day.
  double get bmr =>
      10 * weightKg +
      6.25 * heightCm -
      5 * age +
      (sex == Sex.male ? 5 : -161);

  double get weeklyHours => sessionsPerWeek * minutesPerSession / 60;

  double get activityFactor {
    final h = weeklyHours;
    if (h < 1) return 1.2;
    if (h < 3) return 1.375;
    if (h < 5) return 1.55;
    if (h < 8) return 1.725;
    return 1.9;
  }

  /// Calories burned per day including training and daily movement.
  double get tdee => bmr * activityFactor;

  double get _rawTarget => tdee * (1 + goal.adjust);

  int get _floorKcal => sex == Sex.male ? 1500 : 1200;

  /// True when a weight-loss target was raised to the minimum safe level.
  bool get hitFloor => goal == Goal.cut && _rawTarget < _floorKcal;

  /// Daily calorie target, rounded to the nearest 10.
  int get targetKcal =>
      hitFloor ? _floorKcal : (_rawTarget / 10).round() * 10;

  int get proteinG => (weightKg *
          switch (goal) {
            Goal.cut => 2.0,
            Goal.maintain => 1.6,
            Goal.gain => 1.8,
          })
      .round();

  int get fatG => (targetKcal * 0.25 / 9).round();

  int get carbsG {
    final left = targetKcal - proteinG * 4 - fatG * 9;
    return left <= 0 ? 0 : (left / 4).round();
  }

  HealthProfile copyGoal(Goal newGoal) => HealthProfile(
        sex: sex,
        age: age,
        heightCm: heightCm,
        weightKg: weightKg,
        sessionsPerWeek: sessionsPerWeek,
        minutesPerSession: minutesPerSession,
        types: types,
        goal: newGoal,
      );

  Map<String, dynamic> toJson() => {
        'sex': sex.name,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'sessions': sessionsPerWeek,
        'minutes': minutesPerSession,
        'types': [for (final t in types) t.name],
        'goal': goal.name,
      };

  factory HealthProfile.fromJson(Map<String, dynamic> j) => HealthProfile(
        sex: Sex.values.byName(j['sex'] as String),
        age: j['age'] as int,
        heightCm: j['heightCm'] as int,
        weightKg: (j['weightKg'] as num).toDouble(),
        sessionsPerWeek: j['sessions'] as int,
        minutesPerSession: j['minutes'] as int,
        types: {
          for (final n in j['types'] as List<dynamic>)
            WorkoutType.values.byName(n as String),
        },
        goal: Goal.values.byName(j['goal'] as String),
      );
}

/// One logged food.
class FoodEntry {
  const FoodEntry({
    required this.id,
    required this.name,
    required this.kcal,
    required this.meal,
    required this.at,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  final String id;
  final String name;
  final int kcal;
  final double protein;
  final double carbs;
  final double fat;
  final Meal meal;
  final DateTime at;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'kcal': kcal,
        'p': protein,
        'c': carbs,
        'f': fat,
        'meal': meal.name,
        'at': at.toIso8601String(),
      };

  factory FoodEntry.fromJson(Map<String, dynamic> j) => FoodEntry(
        id: j['id'] as String,
        name: j['name'] as String,
        kcal: j['kcal'] as int,
        protein: (j['p'] as num).toDouble(),
        carbs: (j['c'] as num).toDouble(),
        fat: (j['f'] as num).toDouble(),
        meal: Meal.values.byName(j['meal'] as String),
        at: DateTime.parse(j['at'] as String),
      );
}

/// A food in the quick-add list. Values are approximate.
class FoodItem {
  const FoodItem(
    this.name,
    this.serving,
    this.kcal,
    this.protein,
    this.carbs,
    this.fat,
  );

  final String name;
  final String serving;
  final int kcal;
  final double protein;
  final double carbs;
  final double fat;
}

const List<FoodItem> kFoods = [
  FoodItem('Egg', '1 large', 72, 6.3, 0.4, 4.8),
  FoodItem('Chicken breast', '100 g cooked', 165, 31, 0, 3.6),
  FoodItem('Rice', '1 cup cooked', 205, 4.3, 45, 0.4),
  FoodItem('Oats', '40 g dry', 150, 5, 27, 2.6),
  FoodItem('Banana', '1 medium', 105, 1.3, 27, 0.4),
  FoodItem('Apple', '1 medium', 95, 0.5, 25, 0.3),
  FoodItem('Whole milk', '1 cup', 150, 8, 12, 8),
  FoodItem('Greek yogurt, plain', '170 g', 100, 17, 6, 0.7),
  FoodItem('Bread', '1 slice', 80, 3, 15, 1),
  FoodItem('Olive oil', '1 tablespoon', 119, 0, 0, 13.5),
  FoodItem('Peanut butter', '1 tablespoon', 94, 4, 3.2, 8),
  FoodItem('Almonds', '28 g', 164, 6, 6, 14),
  FoodItem('Salmon', '100 g cooked', 206, 22, 0, 12),
  FoodItem('Lean ground beef', '100 g cooked', 217, 26, 0, 12),
  FoodItem('Tuna in water', '100 g', 116, 26, 0, 1),
  FoodItem('Lentils', '1 cup cooked', 230, 18, 40, 0.8),
  FoodItem('Potato', '1 medium baked', 161, 4.3, 37, 0.2),
  FoodItem('Pasta', '1 cup cooked', 220, 8, 43, 1.3),
  FoodItem('Whey protein', '1 scoop', 120, 24, 3, 1.5),
  FoodItem('Dates', '2 Medjool', 133, 1, 36, 0.1),
  FoodItem('Hummus', '2 tablespoons', 70, 2, 4, 5),
  FoodItem('Cheddar cheese', '28 g', 113, 7, 0.4, 9),
];

/// 2450 -> "2,450".
String formatInt(int n) => n.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
