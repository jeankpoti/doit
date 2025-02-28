import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../../../constants/app_colors.dart';
import '../../pomodoro/domain/models/pomodoro.dart';

class StatsChartWidget extends StatefulWidget {
  final String timeframe;
  final List<int> dailyTasksData;
  // For the Daily timeframe, we now expect actual session objects.
  final List<Pomodoro> dailySessions;
  // (For other timeframes, you can continue using your existing int lists.)
  final List<int> weeklyTasksData;
  final List<int> monthlyTasksData;
  final List<int> lifetimeTasksData;
  final List<int> weeklySessionsData;
  final List<int> monthlySessionsData;
  final List<int> lifetimeSessionsData;

  const StatsChartWidget({
    super.key,
    required this.timeframe,
    required this.dailyTasksData,
    required this.dailySessions,
    required this.weeklyTasksData,
    required this.monthlyTasksData,
    required this.lifetimeTasksData,
    required this.weeklySessionsData,
    required this.monthlySessionsData,
    required this.lifetimeSessionsData,
  });

  @override
  State<StatsChartWidget> createState() => _StatsChartWidgetState();
}

class _StatsChartWidgetState extends State<StatsChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Track the currently touched spot for interactive effects
  FlSpot? _touchedSpot;
  int? _touchedLineIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    // Start the animation when the widget is first built
    _animationController.forward();
  }

  @override
  void didUpdateWidget(StatsChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the timeframe changes, restart the animation
    if (oldWidget.timeframe != widget.timeframe) {
      _animationController.reset();
      _animationController.forward();
      // Reset touched state when data changes
      _touchedSpot = null;
      _touchedLineIndex = null;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return LineChart(
            getChartData(context),
            duration: const Duration(milliseconds: 300),
          );
        },
      ),
    );
  }

  LineChartData getChartData(BuildContext context) {
    switch (widget.timeframe) {
      case 'Weekly':
        return getWeeklyChartData(context);
      case 'Monthly':
        return getMonthlyChartData(context);
      case 'Lifetime':
        return getLifetimeChartData(context);
      case 'Daily':
      default:
        // For daily data, we aggregate sessions based on their createdAt date.
        return getDailyLineChartData(context);
    }
  }

  // Daily chart implementation with animations
  LineChartData getDailyLineChartData(BuildContext context) {
    // Get the current local date, normalized to midnight.
    final now = DateTime.now().toLocal();
    final today = DateTime(now.year, now.month, now.day);

    // Build a list of the last 7 days (ordered oldest to newest).
    final last7Days = List.generate(7, (index) {
      return today.subtract(Duration(days: 6 - index));
    });

    // Aggregate sessions by normalized date.
    DateTime normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

    Map<DateTime, int> sessionCounts = {};
    for (var session in widget.dailySessions) {
      final sessionDate = normalizeDate(session.createdAt.toLocal());
      sessionCounts[sessionDate] = (sessionCounts[sessionDate] ?? 0) +
          (session.completedSessionsPersist ?? 0);
    }

    // Build the chart spots for both sessions and tasks.
    List<FlSpot> sessionSpots = [];
    List<FlSpot> taskSpots = [];

    // We'll use explicit, evenly spaced x values
    for (var i = 0; i < last7Days.length; i++) {
      final day = last7Days[i];
      // Use index as X value to ensure even spacing (multiply by 2 for more space between points)
      double x = i.toDouble() * 2;
      double sessionY = sessionCounts[day]?.toDouble() ?? 0;
      double taskY = i < widget.dailyTasksData.length
          ? widget.dailyTasksData[i].toDouble()
          : 0;

      // Apply animation to y values
      sessionY = sessionY * _animation.value;
      taskY = taskY * _animation.value;

      sessionSpots.add(FlSpot(x, sessionY));
      taskSpots.add(FlSpot(x, taskY));
    }

    // Calculate original max Y (before animation applied) for proper scaling
    double maxY = 5.0; // Default minimum
    final originalSessionY = widget.dailySessions.isEmpty
        ? [0.0]
        : last7Days.map((day) => sessionCounts[day]?.toDouble() ?? 0).toList();
    final originalTaskY =
        widget.dailyTasksData.map((v) => v.toDouble()).toList();

    if (originalSessionY.isNotEmpty || originalTaskY.isNotEmpty) {
      final allYValues = [...originalSessionY, ...originalTaskY];
      if (allYValues.isNotEmpty) {
        maxY = allYValues.reduce((a, b) => a > b ? a : b);
        maxY = maxY == 0
            ? 5.0
            : maxY; // Ensure we have a reasonable Y scale even if all data is 0
      }
    }

    // Custom date labels function with animation
    Widget customDateLabelWidget(double value, TitleMeta meta) {
      // Find which day this x-value corresponds to
      int index =
          (value / 2).round(); // Divide by 2 because we multiplied by 2 above

      if (index >= 0 && index < last7Days.length) {
        final date = last7Days[index];
        final formattedDate = DateFormat('M/d').format(date);
        // Animate label opacity
        final opacity = math.min(1.0, _animation.value * 1.5);

        return Opacity(
          opacity: opacity,
          child: SideTitleWidget(
            meta: meta,
            space: 10,
            child: Text(
              formattedDate,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }

      return const SizedBox.shrink();
    }

    return LineChartData(
      lineTouchData: getLineTouchData(),
      gridData: getAnimatedGridData(),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            // Use custom interval calculation that matches our x-value spacing
            interval: 2.0, // Match the multiplication factor we used earlier
            getTitlesWidget: customDateLabelWidget,
          ),
        ),
        leftTitles: AxisTitles(
          // Use our fixed position titles to avoid duplicates
          sideTitles: getAnimatedLeftTitles(maxY),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: getAnimatedBorderData(),
      lineBarsData: [
        // Tasks line
        getAnimatedLineChartBarData(
          taskSpots,
          Theme.of(context).colorScheme.primary,
          0,
          true,
        ),
        // Sessions line
        getAnimatedLineChartBarData(
          sessionSpots,
          Theme.of(context).colorScheme.secondary,
          1,
          true,
        ),
      ],
      minX: 0,
      maxX: (last7Days.length - 1) * 2,
      minY: 0,
      maxY: maxY * 1.1, // Add 10% padding at the top
    );
  }

  // Weekly chart implementation with animations
  LineChartData getWeeklyChartData(BuildContext context) {
    // Get the current date to calculate week ranges
    final now = DateTime.now().toLocal();

    // Create week labels for the x-axis (last 7 weeks)
    final List<String> weekLabels = [];
    for (int i = 6; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday % 7 + (i * 7)));
      final weekEnd = weekStart.add(const Duration(days: 6));

      // Format as "MM/DD-MM/DD"
      final startStr = DateFormat('M/d').format(weekStart);
      final endStr = DateFormat('M/d').format(weekEnd);
      weekLabels.add('$startStr-$endStr');
    }

    // Build data spots for tasks and sessions
    List<FlSpot> taskSpots = [];
    List<FlSpot> sessionSpots = [];

    // Use a wider spacing for better readability
    const double xSpacing = 2.0;

    for (int i = 0; i < weekLabels.length; i++) {
      double x = i.toDouble() * xSpacing;

      // Get data values, handling potential index out of range
      double taskY = i < widget.weeklyTasksData.length
          ? widget.weeklyTasksData[i].toDouble()
          : 0;
      double sessionY = i < widget.weeklySessionsData.length
          ? widget.weeklySessionsData[i].toDouble()
          : 0;

      // Apply animation
      taskY = taskY * _animation.value;
      sessionY = sessionY * _animation.value;

      taskSpots.add(FlSpot(x, taskY));
      sessionSpots.add(FlSpot(x, sessionY));
    }

    // Calculate max Y for proper scaling (using original values before animation)
    double maxY = 5.0; // Default minimum
    final originalTaskY =
        widget.weeklyTasksData.map((v) => v.toDouble()).toList();
    final originalSessionY =
        widget.weeklySessionsData.map((v) => v.toDouble()).toList();
    final allValues = [...originalTaskY, ...originalSessionY];

    if (allValues.isNotEmpty) {
      maxY = allValues.reduce((a, b) => a > b ? a : b);
      maxY = maxY == 0
          ? 5.0
          : maxY; // Ensure we have a reasonable Y scale even if all data is 0
    }

    // Custom x-axis label widget using our weekLabels
    Widget customWeekLabelWidget(double value, TitleMeta meta) {
      final index = (value / xSpacing).round();
      if (index >= 0 && index < weekLabels.length) {
        // Animate label opacity
        final opacity = math.min(1.0, _animation.value * 1.5);

        return Opacity(
          opacity: opacity,
          child: SideTitleWidget(
            meta: meta,
            space: 10,
            child: Text(
              weekLabels[index],
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return LineChartData(
      lineTouchData: getLineTouchData(),
      gridData: getAnimatedGridData(),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36, // Increased for multi-line labels
            interval: xSpacing,
            getTitlesWidget: customWeekLabelWidget,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: getAnimatedLeftTitles(maxY),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: getAnimatedBorderData(),
      lineBarsData: [
        // Tasks line
        getAnimatedLineChartBarData(
          taskSpots,
          Theme.of(context).colorScheme.primary,
          0,
          true,
        ),
        // Sessions line
        getAnimatedLineChartBarData(
          sessionSpots,
          Theme.of(context).colorScheme.secondary,
          1,
          true,
        ),
      ],
      // Keep tighter bounds on the x-axis
      minX: 0,
      maxX: (weekLabels.length - 1) * xSpacing,
      minY: 0,
      maxY: maxY * 1.1, // Add 10% padding at the top
    );
  }

  // Monthly chart implementation with animations
  LineChartData getMonthlyChartData(BuildContext context) {
    // Get the current date to calculate month ranges
    final now = DateTime.now().toLocal();

    // Create month labels for the x-axis (last 7 months)
    final List<String> monthLabels = [];
    for (int i = 6; i >= 0; i--) {
      final year = now.month - i <= 0 ? now.year - 1 : now.year;
      final month = now.month - i <= 0 ? now.month - i + 12 : now.month - i;
      final monthDate = DateTime(year, month, 1);

      // Format as "MMM YY" (e.g., "Jan 23")
      final monthStr = DateFormat('MMM').format(monthDate);
      final yearStr = DateFormat('yy').format(monthDate);
      monthLabels.add('$monthStr $yearStr');
    }

    // Build data spots for tasks and sessions
    List<FlSpot> taskSpots = [];
    List<FlSpot> sessionSpots = [];

    // Use a wider spacing for better readability
    const double xSpacing = 2.0;

    for (int i = 0; i < monthLabels.length; i++) {
      double x = i.toDouble() * xSpacing;

      // Get data values, handling potential index out of range
      double taskY = i < widget.monthlyTasksData.length
          ? widget.monthlyTasksData[i].toDouble()
          : 0;
      double sessionY = i < widget.monthlySessionsData.length
          ? widget.monthlySessionsData[i].toDouble()
          : 0;

      // Apply animation
      taskY = taskY * _animation.value;
      sessionY = sessionY * _animation.value;

      taskSpots.add(FlSpot(x, taskY));
      sessionSpots.add(FlSpot(x, sessionY));
    }

    // Calculate max Y for proper scaling (using original values before animation)
    double maxY = 5.0; // Default minimum
    final originalTaskY =
        widget.monthlyTasksData.map((v) => v.toDouble()).toList();
    final originalSessionY =
        widget.monthlySessionsData.map((v) => v.toDouble()).toList();
    final allValues = [...originalTaskY, ...originalSessionY];

    if (allValues.isNotEmpty) {
      maxY = allValues.reduce((a, b) => a > b ? a : b);
      maxY = maxY == 0
          ? 5.0
          : maxY; // Ensure we have a reasonable Y scale even if all data is 0
    }

    // Custom x-axis label widget using our monthLabels
    Widget customMonthLabelWidget(double value, TitleMeta meta) {
      final index = (value / xSpacing).round();
      if (index >= 0 && index < monthLabels.length) {
        // Animate label opacity
        final opacity = math.min(1.0, _animation.value * 1.5);

        return Opacity(
          opacity: opacity,
          child: SideTitleWidget(
            meta: meta,
            space: 10,
            child: Text(
              monthLabels[index],
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return LineChartData(
      lineTouchData: getLineTouchData(),
      gridData: getAnimatedGridData(),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: xSpacing,
            getTitlesWidget: customMonthLabelWidget,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: getAnimatedLeftTitles(maxY),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: getAnimatedBorderData(),
      lineBarsData: [
        // Tasks line
        getAnimatedLineChartBarData(
          taskSpots,
          Theme.of(context).colorScheme.primary,
          0,
          true,
        ),
        // Sessions line
        getAnimatedLineChartBarData(
          sessionSpots,
          Theme.of(context).colorScheme.secondary,
          1,
          true,
        ),
      ],
      minX: 0,
      maxX: (monthLabels.length - 1) * xSpacing,
      minY: 0,
      maxY: maxY * 1.1, // Add 10% padding at the top
    );
  }

  // Lifetime chart implementation with animations
  LineChartData getLifetimeChartData(BuildContext context) {
    // Get the current date to calculate period ranges
    final now = DateTime.now().toLocal();

    // Calculate period labels - for lifetime view, we'll use quarters or years
    // depending on how much data we have
    final List<String> periodLabels = [];

    // Generate period labels (either by quarter or year)
    bool useQuarters = widget.lifetimeSessionsData.length <= 8;
    if (useQuarters) {
      // For shorter timeframes, use quarters
      for (int i = 6; i >= 0; i--) {
        final monthsBack = i * 3; // 3 months per quarter
        final date = DateTime(
            now.year -
                (now.month <= monthsBack % 12 ? 1 : 0) -
                (monthsBack ~/ 12),
            ((now.month - monthsBack - 1) % 12) + 1,
            1);

        // Format as "Q1 YY" or "Q2 YY"
        final quarter = ((date.month - 1) ~/ 3) + 1;
        final yearStr = DateFormat('yy').format(date);
        periodLabels.add('Q$quarter $yearStr');
      }
    } else {
      // For longer timeframes, use years or half-years
      for (int i = 6; i >= 0; i--) {
        final year = now.year - i ~/ 2;
        final half = i % 2 == 0 ? 'H2' : 'H1'; // First or second half of year
        periodLabels.add('$half $year');
      }
    }

    // Build data spots for tasks and sessions
    List<FlSpot> taskSpots = [];
    List<FlSpot> sessionSpots = [];

    // Use a wider spacing for better readability
    const double xSpacing = 2.0;

    for (int i = 0; i < periodLabels.length; i++) {
      double x = i.toDouble() * xSpacing;

      // Get data values, handling potential index out of range
      double taskY = i < widget.lifetimeTasksData.length
          ? widget.lifetimeTasksData[i].toDouble()
          : 0;
      double sessionY = i < widget.lifetimeSessionsData.length
          ? widget.lifetimeSessionsData[i].toDouble()
          : 0;

      // Apply animation
      taskY = taskY * _animation.value;
      sessionY = sessionY * _animation.value;

      taskSpots.add(FlSpot(x, taskY));
      sessionSpots.add(FlSpot(x, sessionY));
    }

    // Calculate max Y for proper scaling (using original values before animation)
    double maxY = 5.0; // Default minimum
    final originalTaskY =
        widget.lifetimeTasksData.map((v) => v.toDouble()).toList();
    final originalSessionY =
        widget.lifetimeSessionsData.map((v) => v.toDouble()).toList();
    final allValues = [...originalTaskY, ...originalSessionY];

    if (allValues.isNotEmpty) {
      maxY = allValues.reduce((a, b) => a > b ? a : b);
      maxY = maxY == 0
          ? 5.0
          : maxY; // Ensure we have a reasonable Y scale even if all data is 0
    }

    // Custom x-axis label widget using our periodLabels
    Widget customPeriodLabelWidget(double value, TitleMeta meta) {
      final index = (value / xSpacing).round();
      if (index >= 0 && index < periodLabels.length) {
        // Animate label opacity
        final opacity = math.min(1.0, _animation.value * 1.5);

        return Opacity(
          opacity: opacity,
          child: SideTitleWidget(
            meta: meta,
            space: 10,
            child: Text(
              periodLabels[index],
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return LineChartData(
      lineTouchData: getLineTouchData(),
      gridData: getAnimatedGridData(),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: xSpacing,
            getTitlesWidget: customPeriodLabelWidget,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: getAnimatedLeftTitles(maxY),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: getAnimatedBorderData(),
      lineBarsData: [
        // Tasks line
        getAnimatedLineChartBarData(
          taskSpots,
          Theme.of(context).colorScheme.primary,
          0,
          true,
        ),
        // Sessions line
        getAnimatedLineChartBarData(
          sessionSpots,
          Theme.of(context).colorScheme.secondary,
          1,
          true,
        ),
      ],
      minX: 0,
      maxX: (periodLabels.length - 1) * xSpacing,
      minY: 0,
      maxY: maxY * 1.1, // Add 10% padding at the top
    );
  }

  // Enhanced touch data with interactive effects
  // Update this method in your AnimatedStatsChartWidget class
  // Custom solution for edge tooltip issues with fl_chart v0.70.2
  LineTouchData getLineTouchData() {
    return LineTouchData(
      enabled: true,
      getTouchedSpotIndicator:
          (LineChartBarData barData, List<int> spotIndexes) {
        return spotIndexes.map((spotIndex) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: barData.color,
              strokeWidth: 3,
            ),
            FlDotData(
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6,
                  color: Colors.white,
                  strokeWidth: 3,
                  // strokeColor: barData.color,
                );
              },
            ),
          );
        }).toList();
      },
      touchTooltipData: LineTouchTooltipData(
        tooltipRoundedRadius: 8,
        tooltipPadding: const EdgeInsets.all(8),
        tooltipMargin: 0, // Set to 0 to avoid edge cutoff issues
        // tooltipBgColor: Colors.black.withOpacity(0.7),
        tooltipHorizontalAlignment: FLHorizontalAlignment.left,
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((spot) {
            final lineIndex = spot.barIndex;
            final title = lineIndex == 0 ? 'Tasks' : 'Sessions';

            // Get the original value (not the animated one)
            final originalValue = (spot.y / _animation.value).round();

            // Create a fixed-width placeholder to ensure tooltip isn't cut off
            // Using a short format for edge cases
            return LineTooltipItem(
              '${title[0]}: $originalValue', // Just use first letter of title to save space
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            );
          }).toList();
        },
      ),
      handleBuiltInTouches: true,
      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
        setState(() {
          if (event is FlPanEndEvent ||
              event is FlLongPressEnd ||
              event is FlTapUpEvent ||
              touchResponse == null ||
              touchResponse.lineBarSpots == null ||
              touchResponse.lineBarSpots!.isEmpty) {
            _touchedSpot = null;
            _touchedLineIndex = null;
          } else {
            _touchedSpot = FlSpot(touchResponse.lineBarSpots![0].x,
                touchResponse.lineBarSpots![0].y);
            _touchedLineIndex = touchResponse.lineBarSpots![0].barIndex;
          }
        });
      },
    );
  }

  // Get Y-axis titles with appropriate intervals and animation
  SideTitles getAnimatedLeftTitles(double maxY) {
    // Choose appropriate interval based on the max Y value
    double interval;
    if (maxY <= 3) {
      interval = 1.0; // For small values, show each integer
    } else if (maxY <= 10) {
      interval = 2.0; // For medium values, show every other integer
    } else if (maxY <= 30) {
      interval = 5.0;
    } else if (maxY <= 100) {
      interval = 20.0;
    } else {
      interval =
          (maxY / 5).ceilToDouble(); // For large values, divide into ~5 parts
    }

    return SideTitles(
      showTitles: true,
      reservedSize: 30,
      interval: interval,
      getTitlesWidget: (value, meta) {
        // Only show integer values to avoid duplicates
        if (value == value.roundToDouble() && value % interval == 0) {
          // Animate label opacity
          final opacity = math.min(1.0, _animation.value * 1.5);

          return Opacity(
            opacity: opacity,
            child: SideTitleWidget(
              meta: meta,
              child: Text(
                value.toInt().toString(),
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  FlGridData getAnimatedGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      drawHorizontalLine: true,
      // Animated grid lines
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey.withOpacity(0.2 * _animation.value),
          strokeWidth: 1,
          dashArray: [5, 5],
        );
      },
      getDrawingVerticalLine: (value) {
        return FlLine(
          color: Colors.grey.withOpacity(0.1 * _animation.value),
          strokeWidth: 1,
          dashArray: [5, 5],
        );
      },
    );
  }

  FlBorderData getAnimatedBorderData() {
    return FlBorderData(
      show: true,
      border: Border(
        bottom: BorderSide(
          color: AppColors.primary.withOpacity(0.2 * _animation.value),
          width: 4 * _animation.value,
        ),
        left: const BorderSide(color: Colors.transparent),
        right: const BorderSide(color: Colors.transparent),
        top: const BorderSide(color: Colors.transparent),
      ),
    );
  }

  // Enhanced line chart bar data with animation and interactive effects
  LineChartBarData getAnimatedLineChartBarData(
    List<FlSpot> spots,
    Color color,
    int barIndex,
    bool showAreaBelow,
  ) {
    final bool isSelected = _touchedLineIndex == barIndex;

    return LineChartBarData(
      spots: spots,
      isCurved: false, // Keep this setting from your original code
      color: isSelected ? color : color.withOpacity(0.8),
      barWidth: isSelected ? 5 : 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, bar, index) {
          final isThisSpotTouched = _touchedSpot != null &&
              _touchedLineIndex == barIndex &&
              _touchedSpot!.x == spot.x &&
              _touchedSpot!.y == spot.y;

          final radius = isThisSpotTouched ? 6.0 : 3.5;

          return FlDotCirclePainter(
            radius: radius,
            color: Colors.white,
            strokeWidth: 2.5,
            strokeColor: isThisSpotTouched
                ? color.withOpacity(1.0)
                : color.withOpacity(0.7),
          );
        },
      ),
      belowBarData: BarAreaData(
        show: showAreaBelow,
        color: color.withOpacity(0.15 * _animation.value),
        // Gradient effect
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.4 * _animation.value),
            color.withOpacity(0.0),
          ],
        ),
      ),
    );
  }

  // For non-daily, non-weekly, non-monthly timeframes (lifetime)
  LineChartData getLineChartData(BuildContext context, List<int> tasksData,
      List<int> sessionsData, double maxX) {
    // Find maximum Y value for scaling
    double maxY = 5.0;
    if (tasksData.isNotEmpty || sessionsData.isNotEmpty) {
      final allValues = [...tasksData, ...sessionsData];
      if (allValues.isNotEmpty) {
        maxY = allValues.reduce((a, b) => a > b ? a : b).toDouble();
        if (maxY == 0) maxY = 5.0;
      }
    }

    // Create animated line data with spots
    List<FlSpot> taskSpots = [];
    List<FlSpot> sessionSpots = [];

    for (int i = 0; i < tasksData.length; i++) {
      taskSpots.add(
          FlSpot(i.toDouble(), tasksData[i].toDouble() * _animation.value));
    }

    for (int i = 0; i < sessionsData.length; i++) {
      sessionSpots.add(
          FlSpot(i.toDouble(), sessionsData[i].toDouble() * _animation.value));
    }

    return LineChartData(
      lineTouchData: getLineTouchData(),
      gridData: getAnimatedGridData(),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: getAnimatedBottomTitles(),
        ),
        leftTitles: AxisTitles(
          // Use fixed positions for Y axis
          sideTitles: getAnimatedLeftTitles(maxY),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: getAnimatedBorderData(),
      lineBarsData: [
        getAnimatedLineChartBarData(
          taskSpots,
          Theme.of(context).colorScheme.primary,
          0,
          true,
        ),
        getAnimatedLineChartBarData(
          sessionSpots,
          Theme.of(context).colorScheme.secondary,
          1,
          true,
        ),
      ],
      minX: 0,
      maxX: maxX,
      maxY: maxY * 1.1,
      minY: 0,
    );
  }

  SideTitles getAnimatedBottomTitles() {
    return SideTitles(
      showTitles: true,
      reservedSize: 32,
      interval: 1.0,
      getTitlesWidget: (value, meta) {
        // Animate label opacity
        final opacity = math.min(1.0, _animation.value * 1.5);

        // For non-daily timeframes
        const style = TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        );

        String text;
        switch (widget.timeframe) {
          case 'Weekly':
            text = 'Week ${value.toInt() + 1}';
            break;
          case 'Monthly':
            // Get month label
            final months = [
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'May',
              'Jun',
              'Jul',
              'Aug',
              'Sep',
              'Oct',
              'Nov',
              'Dec'
            ];
            text = months[value.toInt() % 12];
            break;
          case 'Lifetime':
            // Simple lifetime labels
            text = value.toInt() == 0 ? 'Begin' : 'Now';
            break;
          default:
            text = value.toInt().toString();
            break;
        }

        return Opacity(
          opacity: opacity,
          child: SideTitleWidget(
            meta: meta,
            space: 10,
            child: Text(text, style: style),
          ),
        );
      },
    );
  }
}
