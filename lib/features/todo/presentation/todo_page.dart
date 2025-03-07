import 'package:do_it/common_widget/loader_widget.dart';
import 'package:do_it/common_widget/text_small_widget.dart';
import 'package:do_it/features/pomodoro/domain/models/pomodoro.dart';
import 'package:do_it/features/pomodoro/presentation/pomodoro_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common_widget/text_widget.dart';
import '../domain/models/todo.dart';
import '../domain/repository/todo_repo.dart';
import 'add_todo_page.dart';
import 'list_tile_widget.dart';
import 'todo_cubit.dart';
import 'todo_details_page.dart';
import 'todo_state.dart';

class TodoPage extends StatefulWidget {
  final TodoRepo? todoRepo;
  const TodoPage({super.key, required this.todoRepo});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  bool isSelectionMode = false;
  final Set<Todo> selectedTodos = {};

  @override
  void initState() {
    super.initState();
    // Load the todos when this page is first built
    context.read<TodoCubit>().loadTodos();
  }

  Future<void> _refreshData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await Future.wait([
        // Sync todos first
        context.read<TodoCubit>().syncTodosIfNeeded(),
        context.read<TodoCubit>().loadTodos(),

        // Sync Pomodoro data as well
        context.read<PomodoroCubit>().syncPomodoroIfNeeded(),
        context.read<PomodoroCubit>().getSessions(),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Todos',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        actions: [
          if (isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: selectedTodos.isEmpty ? null : _deleteSelectedTodos,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  isSelectionMode = false;
                  selectedTodos.clear();
                });
              },
            )
          ]
        ],
      ),
      body: SafeArea(
        // Now we build based on TodoState instead of List<Todo>
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: BlocBuilder<TodoCubit, TodoState>(
            builder: (context, state) {
              // 1) Loading
              if (state.isLoading) {
                return const Center(
                  child: LoaderWidget(),
                );
              }

              // 2) Error
              if (state.errorMsg != null) {
                return const Center(
                  child: TextSmallWidget(text: 'Something went wrong!'),
                );
              }

              // 3) No todos found
              if (state.todos.isEmpty) {
                return const Center(
                  child: TextSmallWidget(
                    text: 'No todo found!',
                  ),
                );
              }

              // 4) Show the todos list
              final todos = state.todos;

              return ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  final todo = todos[index];
                  // Optionally hide completed
                  // if (todo.isCompleted) {
                  //   return const SizedBox.shrink();
                  // }
                  if (todo.pendingDelete) {
                    return const SizedBox.shrink();
                  }

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TodoDetailsPage(todo: todo),
                      ),
                    ),
                    onLongPress: () {
                      // Enter multi-select mode
                      setState(() {
                        isSelectionMode = true;
                      });
                    },
                    child: ListTileWidget(
                      todoList: todo,
                      isTrailingVisible: true,
                      isSelectionMode: isSelectionMode,
                      isSelected: selectedTodos.contains(todo),
                      onSelected: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            selectedTodos.add(todo);
                          } else {
                            selectedTodos.remove(todo);
                          }
                        });
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),

      // FAB to open a separate AddTodoPage
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddTodoPage(),
          ),
        ),
        child: const Icon(Icons.add),
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  /// Deletes all selected todos, then exits selection mode
  void _deleteSelectedTodos() async {
    final todoCubit = context.read<TodoCubit>();

    for (final todo in selectedTodos) {
      await todoCubit.deleteTodo(todo);
    }

    setState(() {
      selectedTodos.clear();
      isSelectionMode = false;
    });
  }
}




// /*
//  TO DO VIEW: Responsible for displaying UI

//   - use BlocBuilder to listen to cubit state changes
// */

// import 'package:do_it/common_widget/text_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../domain/models/todo.dart';
// import '../domain/repository/todo_repo.dart';
// import 'add_todo_page.dart';
// import 'list_tile_widget.dart';
// import 'todo_cubit.dart';

// class TodoPage extends StatefulWidget {
//   final TodoRepo? todoRepo;
//   const TodoPage({super.key, required this.todoRepo});

//   @override
//   State<TodoPage> createState() => _TodoPageState();
// }

// class _TodoPageState extends State<TodoPage> {
//   bool isSelectionMode = false;
//   final Set<Todo> selectedTodos = {};

//   // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   // final _titleController = TextEditingController();
//   // final _descriptionController = TextEditingController();

//   // void validateAndSave(buildContext) {
//   //   final FormState form = _formKey.currentState!;
//   //   if (form.validate()) {
//   //     final todoCubit = context.read<TodoCubit>();
//   //     todoCubit.addTodo(_titleController.text, _descriptionController.text);

//   //     _titleController.clear();
//   //     _descriptionController.clear();
//   //   } else {}
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Todos',
//           style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//         ),
//         actions: [
//           if (isSelectionMode) ...[
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: selectedTodos.isEmpty ? null : _deleteSelectedTodos,
//             ),
//             IconButton(
//               icon: const Icon(Icons.close),
//               onPressed: () {
//                 setState(() {
//                   isSelectionMode = false;
//                   selectedTodos.clear();
//                 });
//               },
//             )
//           ]
//         ],
//       ),
//       body: SafeArea(
//         child: BlocBuilder<TodoCubit, List<Todo>>(
//           builder: (context, todos) {
//             return todos.isEmpty
//                 ? const Center(
//                     child: TextWidget(
//                       text: 'No todo found!',
//                     ),
//                   )
//                 : ListView.builder(
//                     itemCount: todos.length,
//                     itemBuilder: (context, index) {
//                       final todo = todos[index];

//                       return todo.isCompleted
//                           ? const SizedBox.shrink()
//                           : GestureDetector(
//                               onLongPress: () {
//                                 // Enter multi-select mode
//                                 setState(() {
//                                   isSelectionMode = true;
//                                 });
//                               },
//                               child: ListTileWidget(
//                                 todoList: todo,

//                                 isTrailingVisible: true,
//                                 // New multi-select parameters:
//                                 isSelectionMode: isSelectionMode,
//                                 isSelected: selectedTodos.contains(todo),
//                                 onSelected: (bool? selected) {
//                                   setState(() {
//                                     if (selected == true) {
//                                       selectedTodos.add(todo);
//                                     } else {
//                                       selectedTodos.remove(todo);
//                                     }
//                                   });
//                                 },
//                               ),
//                             );
//                     },
//                   );
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const AddTodoPage(),
//           ),
//         ),
//         child: const Icon(Icons.add),
//       ),
//       resizeToAvoidBottomInset: true,
//     );
//   }

//   void _deleteSelectedTodos() {
//     final todoCubit = context.read<TodoCubit>();
//     for (final todo in selectedTodos) {
//       todoCubit.deleteTodo(todo);
//     }
//     setState(() {
//       selectedTodos.clear();
//       isSelectionMode = false;
//     });
//   }
// }


//   // void _showBottomSheet(BuildContext context) {
//   //   showModalBottomSheet(
//   //     context: context,
//   //     isScrollControlled: true,
//   //     useSafeArea: true,
//   //     builder: (BuildContext context) {
//   //       return Scaffold(
//   //         resizeToAvoidBottomInset: true,
//   //         body: Container(
//   //           padding: const EdgeInsets.all(16.0),
//   //           height: 400,
//   //           width: double.infinity,
//   //           child: Padding(
//   //             padding: const EdgeInsets.only(
//   //               left: 16,
//   //               top: 50,
//   //               right: 16,
//   //               bottom: 50,
//   //             ),
//   //             child: Form(
//   //               key: _formKey,
//   //               child: Column(
//   //                 spacing: 20,
//   //                 children: [
//   //                   TextFormFieldWidget(
//   //                     controller: _titleController,
//   //                     labelText: 'Enter your todo\'s title',
//   //                     validator: (value) =>
//   //                         value!.isEmpty ? 'Please provide a title' : null,
//   //                   ),
//   //                   TextFormFieldWidget(
//   //                     controller: _descriptionController,
//   //                     labelText: 'Enter your todo\'s description',
//   //                     validator: (value) => value!.isEmpty ? null : '',
//   //                   ),
//   //                   const SizedBox(height: 25),
//   //                   ButtonWidget(
//   //                     onPressed: () => {
//   //                       validateAndSave(context),
//   //                       Navigator.pop(context),
//   //                     },
//   //                     text: 'Save'.toUpperCase(),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }

  
  
  
 