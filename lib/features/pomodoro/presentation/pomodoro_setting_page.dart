import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common_widget/app_bar_widget.dart';
import '../../../common_widget/button_widget.dart';
import '../../../common_widget/list_tile_widget.dart';
import '../../../constants/session_list.dart';
import '../../../constants/time_list.dart';
import 'pomodor_config_state.dart';
import 'pomodoro_cubit.dart';

class PomodoroSettingPage extends StatefulWidget {
  const PomodoroSettingPage({super.key});

  @override
  State<PomodoroSettingPage> createState() => _PomodoroSettingPageState();
}

class _PomodoroSettingPageState extends State<PomodoroSettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Duration',
        isAction: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocBuilder<PomodoroCubit, PomodoroConfigState>(
            builder: (context, state) {
              return Column(
                children: [
                  ListTileWidget(
                    title: 'Focus Session',
                    duration: '${state.workDuration ~/ 60} min',
                    onPressed: () => _bottomSheet('Focus Session'),
                  ),
                  ListTileWidget(
                    title: 'Short Break',
                    duration: '${state.shortBreakDuration ~/ 60} min',
                    onPressed: () => _bottomSheet('Short Break'),
                  ),
                  ListTileWidget(
                    title: 'Long Break',
                    duration: '${state.longBreakDuration ~/ 60} min',
                    onPressed: () => _bottomSheet('Long Break'),
                  ),
                  ListTileWidget(
                    title: 'Long Break After',
                    duration: '${state.sessionCount} session(s)',
                    onPressed: () => _bottomSheet('Long Break After'),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ButtonWidget(
                      text: 'Save',
                      onPressed: () => {
                        context.read<PomodoroCubit>().saveSettings(),
                        Navigator.of(context).pop()
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _bottomSheet(String type) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final pomodoroCubit = context.read<PomodoroCubit>();

        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 350,
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 250,
                child: CupertinoPicker(
                    itemExtent: timeList.length.toDouble(),
                    onSelectedItemChanged: (int index) {
                      switch (type) {
                        case 'Focus Session':
                          pomodoroCubit.workDurationChanged(
                            timeList[index],
                          );
                          break;
                        case 'Short Break':
                          pomodoroCubit.shortBreakDurationChanged(
                            timeList[index],
                          );
                          break;
                        case 'Long Break':
                          pomodoroCubit.longBreakDurationChanged(
                            timeList[index],
                          );
                          break;
                        case 'Long Break After':
                          pomodoroCubit.setSessionCount(
                            sessionList[index],
                          );
                          break;
                        default:
                          // Handle unknown type if necessary
                          break;
                      }
                      // if (type == 'Focus Session') {
                      //   pomodoroCubit.workDurationChanged(
                      //     timeList[index],
                      //   );
                      // } else if (type == 'Short Break') {
                      //   pomodoroCubit.shortBreakDurationChanged(
                      //     timeList[index],
                      //   );
                      // } else if (type == 'Long Break') {
                      //   pomodoroCubit.longBreakDurationChanged(
                      //     timeList[index],
                      //   );
                      // } else if (type == 'Long Break After') {
                      //   pomodoroCubit.setSessionCount(
                      //     sessionList[index],
                      //   );
                      // }
                    },
                    children: type == 'Long Break After'
                        ? List.generate(sessionList.length, (index) {
                            return Text('${sessionList[index]} Session(s)');
                          })
                        : List.generate(timeList.length, (index) {
                            return Text('${timeList[index]} min');
                          })),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              )
            ],
          ),
        );
      },
    );
  }
}
