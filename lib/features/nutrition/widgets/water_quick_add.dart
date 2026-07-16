import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nutrition_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// One-tap water logging — no form needed, since "how much" is the
/// only information a water log requires.
/// pushed screen), this stays inline on the Nutrition tab because a
/// full-screen form would be overkill for a single number.
class WaterQuickAdd extends StatelessWidget {
  const WaterQuickAdd({super.key});

  static const List<int> _quickAmounts = [100, 250, 500];

  Future<void> _logWater(BuildContext context, int amountMl) async {
    await context.read<NutritionProvider>().addWater(amountMl);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('+$amountMl ml logged')));
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: _quickAmounts.map((amount) {
        return OutlinedButton.icon(
          onPressed: () => _logWater(context, amount),
          icon: const Icon(Icons.water_drop, size: 18, color: AppColors.health),
          label: Text('+${amount}ml'),
        );
      }).toList(),
    );
  }
}
