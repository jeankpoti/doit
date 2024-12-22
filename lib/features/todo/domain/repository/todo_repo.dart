/*
TodoRepo is an abstract class that defines the methods that the TodoRepository class must implement.

Here we define what the app can do
*/

import '../models/todo.dart';

abstract class TodoRepo {
  Future<void> addTodo(Todo todo);
  Future<void> deleteTodo(Todo todo);
  Future<void> updateTodo(Todo todo);
  Future<List<Todo>> getTodos();
}


/*

The repo in domain layer outlines what operations the app can do, bu
it doesn't worry about the specific implementation details. That's for the data layer.

- Everything in the domain layer should be technology-agnostic, which means it 
should not depend on any specific libraries or frameworks.

*/
