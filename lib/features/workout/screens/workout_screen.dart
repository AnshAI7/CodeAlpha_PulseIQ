import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import '../../../routes/app_routes.dart';
import '../../../core/constants/app_spacing.dart';

/// Live list of logged workouts, backed by WorkoutProvider/Hive.
/// Started as a "Coming soon" placeholder (Day 1, needed something for
/// the bottom nav shell to point at) before Workout logging existed.
class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, Workout workout) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete workout?'),
        content: Text('Remove this ${workout.exerciseType} entry?'),
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
      context.read<WorkoutProvider>().deleteWorkout(workout);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workouts = context.watch<WorkoutProvider>().workouts;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Workout')),
      // Explicit empty state instead of just an empty ListView — a
      // blank screen with only a FAB looks broken; this tells a
      // first-time user exactly what to do next.
      body: workouts.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fitness_center_outlined,
                    size: 48,
                    color: colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('No workouts logged yet', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Tap + to log your first workout',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: workouts.length,
              itemBuilder: (context, index) {
                final workout = workouts[index];
                // Plain bordered Container, not Flutter's Card widget —
                // Card comes with its own default shadow/elevation that
                // doesn't match the flat, bordered look used everywhere
                // else (Home dashboard, Nutrition). Keeping every list
                // item styled the same way is what makes the app read
                // as one design system instead of two colliding ones.
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.fitness_center, color: colorScheme.primary),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.exerciseType,
                              style: textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${workout.durationMinutes} min · ${workout.caloriesBurned} kcal · '
                              '${DateFormat('MMM d, h:mm a').format(workout.dateTime)}',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, workout),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.logWorkout),
        child: const Icon(Icons.add),
      ),
    );
  }
}
