import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common_widget/app_bar_widget.dart';
import '../../../common_widget/button_widget.dart';
import '../../../common_widget/text_form_field_widget.dart';
import 'todo_cubit.dart';

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
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
                    maxLine: 100,
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
        ));
  }
}
