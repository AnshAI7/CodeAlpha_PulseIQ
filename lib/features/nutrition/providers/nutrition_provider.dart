import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/meal.dart';
import '../models/water_entry.dart';

/// Single source of truth for nutrition data — meals and water intake.
/// Wraps two separate Hive boxes (different data shapes) but exposes
/// one unified provider, since the Nutrition tab shows both together.
/// the screen shouldn't need to know or care that 2 boxes exist underneath.
class NutritionProvider extends ChangeNotifier {
  // mealBoxV2, not mealBox — renamed when Meal's schema changed from a
  // single food per meal to a List<FoodEntry>. Old data under the
  // original box name is simply never opened again, which avoids Hive
  // trying (and failing) to read old-shaped objects as the new class.
  final Box<Meal> _mealBox = Hive.box<Meal>('mealBoxV2');
  final Box<WaterEntry> _waterBox = Hive.box<WaterEntry>('waterBox');

  bool _isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  // ---- MEALS ------------------------------------------------------------

  /// Most recent meal first.
  List<Meal> get meals {
    final all = _mealBox.values.toList();
    all.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return all;
  }

  Future<void> addMeal(Meal meal) async {
    await _mealBox.add(meal);
    notifyListeners();
  }

  Future<void> deleteMeal(Meal meal) async {
    await meal.delete();
    notifyListeners();
  }

  int get todayCalories => meals
      .where((m) => _isToday(m.dateTime))
      .fold(0, (sum, m) => sum + m.calories);
  int get todayProtein => meals
      .where((m) => _isToday(m.dateTime))
      .fold(0, (sum, m) => sum + m.proteinGrams);
  int get todayCarbs => meals
      .where((m) => _isToday(m.dateTime))
      .fold(0, (sum, m) => sum + m.carbsGrams);
  int get todayFat => meals
      .where((m) => _isToday(m.dateTime))
      .fold(0, (sum, m) => sum + m.fatGrams);

  /// Total water intake (ml) per day for the last 7 days (oldest first, today last).
  /// today last) — feeds the Analytics "Water Intake" chart. Same
  /// day-bucketing pattern as WorkoutProvider.weeklyCaloriesBurned.
  List<int> get weeklyWaterMl {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - i));
      return waterEntries
          .where(
            (w) =>
                w.dateTime.year == day.year &&
                w.dateTime.month == day.month &&
                w.dateTime.day == day.day,
          )
          .fold(0, (sum, w) => sum + w.amountMl);
    });
  }
  // ---- WATER --------------------------------------------------------------

  /// Most recent entry first.
  List<WaterEntry> get waterEntries {
    final all = _waterBox.values.toList();
    all.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return all;
  }

  Future<void> addWater(int amountMl) async {
    await _waterBox.add(
      WaterEntry(amountMl: amountMl, dateTime: DateTime.now()),
    );
    notifyListeners();
  }

  Future<void> deleteWater(WaterEntry entry) async {
    await entry.delete();
    notifyListeners();
  }

  int get todayWaterMl => waterEntries
      .where((w) => _isToday(w.dateTime))
      .fold(0, (sum, w) => sum + w.amountMl);
}
