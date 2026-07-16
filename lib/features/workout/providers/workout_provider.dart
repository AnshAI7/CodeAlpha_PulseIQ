import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/workout.dart';

/// Single source of truth for workout data. Screens read from and
/// write to this provider — never touch Hive.box directly from a widget.
class WorkoutProvider extends ChangeNotifier {
  final Box<Workout> _box = Hive.box<Workout>('workoutBox');

  /// Most recent workout first.
  List<Workout> get workouts {
    final all = _box.values.toList();
    all.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return all;
  }

  Future<void> addWorkout(Workout workout) async {
    await _box.add(workout);
    notifyListeners();
  }

  Future<void> deleteWorkout(Workout workout) async {
    // Works directly on the object, no need to search the box for its
    // key first — Workout extends HiveObject, which means Hive already
    // tracks which box/key this exact instance came from.
    await workout.delete();
    notifyListeners();
  }

  /// Sum of calories burned across all logged workouts today.
  int get todayCaloriesBurned => _todayTotal((w) => w.caloriesBurned);

  /// Sum of minutes exercised across all logged workouts today.
  int get todayWorkoutMinutes => _todayTotal((w) => w.durationMinutes);

  /// Number of workout sessions logged today.
  /// _todayTotal normally SUMS a value per workout — passing a function
  /// that always returns 1 turns "sum" into "count" for free, without
  /// writing a separate loop just to count entries.
  int get todayWorkoutCount => _todayTotal((_) => 1);
  // Shared by todayCaloriesBurned/todayWorkoutMinutes/todayWorkoutCount —
  // all three needed the exact same "filter to today, then combine"
  // logic, just with a different value being combined each time.
  int _todayTotal(int Function(Workout) valueOf) {
    final now = DateTime.now();
    return workouts
        .where(
          (w) =>
              w.dateTime.year == now.year &&
              w.dateTime.month == now.month &&
              w.dateTime.day == now.day,
        )
        .fold(0, (sum, w) => sum + valueOf(w));
  }

  /// Total calories burned per day for the last 7 days (oldest first, today last).
  /// Feeds the Analytics "Calories Burned" chart.
  List<int> get weeklyCaloriesBurned => _weeklyTotals((w) => w.caloriesBurned);

  /// Total minutes exercised per day for the last 7 days (oldest first, today last).
  /// Feeds the Analytics "Workout Minutes" chart.
  List<int> get weeklyWorkoutMinutes => _weeklyTotals((w) => w.durationMinutes);

  // Same pattern as _todayTotal, just bucketed by day instead of
  // filtered to a single day — this is what let weeklyCaloriesBurned
  // and weeklyWorkoutMinutes both exist without duplicating the
  // 7-day-window loop twice.
  List<int> _weeklyTotals(int Function(Workout) valueOf) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - i));
      return workouts
          .where(
            (w) =>
                w.dateTime.year == day.year &&
                w.dateTime.month == day.month &&
                w.dateTime.day == day.day,
          )
          .fold(0, (sum, w) => sum + valueOf(w));
    });
  }
}
