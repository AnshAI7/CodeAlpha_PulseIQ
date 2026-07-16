import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../workout/providers/workout_provider.dart';
import '../../nutrition/providers/nutrition_provider.dart';
import '../../../core/constants/app_spacing.dart';

// Local to this file — a unified shape for 3 completely different Hive
// models (Workout, Meal, WaterEntry) so they can all sit in one sorted
// timeline together, instead of showing 3 separate lists.
class _ActivityEntry {
  final IconData icon;
  final String title;
  final String subtitle;
  final DateTime dateTime;
  const _ActivityEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.dateTime,
  });
}

bool _isToday(DateTime dt) {
  final now = DateTime.now();
  return dt.year == now.year && dt.month == now.month && dt.day == now.day;
}

/// Today's real logged activity — merges Workout, Meal, and Water
/// entries into one timeline.
/// once all 3 providers actually existed to pull real data from.
class TodayActivityCard extends StatelessWidget {
  const TodayActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final nutrition = context.watch<NutritionProvider>();
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final timeFormat = DateFormat('h:mm a');

    final entries = <_ActivityEntry>[
      ...workout.workouts
          .where((w) => _isToday(w.dateTime))
          .map(
            (w) => _ActivityEntry(
              icon: Icons.fitness_center,
              title: w.exerciseType,
              subtitle:
                  '${timeFormat.format(w.dateTime)} · ${w.durationMinutes} min · ${w.caloriesBurned} kcal',
              dateTime: w.dateTime,
            ),
          ),
      ...nutrition.meals
          .where((m) => _isToday(m.dateTime))
          .map(
            (m) => _ActivityEntry(
              icon: Icons.restaurant,
              // meal.items is a List<FoodEntry> now, not a single food
              // name — joining them here is what lets "Dal, Rice ·
              // Lunch" show as one entry instead of two.
              title:
                  '${m.items.map((i) => i.foodName).join(', ')} · ${m.mealType}',
              subtitle: '${timeFormat.format(m.dateTime)} · ${m.calories} kcal',
              dateTime: m.dateTime,
            ),
          ),
      ...nutrition.waterEntries
          .where((w) => _isToday(w.dateTime))
          .map(
            (w) => _ActivityEntry(
              icon: Icons.water_drop,
              title: 'Water logged',
              subtitle: '${timeFormat.format(w.dateTime)} · ${w.amountMl} ml',
              dateTime: w.dateTime,
            ),
          ),
    ]..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // Capped at 5 — a busy day (multiple meals + water logs + a
    // workout) could otherwise make this card grow past a reasonable
    // dashboard height. Full history already lives on each feature's
    // own tab (Workout, Nutrition).
    final topEntries = entries.take(5).toList();
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Activity", style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          if (topEntries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'Nothing logged yet today',
                style: textTheme.bodyMedium,
              ),
            )
          else
            for (final entry in topEntries)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(entry.icon),
                title: Text(entry.title, style: textTheme.bodyLarge),
                subtitle: Text(entry.subtitle, style: textTheme.bodySmall),
              ),
        ],
      ),
    );
  }
}
