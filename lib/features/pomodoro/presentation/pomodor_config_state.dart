import 'package:equatable/equatable.dart';

class PomodoroConfigState extends Equatable {
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final bool isBreak;
  final bool isPaused;
  final bool isRunning;
  final int completedSessions;
  final int sessionCount;
  final int duration;
  final int remainingTime;

  const PomodoroConfigState({
    required this.workDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
    required this.isBreak,
    required this.isPaused,
    required this.isRunning,
    required this.completedSessions,
    required this.sessionCount,
    required this.duration,
    required this.remainingTime,
  });

  PomodoroConfigState copyWith({
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    bool? isBreak,
    bool? isPaused,
    bool? isRunning,
    int? completedSessions,
    int? sessionCount,
    int? duration,
    int? remainingTime,
  }) {
    return PomodoroConfigState(
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      isBreak: isBreak ?? this.isBreak,
      isPaused: isPaused ?? this.isPaused,
      isRunning: isRunning ?? this.isRunning,
      completedSessions: completedSessions ?? this.completedSessions,
      sessionCount: sessionCount ?? this.sessionCount,
      duration: duration ?? this.duration,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }

  @override
  List<Object> get props => [
        workDuration,
        shortBreakDuration,
        longBreakDuration,
        isBreak,
        isPaused,
        isRunning,
        completedSessions,
        sessionCount,
        duration,
        remainingTime,
      ];
}
