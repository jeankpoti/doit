import '../domain/models/todo.dart';

class TodoState {
  final List<Todo> todos;
  final List<Todo> completedTodos;
  final bool isLoading;
  final String? errorMsg;

  const TodoState({
    this.todos = const [],
    this.completedTodos = const [],
    this.isLoading = false,
    this.errorMsg,
  });

  TodoState copyWith({
    List<Todo>? todos,
    List<Todo>? completedTodos,
    bool? isLoading,
    String? errorMsg,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      completedTodos: completedTodos ?? this.completedTodos,
      isLoading: isLoading ?? this.isLoading,
      errorMsg: errorMsg,
    );
  }
}
