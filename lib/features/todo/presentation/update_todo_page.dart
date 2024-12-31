import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common_widget/app_bar_widget.dart';
import '../../../common_widget/button_widget.dart';
import '../../../common_widget/text_form_field_widget.dart';
import '../domain/models/todo.dart';
import 'todo_cubit.dart';

class UpdateTodoPage extends StatefulWidget {
  final Todo todo;
  const UpdateTodoPage({super.key, required this.todo});

  @override
  State<UpdateTodoPage> createState() => _UpdateTodoPageState();
}

class _UpdateTodoPageState extends State<UpdateTodoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _titleController.text = widget.todo.title;
    _descriptionController.text = widget.todo.description ?? '';
  }

  void validateAndUpdate(buildContext, todo) async {
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      final todoToUpdate = Todo(
          id: todo.id,
          title: _titleController.text,
          description: _descriptionController.text,
          isCompleted: todo.isCompleted);

      final todoCubit = context.read<TodoCubit>();
      todoCubit.updateTodo(todoToUpdate);

      _titleController.clear();
      _descriptionController.clear();
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarWidget(
          title: 'Add Todo',
          isAction: false,
        ),
        body: SafeArea(
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
                      validateAndUpdate(context, widget.todo),
                      Navigator.pop(context),
                    },
                    text: 'Update'.toUpperCase(),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
