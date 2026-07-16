import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Reusable 7-day bar chart. `values` must have exactly 7 entries,
/// oldest (6 days ago) first, today last.
///
/// One widget, used for all 3 charts on the Analytics screen instead of
/// writing the fl_chart boilerplate 3 separate times — fl_chart's API
/// (titlesData/AxisTitles/SideTitles) is verbose enough that repeating
/// it isn't worth it for what's really just "same chart, different data".
class WeeklyBarChart extends StatelessWidget {
  final String title;
  final List<int> values;
  final Color color;
  final String unit;

  const WeeklyBarChart({
    super.key,
    required this.title,
    required this.values,
    required this.color,
    required this.unit,
  });
  // Day labels are computed from the real current date, not hardcoded
  // Mon–Sun — the 7-day window doesn't reset on Monday, it's always
  // "today and the 6 days before it".
  List<String> get _dayLabels {
    final now = DateTime.now();
    return List.generate(
      7,
      (i) => DateFormat('E').format(now.subtract(Duration(days: 6 - i))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final maxValue = values.isEmpty
        ? 0.0
        : values.reduce((a, b) => a > b ? a : b).toDouble();
    final weekTotal = values.fold(0, (sum, v) => sum + v);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleMedium),
        Text('$weekTotal $unit this week', style: textTheme.bodySmall),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: BarChart(
            BarChartData(
              // 20% headroom above the tallest bar so it never touches
              // the top edge of the chart; falls back to 10 when every
              // day is 0, so the chart isn't a flat empty line before
              // any data exists.
              maxY: maxValue == 0 ? 10 : maxValue * 1.2,
              barTouchData: BarTouchData(enabled: false),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                // Only the bottom axis shows anything — top/right/left
                // are explicitly turned off, otherwise fl_chart draws
                // default number labels on all four sides.
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= _dayLabels.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _dayLabels[idx],
                          style: textTheme.labelSmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(values.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: values[i].toDouble(),
                      color: color,
                      width: 18,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
