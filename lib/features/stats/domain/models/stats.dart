import 'package:equatable/equatable.dart';

class Stats extends Equatable {
  final int completed;
  final DateTime date;
  Stats({required this.completed, date}) : date = date ?? DateTime.now();

  // For local or remote serialization
  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      completed: json['completed'] as int,
      date:
          json['date'] != null ? DateTime.parse(json['date'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed': completed,
      'date': date.toIso8601String(),
    };
  }

  // Helper copyWith for immutability
  Stats copyWith({
    int? completed,
    DateTime? date,
  }) {
    return Stats(
      completed: completed ?? this.completed,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [
        completed,
        date,
      ];
}
