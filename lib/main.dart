import 'package:do_it/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'features/pomodoro/data/models/isar_pomodoro.dart';
import 'features/pomodoro/data/repository/pomodoro_repo.dart';
import 'features/pomodoro/presentation/pomodoro_cubit.dart';
import 'features/todo/data/models/isar_todo.dart';
import 'features/todo/data/repository/isar_todo_repo.dart';
import 'features/todo/domain/repository/todo_repo.dart';
import 'features/todo/presentation/todo_cubit.dart';
import 'theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get directory path for storing data
  final dir = await getApplicationDocumentsDirectory();

  // Open isar database
  final isar = await Isar.open([TodoIsarSchema, PomodoroSessionSchema],
      directory: dir.path);

  //initialize repo with isar database
  final isarTodoRepo = IsarTodoRepo(isar);

  final pomodoroRepo = IsarPomodoroRepo();

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<TodoCubit>(
        create: (context) => TodoCubit(isarTodoRepo),
      ), // Ensure this is added
      BlocProvider<ThemeCubit>(
        create: (context) => ThemeCubit(),
      ), // Ensure this is added
      BlocProvider<PomodoroCubit>(
        create: (context) => PomodoroCubit(pomodoroRepo),
      ),
    ],
    child: MyApp(
      todoRepo: isarTodoRepo,
    ),
  ));
}

class MyApp extends StatelessWidget {
  // Database injection through the app
  final TodoRepo todoRepo;

  const MyApp({super.key, required this.todoRepo});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, currentTheme) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Work Snap',
          theme: currentTheme,
          home: SplashPage(todoRepo: todoRepo),
          // TodoPage(todoRepo: todoRepo),
        );
      },
    );
  }
}
