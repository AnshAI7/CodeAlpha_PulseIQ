import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../workout/providers/workout_provider.dart';
import '../../nutrition/providers/nutrition_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Real quick stats. "Steps" was dropped — no real data source without
/// a device pedometer; "Workouts" (session count) replaces it instead.
class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final nutrition = context.watch<NutritionProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: _StatTile(
              icon: Icons.fitness_center,
              value: '${workout.todayWorkoutCount}',
              label: 'Workouts',
              color: AppColors.workout,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatTile(
              icon: Icons.local_fire_department,
              value: '${workout.todayCaloriesBurned}',
              label: 'Kcal',
              color: AppColors.workout,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatTile(
              icon: Icons.water_drop,
              value: '${nutrition.todayWaterMl}ml',
              label: 'Water',
              color: AppColors.health,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: AppSpacing.xs),
          // FittedBox added after real device testing — on narrow
          // phones or with larger system font sizes, a 4-digit calorie
          // number could overflow this tile. This shrinks the text
          // instead of letting it overflow.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: textTheme.titleMedium),
          ),
          Text(label, style: textTheme.labelSmall),
        ],
      ),
    );
  }
}
