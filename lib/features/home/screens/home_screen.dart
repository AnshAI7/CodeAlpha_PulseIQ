import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../widgets/greeting_header.dart';
import '../widgets/health_score_card.dart';
import '../widgets/quick_stats_row.dart';
import '../widgets/today_activity_card.dart';

/// Home dashboard — the app's default landing tab.
///
/// This file only assembles widgets, it doesn't build any UI itself —
/// each section (greeting, score, stats, activity) is its own file
/// under widgets/, so this screen stays readable even as the dashboard
/// grew from a static mockup (Day 1) to real live data (Day 6).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PulseIQ')),
      body: ListView(
        children: const [
          GreetingHeader(),
          HealthScoreCard(),
          SizedBox(height: AppSpacing.md),
          QuickStatsRow(),
          TodayActivityCard(),
        ],
      ),
    );
  }
}
