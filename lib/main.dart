import 'package:do_it/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart' as path;
import 'dart:io' show Platform;

import 'features/pomodoro/data/repository/pomodoro_repo.dart';
import 'features/pomodoro/presentation/pomodoro_cubit.dart';
import 'features/todo/data/repository/sembast_todo_repo.dart';
import 'features/todo/domain/repository/todo_repo.dart';
import 'features/todo/presentation/todo_cubit.dart';
import 'theme/theme_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    // Initialize flutter_background for Android
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "Pomodoro Timer",
      notificationText: "Timer is running in the background",
      notificationImportance: AndroidNotificationImportance.normal,
      notificationIcon:
          AndroidResource(name: 'background_icon', defType: 'drawable'),
    );

    bool initialized =
        await FlutterBackground.initialize(androidConfig: androidConfig);
    if (!initialized) {
      print('Failed to initialize background execution');
    }
  } else if (Platform.isIOS) {
    // Handle iOS-specific background task initialization if needed
    print('iOS does not support flutter_background plugin.');
  }
  // bool hasPermissions = await FlutterBackground.hasPermissions;
  // if (!hasPermissions) {
  //   hasPermissions = await FlutterBackground.reques();
  // }
  // if (hasPermissions) {
  //   await FlutterBackground.initialize(androidConfig: androidConfig);
  // }

  // get the application documents directory
  final dir = await getApplicationDocumentsDirectory();
// make sure it exists
  await dir.create(recursive: true);
// build the database path
  final dbPath = path.join(dir.path, 'my_database.db');
// open the database
  final db = await databaseFactoryIo.openDatabase(dbPath);

  //initialize repo with isar database
  final isarTodoRepo = SembastTodoRepo(db);

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
