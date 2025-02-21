import '../domain/models/todo.dart';

class TodoState {
  final List<Todo> todos;
  final List<Todo> completedTodos;
  final List<int> dailyCompletedTasksData;
  final List<int> weeklyCompletedTasksData;
  final List<int> monthlyCompletedTasksData;
  final List<int> lifetimeCompletedTasksData;
  final bool isLoading;
  final String? errorMsg;

  const TodoState({
    this.todos = const [],
    this.completedTodos = const [],
    this.dailyCompletedTasksData = const [],
    this.weeklyCompletedTasksData = const [],
    this.monthlyCompletedTasksData = const [],
    this.lifetimeCompletedTasksData = const [],
    this.isLoading = false,
    this.errorMsg,
  });

  TodoState copyWith({
    List<Todo>? todos,
    List<Todo>? completedTodos,
    List<int>? dailyCompletedTasksData,
    List<int>? weeklyCompletedTasksData,
    List<int>? monthlyCompletedTasksData,
    List<int>? lifetimeCompletedTasksData,
    bool? isLoading,
    String? errorMsg,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      completedTodos: completedTodos ?? this.completedTodos,
      dailyCompletedTasksData:
          dailyCompletedTasksData ?? this.dailyCompletedTasksData,
      weeklyCompletedTasksData:
          weeklyCompletedTasksData ?? this.weeklyCompletedTasksData,
      monthlyCompletedTasksData:
          monthlyCompletedTasksData ?? this.monthlyCompletedTasksData,
      lifetimeCompletedTasksData:
          lifetimeCompletedTasksData ?? this.lifetimeCompletedTasksData,
      isLoading: isLoading ?? this.isLoading,
      errorMsg: errorMsg,
    );
  }
}
