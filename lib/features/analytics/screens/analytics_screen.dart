import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../workout/providers/workout_provider.dart';
import '../../nutrition/providers/nutrition_provider.dart';
import '../widgets/weekly_bar_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Weekly trends — visualizes existing Workout/Nutrition data.
/// No separate analytics data store; purely a read layer.
/// something we don't actually track (weight, sleep) would just show
/// empty graphs, so this screen is scoped to data that's genuinely real.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workout = context.watch<WorkoutProvider>();
    final nutrition = context.watch<NutritionProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _ChartCard(
            colorScheme: colorScheme,
            child: WeeklyBarChart(
              title: 'Workout Minutes',
              values: workout.weeklyWorkoutMinutes,
              color: AppColors.workout,
              unit: 'min',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ChartCard(
            colorScheme: colorScheme,
            child: WeeklyBarChart(
              title: 'Calories Burned',
              values: workout.weeklyCaloriesBurned,
              color: AppColors.workout,
              unit: 'kcal',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ChartCard(
            colorScheme: colorScheme,
            child: WeeklyBarChart(
              title: 'Water Intake',
              values: nutrition.weeklyWaterMl,
              color: AppColors.health,
              unit: 'ml',
            ),
          ),
        ],
      ),
    );
  }
}

// Private to this file on purpose — the card-with-border look is used
// 3 times above; without this, that same border/radius/color block
// would be copy-pasted 3 times.
class _ChartCard extends StatelessWidget {
  final Widget child;
  final ColorScheme colorScheme;
  const _ChartCard({required this.child, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}
