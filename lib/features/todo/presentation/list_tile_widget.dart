import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../common_widget/icon_widget.dart';
import '../../../common_widget/text_small_widget.dart';
import '../../../common_widget/text_widget.dart';
import '../domain/models/todo.dart';
import 'todo_cubit.dart';
import 'update_todo_page.dart';

class ListTileWidget extends StatefulWidget {
  final String? title, desc, createdAt;
  final Todo todoList;
  final bool isTrailingVisible;
  bool isChecked = false;
  bool isCompleted = false;
  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelected;
  final VoidCallback? onAnimationComplete;

  ListTileWidget({
    super.key,
    this.title,
    this.desc,
    this.createdAt,
    required this.todoList,
    this.isTrailingVisible = true,
    this.isChecked = false,
    this.isCompleted = false,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelected,
    this.onAnimationComplete,
  });

  @override
  State<ListTileWidget> createState() => _ListTileWidgetState();
}

class _ListTileWidgetState extends State<ListTileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeOutAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

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
      end: const Offset(1.5, 0.0),
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Listen for animation completion to notify parent
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed &&
          widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }
    });
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
                // Run animation before actual deletion
                _animateAndDelete(todo, todoCubit);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _animateAndDelete(Todo todo, TodoCubit todoCubit) async {
    // Start the animation
    await _animationController.forward();
    // Delete the todo after animation completes
    todoCubit.deleteTodo(todo);
  }

  void _animateAndToggleStatus(Todo todo, TodoCubit todoCubit) async {
    if (!todo.isCompleted) {
      // Only animate when completing a todo, not when marking as incomplete
      todoCubit.toggleComletedTodoStatus(todo);
    } else {
      // Start the animation for completion
      await _animationController.forward();
      // Toggle status after animation completes
      todoCubit.toggleComletedTodoStatus(todo);
    }
  }

  void handleClick(String value, Todo todo) {
    switch (value) {
      case 'Edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateTodoPage(
              todo: todo,
            ),
          ),
        );
        break;
      case 'Delete':
        showMyDialog(todo);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoCubit = context.read<TodoCubit>();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeOutAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
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
                child: ListTile(
                  title: TextWidget(
                    text: widget.todoList.title,
                    maxLine: 1,
                  ),
                  subtitle: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      TextSmallWidget(
                        text: widget.todoList.description ?? '',
                        maxLine: 1,
                      ),
                      TextSmallWidget(
                        text: widget.todoList.createdAt != null
                            ? DateFormat('MMMM dd, yyyy').format(
                                widget.todoList.createdAt,
                              )
                            : '',
                        maxLine: 1,
                      ),
                    ],
                  ),

                  // Selection or completion checkbox
                  leading: widget.isSelectionMode
                      ? Checkbox(
                          value: widget.isSelected,
                          onChanged: widget.onSelected ?? (_) {},
                        )
                      : Checkbox(
                          value: widget.todoList.isCompleted,
                          onChanged: (value) {
                            // If completing a todo, animate first
                            if (value == true) {
                              _animateAndToggleStatus(
                                  widget.todoList, todoCubit);
                            } else {
                              // Just toggle if marking as incomplete
                              todoCubit
                                  .toggleComletedTodoStatus(widget.todoList);
                            }
                          },
                        ),

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
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';

// // import '../../../common_widget/button_widget.dart';
// import '../../../common_widget/icon_widget.dart';
// // import '../../../common_widget/text_form_field_widget.dart';
// import '../../../common_widget/text_small_widget.dart';
// import '../../../common_widget/text_widget.dart';
// import '../domain/models/todo.dart';
// import 'todo_cubit.dart';
// import 'update_todo_page.dart';

// class ListTileWidget extends StatefulWidget {
//   final String? title, desc, createdAt;
//   final Todo todoList;
//   final bool isTrailingVisible;
//   bool isChecked = false;
//   bool isCompleted = false;
//   final bool isSelectionMode;
//   final bool isSelected;
//   final ValueChanged<bool?>? onSelected;

//   ListTileWidget({
//     super.key,
//     this.title,
//     this.desc,
//     this.createdAt,
//     required this.todoList,
//     this.isTrailingVisible = true,
//     this.isChecked = false,
//     this.isCompleted = false,
//     this.isSelectionMode = false,
//     this.isSelected = false,
//     this.onSelected,
//   });

//   @override
//   State<ListTileWidget> createState() => _ListTileWidgetState();
// }

// class _ListTileWidgetState extends State<ListTileWidget>
//     with SingleTickerProviderStateMixin {
//   // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   // final _titleController = TextEditingController();
//   // final _descriptionController = TextEditingController();

//   late AnimationController _animationController;
//   late Animation<double> _fadeOutAnimation;
//   late Animation<Offset> _slideAnimation;

//   // final isar = Isar.getInstance();

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
//     ).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeOut,
//       ),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: Offset.zero,
//       end: const Offset(1.0, 0.0),
//     ).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeOut,
//       ),
//     );
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
//               child: const TextWidget(text: 'Cancel'),
//               onPressed: () => Navigator.pop(context),
//             ),
//             TextButton(
//               child: const TextWidget(text: 'Delete'),
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
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => UpdateTodoPage(
//               todo: todo,
//             ),
//           ),
//         );
//         // _showBottomSheet(context, todo);
//         break;
//       case 'Delete':
//         showMyDialog(todo);
//         break;
//     }
//   }

//   // void validateAndUpdate(buildContext, todo) async {
//   //   final FormState form = _formKey.currentState!;
//   //   if (form.validate()) {
//   //     // final todoToUpdate = TodoIsar()
//   //     final todoToUpdate = TodoIsar()
//   //       ..id = todo.id
//   //       ..title = _titleController.text
//   //       ..description = _descriptionController.text
//   //       ..isCompleted = todo.isCompleted;

//   //     final todoCubit = context.read<TodoCubit>();
//   //     // todoCubit.updateTodo(todoToUpdate);

//   //     _titleController.clear();
//   //     _descriptionController.clear();
//   //   } else {}
//   // }

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
//             borderRadius: BorderRadius.circular(10),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.black12,
//                 offset: Offset(0, 2),
//                 blurRadius: 6.0,
//               ),
//             ],
//           ),
//           // Keep your existing "isCompleted" logic
//           child: ListTile(
//             title: TextWidget(
//               text: widget.todoList.title,
//               maxLine: 1,
//             ),

//             subtitle: Wrap(
//               alignment: WrapAlignment.spaceBetween,
//               children: [
//                 TextSmallWidget(
//                   text: widget.todoList.description ?? '',
//                   maxLine: 1,
//                 ),
//                 TextSmallWidget(
//                   text: widget.todoList.createdAt != null
//                       ? DateFormat('MMMM dd, yyyy').format(
//                           widget.todoList.createdAt,
//                         )
//                       : '',
//                   maxLine: 1,
//                 ),
//               ],
//             ),

//             // ----------------- MULTI-SELECTION OR COMPLETION CHECKBOX -----------------
//             leading: widget.isSelectionMode
//                 ? Checkbox(
//                     value: widget.isSelected,
//                     // If onSelected is null, do nothing to avoid errors
//                     onChanged: widget.onSelected ?? (_) {},
//                   )
//                 : Checkbox(
//                     value: widget.todoList.isCompleted,
//                     onChanged: (value) =>
//                         todoCubit.toggleComletedTodoStatus(widget.todoList),
//                   ),

//             trailing: widget.isCompleted
//                 ? const SizedBox.shrink()
//                 : SizedBox(
//                     width: 50,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         widget.isTrailingVisible
//                             ? PopupMenuButton<String>(
//                                 icon: const IconWidget(icon: Icons.more_vert),
//                                 onSelected: (String value) {
//                                   handleClick(value, widget.todoList);
//                                 },
//                                 itemBuilder: (BuildContext context) {
//                                   return choices.map((choice) {
//                                     return PopupMenuItem<String>(
//                                       value: choice['title'].toString(),
//                                       child: ListTile(
//                                         leading: choice['icon'],
//                                         title: Text(choice['title'].toString()),
//                                       ),
//                                     );
//                                   }).toList();
//                                 },
//                               )
//                             : const SizedBox.shrink(),
//                       ],
//                     ),
//                   ),
//           ),
//         ),
//       ),
//     );
//   }

//   // void _showBottomSheet(BuildContext context, Todo todo) {
//   //   _titleController.text = todo.title;
//   //   _descriptionController.text = todo.description ?? '';
//   //   showModalBottomSheet(
//   //     context: context,
//   //     builder: (BuildContext context) {
//   //       return Container(
//   //         padding: const EdgeInsets.all(16.0),
//   //         height: 400,
//   //         width: double.infinity,
//   //         child: Padding(
//   //           padding: const EdgeInsets.only(
//   //             left: 16,
//   //             top: 50,
//   //             right: 16,
//   //             bottom: 50,
//   //           ),
//   //           child: Form(
//   //             key: _formKey,
//   //             child: Column(
//   //               spacing: 20,
//   //               children: [
//   //                 TextFormFieldWidget(
//   //                   controller: _titleController,
//   //                   labelText: 'Enter your todo\'s title',
//   //                   validator: (value) =>
//   //                       value!.isEmpty ? 'Please provide a title' : null,
//   //                 ),
//   //                 TextFormFieldWidget(
//   //                   controller: _descriptionController,
//   //                   labelText: 'Enter your todo\'s description',
//   //                   validator: (value) => value!.isEmpty ? null : '',
//   //                 ),
//   //                 const SizedBox(height: 25),
//   //                 ButtonWidget(
//   //                   onPressed: () => {
//   //                     validateAndUpdate(context, todo),
//   //                     Navigator.pop(context),
//   //                   },
//   //                   text: 'Update'.toUpperCase(),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }
// }
