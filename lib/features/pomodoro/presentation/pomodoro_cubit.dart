// Pomodoro Cubit for State Management

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:do_it/features/pomodoro/domain/models/pomodoro.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../main.dart';
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
            sessions: [],
            dailySessionsData: [],
            weeklySessionsData: [],
            monthlySessionsData: [],
            lifeTimeSessionsData: [],
            completedSessions: 0,
            completedSessionsPersist: 0,
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

  void startTimer(int workDuration, {bool isBreak = false}) async {
    _remainingTime = workDuration;
    _timer?.cancel();

    // Cancel any existing notification
    await cancelPomodoroNotification();

    // Save timer state
    await saveTimerState(workDuration, isBreak);

    // Schedule notification for Pomodoro end
    await schedulePomodoroNotification(workDuration);

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
        // if (Platform.isAndroid) {
        //   FlutterBackground.disableBackgroundExecution();
        // } else if (Platform.isIOS) {
        //   AudioService.stop();
        // }

        if (isBreak) {
          // End of break, reset to work session
          // Play sound and vibrate for break end
          notifyCompletion('sounds/clock-alarm.mp3');
          emit(state.copyWith(isRunning: false, isBreak: false));
        } else {
          // Work session completed - notify user
          // Play sound and vibrate for focus end
          notifyCompletion('sounds/clock-alarm.mp3');
          // Save completed sessions to storage
          saveSession();
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

  void startShortBreak(int breakDuration) {
    startTimer(breakDuration, isBreak: true);
  }

  void startLongBreak(int breakDuration) {
    //Reset completed sessions to 0
    emit(state.copyWith(
      completedSessions: 0,
    ));
    startTimer(breakDuration, isBreak: true);
  }

  void skipBreak() {
    _timer?.cancel(); // Stop the break timer

    // Set completedSessions to 0 if skipping long break
    state.completedSessions >= state.sessionCount
        ? emit(state.copyWith(
            isBreak: false, // Transition back to a work session
            isRunning: false, // Timer is paused initially
            isPaused: false,
            remainingTime:
                state.workDuration, // Set time for the next work session
            completedSessions: 0,
          ))
        : emit(state.copyWith(
            isBreak: false, // Transition back to a work session
            isRunning: false, // Timer is paused initially
            isPaused: false,
            remainingTime:
                state.workDuration, // Set time for the next work session
          ));
  }

  void pauseTimer() {
    _timer?.cancel();

    emit(state.copyWith(isRunning: false, isPaused: true));
  }

  void resumeTimer({bool isBreak = false}) {
    if (_remainingTime > 0) {
      _timer?.cancel();

      emit(state.copyWith(
        isRunning: true,
        isPaused: false,
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
            notifyCompletion('sounds/clock-alarm.mp3');
            // Save completed sessions to storage
            saveSession();
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

  void stopTimer(String type) async {
    _timer?.cancel(); // Cancel the running timer

    // Cancel the notification
    await cancelPomodoroNotification();

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

  Future<void> schedulePomodoroNotification(int seconds,
      {String? payload}) async {
    // Setup channel details for Android
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'pomodoro_channel_id',
      'Pomodoro Notifications',
      channelDescription: 'Notifies when Pomodoro ends',
      importance: Importance.max,
      priority: Priority.high,
    );

    // iOS details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert to a tz-based time
    final tz.TZDateTime scheduledTime = tz.TZDateTime.now(tz.local).add(
      Duration(seconds: seconds),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Session Ended',
      'Your Pomodoro session is done. Time for a break.🥳',
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: payload, // optional custom payload
    );
  }

  Future<void> cancelPomodoroNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future<void> saveTimerState(int duration, bool isBreak) async {
    final prefs = await SharedPreferences.getInstance();
    // Store the timestamp of when the timer started
    prefs.setInt('timerStartTimestamp', DateTime.now().millisecondsSinceEpoch);

    // Also store the total duration for the timer
    prefs.setInt('timerDuration', duration);

    // Store whether it's a break session or not
    prefs.setBool('isBreak', isBreak);
  }

  Future<void> resumeFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final startTimestamp = prefs.getInt('timerStartTimestamp');
    final duration = prefs.getInt('timerDuration') ?? 0;
    final wasBreak = prefs.getBool('isBreak') ?? false;

    // If user hasn't started a timer recently, or no start time is stored
    if (startTimestamp == null || duration == 0) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = ((now - startTimestamp) / 1000).round();
    final remaining = duration - elapsed;

    if (remaining <= 0) {
      // Timer ended
      _timer?.cancel();
      // The time should be finished
      // Update state accordingly

      emit(state.copyWith(
        isRunning: false,
        isPaused: false,
        isBreak: wasBreak
            ? false // if break ended, switch to focus
            : true, // if work ended, switch to break
        // For example if a work session ended:
        completedSessions: wasBreak
            ? state.completedSessions // break finished, no increment
            : state.completedSessions + 1,
        remainingTime: 0,
      ));
    } else {
      // The timer is still running
      emit(state.copyWith(
        isRunning: true,
        isBreak: wasBreak,
        remainingTime: remaining,
      ));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }

  Future<void> getSessions() async {
    // emit(state.copyWith(isLoading: true, errorMsg: null));
    try {
      final sessions = await pomodoroRepo.getSessions();
      emit(state.copyWith(sessions: sessions));
    } catch (e) {
      // emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> syncPomodoroIfNeeded() async {
    // emit(state.copyWith(isLoading: true, errorMsg: null));
    try {
      await pomodoroRepo.syncPomodorosIfNeeded();
    } catch (e) {
      // emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> saveSession() async {
    // emit(state.copyWith(isLoading: true, errorMsg: null));
    try {
      final newPomodoro = Pomodoro(
        id: DateTime.now().millisecondsSinceEpoch,
        completedSessionsPersist: 1,
      );

      await pomodoroRepo.saveSession(newPomodoro);
      // emit(state.copyWith(todos: updatedTodos, isLoading: false));
    } catch (e) {
      // emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> dailySessionsData() async {
    try {
      final sessions = await pomodoroRepo.getSessions();
      final now = DateTime.now().toLocal();
      final today = DateTime(now.year, now.month, now.day);

      // Group sessions by normalized date.
      Map<DateTime, int> sessionCounts = {};
      for (var session in sessions) {
        // Normalize using local time.
        final date = DateTime(session.createdAt.toLocal().year,
            session.createdAt.toLocal().month, session.createdAt.toLocal().day);
        sessionCounts[date] = (sessionCounts[date] ?? 0) +
            (session.completedSessionsPersist ?? 0);
      }

      // Create aggregated sessions for the last 7 days.
      List<Pomodoro> dailySessionsList = [];
      for (int i = 6; i >= 0; i--) {
        final day = today.subtract(Duration(days: i));
        final count = sessionCounts[day] ?? 0;
        dailySessionsList.add(
          Pomodoro(
            id: day.millisecondsSinceEpoch,
            completedSessionsPersist: count,
            // isCompleted: false, // Adjust if needed.
            createdAt: day,
            updatedAt: day,
          ),
        );
      }

      emit(state.copyWith(dailySessionsData: dailySessionsList));
    } catch (e) {
      // Handle errors.
    }
  }

  Future<void> weeklySessionsData() async {
    try {
      final sessions = await pomodoroRepo.getSessions();
      final now = DateTime.now().toLocal();

      // Get the start of the current week (considering Sunday as the first day of the week)
      final currentWeekStart = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday % 7));

      // Group sessions by week
      Map<DateTime, int> weeklySessionCounts = {};

      // Process data for the last 7 weeks
      for (int i = 6; i >= 0; i--) {
        // Calculate the start date of this week
        final weekStart = currentWeekStart.subtract(Duration(days: i * 7));
        // Initialize this week with zero sessions
        weeklySessionCounts[weekStart] = 0;
      }

      // Aggregate session counts by week
      for (var session in sessions) {
        final sessionDate = session.createdAt.toLocal();

        // Find which week this session belongs to
        for (var weekStart in weeklySessionCounts.keys) {
          final weekEnd = weekStart.add(
              const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

          if (sessionDate.isAfter(weekStart) && sessionDate.isBefore(weekEnd)) {
            weeklySessionCounts[weekStart] = weeklySessionCounts[weekStart]! +
                (session.completedSessionsPersist ?? 0);
            break;
          }
        }
      }

      // Convert map to list in chronological order
      List<int> weeklyData = [];
      List<DateTime> sortedWeeks = weeklySessionCounts.keys.toList()
        ..sort((a, b) => a.compareTo(b));

      for (var weekStart in sortedWeeks) {
        weeklyData.add(weeklySessionCounts[weekStart] ?? 0);
      }

      emit(state.copyWith(weeklySessionsData: weeklyData));
    } catch (e) {
      // Handle errors appropriately
      // print('Error in weeklySessionsData: $e');
    }
  }

  Future<void> monthlySessionsData() async {
    try {
      final sessions = await pomodoroRepo.getSessions();
      final now = DateTime.now().toLocal();

      // Create a map to store session counts by month
      Map<DateTime, int> monthlySessionCounts = {};

      // Initialize the last 7 months with zero sessions
      for (int i = 6; i >= 0; i--) {
        // Get the first day of each month going back 7 months
        final year = now.month - i <= 0 ? now.year - 1 : now.year;
        final month = now.month - i <= 0 ? now.month - i + 12 : now.month - i;
        final monthStart = DateTime(year, month, 1);

        // Initialize with zero counts
        monthlySessionCounts[monthStart] = 0;
      }

      // Aggregate session counts by month
      for (var session in sessions) {
        final sessionDate = session.createdAt.toLocal();
        final sessionMonthStart =
            DateTime(sessionDate.year, sessionDate.month, 1);

        // Only count sessions from the last 7 months
        if (monthlySessionCounts.containsKey(sessionMonthStart)) {
          monthlySessionCounts[sessionMonthStart] =
              monthlySessionCounts[sessionMonthStart]! +
                  (session.completedSessionsPersist ?? 0);
        }
      }

      // Convert map to list in chronological order
      List<int> monthlyData = [];
      List<DateTime> sortedMonths = monthlySessionCounts.keys.toList()
        ..sort((a, b) => a.compareTo(b));

      for (var monthStart in sortedMonths) {
        monthlyData.add(monthlySessionCounts[monthStart] ?? 0);
      }

      emit(state.copyWith(monthlySessionsData: monthlyData));
    } catch (e) {
      // Handle errors appropriately
      // print('Error in monthlySessionsData: $e');
    }
  }

  Future<void> lifetimeSessionsData() async {
    try {
      final sessions = await pomodoroRepo.getSessions();

      // First, find the earliest and latest session dates
      DateTime? earliestDate;
      DateTime latestDate = DateTime.now().toLocal();

      if (sessions.isEmpty) {
        // If no sessions, just create a simple timeline from now to 6 months ago
        earliestDate = latestDate.subtract(const Duration(days: 180));
      } else {
        // Find the earliest session date
        earliestDate = sessions.map((s) => s.createdAt.toLocal()).reduce(
            (value, element) => value.isBefore(element) ? value : element);

        // Ensure we have at least 6 months of history
        final sixMonthsAgo = latestDate.subtract(const Duration(days: 180));
        if (earliestDate.isAfter(sixMonthsAgo)) {
          earliestDate = sixMonthsAgo;
        }
      }

      // Calculate the total time span in months (rounded up)
      final months = (latestDate.year - earliestDate.year) * 12 +
          latestDate.month -
          earliestDate.month +
          (latestDate.day > earliestDate.day ? 1 : 0);

      // Use 7 time periods for the chart (or fewer if we have less history)
      final periods = months < 7 ? months : 7;
      final monthsPerPeriod = (months / periods).ceil();

      // Create period boundaries
      List<DateTime> periodBoundaries = [];
      for (int i = 0; i <= periods; i++) {
        // Calculate this period's date
        final monthsToAdd = i * monthsPerPeriod;
        final year =
            earliestDate.year + (earliestDate.month + monthsToAdd - 1) ~/ 12;
        final month = (earliestDate.month + monthsToAdd - 1) % 12 + 1;
        periodBoundaries.add(DateTime(year, month, 1));
      }

      // Initialize period counts
      List<int> periodSessionCounts = List.filled(periods, 0);

      // Aggregate sessions by period
      for (var session in sessions) {
        final sessionDate = session.createdAt.toLocal();

        // Find which period this session belongs to
        for (int i = 0; i < periods; i++) {
          if (sessionDate.isAfter(periodBoundaries[i]) &&
              (i == periods - 1 ||
                  sessionDate.isBefore(periodBoundaries[i + 1]))) {
            periodSessionCounts[i] += session.completedSessionsPersist ?? 0;
            break;
          }
        }
      }

      emit(state.copyWith(lifeTimeSessionsData: periodSessionCounts));
    } catch (e) {
      // print('Error in lifetimeSessionsData: $e');
    }
  }
}
