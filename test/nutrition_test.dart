import 'package:crossgym/data/models.dart';
import 'package:crossgym/data/nutrition.dart';
import 'package:flutter_test/flutter_test.dart';

HealthProfile profile({
  Sex sex = Sex.male,
  int age = 30,
  int height = 180,
  double weight = 80,
  int sessions = 4,
  int minutes = 60,
  Goal goal = Goal.maintain,
}) =>
    HealthProfile(
      sex: sex,
      age: age,
      heightCm: height,
      weightKg: weight,
      sessionsPerWeek: sessions,
      minutesPerSession: minutes,
      types: {WorkoutType.gym},
      goal: goal,
    );

void main() {
  test('maintain target equals calories burned', () {
    final p = profile();
    expect(p.bmr, 1780);
    expect(p.activityFactor, 1.55);
    expect(p.targetKcal, 2760);
    expect(p.proteinG, 128);
    expect(p.fatG, 77);
    expect(p.carbsG, 389);
  });

  test('gain adds 10% and cut removes 20%', () {
    expect(profile(goal: Goal.gain).targetKcal, 3030);
    expect(profile(goal: Goal.cut).targetKcal, 2210);
    expect(profile(goal: Goal.cut).proteinG, 160);
  });

  test('female formula and a lighter training week', () {
    final p = profile(
      sex: Sex.female,
      age: 25,
      height: 165,
      weight: 60,
      sessions: 2,
      minutes: 45,
    );
    expect(p.bmr, 1345.25);
    expect(p.activityFactor, 1.375);
    expect(p.targetKcal, 1850);
    expect(p.copyGoal(Goal.cut).targetKcal, 1480);
  });

  test('weight loss never goes below the minimum', () {
    final p = profile(
      sex: Sex.female,
      age: 40,
      height: 150,
      weight: 45,
      sessions: 0,
      goal: Goal.cut,
    );
    expect(p.hitFloor, isTrue);
    expect(p.targetKcal, 1200);
  });

  test('profile survives a JSON round trip', () {
    final p = profile(goal: Goal.gain);
    final back = HealthProfile.fromJson(p.toJson());
    expect(back.targetKcal, p.targetKcal);
    expect(back.types, p.types);
    expect(back.goal, Goal.gain);
  });

  test('food entry survives a JSON round trip', () {
    final entry = FoodEntry(
      id: 'a',
      name: 'Egg',
      kcal: 72,
      protein: 6.3,
      meal: Meal.breakfast,
      at: DateTime(2026, 11, 24, 8),
    );
    final back = FoodEntry.fromJson(entry.toJson());
    expect(back.kcal, 72);
    expect(back.meal, Meal.breakfast);
    expect(back.at, entry.at);
  });

  test('meal follows the time of day', () {
    expect(Meal.forTime(DateTime(2026, 1, 1, 8)), Meal.breakfast);
    expect(Meal.forTime(DateTime(2026, 1, 1, 13)), Meal.lunch);
    expect(Meal.forTime(DateTime(2026, 1, 1, 19)), Meal.dinner);
    expect(Meal.forTime(DateTime(2026, 1, 1, 22)), Meal.snack);
  });

  test('formatInt adds thousands separators', () {
    expect(formatInt(2450), '2,450');
    expect(formatInt(950), '950');
    expect(formatInt(1234567), '1,234,567');
  });
}
