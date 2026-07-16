import 'package:hive/hive.dart';

part 'water_entry.g.dart';

/// A single logged water intake entry.
/// logs (like Workout), not a single running daily total — that's what
/// lets Today's Activity show "Water logged · 9:15 AM · 500ml" as a
/// real event instead of just one number that resets at midnight.
@HiveType(typeId: 2)
class WaterEntry extends HiveObject {
  @HiveField(0)
  final int amountMl;

  @HiveField(1)
  final DateTime dateTime;

  WaterEntry({required this.amountMl, required this.dateTime});
}
