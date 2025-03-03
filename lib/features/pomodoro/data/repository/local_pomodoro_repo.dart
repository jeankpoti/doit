/*

DATABASE REPO

This implements the todo repo and handles storing, retrieving, updating,
 and deleting todos from the isar database.

*/

import 'package:sembast/sembast.dart';

import '../../domain/models/pomodoro.dart';

class LocalPomodoroRepo {
  final Database db;
  final StoreRef<int, Map<String, dynamic>> _pomodoroStore =
      intMapStoreFactory.store('sessions');

  LocalPomodoroRepo(this.db);

  Future<void> saveSession(Pomodoro pomodoro) async {
    final record = _pomodoroStore.record(pomodoro.id);
    final exists = await record.exists(db);
    if (exists) return;

    final todoJson = pomodoro.toJson();
    todoJson['createdAt'] =
        DateTime.now().toIso8601String(); // Ensure creation time is set
    await _pomodoroStore.record(pomodoro.id).put(db, todoJson);
  }

  Future<void> mergeRemoteIntoLocal(Pomodoro pomodoro) async {
    final record = _pomodoroStore.record(pomodoro.id);
    final exists = await record.exists(db);
    if (exists) return;

    final todoJson = pomodoro.toJson();
    todoJson['createdAt'] = pomodoro.createdAt;
    todoJson['updatedAt'] = pomodoro.updatedAt;
    await _pomodoroStore.record(pomodoro.id).put(db, todoJson);
  }

  Future<List<Pomodoro>> getSessions() async {
    final records = await _pomodoroStore.find(
      db,
      finder: Finder(
        sortOrders: [SortOrder('createdAt', false)], // false means descending
      ),
    );
    return records.map((snapshot) {
      final session = Pomodoro.fromJson(snapshot.value);
      return session;
    }).toList();
  }

  Future<void> updatePomodoro(Pomodoro pomodoro) async {
    final record = _pomodoroStore.record(pomodoro.id);
    final exists = await record.exists(db);
    if (!exists) return;

    try {
      final existingPomodoro = await record.get(db);
      final updatedPomodoro = {
        ...pomodoro.toJson(),
        'createdAt': existingPomodoro?['createdAt'] ??
            DateTime.now().toIso8601String(), // Preserve original creation time
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await record.put(db, updatedPomodoro);
    } catch (e) {
      rethrow;
    }
  }
}
