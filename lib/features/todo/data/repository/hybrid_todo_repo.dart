import 'package:device_calendar/device_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

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

  @override
  Future<void> syncTodosToCalendar(context, List<Todo> todos) async {
    // Request permissions
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        // Permissions not granted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calendar permissions are required to sync todos.'),
          ),
        );
        return;
      }
    }

    // Retrieve calendars
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (!calendarsResult.isSuccess || calendarsResult.data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not retrieve calendars.'),
        ),
      );
      return;
    }

    // Filter writable calendars
    final writableCalendars = calendarsResult.data!
        .where((calendar) => calendar.isReadOnly == false)
        .toList();

    if (writableCalendars.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No writable calendars available.'),
        ),
      );
      return;
    }

    // Show calendar selection dialog
    final selectedCalendar = await showDialog<Calendar>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Calendar'),
          content: SingleChildScrollView(
            child: ListBody(
              children: writableCalendars.map((calendar) {
                return ListTile(
                  title: Text(calendar.name ?? 'Unnamed Calendar'),
                  onTap: () {
                    Navigator.pop(context, calendar);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selectedCalendar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No calendar selected.'),
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Syncing todos..."),
            ],
          ),
        );
      },
    );

    try {
      // Retrieve events from the last 3 months only
      final DateTime startDate =
          DateTime.now().subtract(const Duration(days: 90));
      final DateTime endDate =
          DateTime.now().add(const Duration(days: 7)); // Include a week ahead

      final existingEventsResult = await _deviceCalendarPlugin.retrieveEvents(
        selectedCalendar.id,
        RetrieveEventsParams(
          startDate: startDate,
          endDate: endDate,
        ),
      );

      if (!existingEventsResult.isSuccess) {
        throw Exception(
            "Failed to retrieve existing events: ${existingEventsResult.errors.join(', ')}");
      }

      final existingEvents = existingEventsResult.data ?? [];

      // Create a map of existing events by title for faster lookup
      final Map<String, Event> existingEventsByTitle = {};
      for (final event in existingEvents) {
        if (event.title != null) {
          existingEventsByTitle[event.title!] = event;
        }
      }

      int addedCount = 0;
      int updatedCount = 0;

      // Process each todo
      for (var todo in todos) {
        // For all-day events, use the todo creation date or current date
        final DateTime eventDate = todo.createdAt ?? DateTime.now();
        // Normalize to midnight for all-day events
        final DateTime normalizedDate =
            DateTime(eventDate.year, eventDate.month, eventDate.day);

        // Check if a todo with the same title already exists
        final existingEvent = existingEventsByTitle[todo.title];

        if (existingEvent != null) {
          // Update existing event
          existingEvent.description = todo.description;
          existingEvent.allDay = true;
          existingEvent.start =
              // normalizedDate;
              TZDateTime.from(normalizedDate, local);
          existingEvent.end =
              // normalizedDate;
              TZDateTime.from(normalizedDate, local);

          try {
            // Update the event
            final updateResult =
                await _deviceCalendarPlugin.createOrUpdateEvent(existingEvent);
            if (updateResult!.isSuccess) {
              updatedCount++;
            }
          } catch (e) {
            // print("Exception updating event: $e");
          }
        } else {
          // Create new event
          final event = Event(
            selectedCalendar.id,
            title: todo.title,
            description: todo.description,
            allDay: true,
            start:
                // normalizedDate,
                TZDateTime.from(normalizedDate, local),
            end:
                // normalizedDate,
                TZDateTime.from(normalizedDate, local),
          );

          try {
            // Create the event
            final createResult =
                await _deviceCalendarPlugin.createOrUpdateEvent(event);
            if (createResult!.isSuccess) {
              addedCount++;
            }
          } catch (e) {}
        }
      }

      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Todos synced: $addedCount added, $updatedCount updated'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error syncing todos: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
