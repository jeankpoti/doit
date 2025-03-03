import 'package:firebase_auth/firebase_auth.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../domain/models/todo.dart';
import '../../domain/repository/todo_repo.dart';
import 'sembast_todo_repo.dart';
import 'firebase_todo_repo.dart';

class HybridTodoRepo implements TodoRepo {
  final SembastTodoRepo localRepo;
  final FirebaseTodoRepo remoteRepo;

  HybridTodoRepo({
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
  Future<List<Todo>> getTodos() async {
    await checkConnectivity();
    // Always return local data first for instant UI
    await localRepo.getTodos();

    // If signed in & online, fetch remote and attempt to merge
    if (user != null && isOnline) {
      final remoteTodos = await remoteRepo.getTodos();

      // Filter out completed todos
      final activeRemoteTodos =
          remoteTodos.where((element) => element.isCompleted == false).toList();

      await _mergeRemoteIntoLocal(activeRemoteTodos);
    }

    // Return updated local
    return localRepo.getTodos();
  }

  // features/todo/data/repositories/hybrid_todo_repo.dart

  @override
  Future<void> addTodo(Todo todo) async {
    await checkConnectivity();

    if (user != null && isOnline) {
      // If user is signed in & online, push to remote immediately
      await remoteRepo.addTodo(todo);
      await localRepo.addTodo(todo.copyWith(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        needsSync: false,
      ));
    } else {
      // If offline or not signed in, mark needsSync
      await localRepo.addTodo(todo.copyWith(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        needsSync: true,
      ));
    }
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    if (user != null && isOnline) {
      await remoteRepo.updateTodo(todo);
      await localRepo.updateTodo(todo.copyWith(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        needsSync: false,
      ));
    } else {
      await localRepo.updateTodo(todo.copyWith(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        needsSync: true,
      ));
    }
  }

  @override
  Future<void> deleteTodo(Todo todo) async {
    if (user != null && isOnline) {
      // If user is online and signed in:
      // 1) Delete from Firestore
      await remoteRepo.deleteTodo(todo);
      // 2) Then remove from local Sembast
      // Or mark it as truly removed, so it won't appear anymore
      await localRepo.deleteTodoPermanently(todo);
    } else {
      // Mark locally for pending delete
      await localRepo.deleteTodo(todo);
    }
  }

  @override
  Future<void> syncTodosIfNeeded() async {
    // if not signed in, do nothing
    if (user == null) return;

    // check connectivity
    await checkConnectivity();
    if (!isOnline) return;

    // 1) Pull remote changes
    final remoteTodos = await remoteRepo.getTodos();

    // 2) Merge remote into local
    await _mergeRemoteIntoLocal(remoteTodos);

    // 3) Push local pending changes
    await _pushLocalPendingChanges();
  }

// Push all `needsSync = true` todos and delete pending deletes
  Future<void> _pushLocalPendingChanges() async {
    final localTodos = await localRepo.getTodos();

    // 1) For normal updates: find todos with needsSync = true
    final pendingUpdates = localTodos.where((t) => t.needsSync).toList();

    for (final todo in pendingUpdates) {
      final syncedTodoToLocal = todo.copyWith(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        isCompleted: todo.isCompleted,
        needsSync: false,
        pendingDelete: todo.pendingDelete,
      );
      await remoteRepo.addOrUpdateTodo(syncedTodoToLocal);
    }
    // Then mark them synced locally
    for (final todo in pendingUpdates) {
      final syncedTodo = todo.copyWith(
        id: todo.id,
        title: todo.title,
        description: todo.description,
        isCompleted: todo.isCompleted,
        needsSync: false,
        pendingDelete: todo.pendingDelete,
      );
      await localRepo.updateTodo(syncedTodo);
    }

    // 2) For pending deletes: find todos with pendingDelete = true
    final pendingDeletes = localTodos.where((t) => t.pendingDelete).toList();
    for (final todo in pendingDeletes) {
      // Remove from Firestore
      await remoteRepo.deleteTodo(todo);
      // Then remove from local permanently
      await localRepo.deleteTodoPermanently(todo);
    }
  }

  // "latest wins" merge
  Future<void> _mergeRemoteIntoLocal(List<Todo> remoteTodos) async {
    // For each remote todo, upsert into local
    for (final remote in remoteTodos) {
      await localRepo.mergeRemoteIntoLocal(remote);
      // or read local first to check conflicts
    }
  }

  @override
  Future<List<Todo>> getCompletedTodos() async {
    await checkConnectivity();
    // Always return local data first for immediate UI response.
    await localRepo.getCompletedTodos();

    // If the user is signed in and we're online, fetch remote completed todos,
    // merge them into local, and then return the updated local list.
    if (user != null && isOnline) {
      final remoteCompletedTodos = await remoteRepo.getCompletedTodos();
      await _mergeRemoteIntoLocal(remoteCompletedTodos);
    }

    // Return the updated local completed todos.
    return localRepo.getCompletedTodos();
  }

  @override
  Future<void> toggleTodoStatus(Todo todo) async {
    // First, check connectivity so we know if we’re online
    await checkConnectivity();

    if (user != null && isOnline) {
      // If the user is signed in and online,
      // update the remote repo first, then update local marking sync complete
      await remoteRepo.toggleTodoStatus(todo);
      await localRepo.updateTodo(
        todo.copyWith(
          id: todo.id,
          title: todo.title,
          description: todo.description,
          needsSync: false,
          isCompleted: todo.isCompleted,
        ),
      );
    } else {
      // If offline (or not signed in), update local and mark as needing sync
      await localRepo.updateTodo(
        todo.copyWith(
          id: todo.id,
          title: todo.title,
          description: todo.description,
          needsSync: true,
          isCompleted: todo.isCompleted,
        ),
      );
    }
  }
}
