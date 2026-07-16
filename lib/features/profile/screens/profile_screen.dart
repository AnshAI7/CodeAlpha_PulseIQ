import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../../../core/constants/app_spacing.dart';

// Top-level, not a method — shared by Name/Weight/Height edits below.
// Writing this 3 separate times (one AlertDialog per field) would have
// been the exact kind of duplicate code the project avoids elsewhere.
Future<String?> _showEditDialog(
  BuildContext context, {
  required String title,
  required String initialValue,
  TextInputType keyboardType = TextInputType.text,
}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Edit $title'),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: keyboardType,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context, ProfileProvider profile) async {
    final result = await _showEditDialog(
      context,
      title: 'Name',
      initialValue: profile.name,
    );
    if (result != null && result.trim().isNotEmpty) {
      await profile.updateName(result.trim());
    }
  }

  Future<void> _editWeight(
    BuildContext context,
    ProfileProvider profile,
  ) async {
    final result = await _showEditDialog(
      context,
      title: 'Weight (kg)',
      initialValue: profile.weightKg.toStringAsFixed(1),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
    final parsed = double.tryParse(result ?? '');
    // Silently ignores invalid/empty input instead of showing an error —
    // if the user cancels or types garbage, the old value just stays.
    if (parsed != null && parsed > 0) {
      await profile.updateWeight(parsed);
    }
  }

  Future<void> _editHeight(
    BuildContext context,
    ProfileProvider profile,
  ) async {
    final result = await _showEditDialog(
      context,
      title: 'Height (cm)',
      initialValue: profile.heightCm.toStringAsFixed(0),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
    final parsed = double.tryParse(result ?? '');
    if (parsed != null && parsed > 0) {
      await profile.updateHeight(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Center(
            child: Column(
              children: [
                // Plain icon avatar, not a real photo — image_picker +
                // permissions + file storage was scoped out (see README)
                // given the time left before submission.
                CircleAvatar(
                  radius: 40,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => _editName(context, profile),
                  child: Text(
                    profile.name.isEmpty
                        ? 'Tap to set your name'
                        : profile.name,
                    style: textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    // "Not set" instead of "0.0 kg" — showing a fake
                    // zero would look like a real (very wrong) value.
                    value: profile.weightKg > 0
                        ? '${profile.weightKg.toStringAsFixed(1)} kg'
                        : 'Not set',
                    label: 'Weight',
                    onTap: () => _editWeight(context, profile),
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    value: '${profile.heightCm.toStringAsFixed(0)} cm',
                    label: 'Height',
                    onTap: () => _editHeight(context, profile),
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    // BMI can't be trusted without a real weight, so it
                    // shows a dash instead of a misleading number.
                    value: profile.weightKg > 0
                        ? profile.bmi.toStringAsFixed(1)
                        : '—',
                    label: 'BMI · ${profile.bmiCategory}',
                    onTap: null, // BMI is computed, not directly editable
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Appearance', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          // Writes straight through to ProfileProvider, which persists
          // it via SharedPreferences — this is what makes the theme
          // choice survive an app restart, not just the current session.
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('Auto'),
                icon: Icon(Icons.brightness_auto_outlined),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode_outlined),
              ),
            ],
            selected: {profile.themeMode},
            onSelectionChanged: (selection) =>
                profile.updateThemeMode(selection.first),
          ),
        ],
      ),
    );
  }
}

// Private — only used 3 times inside this one screen (Weight/Height/BMI),
// no reason for it to live in shared/widgets.
class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback? onTap;
  const _StatColumn({
    required this.value,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          children: [
            // Shrinks the text instead of overflowing — same fix as
            // QuickStatsRow, needed here for the same reason (narrow
            // phones / larger system font sizes).
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: textTheme.titleMedium),
            ),
            Text(
              label,
              style: textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
