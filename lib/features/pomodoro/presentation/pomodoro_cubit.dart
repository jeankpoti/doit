// Pomodoro Cubit for State Management

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'dart:io' show Platform;
import 'package:timezone/data/latest.dart' as tz;
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

    // if (Platform.isAndroid) {
    //   // Enable background execution for Android
    //   await FlutterBackground.enableBackgroundExecution();
    // } else if (Platform.isIOS) {
    //   // Start background audio task for iOS
    //   // await AudioService.init(
    //   //   builder: () => MyAudioHandler(),
    //   //   config: AudioServiceConfig(
    //   //     androidNotificationChannelId: 'com.jeankpoti.doit.channel.audio',
    //   //     androidNotificationChannelName: 'Music playback',
    //   //   ),
    //   // );
    // }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        emit(state.copyWith(remainingTime: _remainingTime));
      } else {
        timer.cancel();
        if (Platform.isAndroid) {
          FlutterBackground.disableBackgroundExecution();
        } else if (Platform.isIOS) {
          AudioService.stop();
        }

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

    // if (Platform.isAndroid) {
    //   FlutterBackground.disableBackgroundExecution();
    // } else if (Platform.isIOS) {
    //   AudioService.stop();
    // }
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

    // if (Platform.isAndroid) {
    //   FlutterBackground.disableBackgroundExecution();
    // } else if (Platform.isIOS) {
    //   AudioService.pause();
    // }

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

    // if (Platform.isAndroid) {
    //   FlutterBackground.disableBackgroundExecution();
    // } else if (Platform.isIOS) {
    //   AudioService.stop();
    // }

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

  // void resetTimer() {
  //   _timer?.cancel();
  //   // _completedSessions = 0;
  //   // emit(PomodoroInitial());
  // }

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

    print('Remaining: $remaining');
    print('State Remaining: ${state.remainingTime}');

    if (remaining <= 0) {
      // Timer ended
      _timer?.cancel();
      // The time should be finished
      // Update state accordingly
      print('ddddd');
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
}

// class PomodoroAudioHandler extends BaseAudioHandler {
//   final AudioPlayer _audioPlayer = AudioPlayer();

//   @override
//   Future<void> play() async {
//     // Example: play a short silent audio or your "clock alarm" loop
//     // This ensures iOS sees real audio playing
//     await _audioPlayer.play(UrlSource(
//       'sounds/clock-alarm.mp3', // or local asset
//     ));

//     // Update the playback state so iOS/Android knows you're playing audio
//     playbackState.add(
//       playbackState.value.copyWith(
//         playing: true,
//         processingState: AudioProcessingState.ready,
//         controls: [
//           MediaControl.pause,
//           MediaControl.stop,
//         ],
//       ),
//     );
//   }

//   @override
//   Future<void> pause() async {
//     await _audioPlayer.pause();
//     playbackState.add(
//       playbackState.value.copyWith(
//         playing: false,
//         controls: [
//           MediaControl.play,
//           MediaControl.stop,
//         ],
//       ),
//     );
//   }

//   @override
//   Future<void> stop() async {
//     await _audioPlayer.stop();
//     playbackState.add(
//       playbackState.value.copyWith(
//         playing: false,
//         processingState: AudioProcessingState.idle,
//         controls: [],
//       ),
//     );
//     super.stop();
//   }
// }

// void _backgroundTaskEntrypoint() {
//   AudioServiceBackground.run(() => PomodoroBackgroundTask());
// }

// class PomodoroBackgroundTask extends BackgroundAudioTask {
//   final _player = AudioPlayer();

//   @override
//   Future<void> onStart(Map<String, dynamic>? params) async {
//     // Play silent audio to maintain background execution on iOS
//     await _player.play(AssetSource(
//         'sounds/clock-alarm.mp3')); // Replace with your silent audio file
//     _player.setReleaseMode(ReleaseMode.loop);
//   }

//   @override
//   Future<void> onStop() async {
//     // Handle background task stop
//     await _player.stop();
//     await super.onStop();
//   }

//   @override
//   Future<void> onPause() async {
//     // Handle background task pause
//     await _player.pause();
//     await super.onPause();
//   }

//   @override
//   Future<void> onPlay() async {
//     // Handle background task play
//     await _player.play(AssetSource('sounds/clock-alarm.mp3'));
//     await super.onPlay();
//   }
// }
