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

  Future<void> syncTodosIfNeeded() async {
    emit(state.copyWith(isLoading: true, errorMsg: null));
    try {
      await todoRepo.syncTodosIfNeeded();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> dailyCompletedTasksData() async {
    try {
      final completedTodos = await todoRepo.getCompletedTodos();
      final now = DateTime.now().toLocal();
      final today = DateTime(now.year, now.month, now.day);

      // Create a map to store tasks completed each day
      Map<DateTime, int> dailyTasks = {};

      // Initialize the last 7 days with zero tasks
      for (int i = 6; i >= 0; i--) {
        final day = today.subtract(Duration(days: i));
        dailyTasks[day] = 0;
      }

      // Count completed tasks for each day
      for (var todo in completedTodos) {
        if (todo.completedAt != null) {
          // Normalize the date to midnight in local time
          final completedDate = DateTime(
            todo.completedAt!.toLocal().year,
            todo.completedAt!.toLocal().month,
            todo.completedAt!.toLocal().day,
          );

          // Only count tasks from the last 7 days
          final daysSinceCompletion = today.difference(completedDate).inDays;
          if (daysSinceCompletion >= 0 && daysSinceCompletion < 7) {
            dailyTasks[completedDate] = (dailyTasks[completedDate] ?? 0) + 1;
          }
        }
      }

      // Convert map to ordered list of the last 7 days
      List<int> dailyTasksData = [];
      for (int i = 6; i >= 0; i--) {
        final day = today.subtract(Duration(days: i));
        dailyTasksData.add(dailyTasks[day] ?? 0);
      }

      // Emit state with the updated data
      emit(state.copyWith(
        dailyCompletedTasksData: dailyTasksData,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> weeklyCompletedTasksData() async {
    try {
      final completedTodos = await todoRepo.getCompletedTodos();
      final now = DateTime.now().toLocal();

      // Get the start of the current week (considering Sunday as the first day of the week)
      final currentWeekStart = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: now.weekday % 7));

      // Group tasks by week
      Map<DateTime, int> weeklyTaskCounts = {};

      // Process data for the last 7 weeks
      for (int i = 6; i >= 0; i--) {
        // Calculate the start date of this week
        final weekStart = currentWeekStart.subtract(Duration(days: i * 7));
        // Initialize this week with zero tasks
        weeklyTaskCounts[weekStart] = 0;
      }

      // Aggregate task counts by week
      for (var todo in completedTodos) {
        if (todo.completedAt != null) {
          final completedDate = todo.completedAt!.toLocal();

          // Find which week this task belongs to
          for (var weekStart in weeklyTaskCounts.keys) {
            final weekEnd = weekStart.add(
                const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

            if (completedDate.isAfter(weekStart) &&
                completedDate.isBefore(weekEnd)) {
              weeklyTaskCounts[weekStart] = weeklyTaskCounts[weekStart]! + 1;
              break;
            }
          }
        }
      }

      // Convert map to list in chronological order
      List<int> weeklyData = [];
      List<DateTime> sortedWeeks = weeklyTaskCounts.keys.toList()
        ..sort((a, b) => a.compareTo(b));

      for (var weekStart in sortedWeeks) {
        weeklyData.add(weeklyTaskCounts[weekStart] ?? 0);
      }

      emit(state.copyWith(
        weeklyCompletedTasksData: weeklyData,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> monthlyCompletedTasksData() async {
    try {
      final completedTodos = await todoRepo.getCompletedTodos();
      final now = DateTime.now().toLocal();

      // Create a map to store task counts by month
      Map<DateTime, int> monthlyTaskCounts = {};

      // Initialize the last 7 months with zero tasks
      for (int i = 6; i >= 0; i--) {
        // Get the first day of each month going back 7 months
        final year = now.month - i <= 0 ? now.year - 1 : now.year;
        final month = now.month - i <= 0 ? now.month - i + 12 : now.month - i;
        final monthStart = DateTime(year, month, 1);

        // Initialize with zero counts
        monthlyTaskCounts[monthStart] = 0;
      }

      // Aggregate task counts by month
      for (var todo in completedTodos) {
        if (todo.completedAt != null) {
          final completedDate = todo.completedAt!.toLocal();
          final taskMonthStart =
              DateTime(completedDate.year, completedDate.month, 1);

          // Only count tasks from the last 7 months
          if (monthlyTaskCounts.containsKey(taskMonthStart)) {
            monthlyTaskCounts[taskMonthStart] =
                monthlyTaskCounts[taskMonthStart]! + 1;
          }
        }
      }

      // Convert map to list in chronological order
      List<int> monthlyData = [];
      List<DateTime> sortedMonths = monthlyTaskCounts.keys.toList()
        ..sort((a, b) => a.compareTo(b));

      for (var monthStart in sortedMonths) {
        monthlyData.add(monthlyTaskCounts[monthStart] ?? 0);
      }

      emit(state.copyWith(
        monthlyCompletedTasksData: monthlyData,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> lifetimeCompletedTasksData() async {
    try {
      final completedTodos = await todoRepo.getCompletedTodos();

      // First, find the earliest and latest task completion dates
      DateTime? earliestDate;
      DateTime latestDate = DateTime.now().toLocal();

      if (completedTodos.isEmpty) {
        // If no tasks, just create a simple timeline from now to 6 months ago
        earliestDate = latestDate.subtract(const Duration(days: 180));
      } else {
        // Find the earliest completion date among tasks
        earliestDate = completedTodos
            .where((todo) => todo.completedAt != null)
            .map((todo) => todo.completedAt!.toLocal())
            .reduce(
                (value, element) => value.isBefore(element) ? value : element);

        // Ensure we have at least 6 months of history
        final sixMonthsAgo = latestDate.subtract(const Duration(days: 180));
        if (earliestDate.isAfter(sixMonthsAgo)) {
          earliestDate = sixMonthsAgo;
        }
      }

      // Calculate the total time span in months (rounded up)
      final months = (latestDate.year - earliestDate.year) * 12 +
          latestDate.month -
          earliestDate.month +
          (latestDate.day > earliestDate.day ? 1 : 0);

      // Use 7 time periods for the chart (or fewer if we have less history)
      final periods = months < 7 ? months : 7;
      final monthsPerPeriod = (months / periods).ceil();

      // Create period boundaries
      List<DateTime> periodBoundaries = [];
      for (int i = 0; i <= periods; i++) {
        // Calculate this period's date
        final monthsToAdd = i * monthsPerPeriod;
        final year =
            earliestDate.year + (earliestDate.month + monthsToAdd - 1) ~/ 12;
        final month = (earliestDate.month + monthsToAdd - 1) % 12 + 1;
        periodBoundaries.add(DateTime(year, month, 1));
      }

      // Initialize period counts
      List<int> periodTaskCounts = List.filled(periods, 0);

      // Aggregate tasks by period
      for (var todo in completedTodos) {
        if (todo.completedAt != null) {
          final completedDate = todo.completedAt!.toLocal();

          // Find which period this task belongs to
          for (int i = 0; i < periods; i++) {
            if (completedDate.isAfter(periodBoundaries[i]) &&
                (i == periods - 1 ||
                    completedDate.isBefore(periodBoundaries[i + 1]))) {
              periodTaskCounts[i]++;
              break;
            }
          }
        }
      }

      emit(state.copyWith(
        lifetimeCompletedTasksData: periodTaskCounts,
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
