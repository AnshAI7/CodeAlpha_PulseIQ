import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/workout/models/workout.dart';
import 'features/workout/providers/workout_provider.dart';
import 'features/nutrition/models/meal.dart';
import 'features/nutrition/models/water_entry.dart';
import 'features/nutrition/providers/nutrition_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/profile/screens/onboarding_screen.dart';
import 'shared/widgets/main_shell.dart';
import 'routes/app_router.dart';
import 'features/nutrition/models/food_entry.dart';

Future<void> main() async {
  // Required any time main() does async work before runApp() —
  // Flutter's engine binding must be ready before Hive (or any plugin)
  // can talk to the platform.
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  // Every adapter must be registered BEFORE its box is opened — Hive
  // needs to know how to decode bytes back into objects the moment it
  // reads the box, not after.
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(MealAdapter());
  Hive.registerAdapter(WaterEntryAdapter());
  Hive.registerAdapter(FoodEntryAdapter());

  await Hive.openBox<Workout>('workoutBox');
  // mealBoxV2, not mealBox — Meal's schema changed (single food →
  // List<FoodEntry>) partway through the project. Renaming the box
  // instead of migrating it means old-shaped data is just never
  // touched again, rather than crashing every existing install.
  await Hive.openBox<Meal>('mealBoxV2');
  await Hive.openBox<WaterEntry>('waterBox');

  final prefs = await SharedPreferences.getInstance();

  runApp(PulseIQApp(prefs: prefs));
}

class PulseIQApp extends StatelessWidget {
  final SharedPreferences prefs;
  const PulseIQApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider(prefs)),
      ],
      // Deliberately NOT MaterialApp directly here. context inside
      // THIS build method sits above MultiProvider in the tree, so
      // context.watch<ProfileProvider>() wouldn't find it if called
      // right here. _AppView is built as MultiProvider's child, which
      // gives it its own context that's genuinely below the providers.
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return MaterialApp(
      title: 'PulseIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Reads the user's actual saved preference, not a hardcoded
      // ThemeMode.system — this is what makes the Light/Dark/Auto
      // toggle in Profile actually take effect app-wide.
      themeMode: profile.themeMode,
      // Caps content at 600dp wide on larger screens (tablets) instead
      // of letting cards/text stretch edge-to-edge; has no visible
      // effect on normal phone widths (360–430dp).
      builder: (context, child) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: child,
          ),
        );
      },
      // No name in ProfileProvider yet = first launch = show
      // Onboarding. This is a runtime decision (depends on saved
      // data), which is why this uses `home:` instead of
      // `initialRoute:` like earlier versions of this file did.
      home: profile.name.isEmpty ? const OnboardingScreen() : const MainShell(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
