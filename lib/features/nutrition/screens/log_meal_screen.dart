import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/common_foods.dart';
import '../models/food_entry.dart';
import '../models/meal.dart';
import '../providers/nutrition_provider.dart';
import '../../../core/constants/app_spacing.dart';

/// Log a meal made of one or more food items, each with its own
/// adjustable quantity (e.g. 2 eggs vs 5 eggs, 100ml vs 500ml milk).
///
/// Rebuilt from a single-item version — the original form could only
/// log one food per meal, so something like "Dal + Rice" for lunch had
/// to be two separate meal entries. This version builds up a list of
/// items locally in the form, and only creates the actual Meal object
/// once "Save Meal" is tapped.
class LogMealScreen extends StatefulWidget {
  const LogMealScreen({super.key});

  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  static const List<String> _mealTypes = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];
  String _selectedMealType = _mealTypes.first;
  // Items added so far, for THIS meal only — not saved to Hive until
  // the whole meal is submitted. Starts empty every time this screen opens.

  final List<FoodEntry> _items = [];

  late TextEditingController _foodNameController;
  CommonFood? _selectedCommonFood;
  double _quantity = 1;

  // Only used when the typed food doesn't match anything in the
  // common-foods list — lets the user log something custom instead of
  // being blocked by an incomplete database.

  final _customCaloriesController = TextEditingController();
  final _customProteinController = TextEditingController();
  final _customCarbsController = TextEditingController();
  final _customFatController = TextEditingController();

  @override
  void dispose() {
    _customCaloriesController.dispose();
    _customProteinController.dispose();
    _customCarbsController.dispose();
    _customFatController.dispose();
    super.dispose();
  }

  void _selectCommonFood(CommonFood food) {
    setState(() {
      _selectedCommonFood = food;
      _quantity = 1;
    });
  }

  // Clamped 0.5–20 — half-servings are realistic (half a roti), but
  // there's no real reason to allow typing something like 500 eggs.
  void _changeQuantity(double delta) {
    setState(() => _quantity = (_quantity + delta).clamp(0.5, 20));
  }

  void _addItem() {
    final name = _foodNameController.text.trim();
    if (name.isEmpty) {
      return;
    }

    if (_selectedCommonFood != null && _selectedCommonFood!.name == name) {
      // Known food — nutrition is calculated NOW, scaled by quantity,
      // and stored as a fixed number. If commonFoods' base values ever
      // change later, meals already logged today stay exactly as they
      // were when the user actually ate them.
      final food = _selectedCommonFood!;
      setState(() {
        _items.add(
          FoodEntry(
            foodName: food.name,
            quantity: _quantity,
            servingLabel: food.servingLabel,
            calories: (food.calories * _quantity).round(),
            proteinGrams: (food.proteinGrams * _quantity).round(),
            carbsGrams: (food.carbsGrams * _quantity).round(),
            fatGrams: (food.fatGrams * _quantity).round(),
          ),
        );
      });
    } else {
      // Not a known food — fall back to manual entry instead of
      // blocking the user. Calories is the only required field here;
      // macros default to 0 if left blank, same as the original form.
      final calories = int.tryParse(_customCaloriesController.text);
      if (calories == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter calories for this food')),
        );
        return;
      }
      setState(() {
        _items.add(
          FoodEntry(
            foodName: name,
            quantity: 1,
            servingLabel: 'custom',
            calories: calories,
            proteinGrams: int.tryParse(_customProteinController.text) ?? 0,
            carbsGrams: int.tryParse(_customCarbsController.text) ?? 0,
            fatGrams: int.tryParse(_customFatController.text) ?? 0,
          ),
        );
      });
    }

    // Reset the "add item" row so the next food starts fresh — this is
    // what makes adding Dal, then Rice, then Chai all in one meal possible.
    _foodNameController.clear();
    _customCaloriesController.clear();
    _customProteinController.clear();
    _customCarbsController.clear();
    _customFatController.clear();
    setState(() {
      _selectedCommonFood = null;
      _quantity = 1;
    });
  }

  void _removeItem(int index) => setState(() => _items.removeAt(index));

  Future<void> _saveMeal() async {
    // Reset the "add item" row so the next food starts fresh — this is
    // what makes adding Dal, then Rice, then Chai all in one meal possible.
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one food item')),
      );
      return;
    }

    final meal = Meal(
      mealType: _selectedMealType,
      items: List.of(_items),
      dateTime: DateTime.now(),
    );
    await context.read<NutritionProvider>().addMeal(meal);

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Meal saved')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final totalCalories = _items.fold(0, (sum, i) => sum + i.calories);

    return Scaffold(
      appBar: AppBar(title: const Text('Log Meal')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedMealType,
            decoration: const InputDecoration(labelText: 'Meal'),
            items: _mealTypes
                .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                .toList(),
            onChanged: (value) => setState(() => _selectedMealType = value!),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Add Food Item', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                // Autocomplete over commonFoods — typing "egg" surfaces
                // "Boiled Egg" with its nutrition preview, so most users
                // never need the manual calorie fields below at all.
                Autocomplete<CommonFood>(
                  optionsBuilder: (value) {
                    if (value.text.isEmpty) {
                      return const Iterable<CommonFood>.empty();
                    }
                    final query = value.text.toLowerCase();
                    return commonFoods.where(
                      (food) => food.name.toLowerCase().contains(query),
                    );
                  },
                  displayStringForOption: (food) => food.name,
                  onSelected: _selectCommonFood,
                  fieldViewBuilder:
                      (context, controller, focusNode, onSubmitted) {
                        _foodNameController = controller;
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onChanged: (text) {
                            // If the user edits the text after picking a
                            // suggestion, treat it as "no longer a known
                            // food" — otherwise stale nutrition values
                            // could get attached to a different name.
                            if (_selectedCommonFood != null &&
                                text != _selectedCommonFood!.name) {
                              setState(() => _selectedCommonFood = null);
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Food Name',
                            helperText:
                                'Search a common food, or type your own',
                          ),
                        );
                      },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 220,
                            maxWidth: 400,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final food = options.elementAt(index);
                              return ListTile(
                                dense: true,
                                title: Text(food.name),
                                subtitle: Text(
                                  '${food.servingLabel} · ${food.calories} kcal',
                                ),
                                onTap: () => onSelected(food),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                // Two completely different input modes depending on
                // whether a known food was picked: quantity stepper +
                // live-calculated preview, vs. manual number fields.
                if (_selectedCommonFood != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantity (${_selectedCommonFood!.servingLabel} each)',
                        style: textTheme.bodyMedium,
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _changeQuantity(-1),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            _quantity % 1 == 0
                                ? _quantity.toInt().toString()
                                : _quantity.toStringAsFixed(1),
                            style: textTheme.titleMedium,
                          ),
                          IconButton(
                            onPressed: () => _changeQuantity(1),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Live preview — recalculated on every rebuild, not
                  // stored anywhere, so it always matches the current
                  // quantity before the item is even added.
                  Text(
                    '${(_selectedCommonFood!.calories * _quantity).round()} kcal · '
                    'P${(_selectedCommonFood!.proteinGrams * _quantity).round()} '
                    'C${(_selectedCommonFood!.carbsGrams * _quantity).round()} '
                    'F${(_selectedCommonFood!.fatGrams * _quantity).round()}',
                    style: textTheme.bodySmall,
                  ),
                ] else ...[
                  TextField(
                    controller: _customCaloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Calories'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customProteinController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Protein (g)',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _customCarbsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Carbs (g)',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _customFatController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Fat (g)',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add to Meal'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Running list of everything added so far — this is what
          // makes a multi-item meal like "Dal, Rice, Chai" visible and
          // editable (remove any single item) before saving.
          if (_items.isNotEmpty) ...[
            Text(
              'Items in this meal · $totalCalories kcal total',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (int i = 0; i < _items.length; i++)
              Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
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
                          Text(_items[i].foodName, style: textTheme.bodyLarge),
                          Text(
                            _items[i].servingLabel == 'custom'
                                ? '${_items[i].calories} kcal'
                                : '${_items[i].quantity % 1 == 0 ? _items[i].quantity.toInt() : _items[i].quantity} × ${_items[i].servingLabel} · ${_items[i].calories} kcal',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeItem(i),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
          FilledButton(
            onPressed: _saveMeal,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Save Meal'),
            ),
          ),
        ],
      ),
    );
  }
}
