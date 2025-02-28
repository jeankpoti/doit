import 'package:equatable/equatable.dart';

class Pomodoro extends Equatable {
  final int id;
  final int? completedSessionsPersist;
  final bool needsSync;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Pomodoro({
    required this.id,
    required this.completedSessionsPersist,
    this.needsSync = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = DateTime.now();

  // For local or remote serialization
  factory Pomodoro.fromJson(Map<String, dynamic> json) {
    return Pomodoro(
      id: json['id'] as int,
      completedSessionsPersist: json['completedSessionsPersist'] as int,
      needsSync: json['needsSync'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'completedSessionsPersist': completedSessionsPersist,
      'needsSync': needsSync,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper copyWith for immutability
  Pomodoro copyWith({
    int? id,
    int? completedSessionsPersist,
    bool? needsSync,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Pomodoro(
      id: id ?? this.id,
      completedSessionsPersist:
          completedSessionsPersist ?? this.completedSessionsPersist,
      needsSync: needsSync ?? this.needsSync,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Pomodoro toggleCompletion() {
    return Pomodoro(
      id: id,
      completedSessionsPersist: completedSessionsPersist,
      needsSync: needsSync,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        completedSessionsPersist,
        needsSync,
        createdAt,
        updatedAt,
      ];
}
