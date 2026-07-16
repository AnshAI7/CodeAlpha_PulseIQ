import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../shared/widgets/main_shell.dart';
import '../features/workout/screens/log_workout_screen.dart';
import '../features/nutrition/screens/log_meal_screen.dart';

/// Turns a route name into a screen widget. Wired into MaterialApp via
/// onGenerateRoute — this is the ONLY place that maps names to screens.
///
/// Only used for one-off PUSHED screens (Log Workout, Log Meal) — the
/// 5 main tabs (Home/Workout/Nutrition/Analytics/Profile) don't go
/// through here at all, they're handled by MainShell's IndexedStack
/// instead. Two different navigation problems, two different tools.
class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const MainShell());

      case AppRoutes.logWorkout:
        return MaterialPageRoute(builder: (_) => const LogWorkoutScreen());
      case AppRoutes.logMeal:
        return MaterialPageRoute(builder: (_) => const LogMealScreen());
      // Without this, navigating to a typo'd or not-yet-built route
      // crashes the whole app with a red screen — this turns that into
      // a graceful fallback instead.
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
