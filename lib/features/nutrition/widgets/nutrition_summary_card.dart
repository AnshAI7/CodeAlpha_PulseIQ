import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../../../core/constants/app_spacing.dart';

/// Today's calorie + macro totals, summed live from all meals logged today.
class NutritionSummaryCard extends StatelessWidget {
  const NutritionSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final nutrition = context.watch<NutritionProvider>();
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
          Text(
            '${nutrition.todayCalories} kcal',
            style: textTheme.displayMedium,
          ),
          Text('consumed today', style: textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _MacroChip(label: 'Protein', grams: nutrition.todayProtein),
              const SizedBox(width: AppSpacing.sm),
              _MacroChip(label: 'Carbs', grams: nutrition.todayCarbs),
              const SizedBox(width: AppSpacing.sm),
              _MacroChip(label: 'Fat', grams: nutrition.todayFat),
            ],
          ),
        ],
      ),
    );
  }
}

// Private — only ever used inside this one card, 3 times in a row, so
// it doesn't need to live in shared/widgets.
class _MacroChip extends StatelessWidget {
  final String label;
  final int grams;
  const _MacroChip({required this.label, required this.grams});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Text('${grams}g', style: textTheme.titleMedium),
          Text(label, style: textTheme.labelSmall),
        ],
      ),
    );
  }
}
