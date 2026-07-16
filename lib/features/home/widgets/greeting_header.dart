import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../profile/providers/profile_provider.dart';

/// Time-aware, name-aware greeting shown at the top of the Home dashboard.
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = context.watch<ProfileProvider>().name;
    // Falls back to a plain greeting if name is empty — shouldn't
    // normally happen since Onboarding requires a name before Home is
    // ever reachable, but this keeps the widget safe on its own even
    // if that flow ever changes.
    final greeting = name.isEmpty
        ? '${_greeting()} 👋'
        : '${_greeting()}, $name 👋';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting, style: textTheme.headlineLarge),
          const SizedBox(height: 4),
          Text(
            "Here's your health snapshot for today",
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
