import 'package:equatable/equatable.dart';

class Todo extends Equatable {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;
  final bool needsSync;
  final bool pendingDelete;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  Todo({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.needsSync = false,
    this.pendingDelete = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        completedAt = completedAt ?? DateTime.now();

  // For local or remote serialization
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      needsSync: json['needsSync'] as bool? ?? false,
      pendingDelete: json['pendingDelete'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'needsSync': needsSync,
      'pendingDelete': pendingDelete,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': null,
    };
  }

  // Helper copyWith for immutability
  Todo copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    bool? needsSync,
    bool? pendingDelete,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? '',
      description: description,
      isCompleted: isCompleted ?? this.isCompleted,
      needsSync: needsSync ?? this.needsSync,
      pendingDelete: pendingDelete ?? this.pendingDelete,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: completedAt,
    );
  }

  Todo toggleCompletion() {
    return Todo(
      id: id,
      title: title,
      description: description,
      isCompleted: !isCompleted,
      needsSync: needsSync,
      pendingDelete: pendingDelete,
      createdAt: createdAt,
      updatedAt: updatedAt,
      completedAt: isCompleted ? DateTime.now() : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        isCompleted,
        needsSync,
        pendingDelete,
        createdAt,
        updatedAt,
        completedAt,
      ];
}
