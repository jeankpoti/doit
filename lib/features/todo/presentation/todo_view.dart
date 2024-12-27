/*
 TO DO VIEW: Responsible for displaying UI

  - use BlocBuilder to listen to cubit state changes
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common_widget/app_bar_widget.dart';
import '../../../common_widget/button_widget.dart';
import '../../../common_widget/text_form_field_widget.dart';
import '../../../common_widget/text_widget.dart';
import '../domain/models/todo.dart';
import 'add_todo_page.dart';
import 'list_tile_widget.dart';
import 'todo_cubit.dart';

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  void validateAndSave(buildContext) {
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      final todoCubit = context.read<TodoCubit>();
      todoCubit.addTodo(_titleController.text, _descriptionController.text);

      _titleController.clear();
      _descriptionController.clear();
    } else {}
  }

  // Show dialog box to add new todo
  // void _showAddTodoBox(BuildContext context) {
  //   final todoCubit = context.read<TodoCubit>();

  //   final textController = TextEditingController();

  //   showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //             title: const Text('Add Todo'),
  //             content: TextField(controller: textController),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: const Text('Cancel'),
  //               ),
  //               TextButton(
  //                 onPressed: () {
  //                   todoCubit.addTodo(textController.text);
  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text('Add'),
  //               ),
  //             ],
  //           ));
  // }

  @override
  Widget build(BuildContext context) {
    // final todoCubit = context.read<TodoCubit>();
    // final themeCubit = context.read<ThemeCubit>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const AppBarWidget(
        title: 'Todo List',
        isAction: false,
      ),
      body: BlocBuilder<TodoCubit, List<Todo>>(
        builder: (context, todos) {
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return ListTileWidget(
                todoList: todo,
                title: todo.title,
                desc: todo.description,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(context),
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const AddTodoPage(),
        //   ),
        // ),
        // _showAddTodoBox(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 400,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              top: 50,
              right: 16,
              bottom: 50,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                spacing: 20,
                children: [
                  TextFormFieldWidget(
                    controller: _titleController,
                    labelText: 'Enter your todo\'s title',
                    validator: (value) =>
                        value!.isEmpty ? 'Please provide a title' : null,
                  ),
                  TextFormFieldWidget(
                    controller: _descriptionController,
                    labelText: 'Enter your todo\'s description',
                    validator: (value) => value!.isEmpty ? null : '',
                  ),
                  const SizedBox(height: 25),
                  ButtonWidget(
                    onPressed: () => {
                      validateAndSave(context),
                      Navigator.pop(context),
                    },
                    text: 'Save'.toUpperCase(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
