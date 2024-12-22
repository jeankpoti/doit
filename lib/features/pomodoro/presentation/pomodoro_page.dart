import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common_widget/app_bar_widget.dart';
import '../../../common_widget/elevated_button_icon_widget.dart';
import 'pomodor_config_state.dart';
import 'pomodoro_cubit.dart';
import 'setting_page.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  bool started = false;

  @override
  void initState() {
    super.initState();

    context.read<PomodoroCubit>().loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const AppBarWidget(
        title: 'Pomodoro Timer',
        isAction: true,
      ),
      body: BlocBuilder<PomodoroCubit, PomodoroConfigState>(
          builder: (context, state) {
        print('state.sessionCount: ${state.sessionCount}');
        return Column(
          spacing: 30,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TimerDisplay(),
            if (state.isRunning)
              ElevatedButtonIconWidget(
                text: 'Pause',
                icon: const Icon(Icons.pause, size: 40),
                onPressed: () => context.read<PomodoroCubit>().pauseTimer(),
              )
            else if (!state.isRunning &&
                state.remainingTime > 0 &&
                started == true)
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 20,
                children: [
                  if (!state.isRunning &&
                      started == true &&
                      state.completedSessions < state.sessionCount &&
                      state.completedSessions >= 0 &&
                      state.isBreak)
                    ElevatedButtonIconWidget(
                      text: 'Resume',
                      icon: const Icon(Icons.play_arrow, size: 40),
                      onPressed: () =>
                          context.read<PomodoroCubit>().resumeBreakTimer(),
                    )
                  else if (!state.isRunning &&
                      started == true &&
                      state.completedSessions >= state.sessionCount &&
                      state.isBreak)
                    ElevatedButtonIconWidget(
                      text: 'Resume',
                      icon: const Icon(Icons.play_arrow, size: 40),
                      onPressed: () =>
                          context.read<PomodoroCubit>().resumeBreakTimer(),
                    )
                  else
                    ElevatedButtonIconWidget(
                      text: 'Resume',
                      icon: const Icon(Icons.play_arrow, size: 40),
                      onPressed: () =>
                          context.read<PomodoroCubit>().resumeTimer(),
                    ),
                  if (!state.isRunning &&
                      state.remainingTime == 0 &&
                      started == true &&
                      state.completedSessions < state.sessionCount &&
                      state.completedSessions >= 0 &&
                      state.isBreak)
                    ElevatedButtonIconWidget(
                      text: 'Start short break',
                      icon: const Icon(Icons.play_arrow, size: 40),
                      onPressed: () =>
                          context.read<PomodoroCubit>().stopTimer('shortBreak'),
                    )
                  else if (!state.isRunning &&
                      state.remainingTime == 0 &&
                      started == true &&
                      state.completedSessions >= state.sessionCount &&
                      state.isBreak)
                    ElevatedButtonIconWidget(
                      text: 'Start long break',
                      icon: const Icon(Icons.play_arrow, size: 40),
                      onPressed: () =>
                          context.read<PomodoroCubit>().stopTimer('longBreak'),
                    )
                  else
                    ElevatedButtonIconWidget(
                      text: 'Stop',
                      icon: const Icon(Icons.stop, size: 40),
                      onPressed: () =>
                          context.read<PomodoroCubit>().stopTimer('work'),
                    )
                ],
              )
            else if (!state.isRunning &&
                state.remainingTime == 0 &&
                started == true &&
                state.completedSessions < state.sessionCount &&
                state.completedSessions >= 1 &&
                state.isBreak)
              ElevatedButtonIconWidget(
                text: 'Start short break',
                icon: const Icon(Icons.play_arrow, size: 40),
                onPressed: () => {
                  setState(() {
                    started = true;
                  }),
                  context
                      .read<PomodoroCubit>()
                      .startBreak(state.shortBreakDuration)
                },
              )
            else if (!state.isRunning &&
                state.remainingTime == 0 &&
                started == true &&
                state.completedSessions >= state.sessionCount &&
                state.isBreak)
              ElevatedButtonIconWidget(
                text: 'Start long break',
                icon: const Icon(Icons.play_arrow, size: 40),
                onPressed: () => {
                  setState(() {
                    started = true;
                  }),
                  context
                      .read<PomodoroCubit>()
                      .startBreak(state.longBreakDuration)
                },
              )
            else
              ElevatedButtonIconWidget(
                text: 'Start',
                icon: const Icon(Icons.play_arrow, size: 40),
                onPressed: () => {
                  setState(() {
                    started = true;
                  }),
                  context.read<PomodoroCubit>().startTimer(state.workDuration)
                },
              ),
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingPage(),
                ),
              ),
              icon: const Icon(Icons.settings),
            ),
          ],
        );
      }),
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PomodoroCubit, PomodoroConfigState>(
      builder: (context, state) {
        int remainingMinutes = 0, remainingSeconds = 0;
        double progress = 0;

        if (state.isBreak && state.completedSessions < 2) {
          remainingMinutes = state.remainingTime ~/ 60;
          remainingSeconds = state.remainingTime % 60;
          progress = 1 - (state.remainingTime / state.shortBreakDuration);
        } else if (state.isBreak && state.completedSessions >= 2) {
          remainingMinutes = state.remainingTime ~/ 60;
          remainingSeconds = state.remainingTime % 60;
          progress = 1 - (state.remainingTime / state.longBreakDuration);
        } else {
          remainingMinutes = state.remainingTime ~/ 60;
          remainingSeconds = state.remainingTime % 60;
          progress = 1 - (state.remainingTime / state.workDuration);
        }

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: CircularProgressIndicator(
                  value: progress.toDouble(),
                  strokeWidth: 10,
                  color: Theme.of(context).colorScheme.secondary,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.isBreak ? 'Break Time' : 'Focus Time',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
