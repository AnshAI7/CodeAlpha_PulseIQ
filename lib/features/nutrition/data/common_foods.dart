/// A small set of common foods with nutrition PER STATED SERVING —
/// quantity in the UI multiplies against these base values.
///
///Not a real food database (that would need a paid API and internet
/// access) — just enough everyday Indian foods that most quick-logging
/// never needs the manual entry fallback. Values are approximate,
/// intentionally — good enough for a fitness tracker, not a medical tool.
class CommonFood {
  final String name;
  final String servingLabel;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;

  const CommonFood({
    required this.name,
    required this.servingLabel,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });
}

const List<CommonFood> commonFoods = [
  CommonFood(
    name: 'Roti / Chapati',
    servingLabel: '1 piece',
    calories: 120,
    proteinGrams: 3,
    carbsGrams: 18,
    fatGrams: 3,
  ),
  CommonFood(
    name: 'Rice',
    servingLabel: '1 cup',
    calories: 200,
    proteinGrams: 4,
    carbsGrams: 45,
    fatGrams: 1,
  ),
  CommonFood(
    name: 'Dal',
    servingLabel: '1 bowl',
    calories: 180,
    proteinGrams: 9,
    carbsGrams: 27,
    fatGrams: 6,
  ),
  CommonFood(
    name: 'Paneer',
    servingLabel: '100 g',
    calories: 265,
    proteinGrams: 18,
    carbsGrams: 6,
    fatGrams: 20,
  ),
  CommonFood(
    name: 'Chicken Breast',
    servingLabel: '100 g',
    calories: 165,
    proteinGrams: 31,
    carbsGrams: 0,
    fatGrams: 4,
  ),
  CommonFood(
    name: 'Boiled Egg',
    servingLabel: '1 piece',
    calories: 78,
    proteinGrams: 6,
    carbsGrams: 1,
    fatGrams: 5,
  ),
  CommonFood(
    name: 'Banana',
    servingLabel: '1 piece',
    calories: 105,
    proteinGrams: 1,
    carbsGrams: 27,
    fatGrams: 0,
  ),
  CommonFood(
    name: 'Apple',
    servingLabel: '1 piece',
    calories: 95,
    proteinGrams: 1,
    carbsGrams: 25,
    fatGrams: 0,
  ),
  CommonFood(
    name: 'Milk',
    servingLabel: '100 ml',
    calories: 60,
    proteinGrams: 3,
    carbsGrams: 5,
    fatGrams: 3,
  ),
  CommonFood(
    name: 'Curd / Yogurt',
    servingLabel: '1 bowl',
    calories: 100,
    proteinGrams: 6,
    carbsGrams: 8,
    fatGrams: 4,
  ),
  CommonFood(
    name: 'Samosa',
    servingLabel: '1 piece',
    calories: 260,
    proteinGrams: 4,
    carbsGrams: 24,
    fatGrams: 17,
  ),
  CommonFood(
    name: 'Chai / Tea',
    servingLabel: '1 cup',
    calories: 40,
    proteinGrams: 1,
    carbsGrams: 6,
    fatGrams: 2,
  ),
  CommonFood(
    name: 'Bread',
    servingLabel: '1 slice',
    calories: 70,
    proteinGrams: 3,
    carbsGrams: 13,
    fatGrams: 1,
  ),
  CommonFood(
    name: 'Salad',
    servingLabel: '1 bowl',
    calories: 50,
    proteinGrams: 2,
    carbsGrams: 10,
    fatGrams: 1,
  ),
  CommonFood(
    name: 'Biryani',
    servingLabel: '1 plate',
    calories: 450,
    proteinGrams: 15,
    carbsGrams: 55,
    fatGrams: 18,
  ),
  CommonFood(
    name: 'Momos',
    servingLabel: '6 pieces',
    calories: 250,
    proteinGrams: 8,
    carbsGrams: 35,
    fatGrams: 8,
  ),
  CommonFood(
    name: 'Pizza',
    servingLabel: '1 slice',
    calories: 285,
    proteinGrams: 12,
    carbsGrams: 36,
    fatGrams: 10,
  ),
  CommonFood(
    name: 'Burger',
    servingLabel: '1 piece',
    calories: 350,
    proteinGrams: 15,
    carbsGrams: 33,
    fatGrams: 18,
  ),
  CommonFood(
    name: 'Idli',
    servingLabel: '2 pieces',
    calories: 78,
    proteinGrams: 3,
    carbsGrams: 16,
    fatGrams: 0,
  ),
  CommonFood(
    name: 'Poha',
    servingLabel: '1 plate',
    calories: 250,
    proteinGrams: 5,
    carbsGrams: 45,
    fatGrams: 6,
  ),
];
