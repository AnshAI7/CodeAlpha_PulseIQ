import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Single source of truth for profile + app settings. Backed by
/// SharedPreferences, not Hive — this is ONE record, not a list.
/// list like Workout/Meal/WaterEntry, so a lightweight key-value store
/// is the right tool instead of a full database box.
class ProfileProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  ProfileProvider(this._prefs);

  static const _keyName = 'profile_name';
  static const _keyWeight = 'profile_weight_kg';
  static const _keyHeight = 'profile_height_cm';
  static const _keyThemeMode = 'profile_theme_mode';

  String get name => _prefs.getString(_keyName) ?? '';
  // Defaults to 0, not a placeholder like 70 — 0 is treated as "not
  // set yet" everywhere this is read (Workout's calorie auto-estimate,
  // the Profile screen's "Not set" label). A fake default weight would
  // silently produce wrong calorie estimates for a user who never
  // actually entered theirs.
  double get weightKg => _prefs.getDouble(_keyWeight) ?? 0.0;
  // Height CAN have a real default (170) — unlike weight, an unset
  // height doesn't get used to silently estimate anything else, so a
  // reasonable placeholder here doesn't create the same risk.
  double get heightCm => _prefs.getDouble(_keyHeight) ?? 170.0;

  ThemeMode get themeMode {
    final index = _prefs.getInt(_keyThemeMode) ?? ThemeMode.system.index;
    return ThemeMode.values[index];
  }

  double get bmi {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  String get bmiCategory {
    if (bmi < 18.5) {
      return 'Underweight';
    }
    if (bmi < 25) {
      return 'Normal';
    }
    if (bmi < 30) {
      return 'Overweight';
    }
    return 'Obese';
  }

  Future<void> updateName(String value) async {
    await _prefs.setString(_keyName, value);
    notifyListeners();
  }

  Future<void> updateWeight(double value) async {
    await _prefs.setDouble(_keyWeight, value);
    notifyListeners();
  }

  Future<void> updateHeight(double value) async {
    await _prefs.setDouble(_keyHeight, value);
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_keyThemeMode, mode.index);
    notifyListeners();
  }
}
