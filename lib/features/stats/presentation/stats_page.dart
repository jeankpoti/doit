import 'package:do_it/common_widget/app_bar_widget.dart';
import 'package:flutter/material.dart';

import '../domain/models/stats.dart';
import 'stats_chart_widget.dart';

class StatsPage extends StatelessWidget {
  // final List<Stats> dailyStats;

  const StatsPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Stats> dailyStats = [
      Stats(
          completed: 3, date: DateTime.now().subtract(const Duration(days: 6))),
      Stats(
          completed: 4, date: DateTime.now().subtract(const Duration(days: 5))),
      Stats(
          completed: 5, date: DateTime.now().subtract(const Duration(days: 4))),
      Stats(
          completed: 3, date: DateTime.now().subtract(const Duration(days: 3))),
      Stats(
          completed: 6, date: DateTime.now().subtract(const Duration(days: 2))),
      Stats(
          completed: 4, date: DateTime.now().subtract(const Duration(days: 1))),
      Stats(completed: 5, date: DateTime.now()),
    ];

    return const Scaffold(
      appBar: AppBarWidget(
        title: 'Stats',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Daily Completed Tasks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Display the chart with the stats data and target value.
            SizedBox(
              height: 300,
              child: StatsChartWidget(
                isShowingMainData: true,
              ),
            ),
            SizedBox(height: 20),
            // Additional insights can be added here.
            Text(
              'Keep an eye on your trends. If you notice dips in productivity, consider revising your schedule or breaking tasks into smaller steps!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
