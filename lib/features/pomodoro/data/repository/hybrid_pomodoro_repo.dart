import 'package:do_it/features/pomodoro/data/repository/local_pomodoro_repo.dart';
import 'package:do_it/features/pomodoro/domain/models/pomodoro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repository/pomodoro_repo.dart';
import 'firebase_pomodoro_repo.dart';

class HybridPomodoroRepo implements PomodoroRepo {
  final LocalPomodoroRepo localRepo;
  final FirebasePomodoroRepo remoteRepo;

  HybridPomodoroRepo({
    required this.localRepo,
    required this.remoteRepo,
  });

  final user = FirebaseAuth.instance.currentUser;

  // bool isSignedIn = false; // Updated when user logs in/out
  bool isOnline = false; // Could be updated by a connectivity listener

  checkConnectivity() async {
    bool result = await InternetConnection().hasInternetAccess;
    if (result == true) {
      isOnline = true;
    } else {
      isOnline = false;
    }
  }

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

  @override
  Future<List<Pomodoro>> getSessions() async {
    await checkConnectivity();
    // Always return local data first for instant UI
    await localRepo.getSessions();

    // If signed in & online, fetch remote and attempt to merge
    if (user != null && isOnline) {
      final remoteTodos = await remoteRepo.getSessions();

      await _mergeRemoteIntoLocal(remoteTodos);
    }

    // Return updated local
    return localRepo.getSessions();
  }

  @override
  Future<void> saveSession(Pomodoro pomodoro) async {
    await checkConnectivity();

    // Get the list of current sessions from local storage.
    final sessions = await localRepo.getSessions();
    final now = DateTime.now();

    // Try to find an existing session for today.
    Pomodoro? todaySession;
    for (var session in sessions) {
      final sessionDate = session.createdAt;
      if (sessionDate.year == now.year &&
          sessionDate.month == now.month &&
          sessionDate.day == now.day) {
        todaySession = session;
        break;
      }
    }

    if (todaySession != null && todaySession.completedSessionsPersist != null) {
      // A session for today exists; increment completedSessionsPersist.
      final updatedSession = todaySession.copyWith(
        completedSessionsPersist: todaySession.completedSessionsPersist! + 1,
        // Optionally, update the updatedAt field if you have one.
      );

      if (user != null && isOnline) {
        // Update remote repository first.
        await remoteRepo.updatePomodoro(updatedSession);
        // Then update local storage and mark it as synced.
        await localRepo
            .updatePomodoro(updatedSession.copyWith(needsSync: false));
      } else {
        // Offline or not signed in: update local storage and mark as needing sync.
        await localRepo
            .updatePomodoro(updatedSession.copyWith(needsSync: true));
      }
    } else {
      // No session exists for today—create a new one.
      if (user != null && isOnline) {
        await remoteRepo.saveSession(pomodoro);
        await localRepo.saveSession(pomodoro.copyWith(needsSync: false));
      } else {
        await localRepo.saveSession(pomodoro.copyWith(needsSync: true));
      }
    }
  }

  // @override
  // Future<void> saveSession(Pomodoro pomodoro) async {
  //   await checkConnectivity();

  //   if (user != null && isOnline) {
  //     // If user is signed in & online, push to remote immediately
  //     await remoteRepo.saveSession(pomodoro);

  //     await localRepo.saveSession(pomodoro.copyWith(
  //       id: pomodoro.id,
  //       completedSessionsPersist: pomodoro.completedSessionsPersist,
  //       needsSync: false,
  //     ));
  //   } else {
  //     // If offline or not signed in, mark needsSync
  //     await localRepo.saveSession(pomodoro.copyWith(
  //       id: pomodoro.id,
  //       completedSessionsPersist: pomodoro.completedSessionsPersist,
  //       needsSync: true,
  //     ));
  //   }
  // }

  Future<void> syncTodosIfNeeded() async {
    // if not signed in, do nothing
    if (user == null) return;

    // check connectivity
    await checkConnectivity();
    if (!isOnline) return;

    // 1) Pull remote changes
    final remoteSessions = await remoteRepo.getSessions();

    // 2) Merge remote into local
    await _mergeRemoteIntoLocal(remoteSessions);

    // 3) Push local pending changes
    await _pushLocalPendingChanges();
  }

// Push all `needsSync = true` todos and delete pending deletes
  Future<void> _pushLocalPendingChanges() async {
    final localSessions = await localRepo.getSessions();

    // 1) For normal updates: find todos with needsSync = true
    final pendingUpdates = localSessions.where((t) => t.needsSync).toList();

    for (final todo in pendingUpdates) {
      final syncedTodoToLocal = todo.copyWith(
        id: todo.id,
        completedSessionsPersist: todo.completedSessionsPersist,
        needsSync: false,
      );
      await remoteRepo.saveOrUpdatePomodro(syncedTodoToLocal);
    }
    // Then mark them synced locally
    for (final pomodoro in pendingUpdates) {
      final syncedTodo = pomodoro.copyWith(
        id: pomodoro.id,
        completedSessionsPersist: pomodoro.completedSessionsPersist,
        needsSync: false,
      );
      await localRepo.updatePomodoro(syncedTodo);
    }

    // 2) For pending deletes: find todos with pendingDelete = true
    // final pendingDeletes = localSessions.where((t) => t.pendingDelete).toList();
    // for (final todo in pendingDeletes) {
    //   // Remove from Firestore
    //   await remoteRepo.deleteTodo(todo);
    //   // Then remove from local permanently
    //   await localRepo.deleteTodoPermanently(todo);
    // }
  }

  // "latest wins" merge
  Future<void> _mergeRemoteIntoLocal(List<Pomodoro> remotePomodoros) async {
    // For each remote todo, upsert into local
    for (final remote in remotePomodoros) {
      await localRepo.mergeRemoteIntoLocal(remote);
      // or read local first to check conflicts
    }
  }
}
