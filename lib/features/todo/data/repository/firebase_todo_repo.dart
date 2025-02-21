// features/todo/data/repositories/firebase_todo_repo.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/todo.dart';

class FirebaseTodoRepo {
  final FirebaseFirestore firestore;

  FirebaseTodoRepo(this.firestore);

  final user = FirebaseAuth.instance.currentUser;

  CollectionReference get _collection => firestore.collection('todos');

  Future<List<Todo>> getTodos() async {
    try {
      if (user != null) {
        final userId = user!.uid;

        final snapshot =
            await _collection.where('userId', isEqualTo: userId).get();

        return snapshot.docs
            .map((doc) => Todo.fromJson({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }))
            .toList();
      }
    } catch (e) {
      // print('Error: $e');
    }
    return [];
  }

  Future<void> addTodo(Todo todo) async {
    try {
      if (user != null) {
        final userId = user!.uid;

        await _collection.doc(todo.id.toString()).set({
          ...todo.toJson(),
          'userId': userId,
        });
      }
    } catch (e) {
      // print('Error: $e');
    }
  }

  // In FirebaseTodoRepo
  Future<void> addOrUpdateTodo(Todo todo) async {
    try {
      if (user != null) {
        final userId = user!.uid;

        await _collection.doc(todo.id.toString()).set({
          ...todo.toJson(),
          'userId': userId,
        });
      }
    } catch (e) {
      // print('Error: $e');
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      if (user != null) {
        final userId = user!.uid;
        // Create an update map that includes the fields you want to update.
        // Notice that we do not include 'createdAt', so Firestore will leave that field unchanged.
        final updateData = {
          'title': todo.title,
          'description': todo.description,
          'isCompleted': todo.isCompleted,
          'needsSync': todo.needsSync,
          'pendingDelete': todo.pendingDelete,
          'updatedAt': DateTime.now().toIso8601String(),
          'userId': userId,
        };

        await _collection.doc(todo.id.toString()).update(updateData);
      }
    } catch (e) {
      // Handle the error as needed
      rethrow;
    }
  }

  // Future<void> updateTodo(Todo todo) async {
  //   try {
  //     if (user != null) {
  //       final userId = user!.uid;

  //       await _collection.doc(todo.id.toString()).update({
  //         ...todo.toJson(),
  //         'userId': userId,
  //       });
  //     }
  //   } catch (e) {
  //     // print('Error: $e');
  //   }
  // }

  Future<void> deleteTodo(Todo todo) async {
    try {
      await _collection.doc(todo.id.toString()).delete();
    } catch (e) {
      // print('Error: $e');
    }

    await _collection.doc(todo.id.toString()).delete();
  }

  Future<void> syncTodosIfNeeded() async {
    // Firestore-only: typically no local bridging, so no-op
  }

  Future<List<Todo>> getCompletedTodos() async {
    // Query Firestore for documents where 'isCompleted' is true.
    final querySnapshot =
        await _collection.where('isCompleted', isEqualTo: true).get();

    // Map each document into a Todo.
    return querySnapshot.docs.map((doc) {
      // Get the document data as a map.
      final data = doc.data() as Map<String, dynamic>;

      // If the 'id' field is not stored, you could try parsing the doc.id.
      // Here we assume that Firestore stores an 'id' field.
      return Todo.fromJson({
        'id': data['id'] ?? int.tryParse(doc.id) ?? 0,
        ...data,
      });
    }).toList();
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    try {
      // Update only the isCompleted property on the Firestore document.
      await _collection.doc(todo.id.toString()).update({
        'isCompleted': todo.isCompleted,
        'updatedAt': DateTime.now().toIso8601String(),
        'completedAt': todo.isCompleted
            ? DateTime.now().toIso8601String()
            : null, // Set completion time if completed
      });
    } catch (e) {
      rethrow;
    }
  }
}
