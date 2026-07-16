import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import 'water_quick_add.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Today's water intake vs a default daily target (2000ml — becomes a
/// real user-set goal once Profile exists), plus quick-add buttons.
/// Profile supports it, same honesty-about-scope pattern as the
/// Health Score's fixed 30-minute workout guideline).
class WaterProgressCard extends StatelessWidget {
  const WaterProgressCard({super.key});

  static const int _dailyGoalMl = 2000;

  @override
  Widget build(BuildContext context) {
    final todayMl = context.watch<NutritionProvider>().todayWaterMl;
    final progress = (todayMl / _dailyGoalMl).clamp(0.0, 1.0);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop, color: AppColors.health),
              const SizedBox(width: AppSpacing.sm),
              Text('$todayMl / $_dailyGoalMl ml', style: textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.xs),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.health.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(AppColors.health),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const WaterQuickAdd(),
        ],
      ),
    );
  }
}
