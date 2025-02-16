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
            if (state.completedTodos.isEmpty) {
              return const Center(
                child: TextWidget(
                  text: 'No completed todo found!',
                ),
              );
            }

            final completedTodos = state.completedTodos;

            return ListView.builder(
              itemCount: completedTodos.length,
              itemBuilder: (context, index) {
                final completedTodo = completedTodos[index];

                // if (!todo.isCompleted) {
                //   return const SizedBox.shrink();
                // }

                if (completedTodo.pendingDelete) {
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
                    todoList: completedTodo,
                    isTrailingVisible: false,
                    isSelectionMode: isSelectionMode,
                    isSelected: selectedTodos.contains(completedTodo),
                    onSelected: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          selectedTodos.add(completedTodo);
                        } else {
                          selectedTodos.remove(completedTodo);
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
}
