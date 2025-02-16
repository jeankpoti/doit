import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/models/todo.dart';
import '../domain/repository/todo_repo.dart';
import 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoRepo todoRepo;

  TodoCubit(this.todoRepo) : super(const TodoState());

  Future<void> loadTodos() async {
    emit(state.copyWith(isLoading: true, errorMsg: null));
    try {
      final todos = await todoRepo.getTodos();
      emit(state.copyWith(todos: todos, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> loadCompletedTodos() async {
    emit(state.copyWith(isLoading: true, errorMsg: null));
    try {
      final completedTodos = await todoRepo.getCompletedTodos();

      print('Completed Todos: $completedTodos');
      emit(state.copyWith(completedTodos: completedTodos, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> addTodo(String title, String description) async {
    emit(state.copyWith(isLoading: true, errorMsg: null));
    try {
      final newTodo = Todo(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        description: description,
      );

      await todoRepo.addTodo(newTodo);
      final updatedTodos = await todoRepo.getTodos();
      emit(state.copyWith(todos: updatedTodos, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> updateTodo(Todo todo) async {
    emit(state.copyWith(isLoading: true, errorMsg: null));
    try {
      await todoRepo.updateTodo(todo);
      final updatedTodos = await todoRepo.getTodos();
      emit(state.copyWith(todos: updatedTodos, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> deleteTodo(Todo todo) async {
    emit(state.copyWith(isLoading: true, errorMsg: null));
    try {
      await todoRepo.deleteTodo(todo);
      final updatedTodos = await todoRepo.getTodos();
      emit(state.copyWith(todos: updatedTodos, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    emit(state.copyWith(isLoading: true, errorMsg: null));
    try {
      final updatedTodo = todo.toggleCompletion();
      await todoRepo.toggleTodoStatus(updatedTodo);

      final updatedTodos = await todoRepo.getTodos();
      emit(state.copyWith(todos: updatedTodos, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> toggleComletedTodoStatus(Todo todo) async {
    emit(state.copyWith(isLoading: true, errorMsg: null));
    try {
      final updatedTodo = todo.toggleCompletion();
      await todoRepo.toggleTodoStatus(updatedTodo);

      final completedTodos = await todoRepo.getCompletedTodos();
      final unCompletedTodos = await todoRepo.getTodos();

      emit(state.copyWith(
        completedTodos: completedTodos,
        todos: unCompletedTodos,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }
}

// /*
//  TO DO CUBIT - Simple sate management

//  Each cubit is a list of todos
// */

// import 'package:flutter_bloc/flutter_bloc.dart';

// // import '../data/models/isar_todo.dart';
// import '../domain/models/todo.dart';
// import '../domain/repository/todo_repo.dart';

// class TodoCubit extends Cubit<List<Todo>> {
//   // Refernce  todo repo
//   final TodoRepo todoRepo;

//   // Constructor initializes the cubit with an empty list
//   TodoCubit(this.todoRepo) : super([]) {
//     // Load todos from the repo
//     loadTodos();
//   }

//   // Load todos from the repo
//   Future<void> loadTodos() async {
//     // Get todos from the repo
//     final todos = await todoRepo.getTodos();

//     // Emit the fecthed todos as the new state
//     emit(todos);
//   }

//   // Load todos from the repo
//   Future<void> loadCompletedTodos() async {
//     // Get todos from the repo
//     final completedTodos = await todoRepo.getCompletedTodos();

//     // Emit the fecthed todos as the new state
//     emit(completedTodos);
//   }

//   // Add a new todo
//   Future<void> addTodo(String title, description) async {
//     final newTodo = Todo(
//       id: DateTime.now().millisecondsSinceEpoch,
//       title: title,
//       description: description,
//     );

//     // Add the todo to the repo
//     await todoRepo.addTodo(newTodo);

//     // // Re-load
//     // loadTodos();

//     // Get updated list
//     final updatedTodos = await todoRepo.getTodos();

//     // Emit new state immediately
//     emit(updatedTodos);
//   }

//   // Update a todo
//   // Future<void> updateTodo(TodoIsar todo) async {
//   //   // Update the todo in the repo
//   //   await todoRepo.updateTodo(todo);

//   //   // Re-load todos
//   //   loadTodos();
//   // }

//   Future<void> updateTodo(Todo todo) async {
//     // Update the todo in the repo
//     await todoRepo.updateTodo(todo);

//     // Re-load todos
//     loadTodos();
//   }

//   // Delete a todo
//   Future<void> deleteTodo(Todo todo) async {
//     // Delete the todo from the repo
//     await todoRepo.deleteTodo(todo);

//     // Re-load todos
//     loadTodos();
//   }

//   // Toggle the completion status of a todo
//   Future<void> toggleTodoStatus(Todo todo) async {
//     // Toggle the completion status of the todo
//     final updatedTodo = todo.toggleCompletion();

//     // Update the todo in the repo
//     await todoRepo.toggleTodoStatus(updatedTodo);

//     // Re-load todos
//     loadTodos();
//   }
// }
