import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/workout.dart';
import '../providers/workout_provider.dart';
import '../../profile/providers/profile_provider.dart';

/// Form for logging a new workout. Started as a plain manual-entry
/// form (Day 2) — the MET-based auto-estimate below was added later,
/// once Profile actually had a real weight to calculate from.
class LogWorkoutScreen extends StatefulWidget {
  const LogWorkoutScreen({super.key});

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();

  static const List<String> _exerciseTypes = [
    'Running',
    'Walking',
    'Cycling',
    'Weight Training',
    'Yoga',
    'Swimming',
    'Other',
  ];

  /// MET (Metabolic Equivalent of Task) — standard exercise-science
  /// constants: calories ≈ MET × weight(kg) × duration(hours).
  static const Map<String, double> _metValues = {
    'Running': 10,
    'Walking': 3.5,
    'Cycling': 8,
    'Weight Training': 6,
    'Yoga': 3,
    'Swimming': 8,
    'Other': 5,
  };

  String _selectedType = _exerciseTypes.first;
  // Once true, auto-estimate stops touching the Calories field for
  // the rest of this form session — the whole point is that a manual
  // edit should never get silently overwritten by a recalculation.
  bool _userEditedCalories = false;

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _recalculateSuggestedCalories() {
    if (_userEditedCalories) {
      return;
    }

    final weightKg = context.read<ProfileProvider>().weightKg;
    final durationMinutes = int.tryParse(_durationController.text) ?? 0;

    // Bug found during testing: this used to just `return` here with
    // no field update, which left a STALE number sitting in Calories
    // from the previous duration instead of reflecting "0 minutes = 0
    // calories". Explicitly writing '0' fixed it.
    if (weightKg <= 0 || durationMinutes <= 0) {
      _caloriesController.text = '0';
      return;
    }

    final met = _metValues[_selectedType] ?? 5;
    final estimated = (met * weightKg * (durationMinutes / 60)).round();
    _caloriesController.text = estimated.toString();
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final workout = Workout(
      exerciseType: _selectedType,
      durationMinutes: int.parse(_durationController.text),
      caloriesBurned: int.parse(_caloriesController.text),
      dateTime: DateTime.now(),
    );

    await context.read<WorkoutProvider>().addWorkout(workout);

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Workout saved')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // ProfileProvider.weightKg, not .profile.weightKg — an earlier
    // version of this file assumed a nested `.profile` object that
    // never actually existed on ProfileProvider, and crashed on launch.
    final hasWeight = context.watch<ProfileProvider>().weightKg > 0;
    return Scaffold(
      appBar: AppBar(title: const Text('Log Workout')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Exercise Type'),
                items: _exerciseTypes
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedType = value!);
                  // Changing exercise type recalculates too — Running
                  // vs Yoga have very different MET values for the
                  // same duration.
                  _recalculateSuggestedCalories();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                ),
                onChanged: (_) {
                  setState(() {});
                  _recalculateSuggestedCalories();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a duration';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Calories Burned',
                  // Helper text doubles as a hint to go set your weight
                  // in Profile, for anyone who hasn't yet.
                  helperText: hasWeight
                      ? 'Auto-estimated from your weight — edit if you know the real value'
                      : 'Add your weight in Profile for automatic estimates',
                ),
                // Any manual edit permanently disables auto-estimate
                // for the rest of this screen's lifetime.
                onChanged: (_) => _userEditedCalories = true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter calories burned';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saveWorkout,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Save Workout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
