import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../workout/providers/workout_provider.dart';
import '../../nutrition/providers/nutrition_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Real composite health score: 50% water progress + 50% workout
/// progress, both against general daily guidelines (not personalized
/// goals yet — that's Version 2 territory).
/// Version 2 scope). Replaced the Day 1 hardcoded 82 once Workout and
/// Nutrition providers actually existed to compute a real number from.
class HealthScoreCard extends StatelessWidget {
  const HealthScoreCard({super.key});

  static const int _waterGoalMl = 2000;
  static const int _workoutGoalMinutes = 30;

  @override
  Widget build(BuildContext context) {
    final todayWaterMl = context.watch<NutritionProvider>().todayWaterMl;
    final todayWorkoutMinutes = context
        .watch<WorkoutProvider>()
        .todayWorkoutMinutes;

    final waterProgress = (todayWaterMl / _waterGoalMl).clamp(0.0, 1.0);
    final workoutProgress = (todayWorkoutMinutes / _workoutGoalMinutes).clamp(
      0.0,
      1.0,
    );
    final score = (waterProgress * 0.5) + (workoutProgress * 0.5);
    // Message tiers instead of just showing the raw number alone —
    // a bare "42" means nothing to a user without context.
    final String message;
    if (score >= 0.8) {
      message = 'Excellent today';
    } else if (score >= 0.5) {
      message = 'Looking good today';
    } else if (score >= 0.2) {
      message = 'Getting started';
    } else {
      message = 'Log something to begin';
    }

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Health Score', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(message, style: textTheme.bodyMedium),
              ],
            ),
          ),
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score,
                  strokeWidth: 6,
                  backgroundColor: AppColors.health.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation(AppColors.health),
                ),
                Text('${(score * 100).round()}', style: textTheme.titleLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
