import 'package:hive/hive.dart';
import 'food_entry.dart';

part 'meal.g.dart';

/// A single meal event (e.g. "Lunch" at 1:15 PM) — can hold multiple
/// food items logged together.
///
/// typeId stays 1 — same as the original single-food version of this
/// class. Only the SHAPE changed (foodName/calories/etc. replaced by a
/// List<FoodEntry>), which is why the box itself got renamed to
/// mealBoxV2 in NutritionProvider: old saved data used the old shape,
/// and Hive can't read it as the new one. Renaming the box avoids a
/// crash on every existing install instead of trying to migrate it.

@HiveType(typeId: 1)
class Meal extends HiveObject {
  @HiveField(0)
  final String mealType; // Breakfast, Lunch, Dinner, Snack

  @HiveField(1)
  final List<FoodEntry> items;

  @HiveField(2)
  final DateTime dateTime;

  Meal({required this.mealType, required this.items, required this.dateTime});

  // Same names as before, on purpose — NutritionProvider and every
  // screen that reads meal.calories/proteinGrams/etc. keep working
  // unchanged, even though these are now computed, not stored directly.
  // not stored directly. This is what kept the schema change from
  // rippling into every file that displays a meal.
  int get calories => items.fold(0, (sum, i) => sum + i.calories);
  int get proteinGrams => items.fold(0, (sum, i) => sum + i.proteinGrams);
  int get carbsGrams => items.fold(0, (sum, i) => sum + i.carbsGrams);
  int get fatGrams => items.fold(0, (sum, i) => sum + i.fatGrams);
}
