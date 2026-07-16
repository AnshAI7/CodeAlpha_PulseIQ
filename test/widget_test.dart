import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_iq/main.dart';
import 'package:pulse_iq/features/workout/models/workout.dart';
import 'package:pulse_iq/features/nutrition/models/meal.dart';
import 'package:pulse_iq/features/nutrition/models/water_entry.dart';
import 'package:pulse_iq/features/nutrition/models/food_entry.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    // A real Hive instance, backed by a throwaway temp folder — not the
    // actual app's storage. Tests must be repeatable and isolated;
    // pointing this at real app data could corrupt genuinely logged
    // workouts/meals, and results would vary depending on whatever was
    // already saved on the machine running the test.
    tempDir = await Directory.systemTemp.createTemp('pulse_iq_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(WorkoutAdapter());
    Hive.registerAdapter(MealAdapter());
    Hive.registerAdapter(WaterEntryAdapter());
    Hive.registerAdapter(FoodEntryAdapter());
    await Hive.openBox<Workout>('workoutBox');
    await Hive.openBox<Meal>('mealBoxV2');
    await Hive.openBox<WaterEntry>('waterBox');
  });

  tearDown(() async {
    // Fully wipe the temp Hive instance after each test — a clean
    // slate every run, not leftover state from the last one.
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  testWidgets('App launches and shows the Home dashboard', (
    WidgetTester tester,
  ) async {
    // Name pre-set, so this test skips Onboarding and lands straight on
    // Home — without this, a fresh/empty profile would show the
    // Onboarding screen instead, and the assertions below would fail
    // looking for text that isn't on screen yet.
    SharedPreferences.setMockInitialValues({'profile_name': 'Test User'});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(PulseIQApp(prefs: prefs));
    await tester.pumpAndSettle();

    expect(find.text('PulseIQ'), findsOneWidget);
    expect(find.text('Health Score'), findsOneWidget);
  });
}
