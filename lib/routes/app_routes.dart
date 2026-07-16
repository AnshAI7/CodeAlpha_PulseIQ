/// Every route name in the app, in one place. Add a new constant here
/// the moment a new screen needs to be reachable via Navigator.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String logWorkout = '/log-workout';
  static const String logMeal = '/log-meal';
  // Added as each feature gets built:
  // static const String nutrition = '/nutrition';
  // static const String analytics = '/analytics';
  // static const String profile = '/profile';
}
