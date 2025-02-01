import '../domain/models/todo.dart';

class TodoState {
  final List<Todo> todos;
  final bool isLoading;
  final String? errorMsg;

  const TodoState({
    this.todos = const [],
    this.isLoading = false,
    this.errorMsg,
  });

  TodoState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    String? errorMsg,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      errorMsg: errorMsg,
    );
  }
}
