import 'package:equatable/equatable.dart';

import '../domain/models/pomodoro.dart';

class PomodoroConfigState extends Equatable {
  final List<Pomodoro> sessions;
  final List<Pomodoro> dailySessionsData;
  final List<int> weeklySessionsData;

  final List<int> monthlySessionsData;
  final List<int> lifeTimeSessionsData;

  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final bool isBreak;
  final bool isPaused;
  final bool isRunning;
  final int completedSessions;
  final int completedSessionsPersist;
  final int sessionCount;
  final int duration;
  final int remainingTime;

  const PomodoroConfigState({
    required this.sessions,
    required this.dailySessionsData,
    required this.weeklySessionsData,
    required this.monthlySessionsData,
    required this.lifeTimeSessionsData,
    required this.workDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
    required this.isBreak,
    required this.isPaused,
    required this.isRunning,
    required this.completedSessions,
    required this.completedSessionsPersist,
    required this.sessionCount,
    required this.duration,
    required this.remainingTime,
  });

  PomodoroConfigState copyWith({
    List<Pomodoro>? sessions,
    List<Pomodoro>? dailySessionsData,
    List<int>? weeklySessionsData,
    List<int>? monthlySessionsData,
    List<int>? lifeTimeSessionsData,
    int? workDuration,
    int? shortBreakDuration,
    int? longBreakDuration,
    bool? isBreak,
    bool? isPaused,
    bool? isRunning,
    int? completedSessions,
    int? completedSessionsPersist,
    int? sessionCount,
    int? duration,
    int? remainingTime,
  }) {
    return PomodoroConfigState(
      sessions: sessions ?? this.sessions,
      dailySessionsData: dailySessionsData ?? this.dailySessionsData,
      weeklySessionsData: weeklySessionsData ?? this.weeklySessionsData,
      monthlySessionsData: monthlySessionsData ?? this.monthlySessionsData,
      lifeTimeSessionsData: lifeTimeSessionsData ?? this.lifeTimeSessionsData,
      workDuration: workDuration ?? this.workDuration,
      shortBreakDuration: shortBreakDuration ?? this.shortBreakDuration,
      longBreakDuration: longBreakDuration ?? this.longBreakDuration,
      isBreak: isBreak ?? this.isBreak,
      isPaused: isPaused ?? this.isPaused,
      isRunning: isRunning ?? this.isRunning,
      completedSessions: completedSessions ?? this.completedSessions,
      completedSessionsPersist:
          completedSessionsPersist ?? this.completedSessionsPersist,
      sessionCount: sessionCount ?? this.sessionCount,
      duration: duration ?? this.duration,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }

  @override
  List<Object> get props => [
        sessions,
        dailySessionsData,
        weeklySessionsData,
        monthlySessionsData,
        lifeTimeSessionsData,
        workDuration,
        shortBreakDuration,
        longBreakDuration,
        isBreak,
        isPaused,
        isRunning,
        completedSessions,
        completedSessionsPersist,
        sessionCount,
        duration,
        remainingTime,
      ];
}
