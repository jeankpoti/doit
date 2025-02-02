import 'package:do_it/features/todo/presentation/todo_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common_widget/loader_widget.dart';
import '../../../common_widget/text_widget.dart';
import '../domain/models/todo.dart';
import 'list_tile_widget.dart';
import 'todo_state.dart';

class CompletedTodoPage extends StatefulWidget {
  const CompletedTodoPage({super.key});

  @override
  State<CompletedTodoPage> createState() => _CompletedTodoPageState();
}

class _CompletedTodoPageState extends State<CompletedTodoPage> {
  bool isSelectionMode = false;
  final Set<Todo> selectedTodos = {};

  @override
  void initState() {
    super.initState();
    // Load only completed todos
    context.read<TodoCubit>().loadCompletedTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Completed Todos',
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
              return Center(
                child: TextWidget(text: 'Error: ${state.errorMsg}'),
              );
            }

            // 3) No todos found
            if (state.todos.isEmpty) {
              return const Center(
                child: TextWidget(
                  text: 'No completed todo found!',
                ),
              );
            }

            final todos = state.todos;

            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];

                if (!todo.isCompleted) {
                  return const SizedBox.shrink();
                }

                if (todo.pendingDelete) {
                  return const SizedBox.shrink();
                }

                return GestureDetector(
                  onLongPress: () {
                    // Enter multi-select mode
                    setState(() {
                      isSelectionMode = true;
                    });
                  },
                  child: ListTileWidget(
                    todoList: todo,
                    isTrailingVisible: false,
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: const AppBarWidget(
  //       title: 'Completed Todos',
  //     ),
  //     body: BlocBuilder<TodoCubit, TodoState>(
  //       builder: (context, state) {
  //         // 1) Loading state
  //         if (state.isLoading) {
  //           return const Center(child: LoaderWidget());
  //         }

  //         // 2) Error state
  //         if (state.errorMsg != null) {
  //           return Center(
  //             child: Text('Error: ${state.errorMsg}'),
  //           );
  //         }

  //         // 3) If no completed todos
  //         if (state.todos.isEmpty) {
  //           return const Center(
  //             child: Text('No completed todos found!'),
  //           );
  //         }

  //         // 4) Show the list of completed todos
  //         final todos = state.todos;
  //         return ListView.builder(
  //           itemCount: todos.length,
  //           itemBuilder: (context, index) {
  //             final todo = todos[index];
  //             // Display each completed todo in a decorative container
  //             return Container(
  //               margin: const EdgeInsets.symmetric(
  //                 horizontal: 12.0,
  //                 vertical: 4.0,
  //               ),
  //               decoration: BoxDecoration(
  //                 color: Theme.of(context).colorScheme.surface,
  //                 borderRadius: BorderRadius.circular(10),
  //                 boxShadow: const [
  //                   BoxShadow(
  //                     color: Colors.black12,
  //                     offset: Offset(0, 2),
  //                     blurRadius: 6.0,
  //                   ),
  //                 ],
  //               ),
  //               child: ListTile(
  //                 title: Text(todo.title),
  //                 subtitle: Text(todo.description ?? ''),
  //               ),
  //             );
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }
}

// import 'package:do_it/common_widget/app_bar_widget.dart';
// import 'package:do_it/features/todo/presentation/todo_cubit.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import '../domain/models/todo.dart';
// import 'list_tile_widget.dart';

// class CompletedTodoPage extends StatefulWidget {
//   const CompletedTodoPage({super.key});

//   @override
//   State<CompletedTodoPage> createState() => _CompletedTodoPageState();
// }

// class _CompletedTodoPageState extends State<CompletedTodoPage> {
//   @override
//   void initState() {
//     super.initState();

//     context.read<TodoCubit>().loadCompletedTodos();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const AppBarWidget(
//         title: 'Completed Todos',
//       ),
//       body: BlocBuilder<TodoCubit, List<Todo>>(
//         builder: (context, todos) {
//           return ListView.builder(
//               itemCount: todos.length,
//               itemBuilder: (context, index) {
//                 return Container(
//                   margin: const EdgeInsets.symmetric(
//                     horizontal: 12.0,
//                     vertical: 4.0,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.surface,
//                     // border: Border.all(),
//                     borderRadius: BorderRadius.circular(10),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Colors.black12,
//                         offset: Offset(0, 2),
//                         blurRadius: 6.0,
//                       ),
//                     ],
//                   ),
//                   child: ListTile(
//                     title: Text(todos[index].title),
//                     subtitle: Text(todos[index].description ?? ''),
//                   ),
//                 );
//               });

//           // ListView.builder(
//           //   itemCount: todos.length,
//           //   itemBuilder: (context, index) {
//           //     final todo = todos[index];
//           //     print('todo: ${todo.title}');
//           //     return ListTileWidget(
//           //       todoList: todo,
//           //       title: todo.title,
//           //       desc: 'todo.description',
//           //     );
//           //   },
//           // );
//         },
//       ),
//     );
//   }
// }
