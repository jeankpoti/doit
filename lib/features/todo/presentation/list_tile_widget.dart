import 'package:do_it/common_widget/text_widget.dart';
import 'package:do_it/features/todo/presentation/todo_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';

import '../../../common_widget/button_widget.dart';
import '../../../common_widget/icon_widget.dart';
import '../../../common_widget/text_form_field_widget.dart';
import '../data/models/isar_todo.dart';
import '../domain/models/todo.dart';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import '../../../common_widget/icon_widget.dart';
import '../../../common_widget/text_widget.dart';
import '../../../common_widget/button_widget.dart';
import '../../../common_widget/text_form_field_widget.dart';
import '../data/models/isar_todo.dart';
import '../domain/models/todo.dart';
import 'todo_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ListTileWidget extends StatefulWidget {
  final String? title, desc;
  final Todo todoList;
  final bool isTrailingVisible;
  bool isChecked = false;
  bool isCompleted = false;

  // ------------------- ADDED FIELDS FOR MULTI-SELECTION ---------------------
  /// Whether the app is currently in multi-selection mode.
  final bool isSelectionMode;

  /// Whether this specific todo is selected in multi-selection mode.
  final bool isSelected;

  /// Callback when user toggles selection of this todo in multi-selection mode.
  final ValueChanged<bool?>? onSelected;
  // --------------------------------------------------------------------------

  ListTileWidget({
    super.key,
    this.title,
    this.desc,
    required this.todoList,
    this.isTrailingVisible = true,
    this.isChecked = false,
    this.isCompleted = false,

    // ------------------- DEFAULT VALUES FOR NEW FIELDS ----------------------
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelected,
    // ------------------------------------------------------------------------
  });

  @override
  State<ListTileWidget> createState() => _ListTileWidgetState();
}

class _ListTileWidgetState extends State<ListTileWidget>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeOutAnimation;
  late Animation<Offset> _slideAnimation;

  final isar = Isar.getInstance();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeOutAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get choices => [
        {
          'title': 'Edit',
          'icon': const IconWidget(
            icon: Icons.edit,
          ),
        },
        {
          'title': 'Delete',
          'icon': const IconWidget(
            icon: Icons.delete,
          ),
        },
      ];

  Future<void> showMyDialog(Todo todo) async {
    final todoCubit = context.read<TodoCubit>();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const TextWidget(
              text: 'Are you sure you want to delete this todo?'),
          actions: <Widget>[
            TextButton(
              child: const TextWidget(text: 'Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const TextWidget(text: 'Delete'),
              onPressed: () {
                todoCubit.deleteTodo(todo);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void handleClick(String value, Todo todo) {
    switch (value) {
      case 'Edit':
        _showBottomSheet(context, todo);
        break;
      case 'Delete':
        showMyDialog(todo);
        break;
    }
  }

  void validateAndUpdate(buildContext, todo) async {
    final FormState form = _formKey.currentState!;
    if (form.validate()) {
      final todoToUpdate = TodoIsar()
        ..id = todo.id
        ..title = _titleController.text
        ..description = _descriptionController.text
        ..isCompleted = todo.isCompleted;

      final todoCubit = context.read<TodoCubit>();
      todoCubit.updateTodo(todoToUpdate);

      _titleController.clear();
      _descriptionController.clear();
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final todoCubit = context.read<TodoCubit>();

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeOutAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 4.0,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 2),
                blurRadius: 6.0,
              ),
            ],
          ),
          // Keep your existing "isCompleted" logic
          child: widget.todoList.isCompleted
              ? const SizedBox.shrink()
              : ListTile(
                  title: TextWidget(text: widget.todoList.title),
                  subtitle: TextWidget(
                    text: widget.todoList.description ?? '',
                  ),

                  // ----------------- MULTI-SELECTION OR COMPLETION CHECKBOX -----------------
                  leading: widget.isSelectionMode
                      ? Checkbox(
                          value: widget.isSelected,
                          // If onSelected is null, do nothing to avoid errors
                          onChanged: widget.onSelected ?? (_) {},
                        )
                      : Checkbox(
                          value: widget.todoList.isCompleted,
                          onChanged: (value) =>
                              todoCubit.toggleTodoStatus(widget.todoList),
                        ),
                  // ---------------------------------------------------------------------------

                  // Keep your existing trailing with pop-up menu, edit, delete
                  trailing: widget.isCompleted
                      ? const SizedBox.shrink()
                      : SizedBox(
                          width: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              widget.isTrailingVisible
                                  ? PopupMenuButton<String>(
                                      icon: const IconWidget(
                                          icon: Icons.more_vert),
                                      onSelected: (String value) {
                                        handleClick(value, widget.todoList);
                                      },
                                      itemBuilder: (BuildContext context) {
                                        return choices.map((choice) {
                                          return PopupMenuItem<String>(
                                            value: choice['title'].toString(),
                                            child: ListTile(
                                              leading: choice['icon'],
                                              title: Text(
                                                  choice['title'].toString()),
                                            ),
                                          );
                                        }).toList();
                                      },
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ),
                ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, Todo todo) {
    _titleController.text = todo.title;
    _descriptionController.text = todo.description ?? '';
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
                      validateAndUpdate(context, todo),
                      Navigator.pop(context),
                    },
                    text: 'Update'.toUpperCase(),
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

// class ListTileWidget extends StatefulWidget {
//   final String? title, desc;
//   final Todo todoList;
//   final bool isTrailingVisible;
//   bool isChecked = false;
//   bool isCompleted = false;

//   ListTileWidget({
//     super.key,
//     this.title,
//     this.desc,
//     required this.todoList,
//     this.isTrailingVisible = true,
//     this.isChecked = false,
//     this.isCompleted = false,
//   });

//   @override
//   State<ListTileWidget> createState() => _ListTileWidgetState();
// }

// class _ListTileWidgetState extends State<ListTileWidget>
//     with SingleTickerProviderStateMixin {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final _titleController = TextEditingController();
//   final _descriptionController = TextEditingController();

//   late AnimationController _animationController;
//   late Animation<double> _fadeOutAnimation;
//   late Animation<Offset> _slideAnimation;

//   final isar = Isar.getInstance();

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );

//     _fadeOutAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOut,
//     ));

//     _slideAnimation = Tween<Offset>(
//       begin: Offset.zero,
//       end: const Offset(1.0, 0.0),
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOut,
//     ));
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   List<Map<String, dynamic>> get choices => [
//         {
//           'title': 'Edit',
//           'icon': const IconWidget(
//             icon: Icons.edit,
//           ),
//         },
//         {
//           'title': 'Delete',
//           'icon': const IconWidget(
//             icon: Icons.delete,
//           ),
//         },
//       ];

//   Future<void> showMyDialog(Todo todo) async {
//     final todoCubit = context.read<TodoCubit>();
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           backgroundColor: Theme.of(context).colorScheme.surface,
//           title: const TextWidget(
//               text: 'Are you sure you want to delete this todo?'),
//           actions: <Widget>[
//             TextButton(
//               child: const TextWidget(
//                 text: 'Cancel',
//               ),
//               onPressed: () => Navigator.pop(context),
//             ),
//             TextButton(
//               child: const TextWidget(
//                 text: 'Delete',
//               ),
//               onPressed: () {
//                 todoCubit.deleteTodo(todo);
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void handleClick(String value, Todo todo) {
//     switch (value) {
//       case 'Edit':
//         _showBottomSheet(context, todo);

//         break;
//       case 'Delete':
//         showMyDialog(todo);
//         break;
//     }
//   }

//   void validateAndUpdate(buildContext, todo) async {
//     final FormState form = _formKey.currentState!;
//     if (form.validate()) {
//       final todoToUpdate = TodoIsar()
//         ..id = todo.id
//         ..title = _titleController.text
//         ..description = _descriptionController.text
//         ..isCompleted = todo.isCompleted;

//       final todoCubit = context.read<TodoCubit>();

//       todoCubit.updateTodo(todoToUpdate);

//       _titleController.clear();
//       _descriptionController.clear();
//     } else {}
//   }

//   @override
//   Widget build(BuildContext context) {
//     final todoCubit = context.read<TodoCubit>();

//     return SlideTransition(
//       position: _slideAnimation,
//       child: FadeTransition(
//         opacity: _fadeOutAnimation,
//         child: Container(
//           margin: const EdgeInsets.symmetric(
//             horizontal: 12.0,
//             vertical: 4.0,
//           ),
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.surface,
//             // border: Border.all(),
//             borderRadius: BorderRadius.circular(10),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.black12,
//                 offset: Offset(0, 2),
//                 blurRadius: 6.0,
//               ),
//             ],
//           ),
//           child: widget.todoList.isCompleted
//               ? const SizedBox.shrink()
//               : ListTile(
//                   title: TextWidget(text: widget.todoList.title),
//                   subtitle: TextWidget(text: widget.todoList.description ?? ''),
//                   leading: Checkbox(
//                       value: widget.todoList.isCompleted,
//                       onChanged: (value) =>
//                           todoCubit.toggleTodoStatus(widget.todoList)),
//                   trailing: widget.isCompleted
//                       ? const SizedBox.shrink()
//                       : SizedBox(
//                           width: 50,
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               widget.isTrailingVisible
//                                   ? PopupMenuButton<String>(
//                                       icon: const IconWidget(
//                                           icon: Icons.more_vert),
//                                       onSelected: (String value) {
//                                         handleClick(value, widget.todoList);
//                                       },
//                                       itemBuilder: (BuildContext context) {
//                                         return choices.map((choice) {
//                                           return PopupMenuItem<String>(
//                                             value: choice['title'].toString(),
//                                             child: ListTile(
//                                               leading: choice['icon'],
//                                               title: Text(
//                                                   choice['title'].toString()),
//                                             ),
//                                           );
//                                         }).toList();
//                                       },
//                                     )
//                                   : const SizedBox.shrink(),
//                             ],
//                           ),
//                         ),
//                 ),
//         ),
//       ),
//     );
//   }

//   void _showBottomSheet(BuildContext context, Todo todo) {
//     _titleController.text = todo.title;
//     _descriptionController.text = todo.description ?? '';
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(16.0),
//           height: 400,
//           width: double.infinity,
//           child: Padding(
//             padding: const EdgeInsets.only(
//               left: 16,
//               top: 50,
//               right: 16,
//               bottom: 50,
//             ),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 spacing: 20,
//                 children: [
//                   TextFormFieldWidget(
//                     controller: _titleController,
//                     labelText: 'Enter your todo\'s title',
//                     validator: (value) =>
//                         value!.isEmpty ? 'Please provide a title' : null,
//                   ),
//                   TextFormFieldWidget(
//                     controller: _descriptionController,
//                     labelText: 'Enter your todo\'s description',
//                     validator: (value) => value!.isEmpty ? null : '',
//                   ),
//                   const SizedBox(height: 25),
//                   ButtonWidget(
//                     onPressed: () => {
//                       validateAndUpdate(context, todo),
//                       Navigator.pop(context)
//                     },
//                     text: 'Update'.toUpperCase(),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
