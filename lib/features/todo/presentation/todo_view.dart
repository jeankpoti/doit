/*
 TO DO VIEW: Responsible for displaying UI

  - use BlocBuilder to listen to cubit state changes
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common_widget/app_bar_widget.dart';
import '../domain/models/todo.dart';
import '../../../theme/theme_cubit.dart';
import 'todo_cubit.dart';

class TodoView extends StatelessWidget {
  const TodoView({super.key});

  // Show dialog box to add new todo
  void _showAddTodoBox(BuildContext context) {
    final todoCubit = context.read<TodoCubit>();

    final textController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Add Todo'),
              content: TextField(controller: textController),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    todoCubit.addTodo(textController.text);
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final todoCubit = context.read<TodoCubit>();
    // final themeCubit = context.read<ThemeCubit>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const AppBarWidget(
        title: 'Todo List',
        isAction: true,
      ),
      body: BlocBuilder<TodoCubit, List<Todo>>(
        builder: (context, todos) {
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return ListTile(
                title: Text(todo.text),
                leading: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (value) => todoCubit.toggleTodoStatus(todo)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    todoCubit.deleteTodo(todo);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoBox(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
