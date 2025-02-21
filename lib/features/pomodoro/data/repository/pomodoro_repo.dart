/*

DATABASE REPO

This implements the todo repo and handles storing, retrieving, updating,
 and deleting todos from the isar database.

*/

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repository/pomodoro_repo.dart';

class IsarPomodoroRepo implements PomodoroRepo {
  IsarPomodoroRepo();

  @override
  Future<void> saveSettings(
    int workDuration,
    int shortBreakDuration,
    int longBreakDuration,
    int sessionCount,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workDuration', workDuration);
    await prefs.setInt('shortBreakDuration', shortBreakDuration);
    await prefs.setInt('longBreakDuration', longBreakDuration);
    await prefs.setInt('sessionCount', sessionCount);
  }
}
