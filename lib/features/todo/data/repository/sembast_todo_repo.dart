// /*

// DATABASE REPO

// This implements the todo repo and handles storing, retrieving, updating,
//  and deleting todos from the isar database.

// */

import 'package:do_it/features/todo/domain/models/todo.dart';
import 'package:do_it/features/todo/domain/repository/todo_repo.dart';
import 'package:sembast/sembast.dart';

class SembastTodoRepo implements TodoRepo {
  final Database db;
  final StoreRef<int, Map<String, dynamic>> _todoStore =
      intMapStoreFactory.store('todos');

  SembastTodoRepo(this.db);

  @override
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

  @override
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

  @override
  Future<void> addTodo(Todo newTodo) async {
    final todoJson = newTodo.toJson();
    todoJson['createdAt'] =
        DateTime.now().toIso8601String(); // Ensure creation time is set
    await _todoStore.record(newTodo.id).put(db, todoJson);
  }

  @override
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

  @override
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
      };
      await record.put(db, updatedTodo);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteTodo(Todo todo) async {
    await _todoStore.record(todo.id).delete(db);
  }
}


// import 'package:do_it/features/todo/data/models/isar_todo.dart';
// import 'package:do_it/features/todo/domain/repository/todo_repo.dart';
// import 'package:isar/isar.dart';

// import '../../domain/models/todo.dart';

// class IsarTodoRepo implements TodoRepo {
//   final Isar db;

//   IsarTodoRepo(this.db);

//   @override
//   Future<List<Todo>> getTodos() async {
//     // Get all todos from the isar database
//     final todos = await db.todoIsars.where().findAll();

// // Convert the list of todoIsar to a list of todo
//     return todos.map((todoIsar) => todoIsar.toDomain()).toList();
//   }

//   @override
//   Future<List<Todo>> getCompletedTodos() async {
//     final completedTodos =
//         await db.todoIsars.filter().isCompletedEqualTo(true).findAll();
//     return completedTodos.map((todoIsar) => todoIsar.toDomain()).toList();
//   }

//   // Add a todo to the isar database
//   @override
//   Future<void> addTodo(Todo newTodo) {
//     // Convert todo into isar todo
//     final todoIsar = TodoIsar.fromDomain(newTodo);

//     // Update the todo in the isar database
//     return db.writeTxn(() => db.todoIsars.put(todoIsar));
//   }

//   @override
//   Future<void> toggleTodoStatus(Todo todo) async {
//     // Convert to Isar model
//     final todoIsar = TodoIsar.fromDomain(todo);

//     // Check if the record exists
//     final existingTodo = await db.todoIsars.get(todo.id);
//     if (existingTodo == null) {
//       return;
//     }

//     try {
//       // Update the todo in Isar database
//       await db.writeTxn(() async {
//         await db.todoIsars.put(todoIsar);
//       });
//     } catch (e) {
//       rethrow;
//     }
//   }

//   @override
//   Future<void> updateTodo(TodoIsar todo) async {
//     // Check if the record exists
//     final existingTodo = await db.todoIsars.get(todo.id);
//     if (existingTodo == null) {
//       return;
//     }

//     try {
//       // Update the todo in Isar database
//       await db.writeTxn(() async {
//         await db.todoIsars.put(todo); // insert & update
//       });
//     } catch (e) {
//       rethrow;
//     }
//   }

// // Delete a todo from the isar database
//   @override
//   Future<void> deleteTodo(Todo todo) async {
//     await db.writeTxn(() => db.todoIsars.delete(todo.id));
//   }
// }

