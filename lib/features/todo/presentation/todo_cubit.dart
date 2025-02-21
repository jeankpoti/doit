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

  Future<void> dailyCompletedTasksData() async {
    emit(state.copyWith(isLoading: true, errorMsg: null));
    try {
      final completedTodos = await todoRepo.getCompletedTodos();

      // Group completed todos by day
      final Map<String, int> dailyCompletedTasks = {};
      for (var todo in completedTodos) {
        if (todo.completedAt != null) {
          final date = todo.completedAt!.toIso8601String().split('T').first;
          if (dailyCompletedTasks.containsKey(date)) {
            dailyCompletedTasks[date] = dailyCompletedTasks[date]! + 1;
          } else {
            dailyCompletedTasks[date] = 1;
          }
        }
      }

      // Convert the map to a list of counts
      final dailyCompletedTasksData = dailyCompletedTasks.values.toList();

      emit(state.copyWith(
        dailyCompletedTasksData: dailyCompletedTasksData,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> weeklyCompletedTasksData() async {
    emit(state.copyWith(isLoading: true, errorMsg: null));
    try {
      final completedTodos = await todoRepo.getCompletedTodos();

      // Group completed todos by week
      final Map<String, int> weeklyCompletedTasks = {};
      for (var todo in completedTodos) {
        if (todo.completedAt != null) {
          final week = _getWeekOfYear(todo.completedAt!);
          if (weeklyCompletedTasks.containsKey(week)) {
            weeklyCompletedTasks[week] = weeklyCompletedTasks[week]! + 1;
          } else {
            weeklyCompletedTasks[week] = 1;
          }
        }
      }

      // Convert the map to a list of counts
      final weeklyCompletedTasksData = weeklyCompletedTasks.values.toList();

      emit(state.copyWith(
        weeklyCompletedTasksData: weeklyCompletedTasksData,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> monthlyCompletedTasksData() async {
    emit(state.copyWith(isLoading: true, errorMsg: null));
    try {
      final completedTodos = await todoRepo.getCompletedTodos();

      // Group completed todos by month
      final Map<String, int> monthlyCompletedTasks = {};
      for (var todo in completedTodos) {
        if (todo.completedAt != null) {
          final month = '${todo.completedAt!.year}-${todo.completedAt!.month}';
          if (monthlyCompletedTasks.containsKey(month)) {
            monthlyCompletedTasks[month] = monthlyCompletedTasks[month]! + 1;
          } else {
            monthlyCompletedTasks[month] = 1;
          }
        }
      }

      // Convert the map to a list of counts
      final monthlyCompletedTasksData = monthlyCompletedTasks.values.toList();

      emit(state.copyWith(
        monthlyCompletedTasksData: monthlyCompletedTasksData,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> lifetimeCompletedTasksData() async {
    emit(state.copyWith(isLoading: true, errorMsg: null));
    try {
      final completedTodos = await todoRepo.getCompletedTodos();

      // Group completed todos by year
      final Map<String, int> lifetimeCompletedTasks = {};
      for (var todo in completedTodos) {
        if (todo.completedAt != null) {
          final year = todo.completedAt!.year.toString();
          if (lifetimeCompletedTasks.containsKey(year)) {
            lifetimeCompletedTasks[year] = lifetimeCompletedTasks[year]! + 1;
          } else {
            lifetimeCompletedTasks[year] = 1;
          }
        }
      }

      // Convert the map to a list of counts
      final lifetimeCompletedTasksData = lifetimeCompletedTasks.values.toList();

      emit(state.copyWith(
        lifetimeCompletedTasksData: lifetimeCompletedTasksData,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  String _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay / 7).ceil()).toString();
  }
}

// /*
//  TO DO CUBIT - Simple sate management

//  Each cubit is a list of todos
// */
