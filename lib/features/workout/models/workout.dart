import 'package:hive/hive.dart';

part 'workout.g.dart';

/// A single logged workout session. Each field maps to a @HiveField
/// index — once real data exists in the box, these index numbers must
/// never change or get reused for a different field; that corrupts
/// existing saved records.
///
/// typeId: 0 — the first Hive model built in this app. Meal (1),
/// WaterEntry (2), and FoodEntry (3) all had to pick different numbers
/// once they existed, since a typeId collision between two models
/// silently corrupts data instead of throwing a clear error.
@HiveType(typeId: 0)
class Workout extends HiveObject {
  @HiveField(0)
  final String exerciseType;

  @HiveField(1)
  final int durationMinutes;

  @HiveField(2)
  final int caloriesBurned;

  @HiveField(3)
  final DateTime dateTime;

  Workout({
    required this.exerciseType,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.dateTime,
  });
}
