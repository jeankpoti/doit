/*
ISAR TO DO MODEL

Converts todo model into an Isar model that we can store in our isar db
*/

import 'package:isar/isar.dart';

import '../../domain/models/todo.dart';

// This annotation tells Isar to generate a type adapter for this class
// To generate isar todo object, run the command: dart run build_runner build
part 'isar_todo.g.dart';

@collection
class TodoIsar {
  Id id = Isar.autoIncrement;
  late String title;
  late String description;
  late bool isCompleted;

  // Convert isar object -> pure todo object to use in our app
  Todo toDomain() {
    return Todo(
      id: id,
      title: title,
      description: description,
      isCompleted: isCompleted,
    );
  }

  // Convert pure todo object -> isar object to store in isar db
  static TodoIsar fromDomain(Todo todo) {
    return TodoIsar()
      ..id = todo.id
      ..title = todo.title
      ..description = todo.description ?? ''
      ..isCompleted = todo.isCompleted;
  }
}
