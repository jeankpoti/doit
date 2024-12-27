class Todo {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
  });

// Methos to toggle the completion status of a todo to on or off
  Todo toggleCompletion() {
    return Todo(
      id: id,
      title: title,
      description: description,
      isCompleted: !isCompleted,
    );
  }
}
