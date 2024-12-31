import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Todo toggleCompletion() {
    return Todo(
      id: id,
      title: title,
      description: description,
      isCompleted: !isCompleted,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        isCompleted,
        createdAt,
      ];
}
