import 'package:hive/hive.dart';

part 'food_entry.g.dart';

/// One food item inside a meal (e.g. "2 Eggs" inside a "Breakfast").
/// Values here are already scaled by quantity at the time of adding —
/// stored as consumed, so editing the common-foods list later never
/// changes historical logs.
///
/// Deliberately NOT a HiveObject — unlike Workout/Meal/WaterEntry, this
/// never gets saved to a Hive box on its own. It only ever exists as an
/// item inside Meal.items, so it doesn't need Hive's per-object
/// key-tracking (no .delete()/.save() needed on a FoodEntry directly).
@HiveType(typeId: 3)
class FoodEntry {
  @HiveField(0)
  final String foodName;

  @HiveField(1)
  final double quantity;

  @HiveField(2)
  final String servingLabel; // e.g. "100 ml", "1 piece"

  @HiveField(3)
  final int calories;

  @HiveField(4)
  final int proteinGrams;

  @HiveField(5)
  final int carbsGrams;

  @HiveField(6)
  final int fatGrams;

  FoodEntry({
    required this.foodName,
    required this.quantity,
    required this.servingLabel,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });
}
