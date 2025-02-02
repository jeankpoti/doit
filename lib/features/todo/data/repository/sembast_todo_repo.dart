// /*

// DATABASE REPO

// This implements the todo repo and handles storing, retrieving, updating,
//  and deleting todos from the isar database.

// */

import 'package:do_it/features/todo/domain/models/todo.dart';
import 'package:sembast/sembast.dart';

class SembastTodoRepo {
  final Database db;
  final StoreRef<int, Map<String, dynamic>> _todoStore =
      intMapStoreFactory.store('todos');

  SembastTodoRepo(this.db);

  Future<List<Todo>> getTodos() async {
    final records = await _todoStore.find(
      db,
      finder: Finder(
        sortOrders: [SortOrder('createdAt', false)], // false means descending
      ),
    );
    return records
        .map((record) => Todo.fromJson({
              'id': record.key,
              ...record.value,
            }))
        .toList();
  }

  Future<List<Todo>> getCompletedTodos() async {
    final records = await _todoStore.find(
      db,
      finder: Finder(
        filter: Filter.equals('isCompleted', true),
      ),
    );
    return records
        .map((record) => Todo.fromJson({
              'id': record.key,
              ...record.value,
            }))
        .toList();
  }

  // In SembastTodoRepo
  Future<void> addTodo(Todo newTodo) async {
    final todoJson = newTodo.toJson();
    todoJson['createdAt'] =
        DateTime.now().toIso8601String(); // Ensure creation time is set
    await _todoStore.record(newTodo.id).put(db, todoJson);
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    final record = _todoStore.record(todo.id);
    final exists = await record.exists(db);
    if (!exists) return;

    try {
      final existingTodo = await record.get(db);
      final updatedTodo = {
        ...todo.toJson(),
        'createdAt': existingTodo?['createdAt'] ??
            DateTime.now().toIso8601String(), // Preserve original creation time
      };
      await record.put(db, updatedTodo);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTodo(Todo todo) async {
    final record = _todoStore.record(todo.id);
    final exists = await record.exists(db);
    if (!exists) return;

    try {
      final existingTodo = await record.get(db);
      final updatedTodo = {
        ...todo.toJson(),
        'createdAt': existingTodo?['createdAt'] ??
            DateTime.now().toIso8601String(), // Preserve original creation time
        'updatedAt': DateTime.now().toIso8601String(),
      };
      await record.put(db, updatedTodo);
    } catch (e) {
      rethrow;
    }
  }

  // SembastTodoRepo
// @override
  Future<void> deleteTodo(Todo todo) async {
    // If we truly want to remove from local, we'd do:
    // await _store.record(todoId).delete(db);

    // Instead, mark the existing record as pendingDelete
    final record = await _todoStore.record(todo.id).get(db);
    if (record != null) {
      final existingTodo = Todo.fromJson(record);
      final updatedTodo = existingTodo.copyWith(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        isCompleted: todo.isCompleted,
        needsSync: false,
        pendingDelete: true,
        createdAt: todo.createdAt,
        updatedAt: todo.updatedAt,
      );
      await _todoStore.record(todo.id).put(db, updatedTodo.toJson());
    }
  }

  Future<void> deleteTodoPermanently(Todo todo) async {
    await _todoStore.record(todo.id).delete(db);
  }

  Future<void> syncTodosIfNeeded() {
    // Local-only: no-op by default

    // TODO: implement syncTodosIfNeeded
    throw UnimplementedError();
  }
}
