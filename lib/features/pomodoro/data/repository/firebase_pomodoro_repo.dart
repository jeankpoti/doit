// features/todo/data/repositories/firebase_todo_repo.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_it/features/pomodoro/domain/models/pomodoro.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebasePomodoroRepo {
  final FirebaseFirestore firestore;

  FirebasePomodoroRepo(this.firestore);

  final user = FirebaseAuth.instance.currentUser;

  CollectionReference get _collection => firestore.collection('sessions');

  Future<List<Pomodoro>> getSessions() async {
    try {
      if (user != null) {
        final userId = user!.uid;

        final snapshot =
            await _collection.where('userId', isEqualTo: userId).get();

        return snapshot.docs
            .map((doc) => Pomodoro.fromJson({
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

  Future<void> saveSession(Pomodoro pomodoro) async {
    try {
      if (user != null) {
        final userId = user!.uid;

        await _collection.doc(pomodoro.id.toString()).set({
          ...pomodoro.toJson(),
          'userId': userId,
        });
      }
    } catch (e) {
      // print('Error: $e');
    }
  }

  // In FirebaseTodoRepo
  Future<void> saveOrUpdatePomodro(Pomodoro pomodoro) async {
    try {
      if (user != null) {
        final userId = user!.uid;

        await _collection.doc(pomodoro.id.toString()).set({
          ...pomodoro.toJson(),
          'userId': userId,
        });
      }
    } catch (e) {
      // print('Error: $e');
    }
  }

  Future<void> updatePomodoro(Pomodoro pomodoro) async {
    try {
      if (user != null) {
        final userId = user!.uid;
        // Create an update map that includes the fields you want to update.
        // Notice that we do not include 'createdAt', so Firestore will leave that field unchanged.
        final updateData = {
          'completedSessionsPersist': pomodoro.completedSessionsPersist,
          'needsSync': pomodoro.needsSync,
          'updatedAt': DateTime.now().toIso8601String(),
          'userId': userId,
        };

        await _collection.doc(pomodoro.id.toString()).update(updateData);
      }
    } catch (e) {
      // Handle the error as needed
      rethrow;
    }
  }

  Future<void> syncSessionIfNeeded() async {
    // Firestore-only: typically no local bridging, so no-op
  }

  // Future<List<Pomodoro>> getCompletedTodos() async {
  //   // Query Firestore for documents where 'isCompleted' is true.
  //   final querySnapshot = await _collection.get();

  //   // Map each document into a Todo.
  //   return querySnapshot.docs.map((doc) {
  //     // Get the document data as a map.
  //     final data = doc.data() as Map<String, dynamic>;

  //     // If the 'id' field is not stored, you could try parsing the doc.id.
  //     // Here we assume that Firestore stores an 'id' field.
  //     return Pomodoro.fromJson({
  //       'id': data['id'] ?? int.tryParse(doc.id) ?? 0,
  //       ...data,
  //     });
  //   }).toList();
  // }
}
