import 'package:flutter/material.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/workout/screens/workout_screen.dart';
import '../../features/nutrition/screens/nutrition_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/profile/screens/profile_screen.dart';

/// The app's root navigation shell — persistent bottom nav across the
/// 5 main tabs. IndexedStack keeps all 5 alive in memory; switching tabs
/// never destroys/rebuilds a screen the way a pushed route would.
/// scrolling down in Analytics, switching to Profile, then back, keeps
/// the scroll position instead of resetting it).
///
/// Lives in shared/, not inside any one feature — it doesn't belong to
/// Home or Workout specifically, it contains both.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // Plain local setState, deliberately not a Provider — which tab is
  // selected is purely this one widget's own UI concern, nothing else
  // in the app needs to read or react to it.
  int _currentIndex = 0;

  static const List<Widget> _tabs = [
    HomeScreen(),
    WorkoutScreen(),
    NutritionScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Nutrition',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
