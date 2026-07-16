import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../models/meal.dart';
import '../widgets/nutrition_summary_card.dart';
import '../widgets/water_progress_card.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_spacing.dart';

/// Nutrition dashboard — calorie/macro totals, water progress, meal list.
class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, Meal meal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete meal?'),
        // mealType ("Lunch"), not a food name — a Meal can now hold
        // several food items, so there's no single name to reference here.
        content: Text('Remove this ${meal.mealType} entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<NutritionProvider>().deleteMeal(meal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meals = context.watch<NutritionProvider>().meals;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const NutritionSummaryCard(),
          const SizedBox(height: AppSpacing.sm),
          const WaterProgressCard(),
          const SizedBox(height: AppSpacing.md),
          Text('Meals', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          ...meals.isEmpty
              ? [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    child: Center(
                      child: Text(
                        'No meals logged yet',
                        style: textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ]
              : meals
                    .map(
                      (meal) => Container(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.cardRadius,
                          ),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Joins every item's name — e.g. a Lunch
                                  // with Dal + Rice shows as "Dal, Rice ·
                                  // Lunch" instead of two separate cards.
                                  Text(
                                    '${meal.items.map((i) => i.foodName).join(', ')} · ${meal.mealType}',
                                    style: textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  // meal.calories is a computed getter now
                                  // (sums all items), not a stored field —
                                  // this line didn't need to change at all
                                  // when the schema did.
                                  Text(
                                    '${meal.calories} kcal',
                                    style: textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _confirmDelete(context, meal),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.logMeal),
        child: const Icon(Icons.add),
      ),
    );
  }
}
