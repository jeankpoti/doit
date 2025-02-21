import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';

class StatsChartWidget extends StatelessWidget {
  final String timeframe;
  final List<int> dailyTasksData;
  final List<int> weeklyTasksData;
  final List<int> monthlyTasksData;
  final List<int> lifetimeTasksData;
  final List<int> dailySessionsData;
  final List<int> weeklySessionsData;
  final List<int> monthlySessionsData;
  final List<int> lifetimeSessionsData;

  const StatsChartWidget({
    required this.timeframe,
    required this.dailyTasksData,
    required this.weeklyTasksData,
    required this.monthlyTasksData,
    required this.lifetimeTasksData,
    required this.dailySessionsData,
    required this.weeklySessionsData,
    required this.monthlySessionsData,
    required this.lifetimeSessionsData,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      getChartData(context),
      duration: const Duration(milliseconds: 250),
    );
  }

  LineChartData getChartData(context) {
    switch (timeframe) {
      case 'Weekly':
        return getLineChartData(context, weeklyTasksData, weeklySessionsData,
            weeklyTasksData.length - 1);
      case 'Monthly':
        return getLineChartData(context, monthlyTasksData, monthlySessionsData,
            monthlyTasksData.length - 1);
      case 'Lifetime':
        return getLineChartData(
          context,
          lifetimeTasksData,
          lifetimeSessionsData,
          lifetimeTasksData.length - 1,
        );
      case 'Daily':
      default:
        return getLineChartData(
          context,
          dailyTasksData,
          dailySessionsData,
          dailyTasksData.length - 1,
        );
    }
  }

  LineChartData getLineChartData(
      context, List<int> tasksData, List<int> sessionsData, double maxX) {
    return LineChartData(
      lineTouchData: lineTouchData,
      gridData: gridData,
      titlesData: titlesData,
      borderData: borderData,
      lineBarsData: [
        getLineChartBarData(
          tasksData,
          Theme.of(context).colorScheme.primary,
        ),
        getLineChartBarData(
          sessionsData,
          Theme.of(context).colorScheme.secondary,
        ),
      ],
      minX: 0,
      maxX: maxX,
      maxY:
          (tasksData + sessionsData).reduce((a, b) => a > b ? a : b).toDouble(),
      minY: 0,
    );
  }

  LineTouchData get lineTouchData => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.8),
        ),
      );

  FlTitlesData get titlesData => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    String text = value.toInt().toString();

    return SideTitleWidget(
      meta: meta,
      child: Text(
        text,
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  SideTitles leftTitles() {
    double interval;
    switch (timeframe) {
      case 'Weekly':
        interval = 5;
        break;
      case 'Monthly':
        interval = 10;
        break;
      case 'Lifetime':
        interval = 50;
        break;
      case 'Daily':
      default:
        interval = 1;
        break;
    }
    return SideTitles(
      getTitlesWidget: leftTitleWidgets,
      showTitles: true,
      interval: interval,
      reservedSize: 30,
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    String text;
    switch (timeframe) {
      case 'Weekly':
        text = 'Week ${value.toInt() + 1}';
        break;
      case 'Monthly':
        text = _getMonthLabel(value.toInt());
        break;
      case 'Lifetime':
        text = _getLifeTimeLabel(value.toInt());
        break;
      case 'Daily':
      default:
        text = _getDayLabel(value.toInt());
        break;
    }

    return SideTitleWidget(
      meta: meta,
      space: 10,
      child: Text(
        text,
        style: style,
      ),
    );
  }

  String _getMonthLabel(int monthIndex) {
    const months = [
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
    return months[monthIndex];
  }

  String _getLifeTimeLabel(int lifeTimeIndex) {
    const lifeTime = [
      'Beginning',
      ' Today',
    ];
    return lifeTime[lifeTimeIndex];
  }

  String _getDayLabel(int dayIndex) {
    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return days[dayIndex];
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => const FlGridData(show: false);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom:
              BorderSide(color: AppColors.primary.withOpacity(0.2), width: 4),
          left: const BorderSide(color: Colors.transparent),
          right: const BorderSide(color: Colors.transparent),
          top: const BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData getLineChartBarData(List<int> data, Color color) =>
      LineChartBarData(
        isCurved: false,
        color: color,
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: true),
        spots: data
            .asMap()
            .entries
            .map(
                (entry) => FlSpot(entry.key.toDouble(), entry.value.toDouble()))
            .toList(),
      );
}

// class StatsChartWidget extends StatelessWidget {
//   const StatsChartWidget({required this.isShowingMainData});

//   final bool isShowingMainData;

//   @override
//   Widget build(BuildContext context) {
//     return LineChart(
//       isShowingMainData ? sampleData1 : sampleData2,
//       duration: const Duration(milliseconds: 250),
//     );
//   }

//   LineChartData get sampleData1 => LineChartData(
//         lineTouchData: lineTouchData1,
//         gridData: gridData,
//         titlesData: titlesData1,
//         borderData: borderData,
//         lineBarsData: lineBarsData1,
//         minX: 0,
//         maxX: 14,
//         maxY: 4,
//         minY: 0,
//       );

//   LineChartData get sampleData2 => LineChartData(
//         lineTouchData: lineTouchData2,
//         gridData: gridData,
//         titlesData: titlesData2,
//         borderData: borderData,
//         lineBarsData: lineBarsData2,
//         minX: 0,
//         maxX: 14,
//         maxY: 6,
//         minY: 0,
//       );

//   LineTouchData get lineTouchData1 => LineTouchData(
//         handleBuiltInTouches: true,
//         touchTooltipData: LineTouchTooltipData(
//           getTooltipColor: (touchedSpot) =>
//               Colors.blueGrey.withValues(alpha: 0.8),
//         ),
//       );

//   FlTitlesData get titlesData1 => FlTitlesData(
//         bottomTitles: AxisTitles(
//           sideTitles: bottomTitles,
//         ),
//         rightTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         topTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         leftTitles: AxisTitles(
//           sideTitles: leftTitles(),
//         ),
//       );

//   List<LineChartBarData> get lineBarsData1 => [
//         completedTodosLineChartBarData,
//         completedSessionsLineChartBarData,
//         // lineChartBarData1_3,
//       ];

//   LineTouchData get lineTouchData2 => const LineTouchData(
//         enabled: false,
//       );

//   FlTitlesData get titlesData2 => FlTitlesData(
//         bottomTitles: AxisTitles(
//           sideTitles: bottomTitles,
//         ),
//         rightTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         topTitles: const AxisTitles(
//           sideTitles: SideTitles(showTitles: false),
//         ),
//         leftTitles: AxisTitles(
//           sideTitles: leftTitles(),
//         ),
//       );

//   List<LineChartBarData> get lineBarsData2 => [
//         lineChartBarData2_1,
//         // lineChartBarData2_2,
//         lineChartBarData2_3,
//       ];

//   Widget leftTitleWidgets(double value, TitleMeta meta) {
//     const style = TextStyle(
//       fontWeight: FontWeight.bold,
//       fontSize: 14,
//     );
//     String text;
//     switch (value.toInt()) {
//       case 1:
//         text = '1';
//         break;
//       case 2:
//         text = '2';
//         break;
//       case 3:
//         text = '3';
//         break;
//       case 4:
//         text = '5';
//         break;
//       case 5:
//         text = '6';
//         break;
//       default:
//         return Container();
//     }

//     return SideTitleWidget(
//       meta: meta,
//       child: Text(
//         text,
//         style: style,
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   SideTitles leftTitles() => SideTitles(
//         getTitlesWidget: leftTitleWidgets,
//         showTitles: true,
//         interval: 1,
//         reservedSize: 40,
//       );

//   Widget bottomTitleWidgets(double value, TitleMeta meta) {
//     const style = TextStyle(
//       fontWeight: FontWeight.bold,
//       fontSize: 16,
//     );
//     Widget text;
//     switch (value.toInt()) {
//       case 2:
//         text = const Text('SEPT', style: style);
//         break;
//       case 7:
//         text = const Text('OCT', style: style);
//         break;
//       case 12:
//         text = const Text('DEC', style: style);
//         break;
//       default:
//         text = const Text('');
//         break;
//     }

//     return SideTitleWidget(
//       meta: meta,
//       space: 10,
//       child: text,
//     );
//   }

//   SideTitles get bottomTitles => SideTitles(
//         showTitles: true,
//         reservedSize: 32,
//         interval: 1,
//         getTitlesWidget: bottomTitleWidgets,
//       );

//   FlGridData get gridData => const FlGridData(show: false);

//   FlBorderData get borderData => FlBorderData(
//         show: true,
//         border: Border(
//           bottom: BorderSide(
//               color: AppColors.primary.withValues(alpha: 0.2), width: 4),
//           left: const BorderSide(color: Colors.transparent),
//           right: const BorderSide(color: Colors.transparent),
//           top: const BorderSide(color: Colors.transparent),
//         ),
//       );

//   LineChartBarData get completedTodosLineChartBarData => LineChartBarData(
//         isCurved: true,
//         color: AppColors.contentColorGreen,
//         barWidth: 8,
//         isStrokeCapRound: true,
//         dotData: const FlDotData(show: false),
//         belowBarData: BarAreaData(show: false),
//         spots: const [
//           FlSpot(1, 1),
//           FlSpot(3, 1.5),
//           FlSpot(5, 1.4),
//           FlSpot(7, 3.4),
//           FlSpot(10, 2),
//           FlSpot(12, 2.2),
//           FlSpot(13, 1.8),
//         ],
//       );

//   LineChartBarData get completedSessionsLineChartBarData => LineChartBarData(
//         isCurved: true,
//         color: AppColors.contentColorPink,
//         barWidth: 8,
//         isStrokeCapRound: true,
//         dotData: const FlDotData(show: false),
//         belowBarData: BarAreaData(
//           show: false,
//           color: AppColors.contentColorPink.withValues(alpha: 0),
//         ),
//         spots: const [
//           FlSpot(1, 1),
//           FlSpot(3, 2.8),
//           FlSpot(7, 1.2),
//           FlSpot(10, 2.8),
//           FlSpot(12, 2.6),
//           FlSpot(13, 3.9),
//         ],
//       );

//   // LineChartBarData get lineChartBarData1_3 => LineChartBarData(
//   //       isCurved: true,
//   //       color: AppColors.contentColorCyan,
//   //       barWidth: 8,
//   //       isStrokeCapRound: true,
//   //       dotData: const FlDotData(show: false),
//   //       belowBarData: BarAreaData(show: false),
//   //       spots: const [
//   //         FlSpot(1, 2.8),
//   //         FlSpot(3, 1.9),
//   //         FlSpot(6, 3),
//   //         FlSpot(10, 1.3),
//   //         FlSpot(13, 2.5),
//   //       ],
//   //     );

//   LineChartBarData get lineChartBarData2_1 => LineChartBarData(
//         isCurved: true,
//         curveSmoothness: 0,
//         color: AppColors.contentColorGreen.withValues(alpha: 0.5),
//         barWidth: 4,
//         isStrokeCapRound: true,
//         dotData: const FlDotData(show: false),
//         belowBarData: BarAreaData(show: false),
//         spots: const [
//           FlSpot(0, 0),
//           FlSpot(3, 4),
//           FlSpot(5, 1.8),
//           FlSpot(7, 5),
//           FlSpot(10, 2),
//           FlSpot(12, 2.2),
//           FlSpot(13, 1.8),
//         ],
//       );

//   LineChartBarData get lineChartBarData2_2 => LineChartBarData(
//         isCurved: true,
//         color: AppColors.contentColorPink.withValues(alpha: 0.5),
//         barWidth: 4,
//         isStrokeCapRound: true,
//         dotData: const FlDotData(show: false),
//         belowBarData: BarAreaData(
//           show: true,
//           color: AppColors.contentColorPink.withValues(alpha: 0.2),
//         ),
//         spots: const [
//           FlSpot(1, 1),
//           FlSpot(3, 2.8),
//           FlSpot(7, 1.2),
//           FlSpot(10, 2.8),
//           FlSpot(12, 2.6),
//           FlSpot(13, 3.9),
//         ],
//       );

//   LineChartBarData get lineChartBarData2_3 => LineChartBarData(
//         isCurved: true,
//         curveSmoothness: 0,
//         color: AppColors.contentColorCyan.withValues(alpha: 0.5),
//         barWidth: 2,
//         isStrokeCapRound: true,
//         dotData: const FlDotData(show: true),
//         belowBarData: BarAreaData(show: false),
//         spots: const [
//           FlSpot(1, 3.8),
//           FlSpot(3, 1.9),
//           FlSpot(6, 5),
//           FlSpot(10, 3.3),
//           FlSpot(13, 4.5),
//         ],
//       );
// }

// class LineChartSample1 extends StatefulWidget {
//   const LineChartSample1({super.key});

//   @override
//   State<StatefulWidget> createState() => LineChartSample1State();
// }

// class LineChartSample1State extends State<LineChartSample1> {
//   late bool isShowingMainData;

//   @override
//   void initState() {
//     super.initState();
//     isShowingMainData = true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 1.23,
//       child: Stack(
//         children: <Widget>[
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               const SizedBox(
//                 height: 37,
//               ),
//               const Text(
//                 'Monthly Sales',
//                 style: TextStyle(
//                   color: AppColors.primary,
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 2,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(
//                 height: 37,
//               ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.only(right: 16, left: 6),
//                   child: StatsChartWidget(isShowingMainData: isShowingMainData),
//                 ),
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//             ],
//           ),
//           IconButton(
//             icon: Icon(
//               Icons.refresh,
//               color:
//                   Colors.white.withValues(alpha: isShowingMainData ? 1.0 : 0.5),
//             ),
//             onPressed: () {
//               setState(() {
//                 isShowingMainData = !isShowingMainData;
//               });
//             },
//           )
//         ],
//       ),
//     );
//   }
// }
