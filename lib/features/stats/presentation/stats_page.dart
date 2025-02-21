import 'package:do_it/common_widget/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../todo/presentation/todo_cubit.dart';
import '../../todo/presentation/todo_state.dart';
import 'stats_chart_widget.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({Key? key}) : super(key: key);

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String _selectedTimeframe = 'Daily';

  @override
  void initState() {
    super.initState();

    getData();
  }

  Future<void> getData() async {
    await Future.wait([
      context.read<TodoCubit>().dailyCompletedTasksData(),
      context.read<TodoCubit>().weeklyCompletedTasksData(),
      context.read<TodoCubit>().monthlyCompletedTasksData(),
      context.read<TodoCubit>().lifetimeCompletedTasksData(),
    ]);
  }

  final List<int> dailyTasksData = [4, 6];
  final List<int> weeklyTasksData = [3];
  final List<int> monthlyTasksData = [80, 85];
  final List<int> lifetimeTasksData = [0, 350];

  final List<int> dailySessionsData = [1];
  final List<int> weeklySessionsData = [2];
  final List<int> monthlySessionsData = [40, 45];
  final List<int> lifetimeSessionsData = [2];

  Future<void> _refreshData() async {
    // Refresh data based on the selected timeframe
    switch (_selectedTimeframe) {
      case 'Daily':
        await context.read<TodoCubit>().dailyCompletedTasksData();
        break;
      case 'Weekly':
        context.read<TodoCubit>().weeklyCompletedTasksData();
        break;
      case 'Monthly':
        context.read<TodoCubit>().monthlyCompletedTasksData();
        break;
      case 'Lifetime':
        context.read<TodoCubit>().lifetimeCompletedTasksData();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Stats',
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // ensures scrollability even if content is small
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<TodoCubit, TodoState>(builder: (context, state) {
              return Column(
                spacing: 40,
                children: [
                  DropdownButton<String>(
                    value: _selectedTimeframe,
                    items: ['Daily', 'Weekly', 'Monthly', 'Lifetime']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTimeframe = newValue!;
                      });
                    },
                  ),
                  SizedBox(
                    height: 300,
                    child: StatsChartWidget(
                      timeframe: _selectedTimeframe,
                      dailyTasksData: state.dailyCompletedTasksData,
                      weeklyTasksData: state.weeklyCompletedTasksData,
                      monthlyTasksData: state.monthlyCompletedTasksData,
                      lifetimeTasksData: state.lifetimeCompletedTasksData,
                      dailySessionsData: dailySessionsData,
                      weeklySessionsData: weeklySessionsData,
                      monthlySessionsData: monthlySessionsData,
                      lifetimeSessionsData: lifetimeSessionsData,
                    ),
                  ),
                ],
              );
            })),
      ),
    );
  }
}

// class StatsPage extends StatefulWidget {
//   // final List<Stats> dailyStats;

//   const StatsPage({super.key});

//   @override
//   State<StatsPage> createState() => _StatsPageState();
// }

// class _StatsPageState extends State<StatsPage> {
//   String _selectedTimeframe = 'Lifetime';

//   @override
//   Widget build(BuildContext context) {
//     // List<Stats> dailyStats = [
//     //   Stats(
//     //       completed: 3, date: DateTime.now().subtract(const Duration(days: 6))),
//     //   Stats(
//     //       completed: 4, date: DateTime.now().subtract(const Duration(days: 5))),
//     //   Stats(
//     //       completed: 5, date: DateTime.now().subtract(const Duration(days: 4))),
//     //   Stats(
//     //       completed: 3, date: DateTime.now().subtract(const Duration(days: 3))),
//     //   Stats(
//     //       completed: 6, date: DateTime.now().subtract(const Duration(days: 2))),
//     //   Stats(
//     //       completed: 4, date: DateTime.now().subtract(const Duration(days: 1))),
//     //   Stats(completed: 5, date: DateTime.now()),
//     // ];

//     final List<int> dailyData = [3, 5, 2, 4, 6, 1, 7];
//     final List<int> weeklyData = [20, 25, 22, 24, 26, 21, 27];
//     final List<int> monthlyData = [80, 85, 82, 84, 86, 81, 87];
//     final List<int> lifetimeData = [300, 350, 320, 340, 360, 310, 370];

//     return Scaffold(
//       appBar: const AppBarWidget(
//         title: 'Stats',
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             DropdownButton<String>(
//               value: _selectedTimeframe,
//               items: ['Daily', 'Weekly', 'Monthly', 'Lifetime']
//                   .map((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedTimeframe = newValue!;
//                 });
//               },
//             ),
//             SizedBox(
//               height: 300,
//               child: StatsChartWidget(
//                 timeframe: _selectedTimeframe,
//                 dailyData: dailyData,
//                 weeklyData: weeklyData,
//                 monthlyData: monthlyData,
//                 lifetimeData: lifetimeData,
//               ),
//             ),
//           ],
//         ),

//         // Column(
//         //   children: [
//         //     Text(
//         //       'Daily Completed Tasks',
//         //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         //     ),
//         //     SizedBox(height: 16),
//         //     // Display the chart with the stats data and target value.
//         //     SizedBox(
//         //       height: 300,
//         //       child: StatsChartWidget(
//         //         isShowingMainData: false,
//         //       ),
//         //     ),
//         //     SizedBox(height: 20),
//         //     // Additional insights can be added here.
//         //     Text(
//         //       'Keep an eye on your trends. If you notice dips in productivity, consider revising your schedule or breaking tasks into smaller steps!',
//         //       textAlign: TextAlign.center,
//         //     ),
//         //   ],
//         // ),
//       ),
//     );
//   }
// }
