import 'package:do_it/common_widget/app_bar_widget.dart';
import 'package:do_it/common_widget/loader_widget.dart';
import 'package:do_it/common_widget/text_small_widget.dart';
import 'package:do_it/common_widget/text_widget.dart';
import 'package:do_it/features/pomodoro/domain/models/pomodoro.dart';
import 'package:do_it/features/pomodoro/presentation/pomodoro_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../pomodoro/presentation/pomodor_config_state.dart';
import '../../todo/presentation/todo_cubit.dart';
import '../../todo/presentation/todo_state.dart';
import 'stats_chart_widget.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String _selectedTimeframe = 'Daily';

  @override
  void initState() {
    super.initState();

    // getData();
  }

  Future<void> getData() async {
    await Future.wait([
      context.read<TodoCubit>().dailyCompletedTasksData(),
      context.read<TodoCubit>().weeklyCompletedTasksData(),
      context.read<TodoCubit>().monthlyCompletedTasksData(),
      context.read<TodoCubit>().lifetimeCompletedTasksData(),
      context.read<PomodoroCubit>().dailySessionsData(),
      context.read<PomodoroCubit>().weeklySessionsData(),
      context.read<PomodoroCubit>().monthlySessionsData(),
      context.read<PomodoroCubit>().lifetimeSessionsData(),
    ]);
  }

  final List<int> dailyTasksData = [4, 6, 3, 5, 7, 2, 8];
  final List<int> weeklyTasksData = [3, 5, 2, 4, 6, 1, 7];
  final List<int> monthlyTasksData = [80, 85];
  final List<int> lifetimeTasksData = [0, 350];

  final List<int> dailySessionsData = [1, 2, 3, 4, 5, 6, 7];
  final List<int> weeklySessionsData = [2, 3, 4, 5, 6, 7, 8];
  final List<int> monthlySessionsData = [40, 45, 50, 55, 60, 65, 70];
  final List<int> lifetimeSessionsData = [2, 3, 4, 5, 6, 7, 8];

  Future<void> _refreshData() async {
    // Refresh data based on the selected timeframe
    switch (_selectedTimeframe) {
      case 'Daily':
        await Future.wait([
          context.read<TodoCubit>().dailyCompletedTasksData(),
          context.read<PomodoroCubit>().dailySessionsData(),
        ]);
        break;
      case 'Weekly':
        await Future.wait([
          context.read<TodoCubit>().weeklyCompletedTasksData(),
          context.read<PomodoroCubit>().weeklySessionsData(),
        ]);
        break;
      case 'Monthly':
        await Future.wait([
          context.read<TodoCubit>().monthlyCompletedTasksData(),
          context.read<PomodoroCubit>().monthlySessionsData(),
        ]);
        break;
      case 'Lifetime':
        await Future.wait([
          context.read<TodoCubit>().lifetimeCompletedTasksData(),
          context.read<PomodoroCubit>().lifetimeSessionsData(),
        ]);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Stats',
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: FutureBuilder<void>(
              future: getData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoaderWidget());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: TextSmallWidget(text: 'Somenthing went wrong'));
                } else {
                  return SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(), // ensures scrollability even if content is small
                    padding: const EdgeInsets.all(16.0),
                    child: BlocBuilder<TodoCubit, TodoState>(
                        builder: (context, todoState) {
                      return BlocBuilder<PomodoroCubit, PomodoroConfigState>(
                          builder: (context, pomodoroState) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 40,
                          children: [
                            Center(
                              child: SizedBox(
                                width: 200,
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _selectedTimeframe,
                                  items: [
                                    'Daily',
                                    'Weekly',
                                    'Monthly',
                                    'Lifetime'
                                  ].map((String value) {
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
                              ),
                            ),
                            todoState.dailyCompletedTasksData.isNotEmpty ||
                                    pomodoroState
                                        .dailySessionsData.isNotEmpty ||
                                    todoState
                                        .weeklyCompletedTasksData.isNotEmpty ||
                                    todoState
                                        .monthlyCompletedTasksData.isNotEmpty ||
                                    todoState.lifetimeCompletedTasksData
                                        .isNotEmpty ||
                                    pomodoroState
                                        .weeklySessionsData.isNotEmpty ||
                                    pomodoroState
                                        .monthlySessionsData.isNotEmpty ||
                                    pomodoroState
                                        .lifeTimeSessionsData.isNotEmpty
                                ? SizedBox(
                                    height: 300,
                                    child: StatsChartWidget(
                                      timeframe: _selectedTimeframe,
                                      dailyTasksData:
                                          todoState.dailyCompletedTasksData,
                                      weeklyTasksData:
                                          todoState.weeklyCompletedTasksData,
                                      monthlyTasksData:
                                          todoState.monthlyCompletedTasksData,
                                      lifetimeTasksData:
                                          todoState.lifetimeCompletedTasksData,
                                      dailySessions:
                                          pomodoroState.dailySessionsData,
                                      weeklySessionsData:
                                          pomodoroState.weeklySessionsData,
                                      monthlySessionsData:
                                          pomodoroState.monthlySessionsData,
                                      lifetimeSessionsData:
                                          pomodoroState.lifeTimeSessionsData,
                                    ),
                                    // StatsChartWidget(
                                    //   timeframe: _selectedTimeframe,
                                    //   dailyTasksData: dailyTasksData,
                                    //   weeklyTasksData: weeklyTasksData,
                                    //   monthlyTasksData: monthlyTasksData,
                                    //   lifetimeTasksData: lifetimeTasksData,
                                    //   dailySessionsData: dailySessionsData,
                                    //   weeklySessionsData: weeklySessionsData,
                                    //   monthlySessionsData: monthlySessionsData,
                                    //   lifetimeSessionsData: lifetimeSessionsData,
                                    // ),
                                  )
                                : const TextSmallWidget(
                                    text:
                                        'Complete a task or session to see stats',
                                  ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const TextWidget(text: 'Legends'),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  spacing: 25,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 10,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const TextSmallWidget(
                                      text: 'Completed Tasks',
                                    ),
                                  ],
                                ),
                                Row(
                                  spacing: 25,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 10,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    const TextSmallWidget(
                                      text: 'Completed Sessions',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        );
                      });
                    }),
                  );
                }
              }),
        ),
      ),
    );
  }
}
