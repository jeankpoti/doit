// Pomodoro Cubit for State Management

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

import '../domain/repository/pomodoro_repo.dart';
import 'pomodor_config_state.dart';

class PomodoroCubit extends Cubit<PomodoroConfigState> {
  PomodoroRepo pomodoroRepo;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timer;
  int _remainingTime = 0;
  int get remainingTime => _remainingTime;

  PomodoroCubit(this.pomodoroRepo)
      : _remainingTime = 25 * 60,
        super(
          (const PomodoroConfigState(
            completedSessions: 0,
            sessionCount: 4,
            workDuration: 25 * 60,
            shortBreakDuration: 5 * 60,
            longBreakDuration: 15 * 60,
            duration: 0,
            remainingTime: 25 * 60,
            isBreak: false,
            isRunning: false,
            isPaused: false,
          )),
        );

  void workDurationChanged(int workDuration) {
    emit(state.copyWith(workDuration: workDuration * 60));
  }

  void shortBreakDurationChanged(int shortBreakDuration) {
    emit(state.copyWith(shortBreakDuration: shortBreakDuration * 60));
  }

  void longBreakDurationChanged(int longBreakDuration) {
    emit(state.copyWith(longBreakDuration: longBreakDuration * 60));
  }

  void setSessionCount(int sessionCount) {
    emit(state.copyWith(sessionCount: sessionCount));
  }

  void startTimer(int workDuration, {bool isBreak = false}) {
    _remainingTime = workDuration;
    _timer?.cancel();

    emit(state.copyWith(
      isRunning: true,
      isBreak: isBreak,
      remainingTime: _remainingTime,
    ));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        emit(state.copyWith(remainingTime: _remainingTime));
      } else {
        timer.cancel();

        if (isBreak) {
          // End of break, reset to work session
          // Play sound and vibrate for break end
          notifyCompletion('sounds/clock-alarm.mp3');
          emit(state.copyWith(isRunning: false, isBreak: false));
        } else {
          // Work session completed - notify user
          // Play sound and vibrate for focus end
          notifyCompletion('sounds/clock-alarm.mp3');
          emit(state.copyWith(
            isRunning: false,
            isBreak: true,
            remainingTime: 0,
            completedSessions: state.completedSessions + 1,
          ));
        }
      }
    });
  }

  void startBreak(int breakDuration) {
    startTimer(breakDuration, isBreak: true);
  }

  void skipBreak() {
    _timer?.cancel(); // Stop the break timer

    emit(state.copyWith(
      isBreak: false, // Transition back to a work session
      isRunning: false, // Timer is paused initially
      isPaused: false,
      remainingTime: state.workDuration, // Set time for the next work session
    ));

    print("Skipped break. State updated:");
    print(
      "isBreak: ${state.isBreak}, isRunning: ${state.isRunning}, remainingTime: ${state.remainingTime} isPaused: ${state.isPaused} ",
    );
  }

  void pauseTimer() {
    _timer?.cancel();
    emit(state.copyWith(isRunning: false, isPaused: true));
  }

  void resumeTimer({bool isBreak = false}) {
    if (_remainingTime > 0) {
      _timer?.cancel();
      emit(state.copyWith(isRunning: true));

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingTime > 0) {
          _remainingTime--;
          emit(state.copyWith(remainingTime: _remainingTime));
        } else {
          timer.cancel();
          if (isBreak) {
            // End of break, reset to work session
            emit(state.copyWith(isRunning: false, isBreak: false));
          } else {
            // Work session completed - notify user
            emit(state.copyWith(
              isRunning: false,
              isBreak: true,
              remainingTime: 0,
              completedSessions: state.completedSessions + 1,
            ));
          }
        }
      });
    }
  }

  void resumeBreakTimer() {
    resumeTimer(isBreak: true);
  }

  void stopTimer(String type) {
    _timer?.cancel(); // Cancel the running timer
    if (type == 'work') {
      _remainingTime = state.workDuration;
    } else if (type == 'short') {
      _remainingTime = state.shortBreakDuration;
    } else if (type == 'long') {
      _remainingTime = state.longBreakDuration;
    }

    _remainingTime =
        state.workDuration; // Reset remaining time to work duration

    emit(state.copyWith(
      isRunning: false, // Timer is stopped
      remainingTime: _remainingTime, // Reset remaining time
    ));
  }

  Future<void> saveSettings() async {
    pomodoroRepo.saveSettings(
      state.workDuration,
      state.shortBreakDuration,
      state.longBreakDuration,
      state.sessionCount,
    );
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final workDuration = prefs.getInt('workDuration') ?? 25 * 60;
    final shortBreakDuration = prefs.getInt('shortBreakDuration') ?? 5 * 60;
    final longBreakDuration = prefs.getInt('longBreakDuration') ?? 15 * 60;
    final sessionCount = prefs.getInt('sessionCount') ?? 4;

    emit(state.copyWith(
      workDuration: workDuration,
      shortBreakDuration: shortBreakDuration,
      longBreakDuration: longBreakDuration,
      remainingTime: workDuration,
      sessionCount: sessionCount,
    ));
  }

  Future<void> playSound(String soundPath) async {
    await _audioPlayer.play(AssetSource(soundPath));
  }

  Future<void> triggerVibration() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500); // Vibrate for 500ms
    }
  }

  Future<void> notifyCompletion(String soundPath) async {
    await playSound(soundPath);
    await triggerVibration();
  }

  // void resetTimer() {
  //   _timer?.cancel();
  //   // _completedSessions = 0;
  //   // emit(PomodoroInitial());
  // }

  @override
  Future<void> close() {
    _timer?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
